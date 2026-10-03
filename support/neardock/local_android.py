"""Prepare an isolated FOSS APK checkout and private Neardock signing identity."""
from pathlib import Path
import os, secrets, shutil, subprocess

root=Path(__file__).resolve().parents[2]
private=Path(os.environ['LOCALAPPDATA'])/'Neardock/signing'
private.mkdir(parents=True,exist_ok=True)
password_file=private/'password.txt'
keystore=private/'neardock.jks'
if not password_file.exists(): password_file.write_text(secrets.token_urlsafe(40),encoding='utf-8')
env=os.environ.copy(); env['NEARDOCK_KEY_PASSWORD']=password_file.read_text(encoding='utf-8').strip()
keytool=Path(env['JAVA_HOME'])/'bin/keytool.exe'
if not keystore.exists():
    subprocess.run([str(keytool),'-genkeypair','-keystore',str(keystore),'-storepass:env','NEARDOCK_KEY_PASSWORD','-keypass:env','NEARDOCK_KEY_PASSWORD','-alias','neardock','-keyalg','RSA','-keysize','3072','-validity','10000','-dname','CN=YazeKT, OU=Neardock','-storetype','JKS'],env=env,check=True,stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
work=root/'.local/android-build'
work.mkdir(parents=True,exist_ok=True)
ignore=shutil.ignore_patterns('.git','.dart_tool','build','target','.gradle','local.properties','key.properties','*.msix','ephemeral','.plugin_symlinks','.cxx','.kotlin')
for name in ['app','packages','cli','server']:
    shutil.copytree(root/name,work/name,ignore=ignore,dirs_exist_ok=True)
for name in ['pubspec.yaml','pubspec.lock','Cargo.toml','Cargo.lock','rust-toolchain.toml']:
    shutil.copy2(root/name,work/name)
app=work/'app'
# Cargokit's inherited helper only recognises stable/beta/nightly installations.
# Recognise the already-installed numeric pinned toolchain in local staging too,
# avoiding unnecessary rustup network sync. Shared protocol sources stay untouched.
rustup_helper=work/'packages/localsend_isolates/rust_builder/cargokit/build_tool/lib/src/rustup.dart'
helper_source=rustup_helper.read_text(encoding='utf-8')
helper_source=helper_source.replace('r"^(stable|beta|nightly)"', 'r"^(stable|beta|nightly|[0-9]+\\.[0-9]+\\.[0-9]+)"')
rustup_helper.write_text(helper_source,encoding='utf-8')
pubspec=app/'pubspec.yaml'
pubspec.write_text('\n'.join(line for line in pubspec.read_text().splitlines() if '# [FOSS_REMOVE]' not in line)+'\n')
for name in ['lib/config/init.dart','lib/pages/donation/donation_page.dart','lib/pages/donation/donation_page_vm.dart']:
    path=app/name
    text=path.read_text().replace('// [FOSS_REMOVE_START]','/*').replace('// [FOSS_REMOVE_END]','*/')
    if name.endswith('donation_page.dart'): text=text.replace('donationPageVmProvider','donationPageNoopVmProvider')
    path.write_text(text,encoding='utf-8')
(app/'lib/provider/purchase_provider.dart').unlink(missing_ok=True)
password=env['NEARDOCK_KEY_PASSWORD']
(app/'android/key.properties').write_text(f'storeFile={keystore.as_posix()}\nstorePassword={password}\nkeyPassword={password}\nkeyAlias=neardock\n',encoding='utf-8')
print('Isolated Android source prepared; signing material remains outside Git. Back up the signing directory securely.')
