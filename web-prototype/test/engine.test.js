const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const R = require('../src/engine.js');

const scenarios = JSON.parse(fs.readFileSync(path.join(__dirname, 'scenarios.json'), 'utf8'));
const golden = JSON.parse(fs.readFileSync(path.join(__dirname, 'golden.json'), 'utf8'));

function rhythmFrom(spec) {
  return { kind: spec.kind, weekday: spec.weekday, ordinal: spec.ordinal, day: spec.day };
}

function run(scenario) {
  const ids = {};
  const members = scenario.plan.members.map((spec, index) => {
    ids[spec.name] = 'id-' + spec.name;
    return {
      id: ids[spec.name], name: spec.name, weight: spec.weight ?? 1, colorIndex: index, isActive: spec.active ?? true,
      absences: (spec.absences ?? []).map(([start, end]) => ({ start, end, note: null }))
    };
  });
  let plan = {
    id: 'p', name: scenario.name, rhythm: rhythmFrom(scenario.plan.rhythm), start: scenario.plan.start, end: scenario.plan.end,
    slotSize: scenario.plan.slotSize, showAttribution: true, members, slots: []
  };
  const slot = (date) => plan.slots.find((s) => s.date === date);
  const member = (name) => plan.members.find((m) => m.id === ids[name]);
  for (const op of scenario.ops) {
    switch (op.op) {
      case 'regen': plan = R.regenerate(plan, op.today, op.overwriteManual ?? false); break;
      case 'manual': { const e = R.clone(slot(op.date)); e.assigned = op.names.map((n) => ids[n]); plan = R.applyManualEdit(plan, e); break; }
      case 'skip': { const e = R.clone(slot(op.date)); e.isSkipped = true; e.assigned = []; plan = R.applyManualEdit(plan, e); break; }
      case 'swap': plan = R.swap(plan, slot(op.a).id, slot(op.b).id); break;
      case 'absence': member(op.member).absences.push({ start: op.start, end: op.end, note: null }); break;
      case 'weight': member(op.member).weight = op.value; break;
      case 'deactivate': member(op.member).isActive = false; break;
      case 'addMember': ids[op.member] = 'id-' + op.member; plan.members.push({ id: ids[op.member], name: op.member, weight: op.value ?? 1, colorIndex: plan.members.length, isActive: true, absences: [] }); break;
      case 'rhythm': plan.rhythm = rhythmFrom(op.rhythm); if (op.start) plan.start = op.start; if (op.end) plan.end = op.end; break;
      default: throw new Error('unknown op ' + op.op);
    }
  }
  const counts = R.assignmentCounts(plan);
  return {
    name: scenario.name,
    slots: R.sortedSlots(plan).map((s) => ({ date: s.date, names: R.namesOf(plan, s), manual: s.isManual, skipped: s.isSkipped, sequence: s.sequence })),
    counts: Object.fromEntries(plan.members.map((m) => [m.name, counts[m.id] ?? 0]))
  };
}

test('the port reproduces every Swift reference scenario exactly', () => {
  assert.equal(golden.length, scenarios.length);
  scenarios.forEach((scenario, i) => {
    assert.deepEqual(run(scenario), golden[i], 'scenario: ' + scenario.name);
  });
});

function plainPlan(memberCount, days, slotSize = 1) {
  const members = Array.from({ length: memberCount }, (_, i) => ({ id: 'm' + i, name: 'M' + i, weight: 1, colorIndex: i, isActive: true, absences: [] }));
  return { id: 'p', name: 'T', rhythm: { kind: 'daily' }, start: '2026-10-01', end: R.addDays('2026-10-01', days - 1), slotSize, showAttribution: true, members, slots: [] };
}

test('balance: with equal weights no member is ever more than one turn ahead', () => {
  const plan = R.regenerate(plainPlan(5, 100), '2026-10-01');
  const counts = {};
  for (const slot of R.sortedSlots(plan)) {
    for (const id of slot.assigned) counts[id] = (counts[id] || 0) + 1;
    const values = plan.members.map((m) => counts[m.id] || 0);
    assert.ok(Math.max(...values) - Math.min(...values) <= 1);
  }
});

test('absent members are never assigned on absent days', () => {
  const plan = plainPlan(3, 40);
  plan.members[0].absences = [{ start: '2026-10-05', end: '2026-10-25', note: null }];
  const result = R.regenerate(plan, '2026-10-01');
  for (const slot of result.slots) {
    if (slot.date >= '2026-10-05' && slot.date <= '2026-10-25') assert.ok(!slot.assigned.includes('m0'));
  }
});

test('regeneration is deterministic and keeps history and manual slots', () => {
  const plan = R.regenerate(plainPlan(4, 30), '2026-10-01');
  const again = R.regenerate(plainPlan(4, 30), '2026-10-01');
  assert.deepEqual(plan.slots.map((s) => s.assigned), again.slots.map((s) => s.assigned));

  const edited = R.applyManualEdit(plan, { ...R.clone(plan.slots[12]), assigned: ['m3'] });
  const next = R.regenerate(edited, '2026-10-11');
  plan.slots.forEach((slot, i) => { if (slot.date < '2026-10-11') assert.deepEqual(next.slots[i].assigned, slot.assigned); });
  assert.deepEqual(next.slots[12].assigned, ['m3']);
  assert.equal(next.slots[12].isManual, true);
});

test('two people per turn are distinct', () => {
  const plan = R.regenerate(plainPlan(5, 50, 2), '2026-10-01');
  for (const slot of plan.slots) { assert.equal(slot.assigned.length, 2); assert.equal(new Set(slot.assigned).size, 2); }
});

test('calendar arithmetic across month ends, leap years and weekday numbering', () => {
  assert.equal(R.addDays('2028-02-28', 1), '2028-02-29');
  assert.equal(R.addDays('2027-02-28', 1), '2027-03-01');
  assert.equal(R.addDays('2026-12-31', 1), '2027-01-01');
  assert.equal(R.weekday('2026-10-02'), 6);
  assert.equal(R.weekday('2026-10-04'), 1);
  assert.equal(R.daysInMonth('2028-02-10'), 29);
  assert.equal(R.daysBetween('2026-03-28', '2026-03-31'), 3);
});

test('text export lists only upcoming turns and marks open ones', () => {
  const plan = R.regenerate({ ...plainPlan(2, 5), rhythm: { kind: 'daily' } }, '2026-10-01');
  plan.slots[3].assigned = [];
  const text = R.textExport(plan, { from: '2026-10-03' });
  const lines = text.split('\n');
  assert.equal(lines[0], 'T');
  assert.equal(lines.length, 2 + 3);
  assert.ok(text.includes('offen'));
  assert.ok(!text.includes('01.10.2026'));
});
