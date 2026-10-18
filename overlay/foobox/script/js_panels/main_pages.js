// Modified for Foobar Immersive, 2026-10-12.
// Based on dream7180/foobox-cn; upstream notices retained. SPDX-License-Identifier: GPL-3.0-only
// Main page navigation. Uses existing foobox panels, no playback commands.
var fooboxMainPage = 'music';
var fooboxPages = [
    {key: 'music', title: '\u6211\u7684\u97f3\u4e50', panel: 1},
    {key: 'library', title: '\u97f3\u4e50\u5e93', panel: 2},
    {key: 'lyrics', title: '\u6c89\u6d78\u6b4c\u8bcd', panel: 1}
];
if (bio_panel) fooboxPages.push({key: 'bio', title: '\u6b4c\u66f2\u4fe1\u606f', panel: 3});
// Visualization page removed from navigation.
// Removed visualization panel must not be dereferenced.
var fooboxOriginalSwitch = g_switchbar.switch_panel;
function fooboxSelectPage(key) {
    var page = fooboxPages.filter(function(p) { return p.key === key; })[0];
    if (!page) return;
    fooboxMainPage = key;
    // Receivers retain original ratios when leaving the immersive page.
    // Music and lyrics share LIST. Preserve its native window on internal switches.
    if (active_pid !== page.panel - 1) fooboxOriginalSwitch.call(g_switchbar, page.panel);
    window.NotifyOthers('foobox.main.page', key);
    window.Repaint();
}
g_switchbar.switch_panel = function(id) {
    var page = fooboxPages.filter(function(p) { return p.panel === id && p.key !== 'lyrics'; })[0];
    if (page) fooboxSelectPage(page.key);
    else if (id !== 3 + bio_panel) fooboxOriginalSwitch.call(g_switchbar, id);
};
cycle_main_panel = function() {
    var index = fooboxPages.map(function(p) { return p.key; }).indexOf(fooboxMainPage);
    fooboxSelectPage(fooboxPages[(index + 1) % fooboxPages.length].key);
};
set_panel = function() {
    var top = z(38);
    var height = Math.max(0, win_y - top - z(2));
    if (active_p.Width !== ww || active_p.Height !== height || active_p.Y !== top)
        active_p.Move(0, top, ww, height);
};
function fooboxTabAt(x, y) {
    if (y < 0 || y >= z(38)) return -1;
    var index = Math.floor((x - z(12)) / z(106));
    return x >= z(12) && index >= 0 && index < fooboxPages.length ? index : -1;
}
var fooboxOriginalPaint = on_paint;
on_paint = function(gr) {
    fooboxOriginalPaint(gr);
    gr.FillSolidRect(0, 0, ww, z(38), c_background);
    for (var i = 0; i < fooboxPages.length; i++) {
        var selected = fooboxPages[i].key === fooboxMainPage;
        var x = z(12 + i * 106);
        gr.GdiDrawText(fooboxPages[i].title, g_font, selected ? c_seekoverlay : c_font,
            x, 0, z(102), z(36), 0x00000001 | 0x00000004 | 0x00000020);
        if (selected) gr.FillSolidRect(x + z(10), z(35), z(82), z(3), c_seekoverlay);
    }
};
var fooboxOriginalDown = on_mouse_lbtn_down;
on_mouse_lbtn_down = function(x, y) {
    if (y < z(38)) return;
    fooboxOriginalDown(x, y);
};
var fooboxOriginalUp = on_mouse_lbtn_up;
on_mouse_lbtn_up = function(x, y) {
    var index = fooboxTabAt(x, y);
    if (index >= 0) { fooboxSelectPage(fooboxPages[index].key); return; }
    fooboxOriginalUp(x, y);
};

// A palette/font rebuild resets hover while the pointer can remain stationary.
// Hit-test the press itself instead of requiring a preceding mouse-move event.
function fooboxBindPageButton() {
    PBStop.MouseDown = function(x, y) {
        if (this.state === 3) return false;
        var inside = x >= this.x && x < this.x + this.width &&
            y >= this.y && y < this.y + this.height;
        this.state = inside ? 2 : 0;
        this.Repaint();
        return inside;
    };
}
fooboxBindPageButton();

// Theme/font changes rebuild the original icon switcher; reattach navigation.
var fooboxOriginalInitButtons = initbuttons;
initbuttons = function() {
    fooboxOriginalInitButtons();
    fooboxBindPageButton();
    fooboxOriginalSwitch = g_switchbar.switch_panel;
    g_switchbar.switch_panel = function(id) {
        var page = fooboxPages.filter(function(p) { return p.panel === id && p.key !== 'lyrics'; })[0];
        if (page) fooboxSelectPage(page.key);
        else if (id !== 3 + bio_panel) fooboxOriginalSwitch.call(g_switchbar, id);
    };
};
window.SetTimeout(function() { fooboxSelectPage('music'); }, 150);
