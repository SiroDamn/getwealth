/* Reihum engine: a line-by-line port of the Swift package ReihumCore (DayDate, RhythmGenerator, FairnessEngine).
   Dates are ISO strings "YYYY-MM-DD" (calendar days without a time), so ordering is plain string comparison.
   Weekdays follow Swift's Calendar: 1 = Sunday ... 7 = Saturday. */
const Reihum = (() => {
  'use strict';
  const MAX_SPAN_DAYS = 3660;
  const DISTANT_PAST = '0001-01-01';
  const pad = (n) => String(n).padStart(2, '0');

  // ---- calendar days -------------------------------------------------------
  const parse = (iso) => { const [y, m, d] = iso.split('-').map(Number); return { y, m, d }; };
  const format = ({ y, m, d }) => String(y).padStart(4, '0') + '-' + pad(m) + '-' + pad(d);
  const dayNumber = (iso) => { const { y, m, d } = parse(iso); return Math.round(Date.UTC(y, m - 1, d) / 86400000); };
  const fromDayNumber = (n) => {
    const dt = new Date(n * 86400000);
    return format({ y: dt.getUTCFullYear(), m: dt.getUTCMonth() + 1, d: dt.getUTCDate() });
  };
  const addDays = (iso, n) => fromDayNumber(dayNumber(iso) + n);
  const daysBetween = (a, b) => dayNumber(b) - dayNumber(a);
  const weekday = (iso) => new Date(dayNumber(iso) * 86400000).getUTCDay() + 1;
  const isWeekend = (wd) => wd === 1 || wd === 7;
  const daysInMonth = (iso) => { const { y, m } = parse(iso); return new Date(Date.UTC(y, m, 0)).getUTCDate(); };
  const ordinalInMonth = (iso) => Math.floor((parse(iso).d - 1) / 7) + 1;
  const isLastOccurrenceInMonth = (iso) => parse(iso).d + 7 > daysInMonth(iso);
  const todayLocal = (now = new Date()) => format({ y: now.getFullYear(), m: now.getMonth() + 1, d: now.getDate() });
  const firstOfMonth = (iso) => { const { y, m } = parse(iso); return format({ y, m, d: 1 }); };

  // ---- rhythms -------------------------------------------------------------
  // { kind: 'daily' } | { kind: 'weekdays' } | { kind: 'weekly', weekday } | { kind: 'biweekly', weekday }
  // | { kind: 'monthlyNth', ordinal (1..4 or -1 = last), weekday } | { kind: 'monthlyDay', day }
  function generateDates(rhythm, start, end) {
    if (start > end) return [];
    const span = Math.min(daysBetween(start, end), MAX_SPAN_DAYS);
    const out = [];
    let anchor = null;
    let cur = start;
    for (let i = 0; i <= span; i++) {
      const wd = weekday(cur);
      switch (rhythm.kind) {
        case 'daily': out.push(cur); break;
        case 'weekdays': if (!isWeekend(wd)) out.push(cur); break;
        case 'weekly': if (wd === rhythm.weekday) out.push(cur); break;
        case 'biweekly':
          if (wd === rhythm.weekday) {
            if (anchor !== null) { if (daysBetween(anchor, cur) % 14 === 0) out.push(cur); }
            else { anchor = cur; out.push(cur); }
          }
          break;
        case 'monthlyNth':
          if (wd === rhythm.weekday) {
            if (rhythm.ordinal === -1) { if (isLastOccurrenceInMonth(cur)) out.push(cur); }
            else if (ordinalInMonth(cur) === rhythm.ordinal) out.push(cur);
          }
          break;
        case 'monthlyDay': {
          const target = Math.min(Math.max(rhythm.day, 1), daysInMonth(cur));
          if (parse(cur).d === target) out.push(cur);
          break;
        }
      }
      cur = addDays(cur, 1);
    }
    return out;
  }

  // ---- fairness engine -----------------------------------------------------
  const clone = (x) => JSON.parse(JSON.stringify(x));
  const uid = () => (typeof crypto !== 'undefined' && crypto.randomUUID)
    ? crypto.randomUUID()
    : 'id-' + Math.random().toString(36).slice(2) + Date.now().toString(36);
  const sameIds = (a, b) => a.length === b.length && a.every((v, i) => v === b[i]);
  const isAbsent = (member, day) => member.absences.some((a) => a.start <= day && day <= a.end);
  const activeMembers = (plan) => plan.members.filter((m) => m.isActive);
  const memberById = (plan, id) => plan.members.find((m) => m.id === id) || null;
  const namesOf = (plan, slot) => slot.assigned.map((id) => { const m = memberById(plan, id); return m ? m.name : '?'; });
  const sortedSlots = (plan) => plan.slots.slice().sort((a, b) => (a.date < b.date ? -1 : a.date > b.date ? 1 : 0));

  /* Rules (same as Swift):
     1. Past, skipped and manual slots are frozen and count towards each member's load.
     2. Every other turn date gets the members with the lowest load / weight.
     3. Ties: the member whose last turn is longest ago, then the stable member order.
     4. A date on which nobody is available becomes an open slot. */
  function regenerate(input, today, overwriteManual = false) {
    const plan = clone(input);
    const dates = generateDates(plan.rhythm, plan.start, plan.end);
    const dateSet = new Set(dates);

    const frozen = new Map();
    for (const slot of plan.slots) {
      const isPast = slot.date < today;
      const keepManual = slot.isManual && !overwriteManual;
      if (!(isPast || keepManual || slot.isSkipped)) continue;
      if (!(isPast || dateSet.has(slot.date))) continue;
      frozen.set(slot.date, slot);
    }

    const load = {};
    const last = {};
    for (const slot of [...frozen.values()].sort((a, b) => (a.date < b.date ? -1 : 1))) {
      if (slot.isSkipped) continue;
      for (const id of slot.assigned) {
        load[id] = (load[id] || 0) + 1;
        if (last[id] !== undefined && last[id] >= slot.date) continue;
        last[id] = slot.date;
      }
    }

    const existingByDate = new Map();
    for (const slot of plan.slots) if (!existingByDate.has(slot.date)) existingByDate.set(slot.date, slot);
    const indexed = activeMembers(plan).map((m, i) => ({ m, i }));
    const result = [...frozen.values()];

    for (const date of dates) {
      if (frozen.has(date)) continue;
      const slot = existingByDate.get(date) || { id: uid(), date, assigned: [], isManual: false, isSkipped: false, note: null, sequence: 0 };
      const candidates = indexed.filter((x) => !isAbsent(x.m, date));
      const ranked = candidates.slice().sort((a, b) => {
        const la = (load[a.m.id] || 0) / Math.max(a.m.weight, 0.25);
        const lb = (load[b.m.id] || 0) / Math.max(b.m.weight, 0.25);
        if (la !== lb) return la < lb ? -1 : 1;
        const ta = last[a.m.id] !== undefined ? last[a.m.id] : DISTANT_PAST;
        const tb = last[b.m.id] !== undefined ? last[b.m.id] : DISTANT_PAST;
        if (ta !== tb) return ta < tb ? -1 : 1;
        return a.i - b.i;
      });
      const chosen = ranked.slice(0, plan.slotSize).map((x) => x.m.id);
      if (!sameIds(chosen, slot.assigned)) slot.sequence += 1;
      slot.assigned = chosen;
      slot.isManual = false;
      slot.isSkipped = false;
      for (const id of chosen) { load[id] = (load[id] || 0) + 1; last[id] = date; }
      result.push(slot);
    }
    plan.slots = result.sort((a, b) => (a.date < b.date ? -1 : a.date > b.date ? 1 : 0));
    return plan;
  }

  function assignmentCounts(plan) {
    const counts = {};
    for (const m of plan.members) counts[m.id] = 0;
    for (const slot of plan.slots) {
      if (slot.isSkipped) continue;
      for (const id of slot.assigned) counts[id] = (counts[id] || 0) + 1;
    }
    return counts;
  }

  function swap(plan, slotIdA, slotIdB) {
    const out = clone(plan);
    const a = out.slots.find((s) => s.id === slotIdA);
    const b = out.slots.find((s) => s.id === slotIdB);
    if (!a || !b || a === b) return out;
    const tmp = a.assigned; a.assigned = b.assigned; b.assigned = tmp;
    for (const s of [a, b]) { s.isManual = true; s.sequence += 1; }
    return out;
  }

  function applyManualEdit(plan, edited) {
    const out = clone(plan);
    const index = out.slots.findIndex((s) => s.id === edited.id);
    if (index < 0) return out;
    const previous = out.slots[index];
    const slot = clone(edited);
    if (!sameIds(previous.assigned, slot.assigned) || previous.isSkipped !== slot.isSkipped) {
      slot.isManual = true;
      slot.sequence = previous.sequence + 1;
    }
    out.slots[index] = slot;
    return out;
  }

  // ---- export --------------------------------------------------------------
  const WD_SHORT = ['So.', 'Mo.', 'Di.', 'Mi.', 'Do.', 'Fr.', 'Sa.'];
  const formatNumeric = (iso) => { const { y, m, d } = parse(iso); return pad(d) + '.' + pad(m) + '.' + y; };

  function textExport(plan, { memberId = null, from = null } = {}) {
    const lines = [plan.name, ''];
    for (const slot of sortedSlots(plan)) {
      if (slot.isSkipped) continue;
      if (from && slot.date < from) continue;
      if (memberId && !slot.assigned.includes(memberId)) continue;
      const names = namesOf(plan, slot);
      lines.push(WD_SHORT[weekday(slot.date) - 1] + ', ' + formatNumeric(slot.date) + ' – ' + (names.length ? names.join(' & ') : 'offen'));
    }
    return lines.join('\n');
  }

  return {
    MAX_SPAN_DAYS, parse, format, addDays, daysBetween, weekday, daysInMonth, todayLocal, firstOfMonth, formatNumeric,
    generateDates, regenerate, assignmentCounts, swap, applyManualEdit, textExport,
    isAbsent, activeMembers, memberById, namesOf, sortedSlots, uid, clone
  };
})();
if (typeof module !== 'undefined' && module.exports) module.exports = Reihum;
