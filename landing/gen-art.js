// Generates two renovation drawings in the same isometric style and palette as the ADU art
// (white/grey existing house, blue = the new work, green ground). Output: landing/art/art-kitchen.svg, art-exterior.svg
const fs = require('fs');
const path = require('path');
// Run: node landing/gen-art.js landing/art
const OUT = process.argv[2];

const C = { // palette taken from art-detached.svg
  old: { top: '#ffffff', l: '#e7edf2', r: '#d2dbe3', s: '#8c9aa8' },
  neu: { top: '#33a0e6', l: '#0b6cab', r: '#0a5a91', s: '#074a78' },
  slab: { top: '#f9fcff', l: '#e7edf2', r: '#d2dbe3', s: '#5c6f82' },
  floor: { top: '#f3ece0', l: '#e3d7c3', r: '#d6c8b0', s: '#b9a88c' },
  wood: { top: '#f2c27a', l: '#dca35a', r: '#c98f45', s: '#9a6a2e' },
  orange: { top: '#f2a826', l: '#e89915', r: '#c27b0b', s: '#8a5600' },
  ground: { fill: '#e8f3e6', s: '#cfe3cb' }, glass: { fill: '#bfe4fb', s: '#5c6f82' }
};

function scene(u) {
  const items = [], pts = [];
  const P = (x, y, z) => { const p = [(x - y) * 0.866 * u, (x + y) * 0.5 * u - z * u]; pts.push(p); return p; };
  const poly = (ps, fill, stroke, sw = 1) => items.push(`<polygon points="${ps.map(p => p.map(v => v.toFixed(1)).join(',')).join(' ')}" fill="${fill}" stroke="${stroke}" stroke-width="${sw}" stroke-linejoin="round"/>`);
  return {
    pts, items,
    box(x0, y0, z0, x1, y1, z1, c) { // visible faces: y = y1 (along x), x = x1 (along y), top
      poly([P(x0, y1, z0), P(x1, y1, z0), P(x1, y1, z1), P(x0, y1, z1)], c.l, c.s);
      poly([P(x1, y0, z0), P(x1, y1, z0), P(x1, y1, z1), P(x1, y0, z1)], c.r, c.s);
      poly([P(x0, y0, z1), P(x1, y0, z1), P(x1, y1, z1), P(x0, y1, z1)], c.top, c.s);
    },
    quadY(y, x0, x1, z0, z1, fill, stroke, sw = 0.8) { poly([P(x0, y, z0), P(x1, y, z0), P(x1, y, z1), P(x0, y, z1)], fill, stroke, sw); },
    quadX(x, y0, y1, z0, z1, fill, stroke, sw = 0.8) { poly([P(x, y0, z0), P(x, y1, z0), P(x, y1, z1), P(x, y0, z1)], fill, stroke, sw); },
    flat(x0, y0, x1, y1, z, fill, stroke) { poly([P(x0, y0, z), P(x1, y0, z), P(x1, y1, z), P(x0, y1, z)], fill, stroke); },
    raw(ps, fill, stroke, sw) { poly(ps.map(a => P(...a)), fill, stroke, sw); },
    line(a, b, stroke, sw = 0.8) { const p = P(...a), q = P(...b); items.push(`<line x1="${p[0].toFixed(1)}" y1="${p[1].toFixed(1)}" x2="${q[0].toFixed(1)}" y2="${q[1].toFixed(1)}" stroke="${stroke}" stroke-width="${sw}"/>`); },
    tree(x, y, r) { const p = P(x, y, 0); pts.push([p[0] - r - 2, p[1] - 22 - r]); items.push(`<rect x="${(p[0] - 1.5).toFixed(1)}" y="${(p[1] - 10).toFixed(1)}" width="3" height="10" fill="#8a6a4a"/><circle cx="${p[0].toFixed(1)}" cy="${(p[1] - 16).toFixed(1)}" r="${r}" fill="#7bbf6a"/><circle cx="${(p[0] - 4).toFixed(1)}" cy="${(p[1] - 13).toFixed(1)}" r="${r * 0.66}" fill="#8fd07e"/>`); },
    svg() {
      const xs = pts.map(p => p[0]), ys = pts.map(p => p[1]);
      const pad = 8, minX = Math.min(...xs) - pad, minY = Math.min(...ys) - pad, w = Math.max(...xs) - minX + pad, h = Math.max(...ys) - minY + pad;
      return `<svg xmlns="http://www.w3.org/2000/svg" viewBox="${minX.toFixed(1)} ${minY.toFixed(1)} ${w.toFixed(1)} ${h.toFixed(1)}" role="img" aria-hidden="true" preserveAspectRatio="xMidYMid meet">${items.join('')}</svg>`;
    }
  };
}

// ---- Kitchen and bath remodel: a room cutaway with new cabinets, counters and an island ----
{
  const s = scene(16);
  s.box(0, 0, 0, 8, 8, 0.3, C.floor);                       // floor
  s.box(0, 0, 0.3, 8, 0.35, 4.3, C.old);                     // back wall (along x)
  s.box(0, 0.35, 0.3, 0.35, 8, 4.3, C.old);                  // side wall (along y)
  s.quadY(0.351, 4.9, 7.0, 2.4, 3.7, C.glass.fill, C.glass.s); // window
  s.line([5.95, 0.352, 2.4], [5.95, 0.352, 3.7], C.glass.s);
  s.box(0.35, 0.35, 2.85, 4.4, 1.0, 3.85, C.neu);            // upper cabinets
  for (const x of [1.7, 3.05]) s.line([x, 1.001, 2.95], [x, 1.001, 3.75], '#074a78');
  s.box(0.35, 0.35, 0.3, 7.3, 1.75, 1.9, C.neu);             // base cabinets on back wall
  for (const x of [1.75, 3.15, 4.55, 5.95]) s.line([x, 1.751, 0.4], [x, 1.751, 1.8], '#074a78');
  s.box(0.35, 0.35, 1.9, 7.4, 1.85, 2.1, C.slab);            // counter
  s.flat(5.2, 0.6, 6.4, 1.4, 2.101, '#9fb3c6', '#5c6f82');   // sink
  s.box(0.35, 1.85, 0.3, 1.75, 6.2, 1.9, C.neu);             // base cabinets on side wall
  for (const y of [3.2, 4.7]) s.line([1.751, y, 0.4], [1.751, y, 1.8], '#074a78');
  s.box(0.35, 1.85, 1.9, 1.85, 6.3, 2.1, C.slab);            // counter
  s.box(3.5, 3.9, 0.3, 6.5, 5.5, 1.9, C.neu);                // island
  s.box(3.4, 3.8, 1.9, 6.6, 5.6, 2.1, C.slab);
  for (const x of [4.0, 5.3]) s.box(x, 6.1, 0.3, x + 0.6, 6.7, 1.35, C.orange); // stools
  fs.writeFileSync(path.join(OUT, 'art-kitchen.svg'), s.svg());
}

// ---- Exterior: new roof, siding refresh and a deck on an existing home ----
{
  const s = scene(13);
  s.raw([[-1, -1, 0], [14, -1, 0], [14, 11, 0], [-1, 11, 0]], C.ground.fill, C.ground.s, 1);
  s.box(2, 2, 0, 9, 7, 3.2, C.old);                          // house walls
  for (const x of [3.0, 6.6]) s.quadY(7.001, x, x + 1.5, 1.2, 2.4, C.glass.fill, C.glass.s);
  s.quadY(7.001, 4.9, 5.9, 0, 2.2, '#f9fcff', C.glass.s);    // door
  s.quadX(9.001, 3.2, 4.8, 1.2, 2.4, C.glass.fill, C.glass.s);
  // new roof (blue): back slope, gable end, front slope
  s.raw([[1.6, 1.6, 3.2], [9.4, 1.6, 3.2], [9.4, 4.5, 5.3], [1.6, 4.5, 5.3]], C.neu.r, C.neu.s, 1);
  s.raw([[9.0, 2.0, 3.2], [9.0, 7.0, 3.2], [9.0, 4.5, 5.0]], C.old.r, C.old.s, 1);
  s.raw([[1.6, 7.4, 3.2], [9.4, 7.4, 3.2], [9.4, 4.5, 5.3], [1.6, 4.5, 5.3]], C.neu.top, C.neu.s, 1);
  s.box(9, 3, 0, 12.4, 7.4, 0.55, C.wood);                   // new deck
  for (const x of [10.1, 11.2]) s.line([x, 3.05, 0.551], [x, 7.35, 0.551], '#c98f45', 0.7);
  s.tree(12.8, 9.6, 8);
  s.tree(0.4, 9.2, 6);
  fs.writeFileSync(path.join(OUT, 'art-exterior.svg'), s.svg());
}
console.log('written');
