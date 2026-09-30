(() => {
  'use strict';
  const R = Reihum;
  const $app = document.getElementById('app');
  const STORE_KEY = 'reihum-proto-v1';

  // ---- state ---------------------------------------------------------------
  const S = { noStorage: false, plans: [], notes: '', view: 'list', planId: null, sheet: null, wiz: null, toast: '', confirm: '', focusId: null };

  function loadStore() {
    try {
      const raw = localStorage.getItem(STORE_KEY);
      if (!raw) return null;
      const data = JSON.parse(raw);
      return data && Array.isArray(data.plans) ? data : null;
    } catch (e) { return null; }
  }
  function saveStore() {
    try { localStorage.setItem(STORE_KEY, JSON.stringify({ plans: S.plans, notes: S.notes })); } catch (e) { S.noStorage = true; }
  }
  function storageWorks() {
    try { localStorage.setItem('__reihum_probe', '1'); localStorage.removeItem('__reihum_probe'); return true; } catch (e) { return false; }
  }

  // ---- helpers -------------------------------------------------------------
  const WD = ['Sonntag', 'Montag', 'Dienstag', 'Mittwoch', 'Donnerstag', 'Freitag', 'Samstag'];
  const WD_PICK = [2, 3, 4, 5, 6, 7, 1];
  const WD_SHORT = ['So.', 'Mo.', 'Di.', 'Mi.', 'Do.', 'Fr.', 'Sa.'];
  const MONTHS = ['Januar', 'Februar', 'März', 'April', 'Mai', 'Juni', 'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember'];
  const MON_SHORT = ['Jan.', 'Feb.', 'März', 'Apr.', 'Mai', 'Juni', 'Juli', 'Aug.', 'Sep.', 'Okt.', 'Nov.', 'Dez.'];
  const KINDS = [['daily', 'Täglich'], ['weekdays', 'Jeden Werktag'], ['weekly', 'Wöchentlich'], ['biweekly', 'Alle zwei Wochen'], ['monthlyNth', 'Monatlich (Wochentag)'], ['monthlyDay', 'Monatlich (Datum)']];
  const esc = (s) => String(s == null ? '' : s).replace(/[&<>"']/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));
  const today = () => R.todayLocal();
  const short = (iso) => { const p = R.parse(iso); return WD_SHORT[R.weekday(iso) - 1] + ', ' + p.d + '. ' + MON_SHORT[p.m - 1]; };
  const long = (iso) => { const p = R.parse(iso); return WD[R.weekday(iso) - 1] + ', ' + p.d + '. ' + MONTHS[p.m - 1] + ' ' + p.y; };
  const monthTitle = (iso) => { const p = R.parse(iso); return MONTHS[p.m - 1] + ' ' + p.y; };
  const initials = (name) => name.trim().split(/\s+/).slice(0, 2).map((w) => (w[0] || '').toUpperCase()).join('');
  const colorVar = (i) => 'var(--m' + (Math.abs(i) % 10) + ')';
  const findPlan = (id) => S.plans.find((p) => p.id === id) || null;
  const currentPlan = () => findPlan(S.planId);
  const fmtDuration = (ms) => { const s = Math.max(0, Math.round(ms / 1000)); return Math.floor(s / 60) + ':' + String(s % 60).padStart(2, '0'); };

  function rhythmLabel(r) {
    switch (r.kind) {
      case 'daily': return 'Täglich';
      case 'weekdays': return 'Jeden Werktag';
      case 'weekly': return 'Jeden ' + WD[r.weekday - 1];
      case 'biweekly': return 'Alle zwei Wochen am ' + WD[r.weekday - 1];
      case 'monthlyNth': return 'Monatlich am ' + (r.ordinal === -1 ? 'letzten' : r.ordinal + '.') + ' ' + WD[r.weekday - 1];
      case 'monthlyDay': return 'Monatlich am ' + r.day + '.';
      default: return '';
    }
  }
  const rhythmDraft = (r) => ({ kind: r.kind, weekday: r.weekday || 6, ordinal: r.ordinal || 1, day: r.day || 1 });
  function rhythmFromDraft(d) {
    switch (d.kind) {
      case 'weekly': case 'biweekly': return { kind: d.kind, weekday: d.weekday };
      case 'monthlyNth': return { kind: 'monthlyNth', ordinal: d.ordinal, weekday: d.weekday };
      case 'monthlyDay': return { kind: 'monthlyDay', day: d.day };
      default: return { kind: d.kind };
    }
  }
  function avatar(member, size) {
    const st = 'background:' + colorVar(member.colorIndex) + (size ? ';width:' + size + 'px;height:' + size + 'px;font-size:' + Math.round(size * 0.4) + 'px' : '');
    return '<span class="avatar" style="' + st + '" aria-hidden="true">' + esc(initials(member.name)) + '</span>';
  }
  function nextSlot(plan, from) { return R.sortedSlots(plan).find((s) => s.date >= from && !s.isSkipped) || null; }
  function whoText(plan, slot) { const n = R.namesOf(plan, slot); return n.length ? n.join(' & ') : 'offen'; }

  function samplePlan() {
    const t = today();
    let start = t;
    while (R.weekday(start) !== 6) start = R.addDays(start, 1);
    const names = ['Alex', 'Bea', 'Chris', 'Dana', 'Eli'];
    const plan = {
      id: R.uid(), name: 'Beispiel: Znüni-Dienst', colorIndex: 1, rhythm: { kind: 'weekly', weekday: 6 }, start, end: R.addDays(start, 12 * 7 - 1),
      slotSize: 1, showAttribution: true, isSample: true,
      members: names.map((n, i) => ({ id: R.uid(), name: n, weight: 1, colorIndex: i, isActive: true, absences: [] })), slots: []
    };
    plan.members[2].absences.push({ start: R.addDays(start, 14), end: R.addDays(start, 27), note: 'Ferien' });
    return R.regenerate(plan, t);
  }

  function setPath(path, value) {
    const keys = path.split('.');
    let o = S;
    for (let i = 0; i < keys.length - 1; i++) { o = o[keys[i]]; if (o == null) return; }
    o[keys[keys.length - 1]] = value;
  }
  const getPath = (path) => path.split('.').reduce((o, k) => (o == null ? o : o[k]), S);

  // ---- toast ---------------------------------------------------------------
  let toastTimer = null;
  function toast(msg) {
    S.toast = msg; render();
    clearTimeout(toastTimer);
    toastTimer = setTimeout(() => { S.toast = ''; render(); }, 3200);
  }

  // ---- rendering -----------------------------------------------------------
  let lastSheetKey = '';
  function render() {
    const scrollY = window.scrollY;
    const sheetScroll = document.querySelector('.sheet-body') ? document.querySelector('.sheet-body').scrollTop : 0;
    let html = '';
    if (S.wiz) html = viewWizard();
    else if (S.view === 'detail' && currentPlan()) html = viewDetail(currentPlan());
    else html = viewList();
    if (S.sheet && !S.wiz) html += viewSheet();
    if (S.toast) html += '<div class="toast' + (S.sheet && !S.wiz ? ' top' : '') + '" role="status">' + esc(S.toast) + '</div>';
    $app.innerHTML = html;
    document.documentElement.style.overflow = S.sheet ? 'hidden' : '';
    const sb = document.querySelector('.sheet-body');
    if (sb) sb.scrollTop = sheetScroll;
    window.scrollTo(0, scrollY);
    const sheetKey = S.sheet && !S.wiz ? S.sheet.type + ':' + (S.sheet.editing || '') : '';
    if (S.focusId) { const el = document.getElementById(S.focusId); if (el) el.focus(); S.focusId = null; }
    else if (sheetKey && sheetKey !== lastSheetKey) { const sheetEl = document.querySelector('.sheet'); if (sheetEl) sheetEl.focus(); }
    lastSheetKey = sheetKey;
  }

  // ---- list view -----------------------------------------------------------
  function viewList() {
    const t = today();
    const todayLines = S.plans.map((p) => { const s = p.slots.find((x) => x.date === t && !x.isSkipped); return s ? p.name + ': ' + whoText(p, s) : null; }).filter(Boolean);
    let h = '<div class="wrap">';
    h += '<header class="top"><div><h1>Reihum</h1><p class="tag">Wer ist dran?</p></div><button class="btn primary sm" data-act="newPlan" id="btn-new">Neuer Plan</button></header>';
    h += '<div class="stack">';
    if (S.noStorage) h += '<p class="warn">In diesem Fenster kann der Browser nichts speichern. Deine Pläne und Notizen gehen beim Neuladen der Seite verloren. Kopiere Notizen deshalb, bevor du die Seite verlässt.</p>';
    h += '<p class="note">Prototyp zum Ausprobieren. Deine Eingaben bleiben in diesem Browser und werden nirgends hin gesendet. Nimm für den Test am besten Vornamen.</p>';
    if (todayLines.length) h += '<div class="today">Heute\n' + esc(todayLines.join('\n')) + '</div>';
    if (!S.plans.length) {
      h += '<div class="empty"><h2>Wer ist dran?</h2><p>Erstelle einen fairen Plan für alles, was ihr euch abwechselnd teilt: Znüni, Putzen, Elterndienst, Kuchen.</p>' +
        '<button class="btn primary" data-act="newPlan">Ersten Plan erstellen</button><button class="btn" data-act="addSample">Beispielplan anlegen</button></div>';
    } else {
      h += '<div class="section-title">Pläne</div>';
      for (const p of S.plans) {
        const n = nextSlot(p, t);
        const sub = n ? 'Nächster Termin: ' + short(n.date) + ' – ' + whoText(p, n) : 'Keine anstehenden Termine';
        h += '<button class="card" data-act="openPlan" data-id="' + esc(p.id) + '"><span class="dot" style="background:' + colorVar(p.colorIndex) + '"></span><div><div class="t">' + esc(p.name) + '</div><div class="s">' + esc(sub) + '</div></div></button>';
      }
    }
    h += '<details class="tester"><summary>So testest du (5 Aufgaben)</summary><ol>' +
      '<li>Lege einen Plan für eine echte Gruppe an. Die Zeit bis zum fertigen Plan wird dir angezeigt. Ziel: unter zwei Minuten.</li>' +
      '<li>Trage bei einer Person eine Abwesenheit ein und schau, wie sich der Plan ändert.</li>' +
      '<li>Tippe einen Termin an und tausche ihn mit einem anderen.</li>' +
      '<li>Teile den Plan als Bild oder Text mit der Gruppe.</li>' +
      '<li>Notiere unten, was unklar war, was fehlt und ob du es wirklich nutzen würdest.</li></ol>' +
      '<textarea id="notes" class="tx" data-bind="notes" placeholder="Notizen zum Test">' + esc(S.notes) + '</textarea>' +
      '<div class="row" style="padding-bottom:12px"><button class="btn sm" data-act="copyNotes">Notizen kopieren</button></div></details>';
    h += '<div class="row" style="justify-content:center">' +
      (S.confirm === 'reset' ? '<button class="btn danger sm" data-act="resetAll">Wirklich alles zurücksetzen</button><button class="btn sm" data-act="cancelConfirm">Abbrechen</button>'
        : '<button class="btn text" data-act="askReset">Prototyp zurücksetzen</button>') + '</div>';
    h += '</div></div>';
    return h;
  }

  // ---- detail view ---------------------------------------------------------
  function viewDetail(plan) {
    const t = today();
    const nxt = nextSlot(plan, t);
    const counts = R.assignmentCounts(plan);
    const open = plan.slots.filter((s) => !s.isSkipped && s.assigned.length === 0).length;
    let h = '<div class="wrap with-dock">';
    h += '<header class="top"><button class="btn text" data-act="back">‹ Pläne</button><h2>' + esc(plan.name) + '</h2><button class="icon-btn" data-act="openMenu" aria-label="Mehr">•••</button></header>';
    h += '<div class="stack" style="gap:10px">';
    h += '<div class="fair" aria-label="Anzahl Einsätze pro Person">' + plan.members.map((m) =>
      '<span class="chip' + (m.isActive ? '' : ' off') + '">' + avatar(m) + esc(m.name) + ' ' + (counts[m.id] || 0) + '×' + (m.isActive ? '' : ' (inaktiv)') + '</span>').join('') + '</div>';
    if (open) h += '<p class="warn">' + open + ' offene' + (open === 1 ? 'r Termin' : ' Termine') + ': niemand verfügbar. Tippe auf den Termin, um jemanden zu wählen.</p>';
    h += '<p class="meta">' + esc(rhythmLabel(plan.rhythm)) + ' · ' + plan.slotSize + ' pro Termin · ' + esc(R.formatNumeric(plan.start)) + ' bis ' + esc(R.formatNumeric(plan.end)) + '</p>';
    const slots = R.sortedSlots(plan);
    let month = '';
    let group = '';
    const flush = () => { if (group) h += '<div class="month">' + esc(month) + '</div><div class="slots">' + group + '</div>'; group = ''; };
    for (const s of slots) {
      const mt = monthTitle(s.date);
      if (mt !== month) { flush(); month = mt; }
      const isNext = nxt && nxt.id === s.id;
      let right;
      if (s.isSkipped) right = '<span class="skip">Übersprungen</span>';
      else if (!s.assigned.length) right = '<span class="open">Offen</span>';
      else right = s.assigned.map((id) => { const m = R.memberById(plan, id); return m ? avatar(m) + '<span>' + esc(m.name) + '</span>' : '?'; }).join('');
      group += '<button class="slot' + (s.date < t ? ' past' : '') + (isNext ? ' next' : '') + '" data-act="editSlot" data-id="' + esc(s.id) + '">' +
        '<span class="d">' + esc(short(s.date)) + (isNext ? '<span class="tag">Nächster Termin</span>' : '') + '</span>' +
        '<span class="who">' + right + (s.isManual ? '<span class="pill">von Hand</span>' : '') + '</span></button>';
    }
    flush();
    h += '</div></div>';
    h += '<nav class="dock" aria-label="Aktionen"><div class="in"><button class="btn primary" data-act="openShare">Teilen</button><button class="btn" data-act="openMembers">Personen</button><button class="btn" data-act="openRhythm">Rhythmus</button></div></nav>';
    return h;
  }

  // ---- forms ---------------------------------------------------------------
  function rhythmFields(base, d, slotSize, sizePath) {
    let h = '<label class="f">Rhythmus<select id="' + base + '-kind" data-bind="' + base + '.kind" data-render="1">' +
      KINDS.map(([k, l]) => '<option value="' + k + '"' + (d.kind === k ? ' selected' : '') + '>' + l + '</option>').join('') + '</select></label>';
    if (['weekly', 'biweekly', 'monthlyNth'].includes(d.kind)) {
      h += '<label class="f">Wochentag<select id="' + base + '-wd" data-bind="' + base + '.weekday" data-type="int">' +
        WD_PICK.map((w) => '<option value="' + w + '"' + (d.weekday === w ? ' selected' : '') + '>' + WD[w - 1] + '</option>').join('') + '</select></label>';
    }
    if (d.kind === 'monthlyNth') {
      h += '<label class="f">Welcher<select id="' + base + '-ord" data-bind="' + base + '.ordinal" data-type="int">' +
        [[1, 'Erster'], [2, 'Zweiter'], [3, 'Dritter'], [4, 'Vierter'], [-1, 'Letzter']].map(([v, l]) => '<option value="' + v + '"' + (d.ordinal === v ? ' selected' : '') + '>' + l + '</option>').join('') + '</select></label>';
    }
    if (d.kind === 'monthlyDay') {
      h += '<label class="f">Tag des Monats<select id="' + base + '-day" data-bind="' + base + '.day" data-type="int">' +
        Array.from({ length: 31 }, (_, i) => i + 1).map((v) => '<option value="' + v + '"' + (d.day === v ? ' selected' : '') + '>' + v + '.</option>').join('') + '</select></label>' +
        '<p class="help">In kürzeren Monaten wird der letzte Tag verwendet.</p>';
    }
    h += '<div class="row"><span class="grow">Personen pro Termin</span><div class="seg" role="group" aria-label="Personen pro Termin">' +
      [1, 2].map((n) => '<button type="button" data-act="setSlotSize" data-path="' + sizePath + '" data-v="' + n + '" aria-pressed="' + (slotSize === n) + '">' + n + '</button>').join('') + '</div></div>';
    return h;
  }
  const weightSeg = (act, extra, w) => '<div class="seg" role="group" aria-label="Anteil">' +
    [[0.5, '½'], [1, '1'], [2, '2']].map(([v, l]) => '<button type="button" data-act="' + act + '" ' + extra + ' data-w="' + v + '" aria-pressed="' + (w === v) + '">' + l + '</button>').join('') + '</div>';

  // ---- wizard --------------------------------------------------------------
  function newWizard() {
    let start = today();
    while (R.weekday(start) !== 6) start = R.addDays(start, 1);
    return { step: 0, t0: Date.now(), name: '', colorIndex: 0, members: [], rhythm: { kind: 'weekly', weekday: 6, ordinal: 1, day: 1 }, slotSize: 1, start, weeks: 12, error: '' };
  }
  function wizPreview(w) {
    if (!w.start) return { count: 0, end: '' };
    const end = R.addDays(w.start, Math.max(1, w.weeks) * 7 - 1);
    return { count: R.generateDates(rhythmFromDraft(w.rhythm), w.start, end).length, end };
  }
  function viewWizard() {
    const w = S.wiz;
    const titles = ['Name', 'Personen', 'Rhythmus', 'Zeitraum'];
    let h = '<div class="wrap with-dock"><header class="top"><button class="btn text" data-act="wizCancel">Abbrechen</button><h2>' + titles[w.step] + '</h2><span style="min-width:44px"></span></header><div class="stack">';
    h += '<div class="steps" aria-label="Schritt ' + (w.step + 1) + ' von 4">' + [0, 1, 2, 3].map((i) => '<i class="' + (i <= w.step ? 'on' : '') + '"></i>').join('') + '</div>';
    if (w.step === 0) {
      h += '<label class="f">Wofür ist der Plan?<input type="text" id="wiz-name" data-bind="wiz.name" data-enter="wizNext" maxlength="80" placeholder="z. B. Znüni-Dienst" value="' + esc(w.name) + '" autocomplete="off"></label>';
      h += '<div><div class="section-title" style="margin-bottom:8px">Farbe</div><div class="swatches" role="group" aria-label="Farbe">' +
        Array.from({ length: 10 }, (_, i) => '<button type="button" class="sw" style="background:' + colorVar(i) + '" data-act="wizColor" data-v="' + i + '" aria-label="Farbe ' + (i + 1) + '" aria-pressed="' + (w.colorIndex === i) + '"></button>').join('') + '</div></div>';
    } else if (w.step === 1) {
      h += '<div class="list">' + (w.members.length ? w.members.map((m, i) =>
        '<div class="li"><span class="grow">' + esc(m.name) + '</span>' + weightSeg('wizWeight', 'data-i="' + i + '"', m.weight) + '<button class="rm" data-act="wizRemove" data-i="' + i + '" aria-label="' + esc(m.name) + ' entfernen">×</button></div>').join('') : '<div class="li help">Noch niemand. Tippe einen Vornamen und drücke Enter.</div>') + '</div>';
      h += '<div class="row"><input type="text" id="wiz-person" data-enter="wizAddPerson" maxlength="40" placeholder="Vorname hinzufügen" autocomplete="off" class="grow"><button class="btn" data-act="wizAddPerson">Hinzufügen</button></div>';
      h += '<p class="help">' + (w.members.length < 2 ? 'Mindestens zwei Personen.' : 'Anteil ½ = halb so oft dran, zum Beispiel bei Teilzeit. Nur Vornamen genügen.') + '</p>';
    } else if (w.step === 2) {
      h += rhythmFields('wiz.rhythm', w.rhythm, w.slotSize, 'wiz.slotSize');
    } else {
      const pv = wizPreview(w);
      h += '<label class="f">Start<input type="date" id="wiz-start" data-bind="wiz.start" data-render="1" value="' + esc(w.start) + '"></label>';
      h += '<div class="row"><span class="grow">Dauer: ' + w.weeks + ' Wochen</span><div class="seg"><button type="button" data-act="wizWeeks" data-v="-1" aria-label="Eine Woche weniger">−</button><button type="button" data-act="wizWeeks" data-v="1" aria-label="Eine Woche mehr">+</button></div></div>';
      h += '<p class="help">' + (pv.count ? 'Ergibt ' + pv.count + ' Termine bis ' + R.formatNumeric(pv.end) + '.' : 'Bitte ein Startdatum wählen.') + '</p>';
    }
    if (w.error) h += '<p class="err" role="alert">' + esc(w.error) + '</p>';
    h += '</div></div><nav class="dock"><div class="in">' + (w.step > 0 ? '<button class="btn" data-act="wizBack">Zurück</button>' : '') +
      '<button class="btn primary" data-act="wizNext">' + (w.step < 3 ? 'Weiter' : 'Plan erstellen') + '</button></div></nav>';
    return h;
  }
  function wizNext() {
    const w = S.wiz;
    w.error = '';
    if (w.step === 0 && !w.name.trim()) { w.error = 'Bitte gib dem Plan einen Namen.'; return render(); }
    if (w.step === 1) {
      const typed = document.getElementById('wiz-person');
      if (typed && typed.value.trim()) return wizAddPerson();
      if (w.members.length < 2) { w.error = 'Mindestens zwei Personen.'; return render(); }
    }
    if (w.step === 3) return wizCreate();
    w.step += 1;
    S.focusId = w.step === 1 ? 'wiz-person' : null;
    render();
  }
  function wizAddPerson() {
    const w = S.wiz;
    const input = document.getElementById('wiz-person');
    const name = (input ? input.value : '').trim().slice(0, 40);
    if (!name) { w.error = 'Bitte einen Vornamen eingeben.'; S.focusId = 'wiz-person'; return render(); }
    w.error = '';
    w.members.push({ name, weight: 1 });
    S.focusId = 'wiz-person';
    render();
  }
  function wizCreate() {
    const w = S.wiz;
    if (!w.start) { w.error = 'Bitte ein Startdatum wählen.'; return render(); }
    const plan = {
      id: R.uid(), name: w.name.trim().slice(0, 80), colorIndex: w.colorIndex, rhythm: rhythmFromDraft(w.rhythm), start: w.start,
      end: R.addDays(w.start, w.weeks * 7 - 1), slotSize: w.slotSize, showAttribution: true,
      members: w.members.map((m, i) => ({ id: R.uid(), name: m.name, weight: m.weight, colorIndex: i, isActive: true, absences: [] })), slots: []
    };
    const done = R.regenerate(plan, today());
    const elapsed = fmtDuration(Date.now() - w.t0);
    S.plans.push(done); S.planId = done.id; S.view = 'detail'; S.wiz = null;
    saveStore();
    toast('Plan erstellt in ' + elapsed + ' Min.');
  }

  // ---- sheets --------------------------------------------------------------
  function sheetFrame(title, body, foot, closeAct) {
    return '<div class="overlay" data-act="' + (closeAct || 'closeSheet') + '" data-overlay="1"><div class="sheet" role="dialog" aria-modal="true" tabindex="-1" aria-label="' + esc(title) + '">' +
      '<div class="sheet-head"><span style="min-width:44px"></span><h3>' + esc(title) + '</h3><button class="icon-btn" data-act="' + (closeAct || 'closeSheet') + '" aria-label="Schliessen">×</button></div>' +
      '<div class="sheet-body">' + body + '</div>' + (foot ? '<div class="sheet-foot">' + foot + '</div>' : '') + '</div></div>';
  }
  function viewSheet() {
    const sh = S.sheet;
    const plan = currentPlan();
    if (!plan) return '';
    switch (sh.type) {
      case 'menu': return viewMenu(plan);
      case 'slot': return viewSlotSheet(plan, sh);
      case 'members': return sh.editing ? viewMemberEditor(plan, sh) : viewMembers(plan, sh);
      case 'rhythm': return viewRhythmSheet(plan, sh);
      case 'share': return viewShare(plan, sh);
      default: return '';
    }
  }
  function viewMenu(plan) {
    let b = '<button class="btn" data-act="regen" data-over="0">Neu berechnen, manuelle Termine behalten</button>' +
      '<button class="btn" data-act="regen" data-over="1">Neu berechnen, auch manuelle Termine</button>' +
      '<p class="help">Vergangene Termine bleiben in jedem Fall unverändert.</p>' +
      '<label class="f">Plan umbenennen<input type="text" id="menu-name" data-bind="sheet.name" maxlength="80" value="' + esc(S.sheet.name) + '"></label>' +
      '<button class="btn" data-act="rename">Umbenennen</button>';
    b += S.confirm === 'del' ? '<button class="btn danger" data-act="deletePlan">Wirklich löschen: ' + esc(plan.name) + '</button><button class="btn" data-act="cancelConfirm">Abbrechen</button>'
      : '<button class="btn danger" data-act="askDelete">Plan löschen</button>';
    return sheetFrame('Plan', b, '');
  }
  function viewSlotSheet(plan, sh) {
    const d = sh.draft;
    const dayMembers = plan.members;
    let b = '<p><strong>' + esc(long(d.date)) + '</strong></p>';
    for (let i = 0; i < plan.slotSize; i++) {
      b += '<label class="f">' + (plan.slotSize === 1 ? 'Person' : 'Person ' + (i + 1)) + '<select id="slot-sel-' + i + '" data-bind="sheet.sel.' + i + '"' + (d.isSkipped ? ' disabled' : '') + '><option value="">Niemand</option>' +
        dayMembers.map((m) => '<option value="' + esc(m.id) + '"' + (sh.sel[i] === m.id ? ' selected' : '') + '>' + esc(m.name) + (R.isAbsent(m, d.date) ? ' (abwesend)' : '') + '</option>').join('') + '</select></label>';
    }
    b += '<label class="toggle"><span>Termin überspringen</span><input type="checkbox" id="slot-skip" data-bind="sheet.draft.isSkipped" data-type="bool" data-render="1"' + (d.isSkipped ? ' checked' : '') + '></label>';
    b += '<label class="f">Notiz<input type="text" id="slot-note" data-bind="sheet.draft.note" maxlength="200" placeholder="Optional" value="' + esc(d.note || '') + '"></label>';
    const others = R.sortedSlots(plan).filter((s) => s.id !== d.id && !s.isSkipped);
    b += '<div class="row"><label class="f grow">Mit anderem Termin tauschen<select id="slot-swap" data-bind="sheet.swapWith"' + (d.isSkipped ? ' disabled' : '') + '><option value="">Termin wählen …</option>' +
      others.map((s) => '<option value="' + esc(s.id) + '"' + (sh.swapWith === s.id ? ' selected' : '') + '>' + esc(short(s.date)) + ' – ' + esc(whoText(plan, s)) + '</option>').join('') + '</select></label>' +
      '<button class="btn" data-act="doSwap" style="align-self:flex-end"' + (sh.swapWith ? '' : ' disabled') + '>Tauschen</button></div>';
    if (d.isManual) b += '<p class="help">Von Hand gesetzt. «Neu berechnen» überschreibt diesen Termin nur, wenn du das ausdrücklich wählst.</p>';
    return sheetFrame('Termin', b, '<button class="btn" data-act="closeSheet">Abbrechen</button><button class="btn primary" data-act="saveSlot">Speichern</button>');
  }
  function viewMembers(plan, sh) {
    const d = sh.draft;
    let b = '<div class="list">' + d.members.map((m) =>
      '<button class="li" style="width:100%;background:none;border-left:0;border-right:0;border-bottom:0;text-align:left;cursor:pointer" data-act="editMember" data-id="' + esc(m.id) + '">' + avatar(m) +
      '<span class="grow"><span style="display:block;' + (m.isActive ? '' : 'color:var(--muted)') + '">' + esc(m.name) + '</span><span class="sub">Anteil ' + (m.weight === 0.5 ? '½' : m.weight) + (m.isActive ? '' : ' · inaktiv') +
      (m.absences.length ? ' · ' + m.absences.length + ' Abwesenheit' + (m.absences.length === 1 ? '' : 'en') : '') + '</span></span><span aria-hidden="true">›</span></button>').join('') + '</div>';
    b += '<div class="row"><input type="text" id="mem-new" data-enter="addMember" maxlength="40" placeholder="Vorname hinzufügen" autocomplete="off" class="grow"><button class="btn" data-act="addMember">Hinzufügen</button></div>';
    b += '<p class="help">Personen mit vergangenen Terminen werden beim Entfernen deaktiviert, damit die Historie lesbar bleibt. Beim Speichern werden zukünftige Termine neu berechnet.</p>';
    if (sh.error) b += '<p class="err" role="alert">' + esc(sh.error) + '</p>';
    return sheetFrame('Personen', b, '<button class="btn" data-act="closeSheet">Abbrechen</button><button class="btn primary" data-act="saveMembers">Speichern</button>');
  }
  function viewMemberEditor(plan, sh) {
    const idx = sh.draft.members.findIndex((m) => m.id === sh.editing);
    const m = sh.draft.members[idx];
    if (!m) { sh.editing = null; return viewMembers(plan, sh); }
    const base = 'sheet.draft.members.' + idx;
    let b = '<label class="f">Vorname<input type="text" id="mem-name" data-bind="' + base + '.name" maxlength="40" value="' + esc(m.name) + '"></label>';
    b += '<div class="row"><span class="grow">Anteil</span>' + weightSeg('memWeight', '', m.weight) + '</div><p class="help">½ = halb so oft dran, 2 = doppelt so oft. Zum Beispiel bei Teilzeit.</p>';
    b += '<label class="toggle"><span>Aktiv</span><input type="checkbox" id="mem-active" data-bind="' + base + '.isActive" data-type="bool"' + (m.isActive ? ' checked' : '') + '></label>';
    b += '<div class="section-title">Abwesenheiten</div><div class="list">' + (m.absences.length ? m.absences.map((a, i) =>
      '<div class="li"><span class="grow">' + esc(R.formatNumeric(a.start)) + ' bis ' + esc(R.formatNumeric(a.end)) + (a.note ? '<span class="sub" style="display:block">' + esc(a.note) + '</span>' : '') + '</span><button class="rm" data-act="delAbsence" data-i="' + i + '" aria-label="Abwesenheit entfernen">×</button></div>').join('') : '<div class="li help">Keine Abwesenheiten.</div>') + '</div>';
    b += '<div class="row"><label class="f grow">Von<input type="date" id="abs-from" data-bind="sheet.absFrom" value="' + esc(sh.absFrom || '') + '"></label><label class="f grow">Bis<input type="date" id="abs-to" data-bind="sheet.absTo" value="' + esc(sh.absTo || '') + '"></label></div>';
    b += '<label class="f">Hinweis (optional), z. B. Ferien<input type="text" id="abs-note" data-bind="sheet.absNote" maxlength="200" value="' + esc(sh.absNote || '') + '"></label>';
    b += '<button class="btn" data-act="addAbsence">Abwesenheit hinzufügen</button>';
    if (sh.error) b += '<p class="err" role="alert">' + esc(sh.error) + '</p>';
    b += sh.confirmRemove ? '<button class="btn danger" data-act="removeMember">Wirklich entfernen: ' + esc(m.name) + '</button>' : '<button class="btn danger" data-act="askRemoveMember">Person entfernen</button>';
    return sheetFrame(m.name, b, '<button class="btn primary" data-act="doneMember">Fertig</button>', 'doneMember');
  }
  function viewRhythmSheet(plan, sh) {
    let b = '<label class="f">Start<input type="date" id="rh-start" data-bind="sheet.start" value="' + esc(sh.start) + '"></label>';
    b += '<label class="f">Ende<input type="date" id="rh-end" data-bind="sheet.end" value="' + esc(sh.end) + '"></label>';
    b += rhythmFields('sheet.rhythm', sh.rhythm, sh.slotSize, 'sheet.slotSize');
    const ok = sh.start && sh.end && sh.start <= sh.end && R.daysBetween(sh.start, sh.end) <= R.MAX_SPAN_DAYS;
    b += '<p class="help">' + (ok ? 'Ergibt ' + R.generateDates(rhythmFromDraft(sh.rhythm), sh.start, sh.end).length + ' Termine. Vergangene und von Hand gesetzte Termine bleiben erhalten.' : 'Der Zeitraum darf höchstens zehn Jahre umfassen, das Ende nicht vor dem Start liegen.') + '</p>';
    return sheetFrame('Rhythmus & Zeitraum', b, '<button class="btn" data-act="closeSheet">Abbrechen</button><button class="btn primary" data-act="saveRhythm"' + (ok ? '' : ' disabled') + '>Speichern</button>');
  }

  // ---- sharing -------------------------------------------------------------
  const CARD = { light: { bg: '#ffffff', fg: '#0f1f1e', muted: '#566a67', line: '#d5dfdd' }, dark: { bg: '#132321', fg: '#e4f0ee', muted: '#93aaa7', line: '#243b38' } };
  const CARD_COLORS = ['#0f766e', '#c2410c', '#4338ca', '#be185d', '#15803d', '#7e22ce', '#92400e', '#0e7490', '#047857', '#b91c1c'];
  function renderCard(plan, dark) {
    const c = dark ? CARD.dark : CARD.light;
    const rows = R.sortedSlots(plan).filter((s) => !s.isSkipped && s.date >= today());
    const shown = rows.slice(0, 30);
    const W = 540, pad = 28, rowH = 36;
    const H = pad + 44 + 26 + 18 + Math.max(1, shown.length) * rowH + (rows.length > shown.length ? 30 : 0) + (plan.showAttribution ? 46 : 12) + pad - 12;
    const canvas = document.createElement('canvas');
    const scale = 2;
    canvas.width = W * scale; canvas.height = H * scale;
    const g = canvas.getContext('2d');
    g.scale(scale, scale);
    const fam = '-apple-system, BlinkMacSystemFont, "SF Pro Text", system-ui, "Segoe UI", Roboto, sans-serif';
    g.fillStyle = c.bg; g.fillRect(0, 0, W, H);
    let y = pad + 26;
    g.fillStyle = CARD_COLORS[Math.abs(plan.colorIndex) % 10]; g.fillRect(pad, y - 22, 8, 28);
    g.fillStyle = c.fg; g.font = '700 26px ' + fam; g.textBaseline = 'alphabetic';
    let title = plan.name;
    while (g.measureText(title).width > W - pad * 2 - 20 && title.length > 4) title = title.slice(0, -2);
    if (title !== plan.name) title += '…';
    g.fillText(title, pad + 20, y);
    y += 26;
    g.fillStyle = c.muted; g.font = '400 15px ' + fam;
    if (shown.length) g.fillText(short(shown[0].date) + ' bis ' + short(shown[shown.length - 1].date), pad, y);
    y += 14;
    g.strokeStyle = c.line; g.lineWidth = 1; g.beginPath(); g.moveTo(pad, y + 0.5); g.lineTo(W - pad, y + 0.5); g.stroke();
    y += 10;
    if (!shown.length) { g.fillStyle = c.muted; g.fillText('Keine anstehenden Termine', pad, y + 24); y += rowH; }
    for (const s of shown) {
      g.fillStyle = c.muted; g.font = '400 16px ' + fam; g.fillText(short(s.date), pad, y + 24);
      g.fillStyle = c.fg; g.font = '600 17px ' + fam;
      let who = whoText(plan, s);
      while (g.measureText(who).width > W - pad * 2 - 130 && who.length > 4) who = who.slice(0, -2);
      if (who !== whoText(plan, s)) who += '…';
      g.fillText(who, pad + 130, y + 24);
      y += rowH;
    }
    if (rows.length > shown.length) { g.fillStyle = c.muted; g.font = '400 14px ' + fam; g.fillText('… und ' + (rows.length - shown.length) + ' weitere Termine', pad, y + 20); y += 30; }
    if (plan.showAttribution) {
      g.strokeStyle = c.line; g.beginPath(); g.moveTo(pad, y + 8.5); g.lineTo(W - pad, y + 8.5); g.stroke();
      g.fillStyle = c.muted; g.font = '400 14px ' + fam; g.fillText('Erstellt mit Reihum', pad, y + 32);
    }
    try { return canvas.toDataURL('image/png'); } catch (e) { return ''; }
  }
  function viewShare(plan, sh) {
    let b = '<div class="tabs"><div class="seg" role="tablist">' + [['image', 'Bild'], ['text', 'Text'], ['cal', 'Kalender']].map(([k, l]) =>
      '<button type="button" role="tab" data-act="shareTab" data-v="' + k + '" aria-pressed="' + (sh.tab === k) + '">' + l + '</button>').join('') + '</div></div>';
    if (sh.tab === 'image') {
      const url = renderCard(plan, sh.dark);
      b += url ? '<img class="share-img" alt="Vorschau des Plans als Bild" src="' + url + '">' : '<p class="err">Das Bild konnte hier nicht erstellt werden.</p>';
      b += '<p class="help">Zum Sichern das Bild gedrückt halten und «Zu Fotos hinzufügen» wählen. In der App öffnet sich stattdessen direkt das iPhone-Menü «Teilen».</p>';
      b += '<label class="toggle"><span>Dunkle Karte</span><input type="checkbox" id="share-dark" data-bind="sheet.dark" data-type="bool" data-render="1"' + (sh.dark ? ' checked' : '') + '></label>';
    } else if (sh.tab === 'text') {
      b += '<label class="f">Für<select id="share-member" data-bind="sheet.member" data-render="1"><option value="">Alle</option>' + plan.members.map((m) => '<option value="' + esc(m.id) + '"' + (sh.member === m.id ? ' selected' : '') + '>' + esc(m.name) + '</option>').join('') + '</select></label>';
      b += '<pre class="txt" id="share-text">' + esc(R.textExport(plan, { memberId: sh.member || null, from: today() })) + '</pre>';
      b += '<button class="btn primary" data-act="copyText">Text kopieren</button>';
    } else {
      b += '<p><strong>Kalenderdatei (.ics)</strong></p><p class="help">In der App erzeugst du eine Kalenderdatei mit allen kommenden Terminen, wahlweise nur für eine Person. Wer sie öffnet, fügt die Termine dem eigenen Kalender hinzu, inklusive Erinnerung am Vortag um 18 Uhr. Die Empfänger brauchen dafür keine App.</p><p class="help">Dieser Prototyp kann keine Dateien speichern, deshalb lässt sich das hier nicht ausprobieren.</p>';
    }
    b += '<label class="toggle"><span>Hinweis «Erstellt mit Reihum» anzeigen</span><input type="checkbox" id="share-attr" data-act="toggleAttr"' + (plan.showAttribution ? ' checked' : '') + '></label>';
    b += '<p class="help">Der Plan enthält Namen. Teile ihn nur mit den Personen, die dazugehören.</p>';
    return sheetFrame('Teilen', b, '<button class="btn primary" data-act="closeSheet">Fertig</button>');
  }

  // ---- actions -------------------------------------------------------------
  function updatePlan(plan) {
    const i = S.plans.findIndex((p) => p.id === plan.id);
    if (i >= 0) S.plans[i] = plan;
    saveStore();
  }
  function selectText(el) {
    const range = document.createRange(); range.selectNodeContents(el);
    const sel = window.getSelection(); sel.removeAllRanges(); sel.addRange(range);
  }
  async function copy(text, sourceId, okMsg) {
    try { await navigator.clipboard.writeText(text); toast(okMsg); }
    catch (e) { const el = sourceId && document.getElementById(sourceId); if (el) selectText(el); toast('Automatisch kopieren geht hier nicht. Der Text ist markiert: «Kopieren» wählen.'); }
  }
  function memberIndexIn(draft, id) { return draft.members.findIndex((m) => m.id === id); }

  const actions = {
    newPlan() { S.toast = ''; S.wiz = newWizard(); S.sheet = null; render(); S.focusId = 'wiz-name'; render(); },
    addSample() { const p = samplePlan(); S.plans.push(p); saveStore(); render(); },
    openPlan(el) { S.planId = el.dataset.id; S.view = 'detail'; S.sheet = null; render(); window.scrollTo(0, 0); },
    back() { S.view = 'list'; S.planId = null; S.sheet = null; render(); },
    askReset() { S.confirm = 'reset'; render(); },
    cancelConfirm() { S.confirm = ''; render(); },
    resetAll() { S.plans = [samplePlan()]; S.notes = ''; S.confirm = ''; S.view = 'list'; saveStore(); toast('Prototyp zurückgesetzt.'); },
    copyNotes() { copy(S.notes || '(keine Notizen)', 'notes', 'Notizen kopiert.'); },
    closeSheet(el, e) { if (el.dataset.overlay && e.target !== el) return; S.sheet = null; S.confirm = ''; render(); },

    // wizard
    wizCancel() { S.wiz = null; render(); },
    wizBack() { S.wiz.step = Math.max(0, S.wiz.step - 1); S.wiz.error = ''; render(); },
    wizNext, wizAddPerson,
    wizColor(el) { S.wiz.colorIndex = Number(el.dataset.v); render(); },
    wizWeight(el) { S.wiz.members[Number(el.dataset.i)].weight = Number(el.dataset.w); render(); },
    wizRemove(el) { S.wiz.members.splice(Number(el.dataset.i), 1); render(); },
    wizWeeks(el) { S.wiz.weeks = Math.min(104, Math.max(1, S.wiz.weeks + Number(el.dataset.v))); render(); },
    setSlotSize(el) { setPath(el.dataset.path, Number(el.dataset.v)); render(); },

    // detail menu
    openMenu() { S.toast = ''; S.sheet = { type: 'menu', name: currentPlan().name }; S.confirm = ''; render(); },
    regen(el) { const p = R.regenerate(currentPlan(), today(), el.dataset.over === '1'); updatePlan(p); S.sheet = null; toast('Zukünftige Termine neu berechnet.'); },
    rename() { const n = (S.sheet.name || '').trim().slice(0, 80); if (!n) return; const p = R.clone(currentPlan()); p.name = n; updatePlan(p); S.sheet = null; render(); },
    askDelete() { S.confirm = 'del'; render(); },
    deletePlan() { S.plans = S.plans.filter((p) => p.id !== S.planId); saveStore(); S.sheet = null; S.confirm = ''; S.view = 'list'; S.planId = null; toast('Plan gelöscht.'); },

    // slots
    editSlot(el) {
      const plan = currentPlan(); const slot = plan.slots.find((s) => s.id === el.dataset.id); if (!slot) return;
      const sel = slot.assigned.slice(0, plan.slotSize); while (sel.length < plan.slotSize) sel.push('');
      S.toast = ''; S.sheet = { type: 'slot', id: slot.id, draft: R.clone(slot), sel, swapWith: '' }; render();
    },
    saveSlot() {
      const plan = currentPlan(); const sh = S.sheet; const d = R.clone(sh.draft);
      const ids = []; for (const id of sh.sel) if (id && !ids.includes(id)) ids.push(id);
      d.assigned = d.isSkipped ? [] : ids; d.note = (d.note || '').trim() || null;
      updatePlan(R.applyManualEdit(plan, d)); S.sheet = null; render();
    },
    doSwap() {
      const sh = S.sheet; if (!sh.swapWith) return;
      updatePlan(R.swap(currentPlan(), sh.id, sh.swapWith)); S.sheet = null; toast('Termine getauscht.');
    },

    // members
    openMembers() { S.toast = ''; S.sheet = { type: 'members', draft: R.clone(currentPlan()), editing: null, error: '' }; render(); },
    editMember(el) { Object.assign(S.sheet, { editing: el.dataset.id, absFrom: '', absTo: '', absNote: '', error: '', confirmRemove: false }); render(); },
    doneMember() { S.sheet.editing = null; S.sheet.error = ''; render(); },
    addMember() {
      const input = document.getElementById('mem-new'); const name = (input ? input.value : '').trim().slice(0, 40);
      if (!name) return;
      const d = S.sheet.draft; d.members.push({ id: R.uid(), name, weight: 1, colorIndex: d.members.length, isActive: true, absences: [] });
      S.focusId = 'mem-new'; render();
    },
    memWeight(el) { const d = S.sheet.draft; d.members[memberIndexIn(d, S.sheet.editing)].weight = Number(el.dataset.w); render(); },
    addAbsence() {
      const sh = S.sheet; const d = sh.draft; const m = d.members[memberIndexIn(d, sh.editing)];
      if (!sh.absFrom || !sh.absTo) { sh.error = 'Bitte Von und Bis wählen.'; return render(); }
      if (sh.absFrom > sh.absTo) { sh.error = 'Das Ende liegt vor dem Start.'; return render(); }
      m.absences.push({ start: sh.absFrom, end: sh.absTo, note: (sh.absNote || '').trim() || null });
      Object.assign(sh, { absFrom: '', absTo: '', absNote: '', error: '' }); render();
    },
    delAbsence(el) { const d = S.sheet.draft; d.members[memberIndexIn(d, S.sheet.editing)].absences.splice(Number(el.dataset.i), 1); render(); },
    askRemoveMember() { S.sheet.confirmRemove = true; render(); },
    removeMember() {
      const sh = S.sheet; const d = sh.draft; const idx = memberIndexIn(d, sh.editing); const id = sh.editing; const t = today();
      const hasHistory = d.slots.some((s) => s.date < t && s.assigned.includes(id));
      if (hasHistory) d.members[idx].isActive = false;
      else { d.members.splice(idx, 1); for (const s of d.slots) if (s.date >= t) s.assigned = s.assigned.filter((x) => x !== id); }
      sh.editing = null; sh.confirmRemove = false; render();
    },
    saveMembers() {
      const sh = S.sheet; const d = R.clone(sh.draft);
      d.members.forEach((m) => { m.name = (m.name || '').trim().slice(0, 40) || 'Ohne Namen'; });
      if (!d.members.some((m) => m.isActive)) { sh.error = 'Mindestens eine Person muss aktiv sein.'; return render(); }
      updatePlan(R.regenerate(d, today())); S.sheet = null; toast('Personen gespeichert, Termine neu berechnet.');
    },

    // rhythm
    openRhythm() { S.toast = ''; const p = currentPlan(); S.sheet = { type: 'rhythm', rhythm: rhythmDraft(p.rhythm), slotSize: p.slotSize, start: p.start, end: p.end }; render(); },
    saveRhythm() {
      const sh = S.sheet; const p = R.clone(currentPlan());
      p.rhythm = rhythmFromDraft(sh.rhythm); p.slotSize = sh.slotSize; p.start = sh.start; p.end = sh.end;
      updatePlan(R.regenerate(p, today())); S.sheet = null; toast('Rhythmus gespeichert, Termine neu berechnet.');
    },

    // share
    openShare() { S.toast = ''; S.sheet = { type: 'share', tab: 'image', dark: false, member: '' }; render(); },
    shareTab(el) { S.sheet.tab = el.dataset.v; render(); },
    copyText() { copy(R.textExport(currentPlan(), { memberId: S.sheet.member || null, from: today() }), 'share-text', 'Text kopiert.'); },
    toggleAttr(el) { const p = R.clone(currentPlan()); p.showAttribution = el.checked; updatePlan(p); render(); }
  };

  // ---- events --------------------------------------------------------------
  $app.addEventListener('click', (e) => {
    const el = e.target.closest('[data-act]');
    if (!el || !$app.contains(el)) return;
    const act = actions[el.dataset.act];
    if (!act) return;
    if (el.tagName === 'INPUT') return; // checkboxes act on change
    act(el, e);
  });
  function readValue(el) {
    if (el.dataset.type === 'bool') return el.checked;
    if (el.dataset.type === 'int') return parseInt(el.value, 10);
    return el.value;
  }
  $app.addEventListener('input', (e) => {
    const el = e.target;
    if (el.dataset && el.dataset.bind && el.tagName !== 'SELECT' && el.type !== 'checkbox') {
      setPath(el.dataset.bind, readValue(el));
      if (el.dataset.bind === 'notes') saveStore();
    }
  });
  $app.addEventListener('change', (e) => {
    const el = e.target;
    if (el.dataset && el.dataset.act === 'toggleAttr') { actions.toggleAttr(el); return; }
    if (el.dataset && el.dataset.bind) {
      setPath(el.dataset.bind, readValue(el));
      if (el.dataset.bind === 'notes') saveStore();
      if (el.dataset.render) {
        // changing the rhythm kind resets the fields that only some kinds use
        render();
      } else if (el.dataset.bind === 'sheet.swapWith') render();
    }
  });
  $app.addEventListener('keydown', (e) => {
    if (e.key === 'Enter' && e.target.dataset && e.target.dataset.enter) { e.preventDefault(); actions[e.target.dataset.enter](e.target, e); }
  });
  document.addEventListener('keydown', (e) => { if (e.key === 'Escape' && S.sheet) { S.sheet = null; render(); } });

  // ---- start ---------------------------------------------------------------
  S.noStorage = !storageWorks();
  const stored = loadStore();
  if (stored) { S.plans = stored.plans; S.notes = stored.notes || ''; }
  else { S.plans = [samplePlan()]; saveStore(); }
  render();
  window.__reihum = { S, R, render };
})();
