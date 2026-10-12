"""SVG-іконки (однаковий стиль 24×24, stroke) та обкладинки курсів.

Іконки: ``{% icon 'назва' %}`` → інлайновий SVG із ``class="ic"``.
Обкладинки: ``{% cover course %}`` → SVG 320×160 із фото, градієнтом, віньєткою та мотивом.
"""
from django.templatetags.static import static

ICONS = {
    # навігація
    'home': '<path d="m3 10 9-7 9 7v10a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><path d="M9 22V12h6v10"/>',
    'search': '<circle cx="11" cy="11" r="7"/><path d="m21 21-4.3-4.3"/>',
    'compass': '<circle cx="12" cy="12" r="9"/><path d="m15.5 8.5-2 5-5 2 2-5z"/>',
    'spark': '<path d="M12 3l1.9 5.1L19 10l-5.1 1.9L12 17l-1.9-5.1L5 10l5.1-1.9z"/><path d="M19 3v4M21 5h-4"/>',
    'list': '<path d="M3 6h.01M3 12h.01M3 18h.01M8 6h13M8 12h13M8 18h13"/>',
    'target': '<circle cx="12" cy="12" r="9"/><circle cx="12" cy="12" r="5"/><circle cx="12" cy="12" r="1"/>',
    'trend': '<path d="m22 7-8.5 8.5-5-5L2 17"/><path d="M16 7h6v6"/>',
    'bookmark': '<path d="M19 21l-7-5-7 5V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2z"/>',
    'chat': '<path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/>',
    'user': '<circle cx="12" cy="8" r="4"/><path d="M4 21a8 8 0 0 1 16 0"/>',
    'users': '<circle cx="9" cy="8" r="3.5"/><path d="M2.5 20a6.5 6.5 0 0 1 13 0"/><path d="M16 5.5a3.5 3.5 0 0 1 0 7"/><path d="M17.5 14.5A6.5 6.5 0 0 1 21.5 20"/>',
    'sliders': '<path d="M4 6h10M18 6h2M4 12h2M10 12h10M4 18h12M20 18h0"/><circle cx="16" cy="6" r="2"/><circle cx="8" cy="12" r="2"/><circle cx="18" cy="18" r="2"/>',
    'bell': '<path d="M6 8a6 6 0 0 1 12 0c0 7 3 9 3 9H3s3-2 3-9"/><path d="M10.3 21a1.9 1.9 0 0 0 3.4 0"/>',
    'sun': '<circle cx="12" cy="12" r="4"/><path d="M12 2v2M12 20v2M4.9 4.9l1.4 1.4M17.7 17.7l1.4 1.4M2 12h2M20 12h2M4.9 19.1l1.4-1.4M17.7 6.3l1.4-1.4"/>',
    'moon': '<path d="M21 12.8A9 9 0 1 1 11.2 3a7 7 0 0 0 9.8 9.8z"/>',
    'menu': '<path d="M4 6h16M4 12h16M4 18h16"/>',
    'close': '<path d="M18 6 6 18M6 6l12 12"/>',
    # зміст
    'clock': '<circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/>',
    'check': '<path d="M20 6 9 17l-5-5"/>',
    'check_c': '<circle cx="12" cy="12" r="9"/><path d="m8 12 3 3 5-6"/>',
    'play': '<path d="M6 4l14 8-14 8z"/>',
    'flame': '<path d="M12 2c1 4 5 5.5 5 10a5 5 0 0 1-10 0c0-2 1-3 2-4 .3 1.5 1 2 2 2 0-3-1-5 1-8z"/>',
    'star': '<path d="m12 3 2.7 5.6 6.3.9-4.5 4.3 1 6.2-5.5-3-5.5 3 1-6.2L3 9.5l6.3-.9z"/>',
    'heart': '<path d="M12 20s-7-4.4-7-9.5A4 4 0 0 1 12 7a4 4 0 0 1 7 3.5C19 15.6 12 20 12 20z"/>',
    'eye': '<path d="M2 12s3.5-6 10-6 10 6 10 6-3.5 6-10 6-10-6-10-6z"/><circle cx="12" cy="12" r="2.5"/>',
    'plus': '<path d="M12 5v14M5 12h14"/>',
    'trash': '<path d="M4 7h16M9 7V5a1 1 0 0 1 1-1h4a1 1 0 0 1 1 1v2M6 7l1 13a1 1 0 0 0 1 1h8a1 1 0 0 0 1-1l1-13"/>',
    'refresh': '<path d="M20 11A8 8 0 0 0 6 6.5L4 8"/><path d="M4 4v4h4"/><path d="M4 13a8 8 0 0 0 14 4.5l2-1.5"/><path d="M20 20v-4h-4"/>',
    'info': '<circle cx="12" cy="12" r="9"/><path d="M12 11v5M12 8h.01"/>',
    'question': '<circle cx="12" cy="12" r="9"/><path d="M9.5 9.5a2.5 2.5 0 1 1 3.5 2.3c-.7.4-1 .9-1 1.7"/><path d="M12 17h.01"/>',
    'lightbulb': '<path d="M9 18h6"/><path d="M10 21h4"/><path d="M12 3a6 6 0 0 0-3.5 10.8c.6.5 1 1.2 1 2h5c0-.8.4-1.5 1-2A6 6 0 0 0 12 3z"/>',
    'calendar': '<rect x="3" y="5" width="18" height="16" rx="2"/><path d="M3 10h18M8 3v4M16 3v4"/>',
    'award': '<circle cx="12" cy="9" r="5"/><path d="m8.5 13.5-1.5 8 5-3 5 3-1.5-8"/>',
    'graduation': '<path d="M2 8.5 12 4l10 4.5-10 4.5z"/><path d="M6 11v5c0 1.5 2.7 3 6 3s6-1.5 6-3v-5"/>',
    'bolt': '<path d="M13 2 4 14h7l-1 8 9-12h-7z"/>',
    'layers': '<path d="m12 3 9 5-9 5-9-5z"/><path d="m3 13 9 5 9-5"/><path d="m3 17.5 9 5 9-5"/>',
    'filter': '<path d="M3 5h18l-7 8v6l-4 2v-8z"/>',
    'code': '<path d="m8 8-4 4 4 4"/><path d="m16 8 4 4-4 4"/><path d="m13 5-2 14"/>',
    'terminal': '<rect x="3" y="4" width="18" height="16" rx="2"/><path d="m7 9 3 3-3 3M13 15h4"/>',
    'database': '<ellipse cx="12" cy="6" rx="8" ry="3"/><path d="M4 6v12c0 1.7 3.6 3 8 3s8-1.3 8-3V6"/><path d="M4 12c0 1.7 3.6 3 8 3s8-1.3 8-3"/>',
    'table': '<rect x="3" y="4" width="18" height="16" rx="2"/><path d="M3 10h18M9 10v10"/>',
    'globe': '<circle cx="12" cy="12" r="9"/><path d="M3 12h18"/><path d="M12 3c2.5 2.5 3.8 5.6 3.8 9S14.5 18.5 12 21c-2.5-2.5-3.8-5.6-3.8-9S9.5 5.5 12 3z"/>',
    'rocket': '<path d="M12 3c3.5 1.5 6 5 6 9l-3 3H9l-3-3c0-4 2.5-7.5 6-9z"/><circle cx="12" cy="10" r="2"/><path d="M9 18c-1.5 1-2 2.5-2 4 1.5 0 3-.5 4-2M15 18c1.5 1 2 2.5 2 4-1.5 0-3-.5-4-2"/>',
    'book': '<path d="M4 5a2 2 0 0 1 2-2h13v16H6a2 2 0 0 0-2 2z"/><path d="M6 17h13"/>',
    'palette': '<path d="M12 3a9 9 0 1 0 0 18c1.5 0 2-1 2-2s-1-1.5-1-2.5 1-1.5 2-1.5h1.5A3.5 3.5 0 0 0 20 11c0-4.4-3.6-8-8-8z"/><circle cx="8" cy="10" r="1"/><circle cx="12" cy="7.5" r="1"/><circle cx="16" cy="10" r="1"/>',
    'image': '<rect x="3" y="4" width="18" height="16" rx="2"/><circle cx="8.5" cy="9.5" r="1.5"/><path d="m4 18 5-5 4 4 3-3 4 4"/>',
    'cpu': '<rect x="7" y="7" width="10" height="10" rx="2"/><path d="M10 3v4M14 3v4M10 17v4M14 17v4M3 10h4M3 14h4M17 10h4M17 14h4"/>',
    'bot': '<rect x="4" y="8" width="16" height="12" rx="4"/><path d="M12 4v4M9 14h.01M15 14h.01M9 17.5c1.8 1 4.2 1 6 0"/><path d="M2 13v3M22 13v3"/>',
    'send': '<path d="M21 3 3 10.5l7 3 3 7z"/><path d="m10 13.5 4.5-4.5"/>',
    'history': '<path d="M3 12a9 9 0 1 0 3-6.7L3 8"/><path d="M3 4v4h4"/><path d="M12 8v4.5l3 1.8"/>',
    'arrow_r': '<path d="M5 12h14"/><path d="m13 6 6 6-6 6"/>',
    'shield': '<path d="M12 3l8 3v6c0 4.4-3.2 8.3-8 9.5C7.2 20.3 4 16.4 4 12V6z"/><path d="m9 12 2 2 4-4"/>',
    'lock': '<rect x="4" y="10" width="16" height="11" rx="2"/><path d="M8 10V7a4 4 0 0 1 8 0v3"/>',
    'mail': '<rect x="3" y="5" width="18" height="14" rx="2"/><path d="m3 7 9 6 9-6"/>',
    'pie': '<path d="M12 3a9 9 0 1 0 9 9h-9z"/><path d="M15 3.5A9 9 0 0 1 20.5 9H15z"/>',
    'signal': '<path d="M4 20V10M10 20V4M16 20v-7M22 20H2"/>',
    'magic': '<path d="m4 20 10-10"/><path d="m14 4 1.2 2.8L18 8l-2.8 1.2L14 12l-1.2-2.8L10 8l2.8-1.2z"/><path d="M19 14l.8 1.8L21.5 17l-1.7.7L19 19.5l-.8-1.8L16.5 17l1.7-.7z"/>',
    'puzzle': '<path d="M10 4h4v2.5a1.5 1.5 0 1 0 3 0V4h3v4h-2.5a1.5 1.5 0 1 0 0 3H21v6h-3v-2.5a1.5 1.5 0 1 0-3 0V21H8v-3H5.5a1.5 1.5 0 1 0 0-3H8V4z"/>',
}

MOTIFS = {
    'python': '<rect x="76" y="34" width="168" height="96" rx="12" fill="#fff" fill-opacity=".94"/><circle cx="92" cy="49" r="4" fill="#ff6b6b"/><circle cx="105" cy="49" r="4" fill="#ffc53d"/><circle cx="118" cy="49" r="4" fill="#3ddc97"/><path d="M94 76h54M94 92h88M110 108h46" stroke="#5b4fe0" stroke-width="6" stroke-linecap="round"/>',
    'web': '<rect x="62" y="30" width="196" height="102" rx="12" fill="#fff" fill-opacity=".94"/><rect x="62" y="30" width="196" height="20" rx="10" fill="#0000001a"/><rect x="76" y="62" width="72" height="56" rx="8" fill="#3b82f6" fill-opacity=".3"/><rect x="158" y="62" width="86" height="24" rx="6" fill="#3b82f6" fill-opacity=".55"/><rect x="158" y="94" width="86" height="24" rx="6" fill="#3b82f6" fill-opacity=".25"/>',
    'data': '<rect x="66" y="30" width="188" height="102" rx="12" fill="#fff" fill-opacity=".94"/><rect x="86" y="86" width="22" height="34" rx="4" fill="#10a37f"/><rect x="118" y="66" width="22" height="54" rx="4" fill="#10a37f" fill-opacity=".7"/><rect x="150" y="76" width="22" height="44" rx="4" fill="#10a37f" fill-opacity=".5"/><path d="M86 64l50-16 40 14 50-22" fill="none" stroke="#0ea5e9" stroke-width="4" stroke-linecap="round"/>',
    'ai': '<g stroke="#fff" stroke-width="3" stroke-opacity=".8"><path d="M90 50l70 30M90 110l70-30M90 80h70M160 80l70-30M160 80l70 30"/></g><g fill="#fff"><circle cx="90" cy="50" r="11"/><circle cx="90" cy="80" r="11"/><circle cx="90" cy="110" r="11"/><circle cx="160" cy="80" r="15"/><circle cx="230" cy="50" r="11"/><circle cx="230" cy="110" r="11"/></g>',
    'db': '<g fill="#fff" fill-opacity=".95"><ellipse cx="160" cy="48" rx="56" ry="16"/><path d="M104 48v26c0 9 25 16 56 16s56-7 56-16V48c0 9-25 16-56 16s-56-7-56-16z"/><path d="M104 80v26c0 9 25 16 56 16s56-7 56-16V80c0 9-25 16-56 16s-56-7-56-16z" fill-opacity=".8"/></g>',
    'ux': '<rect x="70" y="30" width="180" height="102" rx="12" fill="#fff" fill-opacity=".94"/><rect x="84" y="44" width="70" height="74" rx="8" fill="#ec4899" fill-opacity=".3"/><rect x="164" y="44" width="72" height="14" rx="5" fill="#ec4899" fill-opacity=".6"/><rect x="164" y="66" width="50" height="10" rx="5" fill="#ec4899" fill-opacity=".3"/><circle cx="218" cy="104" r="14" fill="#5b4fe0"/><path d="M212 98l16 8-7 2-3 7z" fill="#fff"/>',
    'eng': '<rect x="66" y="34" width="130" height="62" rx="16" fill="#fff" fill-opacity=".95"/><path d="M96 96l-12 20 28-20z" fill="#fff" fill-opacity=".95"/><rect x="150" y="76" width="106" height="52" rx="16" fill="#fff" fill-opacity=".7"/><path d="M82 56h86M82 72h58" stroke="#16a34a" stroke-width="6" stroke-linecap="round"/>',
}

HUE = {'python': (255, 300), 'web': (205, 245), 'data': (155, 195), 'ai': (275, 325),
       'db': (18, 48), 'ux': (335, 8), 'eng': (95, 150)}
PHOTO_BY_KEY = {
    'python': 'core/img/covers/python.jpg',
    'web': 'core/img/covers/web.jpg',
    'data': 'core/img/covers/data.jpg',
    'ai': 'core/img/covers/ai.jpg',
    'db': 'core/img/covers/db.jpg',
    'ux': 'core/img/covers/ux.jpg',
    'eng': 'core/img/covers/eng.jpg',
}
DEFAULT_PHOTO = PHOTO_BY_KEY['python']


def svg(name, cls='ic'):
    """Інлайновий SVG-іконка (24×24, обводка currentColor)."""
    body = ICONS.get(name, ICONS['spark'])
    return (f'<svg class="{cls}" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" '
            f'stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">{body}</svg>')


def cover(course_id, key):
    """Обкладинка 320×160: фото + градієнт + мотив + віньєтка (унікальний id градієнта)."""
    a, b = HUE.get(key, (255, 300))
    photo = static(PHOTO_BY_KEY.get(key, DEFAULT_PHOTO))
    gid = f'g{course_id}'
    return (
        f'<svg class="cv" viewBox="0 0 320 160" preserveAspectRatio="xMidYMid slice" role="img" aria-hidden="true">'
        f'<defs>'
        f'<linearGradient id="{gid}" x1="0" y1="0" x2="1" y2="1">'
        f'<stop offset="0" stop-color="hsl({a} 80% 60%)"/><stop offset="1" stop-color="hsl({b} 78% 44%)"/>'
        f'</linearGradient>'
        f'<radialGradient id="v{gid}" cx=".5" cy=".5" r=".75">'
        f'<stop offset=".55" stop-color="#000" stop-opacity="0"/><stop offset="1" stop-color="#0b1020" stop-opacity=".55"/>'
        f'</radialGradient>'
        f'</defs>'
        f'<image href="{photo}" x="0" y="0" width="320" height="160" preserveAspectRatio="xMidYMid slice"/>'
        f'<rect width="320" height="160" fill="url(#{gid})" opacity="0.42"/>'
        f'<circle cx="36" cy="26" r="58" fill="#fff" fill-opacity=".10"/>'
        f'<circle cx="296" cy="146" r="72" fill="#fff" fill-opacity=".09"/>'
        f'<g class="mo">{MOTIFS.get(key, MOTIFS["python"])}</g>'
        f'<rect width="320" height="160" fill="url(#v{gid})"/>'
        f'</svg>'
    )
