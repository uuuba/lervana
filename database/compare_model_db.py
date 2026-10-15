"""Перевірка відповідності бази даних MySQL моделі MySQL Workbench.

Порівнює ER-модель (.mwb) із живою базою за трьома ознаками:
  * склад таблиць;
  * колонки та їхні типи (varchar-довжина, unsigned, tinyint(1) для bool);
  * зв'язки foreign key (таблиця, посилання, колонка).

Запуск (з теки проєкту):
    .venv\\Scripts\\python.exe database\\compare_model_db.py [шлях.do.mwb]

За замовчуванням перевіряється docs/ERD.mwb (копія моделі у проєкті).
Результат також записується у database/model-vs-db.txt.
"""
import os
import sys
import zipfile
import xml.etree.ElementTree as ET
from collections import defaultdict

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')

import django
django.setup()

from django.db import connection  # noqa: E402

BASE = os.path.dirname(os.path.abspath(__file__))
MWB = sys.argv[1] if len(sys.argv) > 1 else os.path.join(BASE, '..', 'docs', 'ERD.mwb')


def kv(v, key):
    for c in v.findall('./value'):
        if c.get('key') == key:
            return c
    return None


def read_model(path):
    """Повертає (таблиці, зв'язки FK) з файлу моделі Workbench."""
    root = ET.fromstring(zipfile.ZipFile(path).read('document.mwb.xml').decode('utf-8', 'ignore'))
    id_to_table, id_to_col, tables = {}, {}, {}

    for v in root.iter('value'):
        oid, sid = v.get('id'), v.get('struct-name')
        if not oid:
            continue
        name = kv(v, 'name')
        if name is None:
            continue
        if sid in ('db.mysql.Table', 'db.Table'):
            id_to_table[oid] = name.text
        elif sid in ('db.mysql.Column', 'db.Column'):
            id_to_col[oid] = name.text

    for v in root.iter('value'):
        if v.get('struct-name') != 'db.mysql.Table':
            continue
        tname = kv(v, 'name').text
        cols = {}
        colsv = kv(v, 'columns')
        if colsv is not None:
            for c in colsv.findall('./value'):
                cname = kv(c, 'name').text
                st = c.find("./link[@key='simpleType']")
                typ = st.text.split('.')[-1] if st is not None else '?'
                length = kv(c, 'length')
                if typ in ('varchar', 'char') and length is not None \
                        and length.text not in (None, '-1', '0'):
                    typ = f'{typ}({length.text})'
                flags = kv(c, 'flags')
                if flags is not None and 'unsigned' in [f.text for f in flags.findall('./value')]:
                    typ += ' unsigned'
                if typ == 'tinyint':          # Bool у Workbench = tinyint(1)
                    typ = 'tinyint(1)'
                cols[cname] = typ
        tables[tname] = cols

    fk = set()
    for v in root.iter('value'):
        if v.get('struct-name') != 'db.mysql.ForeignKey':
            continue
        owner, ref = v.find("./link[@key='owner']"), v.find("./link[@key='referencedTable']")
        cols_v = kv(v, 'columns')
        if owner is None or ref is None or cols_v is None:
            continue
        tname, rt = id_to_table.get(owner.text), id_to_table.get(ref.text)
        if not tname or not rt:
            continue
        for cc in cols_v.findall('./link'):
            cn = id_to_col.get(cc.text)
            if cn:
                fk.add((tname, rt, cn))
    return tables, fk


def read_database():
    """Повертає (таблиці, зв'язки FK) з живої бази MySQL."""
    cur = connection.cursor()
    cur.execute("""
        SELECT table_name, column_name, column_type
        FROM information_schema.columns
        WHERE table_schema=%s ORDER BY table_name, ordinal_position
    """, [connection.settings_dict['NAME']])
    tables = defaultdict(dict)
    for t, c, typ in cur.fetchall():
        tables[t][c] = typ

    cur.execute("""
        SELECT table_name, column_name, referenced_table_name
        FROM information_schema.key_column_usage
        WHERE table_schema=%s AND referenced_table_name IS NOT NULL
    """, [connection.settings_dict['NAME']])
    fk = {(t, rt, c) for t, c, rt in cur.fetchall()}
    return dict(tables), fk


def norm(t):
    """Нормалізація дрібних розбіжностей подання (не впливає на схему)."""
    if t.startswith('datetime'):
        t = 'datetime'
    if t.startswith('text') or t == 'longtext':
        t = 'text'
    if t.startswith('int'):
        t = t.replace('int unsigned', 'int')
    if t.startswith('smallint'):
        t = t.replace('smallint unsigned', 'smallint')
    return t


def main():
    model, model_fk = read_model(MWB)
    live, live_fk = read_database()

    lines = []

    def out(s=''):
        print(s)
        lines.append(s)

    out('ПОРІВНЯННЯ: MySQL Workbench модель vs база MySQL')
    out(f'модель: {os.path.basename(MWB)}   база: {connection.settings_dict["NAME"]}')
    out('=' * 74)
    out(f'Таблиць: модель {len(model)} | база {len(live)}')
    out(f'  лише в моделі: {sorted(set(model) - set(live)) or "немає"}')
    out(f'  лише в базі  : {sorted(set(live) - set(model)) or "немає"}')

    diffs = []
    for t in sorted(set(model) & set(live)):
        mc, lc = model[t], live[t]
        for c in sorted(set(mc) | set(lc)):
            if c not in lc:
                diffs.append(f'колонка лише в моделі: {t}.{c} = {mc[c]}')
            elif c not in mc:
                diffs.append(f'колонка лише в базі  : {t}.{c} = {lc[c]}')
            elif norm(mc[c]) != norm(lc[c]):
                diffs.append(f'тип: {t}.{c}  модель={mc[c]}  база={lc[c]}')
    out(f'Колонок: модель {sum(len(c) for c in model.values())} | '
        f'база {sum(len(c) for c in live.values())}')
    out(f'Розбіжностей за колонками/типами: {len(diffs)}')
    for d in diffs:
        out('  - ' + d)

    out(f'Звʼязків FK: модель {len(model_fk)} | база {len(live_fk)}')
    out(f'  лише в моделі: {sorted(model_fk - live_fk) or "немає"}')
    out(f'  лише в базі  : {sorted(live_fk - model_fk) or "немає"}')

    ok = set(model) == set(live) and not diffs and model_fk == live_fk
    out('')
    out('ВИСНОВОК: ' + ('структури ЗБІГАЮТЬСЯ повністю' if ok else 'Є РОЗБІЖНОСТІ (див. вище)'))

    with open(os.path.join(BASE, 'model-vs-db.txt'), 'w', encoding='utf-8') as f:
        f.write('\n'.join(lines) + '\n')
    return 0 if ok else 1


if __name__ == '__main__':
    sys.exit(main())
