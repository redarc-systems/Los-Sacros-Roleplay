let SHOW = false;

let state = {
  agency: 'AGENCY',
  officer: 'Officer',
  callsign: 'P-101',
  showGPS: true,
  showBatt: true,
  pos: 'top-right',
  scale: 1.0,
  clock24: true,
  volume: 0.5
};

const el = {
  container: () => document.getElementById('container'),
  panel:    () => document.getElementById('panel'),
  agency:   () => document.getElementById('agency'),
  officer:  () => document.getElementById('officer'),
  callsign: () => document.getElementById('callsign'),
  date:     () => document.getElementById('date'),
  time:     () => document.getElementById('time'),
  gps:      () => document.getElementById('gps'),
  battLvl:  () => document.getElementById('batt-level'),
  battTxt:  () => document.getElementById('batt-text'),
  sfxActivate: () => document.getElementById('sfx-activate'),
  sfxDeactivate: () => document.getElementById('sfx-deactivate'),
  sfxPeriodic: () => document.getElementById('sfx-periodic'),
};

function setVisibility(show) {
  SHOW = !!show;
  el.container().classList.toggle('hidden', !SHOW);
}

function clamp(v, a, b) { return Math.max(a, Math.min(b, v)); }

function applyHud() {
  el.agency().textContent  = state.agency || '';
  el.officer().textContent = state.officer || '';
  el.callsign().textContent = state.callsign || '';

  // Position & scale
  el.panel().classList.toggle('top-left', state.pos === 'top-left');
  el.panel().classList.toggle('top-right', state.pos !== 'top-left');

  el.panel().classList.remove('scale-090','scale-100','scale-125');
  const scale = state.scale || 1.0;
  if (scale < 1.0) el.panel().classList.add('scale-090');
  else if (scale > 1.0) el.panel().classList.add('scale-125');
  else el.panel().classList.add('scale-100');

  // Battery cosmetic
  el.battLvl().style.width = '92%';
  el.battTxt().textContent = '96%';
  el.gps().style.display = state.showGPS ? 'block' : 'none';
}

function updateDateTime() {
  const now = new Date();
  const day  = String(now.getDate()).padStart(2, '0');
  const mon  = String(now.getMonth()+1).padStart(2, '0');
  const year = now.getFullYear();

  let hours = now.getHours();
  let suffix = '';
  if (!state.clock24) {
    suffix = hours >= 12 ? ' PM' : ' AM';
    hours = hours % 12; if (hours === 0) hours = 12;
  }
  const mins  = String(now.getMinutes()).padStart(2, '0');
  const secs  = String(now.getSeconds()).padStart(2, '0');

  el.date().textContent = `${day}/${mon}/${year}`;
  el.time().textContent = `${String(hours).padStart(2,'0')}:${mins}:${secs}${suffix}`;
}

window.addEventListener('message', (e) => {
  const data = e.data;
  if (!data || typeof data !== 'object') return;

  if (data.action === 'visibility') {
    setVisibility(!!data.show);
  }

  if (data.action === 'hud') {
    state.agency   = data.agency ?? state.agency;
    state.officer  = data.officer ?? state.officer;
    state.callsign = data.callsign ?? state.callsign;
    state.showGPS  = data.showGPS ?? state.showGPS;
    state.showBatt = data.showBatt ?? state.showBatt;
    state.pos      = data.pos ?? state.pos;
    state.scale    = data.scale ?? state.scale;
    state.clock24  = data.clock24 ?? state.clock24;
    applyHud();
  }

  if (data.action === 'tick') {
    if (typeof data.gps === 'string' && state.showGPS) el.gps().textContent = data.gps;
    updateDateTime();
  }

  if (data.action === 'play') {
    const name = data.sound;
    const vol  = clamp(data.volume ?? 0.5, 0, 1);
    let audio = null;
    if (name === 'activate.ogg' || name === 'activate.mp3' || name === 'activate.wav') audio = el.sfxActivate();
    else if (name === 'deactivate.ogg' || name === 'deactivate.mp3' || name === 'deactivate.wav') audio = el.sfxDeactivate();
    else if (name === 'periodic.ogg' || name === 'periodic.mp3' || name === 'periodic.wav') audio = el.sfxPeriodic();

    if (audio) {
      audio.volume = vol;
      audio.currentTime = 0;
      audio.play().catch(() => {});
    }
  }
});

// steady clock tick (UI-only)
setInterval(() => {
  if (SHOW) updateDateTime();
}, 500);
