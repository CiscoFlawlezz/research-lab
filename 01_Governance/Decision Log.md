"Frontier-session allocation accepted per RL-ROADMAP-001: A3+A4 → A1 → A2+A8 → A5/A6/A7 → A10 → A9. Revisit trigger: completion of A10 or loss of Fable 5 access."

07-06-2026: Mission.md v2 accepted as proposed (RL-SPEC-001 §1.1, Appendix A item 4 resolved). Original ambitions preserved in [[Future_Directions]], status decaying. Revisit trigger: V2 exit gate

2026-07-13: climate_day() settlement-day boundary uses FIXED per-city standard-time
offsets (phoenix -7, nyc/miami -5, chicago/austin -6), applied year-round, NOT a
DST-aware timezone library — deliberately, so the boundary never shifts with DST.
This is the executable form of the LST finding (M2.T5 / Miami-Austin notes). Accepted
per D1 (single settlement-day function). Revisit trigger: adding a city outside these
three offset zones, or any evidence a Kalshi series settles on a non-standard-time day
boundary. Status: E3 Architect ratified

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

2026-08-11: scripts/backup_db.py row-count verification replaced with a
bounded-prefix check keyed on id; kalshi_observations added to COUNTED_TABLES; a
missing counted table becomes a hard failure. Reason: the live-vs-snapshot dict
equality at line 157 is the exact defect CLAUDE.md guardrail 4 names -- an
absolute row count used as a verification criterion on a live database -- and it
has failed nineteen runs, eighteen of them consecutive, most recently
2026-08-11T05:01:03Z. The snapshot is a superset in every failure, never a
subset; raw_nws_cli matches exactly every run and only the two Kalshi-fed tables
drift, which is what an append-only schema plus a five-minute writer predicts.
integrity_check passed all nineteen times. The snapshot is good and the
verification is wrong. Correction to the record as previously carried: the
failures begin 2026-07-23, not 2026-07-24, and 2026-07-24 succeeded after the
first failure with a one-second VACUUM against a 48 MB file -- the single success
inside the failure era is the race being won once, not evidence the defect was
absent. There is no gap in the log between 2026-07-24 and 2026-08-06; every day
is present and every day failed. Mechanism: table_counts() is read, VACUUM INTO
runs, and the Kalshi sweep writes during that window; the window has grown from
one second to fifty seconds in eighteen days and nearly doubled between 08-10 and
08-11 alone, so the defect compounds and cannot self-recover. Two deeper faults
found beneath the visible one and folded into this change: table_counts() runs
three COUNT(*) statements in autocommit, so the live baseline is a smear across
three unsynchronised instants rather than one consistent view, and the -1
sentinel for a missing table compares equal to itself, so an omitted table passes
verification while verifying nothing. Predicate ruled: capture a per-table id
ceiling inside a single read transaction and assert the snapshot contains exactly
that prefix, rather than snapshot >= live_before, which has no upper bound and
whose slop widens on the same clock as the defect it replaces. snapshot_blob is
handled by hash-reachability from the snapshot_index prefix and NOT by rowid,
because it declares hash TEXT PRIMARY KEY with no integer id and SQLite permits
VACUUM to renumber implicit rowids -- a rowid-keyed check would be unsound in a
way that passes green most of the time. Adding an integer id to snapshot_blob is
correct long-term but is a live-DB migration on a one-gigabyte file and is
excluded. Assertions are non-negotiable and land in the same commit: a negative
test proving the predicate REJECTS a deliberately truncated snapshot through the
real call site, and a synthetic-concurrency test with a writer appending during
VACUUM INTO against a scratch database. A green run against a quiet database
proves nothing, since the current script is green against a quiet database; a
live run in which nothing was written during the VACUUM is a void test, not a
passing one. Failed runs delete their snapshots -- shutil.rmtree with
ignore_errors=True executes one line before fail() at every failure exit -- so
eighteen valid integrity-checked snapshots were created and destroyed, nothing
partial ever reached D:, and the cost of this defect is eighteen days of backup
coverage rather than any data corruption. Restoring from the newest surviving
generation, pipeline_2026-07-24.db.gz, would lose roughly 326,930 snapshot_index
rows, 246,123 blobs and 901 MiB of irreversible Kalshi depth. Excluded from this
change and recorded: pruning, which is a delete against a capacity risk that is
not realised (1.53 TB free, 8.5 MB of backups, nothing accumulating because
nothing is succeeding) and which wants its own approval surface, but which is
scheduled as the next backup-track task rather than deferred, since resumed
backups run near 0.9 GB compressed per day and rising; the off-site leg, recorded
against review sections 5, 11 risk 6, 12, 15 action 9 and 16, unsolved; the
local-versus-UTC filename stamp at line 117, which has already caused two silent
generation overwrites via shutil.move (2026-07-17 and 2026-07-21), giving nine
successful runs but seven files, and which travels with pruning; and content-level
hash verification of snapshot blobs, which is a new capability rather than a
defect fix. The line 6 docstring citing schema.sql line 1 as the cause of WAL is
corrected in this change rather than queued, on the Q1 precedent that a governance
file and the code it describes stop disagreeing in the same commit; schema.sql is
retired to archive/ and WAL is set at runtime by SnapshotStore._connect(), and
CLAUDE.md already carries the ratified replacement text. This work is sequenced
ahead of F2 on governance grounds rather than schedule: operational guardrail 2
requires scripts/backup_db.py before any DB mutation, so with no working backup
that guardrail is unsatisfiable and every DB mutation in the arc -- the pending
F-01 eight-row re-derivation, Task 4's collection_runs DDL, any ALTER -- is
blocked behind it. Revisit trigger: the D: survey showing the surviving
generations are not what backup_health.log records, which would reclassify this
from a predicate defect to a data-loss investigation; or orphaned
pipeline_backup_* directories found under %TEMP%, which would make the
ignore_errors=True cleanup a second live defect in the same failure path and fold
it into this change; or any counted table acquiring a DELETE path, which changes
the prefix check's soundness argument; or a second database file being ruled under
option B or C, since backup_db.py generalising to N files is a hard prerequisite
for that and not a follow-up. Status: E3 Architect ratified. 