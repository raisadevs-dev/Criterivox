(() => {
  'use strict';

  const canvas = document.getElementById('character');
  const ctx = canvas.getContext('2d');
  const stateEl = document.getElementById('state');
  const query = new URLSearchParams(location.search);
  const characterId = (query.get('character') || 'dharen').toLowerCase();
  let reducedMotion = query.get('reducedMotion') === 'true';
  let library = null;
  let currentState = (query.get('state') || 'IDLE').toUpperCase();
  let targetState = currentState;
  let transition = 1;
  let time = 0;
  let last = performance.now();

  const TAU = Math.PI * 2;
  const clamp = (v, a, b) => Math.max(a, Math.min(b, v));
  const lerp = (a, b, t) => a + (b - a) * t;
  const ease = t => t * t * (3 - 2 * t);

  function resize() {
    const dpr = Math.min(devicePixelRatio || 1, 2);
    const r = canvas.getBoundingClientRect();
    canvas.width = Math.max(1, r.width * dpr);
    canvas.height = Math.max(1, r.height * dpr);
    ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
  }

  new ResizeObserver(resize).observe(canvas);
  resize();

  function sample(track, t) {
    const out = {};
    for (const [bone, props] of Object.entries(track?.bones || {})) {
      out[bone] = {};
      for (const [name, values] of Object.entries(props)) {
        if (!Array.isArray(values) || !values.length) continue;
        if (values.length === 1) {
          out[bone][name] = Number(values[0]) || 0;
          continue;
        }
        const u = clamp(t / Math.max(.001, track.duration || 1), 0, 1) * (values.length - 1);
        const i = Math.min(values.length - 2, Math.floor(u));
        const f = u - i;
        out[bone][name] = lerp(Number(values[i]) || 0, Number(values[i + 1]) || 0, f);
      }
    }
    return out;
  }

  function mix(a, b, t) {
    const out = {};
    const bones = new Set([...Object.keys(a || {}), ...Object.keys(b || {})]);
    for (const bone of bones) {
      out[bone] = {};
      const props = new Set([...Object.keys(a?.[bone] || {}), ...Object.keys(b?.[bone] || {})]);
      for (const p of props) out[bone][p] = lerp(Number(a?.[bone]?.[p] || 0), Number(b?.[bone]?.[p] || 0), t);
    }
    return out;
  }

  function pose(state, t) {
    return sample(library.animationTracks[state] || library.animationTracks.IDLE, t);
  }

  function worldBones(rig, poseData) {
    const result = new Map();
    const defs = new Map((rig?.bones || []).map(b => [b.name, b]));
    function resolve(name) {
      if (result.has(name)) return result.get(name);
      const b = defs.get(name);
      if (!b) return { x: 0, y: 0, rotation: 0 };
      const p = poseData[name] || {};
      const x = (b.x || 0) + (p.x || 0);
      const y = (b.y || 0) + (p.y || 0);
      const r = (b.rotation || 0) + (p.rotation || 0);
      if (!b.parent) {
        const v = { x, y, rotation: r };
        result.set(name, v);
        return v;
      }
      const parent = resolve(b.parent);
      const c = Math.cos(parent.rotation), s = Math.sin(parent.rotation);
      const v = {
        x: parent.x + x * c - y * s,
        y: parent.y + x * s + y * c,
        rotation: parent.rotation + r,
      };
      result.set(name, v);
      return v;
    }
    for (const b of rig?.bones || []) resolve(b.name);
    return result;
  }

  function colors(c) { return c.skin || {}; }
  function drawCapsule(length, width, fill) {
    ctx.fillStyle = fill;
    ctx.beginPath();
    ctx.roundRect(-width / 2, -4, width, length + 8, Math.min(width / 2, 10));
    ctx.fill();
  }
  function drawCircle(r, fill) {
    ctx.fillStyle = fill;
    ctx.beginPath();
    ctx.arc(0, 0, r, 0, TAU);
    ctx.fill();
  }
  function drawEllipse(rx, ry, fill) {
    ctx.fillStyle = fill;
    ctx.beginPath();
    ctx.ellipse(0, 0, rx, ry, 0, 0, TAU);
    ctx.fill();
  }
  function atBone(world, name, fn) {
    const b = world.get(name);
    if (!b) return;
    ctx.save();
    ctx.translate(b.x, b.y);
    ctx.rotate(b.rotation);
    fn(b);
    ctx.restore();
  }

  function drawHair(c, activity) {
    const d = colors(c).dark, s = colors(c).secondary;
    const sway = reducedMotion ? 0 : Math.sin(time * 2.4) * activity;
    ctx.save();
    ctx.rotate(sway * .012);
    ctx.fillStyle = d;
    if (c.hair === 'twin-buns') {
      drawEllipse(30, 24, d);
      ctx.beginPath();
      ctx.arc(-23, -28, 16 + sway * .2, 0, TAU);
      ctx.arc(23, -28, 16 - sway * .2, 0, TAU);
      ctx.fill();
    } else if (c.hair === 'silver-lilac') {
      ctx.fillStyle = s;
      drawEllipse(32, 24, s);
      ctx.fillRect(-34, -4, 12, 48 + sway);
      ctx.fillRect(22, -4, 12, 48 - sway);
    } else if (c.hair === 'messy') {
      ctx.beginPath();
      ctx.moveTo(-30, -8); ctx.lineTo(-37, -34); ctx.lineTo(-18, -24);
      ctx.lineTo(-8, -43); ctx.lineTo(4, -25); ctx.lineTo(20, -42);
      ctx.lineTo(22, -21); ctx.lineTo(37, -28); ctx.lineTo(30, 5);
      ctx.closePath(); ctx.fill();
    } else if (c.hair === 'swept') {
      ctx.beginPath();
      ctx.moveTo(-31, -9); ctx.quadraticCurveTo(-8, -47, 34, -26);
      ctx.lineTo(22, 5); ctx.lineTo(-31, 7); ctx.closePath(); ctx.fill();
    } else {
      ctx.beginPath(); ctx.ellipse(0, -17, 31, 23, 0, Math.PI, TAU); ctx.fill();
    }
  }

  function drawAccessory(c) {
    const a = colors(c).accent, d = colors(c).dark, s = colors(c).secondary;
    if (c.accessory === 'visor') {
      ctx.fillStyle = a; ctx.globalAlpha = .9; ctx.fillRect(-31, -8, 62, 9); ctx.globalAlpha = 1;
      ctx.strokeStyle = s; ctx.strokeRect(-28, -6, 56, 5);
    } else if (c.accessory === 'headphones') {
      ctx.strokeStyle = a; ctx.lineWidth = 5; ctx.beginPath();
      ctx.arc(0, -10, 37, Math.PI * 1.05, Math.PI * 1.95); ctx.stroke();
      ctx.fillStyle = d; ctx.fillRect(-38, -3, 8, 17); ctx.fillRect(30, -3, 8, 17);
    } else if (c.accessory === 'coat') {
      const sway = reducedMotion ? 0 : Math.sin(time * 1.7) * 3;
      ctx.strokeStyle = a; ctx.lineWidth = 5; ctx.beginPath();
      ctx.moveTo(-31, 20); ctx.lineTo(-41 - sway, 94); ctx.moveTo(31, 20); ctx.lineTo(41 + sway, 94); ctx.stroke();
    } else if (c.accessory === 'notebook') {
      ctx.fillStyle = a; ctx.beginPath(); ctx.roundRect(36, 8, 25, 34, 4); ctx.fill();
      ctx.fillStyle = d; ctx.fillRect(40, 15, 16, 3); ctx.fillRect(40, 23, 13, 3);
    } else if (c.accessory === 'orb') {
      const p = reducedMotion ? 0 : Math.sin(time * 3) * 2;
      ctx.globalAlpha = .18; drawCircle(24 + p, a); ctx.globalAlpha = 1;
      drawCircle(12 + p, a); drawCircle(4, colors(c).highlight);
    } else if (c.accessory === 'star') {
      ctx.fillStyle = a; ctx.save(); ctx.translate(43, 18); ctx.rotate(reducedMotion ? 0 : time * .25);
      ctx.beginPath();
      for (let i = 0; i < 10; i++) { const ang = i * Math.PI / 5, r = i % 2 ? 6 : 15; ctx.lineTo(Math.cos(ang) * r, Math.sin(ang) * r); }
      ctx.closePath(); ctx.fill(); ctx.restore();
    }
  }

  function drawFace(c, activity) {
    const col = colors(c), expression = currentState === 'WARNING' ? 1 : currentState === 'COMPLETE' ? .7 : activity;
    ctx.fillStyle = col.dark;
    ctx.beginPath(); ctx.arc(-10, -1, 2.2, 0, TAU); ctx.arc(10, -1, 2.2, 0, TAU); ctx.fill();
    ctx.strokeStyle = col.dark; ctx.lineWidth = 2; ctx.beginPath();
    if (expression > .75) ctx.arc(0, 6, 8, 0.1, Math.PI - .1);
    else if (currentState === 'WARNING') ctx.moveTo(-6, 11), ctx.lineTo(6, 8);
    else ctx.arc(0, 9, 6, Math.PI + .1, TAU - .1);
    ctx.stroke();
  }

  function draw(c, poseData) {
    const r = canvas.getBoundingClientRect(), w = r.width, h = r.height;
    ctx.clearRect(0, 0, w, h);
    ctx.save();
    ctx.translate(w / 2, h * .54);
    const scale = Math.min(w / 250, h / 330) * (c.scale || 1);
    ctx.scale(scale, scale);
    const world = worldBones(library.rig, poseData);
    const col = colors(c);
    const activity = reducedMotion ? 0 : (c.animation?.gesture || 1) * (currentState === 'WORK' ? 1 : .55);

    for (const n of ['thigh_l','shin_l','foot_l','thigh_r','shin_r','foot_r','upper_arm_l','forearm_l','hand_l','upper_arm_r','forearm_r','hand_r']) {
      atBone(world, n, () => {
        if (n.startsWith('thigh')) drawCapsule(58, 18, col.main);
        else if (n.startsWith('shin')) drawCapsule(58, 16, col.secondary);
        else if (n.startsWith('foot')) drawEllipse(18, 7, col.dark);
        else if (n.startsWith('upper')) drawCapsule(48, 16, col.main);
        else if (n.startsWith('forearm')) drawCapsule(42, 14, col.secondary);
        else drawCircle(9, col.skin);
      });
    }

    atBone(world, 'torso', () => {
      ctx.fillStyle = col.main; ctx.beginPath(); ctx.roundRect(-34, -4, 68, 96, 16); ctx.fill();
      ctx.fillStyle = col.secondary; ctx.beginPath(); ctx.moveTo(-23, 5); ctx.lineTo(0, 27); ctx.lineTo(23, 5); ctx.lineTo(17, 84); ctx.lineTo(-17, 84); ctx.closePath(); ctx.fill();
      ctx.fillStyle = col.accent; ctx.fillRect(-3, 10, 6, 68);
      if (currentState === 'WORK' && !reducedMotion) { ctx.globalAlpha = .22; ctx.fillStyle = col.highlight; ctx.fillRect(-23, 32, 46, 4); ctx.globalAlpha = 1; }
    });

    atBone(world, 'neck', () => { ctx.fillStyle = col.skin; ctx.beginPath(); ctx.roundRect(-10, -1, 20, 24, 8); ctx.fill(); });
    atBone(world, 'head', () => {
      drawEllipse(31, 35, col.skin);
      drawHair(c, activity);
      drawFace(c, activity);
      drawAccessory(c);
    });

    ctx.fillStyle = col.highlight; ctx.globalAlpha = .08; ctx.beginPath(); ctx.ellipse(0, 118, 82, 18, 0, 0, TAU); ctx.fill();
    ctx.restore();
  }

  function render(now) {
    const dt = Math.min(.05, (now - last) / 1000);
    last = now;
    time += dt;
    if (library) {
      const c = library.characters[characterId] || library.characters.dharen;
      const current = library.animationTracks[currentState] || library.animationTracks.IDLE;
      const target = library.animationTracks[targetState] || current;
      if (transition < 1 && !reducedMotion) transition = clamp(transition + dt * 4.8, 0, 1);
      else transition = 1;
      const currentTime = reducedMotion ? 0 : (current.loop ? time % (current.duration || 1) : Math.min(time, current.duration || 1));
      const targetTime = reducedMotion ? 0 : (target.loop ? time % (target.duration || 1) : Math.min(time, target.duration || 1));
      draw(c, mix(pose(currentState, currentTime), pose(targetState, targetTime), ease(transition)));
    }
    requestAnimationFrame(render);
  }

  window.addEventListener('message', event => {
    const data = event.data || {};
    if (data.type !== 'criterivox-character-state') return;
    reducedMotion = data.reducedMotion === true;
    const next = String(data.state || 'IDLE').toUpperCase();
    if (!library?.animationTracks?.[next]) return;
    if (next === targetState) return;
    currentState = targetState;
    targetState = next;
    transition = reducedMotion ? 1 : 0;
    stateEl.textContent = next;
  });

  fetch('character_runtime/characters.json', { cache: 'no-store' })
    .then(response => { if (!response.ok) throw new Error(`HTTP ${response.status}`); return response.json(); })
    .then(data => {
      library = data;
      if (!library.animationTracks[currentState]) currentState = 'IDLE';
      if (!library.animationTracks[targetState]) targetState = currentState;
      stateEl.textContent = currentState;
      requestAnimationFrame(render);
    })
    .catch(error => {
      console.error(error);
      stateEl.textContent = 'Character runtime unavailable';
    });
})();
