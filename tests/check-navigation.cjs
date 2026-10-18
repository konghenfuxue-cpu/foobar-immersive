const fs = require('fs');
const path = require('path');
const vm = require('vm');
const assert = require('assert');
const script = path.join(__dirname, '../overlay/foobox/script/js_panels/main_pages.js');
const source = fs.readFileSync(script, 'utf8');
const expected = ['我的音乐', '音乐库', '沉浸歌词', '歌曲信息'];
for (const encoding of ['utf8', 'latin1']) {
    const text = fs.readFileSync(script).toString(encoding);
    const titles = [...text.matchAll(/title:\s*('(?:\\.|[^'\\])*')/g)].map(m => m[1]);
    assert.deepEqual(Array.from(vm.runInNewContext('[' + titles.join(',') + ']')), expected);
}
const calls = [];
const host = {
    bio_panel: 1, active_pid: 0,
    g_switchbar: {switch_panel(id) {calls.push('physical:' + id); host.active_pid = id - 1;}},
    PBStop: {state: 0, x: 100, y: 100, width: 20, height: 20, Repaint() {}},
    initbuttons() {}, z: x => x, on_paint() {}, on_mouse_lbtn_down() {}, on_mouse_lbtn_up() {},
    window: {NotifyOthers(name, key) {calls.push('notify:' + key);}, Repaint() {}, SetTimeout() {}}
};
vm.createContext(host);
vm.runInContext(source, host);
host.fooboxSelectPage('lyrics'); host.fooboxSelectPage('music');
assert.deepEqual(calls, ['notify:lyrics', 'notify:music']);
calls.length = 0; host.fooboxSelectPage('library');
assert.deepEqual(calls, ['physical:2', 'notify:library']);
calls.length = 0; host.fooboxSelectPage('lyrics');
assert.deepEqual(calls, ['physical:1', 'notify:lyrics']);
assert.equal(host.PBStop.MouseDown(110, 110), true);
assert.equal(host.PBStop.MouseDown(0, 0), false);
console.log('PASS: navigation encoding, shared-root retention, notification order, stationary-pointer button hit testing');
