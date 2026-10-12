"""SVG-іконки та обкладинки курсів."""

from django.templatetags.static import static

ICONS = {
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
    'sliders': '<path d="M4 6h10M18 6h2M4 12h2M10 12h10M4 18h12M20 18h0"/><circle cx="16" cy="6" r="2"/><circle cx="8" cy="12" r="2"/><circle cx="18" cy="18" r="2"/>',
    'bell': '<path d="M6 8a6 6 0 0 1 12 0c0 7 3 9 3 9H3s3-2 3-9"/><path d="M10.3 21a1.9 1.9 0 0 0 3.4 0"/>',
    'sun': '<circle cx="12" cy="12" r="4"/><path d="M12 2v2M12 20v2M4.9 4.9l1.4 1.4M17.7 17.7l1.4 1.4M2 12h2M20 12h2M4.9 19.1l1.4-1.4M17.7 6.3l1.4-1.4"/>',
    'moon': '<path d="M21 12.8A9 9 0 1 1 11.2 3a7 7 0 0 0 9.8 9.8z"/>',
    'menu': '<path d="M4 6h16M4 12h16M4 18h16"/>',
    'clock': '<circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/>',
    'check': '<path d="M20 6 9 17l-5-5"/>',
    'play': '<path d="M6 4l14 8-14 8z"/>',
    'flame': '<path d="M12 2c1 4 5 5.5 5 10a5 5 0 0 1-10 0c0-2 1-3 2-4 .3 1.5 1 2 2 2 0-3-1-5 1-8z"/>',
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

HUE = {'python': (255, 300), 'web': (205, 245), 'data': (155, 195), 'ai': (275, 325), 'db': (18, 48), 'ux': (335, 8), 'eng': (95, 150)}
PHOTO_BY_KEY = {
    'python': 'core/img/covers/python.jpg',
    'web': 'core/img/covers/web.jpg',
    'data': 'core/img/covers/data.jpg',
    'ai': 'core/img/covers/ai.jpg',
    'db': 'core/img/covers/db.jpg',
    'ux': 'core/img/covers/ux.jpg',
    'eng': 'core/img/covers/eng.jpg',
}


def svg(name):
    return ('<svg class="ic" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" '
            f'stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">{ICONS[name]}</svg>')


def cover(course_id, key):
    a, b = HUE.get(key, (255, 300))
    photo = static(PHOTO_BY_KEY.get(key, PHOTO_BY_KEY['python']))
    return (f'<svg class="cv" viewBox="0 0 320 160" preserveAspectRatio="xMidYMid slice" aria-hidden="true"><defs>'
            f'<linearGradient id="g{course_id}" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="hsl({a} 80% 62%)"/>'
            f'<stop offset="1" stop-color="hsl({b} 80% 46%)"/></linearGradient></defs>'
            f'<image href="{photo}" x="0" y="0" width="320" height="160" preserveAspectRatio="xMidYMid slice"/>'
            f'<rect width="320" height="160" fill="url(#g{course_id})" opacity="0.38"/>'
            f'<circle cx="36" cy="26" r="58" fill="#fff" fill-opacity=".12"/><circle cx="296" cy="146" r="72" fill="#fff" fill-opacity=".11"/>'
            f'<g class="mo">{MOTIFS.get(key, MOTIFS["python"])}</g></svg>')
