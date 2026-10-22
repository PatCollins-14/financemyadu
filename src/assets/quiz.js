/* Progressive enhancement only. Without JavaScript the quiz is one normal HTML form with every
   field visible, posted to FORM_ENDPOINT. All page text is already in the HTML. */
(function () {
  var root = document.documentElement;
  var body = document.body;
  var endpoint = body.getAttribute('data-endpoint') || '';
  var analyticsId = body.getAttribute('data-analytics') || '';
  var consentKey = 'adu_consent';

  function getConsent() { try { return localStorage.getItem(consentKey); } catch (e) { return null; } }
  function setConsent(v) { try { localStorage.setItem(consentKey, v); } catch (e) { /* ignore */ } }

  /* ---- analytics: off by default, loads only after explicit consent ---- */
  var queued = [];
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
    queued.splice(0).forEach(function (n) { sendEvent(n); });
  }
  function sendEvent(name) {
    if (window.gtag) { window.gtag('event', name, { page: 'adu_funnel' }); }
    else if (window.dataLayer) { window.dataLayer.push({ event: name, page: 'adu_funnel' }); }
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

  /* ---- click events ---- */
  document.addEventListener('click', function (e) {
    var a = e.target.closest('[data-event]');
    if (a) track(a.getAttribute('data-event'));
  });

  /* ---- UTM capture (values come from the visitor's own URL) ---- */
  var form = document.getElementById('quizForm');
  if (!form) return;
  try {
    var q = new URLSearchParams(location.search);
    ['utm_source', 'utm_medium', 'utm_campaign', 'utm_content'].forEach(function (k) {
      var el = form.elements[k];
      if (el && q.get(k)) el.value = q.get(k);
    });
  } catch (e) { /* ignore */ }

  /* ---- step-by-step quiz ---- */
  root.classList.add('js');
  var steps = Array.prototype.slice.call(form.querySelectorAll('.qstep'));
  var bar2 = document.getElementById('quizBar');
  var i = 0, started = false;
  function show(n) {
    i = n;
    steps.forEach(function (s, idx) { s.hidden = idx !== n; });
    if (bar2) bar2.style.width = Math.round(((n + 1) / steps.length) * 100) + '%';
    var back = document.getElementById('quizBack');
    var next = document.getElementById('quizNext');
    var submit = document.getElementById('quizSubmit');
    if (back) back.hidden = n === 0;
    if (next) next.hidden = n === steps.length - 1;
    if (submit) submit.hidden = n !== steps.length - 1;
    var f = steps[n].querySelector('select,input');
    if (f && started) f.focus();
  }
  function validate(scope) {
    var ok = true;
    scope.querySelectorAll('input,select').forEach(function (el) {
      var wrap = el.closest('.field') || el.closest('.consent');
      var bad = false;
      if (el.type === 'checkbox') { bad = el.required && !el.checked; }
      else if (el.required) {
        var v = (el.value || '').trim();
        bad = !v;
        if (!bad && el.name === 'phone') bad = v.replace(/\D/g, '').length < 10;
        if (!bad && el.type === 'email') bad = !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(v);
      }
      if (wrap) wrap.classList.toggle('err', bad);
      if (bad && ok) { ok = false; el.focus(); }
    });
    return ok;
  }
  if (steps.length) {
    show(0);
    form.addEventListener('focusin', function () {
      if (!started) { started = true; track('quiz_start'); }
    });
    var nextBtn = document.getElementById('quizNext');
    var backBtn = document.getElementById('quizBack');
    if (nextBtn) nextBtn.addEventListener('click', function () {
      if (!started) { started = true; track('quiz_start'); }
      if (validate(steps[i])) show(i + 1);
    });
    if (backBtn) backBtn.addEventListener('click', function () { show(i - 1); });
  }
  form.addEventListener('input', function (e) {
    var w = e.target.closest('.field') || e.target.closest('.consent');
    if (w) w.classList.remove('err');
  });
  form.addEventListener('submit', function (e) {
    e.preventDefault();
    if (!validate(form)) return;
    var note = document.getElementById('quizNote');
    if (!endpoint) {
      if (note) { note.textContent = 'This form is not connected yet, so nothing was sent. Please call or book a time instead.'; note.hidden = false; }
      return;
    }
    var btn = document.getElementById('quizSubmit');
    if (btn) { btn.disabled = true; btn.textContent = 'Sending...'; }
    var data = new URLSearchParams(new FormData(form));
    fetch(endpoint, { method: 'POST', headers: { 'Content-Type': 'application/x-www-form-urlencoded' }, body: data })
      .then(function (r) { if (!r.ok) throw new Error('bad response'); return r; })
      .then(function () {
        track('quiz_complete');
        form.hidden = true;
        var ok = document.getElementById('quizOk');
        if (ok) { ok.classList.add('show'); ok.setAttribute('tabindex', '-1'); ok.focus(); }
      })
      .catch(function () {
        if (btn) { btn.disabled = false; btn.textContent = 'See my financing options'; }
        if (note) { note.textContent = 'Sorry, that did not send. Please call or book a time instead.'; note.hidden = false; }
      });
  });
})();
