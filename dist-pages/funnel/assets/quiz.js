/* Progressive enhancement only. Without JavaScript the lead form is one normal HTML form
   (name, email, phone) posted to FORM_ENDPOINT. All page text is already in the HTML. */
(function () {
  var body = document.body;
  var endpoint = body.getAttribute('data-endpoint') || '';
  var analyticsId = body.getAttribute('data-analytics') || '';
  var consentKey = 'adu_consent';

  function getConsent() { try { return localStorage.getItem(consentKey); } catch (e) { return null; } }
  function setConsent(v) { try { localStorage.setItem(consentKey, v); } catch (e) { /* ignore */ } }

  /* ---- analytics: off by default, loads only after explicit consent ---- */
  var queued = [];
  function sendEvent(name) {
    if (window.gtag) { window.gtag('event', name, { page: 'adu_funnel' }); }
    else if (window.dataLayer) { window.dataLayer.push({ event: name, page: 'adu_funnel' }); }
  }
  function loadAnalytics() {
    if (!analyticsId || window.__aduAnalytics) return;
    window.__aduAnalytics = true;
    window.dataLayer = window.dataLayer || [];
    var s = document.createElement('script');
    s.async = true;
    if (analyticsId.indexOf('GTM-') === 0) {
      window.dataLayer.push({ 'gtm.start': Date.now(), event: 'gtm.js' });
      s.src = 'https://www.googletagmanager.com/gtm.js?id=' + encodeURIComponent(analyticsId);
    } else {
      window.gtag = function () { window.dataLayer.push(arguments); };
      window.gtag('js', new Date());
      window.gtag('config', analyticsId, { anonymize_ip: true });
      s.src = 'https://www.googletagmanager.com/gtag/js?id=' + encodeURIComponent(analyticsId);
    }
    document.head.appendChild(s);
    queued.splice(0).forEach(sendEvent);
  }
  function track(name) {
    if (!analyticsId || getConsent() !== 'granted') return;
    if (window.__aduAnalytics) { sendEvent(name); } else { queued.push(name); }
  }
  window.aduTrack = track;

  var bar = document.getElementById('consentBar');
  if (analyticsId && bar) {
    var c = getConsent();
    if (c === 'granted') { loadAnalytics(); }
    else if (c !== 'denied') { bar.classList.add('show'); }
    bar.addEventListener('click', function (e) {
      var t = e.target.closest('[data-consent]');
      if (!t) return;
      var v = t.getAttribute('data-consent');
      setConsent(v);
      bar.classList.remove('show');
      if (v === 'granted') loadAnalytics();
    });
  }

  document.addEventListener('click', function (e) {
    var a = e.target.closest('[data-event]');
    if (a) track(a.getAttribute('data-event'));
  });

  /* ---- lead form ---- */
  var form = document.getElementById('leadForm');
  if (!form) return;
  form.setAttribute('novalidate', ''); /* our messages replace the browser's; without JS the browser validates */
  try {
    var q = new URLSearchParams(location.search);
    ['utm_source', 'utm_medium', 'utm_campaign', 'utm_content'].forEach(function (k) {
      var el = form.elements[k];
      if (el && q.get(k)) el.value = q.get(k);
    });
  } catch (e) { /* ignore */ }

  var started = false;
  form.addEventListener('focusin', function () { if (!started) { started = true; track('quiz_start'); } });
  form.addEventListener('input', function (e) { var f = e.target.closest('.field'); if (f) f.classList.remove('err'); });

  function validate() {
    var ok = true;
    form.querySelectorAll('input[required]').forEach(function (el) {
      var v = (el.value || '').trim();
      var bad = !v;
      if (!bad && el.name === 'phone') bad = v.replace(/\D/g, '').length < 10;
      if (!bad && el.type === 'email') bad = !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(v);
      var wrap = el.closest('.field');
      if (wrap) wrap.classList.toggle('err', bad);
      if (bad && ok) { ok = false; el.focus(); }
    });
    return ok;
  }

  form.addEventListener('submit', function (e) {
    e.preventDefault();
    if (!validate()) return;
    var note = document.getElementById('leadNote');
    if (!endpoint) {
      if (note) { note.textContent = 'This form is not connected yet, so nothing was sent. Please call or book a time instead.'; note.hidden = false; }
      return;
    }
    var btn = document.getElementById('leadSubmit');
    if (btn) { btn.disabled = true; btn.textContent = 'Sending...'; }
    var data = new URLSearchParams(new FormData(form));
    fetch(endpoint, { method: 'POST', headers: { 'Content-Type': 'application/x-www-form-urlencoded' }, body: data })
      .then(function (r) { if (!r.ok) throw new Error('bad response'); return r; })
      .then(function () {
        track('quiz_complete');
        var first = (form.elements.name.value || '').trim().split(' ')[0];
        var nm = document.getElementById('okName');
        if (nm && first) nm.textContent = first;
        form.hidden = true;
        var ok = document.getElementById('leadOk');
        if (ok) { ok.hidden = false; ok.setAttribute('tabindex', '-1'); ok.focus(); }
      })
      .catch(function () {
        if (btn) { btn.disabled = false; btn.textContent = 'See my financing options'; }
        if (note) { note.textContent = 'Sorry, that did not send. Please call or book a time instead.'; note.hidden = false; }
      });
  });

  // review carousel: arrows, dots, keyboard scroll. Without JS the row still scrolls sideways by touch or trackpad.
  (function () {
    /* reviews: shuffle on every page load while spreading the sources evenly (only when the data asks for it) */
    (function () {
      var tr = document.querySelector('.g-track');
      if (!tr || tr.getAttribute('data-order') !== 'random-balanced') return;
      var kids = Array.prototype.slice.call(tr.children), groups = {};
      kids.forEach(function (c) { var k = c.getAttribute('data-platform') || ''; (groups[k] = groups[k] || []).push(c); });
      function shuffle(a) { for (var i = a.length - 1; i > 0; i--) { var j = Math.floor(Math.random() * (i + 1)), t = a[i]; a[i] = a[j]; a[j] = t; } return a; }
      var keys = Object.keys(groups).sort(function (a, b) { return groups[a].length - groups[b].length; });
      if (!keys.length) return;
      var order = shuffle(groups[keys[0]].slice());
      for (var k = 1; k < keys.length; k++) {
        var added = shuffle(groups[keys[k]].slice()), gaps = order.length + 1, base = Math.floor(added.length / gaps), extra = added.length % gaps, counts = [], idx = [];
        for (var g = 0; g < gaps; g++) { counts.push(base); idx.push(g); }
        shuffle(idx); for (var x = 0; x < extra; x++) counts[idx[x]]++;
        var next = [], cur = 0;
        for (var gap = 0; gap < gaps; gap++) { for (var z = 0; z < counts[gap]; z++) next.push(added[cur++]); if (gap < order.length) next.push(order[gap]); }
        order = next;
      }
      order.forEach(function (c) { tr.appendChild(c); });
    })();
    var track = document.querySelector('.g-track');
    if (!track) return;
    var cards = track.querySelectorAll('.g-card');
    var ctl = document.querySelector('.g-ctl');
    var dots = document.querySelector('.g-dots');
    var prev = ctl && ctl.querySelector('[data-dir="-1"]');
    var next = ctl && ctl.querySelector('[data-dir="1"]');
    var reduce = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    function step() { return cards.length > 1 ? cards[1].offsetLeft - cards[0].offsetLeft : track.clientWidth; }
    function perView() { return Math.max(1, Math.round(track.clientWidth / step())); }
    function go(i) {
      i = Math.max(0, Math.min(cards.length - 1, i));
      track.scrollTo({ left: cards[i].offsetLeft - cards[0].offsetLeft, behavior: reduce ? 'auto' : 'smooth' });
    }
    function current() { return Math.round(track.scrollLeft / step()); }
    function buildDots() {
      if (!dots) return;
      var pages = Math.ceil(cards.length / perView());
      var counter = pages > 10;
      if (counter) { dots.classList.add('g-count'); dots.textContent = ''; return; }
      dots.classList.remove('g-count');
      if (dots.children.length === pages) return;
      dots.textContent = '';
      for (var p = 0; p < pages; p++) {
        (function (p) {
          var d = document.createElement('button');
          d.type = 'button'; d.className = 'g-dot';
          d.setAttribute('aria-label', 'Show reviews page ' + (p + 1) + ' of ' + pages);
          d.addEventListener('click', function () { go(p * perView()); });
          dots.appendChild(d);
        })(p);
      }
    }
    function sync() {
      buildDots();
      var pv = perView(), pages = Math.ceil(cards.length / pv);
      var page = track.scrollLeft >= track.scrollWidth - track.clientWidth - 2 ? pages - 1 : Math.min(pages - 1, Math.round(current() / pv));
      if (prev) prev.disabled = track.scrollLeft <= 2;
      if (next) next.disabled = track.scrollLeft >= track.scrollWidth - track.clientWidth - 2;
      if (dots && dots.classList.contains('g-count')) dots.textContent = (page + 1) + ' of ' + pages;
      else if (dots) Array.prototype.forEach.call(dots.children, function (d, n) { d.classList.toggle('on', n === page); });
    }
    if (ctl) {
      ctl.hidden = false;
      ctl.addEventListener('click', function (e) {
        var b = e.target.closest('[data-dir]'); if (!b) return;
        go(current() + parseInt(b.getAttribute('data-dir'), 10) * perView());
      });
    }
    if (dots) dots.hidden = false;
    track.addEventListener('scroll', function () { window.requestAnimationFrame(sync); }, { passive: true });
    track.addEventListener('keydown', function (e) {
      if (e.key === 'ArrowRight') { e.preventDefault(); go(current() + 1); }
      if (e.key === 'ArrowLeft') { e.preventDefault(); go(current() - 1); }
    });
    var showAll = document.querySelector('.g-show-all');
    if (showAll) {
      showAll.addEventListener('click', function () {
        var panel = showAll.closest('.g-carousel'), on = panel.classList.toggle('g-expanded');
        showAll.setAttribute('aria-pressed', String(on));
        showAll.textContent = on ? 'Back to review carousel' : 'Show all ' + cards.length + ' review cards';
        if (!on) { track.scrollLeft = 0; sync(); }
      });
    }
    window.addEventListener('resize', sync);
    sync();
  })();

  // platform review widgets: each loads only when the visitor presses its button or has already accepted cookies
  (function () {
    var boxes = document.querySelectorAll('.g-widget');
    if (!boxes.length) return;
    function loadWidget(box) {
      var tpl = box.querySelector('template'), slot = box.querySelector('.g-widget-slot');
      if (!tpl || !slot || box.getAttribute('data-loaded')) return;
      box.setAttribute('data-loaded', '1');
      slot.appendChild(tpl.content.cloneNode(true));
      Array.prototype.forEach.call(slot.querySelectorAll('script'), function (old) {
        var s = document.createElement('script');
        Array.prototype.forEach.call(old.attributes, function (a) { s.setAttribute(a.name, a.value); });
        s.text = old.text;
        old.parentNode.replaceChild(s, old);
      });
      slot.hidden = false;
      var b = box.querySelector('.g-widget-load'), w = box.querySelector('.g-widget-wait');
      if (b) b.hidden = true;
      if (w) w.hidden = true;
    }
    document.addEventListener('click', function (e) {
      var b = e.target.closest('.g-widget-load'); if (!b) return;
      loadWidget(b.closest('.g-widget'));
    });
    if (getConsent() === 'granted') Array.prototype.forEach.call(boxes, loadWidget);
  })();
})();
