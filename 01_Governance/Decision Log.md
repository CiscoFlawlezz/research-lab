"Frontier-session allocation accepted per RL-ROADMAP-001: A3+A4 → A1 → A2+A8 → A5/A6/A7 → A10 → A9. Revisit trigger: completion of A10 or loss of Fable 5 access."

07-06-2026: Mission.md v2 accepted as proposed (RL-SPEC-001 §1.1, Appendix A item 4 resolved). Original ambitions preserved in [[Future_Directions]], status decaying. Revisit trigger: V2 exit gate

2026-07-13: climate_day() settlement-day boundary uses FIXED per-city standard-time
offsets (phoenix -7, nyc/miami -5, chicago/austin -6), applied year-round, NOT a
DST-aware timezone library — deliberately, so the boundary never shifts with DST.
This is the executable form of the LST finding (M2.T5 / Miami-Austin notes). Accepted
per D1 (single settlement-day function). Revisit trigger: adding a city outside these
three offset zones, or any evidence a Kalshi series settles on a non-standard-time day
boundary. Status: E4 code pending Architect ratification.

2026-07-13: M2.T4 (CLI collector) split into M2.T4a (scaffold + source confirmation,
parser stubbed) and M2.T4b (parser built against a real captured sample). Reason: per
F1 discipline, the high/low parser must not be written against a guessed CLI format;
the raw body is preserved in the snapshot store regardless, so the accrual clock can
start on snapshots before the parser exists. Scope: Phoenix-only first (KPHX fully
verified); other four cities added as F2 rulebook confirmations land. Alternative
(build parser now from memory of CLI format) rejected as the canonical F1 error.
Revisit trigger: F2 closure for non-Phoenix cities. Status: E4.