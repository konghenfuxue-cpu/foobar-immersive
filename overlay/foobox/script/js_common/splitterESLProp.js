// Modified for Foobar Immersive, 2026-10-12.
// Based on dream7180/foobox-cn; upstream notices retained. SPDX-License-Identifier: GPL-3.0-only
// Reuse the existing foobox cover palette; do not decode images again.
function fooboxReadableAccent(rgb) {
    var values = rgb.map(function(v) { return Math.max(0, Math.min(255, Number(v))); });
    var luminance = values[0]*0.2126 + values[1]*0.7152 + values[2]*0.0722;
    var mix = luminance < 155 ? (155-luminance)/(255-luminance) : 0;
    values = values.map(function(v) { return Math.round(v + (255-v)*mix); });
    return 0xff000000 | (values[0]<<16) | (values[1]<<8) | values[2];
}
var fooboxThemeAccent = window.GetColourDUI(2);
var fooboxSpectrumAccent = fooboxReadableAccent([(fooboxThemeAccent>>>16)&255,(fooboxThemeAccent>>>8)&255,fooboxThemeAccent&255]);
window.DefinePanel('Jsplitter R02');
window.DlgCode = 0x0004;
let ww = 0;
let wh = 0;
var INFO, ESL, active_p;
var timer_swp = false;
var fooboxImmersive = false;
var autosw = window.GetProperty("Auto.Switch", true);

function get_panel() {
	INFO = window.GetPanel('TrackProp');
	ESL = window.GetPanel('ESLyric');
	if(!autosw){
		if(ESL.Hidden) active_p = INFO;
		else active_p = ESL;
	}
	else{
		if(!fb.IsPlaying) {
			active_p = INFO;
			if(INFO.Hidden) INFO.Show(true);
			if(!ESL.Hidden) ESL.Show(false);
		}
		else {
			active_p = ESL;
			if(ESL.Hidden) ESL.Show(true);
			if(!INFO.Hidden) INFO.Show(false);
		}
	}
	INFO.ShowCaption = ESL.ShowCaption = false;
}

function set_panel() {
	try{
		if(active_p.Width != ww || active_p.Height != wh)
		active_p.Move(0, 0, ww, wh);
	} catch(e){//快速设置布局的bug
		get_panel();
	}
}

function swith_panel(pno) {
	active_p.Show(false);
	if(pno == 2) active_p = ESL;
	else active_p = INFO;
	active_p.Show(true);
	set_panel();
}

//////////////
get_panel();

function on_size() {
    ww = window.Width;
	wh = window.Height;
	if(ww) set_panel();
}

function on_playback_new_track(info) {
	if (fooboxImmersive || !autosw) return;
	timer_swp && window.ClearTimeout(timer_swp);
	timer_swp = false;
	swith_panel(2);
}

function on_playback_stop(reason) {
	if (fooboxImmersive || !autosw) return;
	timer_swp = window.SetTimeout(function() {
		swith_panel(1);
		timer_swp && window.ClearTimeout(timer_swp);
		timer_swp = false;
	}, 150); 
}

function on_notify_data(name, info) {
    if (name === 'color_scheme_updated') {
        if (info && info.length >= 3 && [info[0],info[1],info[2]].every(function(v) { return typeof v === 'number' && isFinite(v); })) {
            fooboxSpectrumAccent = fooboxReadableAccent([info[0],info[1],info[2]]);
        } else if (!info) {
            var accent = window.GetColourDUI(2);
            fooboxSpectrumAccent = fooboxReadableAccent([(accent>>>16)&255,(accent>>>8)&255,accent&255]);
        }
        if (fooboxImmersive) {
            try { new ActiveXObject('ESLyric').GetAll().SetTextHighlightColor(fooboxSpectrumAccent); }
            catch (error) { console.log('Foobox spectrum color: ' + error); }
        }
        return;
    }

    if (name === 'foobox.main.page') {
        var previousImmersive = fooboxImmersive;
        fooboxImmersive = info === 'lyrics';
        timer_swp && window.ClearTimeout(timer_swp); timer_swp = false;
        if (fooboxImmersive) {
            swith_panel(2);
            try {
                var controls = new ActiveXObject('ESLyric').GetAll();
                controls.SetLayoutName('FooboxImmersive');
                console.log('Foobox ESLyric: requested FooboxImmersive layout');
                controls.SetTextColor(0xffffffff);
                controls.SetTextHighlightColor(fooboxSpectrumAccent);
                controls.SetTextFont('Microsoft YaHei', 24, 0);
                controls.SetBackgroundType(1);
                controls.SetBackgroundImageBlurRadius(60);
                fooboxApplyLyricBackground(controls);
            } catch (error) {
                console.log('沉浸歌词自动设置失败，请在ESLyric面板设置中选择布局：' + error);
            }
        } else if (previousImmersive) {
            try {
                var normalControls = new ActiveXObject('ESLyric').GetAll();
                normalControls.SetLayoutName('日常简洁歌词');
                normalControls.SetTextFont('Microsoft YaHei', 16, 0);
                normalControls.SetTextColor(window.GetColourDUI(0));
                normalControls.SetTextHighlightColor(window.GetColourDUI(2));
                normalControls.SetBackgroundType(0);
                normalControls.SetBackgroundColor(window.GetColourDUI(1));
            } catch (error) { console.log('恢复侧栏歌词设置失败：' + error); }
            swith_panel(fb.IsPlaying ? 2 : 1);
        }
        return;
    }
	switch (name) {
	case "SwitchESLProp":
		if(INFO.Hidden) swith_panel(1);
		else swith_panel(2);
		break;
	case "AutoESLProp":
		autosw = info;
		window.SetProperty("Auto.Switch", autosw);
		break;
	}
}

// Follow the existing DUI palette, including imported colour-only themes.
function fooboxApplyLyricBackground(controls) {
    var background = window.GetColourDUI(1);
    var red = (background >>> 16) & 255, green = (background >>> 8) & 255, blue = background & 255;
    var dark = red + green + blue < 383;
    controls.SetBackgroundColor(dark ? 0xff202020 : background);
    controls.SetBackgroundImageBlendAlpha(dark ? 65 : 50);
}
function on_colours_changed() {
    try {
        var controls = new ActiveXObject('ESLyric').GetAll();
        if (fooboxImmersive) fooboxApplyLyricBackground(controls);
        else {
            controls.SetBackgroundColor(window.GetColourDUI(1));
            controls.SetTextColor(window.GetColourDUI(0));
            controls.SetTextHighlightColor(window.GetColourDUI(2));
        }
    } catch (error) { console.log('Foobox lyric theme: ' + error); }
}
