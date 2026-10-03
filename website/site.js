'use strict';
const platform = document.querySelector('#platform');
const architecture = document.querySelector('#architecture');
const target = document.querySelector('#downloads');
let release;
function render() {
  if (!release) return;
  target.replaceChildren();
  const prefix = `${platform.value}-${architecture.value}`;
  const assets = release.assets.filter(asset => asset && typeof asset.id === 'string' && (asset.id === prefix || asset.id.startsWith(prefix + '-')) && asset.buildVerified === true && typeof asset.deviceTested === 'boolean' && typeof asset.signing === 'string' && typeof asset.url === 'string' && /^https:\/\/github\.com\/YazeKT\/Neardock\/releases\/download\/neardock-v1\.0\.0\/[A-Za-z0-9._-]+$/.test(asset.url) && /^[a-f0-9]{64}$/.test(asset.sha256));
  if (!assets.length) {
    const p = document.createElement('p'); p.className = 'status';
    p.textContent = 'This architecture is not available yet. Choose Windows x64 or Android ARM64 for the verified 1.0.0 downloads.';
    target.append(p); return;
  }
  for (const asset of assets) {
    if (!asset.url.startsWith('https://github.com/YazeKT/Neardock/releases/download/neardock-v1.0.0/') || !/^[a-f0-9]{64}$/.test(asset.sha256)) continue;
    const section = document.createElement('section'); section.className = 'download-card';
    const heading = document.createElement('h2'); heading.textContent = asset.label;
    const status = document.createElement('p'); status.textContent = `Build: ${asset.buildVerified ? 'verified' : 'pending'} · Device tests: ${asset.deviceTested ? 'verified' : 'pending'} · ${asset.signing}`;
    const link = document.createElement('a'); link.className = 'button'; link.href = asset.url; link.textContent = 'Download ↗';
    const hash = document.createElement('code'); hash.textContent = 'SHA-256: ' + asset.sha256;
    section.append(heading, status, link, hash); target.append(section);
  }
}
if (platform) {
  platform.addEventListener('change', () => {
    architecture.replaceChildren();
    const values = platform.value === 'windows' ? [['x64','x64 — Intel / AMD'],['arm64','ARM64 — Windows ARM']] : [['arm64','ARM64 — most recent phones'],['arm32','ARM32 — older devices'],['x64','x64 — Intel / emulators']];
    for (const [value,label] of values) architecture.add(new Option(label,value));
    render();
  });
  architecture.addEventListener('change', render);
  fetch('releases.json').then(response => { if (!response.ok) throw new Error(); return response.json(); }).then(data => { if (!data || data.version !== '1.0.0' || !Array.isArray(data.assets)) throw new Error('Invalid release manifest'); release = data; render(); }).catch(() => { target.textContent = 'Release availability could not be loaded. Visit GitHub Releases or try again.'; });
}

const previews = {
  send: ['Windows Send screen with nearby devices and file selection', 'Send · Select a nearby device, add files and send.'],
  receive: ['Windows Receive screen with the device identity and destination', 'Receive · See your device and chosen save destination.'],
  chat: ['Windows Chat screen with a device list and conversation', 'Chat · Local conversations using ordinary text transfers.'],
  clipboard: ['Windows Clipboard screen with explicit paste and send controls', 'Clipboard · Paste, review, send and copy when you choose.'],
  settings: ['Windows Settings screen with grouped controls', 'Settings · Appearance, transfers, devices and privacy.']
};
for (const button of document.querySelectorAll('[data-screen]')) {
  button.addEventListener('click', () => {
    const key = button.dataset.screen;
    if (!Object.hasOwn(previews, key)) return;
    document.querySelector('#app-preview').src = `assets/windows-${key}.png`;
    document.querySelector('#app-preview').alt = previews[key][0];
    document.querySelector('#preview-caption').textContent = previews[key][1];
    for (const other of document.querySelectorAll('[data-screen]')) other.setAttribute('aria-pressed', String(other === button));
  });
}
