(function () {
  'use strict';
  const $ = (s, r = document) => r.querySelector(s);
  const $$ = (s, r = document) => [...r.querySelectorAll(s)];
  const root = document.documentElement;
  const csrf = () => $('meta[name=csrf]').content;
  const post = (url, body) => fetch(url, {
    method: 'POST',
    headers: {'X-CSRFToken': csrf(), 'X-Requested-With': 'XMLHttpRequest', 'Content-Type': 'application/json'},
    body: JSON.stringify(body || {})
  }).then(r => r.json());

  /* toast + повідомлення Django (messages framework) */
  let tt;
  function toast(msg, err) {
    const x = $('#toast');
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

  /* сповіщення */
  const np = $('#np'), bell = $('#bl');
  if (bell && np) {
    bell.onclick = e => {
      e.stopPropagation();
      np.hidden = !np.hidden;
      const badge = $('#bd');
      if (!np.hidden && !badge.hidden) post(np.dataset.url).then(() => (badge.hidden = true));
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
      $('span', b).textContent = d.label;
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

  /* асистент (демо-режим) */
  const chat = $('#chat');
  if (chat) {
    const url = $('#chat-cfg').dataset.url;
    const add = (cls, content) => {
      const d = document.createElement('div');
      d.className = 'msg ' + cls;
      d.append(content);
      chat.append(d);
      return d;
    };
    const ask = async (label, payload) => {
      add('u', label);
      const dots = document.createElement('span');
      dots.className = 'dots';
      dots.innerHTML = '<i></i><i></i><i></i>';
      const m = add('a', dots);
      const [d] = await Promise.all([post(url, payload), new Promise(r => setTimeout(r, 800))]);
      m.textContent = d.answer;
    };
    $$('.js-q').forEach(b => (b.onclick = () => ask(b.textContent, {q: b.dataset.q})));
    const send = () => { const i = $('#ai'), v = i.value.trim(); if (v) { i.value = ''; ask(v, {text: v}); } };
    $('#send').onclick = send;
    $('#ai').onkeydown = e => { if (e.key === 'Enter') send(); };
  }
})();
