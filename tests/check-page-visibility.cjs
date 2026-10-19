const fs=require('fs'),vm=require('vm'),assert=require('assert'),path=require('path');
for(const file of ['splitterh.js','splitterve.js']){
 const source=fs.readFileSync(path.join(__dirname,'../overlay/foobox/script/js_common',file),'utf8');
 const start=source.indexOf('function on_notify_data(');
 const stop=source.indexOf('\n// Follow',start);
 const calls=[];
 const panel=name=>({Width:100,Height:100,Show(v){calls.push(name+':'+v)}});
 const host={fooboxMainSplit:true,fooboxImmersive:false,ww:400,wh:300,sp_drag:false,
 PLeft:panel('left'),PRight:panel('right'),PUpper:panel('upper'),PLower:panel('lower'),
 on_size(){calls.push('size')},window:{Repaint(){}},console:{log(){}}};
 vm.createContext(host);vm.runInContext(source.slice(start,stop<0?undefined:stop),host);
 host.on_notify_data('foobox.main.page','music');
 const expected=file==='splitterh.js'?['left:true','right:true']:['upper:true','lower:true'];
 for(const call of expected)assert(calls.includes(call),file+' does not restore '+call+' on initial music state');
 assert(calls.includes('size'),file+' does not size children');
}
console.log('PASS: initial/same-page notifications restore native child visibility');
