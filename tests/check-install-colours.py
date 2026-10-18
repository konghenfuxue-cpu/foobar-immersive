"""Integration check using supplied real component DLLs; never touches a live profile."""
from pathlib import Path
import hashlib, shutil, struct, subprocess, sys, tempfile
repo=Path(__file__).resolve().parents[1]
runtime=Path(sys.argv[1]).resolve()
pwsh=shutil.which('pwsh') or shutil.which('powershell')
assert pwsh,'PowerShell is required'
def sections(data):
 count=struct.unpack_from('<I',data,16)[0];pos=20;out=[]
 for _ in range(count):
  size=struct.unpack_from('<I',data,pos+16)[0];out.append(data[pos:pos+36+size]);pos+=36+size
 assert pos==len(data)
 return out
dark=(repo/'overlay/foobox/配色/深色-仅颜色.fth').read_bytes()
colour_key=dark[20:36]
def snap(p):return {str(f.relative_to(p)):hashlib.sha256(f.read_bytes()).hexdigest() for f in p.rglob('*') if f.is_file()}
for keep in [False,True]:
 with tempfile.TemporaryDirectory(prefix='foobar-colours-') as tmp:
  profile=Path(tmp)/'中文 空格配置';profile.mkdir()
  for rel in ['foobox/script/js_panels/bottombar.js','foobox/script/js_common/common.js','foobox/script/js_common/splitterh.js','foobox/script/js_common/splitterve.js','foobox/script/js_common/splitterESLProp.js','user-components-x64/foo_uie_eslyric/foo_uie_eslyric.dll','user-components-x64/foo_uie_jsplitter/foo_uie_jsplitter.dll','theme.fth']:
   dst=profile/rel;dst.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(runtime/rel,dst)
  original=(profile/'theme.fth').read_bytes();before=snap(profile)
  cmd=[pwsh,'-NoProfile','-File',str(repo/'Install.ps1'),'-ProfilePath',str(profile)]+(['-KeepColours'] if keep else [])
  r=subprocess.run(cmd,capture_output=True,text=True,encoding='utf-8',errors='replace');assert r.returncode==0,r.stderr
  assert snap(profile)==before,'Dry run modified the profile'
  r=subprocess.run(cmd+['-Apply'],capture_output=True,text=True,encoding='utf-8',errors='replace');assert r.returncode==0,r.stderr
  actual=(profile/'theme.fth').read_bytes()
  if keep:assert actual==original,'KeepColours changed theme bytes'
  else:
   chunks=sections(actual)
   assert [c for c in chunks if c[:16]==colour_key]==[sections(dark)[0]],'Default installation did not select dark colours'
   assert [c for c in chunks if c[:16]!=colour_key]==[c for c in sections(original) if c[:16]!=colour_key],'Layout/fonts changed'
   backups=list(profile.glob('foobox-theme-before-dark-*.fth'));assert len(backups)==1 and backups[0].read_bytes()==original,'Original theme backup missing or incorrect'
print('PASS: real installer dry run, dark default, exact layout preservation, backup, KeepColours; Chinese/space paths')
