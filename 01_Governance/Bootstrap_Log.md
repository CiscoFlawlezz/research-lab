# Bootstrap Log

2026-07-04 — Pre-move snapshot created from fully hydrated OneDrive copy and verified by opening a note inside the zip. Stored at: [My Passport D:].

2026-07-04 — Vault relocated from C:\Users\rjkir\OneDrive\Documents\Obsidian\Research Lab to C:\Users\rjkir\Obsidian\Research Lab. Vault opens with all content intact. Old OneDrive copy removed. No OneDrive sync icons on new location.

2026-07-06 — Git for Windows 2.55.0.windows.2 installed. Editor: Notepad. Default branch: main. Line endings: checkout as-is, commit as-is. Credential helper: Git Credential Manager. Identity configured (user.name, user.email). Repository initialized at vault root. .gitignore created (excludes workspace.json, workspace-mobile.json, .trash/, Windows debris).

2026-07-06 — Private GitHub remote created (github.com/CiscoFlawlezz/research-lab). Local main tracks origin/main. First push verified in browser: 2 commits, correct exclusions, Private badge confirmed. Auth via Git Credential Manager (browser flow); credential stored in Windows Credential Manager. 2FA enabled on account.

2026-07-06 — Reconciliation: expected 3 commits, found 2. Root cause: environment-log entry was written before the initial commit and was included in it; the intended separate commit found nothing to commit. Verified local main == origin/main (hashes 0162068, 14ae139). No content loss. Lesson: read git commit output — "nothing to commit" means no commit was created.

2026-07-06 — Automated backups live. Script: C:\Users\rjkir\Obsidian\Scripts\vault-backup.bat (full-path git, empty-run guard, output to backup.log). Task Scheduler: daily at [9:15pm] + at-logon with 15 min delay; run-when-logged-on; battery-enabled; missed-start catchup ON. Manual scheduler run verified 0x0; auto-commit confirmed on GitHub.
add
commit -m "Log: automation established"
push

2026-07-06 — Recovery drill PASSED. Full clone from GitHub to isolated folder; history hashes matched; vault opened in Obsidian with settings intact; historical file version retrieved via git show; drill copy destroyed. Recovery time: ~[X] minutes. Next drill due: 2026-10-06 (quarterly).

2026-07-06 ---- [ ] **R5 — Off-machine backup with tested restore.** Establish a scheduled backup of `data/`, `snapshots/`, and BOTH Git repositories to an off-machine location (external drive kept unplugged between backups, and/or a cloud remote). Then perform a TEST RESTORE into a scratch folder and confirm the database opens and the vault loads. An untested backup is a hypothesis, not a backup. (Source: Master Spec §10 R5, Appendix A item 3.)
- Done means: a file deleted from the live folder can be recovered from the backup in a test, AND the restored SQLite database passes an integrity check.

## [M0.T1] Bootstrap Section 2 closed: git version + commit identity verified — 2026-07-06

Shell: Git Bash (MINGW64)

$ git --version
git version 2.55.0.windows.2

$ git config --global --list
user.name=rjkir
user.email=rjkirby316@gmail.com

$ git config --system --list   (installer settings confirmed here, not in --global)
core.autocrlf=false
core.editor=notepad
credential.helper=manager
init.defaultbranch=main
(plus git-lfs filters, ssl backend, fscache — installer defaults)

$ git config --get init.defaultbranch
main

Acceptance: MET — user.name and user.email present and correct.
Contradiction resolved: installer settings (branch/editor/line-endings/GCM)
live in --system, not --global. Graph §0 assumptions now VERIFIED against
terminal output. Default branch = main confirmed ahead of M0.T2.

2026-07-07 — Vault walkthrough Sections 3–7 complete per ADR-022: hybrid scheme applied, duplicate resolved (scoring rules note archived), 15 empty placeholders deleted, 5 seeds retained, MOC_Home + MOC_Probability_and_Scoring + Prediction_Ledger created, orphan sweep passed.

2026-07-09 — Confirmed: no Windows Task Scheduler auto-backup task exists for weather-pipeline (only the vault has one). Pipeline currently backed up by manual commit only. Flagged against Risk R5. To be scheduled before first live data collection.

## 2026-07-09 — Milestone 1b Gate 1 & 2 COMPLETE: Settlement station verification

**Gate 1 — Station ID verification (Master Spec R1 mitigation).** Verified all five
settlement stations against Kalshi's official market rules pages. Five snapshots saved
to `snapshots/2026-07-09_station_verification/`. All five candidate stations CONFIRMED
correct against primary source; zero station_id corrections required.

| City    | Kalshi rulebook | Settlement location (per rules) | station_id | Result   |
|---------|-----------------|----------------------------------|------------|----------|
| Phoenix | (KXHIGHTPHX)    | Phoenix Sky Harbor               | KPHX       | VERIFIED |
| NYC     | NHIGH           | Central Park, New York (wfo=okx) | KNYC       | VERIFIED |
| Chicago | CHIHIGH         | Chicago Midway, Illinois (wfo=lot)| KMDW      | VERIFIED |
| Miami   | MIAHIGH         | Miami, FL                        | KMIA       | VERIFIED |
| Austin  | AUSHIGH         | Austin Bergstrom                 | KAUS       | VERIFIED |

**Gate 2 — NWS user-agent email.** Confirmed correct in config.yaml
(user_agent: "prediction-market-research-lab (ryaneastnc@gmail.com)"). No change needed.

**config.yaml updated:** all five cities flipped `verified: false` → `verified: true`;
station_id comments updated to cite primary source + date; header comment block updated.

### FINDINGS RECORDED (do not lose these — they affect data validity)

**F1 — Settlement source is the NWS Daily Climate Report (CLI product), not raw station obs.**
Rules route to the NWS Daily Climate Report for a named location via WFO office
(e.g., Chicago → wfo=lot → "Chicago Midway, IL"; NYC → wfo=okx → "Central Park NY"),
column "Observed Value", row "Maximum". The authoritative settlement value is the
Daily Climate Report maximum, which can differ from raw METAR hourly obs. The NWS
collector MUST pull the Daily Climate Report figure, not the station's raw max, or
scored outcomes will not match Kalshi settlement. Flagged as R1-adjacent. Open until
collector design confirms it reads the CLI product.

**F2 — Series tickers (KXHIGH...) are NOT verified by this task.** The rules pages are
headed by contract rulebook codes (CHIHIGH, MIAHIGH, NHIGH, AUSHIGH), not the KXHIGH...
series tickers in config. Only KXHIGHTPHX was confirmed via a live market URL. The other
four series are "confirmed to exist via test_connections.py" (API existence, E-lower)
but NOT confirmed via primary-source rules page. Series-ticker verification remains an
open sub-task, distinct from station verification.

**F3 — Per-city settlement subtleties.**
- Miami & Austin: determination delayed to 11:00 AM ET if high is inconsistent with
  6-hr/24-hr METAR highs, or if final report high is lower than earlier report(s).
- Austin: trades on CT (Last Trading Time 11:59 PM CT); the other four are ET.
  Day-boundary / timezone handling must be per-city.
- Day boundary is NWS Daily Climate Report / local standard time — shifts under DST.
  Do not assume local-clock midnight.

**Evidence grade:** This verification is E4 (Architect testimony) ratified against five
saved PDF snapshots (primary source). Snapshots are the evidence; the pasted text
transcription was a convenience copy only.

**Milestone 1b Gate 1 & 2: CLOSED.** NWS collectors are now unblocked on the station
question. Remaining pre-collection blockers: F1 (collector must read CLI product) and
F2 (series-ticker rules verification).

2026-07-13 — M2.T4 prerequisite #1 complete: core/config.py accessors + tests.
  Built core/config.py exposing cities(), series(), stations(), station(),
  nws_user_agent(), nws_base_url(), kalshi_base_url(), cli_cadence(); cutoffs()
  raises ConfigError ("not yet configured" — enters at model rung, M5). Missing
  keys raise ConfigError (subclass of KeyError), never silently default — the
  load-bearing property. Tests: 11 passed. D4 grep audit
  (grep -rn "KXHIGH\|KPHX\|KNYC\|KMDW\|KMIA\|KAUS" --include=*.py) returns no
  ticker literals inside core/config.py. Committed to pipeline repo, visible in
  git log. Status: E4, code ungraded pending Architect ratification (Invariant 3).
  Governing: RL-ENG-001 (D4 config unification).

2026-07-13 — M1.T6 complete: snapshot store + provenance index.
  Built storage/snapshots.py — content-addressed store (SHA-256), blob bytes and
  index row written in a single SQLite transaction so neither an orphan blob nor a
  dangling index row is possible. retrieve() re-hashes on read and raises on
  integrity mismatch. Idempotent re-store: identical content stored once, each
  fetch event recorded as a new provenance row. Tests: 10 passed, including the
  kill-between-write test (simulated mid-transaction crash rolls back to neither
  blob nor index row) and orphan/dangling audit counts = 0. Full suite 21 passed.
  No .db file committed. Committed, visible in git log. Status: E4, ungraded
  pending ratification. Governing: M1.T6 hashing ADR (Invariant 4, snapshot what
  you cite). NOTE: hash algorithm (SHA-256) and index schema are [IRR] — this
  fixes them; a change later requires a dated ADR addendum, not a silent edit.

2026-07-13 — M2.T1 complete: climate_day() + DST test suite.
  Built core/climate_day.py — single authority for settlement-day assignment
  (D1). Uses FIXED per-city standard-time offsets year-round (phoenix -7, nyc -5,
  chicago -6, miami -5, austin -6); DST is never applied, so the climate-day
  boundary does not shift twice a year. Naive datetimes assumed UTC (explicit);
  non-UTC-aware inputs converted; unknown city raises ClimateDayError. Tests: 12
  passed, spanning both 2026 DST transitions (spring-forward Mar 8, fall-back
  Nov 1) for the affected cities, a Phoenix summer/winter-identical control case,
  and a BITE test asserting a naive UTC-date implementation is wrong on the same
  boundary instants. Full suite 33 passed. Committed, visible in git log.
  Status: E4, ungraded pending ratification. Governing: D1 (one settlement-day
  function — lint-grade rule: no other module computes settlement days).

2026-07-13 — All three M2.T4 (CLI collector) prerequisites now closed:
  core/config.py ✓, snapshot store ✓, climate_day() ✓. Next critical-path task:
  M2.T4 — CLI Daily Climate Report ingestion [ACC][IRR], the task that starts the
  irreversible accrual clock on settlement ground truth.

  Two open items surfaced this session, recorded here rather than left implicit:
  (1) DESIGN DECISION PENDING RATIFICATION — climate_day() uses a hardcoded
      standard-offset table, not a DST-aware timezone library, deliberately (the
      boundary must not move). This is the executable form of the LST finding and
      warrants a one-line Decision Log entry at ratification.
  (2) VERIFICATION GAP for M2.T4 — the collector will need the CLI product text
      format (F1) and the four non-Phoenix rulebook confirmations (F2), both still
      open in the ★-priority queue. Prerequisites did not need these; the collector
      does. Decide before M2.T4 whether to ship Phoenix-only first (fully verified)
      and add the other four as their rulebook confirmations land.

  CORRECTION (KT Rank 5, scoped to this session's observed terminal output): at
  the start of this work, core/ and storage/ were found effectively empty of the
  real modules — the earlier "built or in progress" status for these three
  prerequisites did not match disk. This session built them from clean rather than
  confirming pre-existing work. Verified against `find . -name "*.py"` output,
  2026-07-13.

2026-07-13 — M2.T4a complete: CLI collector scaffold + source confirmation (Phoenix).
  Confirmed NWS text-product endpoint against primary docs:
  /products/types/CLI/locations/{locationId}/latest, type id CLI, User-Agent required.
  Built storage/schema.py (raw_nws_cli, append-only, nullable high/low) +
  collectors/nws_cli_collector.py (fetch -> snapshot raw body -> append row;
  parse_high_low stubbed, parser_version "stub-0"; amendment = new row; dup product_id
  skipped). Added cli_location_id to config.yaml (phoenix) + core/config.py accessor.
  Scaffold insert-only/amendment logic verified locally. LIVE steps (discover Phoenix
  CLI locationId, run fetch, capture sample) executed on Architect machine — sandbox
  cannot reach api.weather.gov. Status: E4. Parser deferred to M2.T4b per Decision Log
  2026-07-13. NOTE: raw_nws_cli schema + snapshot_hash linkage are [IRR] once rows accrue.

2026-07-14 — M2.T4 COMPLETE for Phoenix: CLI collector built, tested, running live.
  This is the [ACC][IRR] task — the settlement-ground-truth accrual clock is now
  started for Phoenix. Committed at ef53c62 (pipeline repo).

  Built this session:
  - core/config.py: added cli_location_id(city) accessor. NOTE: the CLI product
    locationId is NOT the station_id and NOT the issuing office — it is a distinct
    location code the NWS text-product API files the product under.
  - config.yaml: phoenix.cli_location_id = "PHX", confirmed live (see below).
  - storage/schema.py: raw_nws_cli append-only table. Columns include report_kind,
    nullable high/low (a report may show MM), snapshot_hash (links every parsed row
    to its preserved raw body), parser_version.
  - collectors/nws_cli_collector.py: fetch latest CLI -> snapshot raw body ->
    parse high/low -> append row. Amendments/later reports append as new rows;
    re-fetch of identical product_id is skipped. parser_version = "1".
  - tests/test_cli_parser.py: parser tests pinned to the real captured sample.
  - .gitignore: added sample_cli_*.txt (captured samples are scratch, not artifacts).

  SOURCE CONFIRMED (closes F1 endpoint question, primary-source/empirical):
  NWS text-product endpoint = /products/types/CLI/locations/{locationId}/latest,
  type id CLI, User-Agent required. Phoenix locationId "PHX" confirmed by live fetch:
  HTTP 200, productCode CLI, issuingOffice KPSR, header "NATIONAL WEATHER SERVICE
  PHOENIX AZ", body "THE PHOENIX AZ CLIMATE SUMMARY". This is the F1 collector-design
  confirmation the 2026-07-09 F1 flag was left open pending.

  MOST SIGNIFICANT FINDING (F1 discipline paid off): the real CLI product contains a
  SECOND MAXIMUM/MINIMUM section — "CLIMATE NORMALS FOR TOMORROW" — whose lines read
  "MAXIMUM TEMPERATURE (F) 107" etc. A format-guessed parser keying on "MAXIMUM"
  would silently read TOMORROW'S NORMAL (107/85) instead of today's OBSERVED value
  (108/82) if the TODAY block were ever absent or reordered — storing a forecast
  normal as an observed settlement value. The parser was hardened to (a) scope to the
  TODAY temperature block only (open at a bare "TODAY" line, close at "PRECIPITATION")
  and (b) require a numeric token immediately after a bare MAXIMUM/MINIMUM label, so
  the "TEMPERATURE (F)" normals lines never match. This bug would not have been found
  without capturing a real sample first — the whole point of F1.

  Live acceptance: collector stored one row — station KPHX, locationId PHX,
  climate_day 2026-07-13 (from a 2026-07-14T00:34Z issuance, correctly mapped back to
  the Phoenix standard-time day by climate_day), report_kind "preliminary",
  high=108, low=82, parser_version 1. Re-run correctly skipped the duplicate product.
  Full suite: 37 passed. No .db or sample committed.

  Status: E4, ungraded pending Architect ratification (Invariant 3).

  OPEN AFTER THIS SESSION:
  - .gitignore change (sample_cli_*.txt) committed separately AFTER ef53c62; and
    local main is AHEAD of origin/main — work is committed but NOT yet pushed
    (local commit ≠ off-machine backup). Push pending.
  - report_kind classification is coarse (preliminary vs summary); the Miami/Austin
    11am-ET delay rule (F3) is not yet encoded — not needed for Phoenix, needed before
    those two cities settle.
  - raw_nws_cli schema + snapshot_hash linkage are now [IRR] as rows accrue — change
    only via dated ADR addendum.

### 2026-07-15 — Log Score and Kelly Identity V2 ratified (supersedes V1)

**Type:** Reference revision + ratification **Document:** `07_References/Concepts/Log Score and Kelly Identity.md` **Prior state:** V1, created 2026-07-04, 3,228 chars. Verified live on `origin/main` this session. **New state:** V2, full rewrite. Filename preserved; all existing backlinks resolve unchanged. **Evidence grade:** E4 → **E1 (Architect-ratified, canon)** per Invariant 3. 
#### Record correction (KT Rank 5) Session memory listed "Log Score and Kelly Identity V2" as already part of the ratified canonical corpus. Disk state contradicted this: `main` contained only V1, and the live `Repository_Manifest.txt` showed no V2 file. The ratification record was wrong; no V2 existed prior to this session. Named rather than silently corrected. This is the second instance of a "prior session claims built" mismatch (cf. 2026-07-14 module build) — the pattern is now established enough to treat manifest/disk verification as mandatory before any revision session.

**Type:** Canonization (document rewrite) **Document:** `07_References/Concepts/Effective Sample Size.md` **Prior version:** V1 (2026-07-04), standing-rule note **Evidence grade at ratification:** E4 → ratified; ⚑ citation flags NOT discharged (see Open flags) 
**What happened.** Independent audit of ESS V1 against graduate-level review standards. Verdict: 8/10 as a standing-rule note, 3/10 as a canonical reference. The rule was correct and load-bearing; the document was thinner than the five documents citing it. Formal machinery attributed to it (Kish equicorrelation, block bootstrap, MCMC ESS) actually lived in Forecast Verification §17.3 and Bayesian Statistics §9.1 — an inversion of the single-home convention. Rewritten from the ground up. **Rule status.** §0 Standing Rule carried verbatim from V1. City-day remains the unit of statistical evidence; cluster-by-date / block-bootstrap-by-date remains the registered default. **No operational change.** V2 supplies the why, the how-much, and the how-to-measure.

## 2026-07-15 — Kalshi Market Structure reference rebuilt (v1 → v2), ratified **Type:** Canonization (document rewrite) **Artifact:** `07_References/Data_Sources/Kalshi Ticker Anatomy and Market Structure.md` **Supersedes:** v1 (2026-07-04, Milestone 1a field notes) **Evidence at draft:** E4 (AI-drafted) **Disposition:** Ratified by Architect 2026-07-15 → canon **Audit artifact:** `Kalshi_Doc_Audit_and_Changelog.md` (Parts 1–2; retained as evidence trail) ### What happened v1 was audited as a canonical reference (5/10) rather than as the field notes it actually was (~8/10). Nothing in it was flatly wrong; it covered ~10–15% of the required surface and carried five precision defects. Full rewrite performed against primary Kalshi documentation (docs.kalshi.com, help.kalshi.com, contract-terms PDFs, live market pages) plus the lab's own 1a observations. v2 is organized along the causal chain: exchange → contract → identification → book → price → information → data → research use → pitfalls → lab integration, closing with a Verification Ledger grading every load-bearing claim [P]/[O]/[S]⚑/[I].

## 2026-07-17 — Governance Audit Task 1: obsolete documents archived, duplicated navigation removed

**Type:** Repository maintenance (governance cleanup)
**Commit:** 4c79019 (vault repo) — 7 files, 3 insertions / 31 deletions
**Governing:** Governance Audit 2026-07-17 (AI-drafted, E4), Task 1 scope as approved by Architect
**Push status:** committed, NOT yet pushed to origin/main at time of writing

**Archived to `08_Archive/` (git-tracked renames, 100% similarity, history preserved):**
- `01_Governance/Current Sprint.md` — content: "Sprint 1: Install Python, learn variables, learn loops." Falsified by reality; the pipeline has 37 passing tests and three scheduled Task Scheduler collections.
- `01_Governance/Master Roadmap.md` — two lines, a pointer to Pre_Implementation_Artifact_Roadmap_v1.
- `01_Governance/Learning Roadmap.md` — 0 bytes, linked from two governance headers.

**Navigation removed (deletions only; no substantive content altered):**
- `Research_Methodology_v2_Canonical.md` — 13-line pasted nav block sitting above the document title. The constitution's text begins at `# Research Methodology (Canonical)` and is untouched.
- `ADR_Collection_v2.0.md` — 13-line pasted nav block between title and Document ID header. No ADR body touched.
- `00_MOC/Home.md` — two dead links ([[Master Roadmap]], [[Current Sprint]]).

Both nav blocks were unauthorized duplicates of the Home MOC index (audit finding D5) that had already drifted from Home and from each other. Home MOC is now the sole navigation layer.

**Retained:**
- `04_Experiments/Experiment Log.md` — blocked by a live cross-link from canonical `Brier Decomposition - Worked Example.md:4`. Deferred to Task 2.
- `01_Governance/Pre_Implementation_Artifact_Roadmap_v1.md` — ARCHIVE candidate per audit, out of Task 1 scope.

**Verification performed:** post-move grep for `[[Current Sprint]]`, `[[Master Roadmap]]`, `[[Learning Roadmap]]` across the vault (excluding .git and 08_Archive) returned zero hits. `git diff --cached --stat` confirmed deletions-only on all three governing documents. `file` confirmed LF line endings preserved on all touched files. Manifest regenerated (63 entries; three paths rewritten).

### FINDINGS RECORDED

**`08_Archive/` had never existed in Git.** ADR-022 (2026-07-07) declares the folder as part of the vault scheme, but Git does not track empty directories and nothing had ever been placed there. The folder existed only in the ADR's text for ten days. This commit creates it. Lesson: a declared-but-empty directory is not a fact about the repository — verify structure against `git ls-files`, not against the ADR that specifies it.

**Three wikilinks were already broken before this task.** Both removed nav blocks contained links to files that do not exist under those names: `[[Future Directions]]` (ADR Collection) and `[[Future_Directions.md]]` (Methodology) — the real file is `Future_Directions.md.md`, a double-extension error; and `[[Pre_Implementation_Artifact_roadmap]]` (ADR Collection) — missing the `_v1` suffix. No working link was destroyed by their removal. This is direct evidence for the audit's D5 finding: the duplicated nav blocks had drifted and were not being maintained.

**`Future_Directions.md.md` now has zero inbound links.** The two nav blocks were its only referrers; Home MOC never linked it. The file is load-bearing for ADR-020 (accepted 2026-07-06) and Master Spec §13. A canonical, accepted-ADR-referenced document is now orphaned from vault navigation — a pre-existing gap surfaced (not caused) by this cleanup. Flagged for Task 2, along with the filename fix.

**Journal references left untouched deliberately.** `09_Journal/Vault Additions 2026-07-04.md` mentions Master Roadmap and Learning Roadmap at lines 94, 116, 117 — as plain prose in backticks and checkboxes, not wikilinks. They do not break, and journal entries are frozen history, not maintained guidance.

### PROCESS FAILURES — AI-side, both caught by verification gates (KT Rank 5)

**Failure 1 — CRLF corruption of three canonical documents.** The first edit script used Python's `write_text()`, which on Windows defaults to translating `\n` → `\r\n`. This silently converted `Home.md`, `ADR_Collection_v2.0.md`, and `Research_Methodology_v2_Canonical.md` from LF to CRLF, rewriting every line of all three. `git diff --stat` reported 1031 insertions / 1059 deletions instead of the predicted 0 / 28 — the gate fired correctly. The bad commit (f6618fb) was reset with `git reset --hard HEAD~1`; nothing had been pushed. Root cause: the dry run was executed in a Linux sandbox where the LF/CRLF distinction does not exist, so the defect could not surface before delivery. Fix: `newline=""` on both read and write. Note the read-side matters equally — it makes a CRLF file fail the block match loudly rather than be silently mangled. This directly threatened ADR-006's as-is line-ending decision, which exists to keep Markdown diffs readable.

**Failure 2 — speculation ahead of evidence.** After the reset, `git mv` failed with "No such file or directory." The AI speculated about index/working-tree divergence and manifest counts rather than running `ls`. The actual cause was mundane: `08_Archive/` had been created by `mkdir -p` (untracked, empty) and was removed by the `--hard` reset, so `git mv` failed on the *destination*, not the source. Git's error message is ambiguous about which path is missing. One `ls -la 08_Archive/` answered it immediately. This is the third recorded instance of the "stated understanding did not match disk" pattern (cf. 2026-07-14 module build, 2026-07-15 Log Score V2 ratification record). The pattern is now established across three different failure surfaces — code, ratification records, and filesystem state.

**Standing lesson reinforced:** verify against actual terminal output, never against expectation. Both failures were caught because the guide specified expected output at every step and stop points on mismatch — the beginner-proof format is load-bearing, not a courtesy.

**Evidence grade:** E4 → **ratified by Architect 2026-07-17**. The archive/removal decisions are Architect-approved; the audit that recommended them remains E4 pending item-by-item verification.

## 2026-07-17 — R5 Phase 1 COMPLETE: pipeline.db backup live, restore verified

**Commits:** c0326c1 (scripts, via auto-commit), 87e3998 (XML + rationale). Both pushed.
**Governing:** R5 Disaster Recovery audit 2026-07-17 (E4); Master Spec R5; ADR-017.

**Built:** scripts/backup_db.py + run_backup.bat + scheduler/WeatherPipeline_Backup.xml.
Daily 01:00 (after the 00:30 final sweep). Target D:\Backups\weather-pipeline.
VACUUM INTO -> integrity_check on the COPY -> live-vs-snapshot row counts ->
gzip round-trip -> sha256 re-hashed after write. Any failure aborts and leaves
the prior generation untouched. Exits non-zero.

**Verified live:** manual run 00:49Z (0x0), scheduled run 01:12Z (0x0).
90,112 -> 8,972 bytes. RESTORE PROVEN: gunzip -> integrity_check ok, 15 rows,
15 snapshot blobs, climate_days 2026-07-13..2026-07-16. R5 is no longer
unmitigated for the pipeline; it was total loss until tonight.

### FINDING 1 — "weather-pipeline-backup" was never a data backup (8 days)

Task created 2026-07-09T13:00:59, hourly x12/day, description
"Auto-commit and push weather-pipeline to GitHub (R5 backup)". It runs
auto_backup.bat = git add -A / commit / push. .gitignore excludes data/,
snapshots/, *.db. The task therefore succeeded ~12x/day for 8 days while
backing up ZERO irreplaceable data, and its name + description asserted R5
was mitigated. R5 is ranked the Lab's largest unmitigated risk.

Contradicts Bootstrap_Log 2026-07-09 ("no Task Scheduler auto-backup task
exists for weather-pipeline") -- the task was created hours after that entry.
Fifth instance of the record-vs-disk pattern (cf. 2026-07-14 modules,
2026-07-15 Log Score V2, 2026-07-17 08_Archive, 2026-07-17 stale manifest).

Disposition: task retained (valid auto-commit job); description corrected.
Windows does not permit renaming a task in place; rename deferred as debt.
Script rename auto_backup.bat -> auto_commit.bat pending (breaks the task's
Action path; two-step change).

Standing lesson: a task's NAME is not evidence of what it does. Read the
Action. Invariant 3 applied to infrastructure.

### FINDING 2 — WAL mode makes file-copy backups silently lossy

pipeline.db runs journal_mode=WAL (schema.sql line 1). Committed rows live
in pipeline.db-wal until checkpoint. Demonstrated on a schema replica with a
writer mid-transaction: `copy pipeline.db` captured 1 row; VACUUM INTO
captured 51. The naive copy opened cleanly, hashed cleanly, and would have
passed integrity_check -- while missing 50 rows. Any future backup or restore
tooling MUST use VACUUM INTO. [IRR]-adjacent: a lossy backup is undetectable
until the restore that needs it.

### FINDING 3 — auto-commit task races manual work

At 21:14 the hourly auto-commit swept up backup_db.py and run_backup.bat
mid-session and pushed them under "Auto-backup: Fri 07/17/2026 21:14:30.64",
before the deliberate commit could be written. Rationale was recorded in
87e3998 instead. An unattended `git add -A; commit; push` on a repo with an
active operator will eventually push a broken script, a debug edit, or a
secret. Its original job (off-machine code protection) is legitimate; hourly
cadence on an actively-worked repo is not. Candidate ADR: disable, reduce to
daily, or commit-without-push.

### AI process failures this session (KT Rank 5)

1. CRLF corruption: an AI-supplied edit script used Python write_text(),
   translating LF->CRLF and rewriting every line of three canonical vault
   documents. Caught by `git diff --stat` (1031 insertions vs 0 expected);
   reset before push. Root cause: dry run executed in a Linux sandbox where
   the distinction does not exist. Fix: newline="" on read AND write.
2. Speculation ahead of evidence: after the reset, `git mv` failed and the AI
   theorized about index divergence instead of running `ls`. Actual cause:
   08_Archive was an untracked empty dir removed by the reset. One `ls`
   answered it.

Both caught by the guide's expected-output/stop-point format. The format is
load-bearing, not courtesy.

**Evidence grade:** E4 -> **ratified by Architect 2026-07-17** (backup verified
live and restored). The R5 audit document remains E4 pending item-by-item review.

2026-07-17 — F7 RESOLVED: multi-city collection confirmed live from disk.
All five stations present in raw_nws_cli (KAUS, KMDW, KMIA, KNYC, KPHX).
Rollout landed 2026-07-16: rows per climate_day 07-13:1, 07-14:1, 07-15:2,
07-16:11 (Phoenix-only -> all five). Accrual is ~5 city-days/day, not 1;
no city-days were being forfeited. Commit 757df5b ("config-driven multi-city
collection with failure isolation") shipped this and was recorded in neither
the manifest nor this log — documentation lag, not a collection gap.

NOTE: row count != city-day count. Amendments append as new rows (KAUS 3 and
KPHX 6 rows on/through 07-16). n is counted in city-days per ADR-010.

## 2026-07-19 — M1.T2 COMPLETE: Kalshi order-book depth collector (Option B), five cities

**Type:** Collector build (irreversible market-microstructure accrual)
**Status:** E4 — AI-drafted, pending Architect ratification (Invariant 3)
**Push status:** Committed and pushed 2026-07-19. Pipeline origin/main advanced 87e3998 -> d1cccfe (53a0c93 collector + d1cccfe manifest generator); vault origin/main advanced ccbe391 -> db7c0ae (this log entry). A later commit corrected this line (see log tail); that correction commit is pushed separately.

**Built:** collectors/kalshi_observation_collector.py + storage.schema
ensure_kalshi_observations + kalshi_client raw-fetch methods + config
accessor + config.yaml cadence block + tests/test_kalshi_observations.py
(21 tests) + run_kalshi_observations.bat (delivered, NOT scheduled).

**Decisions (ratified 2026-07-19):** Option B (depth + fast-moving state,
no slow-moving duplication — that stays in kalshi_markets). 5-min cadence,
config-driven. Duplicate policy (i): every poll a new row, no UNIQUE.
Scope: all five cities, open markets discovered live. Atomicity =
transactional write of two jointly-fetched responses; either fetch fails
-> whole observation discarded; both fetch Date headers stored so skew is
auditable. True network simultaneity is impossible and not required.

**F1 discipline:** parser built ONLY against real captures. Pre-build
shape check across all five cities confirmed one uniform orderbook_fp
shape and surfaced the empty-side case (one ladder can be []), which the
parser and schema handle. Live run stored empty-side markets cleanly.

**Verified live (throwaway DB, production untouched):** 60/60 obs ok, five
cities x 12 markets, exit 0, dual timestamps (1s skew observed), snapshot
store 0 orphan / 0 dangling. Test DB deleted after.

**Full test suite: 69 passed, 0 failed.**

### FINDINGS
- Existing test count was 48, not the 37 in the record (suite grew with
  the 07-16/17 multi-city + R5 work). Eighth record-vs-disk instance;
  benign (more passing tests than remembered).
- open_interest_fp moved intraday (991.80 capture -> 999.50 live 40 min
  later), confirming Option B's fast-moving fields are worth per-poll
  capture and are not backfillable from candlesticks.
- Two Pythons on PATH: interactive bare `python` is a standalone 3.14
  WITHOUT project deps; the pipeline runs venv\Scripts\python.exe. All
  checks/tests this session used the venv Python. Not a defect, but a
  footgun for future interactive verification — noted.

### AI PROCESS NOTES (KT Rank 5)
- New .py files saved CRLF by the editor twice; converted to LF to match
  sibling collectors. .bat left CRLF (correct). Caught by `file` checks.
- Sandbox config.py was the pre-edit copy, so one cadence test failed in
  sandbox until the accessor was added there; on-disk config already had
  it (verified Step 3). Named, not silently reconciled.

## 2026-07-20 — F-01 RESOLVED: climate_day derived from CLI body, not issuance time (parser v2)
**Type:** Settlement-key correctness fix (verification-first; append-only)
**Status:** E4 — AI-drafted, pending Architect ratification (Invariant 3)
**Push status:** Committed and pushed 2026-07-20. Pipeline origin/main advanced
d1cccfe -> 2d4fca1: fa0a99f (parser v2 + fixtures + tests), 96ba6b9 (add
Final_Architectural_Review_2026-07-19.md, previously untracked), 2d4fca1 (review
section 15 resolution stamp). Vault: this entry was first stored mangled (9381dfd,
single truncated line) and a botched head/mv recovery then overwrote the working
log with only the entry (7dbd184, 422 deletions); both are recorded below. History
restored from 9381dfd and this clean entry appended. Append-only; no history rewrite.
**Adjudicated:** The architectural review's section 1 climate_day claim,
verification-first. Read the snapshot BODIES (not timestamps) for the contradictory
07-15 Phoenix rows and the 07-16 NYC row via storage/snapshots.py retrieve().
Section 1 CONFIRMED as a real defect — the instrument was mis-keying its settlement
field — but with one mechanism correction (see FINDINGS).
**Fixed:** collectors/nws_cli_collector.py PARSER_VERSION -> "2"; new
derive_covered_day() reads the covered day from the "CLIMATE SUMMARY FOR <DATE>"
header (authority) + TODAY/YESTERDAY block marker, cross-checked against the
issuance-derived day; disagreement stored via new storage/schema.py column
covered_day_issuance_mismatch. Unparseable header hard-fails (ValueError), no
silent fallback. Real captured Phoenix summary + preliminary bodies committed as
regression fixtures (tests/fixtures/, per review section 16).
**Verified (production DB read-only; no rows written):** all 8 summary bodies on
disk carry a YESTERDAY block, none TODAY, each stored one day past its header day;
both preliminary bodies carry TODAY, header day == stored day == correct. Spot-check:
summary -> ('2026-07-15','YESTERDAY',1), preliminary -> ('2026-07-15','TODAY',0).
**Full test suite: 73 passed, 0 failed** (was 69; +4 in tests/test_covered_day.py).
**NOT done (open, requires separate Architect authorization):** re-derivation of the
8 existing mis-keyed v1 summary rows as new parser_version=2 rows. Migration planned
(append-only inserts, +8 rows, ALTER TABLE ADD COLUMN on live DB,
DELETE-by-parser_version rollback) but NOT executed. The 8 v1 rows remain untouched.
### FINDINGS
- Mechanism correction to review section 1 (KT Rank 5, drafting AI's error): section
  1 attributed the mis-key to summaries "issued after local midnight / next morning."
  That is coincidental correlation, not cause. The true invariant is report-semantic:
  every CLI summary describes YESTERDAY regardless of issuance hour. Section 1's
  recompute-from-issuance remedy would NOT have fixed it. Covered day must come from
  the body — which is what shipped. Recorded in review section 15 stamp (2d4fca1).
- Prior-session memory of an "RL-FIX-001 register with findings F-01..F-15" was
  confabulation: no such file or ID scheme exists on disk or in vault git history
  (--all searched). The review tracks findings as prose sections, not IDs. Real prior
  findings in git are F1-F3 (406080b) and F7 (ccbe391) — a different, older series.
  No register created; fix recorded in-place in the review + here.
- Final_Architectural_Review_2026-07-19.md was untracked until this session; now
  committed (96ba6b9).
### AI PROCESS NOTES (KT Rank 5)
- Verification-first held for the code fix: parser not written until bodies read and
  the YESTERDAY invariant proven across all 8 summaries. Adjudication stated first.
- Log-paste discipline FAILED twice at close: 9381dfd stored the entry flattened to
  one truncated line; the recovery then ran a multi-line command block with an
  unresolved placeholder, whose head/mv overwrote the working log with only the entry
  and committed it (7dbd184) despite its own verification showing history missing.
  Root cause: pasting multi-step blocks instead of one command at a time with a stop
  at each check. Fixed by rebuilding from 9381dfd one command at a time.
- Two write-to-/tmp attempts failed (Permission denied, C:\ root) — the documented
  Windows /tmp footgun. Recovered via repo-local scratch files.
- Initial DB query guessed column `city`; corrected to `location_id` after reading
  the real schema. Named, not silently reconciled.

## 2026-07-20 — F-01 MIGRATION: 8 mis-keyed v1 summary rows re-derived as parser_version=2
**Type:** Data correction on production pipeline.db (append-only; reversible)
**Status:** E4 — AI-drafted, pending Architect ratification (Invariant 3)
**Authorization:** Architect directed migration this session, after the F-01 fix
(commit fa0a99f) and its resolution stamp were in place.
**Safety before write:** state verified from disk (HEAD==origin 2d4fca1, suite 73
green); pipeline.db WAL-checkpointed and file-copied to
backups/pipeline_pre_f01_migration_20260720_224306.db (34 rows, verified openable
and count-matched) BEFORE any write — the auto_backup gap means git does not cover
the .db, so a file backup was mandatory.
**What ran:** (1) ALTER TABLE raw_nws_cli ADD COLUMN covered_day_issuance_mismatch
INTEGER (additive; existing rows -> NULL; count unchanged at 34). (2) Dry-run over
the 8 parser_version=1 summary rows: each retrieved its snapshot body, ran
derive_covered_day, asserted marker=YESTERDAY, delta=-1, flag=1 — all 8 clean, no
insert. (3) Apply: 8 corrected rows inserted as parser_version=2 in ONE
transaction (with in-transaction re-assertion of the same guarantees), copying all
parent fields except the corrected climate_day and the flag, re-using the parent
snapshot_hash. Count 34 -> 42.
**Verified independently after write:** v1 summary rows unchanged (still 8, still
showing the original late days — originals preserved as evidence). v2 rows = 8
(ids 35-42), each climate_day == its snapshot header day, each with a v1 parent by
hash, each covered_day_issuance_mismatch=1. Preliminaries untouched (26 v1, 0 v2).
Suite still 73 green (data changed, not code). pipeline.db checkpointed, 42 rows.
**Rollback:** DELETE FROM raw_nws_cli WHERE parser_version='2'. No v1 row was
mutated, so rollback is total. File backup above is the belt-and-suspenders.
**OPEN for ratification — read authority:** append-only correction means each of
the 8 affected climate-days now has BOTH a v1 (wrong) and a v2 (correct) row. Any
read that joins on (station, climate_day) WITHOUT filtering parser_version will
double-count those 8 days. "Which parser_version is authoritative for reads" is now
a required Architect decision. Recommend: reads select the highest parser_version
per (product_id) — but that is not yet decided or implemented.
### AI PROCESS NOTES (KT Rank 5)
- Migration gated behind: real file backup, dry-run with per-row assertions, and
  independent post-write verification — none skipped. No write occurred until the
  dry-run showed ALL 8 CLEAN.
- The dry-run was re-run once by accident before apply; harmless (read-only,
  identical output). Named, not silently passed over.

## 2026-07-21 — SESSION CLOSE: handoff committed, scratch cleared, tree clean
**Type:** Session-close housekeeping (no code or data change)
**Status:** E4 — AI-drafted, pending Architect ratification (Invariant 3)
**Context:** Follows the F-01 RESOLVED and F-01 MIGRATION entries above, all
ratified this session.
**Done:**
- Session handoff written and committed to the pipeline repo root:
  SESSION_HANDOFF_2026-07-20_F01.md (238 lines). Pipeline origin/main advanced
  2d4fca1 -> f82850b. The handoff is the permanent transition record for the
  F-01 session (adjudication, parser v2, migration, ratification ledger) and is
  itself E4.
- Eight untracked session scratch scripts deleted from the pipeline repo
  (query_f01, read_blob, read_blobs, capture_fixtures, validate_summaries,
  migrate_f01_dryrun, migrate_f01_apply, verify_f01_migration). None were
  tracked; deletion affects disk only, nothing in git history.
- verify_f01_migration.py was deliberately removed rather than kept: it carried
  a frozen-DB bug (asserted v2 prelim == 0), which falsely reported PROBLEM once
  the live scheduler wrote rows. Its logic is captured in the handoff; do not
  resurrect it as-is.
**Final verified state (from disk):** pipeline HEAD f82850b == origin, working
tree clean; vault HEAD d3b16f2 == origin; suite 73 passing; raw_nws_cli holds the
8 migration rows (ids 35-42) plus ongoing live scheduler rows.
**Carried forward (open, next session):** (1) read-authority decision — which
parser_version wins on reads; ADR-worthy, blocks downstream reads/V2. (2) Kalshi
depth collector scheduling ([ACC][IRR], highest accrual cost). (3) remaining
review findings: F-13 / 11am ET rule (read MIA/AUS PDFs first), forecast
collector (F2, [IRR]), collection_runs audit rows, auto-backup remediation.
### AI PROCESS NOTES (KT Rank 5)
- Handoff committed by explicit path (git add <file>), never git add -A, to keep
  the scratch scripts out of the commit.
- Scratch deletion is unrecoverable (untracked); files named explicitly rather
  than by wildcard so nothing unintended was removed.

## 2026-07-22 — VERIFY: Kalshi observation collector never scheduled / zero production accrual (Adjudication C)
**Type:** Verification finding (no code, config, or DB change this session)
**Status:** E4 — AI-verified, pending Architect ratification (Invariant 3)
**Session:** First Claude Code session (Priority 1: verify Kalshi collector scheduling). Repo HEAD f0edb39 == origin at session start; suite 73/73 green (via venv Python — bare `python` on PATH is a non-project 3.14 interpreter).
**Question:** Is the Kalshi observation collector ([ACC][IRR]) actually scheduled and firing?
**Finding — Adjudication (C), confirmed from disk:**
- No registered Task Scheduler task for Kalshi. Only WeatherPipeline_Backup, WeatherPipeline_CLI_Primary/Amendment/Final exist (plus a disabled weather-pipeline-backup).
- No `scheduler/*.xml` for Kalshi (only Backup + the three CLI tasks).
- `run_kalshi_observations.bat` exists at repo root; its own header states it was DELIVERED BUT NOT YET SCHEDULED, to be registered only on Architect instruction.
- Worse than a stoppage: `pipeline.db` has NO `kalshi_observations` table at all. Per the 2026-07-19 M1.T2 entry, the collector has only ever run against a throwaway test DB. **Production has never been touched — zero accrual since the collector shipped 2026-07-19.**
- `logs/` has zero `kalshi_obs_*.log` files.
- Collector health confirmed: manual test-run against a scratch DB this session returned 60/60 observations ok, exit 0. The collector is ready; only registration is missing.
- Configured cadence: `cadence_minutes: 5` (config.yaml).
**Consequence:** every 5-minute order-book-depth interval across all five cities since 2026-07-19 is permanently lost (depth is not reconstructable from candlesticks), and loss continues until registration.
**Logon-pattern comparison (read-only, for the registration mirror + Priority 2):**
- The three CLI tasks that DO fire: InteractiveToken + LeastPrivilege, "Interactive only," RunAs rjkir, all Last Result 0. Proven-good but "Interactive only" = runs only when logged in.
- Backup task: Password logon (explicit SID + stored credential), "Interactive/Background," HighestAvailable — survives logout, but a distinct setup path.
- **Open Priority 2 question flagged:** should collectors use the survives-logout pattern (Backup) or the only-when-logged-in pattern (CLI)? "Interactive only" is a latent silent-stoppage risk if the machine is logged out. Not decided this session.
**Action taken:** NONE. No task registered, no DB written, nothing changed — per Architect instruction to report/record first. Registration deferred to a deliberate next step.
**Next:** Architect to decide (a) register now on the proven CLI InteractiveToken pattern to stop the bleed, accepting a possible later re-registration if Priority 2 moves collectors to the survives-logout pattern; or (b) decide the logon pattern first, then register. First scheduled run will be the first-ever production write to a new `kalshi_observations` table → run `scripts/backup_db.py` first (guardrail #2).
### AI PROCESS NOTES (KT Rank 5)
- Verify-first held: no registration or DB write; adjudication (C) stated before any proposed change; used venv Python throughout (avoided the bare-`python` footgun).
- Declined a blanket `schtasks *` approval — `schtasks` also creates/changes/deletes tasks, so it stays per-invocation to preserve guardrail #1.

## 2026-07-22 — REGISTER: Kalshi observation collector scheduled, production accrual started
**Type:** Standing-config change + first-ever production write (new table)
**Status:** E4 — AI-executed under Architect approval, pending ratification (Invariant 3)
**Session:** Second Claude Code session (Priority 1.5: register Kalshi collector). Follows the P1 finding (vault c7e2aeb) that it had never been scheduled.
**Decision:** Register now on the proven CLI pattern (InteractiveToken + LeastPrivilege, "Interactive only", RunAs rjkir) to stop the bleed; the survives-logout question is deferred to P2. A working schedule accruing data beats a perfect one not yet running.
**Safety before write:** scripts/backup_db.py ran and verified BEFORE any production write (VACUUM INTO + integrity + row-count + hash, generation 5). Collector re-proven clean on a throwaway DB (60/60 observations, exit 0); scratch DB deleted. First-ever write to a new kalshi_observations table.
**Registered:** WeatherPipeline_Kalshi under \WeatherPipeline\, via `schtasks /Create /XML scheduler\WeatherPipeline_Kalshi.xml /TN "WeatherPipeline\WeatherPipeline_Kalshi" /RU rjkir /IT`. Trigger: CalendarTrigger + ScheduleByDay (DaysInterval=1) + Repetition Interval=PT5M, no Duration → indefinite 5-min cadence (matches config cadence_minutes: 5). MultipleInstancesPolicy=IgnoreNew, ExecutionTimeLimit=PT10M, WakeToRun=true, RunOnlyIfNetworkAvailable=true. Committed export scheduler/WeatherPipeline_Kalshi.xml (UTF-16LE, matching the other four; pipeline commit <cb66381>).
**Verified firing (not just registered):** first fire 2026-07-22T02:44:50Z (10:44:50 PM local), Last Result 0 after completion (transient SCHED_S_TASK_RUNNING correctly distinguished from failure). Production pipeline.db kalshi_observations table now exists: 60 rows, 12 per city × 5 cities, dual fetch timestamps, collector_version='1'. Next fire queued (10:50 PM) — recurring cadence confirmed, not a one-off. New logs/kalshi_obs_*.log with exit 0.
**Consequence closed:** production accrual has started. The zero-accrual gap since 2026-07-19 is ended (that lost window remains permanently unrecoverable).
**Still open (P2):** InteractiveToken means collection runs only while logged in — a silent-stoppage risk on logout. The survives-logout logon-pattern decision (Backup-style Password logon vs CLI InteractiveToken) is deferred to P2 and may re-register all collectors together.
### AI PROCESS NOTES (KT Rank 5)
- Backup-first held (guardrail #2) before the first production write; no write until the scratch-DB run was clean.
- schtasks kept per-invocation approval (never blanket-allowed), since the same verb creates/changes/deletes.
- STOP 3 verified real rows by timestamp, not "task registered" — the P1 false-success lesson applied. The transient task-running status code was distinguished from a failure code by re-checking after completion.