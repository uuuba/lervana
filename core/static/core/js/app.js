(function () {
  'use strict';
  const $ = (s, r = document) => r.querySelector(s);
  const $$ = (s, r = document) => [...r.querySelectorAll(s)];
  const root = document.documentElement;
  const csrf = () => ($('meta[name=csrf]') || {content: ''}).content;
  const post = (url, body) => fetch(url, {
    method: 'POST',
    headers: {'X-CSRFToken': csrf(), 'X-Requested-With': 'XMLHttpRequest', 'Content-Type': 'application/json'},
    body: JSON.stringify(body || {})
  }).then(r => r.json());

  /* toast + повідомлення Django (messages framework) */
  let tt;
  function toast(msg, err) {
    const x = $('#toast');
    if (!x) return;
    x.textContent = msg;
    x.className = 'on' + (err ? ' er' : '');
    clearTimeout(tt);
    tt = setTimeout(() => (x.className = ''), 2600);
  }
  const msgs = $$('.js-msg');
  if (msgs.length) { const m = msgs[msgs.length - 1]; toast(m.textContent.trim(), m.dataset.level === 'error'); }

  /* тема (світла/темна), зберігається в localStorage */
  function themeIcon(spin) {
    const b = $('#tb');
    if (!b) return;
    const iconTemplate = $('#ic-' + (root.dataset.theme === 'dark' ? 'sun' : 'moon'));
    if (!iconTemplate) return;
    b.innerHTML = iconTemplate.innerHTML;
    if (spin && b.firstElementChild) {
      b.firstElementChild.animate([{transform: 'rotate(-120deg) scale(.4)', opacity: 0}, {transform: 'none', opacity: 1}],
        {duration: 400, easing: 'ease-out'});
    }
  }
  function setTheme(m) {
    root.dataset.theme = m;
    try { localStorage.setItem('ln-t', m); } catch (e) { /* ignore */ }
    themeIcon(true);
  }
  themeIcon();
  const themeBtn = $('#tb');
  if (themeBtn) themeBtn.onclick = () => setTheme(root.dataset.theme === 'dark' ? 'light' : 'dark');
  $$('[data-theme-set]').forEach(b => (b.onclick = () => setTheme(b.dataset.themeSet)));

  /* мобільне меню */
  const menuBtn = $('#mb');
  const side = $('#side');
  if (menuBtn && side) menuBtn.onclick = () => side.classList.toggle('open');
  document.addEventListener('click', e => {
    if (side && side.classList.contains('open') && !side.contains(e.target) && e.target.closest('#mb') === null) {
      side.classList.remove('open');
    }
  });

  /* сповіщення */
  const np = $('#np'), bell = $('#bl');
  if (bell && np) {
    bell.onclick = e => {
      e.stopPropagation();
      np.hidden = !np.hidden;
      const badge = $('#bd');
      if (!np.hidden && badge && !badge.hidden) post(np.dataset.url).then(() => (badge.hidden = true));
    };
    document.addEventListener('click', e => { if (np && !np.contains(e.target)) np.hidden = true; });
  }

  /* збереження курсу */
  document.addEventListener('click', e => {
    const b = e.target.closest('.js-save');
    if (!b) return;
    post(b.dataset.url).then(d => {
      b.classList.toggle('sv', d.saved);
      b.setAttribute('aria-pressed', d.saved);
      const label = $('span', b);
      if (label) label.textContent = d.label;
      toast(d.msg);
    });
  });

  /* виконання модулів плану */
  document.addEventListener('change', e => {
    const c = e.target.closest('.js-task');
    if (!c) return;
    post(c.dataset.url).then(d => {
      const bar = $('#bar-' + d.course), pct = $('#pct-' + d.course);
      if (bar) bar.style.width = d.pct + '%';
      if (pct) pct.textContent = d.pct + '%';
      toast(d.msg);
    });
  });

  /* значення повзунків у профілі */
  document.addEventListener('input', e => {
    if (e.target.matches('[data-out]')) e.target.previousElementSibling.textContent = e.target.value;
  });

  /* лічильники на панелі */
  $$('[data-n]').forEach(el => {
    const n = +el.dataset.n, s = performance.now();
    (function f(x) {
      const p = Math.min(1, (x - s) / 900);
      el.textContent = Math.round(n * (1 - Math.pow(1 - p, 3)));
      if (p < 1) requestAnimationFrame(f);
    })(s);
  });

  /* ================= «ШІ-агент»: чат ================= */
  function makeChat(cfg) {
    const body = $(cfg.body), form = $(cfg.form), input = cfg.input ? $(cfg.input) : null;
    if (!body || !form) return null;
    const typing = cfg.typing || '…';

    const add = (cls, content, srcLabel) => {
      const d = document.createElement('div');
      d.className = 'msg ' + cls;
      const text = document.createElement('span');
      text.className = 'msg-in';
      text.textContent = content;
      d.append(text);
      if (srcLabel) {
        const s = document.createElement('span');
        s.className = 'msg-src';
        s.textContent = srcLabel;
        d.append(s);
      }
      body.append(d);
      body.scrollTop = body.scrollHeight;
      return d;
    };

    const send = async text => {
      add('u', text);
      const dots = document.createElement('span');
      dots.className = 'dots';
      dots.innerHTML = '<i></i><i></i><i></i>';
      const pending = add('a', '');
      pending.querySelector('.msg-in').append(dots);
      try {
        const d = await post(cfg.ask, {text: text, q: text});
        pending.querySelector('.msg-in').textContent = d.answer || '';
        if (d.label) {
          const s = document.createElement('span');
          s.className = 'msg-src';
          s.textContent = d.label;
          pending.append(s);
        }
      } catch (e) {
        pending.querySelector('.msg-in').textContent = cfg.err || '…';
      }
      body.scrollTop = body.scrollHeight;
    };

    form.addEventListener('submit', e => {
      e.preventDefault();
      if (!input) return;
      const v = input.value.trim();
      if (!v) return;
      input.value = '';
      send(v);
    });

    $$(cfg.chipSel || '.js-q', body.parentNode).forEach(b => {
      b.onclick = () => send((b.dataset.q || b.textContent).trim());
    });

    const clearBtn = $(cfg.clear);
    if (clearBtn && cfg.clearUrl) {
      clearBtn.onclick = () => post(cfg.clearUrl).then(() => { body.innerHTML = ''; toast(clearBtn.textContent); });
    }
    return {add, send};
  }

  /* ---- діалог на сторінці «Асистент» ---- */
  const chatCfg = $('#chat-cfg');
  if (chatCfg) {
    makeChat({
      body: '#chat', form: '#ag-form', input: '#ai', ask: chatCfg.dataset.url,
      clearUrl: chatCfg.dataset.clear, clear: '#ag-clear', chipSel: '.js-q',
      typing: chatCfg.dataset.typing, err: chatCfg.dataset.err,
      srcDb: chatCfg.dataset.srcDb, srcKb: chatCfg.dataset.srcKb, srcFallback: chatCfg.dataset.srcFallback
    });
  }

  /* ---- плаваючий віджет «порадитись з агентом» (кожна сторінка) ---- */
  const w = $('#agentw');
  if (w) {
    const panel = $('#agw-panel'), fab = $('#agw-fab'), close = $('#agw-close'), body = $('#agw-body');
    let opened = false, loaded = false;
    const chat = makeChat({
      body: '#agw-body', form: '#agw-form', input: '#agw-input', ask: w.dataset.ask,
      clearUrl: w.dataset.clear, clear: '#agw-clear', chipSel: '.js-agq',
      typing: w.dataset.typing, err: w.dataset.err,
      srcDb: w.dataset.srcDb, srcKb: w.dataset.srcKb, srcFallback: w.dataset.srcFallback
    });

    const labelFor = code => ({db: w.dataset.srcDb, kb: w.dataset.srcKb, fallback: w.dataset.srcFallback})[code] || w.dataset.srcDb;
    const loadHistory = () => fetch(w.dataset.hist, {headers: {'X-Requested-With': 'XMLHttpRequest'}})
      .then(r => r.json())
      .then(d => {
        const rows = (d && d.messages) || [];
        if (!rows.length || !chat) return;
        body.innerHTML = '';
        rows.forEach(m => chat.add(m.role === 'user' ? 'u' : 'a', m.content, m.role === 'agent' ? labelFor(m.source) : ''));
      }).catch(() => { /* ignore */ });

    const setOpen = open => {
      panel.hidden = !open;
      fab.setAttribute('aria-expanded', open ? 'true' : 'false');
      w.classList.toggle('on', open);
      if (open) {
        if (!loaded) { loaded = true; loadHistory(); }
        const i = $('#agw-input');
        if (i) setTimeout(() => i.focus(), 60);
      }
    };
    fab.onclick = e => {
      e.stopPropagation();
      setOpen(panel.hidden);
    };
    if (close) {
      close.onclick = e => {
        e.stopPropagation();
        setOpen(false);
      };
    }
    document.addEventListener('keydown', e => { if (e.key === 'Escape' && !panel.hidden) setOpen(false); });
    document.addEventListener('click', e => {
      if (!panel.hidden && !w.contains(e.target)) setOpen(false);
    });
  }
})();
