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
Revisit trigger: F2 poll cadence ruled at 5 minutes or faster; or collection_runs ruled
per-collector rather than global; or adoption of a ratified append-only exception for
pure file relocation; or Q2 resolved such that a measured SQLITE_BUSY rate exists and is
non-trivial. Note that the volume condition originally drafted as a trigger (pipeline.db
exceeding 2 GB) is recorded instead as a FINDING, not a trigger: at ruling time the file
already stood at 960,946,176 bytes (916 MiB) with ~331,542 snapshot_index rows implying
~9.6 collection-days and a growth rate near 95 MiB per full collection-day. The §16
market.db split is consequently no longer deferrable on its own clock — independently of
F2, which lands in pipeline.db either way and does not change the split's cost. Under
Invariant 1 that split cannot delete the originals, so its cost is a permanent
duplication of ~0.9 GB and rising unless an append-only exception is ratified. Schedule
it as its own task.

2026-08-10: raw_nws_hourly_forecast (F2) lands in data/pipeline.db — single file, no
topology change. The four ratified F2 rulings named a table, not a file; this closes
that gap before the table has rows. Reason: review §16 splits on vendor/stream identity
(pipeline.db = CLI + runs; market.db = Kalshi + its snapshots), not on growth rate, and
F2 is an NWS stream that joins constantly to raw_nws_cli — the review's own boundary
puts it on the pipeline.db side. Splitting F2 out separately would pre-empt §16 in a
shape the review never proposed. Supporting: SQLite provides no atomic transaction
across attached databases when any is in WAL mode, so any split makes a combined data
row + collection_runs audit row write non-atomic (constrains Task 4 directly); and the
contention that motivates splitting is currently unmeasurable, since SQLITE_BUSY
surfaces as sqlite3.OperationalError into a broad handler indistinguishable from a
network timeout (Q2). Two objections to splitting were examined and REJECTED as weak,
recorded so they are not re-litigated in their strong form: SnapshotStore's blob+index
atomicity is per-call and per-file, so a split cannot break Invariant 3's
no-orphan/no-dangler property; and cross-stream content dedupe is ~zero, since CLI
text, Kalshi JSON and gridpoint JSON never collide by SHA-256 — only query reach is
lost, not integrity. Threading cost of a second file was measured, not assumed: four
origination points (nws_cli_collector.py:259, kalshi_observation_collector.py:307,
run_cli_collection.bat:24, run_kalshi_observations.bat:29), one hardcoded absolute
constant (backup_db.py:39), and zero scheduler XML changes — all five task definitions
pass Command + WorkingDirectory only, never a DB path. Accepted cost: reversibility is
asymmetric and runs against this ruling — under Invariant 1 a later split cannot delete
the originals, so it either duplicates data permanently or needs a ratified append-only
exception, whereas a later merge is cheap (freeze the file in place as a read-only
historical source, as archive/schema.sql was retired in Task 1). Alternative options B
(dedicated forecast.db) and C (execute §16 market split first) rejected for now; C
remains correct sequencing if the split is ever pursued, as its own task. If B or C is
ever ruled, generalising scripts/backup_db.py to N files is a hard prerequisite, not a
follow-up — a second file is backed up by nothing (git excludes *.db), and an
unbacked-up file holding [IRR] data is worse than any contention it relieves. Revisit
trigger: F2 poll cadence ruled at 5 minutes or faster; or pipeline.db exceeding 2 GB on
disk or backup VACUUM INTO exceeding the 5-minute Kalshi sweep interval; or
collection_runs ruled per-collector rather than global; or adoption of a ratified
append-only exception for pure file relocation; or Q2 resolved such that a measured
SQLITE_BUSY rate exists and is non-trivial. Status: E4 pending Architect ratification.