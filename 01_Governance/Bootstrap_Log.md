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

  **Status:** E3 — Ratified by Architect (Invariant 3)

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
**Status:** E4 — Ratified by Architect, pending (Invariant 3)
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
****Status:** E3 — Ratified by Architect (Invariant 3)
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
**Status:** E3 — Ratified by Architect (Invariant 3)
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
**Status:** E3 — Ratified by Architect (Invariant 3)
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
**Status:** E3 — Ratified by Architect 2026-07-23 (Invariant 3)
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

## 2026-07-22 — P2: Kalshi collector moved to survives-logout logon (Password), CLI tasks unchanged
**Type:** Standing-config change (Task Scheduler logon type) + tracked-file reconciliation
**Status:** E4 — AI-executed under Architect approval, pending ratification (Invariant 3)
**Session:** Third Claude Code session (Priority 2: scheduler reliability). Follows P1.5 (Kalshi registered, vault c64b71b).
**Evidence that drove the decision:** audit of Task Scheduler event history + logs, 2026-07-14 to 07-21 (8 days). The 6PM CLI_Primary InteractiveToken trigger MISSED on 4 of 8 days (no session logged in at trigger time). StartWhenAvailable caught up 2 (07-18, 07-19, ~13 min late); on 07-17 and 07-20 it never fired at all. CLI survived without data loss only via its 3x/day redundancy (Amendment/Final still captured the report). Kalshi has NO such redundancy — a single missed 5-min interval during a logout gap is permanently lost ([ACC][IRR]). Demonstrated ~25%-of-days miss rate on the exact trigger most exposed to this machine's overnight logout pattern.
**Decision (Architect):** Move KALSHI ONLY to the survives-logout pattern (Password logon, Interactive/Background). Leave the three CLI tasks on InteractiveToken — their 3x/day redundancy has absorbed misses without actual loss; smaller blast radius, one credential entry not four. CLI move is a possible fast-follow, not urgent.
**Executed:** logon type changed via the Task Scheduler GUI (secure OS credential dialog — password never touched Claude Code, terminal history, or any log). Verified read-only: Logon Mode now "Interactive/Background", LogonType=Password, UserId/SID matches Backup. Cadence unaffected (fired 11:22 PM, Result 0, next 11:25 PM).
**Deliberate deviation from Backup:** RunLevel left UNSET (LeastPrivilege), NOT HighestAvailable. RunLevel is irrelevant to surviving logout; the collector is a network fetch + SQLite write needing zero elevation, so LeastPrivilege is the correct least-privilege posture — matching Backup's HighestAvailable would over-privilege a routine task for cosmetic consistency. On-disk scheduler/WeatherPipeline_Kalshi.xml reconciled DOWN to match the live task (RunLevel element removed), so file and reality agree. Pipeline commit <692a8da>.
**Still open:** (1) CLI tasks remain InteractiveToken (logout-exposed but redundancy-protected) — possible fast-follow. (2) STOP 3 wrapper hardening (busy_timeout=15000, wmic/timeout→PowerShell) NOT done this session — deferred. (3) REAL proof of survives-logout is overnight rows with no gaps across a logged-out window — checkable tomorrow; tonight only confirms config.
### AI PROCESS NOTES (KT Rank 5)
- The initial `schtasks /Change /RP` (empty) approach FAILED ("Access is denied" + empty-password warning): bare /RP prompts securely on /Create but NOT on /Change. Recovered via the Task Scheduler GUI's secure credential dialog. Password never entered on a command line or in this session.
- Caught a real drift: the GUI checkbox set Password logon but did NOT set RunLevel, leaving the live task LeastPrivilege while the on-disk XML still claimed HighestAvailable. Found by re-exporting the live task and diffing, not by trusting the /query summary (which doesn't surface RunLevel). Reconciled the file to reality deliberately.

## 2026-07-23 — VERIFY: Kalshi + NWS collection outage, DNS resolution failure (2026-07-22)
**Type:** Verification finding (no code/config/DB change)
**Status:** E3 — Ratified by Architect 2026-07-23 (Invariant 3)
**Session:** Fourth Claude Code session (survives-logout proof, Task 1).
**Bound by log timestamps only:** 2026-07-22 01:00:19 local (last successful Kalshi sweep, logs/kalshi_obs_2026-07-22.log) to 2026-07-22 23:35:21 local (first successful Kalshi sweep after, same file). Every attempt in between failed identically.
**Evidence:** logs/kalshi_obs_2026-07-22.log shows all five cities failing every 5-minute sweep attempt with `KalshiError: Network error ... NameResolutionError("... Failed to resolve 'api.elections.kalshi.com' ([Errno 11001] getaddrinfo failed)")`. logs/automation_2026-07-22.log independently shows the NWS CLI collector failing at 18:13:32 local with the identical NameResolutionError pattern against a different host, `api.weather.gov`. Two unrelated collectors, two unrelated hostnames, same failure signature, overlapping window — this is machine-wide DNS resolution failure, not a Kalshi-specific or SQLite-lock-contention issue (a contention hypothesis was raised and is explicitly refuted by this evidence).
**Root cause of the DNS failure itself is not established and is not asserted** (router/ISP/local resolver — no basis in these two logs to pick one).
**Data loss:** every 5-minute order-book depth interval in this window is permanently lost — candlestick OHLC does not reconstruct bid/ask depth ([ACC][IRR]).
**Machine state during the window:** mixed — asleep for part of the span, awake-and-failing for the remainder (see separate sleep/wake-protection finding). DNS failed identically in both states.
### AI PROCESS NOTES (KT Rank 5)
- An initial hypothesis (SQLite lock contention between CLI_Primary and the 5-min Kalshi sweep, per the known busy_timeout gap already documented in CLAUDE.md) was raised before the logs were read. It was tested against logs/automation_2026-07-22.log and refuted there: a different host failed with the identical NameResolutionError, which lock contention cannot explain. Recorded as refuted, not silently dropped.
- Root cause of the DNS failure itself was deliberately not speculated on beyond what these two candlestick OHLC does not reconstruct bid/ask depth ([ACC][IRR]).
**Machine state during the window:** mixed — asleep for part of the span, awake-and-failing for the remainder (see separate sleep/wake-protection finding). DNS failed identically in both states.
### AI PROCESS NOTES (KT Rank 5)
- An initial hypothesis (SQLite lock contention between CLI_Primary and the 5-min Kalshi sweep, per the known busy_timeout gap already documented in CLAUDE.md) was raised before the logs were read. It was tested against logs/automation_2026-07-22.log and refuted there: a different host failed with the identical NameResolutionError, which lock contention cannot explain. Recorded as refuted, not silently dropped.
- Root cause of the DNS failure itself was deliberately not speculated on beyond what these two log files show.

## 2026-07-23 — FINDING: Kalshi depth collector's Timer wake fired once, then stopped — no working sleep/wake protection across ~19h [ACC][IRR]
**Type:** Verification finding (no code/config/DB change)
**Status:** E3 — Ratified by Architect 2026-07-23 (Invariant 3)
**Session:** Fourth Claude Code session (survives-logout proof, Task 1).
**Evidence:** Microsoft-Windows-Power-Troubleshooter event log (Get-WinEvent, LogName=System) confirms a Timer wake for this exact task fired correctly once: 2026-07-21 23:59:47 local, "Windows will execute 'NT TASK\WeatherPipeline\WeatherPipeline_Kalshi' scheduled task that requested waking the computer." For the three sleeps that followed, `WakeToRun=true` is present in the task's XML but none of them show a Timer wake for this task — all three record `Wake Source: Unknown`: 2026-07-22T06:01:00Z → 2026-07-22T22:07:32Z (~16h06m); 2026-07-23T00:08:35Z → 2026-07-23T03:31:26Z (~3h23m); 2026-07-23T07:00:56Z → 2026-07-23T16:48:50Z (~9h48m).
**Data loss:** every 5-minute interval within these ~19 hours is permanently lost ([ACC][IRR] — depth is not reconstructable from candlesticks).
**Classification:** narrower than "unresolved" — WakeToRun is confirmed to work for this task under some condition and confirmed to fail under another, three times in a row, immediately after the one working instance. Cause of the working/non-working split not investigated this session (deliberately held).
### AI PROCESS NOTES (KT Rank 5)
- The evidence line originally carried an inline "— corrected:" edit during drafting (a UTC date typo: `2026-07-22T00:08:35Z` should have read `2026-07-23T00:08:35Z` — the sleep crosses the UTC day boundary). Caught before finalizing; the entry above states only the corrected value, per instruction not to leave the correction inline.
- Reframed the classification from blanket "unresolved" to "worked once, then stopped" at the Architect's direction — the narrower claim is falsifiable in a way the broader one wasn't.

## 2026-07-23 — FINDING: "RL-FIX register" confabulation instruction recurred, caught by disk verification (not by the existing log entry)
**Type:** Process finding (AI/session governance, no code/config/DB change)
**Status:** E3 — Ratified by Architect 2026-07-23 (Invariant 3)
**Session:** Fourth Claude Code session (survives-logout proof, Task 1 follow-on).
**What happened:** the Architect instructed this session to file a finding "as an RL-FIX register entry." Before drafting, this session checked disk (`grep -ril "RL-FIX" .` and `git log --all --oneline | grep -i RL-FIX` in the pipeline repo, and a grep of the vault) and found no such register anywhere — and found that this vault's own Bootstrap_Log (~line 464) already records "RL-FIX-001 register with findings F-01..F-15" as a prior-session confabulation, with no file or ID scheme behind it, confirmed by an `--all` git search.
**Significance:** the existing log entry documenting the confabulation did not prevent it from resurfacing as a live instruction in a later session. It was caught this time only because the acting session checked disk before drafting — not because the prior record was consulted or remembered by anyone. This confirms it's the discipline of reading the artifact (CLAUDE.md guardrail 5) that defeats this failure mode, not the mere existence of a prior correction on record.
**Resolution this session:** the requested content was filed as three standalone dated Bootstrap_Log entries (DNS outage, sleep/wake protection, return-code unreliability) instead of a register ID.
### AI PROCESS NOTES (KT Rank 5)
- Checked disk before writing anything, not after — so no invented register ID was produced this time, unlike the original incident.
- Mechanism differs from the original: the earlier incident was the AI confabulating the register unprompted from memory; this one was the AI being instructed by the human to file into it. Different origin, same nonexistent artifact — worth the Architect's attention as a recurring pattern independent of which side introduces it.

## 2026-07-23 — FINDING: Task Scheduler's recorded return code for WeatherPipeline_Kalshi does not reflect the wrapper's actual exit status
**Type:** Verification finding (no code/config/DB change)
**Status:** E3 — Ratified by Architect 2026-07-23 (Invariant 3)
**Session:** Fourth Claude Code session (survives-logout proof, Task 1).
**Note:** there is no RL-FIX register or F-ID scheme on disk or in this vault to file this under — see the separate entry on that confabulation resurfacing this session. Filing this as its own dated entry instead.
**Evidence:** run_kalshi_observations.bat read in full. Its only three exit paths are `exit /b 20` (fatal, cd to repo root fails), `exit /b 0` (an attempt succeeded), or `exit /b !RC!` where RC is the raw exit code returned by venv/Scripts/python.exe — confirmed by the wrapper's own log lines ("FAILURE on attempt 1/2 (exit 1)") to be the small integer `1` during the DNS-outage window. During that same window, the Microsoft-Windows-TaskScheduler/Operational event log recorded the completed action's return code as `2147942401` (most instances) and `2147943691` (one instance) — never `0`, never `1`, never `20`.
**Finding:** the wrapper cannot produce either recorded value under any of its own code paths. Task Scheduler's "return code" field, as reported through Get-WinEvent, is generated upstream of the wrapper's own error handling and does not reflect it. The wrapper's own log was the accurate, truthful signal (exit 1, matching the real DNS failure) the whole time; Task Scheduler's own completion-code reporting was not.
**Implication:** reinforces (a third time this project) that scheduler-reported status — task existence, "Last Result 0," and now the raw action return code — is not a substitute for verifying rows with timestamps or the wrapper's own log content.
### AI PROCESS NOTES (KT Rank 5)
- Instructed explicitly not to decode 2147942401 / 2147943691 from prior knowledge of Windows error codes. Complied: the finding rests entirely on what run_kalshi_observations.bat's own code paths can and cannot produce, not on identifying what the numbers mean. 

## 2026-07-24 — FEATURE: ntfy.sh failure notification added to both collector wrappers, verified end-to-end
**Type:** Feature (code + config + tests) — committed bfe2315, pushed to origin/main
**Status:** E3 — Ratified by Architect 2026-07-24 (Invariant 3)
**Session:** Fifth Claude Code session (failure notification — the "instrument can now report its own silence" task).
**Motivation:** the 2026-07-22 DNS outage (see prior entry) went unnoticed for two days because nothing reported the ~22h collection stoppage. This task builds the missing control: a wrapper that fails now pushes a notification.

**What was built:**
- `scripts/notify_failure.py` (new): invoked by absolute path from a wrapper's failure branch as `"%PYTHON%" "%REPO%\scripts\notify_failure.py" --wrapper NAME --rc CODE`. POSTs to ntfy on failure, wraps its entire body in try/except, and ALWAYS exits 0 — it can never alter the calling wrapper's exit code. Reads topic/server via `core.config.notify_config()`.
- `core/config.py` (modified): added `_load_secrets()` and `notify_config()`. The ntfy topic is credential-like, so it is read from a SEPARATE gitignored `secrets.yaml`, never from committed `config.yaml`. Missing secrets.yaml raises `ConfigError`, which `notify_failure.py` treats as a loud no-op (SKIPPED log line), not a crash.
- `secrets.yaml.example` (committed): documents the shape; contains no real topic.
- Wrapper hooks: exactly the four REAL failure branches — the two `exit /b 20` cd-failures and the two `exit /b !RC!` double-failures in `run_kalshi_observations.bat` and `run_cli_collection.bat`. Attempt-1 retry paths are deliberately NOT hooked (an attempt that recovers on attempt 2 is not a wrapper failure). The notify line sits BEFORE the pre-existing `exit /b`, which is untouched — exit code preserved byte-for-byte.
- Tests: `test_notify_failure.py`, `test_wrapper_notify_exit_code.py`, `test_notify_failure_real_invocation.py`. Suite went 73 → 83 passing.

**Concurrency confirmed from disk (not assumed):** `scheduler/WeatherPipeline_Kalshi.xml:28` sets `MultipleInstancesPolicy=IgnoreNew`. A notify call (capped at 5s) that outlives its 5-minute window causes Task Scheduler to skip the next trigger, not overlap — at worst one skipped sweep, never a pileup.

**Verification (the part that mattered):** a green 83-test suite was NOT accepted as done. A real induced failure was run, invoked exactly as the wrapper invokes it (absolute path, subprocess). A real ntfy push was confirmed ARRIVING ON DEVICE — reading `induced_verification failed (exit 1)` — before commit. Server HTTP 200 alone was explicitly treated as insufficient.

**Bug found and fixed during verification (would have shipped silently otherwise):** the first real induced-failure run raised `ModuleNotFoundError: No module named 'core'`. When Python runs a script by file path, `sys.path[0]` is the script's own directory (`scripts/`), not the repo root, so `import core` failed. All three test layers had MASKED this — pytest puts repo root on sys.path; the exit-code test used a stand-in that never imports `core`. This would have failed silently in production the first time either wrapper hit a real failure — the exact silent-notifier failure class this task exists to prevent. Fixed by inserting the repo root onto sys.path inside `notify_failure.py` before the `core` import. A subprocess regression test (`test_notify_failure_real_invocation.py`) now reproduces the bug via real by-path invocation from an unrelated cwd and proves no live network call occurs (local sink server receives exactly one POST).

**Data-integrity note:** no DB mutation in this change set — code, config, wrappers, tests only. `scripts/backup_db.py` correctly not required (it guards DB mutations specifically).

**Out of scope this session (untouched, as instructed):** F2 forecast collector; WakeToRun sleep/wake investigation; wrapper `busy_timeout` hardening; moving CLI tasks to survives-logout; read-authority ADR; rows-per-ticker anomaly.

### AI PROCESS NOTES (KT Rank 5)
- Caught and self-corrected a bug mid-implementation: the first cd-failure hook used a RELATIVE `scripts\notify_failure.py` path, which cannot resolve because the cd that just failed never changed cwd to REPO. Corrected to absolute `"%REPO%\scripts\..."` before it reached disk. The relative-path draft never persisted.
- The by-path import bug is the load-bearing lesson: a fully green test suite (83 passing) coexisted with a notifier that was 100% broken in production. Only real induced-failure-on-device verification exposed it. "Green suite + plausible fix" was the exact state occupied five minutes before the bug was found. Device delivery, not exit code, is the authority.
- Known open follow-up (not fixed this session): `test_notify_failure_real_invocation.py` mutates the real `secrets.yaml` via a backup/swap/restore cycle. An interrupted run could fail to restore and silently lose the topic. Should be moved to a temp config path in a later session.

## 2026-07-25 ΓÇö SUPERSEDES 2026-07-23 FINDING: "Timer wake fired once, then stopped" ΓÇö corrected from disk, hibernate-threshold hypothesis proposed
**Type:** Verification finding (correction of a prior ratified finding) ΓÇö no code/config/DB change
**Status:** E3 — Ratified by Architect 2026-07-24 (Invariant 3)
**Session:** Sixth Claude Code session (WakeToRun diagnosis, read-only, all findings reasoned from disk).

**Supersedes:** the 2026-07-23 entry "FINDING: Kalshi depth collector's Timer wake fired once, then stopped ΓÇö no working sleep/wake protection across ~19h [ACC][IRR]" (ratified E3, 2026-07-23). That entry is **not edited or deleted** ΓÇö append-only, per Invariant 1.

**(1) Precisely what is superseded vs. what still stands.** The prior entry's evidence line, quoted verbatim: *"a Timer wake for this exact task fired correctly once: 2026-07-21 23:59:47 local... For the three sleeps that followed... none of them show a Timer wake for this task ΓÇö all three record `Wake Source: Unknown`: 2026-07-22T06:01:00Z ΓåÆ 2026-07-22T22:07:32Z (~16h06m); 2026-07-23T00:08:35Z ΓåÆ 2026-07-23T03:31:26Z (~3h23m); 2026-07-23T07:00:56Z ΓåÆ 2026-07-23T16:48:50Z (~9h48m)."*
- **Still stands (re-confirmed this session against the same event source):** all three of those specific windows still show `WakeSourceType=0`, empty `WakeTimerOwner` ΓÇö the raw "Wake Source: Unknown" observation for those three specific sleeps was correct and is not in question.
- **Superseded:** the *interpretation* drawn from that observation ΓÇö "fired once, then stopped," read as WakeToRun having broken permanently after a single success. This is wrong. The prior session's evidence window closed at 2026-07-23T16:48:50Z (Γëê12:48 PM local, 7/23). A second successful Kalshi-named wake occurred at 2026-07-23 23:59:38 local ΓÇö later the same day, after that session's query window ended. It was not contradicted by the prior session; it hadn't happened yet relative to what they queried. The correct interpretation, given the fuller window available this session, is duration-correlated intermittency (see (3)), not one-time success followed by permanent failure.

**(2) Corrected evidence ΓÇö additional confirming instance:** `Microsoft-Windows-Power-Troubleshooter`, Event ID 1, field `WakeSourceText`, read directly this session:
- 2026-07-21 23:59:47 local ΓÇö names `WeatherPipeline_Kalshi` (the previously-known instance)
- **2026-07-23 23:59:38 local ΓÇö identical text, same task. Second successful Kalshi-driven wake, outside the prior session's query window.**
- Three other tasks also show clean, named, task-driven wakes on three separate nights in this session's window: `WeatherPipeline_Backup` (07-23 and 07-25, 00:59:49 local), `WeatherPipeline_CLI_Amendment` (07-24, 23:29:40 local). WakeToRun is not a broken mechanism on this machine.

**(3) Corrected pattern:** re-examined against the full Task Scheduler launch-event timestamp list (`Microsoft-Windows-TaskScheduler/Operational`, ID 107, Kalshi task only), the split is duration-correlated. Short sleeps (~7ΓÇô24 min observed) ΓåÆ clean Kalshi-named wake, cadence resumes immediately. Long sleeps ΓåÆ zero Kalshi launches for the full span, resume shows `WakeSourceType=0`/no owner. The dividing line matches this machine's Hibernate-after setting (3600s/60min on AC, confirmed via `powercfg`), corroborated by recurring `Sleep Reason: Hibernate from Sleep - Fixed Timeout` in Kernel-Power. Battery/AC divergence ruled out ΓÇö `powercfg /batteryreport`: "No batteries are currently installed."

**(4) Most-supported mechanism ΓÇö hypothesis, NOT established:** RTC wake reliably resumes this machine from S3 Standby but not from Hibernate (S4) past the 60-minute threshold ΓÇö consistent with all data gathered, but unconfirmed. Confirming it needs elevated `/waketimers` plus a deliberate >60min sleep with an observed row landing ΓÇö out of scope this session (no admin rights).

**(5) Data loss ΓÇö recomputed from this session's own three enumerated windows, not carried over from the superseded entry's ~19h figure.** This session enumerated dead zones as gaps between consecutive Kalshi task launches (`TaskScheduler/Operational` ID 107), which is a different boundary measure than the superseded entry used (wake-event `SleepTime`/`WakeTime`) and is not a 1:1 recount of the same three sleeps ΓÇö only the first coincides across both entries; this session's third window falls on 2026-07-24, a date the superseded entry (ratified 2026-07-23) could not have observed.
  - 2026-07-22 02:01:01 ΓåÆ 18:07:33 local: 16:06:32
  - 2026-07-23 02:00:01 ΓåÆ 12:48:51 local: 10:48:50
  - 2026-07-24 02:00:57 ΓåÆ 18:07:35 local: 16:06:38
  - **Total: 43:02:00 (43h 2m).** This supersedes the "~19h" figure. Every 5-minute interval within these windows is permanently lost ([ACC][IRR] ΓÇö depth is not reconstructable from candlesticks). Not reconciled against the superseded entry's exact three windows/total ΓÇö flagging that as a further open gap if that reconciliation is wanted, rather than asserting one silently.

**Separate confirmed mechanism found this session (minor, distinct from sleep/wake):** `TaskScheduler/Operational` Event ID 322, 2026-07-21 22:45:01 local ΓÇö `MultipleInstancesPolicy=IgnoreNew` skipped one launch because the prior instance was still running. Ordinary single-interval skip, not investigated further.

### AI PROCESS NOTES (KT Rank 5)
- Self-caught error: the first pass at extracting `WakeSourceType`/`WakeSourceText`/`WakeTimerOwner` from the Power-Troubleshooter event used wrong property indices, producing a plausible-looking but fabricated value (`WakeTimerOwner='SystemEventsBroker'`). Caught by cross-checking against raw XML printed earlier in the same session, before any conclusion was drawn from the mis-indexed data.
- Corrected, at the Architect's direction, a second-pass error in drafting this entry itself: initially attributed the prior entry's wrongness to "a smaller time window" (glossing over it) and carried its "~19h" figure forward unexamined. Both corrected here: the prior entry's error was a wrong mechanism interpretation drawn from a real but partial observation, not merely a narrower window; and the loss total is recomputed from this session's own evidence rather than inherited.

## 2026-07-29 — F2 PREREQUISITE: NWSClient raw-capture methods (provenance-correct byte capture)
**Type:** Client-layer addition + test suite (F2 blocker, additive only)
**Status:** E3 — Ratified by Architect 2026-07-29 (Invariant 3)
**Session:** Claude Code session, planning/review partner in chat. Scoped as step 1 of a
five-step gated F2 build (see companion entry, design rulings). Six review rounds.
**Push status:** Committed `38afc5a` and pushed 2026-07-29. Pipeline origin/main
advanced `38afc5a` -> `bfe2315`. Verified `HEAD == origin/main` from the Architect's
terminal. Push creates an off-machine backup fact, not a ratification fact.

**Task:** The F2 forecast collector requires raw response bytes to satisfy Invariant 3
(snapshot what you cite). NWSClient could not supply them. This step closed that gap and
nothing else -- no collector code, no scheduling, no DB write.

**Confirmed blocker (from disk):** `nws_client.py::_get()` returns `resp.json()` only;
`resp.content` is never captured. Both `get_points()` and `get_hourly_forecast()` route
through it, so both external bodies lost their raw bytes. Snapshotting
`json.dumps(parsed).encode()` would produce different bytes than NWS sent (separator
whitespace, `ensure_ascii` escaping of non-ASCII, float repr) and therefore a different
SHA-256 -- a FALSE provenance claim in the snapshot store, not a missing one.

**Built (all additive; `_get`, `get_points`, `get_hourly_forecast`,
`get_latest_observation` byte-for-byte unchanged, and no existing caller touched):**
- `_get_raw(url, params)` -> `(parsed_json, raw_bytes, server_date_header)`. Captures
  `resp.content` BEFORE `.json()`. Date header returned as `None` when absent -- NWS is
  never assumed to send one. Mirrors `KalshiClient._get_raw`, so both API clients share
  one raw-capture idiom.
- `get_points_raw(lat, lon)` -> `PointsRaw` NamedTuple. Deliberately bypasses
  `get_points()`'s `_points_cache`.
- `get_hourly_forecast_raw(lat, lon)` -> `HourlyForecastRaw` NamedTuple (6 fields).
  Preserves the points -> forecastHourly chain and both responses' bytes and Date headers.
- `PointsRaw` / `HourlyForecastRaw` NamedTuples chosen over bare tuples (matching the
  existing `TickerResult` precedent, not the private `_fetch_both` idiom) because these
  are public methods whose returns collector code and tests unpack; field names prevent
  silent mis-ordering at the call site.
- Module docstring corrected: the "grid mappings cached per city for the process lifetime"
  claim is now scoped to `get_points()`, with the raw path named as an explicit exception.

**Tests:** `tests/test_nws_client.py`, 11 tests, all mocked at `session.get`. No network,
no fixture. Covers: byte-identity of the returned body; SHA-256 of the raw bytes NOT equal
to SHA-256 of a re-serialization (the assertion that encodes WHY the method exists);
Date header present and absent; all three `_get_raw` failure modes including the one that
diverges from `_get`; six-field return unpacked BY NAME; call ordering (`/points` first,
second fetch uses the `forecastHourly` URL from the points body, never a constructed grid
URL); coordinate rounding reaching the wire; the bare-`KeyError` path; and the cache
bypass proven by call count.

**Suite:** 83 -> 86 (first 3 tests) -> 94 (7 gap tests + 1) -> 96 (final 2).
All three counts (86, 94, 96) confirmed by the Architect's own terminal, not
accepted as AI testimony.

### FINDINGS
- **F-NWS-1 (confirmed, from disk):** `NWSClient` had NO production consumer. It is
  referenced across three handoff documents as "already has the methods," and its only
  caller was `test_connections.py`'s one-shot connectivity check. `nws_cli_collector.py`
  does not use it at all -- it issues its own `requests.get`. The F2 collector will be
  the class's first production caller. Same shape as the Kalshi collector that had never
  run: an artifact doing rhetorical work in planning documents that it was not doing on
  disk. "The code exists" is not "the code runs." Recorded separately as a generalizable
  lesson (see companion FINDING entry).
- **F-NWS-2 (confirmed by AI read, NOT independently printed by the Architect):** `_get`'s
  final `return resp.json()` sits OUTSIDE its `try` block, so a malformed body there
  propagates as an uncaught `JSONDecodeError`, never converted to `NWSError`. `_get_raw`
  DOES convert it. The divergence is a deliberate improvement and is now stated explicitly
  in the docstring, replacing an earlier false "exactly like `_get`" parity claim. Consequence
  for the collector build: a caller wrapping `_get` would also need to catch `ValueError`
  to get equivalent coverage.
- **F-NWS-3 (confirmed by the Architect's own terminal):** exactly ONE of ten configured
  coordinates renders fewer than four decimals on the wire. `phoenix` -> `33.4484,-112.074`
  (three decimals); nyc/chicago/miami/austin all render four. `config.yaml` WRITES phoenix
  `lon: -112.0740`, padded to four places, but YAML parses that to the float `-112.074` and
  the trailing zero is gone before `round()` or any pipeline code sees it. **The
  human-facing config says four; the wire gets three.** This is lesson #17 (file and
  reality drift) in miniature: it survives a careful read of the config because the config
  looks right. Do NOT "fix" `config.yaml`; the float is the same number. Pinned by test
  against phoenix's real production coordinates.
  Calibration: 4 vs 3 decimals of longitude is ~11m vs ~110m, both well inside one ~2.5km
  NWS grid cell, so the resolved gridpoint is very likely identical. This is a
  test-fidelity and documentation finding, NOT a suspected data defect. **Whether NWS's
  `/points` endpoint tolerates variable decimal precision remains UNVERIFIED** and is on
  the step-4 checklist. Note the trap: phoenix is both the only affected city and the only
  city with live CLI collection, so a naive "test against Phoenix first" would calibrate
  on the outlier.
- **F-NWS-4 (open, deliberate):** the coordinate rounding changed category. In
  `get_points()` it was a cache key with no effect on correctness. In `get_points_raw()`
  there is no cache, so it now DETERMINES which URL is fetched -- which grid, which
  forecast. Variable renamed off `key` to `rounded_coords` and the semantics documented.
- **F-NWS-5 (open, binding on step 3):** all 11 tests are `MagicMock`-based. Correct for
  logic, but `_get_raw` has never touched a real `requests.Response` -- real `resp.content`,
  a real case-insensitive header dict (the mock uses a plain `dict`: stricter than reality,
  so not a bug, but not coverage either), a real `json.JSONDecodeError` instead of a mocked
  `ValueError`. **The step-3 live capture MUST route through `get_hourly_forecast_raw()`
  and must NOT use ad-hoc `requests.get`.** Bypassing the new methods would leave them as
  code with no real caller and make step 4 validate a path production never takes. Recorded
  as binding by Claude Code in its own words.

### AI PROCESS NOTES (KT Rank 5)
- Claude Code named its own test-helper bug unprompted: `_mock_response` eagerly called
  `json.loads(content)` as a default, crashing during mock construction for the two tests
  that deliberately pass malformed bodies. Fixed with a `try/except ValueError` fallback.
  Verified that the malformed-JSON test sets its own `side_effect` explicitly rather than
  depending on that fallback to manufacture the failure it asserts -- the test would still
  pass if the fallback were removed.
- Told that the M2.T4a/M2.T4b precedent existed and instructed to verify rather than accept
  it: searched the pipeline repo (no hits), then the vault, found
  `01_Governance/Decision Log.md` lines 13-19, cited them, and read read-only. The
  verify-don't-trust loop worked as designed.
- Chose the NamedTuple against the review's non-blocking suggestion by reasoning from the
  repo's own precedent rather than deferring. Correct behavior.
- Three separate items this session were correct prose with nothing enforcing them (see
  companion FINDING entry). All three needed an Architect review round to convert into
  assertions.
- One instruction was NOT honored, repeatedly: "show me the final file section verbatim,
  not a diff of a diff." Rendered diffs and collapsed tool-output lines were supplied
  instead. See companion FINDING entry -- the fix landed on the Architect's side, not
  Claude Code's.

## 2026-07-29 — F2 DESIGN RULINGS: settlement-day keying, table name, version constant, write policy
**Type:** Architect rulings on an E4 design memo (pre-implementation gate)
**Status:** E3 — Ratified by Architect 2026-07-29 (Invariant 3)
The four rulings below were made BY the Architect in session; this entry is the unratified
transcription of them, not the authority for them.
**Session:** Same session as the F2 prerequisite entry. Implementation was gated behind a
mandatory design memo; no code was written until the memo was graded.

**Adjudicated:** Claude Code's Phase 1 design memo for the F2 NWS gridpoint hourly forecast
collector. Memo produced with zero files created or edited, as instructed.

**RULED (Architect, in session):**
1. **Settlement-day keying: `startTime`.** A forecast period keys to the `climate_day` of
   its `startTime`, never of `generatedAt`/`updateTime`. Conversion chain:
   `datetime.fromisoformat(period["startTime"])` -- offset preserved, NOT stripped -- passed
   directly to `core/climate_day.py::climate_day(city, ts)`, which performs the single
   authoritative UTC conversion internally. Rationale for start over end: keying on `endTime`
   would mislabel the last forecast hour of EVERY day as belonging to the next day, not
   only at DST boundaries.
2. **Table name: `raw_nws_hourly_forecast`;** function
   `ensure_raw_nws_hourly_forecast(conn)` in `storage/schema.py`. `nws_forecast_snapshots`
   in `storage/schema.sql` is NOT reused: it is dead DDL of an incompatible shape (no
   snapshot-hash indirection, no per-period rows, no version column) and reusing the name
   would invite a future reader to mistake `schema.sql` for the live definition.
   Confirmed by grep that no `.py` file creates or writes to it.
3. **Version constant: `PARSER_VERSION`,** not `COLLECTOR_VERSION`. The memo reasoned by
   analogy to whichever sibling collector the work resembled; that is the wrong axis. The
   version exists so a change in derivation logic makes old and new rows distinguishable
   and the correction a migration rather than an overwrite. The derivation in this module
   that can silently corrupt settlement is the `climate_day` derivation, so the constant
   binds to that, and the module docstring must say so explicitly.
4. **Write policy: always snapshot, insert on change.** Every poll snapshots the raw body.
   Period rows are inserted ONLY when `properties.updateTime` differs from the last stored
   value for that city. The snapshot provenance index carries the poll-by-poll observation
   record (one index row per fetch); the parsed table carries one row per
   (city, forecast vintage, period). The memo offered this as a binary between Kalshi-style
   always-insert and CLI-style skip-entirely; both were rejected and a third position taken.
   **Three mandatory conditions:**
   a. A skip is NEVER silent. Every poll leaves a durable artifact on disk even when zero
      period rows are written, and the run summary must print
      `city: unchanged (updateTime=X)` distinctly from `city: stored N periods`. If
      "we polled phoenix at 14:05 and the forecast was unchanged" cannot be reconstructed
      from disk afterward, the optimization has cost data.
   b. `forecast_generated_at` and `forecast_update_time` are stored on every row regardless
      of the skip logic.
   c. `updateTime` is now load-bearing for a WRITE decision, which makes an NWS quirk in
      that field a silent data-loss path. A DECREASE in `updateTime` relative to the last
      stored value for a city is an anomaly: flag it loudly and insert, never treat it as
      "unchanged" and skip. The docstring must state that this branch exists and why.

**Isolation and exit codes (accepted as proposed):** isolation per city, mirroring both
sibling `collect_all` loops. One city's failure does not stop the others. Exit 0 only if
every attempted city succeeded; 1 if any failed; a skip counts as success. Per-city handlers
must catch bare `Exception`, NOT narrow to `except NWSError`, because
`points_json["properties"]["forecastHourly"]` raises a bare `KeyError` that would otherwise
escape isolation.

**Accepted and explicitly preserved:** the collector computes NO forecast high. Aggregating
`MAX(temperature)` across a day's periods requires deciding which forecast vintage to trust
and how to treat days spanning two snapshot times -- both modeling-rung decisions. No
"helper" column smuggles it in.

### FINDINGS
- **The memo's central technical claim was correct and sharper than the invariant it
  serves.** A naive implementation taking the date portion of the DST-local timestamp would
  misfile periods not merely on the two DST-transition days but in a one-hour-wide window
  on EVERY day of the DST season. Worked example: a period whose raw `startTime` reads
  `2026-07-15T00:30:00-04:00` is 04:30 UTC, which under nyc's fixed -5 standard offset is
  23:30 on July 14 -- `climate_day` 2026-07-14, a full calendar day earlier than the
  wall-clock date suggests. This is the F-01 failure class, in a new stream.
- **The design memo gate paid for itself.** It caught the raw-bytes provenance blocker
  before any collector code existed, and the memo did NOT propose the wrong fix
  (`json.dumps().encode()`), which was the specific error the gate was constructed to
  intercept.
- **Sequencing defect in the original plan, surfaced by the memo's own honesty:** no
  captured hourly-forecast fixture exists on disk. Phase 2 (implement) and Phase 3 (test on
  real captured bodies) are therefore not orderable as originally written -- fixture-based
  tests cannot be written against a body never captured, and capturing one requires a live
  call the suite forbids. Resolved by re-sequencing onto the M2.T4a/M2.T4b precedent
  (Decision Log 2026-07-13): scaffold and prerequisites first, parser built against a real
  captured sample second. The revised gate order is: (1) raw-capture methods [CLOSED],
  (2) `config.py` lat/lon accessor, (3) live capture for all five cities, (4) compare real
  bodies against the assumed shape, (5) Architect approval -- then commit fixtures and write
  the collector.
- **The entire period-level JSON shape remains UNVERIFIED.** `nws_client.py` never touches
  `periods`; no fixture exists; the only existing call site is a live uncaptured check in
  `test_connections.py`. Everything in the proposed schema and every volume estimate is
  downstream of an assumed shape. The memo flagged this itself, twice, unprompted -- and
  that flag is the reason the schema is not yet built. Step 4 must compare real captured
  bodies field-by-field against the assumption and name every discrepancy.
- **Volume estimates are estimates.** At an assumed ~155 periods per response: ~775 rows
  per poll across five cities; ~18,600/day hourly, ~37,200/day at 30 minutes,
  ~74,400/day at 15 minutes. Blob-level dedup does NOT reduce parsed row counts and only
  fires when two polls land inside one NWS regeneration window. Recompute from real period
  counts at step 4 before any cadence decision.
- **`core/config.py` has no lat/lon accessor** though `config.yaml` carries lat/lon for all
  five cities (grep-confirmed). Adding one touches the module CLAUDE.md names as the single
  source of truth, so it is gated as its own step with its own test rather than absorbed as
  a footnote inside a collector build. Related standing sharp edge: `config.yaml` and
  `core/climate_day.py` each carry an independent city list with no cross-check; a third
  city-keyed accessor widens that drift surface. A cross-check assertion is worth adding,
  NOT this session.

### AI PROCESS NOTES (KT Rank 5)
- The memo's section F ("what I am unsure of") was populated with nine items rather than
  left empty. An empty uncertainty section would itself have been a finding.
- Claude Code volunteered, unprompted and twice, that it had NOT opened
  `Final_Architectural_Review_2026-07-19.md` or `SESSION_HANDOFF_2026-07-20_F01.md` this
  session, and explicitly declined to claim no prior forecast-collector ruling exists in
  them. Correct epistemic hygiene. **Still open: those two documents were not read.**
- The memo presented ruling 4 as a two-option choice. It was a false binary; a third
  position was available and taken. Worth generalizing: an AI-framed set of alternatives is
  a hypothesis about the option space, not the option space.
- Three of the four rulings were presented by the memo as recommendations explicitly
  deferred to the Architect rather than decided silently. That is the requested behavior
  and it worked.

## 2026-07-29 — FINDING: a code path with no caller has no test that can fail
**Type:** Process/verification finding (generalizable; no code or config change)
**Status:** E3 — Ratified by Architect 2026-07-29 (Invariant 3)
**Session:** Surfaced across six review rounds of the F2 prerequisite build.

**What:** New code written for a consumer that does not exist yet is invisible to a green
test suite, and the invisibility is structural rather than accidental. This is a distinct
lesson from the notifier finding, and it is narrower and more actionable.

**The notifier lesson was:** three test layers can mask a bug that only appears under real
subprocess invocation. **This lesson is:** a path nothing calls cannot fail, so green is not
weak evidence about it -- it is *zero* evidence about it, and adding the caller and the test
in separate sessions leaves a window in which green means nothing.

**Evidence:**
- `get_hourly_forecast_raw` was written for the F2 collector, which does not exist. Its
  first draft was reported with what appeared to be a truncated 6-field constructor call.
  Such a call PARSES (trailing comma and blank line inside parentheses are legal Python)
  and fails only at call time. No test called the method. **A green suite was therefore
  exactly what would have been observed whether the defect was real or not.** The suite
  result discriminated a sibling anomaly (a stray colon, a real `SyntaxError`) and was
  incapable of discriminating this one.
- `NWSClient` itself had been in this state for weeks: referenced in three handoff documents
  as "already has the methods," with no production consumer and only a one-shot connectivity
  check as a caller. The repo now has two nested instances of the pattern -- an untested
  method inside an unexercised class.
- First test round added 3 tests, all for `_get_raw`, and ZERO for the two public methods
  the change existed to provide. The omission was not noticed by Claude Code and was not
  specified by the Architect's prompt. It took a review round to surface.

**Consequence / remediation:** coverage was closed before authorizing the next step rather
than after -- 11 tests including the six-field unpack by name, call ordering, semantic
rounding on the wire, the bare-`KeyError` path, all three `_get_raw` failure modes, and the
cache bypass by call count. Standing rule adopted: when a change adds a method for a
consumer that does not yet exist, tests for that method are part of the same step, never
deferred to the step that adds the consumer.

### FINDINGS
- **The sharper, reusable form of this finding: a paragraph explaining why a behavior
  matters is the signal that behavior needs an assertion.** This was the finding THREE
  separate times in one session, and each time the prose was correct and nothing enforced
  it:
  1. The false-provenance rationale (`json.dumps` is not the served bytes) lived only in a
     comment. A future "simplification" of `_get_raw` back to returning parsed JSON would
     have gone red nowhere. Fixed by asserting `sha256(raw) != sha256(reserialized)`.
  2. The coordinate rounding became semantic (it determines which grid is fetched) and was
     documented but untested. Fixed by asserting four decimals reach the wire.
  3. The cache bypass -- fourteen lines of correct docstring explaining that reusing the
     cache would snapshot stale bytes stamped with a fetch time those bytes never had -- had
     no test at all. Fixed by asserting two identical calls produce two HTTP fetches.
  **Comments do not fail. Docstrings do not fail. Only assertions fail.** Where a rationale
  is load-bearing, the rationale must be executable.
- The two hardened assertions are worth noting for their construction, not just existence.
  The provenance test initially rested on whitespace divergence alone -- and Python dicts
  preserve insertion order while `json.dumps` does not sort by default, so key order would
  never have differed, contrary to the test's own comment. Whitespace alone is defeatable by
  someone "fixing" the comparison with `separators=(',',':')`. A non-ASCII value was added,
  because `ensure_ascii` escaping cannot be normalized away. **A guard that can be defeated
  by a plausible future edit is not yet a guard.**
- Corollary on the mock/real boundary, carried forward as F-NWS-5: all coverage is
  `MagicMock`-based, so the real `requests.Response` surface is still untouched. The live
  capture step is the real-invocation test and must route through the new methods.

### AI PROCESS NOTES (KT Rank 5)
- The coverage gap was jointly produced: the Architect's prompt specified one test
  (Amendment 1) and did not specify coverage for the methods being added around it; Claude
  Code delivered exactly what was specified and did not notice the omission. Neither party
  caught it at the time. A prompt that names one required test implicitly invites treating
  that test as sufficient -- worth guarding against in future prompts by asking "what does
  this change make callable, and is each of those things called by a test?"
- Green-suite counts this session: 83 -> 86 -> 94 -> 96. Every increment was reported as
  proof of correctness. Only the 94 -> 96 increment (the cache-bypass and trailing-zero
  tests) was specifically constructed so that it COULD fail against a plausible regression.

## 2026-07-29 — FINDING: a rendered diff is not an artifact (review-channel lossiness)
**Type:** Process finding + working-discipline change (no code or config change)
**Status:** E3 — Ratified by Architect 2026-07-29 (Invariant 3)
**Session:** Surfaced three times across six review rounds of the F2 prerequisite build.

**What:** The existing guardrail "read the artifact, never assert from memory; print, do not
summarize" already covered one failure direction -- a real defect hidden by a summary. This
session found the INVERSE direction: **a phantom defect manufactured by a lossy render.**
Three times, the planning/review partner raised a defect that did not exist on disk.

**Evidence (all three cleared by the Architect's own terminal, in seconds):**
1. `get_hourly_forecast_raw`'s `return HourlyForecastRaw(...)` appeared to pass 3 of 6
   required fields. `inspect.getsource` showed all six present.
2. `get_points_raw`'s Amendment 3 docstring appeared to collapse "within one scheduled run
   (one process, one poll per city) the cache" into "within on". `inspect.getsource` showed
   the sentence whole.
3. A later round showed `class PointsRaw(NamedTuple):` missing its header line, an
   undefined `fake_get`, an unterminated docstring, and a missing `import hashlib` -- every
   one of which would have produced a `SyntaxError`, `NameError`, or failing test. The suite
   was green and `PointsRaw` was importable by name, so all four were artifacts.

**Root cause, and it is NOT Claude Code refusing to print.** Claude Code ran the reads and
prints as instructed. Its interface collapses tool output into single lines
(`Read 1 file`, `Ran 1 shell command`), so what reaches a review channel by copy-paste
contains the FACT of the print and none of its content. Five consecutive rounds of
"print verbatim, do not summarize" did not survive the channel. Meanwhile every command run
directly in Git Bash arrived intact and settled each question immediately.

**Working-discipline change adopted (the actual remediation, and it sits on the Architect's
side, not the AI's):** proposed one-line addition to `CLAUDE.md`, for Architect ratification:

> Claude Code's printed output does not survive copy-paste into a review channel.
> Verification claims are E4 testimony regardless of how they are formatted. The Architect
> confirms from his own terminal -- `inspect.getsource(...)` for functions, `cat` for whole
> files -- before accepting any claim about disk state.

**`inspect.getsource` over `cat` for functions, and the reason matters:** it prints what
Python actually PARSED, not what a renderer drew, so it survives the copy-paste channel that
demonstrably eats diffs. Adopted as the standing verification idiom for this repo.

### FINDINGS
- **A green suite discriminates SOME render artifacts and not others, and the distinction is
  precise enough to use.** Anything that would break parsing or fail a test (missing class
  header, undefined name, unterminated string, dropped import, stray colon) is cleared by a
  passing suite. Two classes are NOT cleared: (1) code that parses but fails only at call
  time on a path no test exercises -- e.g. a truncated constructor call; (2) **docstring
  content**, which passes every test regardless of whether it is mangled. Verification
  requests should therefore be narrowed to those two classes rather than demanding
  whole-file prints every round.
- **Named review-partner error (KT Rank 5, chat partner's own):** the first anomaly was
  raised with "Stop here" and "two things are wrong on their face" while the actual evidence
  was a rendered diff. The hedge and the settling command were both supplied, but the
  framing was stronger than the evidence supported. Asserting a defect from a render is the
  same category of error as asserting from memory. One full round trip was spent on it.
- **Named review-partner error #2:** the diagnostic one-liner supplied for the coordinate
  check was itself broken -- single-quoted for bash with `\"` escapes inside an f-string,
  which Python read as a line continuation. It failed on first run. A command handed over
  for the Architect to run is an artifact too, and it was not tested before delivery. This
  is adjacent to the known failure mode about command blocks with unresolved placeholders.
- The verbatim-print instruction is still correct and should stay in force; it is simply
  insufficient on its own, because compliance with it is not observable through this channel.

### AI PROCESS NOTES (KT Rank 5)
- Total review rounds on a step originally scoped as "add a raw-capturing method": six.
  Three of them turned wholly or partly on render lossiness rather than on code.
- Two memory entries were written by Claude Code at session end for continuity, both
  explicitly flagged as pointers to re-verify from disk rather than facts to trust: the
  verbatim/`inspect.getsource` discipline, and the F2 gate structure with its four ratified
  rulings. Per Invariant 3 and the standing disk-wins rule, next session must re-verify
  HEAD == origin, suite green, and the three raw methods present via `inspect.getsource`
  before relying on any of it.
- Session ended deliberately at step 1 rather than continuing into step 2, per one-task-
  per-session. Prior sessions' clustered mistakes at the end of long sessions were the
  stated reason.

## 2026-08-04 — FILESYSTEM ACCESS: research-lab-files MCP connector established (Windows 8.3 path requirement)
**Type:** Tooling / review-channel infrastructure (no pipeline code, no DB, no repo commit)
**Status:** E3 — Ratified by Architect 2026-08-04 (Invariant 3)
**Session:** Post-break session, 2026-08-04. No pipeline work performed; setup, correction, and governance only.

**Task:** Give the chat-side planning/review partner live read access to both trees, to
close the review-channel lossiness documented in the 2026-07-29 rendered-diff entry.

**Built:** `research-lab-files` filesystem MCP server registered in
`C:\Users\rjkir\AppData\Roaming\Claude\claude_desktop_config.json`, exposing exactly two
directories: `C:\Projects\weather-pipeline` and `C:\Users\rjkir\Obsidian\Research Lab`.
Read-only by standing instruction, not by server capability -- the server ships write tools;
the restriction is enforced in the project Instructions, not in the config. Pre-existing
config keys (`coworkUserFilesPath`, `preferences`) were preserved through a merge, verified
by key count (11 preference keys before and after). A `.bak` of the original 1204-byte config
was taken before any edit.

**Standing rules written into project Instructions:** read-only, never write; **never read
`data/pipeline.db`** (live WAL database, schedulers writing every five minutes, a raw file
read risks a torn view missing committed rows in the `-wal` file -- the same reasoning that
makes `scripts/backup_db.py` use `VACUUM INTO` rather than a file copy); never read
`secrets.yaml`; and a file read is better evidence than a pasted diff but is **still AI
testimony** -- reading a file does not advance any claim about it to E3.

**Also done:** the two GitHub repo context cards (`CiscoFlawlezz/research-lab`,
`CiscoFlawlezz/weather-pipeline`, 26% of project capacity) were removed from the Claude
project. They provided a *last-pushed* view that would now sit alongside a *disk* view with
nothing in a response indicating which was read. That ambiguity is worse than either source
alone.

### FINDINGS
- **A local MCP server's `command` value on this machine must contain no spaces; use the 8.3
  short path.** Claude Desktop wraps the configured command as
  `cmd.exe /c <command> <args>`, and `cmd` splits the string at the first unquoted space.
  `"command": "npx"` resolved to `C:\Program Files\nodejs\npx`, so `cmd` attempted to execute
  `C:\Program` and the server died immediately on every launch. Working value:
  `C:\PROGRA~1\nodejs\npx.cmd`. Obtain it with, in `cmd.exe`:
  `for %I in ("C:\Program Files\nodejs\npx.cmd") do @echo %~sI`
  Note the asymmetry that masks this: **arguments** may contain spaces safely (the vault path
  `...\Obsidian\Research Lab` is passed as its own array element and works untouched); only
  the **command** value is split. This is the inverse of the Git Bash quoting rule already in
  use for that same path.
- **The failure was invisible to interactive testing.** Running
  `npx -y @modelcontextprotocol/server-filesystem "C:\Projects\weather-pipeline" "C:\Users\rjkir\Obsidian\Research Lab"`
  by hand in `cmd.exe` succeeded and printed `Secure MCP Filesystem Server running on stdio`,
  because an interactive prompt resolves `npx` through PATHEXT to `npx.cmd` and handles the
  space. A manual success therefore proved nothing about the app's spawn path. Same category
  as the standing lesson that scheduler registration is not execution: *the mechanism that
  works by hand is not the mechanism the system uses.*
- **The Developer-pane status label is not a verification criterion.** The MCP server log
  printed `Server started and connected successfully` on three separate occasions
  **immediately before** the process died with the `'C:\Program'` error. The verification
  standard is the log showing (a) the allowed directories echoed back by the server, and
  (b) a completed `tools/list` request-and-result exchange. Both appeared at `16:36:39` on
  the successful launch. This is the notifier lesson again in a new stream: a green status is
  not device delivery.
- **The connector is a DEFERRED tool and this creates a live false-negative risk.** It does
  not load into context automatically; it is discoverable only via `tool_search`. On two
  occasions in this session Claude asserted the connector was absent and that the paths were
  unreachable -- once falling back to "the indexed project files are snapshots, so I cannot
  answer," which is the exact stale-snapshot failure the connector was installed to end. On
  the second occasion Claude searched of its own accord, found the connector, and named the
  error. **The reflex fired; it was not forced.** The project Instructions now require
  `tool_search` before any claim that filesystem access is absent. Absence of a tool is a
  claim about state and is subject to the same verify-before-asserting rule as any other.

### AI PROCESS NOTES (KT Rank 5)
- **Named review-partner error (chat partner's own, KT Rank 5):** the first proposed fix was
  to replace `"command": "npx"` with the full path `C:\Program Files\nodejs\npx.cmd`. This
  was WRONG and failed identically. It **moved** the space rather than removing it; `cmd`
  split at `C:\Program` exactly as before. The misdiagnosis was "npx is not being resolved"
  when the actual mechanism was "the command string is split at its first space." The log
  message named the mechanism correctly from the first failure -- `'C:\Program' is not
  recognized`, not `'npx' is not recognized` -- and was read past. Lesson: the error string
  was more specific than the hypothesis, and the hypothesis won anyway.
- Diagnosis was run before any change was applied, deliberately, so that a fix that worked
  could be attributed. This paid off: the first fix did not work, and because nothing else had
  been changed alongside it, that was unambiguous rather than confounded.
- Verification of the merged config was by content, not by parse: `HAS SPACE: False`,
  `EXISTS: True` (from `os.path.exists`), and `PREFS KEYS: 11`. Valid JSON alone would not
  have caught a dropped preferences block or a non-existent command path.

## 2026-08-04 — CORRECTION: tests/test_nws_client.py holds 13 tests, not 11 (supersedes a figure in a ratified entry)
**Type:** Correction to canon (append-only; supersedes, does not edit)
**Status:** E3 — Ratified by Architect 2026-08-04 (Invariant 3)
**Session:** 2026-08-04, during verification of the newly established filesystem connector.

**Correction.** The ratified entry `2026-07-29 — FINDING: a code path with no caller has no
test that can fail` states, under *Consequence / remediation*, that coverage was closed with
**11 tests**. That figure is wrong. The correct figure is **13**.

**Handled per append-only discipline (corrections are new rows under a bumped version, never
UPDATE, never DELETE).** The 2026-07-29 entry is ratified canon and is NOT edited. This entry
supersedes the figure. Any future read of that entry's test count should resolve to this
correction -- which is the same read-authority problem the open ADR covers for
`parser_version` collisions in the DB, now appearing in the governance log itself.

**Evidence, from the Architect's own terminal 2026-08-04:**

13 defined, 13 collected. The two counts agree, so there are no defined-but-uncollected
tests; the correction is purely to the recorded number, not to what runs.

**Provenance of the error.** The figure 11 originated from two sources, both of which this
same session's ratified rendered-diff finding classifies as untrustworthy: (a) counting test
functions off a copy-pasted render of the file, and (b) Claude Code's own summary claim of
"all 11 pass." Neither was ever checked against the suite, and the number then propagated
through several turns of review and into a ratified log entry.

### FINDINGS
- **A number read off a render is render evidence and loses to disk, exactly as a code
  fragment does.** The 2026-07-29 rendered-diff finding was framed around *code* mangled in
  transit. It generalizes to any datum extracted from that channel, including counts,
  timestamps, and file sizes -- categories that look like facts rather than like renders and
  therefore attract less suspicion.
- **The error nearly propagated into a second, worse use.** The figure 11 was about to be used
  as the *expected value* for verifying that the new filesystem connector was reading live
  disk ("if it reports 11 tests, access is live"). Had disk happened to agree, an unverified
  number would have been used to certify a new capability. The check passed only because disk
  was consulted directly and the discrepancy surfaced. **A verification criterion sourced
  from unverified evidence is not a verification criterion.**
- **This is the first correction to ratified canon in the log.** The mechanism used here (new
  superseding entry, original untouched) should be treated as the standing pattern, and it
  argues for the open read-authority ADR being written to cover documents as well as DB rows:
  the log now contains two entries with different values for the same fact, and the selection
  rule lives only in this sentence.

### AI PROCESS NOTES (KT Rank 5)
- The error is the chat partner's, named explicitly: the count was asserted repeatedly across
  turns without ever being checked, in a session whose central finding was that this exact
  evidence class cannot be trusted. Holding a discipline and applying it to one's own inputs
  are separate acts.
- The correction cost one command and was surfaced only because the connector verification
  happened to target that file. Nothing systematic caught it.

## 2026-08-04 — F2 GATE REVIEW: Final_Architectural_Review §15/§16 read against the four ratified rulings
**Type:** Governance review (closes a standing open item; no code, no DB, no commit)
**Status:** E3 — Ratified by Architect 2026-08-04 (Invariant 3)
**Session:** 2026-08-04. First substantive use of the research-lab-files connector.

**Open item closed.** The 2026-07-29 design-rulings entry recorded, under AI PROCESS NOTES,
that `Final_Architectural_Review_2026-07-19.md` had **not** been read and that no claim was
being made about whether it contained a prior forecast-collector constraint. §15 and §16 have
now been read.

**Headline: no contradiction.** Nothing in §15 or §16 contradicts any of the four ratified F2
rulings. §15.5 affirmatively endorses the build and its scope choice (start with NWS gridpoint
hourly, NBM later). The rulings stand as ratified. What the review adds is a set of constraints
the rulings are **silent** on, plus one genuine tension.

**EVIDENCE STATUS -- read before acting on anything below.** This is a single AI file read,
which is better evidence than a pasted diff but is still AI testimony; it does not make any
claim below E3. The source document's own frontmatter classifies it as E4 pending ratification,
and its §15 resolution block classifies itself as E4 and explicitly invites verification
against commit `fa0a99f` and the snapshot store. **The claim that exactly 8 v1 summary rows
remain unmigrated is a DB-state claim that was not and cannot be verified by a file read** --
it requires the Architect running a query. Treat every specific figure and section number
below as pending independent confirmation.

**Bearing on Ruling 1 (key on `startTime`) -- not constrained; indirectly reinforced.**
§16's F3 note warns that the PDFs should be read first because one interpretation touches
`climate_day`, i.e. `climate_day` semantics for MIA/AUS may still change. `startTime` is a raw
vendor field, so keying on it is immune to that; the exposure lands entirely on the derivation,
which is exactly where Ruling 3 already binds the version. The raw/derived separation holds
under this pressure.

**Bearing on Ruling 2 (`raw_nws_hourly_forecast`) -- two items, both new.**
1. *Legacy name collision, and it may be a prerequisite rather than a someday item.* §4
   weakness #10 records that dead `storage/schema.sql` already defines an
   `nws_forecast_snapshots` table no live code creates; §16 prescribes retiring `schema.sql`
   into `archive/` with a header. Shipping `raw_nws_hourly_forecast` while a stale,
   differently-named forecast table sits in an unretired schema file produces precisely the
   reader confusion §4 already flags. The retirement is cheap. **Candidate for insertion
   before F2 Step 2.**
2. *The ruling names a table, not a database file.* §16 opens with "split `market.db` from
   `pipeline.db`." Hourly gridpoint forecast is a high-cadence, high-volume stream whose growth
   profile resembles Kalshi order books more than CLI truth. **Which database file
   `raw_nws_hourly_forecast` lives in is an open question none of the four rulings answer, and
   it is far cheaper to answer before the table is populated than after.**

**Bearing on Ruling 3 (`PARSER_VERSION` bound to the climate_day derivation) -- design
validated; a read-side hazard surfaced.** §16's F3 11am-ET interpretation is a foreseeable,
not hypothetical, trigger for a version bump, which validates binding the constant to the
derivation. **The hazard:** the system will then have *two independent climate_day derivations*
-- the CLI parser's covered-day-from-header (parser v2, commit `fa0a99f`) and F2's
`startTime`-based one -- which must agree on identical key semantics or every forecast-to-truth
join silently mis-registers. Per §15's resolution block, `raw_nws_cli` currently holds 8
mis-keyed v1 summary rows whose v2 corrections **do not yet exist**; the migration is
authorized-pending, not executed. F2 will therefore begin producing rows keyed on a semantic
the CLI table does not yet uniformly satisfy. **This makes the open read-authority ADR a
blocker for any F2-to-CLI join -- though not for F2 collection itself.**

**Bearing on Ruling 4 (always-snapshot, insert on `updateTime` change) -- the real tension.**
- *Supported* by §4 #13: `/latest`-only fetching misses interstitial products. The gridpoint
  hourly endpoint has no listable history and returns current state only, so always-snapshot is
  the correct structural answer to that defect class, not redundancy.
- *Stressed* by §16's "gzip snapshot blobs." ~156 periods of JSON per call, and NWS mutates
  `updateTime`/`generatedAt` on nearly every response, so hash-level dedup will almost never
  fire. Unconditional snapshotting becomes the largest single blob-growth decision in the
  project. The ruling is defensible on irreversibility grounds, but §16 argues the compression
  mitigation should land **alongside** it, not later.
- *Mechanism challenged* by §15.7: replace check-then-insert dedup with a DB-level unique index
  plus `INSERT OR IGNORE`. "Insert only when `updateTime` changes" **is** a check-then-insert
  pattern, and §4 #9 flags that shape as race-prone across retry paths and overlapping
  scheduled runs. A unique index on approximately `(location, start_time, update_time)` would
  enforce the ruling's intent at the DB layer rather than in application logic -- **same
  policy, stronger guarantee.** This does not contradict Ruling 4; it proposes a better
  implementation of it.
- *Prerequisite* per §15.6: always-snapshot at poll cadence adds a writer to a database that
  still has no `busy_timeout`. `PRAGMA busy_timeout=15000` is a prerequisite, not a nicety.
  Related: the snapshot store commits on its own connection, so always-snapshot plus
  conditional row insert is inherently **two transactions**. In the no-change case, a snapshot
  with no row is the intended state -- which is fine, but §4 #4's lesson applies: document that
  honestly rather than repeating the false-atomicity docstring pattern.

**Bearing on F2 that no ruling covers.**
- **§15.3 -- `collection_runs` rows.** F2 will be the fourth stream with no gap-audit coverage.
  Emitting run rows from the collector's first commit is cheaper than retrofitting, and §16
  makes the completeness report one of only two Plane 3 launch artifacts. **See also the
  downtime-accounting entry below: run rows are the mechanism that distinguishes intended
  downtime from collector failure.**
- **§15.5 says "and schedule it,"** which under §15.4 implies Password logon type, ntfy.sh on
  the failure path, and PowerShell rather than `wmic`/`timeout` in the wrapper. The
  notification layer is already built and device-verified, so this is wiring, not building.
  **Note: scheduling remains explicitly out of scope until the collector runs clean manually
  and the Architect approves.**
- **§16's fixture precedent** -- commit real captured gridpoint bodies as test fixtures --
  independently confirms the Step 3/4 sequencing already adopted from the M2.T4a/M2.T4b
  precedent.

### FINDINGS
- **The four rulings survive the review intact, and that is the primary result.** The purpose of
  reading §15/§16 was to find a prior constraint that might contradict ratified canon. None
  exists. The rulings were made without this document and are consistent with it.
- **The rulings' silences are where the risk lives, not their content.** Three unanswered
  questions now have names: which DB file the table belongs in; whether `schema.sql` retirement
  precedes Step 2; and whether the write gate is enforced in application logic or by a unique
  index. All three are cheaper to decide before the table exists.
- **`busy_timeout` moves category.** It was on the deferred list. §15.6 makes it a prerequisite
  for adding a poll-cadence writer, which F2 is. **Recommend moving it off deferred and in
  front of F2 Step 3.**
- **The read-authority ADR is now blocking something concrete**, rather than being a tidy-up
  item: it gates any F2-to-CLI join, because the two climate_day derivations will coexist before
  the CLI v1/v2 migration is executed.
- **This item sat open for six days and closed in one file read.** It was flagged twice,
  unprompted, by Claude Code on 2026-07-29 as unread, and the flag was correctly carried forward
  rather than dropped. The cost of leaving it open was the possibility of building Steps 2-5 on
  rulings that contradicted prior canon.

### AI PROCESS NOTES (KT Rank 5)
- This entry is derived from **one** AI read of one document. It has not been independently
  confirmed by the Architect, and the section numbers, the `fa0a99f` reference, and the 8-row
  figure are all reported rather than verified. The connector makes reads cheap; it does not
  make them E3.
- The review was requested specifically as the connector's first real task, so that the new
  capability was exercised on work that mattered rather than on a synthetic check. It
  simultaneously closed a standing governance item and demonstrated the tool.
- No action was taken on any finding above. All of it is queued for Architect decision. Reading
  a review is not adopting its recommendations.

## 2026-08-04 — SUPERSEDING: the wake/hibernate investigation is closed; long gaps are intended Architect downtime
**Type:** Correction to a standing open item (append-only; supersedes, does not edit)
**Status:** E3 — Ratified by Architect 2026-08-04 (Invariant 3)
**Session:** 2026-08-04. Architect statement of operating practice; no code, no DB, no commit.

**Correction, stated by the Architect.** The machine is **sometimes shut down manually and
deliberately**. Extended periods with no collection are, in those cases, the expected
consequence of an operating decision, not a symptom of a defect. Power configuration is
correct; there is no hardware or settings question outstanding.

**What this supersedes.** Prior entries carry the wake/hibernate finding as **INCONCLUSIVE,
pending a forward-verification window** -- specifically, that `powercfg /change
hibernate-timeout-ac 0` was applied and confirmed reading `0x00000000`, but that two gaps
appeared in the post-fix observation window and sleep/wake event timestamps were never
correlated against the time the fix was applied. **That framing is retired.** It implies a live
technical question awaiting evidence. The correct status is: *gaps coinciding with
Architect-initiated downtime are expected behavior and require no investigation.* Prior entries
are ratified canon and are NOT edited; this entry supersedes their status.

**What this does NOT retire.** Three things survive the reframe and must not be swept up with
it:
1. **The 43h02m historical loss remains a real, recorded loss.** Reclassifying the cause does
   not un-lose the data. The `[IRR]` character of missed collection windows is unchanged.
2. **The sub-hour dropout pattern is untouched and is now the only unexplained continuity
   finding.** Some hour buckets show ~408-420 rows where full hours show 720 at the same
   60-ticker denominator. Downtime explains missing **hours**; it cannot explain a **partial**
   hour, because the machine was up and the collector was firing throughout. This finding was
   partially obscured by the hibernate hypothesis and is now isolated.
3. **The rows-per-ticker anomaly** (within-run row counts varying against a flat or falling
   distinct-ticker denominator; partial-hour-truncation hypothesis probably right but never
   confirmed) is unaffected.

### FINDINGS
- **A gap in the data is not self-describing.** The same absence of rows is produced by a
  hibernate defect and by the Architect pressing shut down, and nothing in the DB distinguishes
  them. Roughly six days of investigation-shaped attention went to a mechanism question that a
  single sentence of operating context dissolved. **The instrument records that collection did
  not happen; it does not record why, and it currently has no field that could.**
- **This is the strongest concrete argument yet for §15.3's `collection_runs` rows.** A run
  table distinguishes "the collector ran and stored nothing" from "the collector never ran"
  from "the machine was off." Without it, every gap is ambiguous and every gap investigation
  starts from zero. The §15/§16 review already recommended emitting run rows from F2's first
  commit; this entry independently strengthens that to a general instrument-correctness
  requirement, not merely an F2 nicety.
- **Downtime is now a known, deliberate, and unrecorded input to the corpus.** For a V1
  measurement instrument, an operating practice that produces data gaps is a property of the
  instrument and should be *recorded* rather than *inferred* -- ideally as an Architect-logged
  downtime window, so that a future completeness report can classify a gap as intended rather
  than flagging it. This is a design question, not an action item, and it is raised here rather
  than decided.
- **The ntfy notification layer has a stated blind spot, which is correct but must not be
  forgotten.** It fires on wrapper failure. It cannot fire when the machine is off. "No
  notification received" therefore means "nothing to report **while the machine was up**." That
  is acceptable and expected under this operating practice; it is written down here so it is
  never mistaken for full coverage.

### AI PROCESS NOTES (KT Rank 5)
- **Named review-partner error (chat partner's own, KT Rank 5):** the hibernate hypothesis was
  carried forward across this entire session and used to argue that a continuity check was the
  highest-priority irreversible next task, on the reasoning that the break window was "the
  >60-minute idle window the forward-verification needed." That framing was wrong, and it was
  wrong because a premise about the Architect's own operating practice was never asked about.
  The correct question -- *was the machine off on purpose?* -- is cheaper than any evidence
  the proposed investigation would have produced.
- **Generalizable:** before proposing an investigation into a system's behavior, establish
  whether the behavior is being caused deliberately by the operator. AI review partners have no
  visibility into operator intent and will default to treating an anomaly as a defect. This is
  the mirror image of the confabulation failure mode -- not inventing an artifact that does not
  exist, but inventing a *problem* that does not exist.
- The correction cost one sentence from the Architect and retired a multi-session open item.

## 2026-08-06 — TASK 1 COMPLETE: storage/schema.sql retired to archive/ (§16); a header-only near-miss and two review-partner verification errors
**Type:** Instrument hygiene + process finding (code move + one ratified-doc edit; one commit, pushed)
**Status:** E3 — Ratified by Architect 2026-08-06 (Invariant 3)
**Session:** 2026-08-06. Executed via Claude Code (manual-approval mode) after two failed hand-paste attempts; chat-side Claude as planning/review partner.

**Task.** Retire the dead DDL file `storage/schema.sql` into `archive/` per
`Final_Architectural_Review_2026-07-19.md` §16 and §4 weakness #10. The file creates
nothing at runtime: nothing in the tree imports, opens, or executes it (verified by grep
across the full tree before the move); `storage/schema.py` is the live schema authority;
its `PRAGMA journal_mode = WAL` has never executed (WAL is set per-connection by
`SnapshotStore._connect()`). Six tables are defined in it — `collection_runs`,
`nws_forecast_snapshots`, `nws_observations`, `kalshi_markets`, `kalshi_candlesticks`,
`kalshi_settlements` — and an Architect query (2026-08-05) confirmed none exists in
`data/pipeline.db`, which holds exactly `kalshi_observations`, `raw_nws_cli`,
`snapshot_blob`, `snapshot_index`, `sqlite_sequence`.

**What landed.** Commit `8a0a28c` (pushed to origin/main):
- `git mv storage/schema.sql archive/schema.sql` — a true rename; git recorded
  `{storage => archive}/schema.sql`, all six `CREATE TABLE` statements and the single real
  PRAGMA preserved in the body, zero DDL deletions.
- An E4 retirement header prepended to the archived file, stating: creates nothing;
  `schema.py` is sole authority; do not add tables here; the line-1 PRAGMA has never
  executed and WAL is set at runtime by `SnapshotStore._connect()`; a dated DB-state block
  listing the five live tables; and a forward-pointer noting `collection_runs` is the
  starting DDL for the Task 4 run-audit table (§15.3, review:207).
- `CLAUDE.md` line 63 edited **in place, by the Architect by hand** (current-state
  governance document, corrected in place — not a superseding entry), replacing the
  `storage/schema.sql` module-layout bullet with an `archive/schema.sql — retired` bullet.
  Staged and committed in the same change so no ratified doc ever described a state the
  move had falsified.

**Explicitly out of scope, recorded not fixed** (Architect to schedule separately):
- False-storage-docstring task: `backup_db.py:6` (cites "schema.sql line 1" as the reason
  for WAL — now doubly stale: wrong path, and the PRAGMA never executes from that file at
  all, so only a substantive rewrite is correct), `storage/schema.py:53` and
  `collectors/kalshi_observation_collector.py:134` (both assert market metadata "lives in
  `kalshi_markets`" — a table confirmed absent; the metadata lives only in the raw snapshot).
- `Bootstrap_Log.md:329` carries the same false WAL causal claim; correction is a
  superseding entry (append-only), never an edit.
- Untouched by design: `README.md`, both `SESSION_HANDOFF` files,
  `Repository_Manifest.txt`, `Final_Architectural_Review_2026-07-19.md`.

### FINDINGS
- **A header-only near-miss was caught before it committed, and append-only is why recovery
  was free.** At one point `archive/schema.sql` was staged with the retirement header and
  **none of the six CREATE TABLE statements** — a delete-plus-header-add masquerading as a
  move, net −61 lines, carrying a stray `Status: E3 — Architect ratified` header from some
  earlier partial write. Had it committed, the archived file would have contradicted its own
  header ("the tables defined below…") and misrepresented what it preserved. It was caught
  because the rebuild verified `grep -c 'CREATE TABLE'` against the pristine
  `HEAD:storage/schema.sql` rather than trusting the staged file. Recovery was
  `git reset` + `git checkout -- storage/schema.sql` + `rm -rf archive`, returning to a clean
  `38afc5a` — and it cost nothing **because `git mv` and the append-only discipline meant the
  full DDL lived in history the entire time.** The safety net was structural, not lucky.
- **The redo added a per-step content guard that the first attempt lacked.** `CREATE TABLE`
  count must equal 6 (proves the DDL survived the header prepend) and the real PRAGMA
  statement must still be present exactly once in the body (proves no duplication). These are
  content assertions on the artifact, not a summary of it — the same principle as
  "only assertions fail."
- **Claude Code stopped on every mismatch rather than proceeding on judgment.** On both the
  header-only discrepancy and the PRAGMA-count deviation, it printed the actual line numbers
  and handed the decision back rather than silently reconciling. This is print-don't-summarize
  and hard-stop-before-git working as designed, executed by the implementation agent without
  being separately instructed each time.
- **The tool switch itself was the fix for the failure that recurred by hand.** Two hand-paste
  attempts failed identically: a long commit message pasted into `git commit -F -` without a
  preceding newline was interpreted line-by-line as bash (`command not found` flood; no damage,
  nothing committed). Moving execution to Claude Code — which writes header and message to disk
  directly, never through the shell — eliminated the entire failure class. The final commit
  used `git commit -F <tempfile>` for the same reason.

### AI PROCESS NOTES (KT Rank 5)
- **Named review-partner error #1 (chat partner's own):** the pre-flight check was written as
  "working tree clean," when the same session's own earlier disk read had already listed
  `SESSION_DELTAS_2026-08-04.txt` as untracked — guaranteeing the criterion would trip on a
  benign, pre-existing file. A verification criterion written from a template instead of from
  the evidence already in hand. Same class as the 2026-08-04 test-count error: holding a
  discipline and applying it to one's own inputs are separate acts.
- **Named review-partner error #2 (chat partner's own):** the guard "`grep -c 'PRAGMA
  journal_mode'` must be 1" was falsified by the header text the same partner supplied, which
  quotes the string `PRAGMA journal_mode = WAL;` inline while describing the trap. Correct
  expected count was 2 (one comment mention, one real statement at line 56). The predicate was
  wrong, not the file. Caught because Claude Code refused the mismatch and printed both line
  numbers. **A verification criterion is only as trustworthy as whoever wrote it, and it can be
  defeated by content introduced in the same breath.**
- Both partner errors were caught by the implementation agent stopping, not by the review
  partner self-correcting. The machinery caught the narrator again — the recurring lesson of
  this log.
- One cosmetic item left deliberately unfixed: the Architect's CLAUDE.md hand-edit dropped the
  trailing EOF newline. Corrected-in-place-at-the-finish-line risk was judged higher than the
  one-byte benefit; flagged for the next by-hand CLAUDE.md touch rather than re-edited now.

## 2026-08-06 — TASK 2 (SURVEY): busy_timeout site inventory; premise corrected from 0→15000 to 5000→15000
**Type:** Instrument hygiene survey (survey-and-decide session; no code, no DB mutation, no commit)
**Status:** E3 — Ratified by Architect 2026-08-06 (Invariant 3)
**Session:** 2026-08-06. Chat-side Claude as planning/review partner; all terminal commands run by the Architect (grep site list and the in-memory PRAGMA check are E3, Architect's terminal). No Claude Code invocation — nothing was changed.

**Task.** Task 2 is `PRAGMA busy_timeout=15000` on all writer connections, moved from the deferred list to the arc because §15.6 makes it a prerequisite for adding a poll-cadence writer, which F2 is. This session was scoped survey-only: find every SQLite connection in the tree, classify each writer vs reader, and decide four questions the survey surfaced — before any edit is drafted.

**Headline finding — the premise was wrong, and it resizes the task.** CLAUDE.md's sharp-edges bullet and the standing arc both framed this as setting a timeout where there is none: `0 → 15000`. Disk says otherwise. Python's `sqlite3.connect()` applies a default `timeout=5.0`, implemented as `sqlite3_busy_timeout(5000)`. Confirmed at the Architect's terminal: a default connection returns `PRAGMA busy_timeout` `(5000,)`; `timeout=15` returns `(15000,)`. So **every connection in the tree already waits five seconds, not zero.** Task 2 is `5000 → 15000`, a smaller change than scoped. Contention today does not fail instantly — it fails after a five-second stall. The `timeout=15.0` argument form and an explicit `PRAGMA busy_timeout=15000` are proven equivalent on this interpreter, which is live input to the factory memo.

**Site inventory (11 `sqlite3.connect(` sites, grep-confirmed E3, one-to-one with the survey).**
- **3 production writers:** `storage/snapshots.py:66` (`SnapshotStore._connect()` — the tree's only connection factory, already the PRAGMA home for `journal_mode`/`foreign_keys`); `collectors/nws_cli_collector.py:174` (`collect_city`, raw connect, no PRAGMAs); `collectors/kalshi_observation_collector.py:269` (`collect_all`, raw connect, no PRAGMAs, long-lived across the whole sweep).
- **3 read-only URI readers:** `scripts/backup_db.py:71, 122, 140` — all `file:...?mode=ro`. Line 122 is the `VACUUM INTO`, which holds a read lock for a full DB copy against a 5-minute writer.
- **5 test sites:** all against `tmp_path` files, single-process (`test_kalshi_observations.py:94, 101, 346`; `test_snapshots.py:78, 133` — :78 is the lone `UPDATE` in the tree, a deliberate corruption injection).
- **Zero `busy_timeout` occurrences in source, tree-wide** (grep, E3). The 5000 ms is a library default, written nowhere.
- **No hidden opener:** the wider net (`connect(|sqlite`) surfaced only the six `self._connect()` callers inside `SnapshotStore` (inherit the factory) and the two `ensure_*(conn)` functions (take `conn` as a parameter, open nothing). No `.bat`/`.sh`/`.xml` shells out to the sqlite3 CLI. Only three Python writers and one Python reader script open the database.

**busy_timeout is per connection, not per database.** In `collect_city`, setting the PRAGMA on `conn` does nothing for the `SnapshotStore` handle opened two lines earlier against the same file. The number of connections needing coverage is not the number of `sqlite3.connect` calls a reader notices — `SnapshotStore` opens a fresh handle per `snapshot()`.

**Real connection count under load.** Not "two collectors." A Kalshi sweep is ~120 short-lived handles: 1 long-lived collector connection plus 2 `SnapshotStore` handles per ticker across ~60 tickers, plus one from each `SnapshotStore.__init__`. F2 adds a third writer at poll cadence whose always-snapshot policy (ruling 4) writes at least five snapshots per poll even when no period rows are inserted. Under WAL, readers never block writers, but there is exactly one writer at a time — so three poll-cadence writers make lock contention a scheduling property, not a hypothesis.

**Rulings this session (R1–R8), each recorded so none is re-litigated:**
- **R1 — Scope.** Survey-and-decide only. The change is next session. No change prompt drafted.
- **R2 — Shape.** Ruling *toward* the shared connection factory (not the repeated line), but **not adopted this session.** F2 adds the fourth copy either way, so deciding shape before F2 is the cheaper ordering. Blocker on ruling today: a factory silently switches `foreign_keys=ON` for both collector connections — inert now (collectors' tables declare no FKs; only `snapshot_index` has one, written solely through `SnapshotStore`, which already sets it), but "inert today" is not "inert." Next session: a factory memo (module, call signature, four consumers, what travels with it, per-consumer behavioral change, proposed CLAUDE.md bullet), filed in the Decision Log with a revisit trigger. No factory code until the Architect rules on the memo.
- **R3 — backup_db.py.** In scope; covered in the memo as a **distinct reader class** with its own reasoning, not folded into "writers." VACUUM INTO holding a read lock for a full copy against a 5-minute writer is the site where a timeout most plausibly matters.
- **R4 — Config vs literal.** **Literal**, a single named constant in the factory module — not `config.yaml`. Reasoning (recorded so no future reader re-litigates it as a D4 violation): `core/config.py` re-reads and re-parses `config.yaml` on every accessor call, ~120 times per Kalshi sweep. D4 exists to stop operational identifiers (tickers, station IDs, cadences) whose wrongness silently corrupts data from being hardcoded. A lock-wait timeout is a robustness constant with no settlement consequence — not that class.
- **R5 — The assertion.** Non-negotiable, and in the **same commit** as the change, never a later one. The test must open a connection through the real call site or factory and assert `PRAGMA busy_timeout` returns 15000. A test that builds its own connection and checks the PRAGMA is the code-path-with-no-caller failure. Named explicitly in the memo.
- **R6 — Contention legibility.** Not folded into Task 2. See Q2.
- **R7 — Self-contention.** Recorded, not actioned. See Q3.
- **R8 — Evidence discipline.** See AI Process Notes.

**Queue additions (recorded, not actioned):**
- **Q1.** CLAUDE.md sharp-edges bullet ("with no `busy_timeout` set") is confirmed false about effective behavior. Ruling: does **not** fold into the false-storage-docstring task (that task is false *storage locations* in docstrings; this is a governance file asserting a false *runtime mechanism*). Becomes an **in-place CLAUDE.md correction bundled into the Task 2 change commit**, so the bullet and the code stop disagreeing in the same commit — same discipline as line 63 last session. Replacement text not drafted yet.
- **Q2.** Contention invisibility (R6): `SQLITE_BUSY` arrives as `sqlite3.OperationalError`, caught by the broad per-unit handler, logged indistinguishably from a network timeout — so raising the timeout makes the misattribution rarer and therefore harder to ever notice. Queued adjacent to Task 4 (`collection_runs`), where a distinguishable contention signal would live.
- **Q3.** `collect_ticker` self-contention ordering (R7): nesting `store.snapshot()` inside the outer `with conn:` is safe only by statement ordering and Python's deferred `BEGIN`; a longer timeout converts an instant error into a 15-second hang if that ordering ever changes. Queued adjacent to the tracked `collect_ticker` false-atomicity docstring — same function, related cause, separate task.

### FINDINGS
- **A sharp-edge note describing ABSENCE OF CONFIGURATION was true about the source text and false about effective behavior — and went unchecked for months.** "The collectors write with no `busy_timeout` set" is literally true (grep confirms zero occurrences in source) and operationally false (the runtime default is 5000 ms). No one ran the one-line runtime check until this session. **A claim about what a system does *not* do is still a claim and still needs evidence.** This is the same defect class as `backup_db.py:6`'s WAL causal claim and the confabulated-artifact failures: an assertion carried forward on plausibility, not verification — here made harder to catch precisely because it asserted an absence, and absences feel self-evident.
- **The premise correction resized the task before any code existed.** The survey's stated purpose — show every site before changing any — is what created room for the correction to land. Had this been scoped as a mechanical edit, `0 → 15000` would have shipped, over-specifying a timeout against a baseline that was never zero, and the sharp-edges bullet's falseness would have survived the commit unnoticed.
- **The factory decision is a scope-expansion trap, not a style choice.** Adopting a shared factory silently turns on `foreign_keys` enforcement for two connections currently running without it. Inert today by three separate contingent facts (no FKs on the collector tables; the one FK-bearing table written only through `SnapshotStore`; `journal_mode` persistent in the file header regardless). Three contingent facts holding simultaneously is exactly the configuration that breaks quietly when one changes. Deferring adoption to a memo is the correct handling.

### AI PROCESS NOTES (KT Rank 5)

**Status:** E3 — Ratified by Architect 2026-08-06 (Invariant 3)
- **The premise correction was the review partner's, arrived at unprompted, and it materially resized the task before any code was written.** The partner flagged the 5000 ms default rather than accepting the `0 → 15000` framing inherited from CLAUDE.md and the arc. This is the survey doing its job: the value of "show me each site before changing any" is realized at exactly the moment a framing assumption turns out to be false.
- **The partner flagged the 5000 ms claim as CPython knowledge rather than a disk read, and supplied the one command that settles it.** Correct handling of a load-bearing claim that cannot be verified with the tools in hand: name the epistemic status explicitly, and hand over the cheapest command that converts it from testimony to E3 — rather than asserting it flatly or burying the uncertainty.
- **The partner declined to predict a PRAGMA/`busy_timeout` count, citing last session's falsified predicate, and stated the `sqlite3.connect(` count narrowly instead.** It held at 11. **A predicate holding is not retroactive evidence that predicting was safe.** The narrow scope — one unambiguous, greppable token, no derived count layered on top — is what made it safe, not the outcome. Last session's guard failed because it predicted a count of a string that appeared in the very text supplied alongside it; the safe version predicts only what a single literal grep will return and nothing composed on top of it. Keep the scope narrow; do not read the good outcome as license to widen it.

## 2026-08-10 — TASK 3 COMPLETE: raw_nws_hourly_forecast lands in data/pipeline.db (Option A)

**Task:** Decide which SQLite database file the F2 hourly gridpoint forecast table lives in. Decision session — no code, no schema, no DB mutation, no pipeline commit.
**Ruling:** Option A — single file, `data/pipeline.db`. Options B (dedicated `forecast.db`) and C (execute §16 `market.db` split first) rejected for now; C remains correct sequencing if the split is pursued, as its own task.
**Artifacts:** Decision Log entry 2026-08-10. Read-only path inventory `task3_inventory.txt` (881 lines, generated at Architect's terminal, untracked scratch).
**Status:** E3 — Ratified by Architect 2026-08-10 (Invariant 3, per guardrail 3)

### FINDINGS

- **Database-path threading cost measured, not assumed.** Four origination points where a path is named: `collectors/nws_cli_collector.py:259`, `collectors/kalshi_observation_collector.py:307`, `run_cli_collection.bat:24`, `run_kalshi_observations.bat:29`. One hardcoded absolute constant: `scripts/backup_db.py:39`. Eleven pass-through sites. **Zero scheduler changes** — all five Task Scheduler XMLs pass `<Command>` + `<WorkingDirectory>` only and never carry a DB path.
- **SQLite provides no atomic transaction across attached databases when any is in WAL mode.** `pipeline.db` is WAL. Any split therefore makes a combined data-row + `collection_runs` audit-row write non-atomic. This constrains Task 4 directly and is the strongest structural argument for one file.
- **Two objections to splitting examined and REJECTED as weak**, recorded so they are not re-litigated in their strong form: (a) SnapshotStore's blob+index atomicity is per-call and per-file, so a split cannot break Invariant 3's no-orphan/no-dangler property; (b) cross-stream content dedupe is bounded by a rounding error — CLI text, Kalshi JSON and gridpoint JSON never collide by SHA-256. What a split costs is provenance query reach, not integrity.
- **Dedupe is real and is within-stream.** `snapshot_index` 331,542 / `snapshot_blob` 250,555 = ratio 1.32, ~81,000 dedupe hits (24%). With `raw_nws_cli` at 180 rows against `kalshi_observations` at 165,685, essentially all of it is within-Kalshi — confirming the claim above empirically rather than by assertion.
- **Volume finding, recorded as a FINDING and deliberately not as a revisit trigger.** `data/pipeline.db` stood at 960,946,176 bytes (916 MiB) at ruling time. Index rows imply ~9.6 collection-days at full cadence and a growth rate near 95 MiB per collection-day (~35 GB/yr) before F2 adds anything. A threshold trigger drafted at 2 GB would have fired in roughly eleven collection-days; a trigger that fires almost immediately is a finding that was mis-typed as a trigger.
- **The §16 `market.db` split is no longer deferrable on its own clock, independently of F2.** F2 lands in `pipeline.db` under Option A and Option C alike, so sequencing F2 before or after the split does not change the split's cost by a byte. Under Invariant 1 the split cannot delete the originals, so its cost is a permanent duplication of ~0.9 GB and rising, unless a ratified append-only exception for pure file relocation is adopted.
- **Reversibility is asymmetric and runs against this ruling; the cost is accepted knowingly.** A later split cannot delete originals. A later merge is cheap — freeze the file in place as a read-only historical source, exactly as `archive/schema.sql` was retired in Task 1.

### DEFECTS RECORDED, NOT ACTIONED (KT Rank 5)

- `scripts/backup_db.py:44` — `COUNTED_TABLES = ["raw_nws_cli", "snapshot_blob", "snapshot_index"]` omits `kalshi_observations`. The `[ACC][IRR]` stream is not row-count verified live-vs-snapshot. Compounding: `table_counts()` maps a missing table to `-1` rather than failing (lines 76–77), so the omission cannot surface as an error. Same defect class as the `busy_timeout` sharp edge — a verification that passes because it never looked.
- `CLAUDE.md` cross-reference collision: design invariant 3 is **"Snapshot what you cite"**; operational guardrail 3 reads **"Ratification is Architect-only (Invariant 3)."** Both are in the ratified file, citing the same number for different invariants. Every E4 docstring in the tree inherits the ambiguity.
- `scripts/backup_db.py` has **no backup pruning** — line 208 counts generations by glob but nothing deletes. Daily gzips of a 916 MiB database growing 95 MiB/day against a local `D:\Backups\weather-pipeline`. Review §16 predicted this would fill the drive; the prediction is now materialising rather than hypothetical. Higher priority than the cosmetic queue items.
- Three CLI scheduler tasks use `<LogonType>InteractiveToken</LogonType>`; `Kalshi` and `Backup` use `Password`. Recorded as a fact about the deployed schedule. Not investigated, per the standing ruling that long collection gaps are deliberate operator downtime.

### AI PROCESS NOTES (KT Rank 5)

- **Three prompt defects this session, all authored by the chat-side partner.** (1) A UTF-16 decode applied to a directory glob (`scheduler/*`) when Claude Code's own prior run had already reported that the `.xml` files specifically are UTF-16 — feeding a UTF-8 markdown file to a UTF-16 decoder produced a decode error and ~440 lines of mojibake. Correct glob was `scheduler/*.xml`. Template applied over evidence already in hand. (2) The inventory's output file was written into the directory being grepped, so `git grep --untracked` matched the file's own growing contents across six steps. Fixed by pathspec exclusion. (3) The Decision Log entry was drafted as a `## D-00X` heading with bold-label sections, a format the file does not use — corrected only after reading `Decision Log.md`, which contains dated prose paragraphs with no headings and no D-numbers.
- **A date was asserted without being read.** The memo header dated the inventory 2026-08-08; it was generated 2026-08-10. No artifact was consulted.
- **A revisit trigger was drafted before the evidence that would falsify it.** The 2 GB threshold was written prior to running the volume query and would have fired in ~11 collection-days. Recurrence of the established pattern: verification criteria must be checked against evidence already in hand. Caught only by running the query the same session.
- **Claude Code undercounted the scheduler XMLs as four in its second run; disk shows five** (`Backup`, `CLI_Primary`, `CLI_Amendment`, `CLI_Final`, `Kalshi`). Its first run said five and was correct. Settled by an independent directory read, not by preferring either run.
- **Claude Code correctly halted twice rather than working around errors** — once on the iconv failure, once on output truncation. Both stops were the hard constraints functioning as designed; neither error was self-corrected by the drafting partner.
- **A conditional in the memo was overruled by its own author on reflection, not honoured mechanically.** §4 item 2 said a large DB should flip the recommendation to Option C. Working it against real numbers showed the two tasks are volume-independent — splitting `market.db` moves Kalshi bytes whether or not F2 exists — so the conditional was poorly reasoned and was withdrawn rather than followed.

## 2026-08-10 — DIAGNOSTIC: five-city truth stream confirmed; executable spread measured; dead-zone constraint relocated to fees

**Session type:** Diagnostic, not a task. Post-Task-3. Two read-only queries at the Architect's terminal. No code, no schema, no DB mutation, no commit to the pipeline repo.
**Trigger:** Timeline analysis raised two questions the existing data could answer directly — whether CLI truth was running one city or five, and whether the microstructure dead zone leaves room to transact at all.
**Status:** E3 — Ratified by Architect 2026-08-10 (Invariant 3)

### FINDINGS

- **CLI truth is running five-city and has been since project start.** `raw_nws_cli` by `location_id`: PHX 53 (2026-07-13 → 2026-08-09), AUS 44 (from 2026-07-16), MIA 28, MDW 28, NYC 27 (all from 2026-07-15, all current to 2026-08-09). Count spread is explained by Phoenix's two-day head start and dual-report cadence, not by collection gaps. **The accrual clock runs at full width, not one-fifth.** Annual-cycle completion therefore falls around mid-July 2027; that is the earliest date on which a seasonal-artifact-free edge claim is defensible.
- **Report-kind and parser-version split is consistent with F-01 history.** 146 preliminary / 34 summary; 146 parser v2 / 34 parser v1 — the summaries are the older migrated stream. Confirms shape only. The read-authority question (`SESSION_HANDOFF_2026-07-20_F01.md:107`, double-counting on climate_day joins) remains OPEN and is untouched by this finding.
- **Executable YES spread measured over 101,659 two-sided observations** (of 166,045 total; 61% two-sided). Median spread is **$0.01 in every mid-price bucket from 0.0 through 0.7**, p90 $0.02–0.03, widening to a $0.02 median only in the thin 0.8–0.9 buckets. Zero crossed books, zero unparseable rows.
- **Data-integrity finding in passing:** the fixed-point TEXT price columns parse cleanly with no float artifacts and no crossed quotes across 101,659 rows. The schema docstring's claim that prices are stored verbatim as API-returned strings is supported by evidence, not merely asserted.
- **CONSEQUENCE — the dead-zone constraint is fee-dominated, not spread-dominated.** A $0.01 median spread in the 0.4–0.6 band is about as tight as these markets get; the spread does not disqualify the project. But spread is only half the cost of entry. Kalshi's fee scales with price×(1−price) and is maximised at 0.50 — precisely the band where genuine forecast disagreement lives. At a one-cent spread the fee almost certainly dominates. **The V2 gate question is therefore restated: not "is there a spread to cross" but "does detectable divergence Δ exceed the ROUND-TRIP FEE at price."** This is a sharper and better-posed gate than the one previously carried.
- **Open input, not yet on file:** Kalshi's current published fee schedule. Required to compute the true cost floor. Must be read from Kalshi's live terms — NOT reconstructed from AI memory or from any figure in this log.
- **Live-DB behaviour observed and behaving as documented:** `kalshi_observations` read 165,685 earlier in the same session and 166,045 later. The scheduler wrote 360 rows mid-session. Consistent with CLAUDE.md's sharp-edge warning; absolute row counts remain unusable as verification criteria.

### AI PROCESS NOTES (KT Rank 5)

- **Column names asserted without reading the DDL.** The `location_id` / `climate_day` query was drafted from the shape of the problem, not from `storage/schema.py`. The columns happened to exist. **Right by luck is not right by verification** — the schema was only read afterwards, at which point the guess was confirmed. Same error class as the confabulated-artifact failures already on record; it produced no damage this time purely by chance.
- **A one-command query was mis-scoped as a build session.** The dead-zone check was proposed as work requiring blob parsing and a gated Claude Code build. Reading `storage/schema.py` revealed `yes_bid_dollars` / `yes_ask_dollars` already exist as parsed columns, collapsing the task to a single read-only query. The over-scoping came from reasoning about the data model instead of reading it.
- **A timeline projection was built on an unverified premise.** The prior analysis treated a possible one-fifth accrual rate as a live branch and named CLI expansion as potentially the highest-leverage item on the board. Disk refuted it in one query. The row-count inference (180 rows at ~6.3/day implying more than one city) had been available and was not pursued to conclusion before the projection was written.
- **Positive:** the ordering held — query first, interpret second. Both findings above were read off output rather than predicted, and the spread result was explicitly not allowed to clear the project on its own, since fees remained unmeasured.

## 2026-08-11 — BACKUP VERIFICATION DEFECT: row-count equality ruled out, bounded-prefix check ruled in; eighteen days of unbacked-up data quantified

**Task:** Diagnose why `scripts/backup_db.py` has failed every run since late July, and rule on the correct verification predicate. Memo-and-decide session — no code, no schema, no DB mutation, no commit to the pipeline repo.
**Ruling:** Replace live-vs-snapshot dict equality with a per-table `id`-ceiling bounded-prefix check captured inside a single read transaction. Add `kalshi_observations` to `COUNTED_TABLES`. A missing counted table becomes a hard failure rather than `-1`. Pruning, the off-site leg, the filename-stamp defect and content-level hash verification are excluded and recorded.
**Artifacts:** Decision Log entry 2026-08-11 (E3). `backup_drive_survey_2026-08-11.txt` (Claude Code, read-only, 3.16 KB, untracked scratch). Chat-side memo, E4, not filed in the vault.
**Session:** 2026-08-11. Chat-side Claude as planning/review partner, reading `scripts/backup_db.py`, `logs/backup_health.log`, `CLAUDE.md`, `storage/schema.py`, `storage/snapshots.py`, `config.yaml`, `run_backup.bat`, the review, and both repos' refs through the research-lab-files connector. One Claude Code invocation, read-only, one output file. All connector reads are AI testimony; the Architect's terminal remains the authority.
**Status:** E3 — Ratified by Architect 2026-08-11 (Invariant 3, per guardrail 3)

### FINDINGS

- **The verification is wrong and the snapshots were good.** `backup_db.py:157` compares `dict != dict` — exact equality across three tables at once. In nineteen failures the snapshot is a *superset* of the live baseline, never once a subset; `raw_nws_cli` matches exactly every run and only the two Kalshi-fed tables drift; `PRAGMA integrity_check` returned `ok` all nineteen times. `table_counts(LIVE_DB)` is read, `VACUUM INTO` runs, the five-minute Kalshi sweep writes during that window, and the script discards a valid, transactionally consistent copy. **This is the exact defect CLAUDE.md guardrail 4 names: an absolute row count used as a verification criterion on a live database.**
- **Two premises carried into the session were falsified by reading the log in full.** The failures begin **2026-07-23, not 2026-07-24**, and **2026-07-24 succeeded after the first failure** — a one-second `VACUUM` against a 48 MB file, the race being won once rather than evidence the defect was absent. And **there is no gap between 2026-07-24 and 2026-08-06**: every day is present in the log and every day failed. Nineteen failures total, eighteen consecutive, most recently `2026-08-11T05:01:03Z`.
- **The compounding is measured, not asserted.** The `VACUUM` window ran 1 s on 2026-07-24 and 50 s on 2026-08-11, nearly doubling between 08-10 and 08-11 alone on a 9% file-size increase. The full exposure window (live count read to snapshot count read) is now 58 s, roughly 19% of the Kalshi sweep interval. The defect widens daily and cannot self-recover.
- **A failed run deletes its own snapshot.** `shutil.rmtree(tmp_dir, ignore_errors=True)` executes one line before `fail()` at every failure exit, and the target lives in a `tempfile.mkdtemp(prefix="pipeline_backup_")` directory under `%TEMP%`, never on `D:`. Eighteen valid, integrity-checked snapshots were created and destroyed. Failure occurs before compression, so no `.gz` and no `.sha256` was ever produced by a failed run and nothing partial can have reached the backup drive. **The cost of this defect is eighteen days of backup coverage, not data corruption.**
- **The drive evidence loop is closed and byte-exact.** The survey confirms seven generations plus seven sidecars, 14 files, 8,549,192 bytes, no subdirectories, no unexpected files. A figure derived independently from the log's `Compressed:` lines gave 8,548,548 bytes for the seven archives; the difference of 644 bytes is exactly seven 92-byte sidecars. `pipeline_2026-07-24.db.gz` is a valid gzip, its SHA-256 matches the sidecar written eighteen days earlier, its uncompressed size (48,668,672) matches the log, and its internal row counts (`raw_nws_cli` 68, `snapshot_blob` 12,598, `snapshot_index` 17,100) match the `2026-07-24T05:00:02Z` log line exactly. `integrity_check` returns `ok`. **The problem is a predicate defect, not a data-loss event.**
- **The 800x size jump between the oldest and newest generation is explained and benign.** The discontinuity is at `2026-07-22T05:00Z` — live DB 253,952 to 8,413,184 bytes, `snapshot_blob` 44 to 2,137 — and the survey confirms it from inside the file: 8,520 `kalshi_observations` rows in the 07-24 generation, in a table that barely existed a week earlier. That is the Kalshi observation collector coming online. Both endpoints of the jump are trustworthy.
- **The exposure, quantified against the stream that actually matters.** The newest surviving generation holds **8,520 `kalshi_observations` rows**. Live stood at 166,045 on 2026-08-10 (E3, Architect's terminal). **A restore from the newest surviving backup would lose at least 157,525 rows of the `[ACC][IRR]` stream — roughly 94.9% of it — plus approximately 326,930 `snapshot_index` rows, 246,123 blobs and 901 MiB.** Kalshi order-book depth is irreversible by design; candlestick OHLC does not preserve the ladder.
- **`snapshot_blob` has no integer id, and a naive prefix check keyed on its rowid would be unsound.** `storage/snapshots.py` declares `hash TEXT PRIMARY KEY`; the table's only monotonic column is the implicit rowid, and SQLite permits `VACUUM` to renumber rowids for any table lacking an explicit `INTEGER PRIMARY KEY`. `VACUUM INTO` is a `VACUUM`. The ruled handling derives that table's ceiling from `snapshot_index` and asserts hash reachability, which verifies Invariant 3's no-dangling-index-row property on the restored copy rather than a bare count. `raw_nws_cli`, `kalshi_observations` and `snapshot_index` all carry `id INTEGER PRIMARY KEY AUTOINCREMENT` and are safe.
- **Two deeper faults sit beneath the visible one.** `table_counts()` runs three `SELECT COUNT(*)` statements in autocommit with no `BEGIN`, so the live baseline is a smear across three unsynchronised instants — four seconds apart on 2026-08-11 — rather than one consistent view; **no sound inequality can be built against a baseline that was never simultaneous.** And the `-1` sentinel for a missing table compares equal to itself, so an omitted table would pass verification while verifying nothing — inert today only because all three counted tables exist, and load-bearing the moment `kalshi_observations` is added.
- **`snapshot >= live_before` was evaluated and rejected as insufficient.** It has no upper bound, its band width equals the rows written during the window so a loss offset by a concurrent gain lands dead-centre and passes, its endpoints are both fuzzy for the smear reason above, and its precision degrades on exactly the same clock as the defect it replaces. It also depends silently on Invariant 1: `live_before <= live_after` holds only because the schema is append-only.
- **Operational guardrail 2 is currently unsatisfiable, and it blocks the arc.** The guardrail reads "Before any DB mutation: run `scripts/backup_db.py`." With no working backup for eighteen days, every DB mutation on the board is blocked behind this — the pending F-01 eight-row re-derivation, Task 4's `collection_runs` DDL, any `ALTER`. **This work sequences ahead of F2 on governance grounds rather than schedule.**
- **The drive is not the problem and never was.** `D:` holds 1,527,661,043,712 bytes free of 2,000,363,188,224. Seven generations total 8.5 MB. Nothing is accumulating because nothing is succeeding. `C:` holds 448,479,432,704 bytes free, and the survey found **no orphaned `pipeline_backup_*` directories under `%TEMP%`** — the cleanup has succeeded nineteen times.
- **Review §16 predicted this in July and named it precisely.** §5: "Backup. Script: excellent. System: incomplete — local target, no restore test, no retention, logs out of scope." All four remain true. §15 action 9's tested restore is now partially discharged in substance, though not as a logged ratified restore test: the survey decompressed a generation, opened it read-only, and read row counts out of it.

### DEFECTS RECORDED, NOT ACTIONED (KT Rank 5)

- **`backup_db.py:117` stamps filenames in LOCAL time while every log line is UTC, and a successful run silently overwrites a same-stamped generation.** `shutil.move` at line 192 overwrites without warning. Nine successful runs produced seven files. **Now confirmed from the drive itself, not merely inferred:** `pipeline_2026-07-17.db.gz` carries mtime `2026-07-18 01:12:05Z` — the second run's timestamp, not the first at `00:49:12Z` — and `pipeline_2026-07-21.db.gz` carries `2026-07-22 02:38:34Z` at 25,918 bytes, overwriting a 23,638-byte generation. The docstring guarantees the previous generation is untouched *on failure*; there is no corresponding guarantee on success. Both losses were manual out-of-schedule runs, so operational exposure today is low. Travels with pruning.
- **`shutil.rmtree(..., ignore_errors=True)` makes a failed cleanup silent.** Zero orphans found across nineteen failed runs, so the path is unrealised — but this is evidence the cleanup worked, not proof it cannot fail. An undetected failure would strand a ~1 GB file per run on `C:` with no log line. Recorded, downgraded, not closed.
- **`backup_db.py:30` imports `os`, unused.**
- **`*.txt` is not gitignored, and `auto_backup.bat` runs `git add -A` followed by `git push origin main`.** If that wrapper runs on a schedule, `backup_drive_survey_2026-08-11.txt`, `task3_inventory.txt` and `SESSION_DELTAS_2026-08-04.txt` will be committed and pushed despite the standing instruction not to stage them. **Whether `auto_backup.bat` is scheduled was NOT verified** — the five known Task Scheduler XMLs are `Backup`, `CLI_Primary`, `CLI_Amendment`, `CLI_Final`, `Kalshi`. Recorded as a conditional, not a claim.
- **`backups/pipeline_pre_f01_migration_20260720_224306.db` (192 KB, 2026-07-20) exists at the pipeline repo root.** A one-off pre-migration safety copy, not a backup generation, and gitignored by `*.db`. Recorded so no future reader mistakes it for backup coverage during the eighteen-day window.
- **No pruning exists.** Line 208 counts generations by glob; nothing deletes. Excluded from this change deliberately — it is a delete against a capacity risk that is not realised, and it wants its own approval surface. **Scheduled as the next backup-track task rather than deferred**, since resumed backups run near 0.9 GB compressed per day and rising.

### AI PROCESS NOTES (KT Rank 5)

- **The memo applied the defect's own blind spot to its own impact assessment.** §5 sized the exposure at 326,930 `snapshot_index` rows, 246,123 blobs and 901 MiB — every figure drawn from `backup_health.log`, which reports only the three tables `COUNTED_TABLES` names. The same memo argued two sections earlier that `kalshi_observations` is the omitted, irreplaceable table. **The exposure figure inherited the exact omission the memo was ruling on, and the survey had to supply the number.** The row count for that table at 07-24 was genuinely unreachable from the log or from the connector, so the missing figure was not the error; **the error was stating the exposure without flagging that it was incomplete in a known direction and probably dominated by the unmeasured term.** Same class as the recorded 2026-08-04 and 2026-08-06 pattern: holding a discipline and applying it to one's own inputs are separate acts.
- **The ratified Decision Log entry carries that understated figure.** It is incomplete rather than false. Under Invariant 1 an append-only log is corrected by a superseding entry, not an edit; whether this rises to that threshold is an open Architect call, and the sharper number is recorded here in the meantime.
- **Reading `storage/snapshots.py` before proposing the predicate is what caught the `snapshot_blob` rowid trap.** Had the bounded-prefix check been designed from the shape of the problem rather than the DDL, it would have keyed on rowid and shipped a verification that is unsound in a way that passes green most of the time — the worst available failure class, in the file whose entire purpose is verification. **This is the 2026-08-10 "column names asserted without reading the DDL" failure not recurring, and this time the read is what caught it rather than luck confirming a guess.**
- **`Decision Log.md` was read before the entry was drafted.** The Task 3 defect — a Decision Log entry drafted with `## D-00X` headings the file does not use — did not recur.
- **The Claude Code prompt banned searching the pipeline repo outright and excluded its own output file by pathspec.** The Task 3 defect, where `git grep --untracked` matched its own growing output across six steps, did not recur.
- **Survey item (d) was executed in `%TEMP%` rather than on `D:`, because reading the code showed that is the only place a `VACUUM INTO` target is ever created.** Checking the backup drive alone would have executed the item in the wrong location and returned a clean result that meant nothing.
- **Reading the log in full rather than tailing it is what falsified both carried premises.** The 07-23 failure and the 07-24 success sit in the middle of the file; a tail would have shown an unbroken failure streak and confirmed the briefing.
- **Scope was expanded once, deliberately, and it is a judgment call rather than a clean win.** On seeing `backups/` and `auto_backup.bat` in a directory listing, the partner read both plus `.gitignore` mid-report rather than queueing them — reasoning that a wrapper running `git add -A && git push` in a repo containing `secrets.yaml` is a potential credential exposure, and that a ratified entry claiming eighteen days of no backup should be checked against a directory literally named `backups`. Both came back clean (`secrets.yaml` and `*.db` are gitignored; the file is a one-off pre-migration copy). **The check was cheap and the ratified entry survived it, but the same instinct is how a memo-only session becomes a three-thread investigation. Recorded as a live tension, not as a precedent.**

## 2026-08-12 — BACKUP VERIFICATION CHANGE SHIPPED: bounded-prefix predicate and first tests landed; VACUUM INTO's snapshot mechanism measured and a ratified criterion falsified

**Task:** Implement the ratified 2026-08-11 change in `scripts/backup_db.py`, create `tests/test_backup_db.py` from nothing, run the full suite, run the backup live against the production database, and commit. Code session — one commit to the pipeline repo.
**Rulings:** interim verified snapshot taken first as the dominant removable risk; the `run_backup.bat` notify hook authorised as a gated second commit and later DROPPED under its own gate; the void-run criterion replaced with log-only superset-delta diagnostics that can never gate a run; the concurrency test restructured to be deterministic; the 2026-08-11 Decision Log entry superseded in three particulars.
**Artifacts:** pipeline commit `5b53a4b3dace5e40e5cb30c4983112b172667c44` (from `8a0a28c`), pushed. Decision Log entry 2026-08-12 (E3). `D:\Backups\manual_interim\interim_manual_20260811T183645Z.db` (interim, NOT a generation). `D:\Backups\weather-pipeline\pipeline_2026-08-11.db.gz` plus sidecar (generation 8). Five untracked scratch results files at the pipeline repo root: `BACKUP_VERIFICATION_TASK_RESULTS.txt`, `BACKUP_SUITE_RESULTS.txt`, `BACKUP_FINAL_RESULTS.txt`, `BACKUP_DOCFIX_RESULTS.txt`, `BACKUP_LIVERUN_RESULTS.txt`.
**Session:** 2026-08-12 UTC (2026-08-11 evening local). Chat-side Claude as planning/review partner. Five Claude Code invocations, each a separate approved artifact writing to a named results file read back through the connector. Two Architect-run Git Bash actions: the interim snapshot query, and the commit and push. All connector reads are AI testimony; the Architect's terminal remains the authority.
**Status:** E3 — Ratified by Architect 2026-08-13 (Invariant 3)

### FINDINGS

- **Commit 1 landed and pushed: `8a0a28c` → `5b53a4b3dace5e40e5cb30c4983112b172667c44`**, two files, 12.23 KiB. `scripts/backup_db.py` modified, `tests/test_backup_db.py` new. Local and origin-tracking refs confirmed identical from disk after the push. **Operational guardrail 2 is satisfiable again**, which unblocks the pending F-01 eight-row re-derivation, Task 4's `collection_runs` DDL, and every other DB mutation on the board.
- **The exposure was closed before any code review began, on the Architect's ruling.** An interim verified `VACUUM INTO` at `2026-08-11T18:36:45Z` produced `interim_manual_20260811T183645Z.db`, 1,029,144,576 bytes, `integrity_check` ok, holding `kalshi_observations` 178,789 / `raw_nws_cli` 186 / `snapshot_blob` 269,455 / `snapshot_index` 357,756. Deliberately outside `D:\Backups\weather-pipeline` and not matching `pipeline_*.db.gz`, so it is not a managed generation and cannot be swept by the pruning task. **Eighteen days of exposure on an irreplaceable corpus removed by one read-only command, about a minute of work, before a line of the fix was written.** The correct first move in a session about a broken backup was not to review code.
- **All eight ruled rows implemented, and verified against the source rather than against the implementer's own audit.** Baseline captured in a single `BEGIN`/`COMMIT` read transaction; bounded-prefix check keyed on a per-table `id` ceiling captured in that same transaction; `snapshot_blob` verified by hash reachability from the `snapshot_index` prefix, never by rowid; `kalshi_observations` added to the counted tables; a missing counted table now a hard failure at exit code 22 naming the table, replacing the `-1` sentinel; ceilings and verified prefix counts logged every run; the line 6 WAL docstring corrected by transcription from `CLAUDE.md`; and `tests/test_backup_db.py` created from nothing.
- **Two structural consequences were surfaced for ruling rather than folded in.** Row 8(a) required lifting the comparison out of the inline `if` at line 157 into `verify_snapshot_prefix`, a named importable predicate that returns data and calls neither `fail()` nor `sys.exit()` nor `log_line()` — 8(a) is unsatisfiable without it. The log-line test requirement then required lifting the success-line construction out of `main()` into `format_verification_log`, a pure function, because `main()` cannot run in a test. Both were ruled in.
- **THE MECHANISM WAS MEASURED, AND IT FALSIFIED A CRITERION THAT HAD ALREADY BEEN RATIFIED.** `VACUUM INTO` runs inside its own read transaction; under WAL snapshot isolation that transaction's view is fixed at acquisition, so rows committed afterwards never reach the snapshot however long the page copy runs. Evidence: in a recorded full-suite run the concurrency test's first two guards passed — the writer demonstrably committed rows above the ceiling _while_ `VACUUM INTO` was executing — while the third failed with `assert 0 > 0`, the snapshot containing none of them. **A direct observation, not an inference from documentation.** The interval that governs whether a snapshot is a superset is baseline-read-snapshot-instant to VACUUM-read-transaction-acquisition, not the copy duration. Both scale with file size, so every conclusion of the 2026-08-11 ruling survives; its causal sentence does not. Recorded in the 2026-08-12 superseding Decision Log entry (E3).
- **The void-run criterion was consequently rebuilt, and deliberately kept out of the script's control flow.** A run in which nothing was written between the baseline and the VACUUM's snapshot instant is a legitimately successful backup — a perfectly good copy of a quiet database. Wiring the superset comparison as an assertion would reject valid data on writer timing, a structural re-run of the original defect in new clothes. The script therefore computes a per-table superset delta and **logs it as diagnostic output only**: it appears in no conditional, cannot reach `fail()`, and cannot alter the exit code. Whether a given run was DEMONSTRATIVE is an Architect judgment applied to evidence after the fact, which is where a void criterion always belonged.
- **The live run was designed, not hoped for.** `scheduler/WeatherPipeline_Kalshi.xml` gives `StartBoundary 2026-07-21T00:00:00` with `Repetition PT5M`, so sweeps fire on exact five-minute wall-clock boundaries; `logs/kalshi_obs_2026-08-11.log` shows the 21:00:00 sweep finishing at `21:00:21.64` after 60 observations — a ~21-second write burst. Launching `backup_db.py` on a boundary puts the baseline scan inside that burst by construction. **Reading two artifacts is the difference between a coin flip and a designed collision.**
- **Live run `2026-08-12T01:10Z`, exit 0, all nine gating criteria met.** Baseline `raw_nws_cli` ceiling 191, `kalshi_observations` 183,469, `snapshot_index` 367,121. VACUUM 8 s; `integrity_check` ok; verified prefix counts matching with `dangling=0`; superset deltas `kalshi_observations` +6, `snapshot_index` +12, `snapshot_blob` +10, `raw_nws_cli` 0; compressed 157,924,782 bytes; sidecar digest matching the `BACKUP OK` line; generations 7 to 8; no `pipeline_backup_*` orphan under `%TEMP%` on the first pass through the _success_ exit path, a different branch from the nineteen audited failures. **The old predicate would have compared 367,121 against 367,133 and failed with the exact signature of the nineteen failures. The new one accepted the snapshot and produced a verified generation.** `raw_nws_cli` at zero is correct: CLI sweeps run 18:00, 23:30 and 00:30 local.
- **The backup script now has tests, having had none across nineteen production failures.** Full suite 107 tests, three consecutive green runs after the determinism fix and one further green run after the docstring corrections. `tests/test_backup_db.py` carries: negative truncation tests parametrized over all three ceiling tables, exercised through the real call site so a `return True` implementation would fail four tests; a dangling-blob test proving the hash-reachability leg is not decorative; missing-table tests on both the live and snapshot sides; a synthetic-concurrency test with a background writer and deterministic rows landing between baseline and VACUUM; and superset-delta tests including a quiet-database case whose entire purpose is to prove the diagnostics are not a gate.
- **The first successful generation measures the backup track's real economics.** 157,924,782 bytes compressed from a 1,055,240,192-byte snapshot — a 6.7x ratio identical to the 2026-07-24 generation's 6.74x. The queued figure of "near 0.9 GB compressed per day" was the _uncompressed_ snapshot size read as if it were the generation, overstating daily volume by a factor near six. Corrected in the 2026-08-12 Decision Log entry, where the pruning runway is restated at roughly 443 days on generation growth rather than on daily volume.

### DEFECTS RECORDED, NOT ACTIONED (KT Rank 5)

- **The line 117 local-vs-UTC filename stamp is now visible in a _successful_ run.** The generation landed as `pipeline_2026-08-11.db.gz` while its own log lines read `2026-08-12T01:10:xxZ`. No collision occurred — D: held only 2026-07-17 through 2026-07-24, and the next scheduled 05:00Z run stamps `2026-08-12`. Travels with pruning.
- **Exception masking in `read_live_baseline`.** `finally: conn.execute("COMMIT")` runs on the exception path. If that COMMIT ever raised it would replace a pending `MissingTableError`, and `main()` would exit 12 ("cannot read live DB") instead of 22 naming the missing table. COMMIT on an active read-only transaction essentially cannot fail; unrealised, not closed.
- **An entirely empty counted table verifies trivially green.** `COALESCE(MAX(id), 0)` with `WHERE id <= 0` yields a prefix count of 0 on both sides. Inert today — all four tables are populated and absence is caught by the presence check — but structurally the same shape as the `-1` sentinel this change removed.
- **`backup_health.log` changes format mid-file**, `rows {...}` becoming `prefix_counts {...}` plus superset deltas. Nothing parses the log, but the 2026-07-24 forensic reconstruction was done by reading `rows {...}` out of old lines, so a future reader will meet a discontinuity.
- **VACUUM duration is not a stable metric and must not be cited as a trend.** 8 s against 1,059,291,136 bytes warm, against 50 s at 993,738,752 bytes cold twenty hours earlier. Page-cache state dominates. Meanwhile the baseline read grew from 4 s to 10 s now that `kalshi_observations` is counted — the interval that actually governs the defect widened while the interval previously cited narrowed. The 10-second read transaction also defers WAL checkpointing for its duration; harmless daily, recorded.
- **Eight untracked scratch `.txt` files now sit at the pipeline repo root**, five produced this session. The `auto_backup.bat` `git add -A` plus `git push origin main` conditional is unchanged in kind and larger in degree. Whether that wrapper is scheduled remains UNVERIFIED.
- **A Claude Code invocation wrote an unread ~50-line launcher script during the live run**, against a constraint permitting exactly one new file. It governed the boundary wait, the timeout and the exit-code capture. Named rather than glossed. It did not affect the verdict: eight of nine criteria were checkable from `backup_health.log` and the D: listing, neither of which it produced, and `log_line("BACKUP OK ...")` is the statement immediately before `sys.exit(0)`.
- **`Bootstrap_Log.md` itself carries pre-existing mojibake.** The 2026-07-25 entry title renders `ΓÇö` where an em-dash belongs — a UTF-8 sequence written through a cp1252 path. Cosmetic, pre-dating this session, recorded so it is not mistaken for new damage.

### AI PROCESS NOTES (KT Rank 5)

- **E3 records who signed, not whether the thing is true.** The void-run criterion — "the log must show a concurrent write during the VACUUM" — was false. It originated in the partner's memo, passed through Architect ratification, and neither party caught it. It was then falsified by evidence produced _after_ ratification, by the very work the ratification authorised. Ratification is a statement about authority, not about correctness; a ratified criterion can still be wrong, and the discovery that it is wrong is not a governance failure but the system working.
- **Do not declare a file final before the verification that depends on it has run.** `scripts/backup_db.py` was called complete and verified against all eight rows, then reopened twice — once for the superset-delta logging, once for two false docstrings. Both reopenings were forced by evidence that did not exist when "final" was said.
- **The commit whose Row 7 corrects a false-mechanism docstring introduced three more and repeated a fourth.** `verify_snapshot_prefix` and both test docstrings asserted that writes during the VACUUM _copy_ caused the failures; `format_verification_log` carried a cross-reference to a module docstring that does not exist; and the concurrency test's opening paragraph contradicted its own seed comment thirty lines below. All four were caught by re-reading the file after the change, not by any process step. **Holding a discipline and applying it to one's own output remain separate acts** — the same pattern already recorded on 2026-08-04, 2026-08-06 and 2026-08-11.
- **The partner's "decisive fact" against including the notify hook was a cost estimate never checked against the file it described.** It claimed extending `tests/test_wrapper_notify_exit_code.py` required surgery on a guard shared by two other wrappers; the Architect read the file and demonstrated that a second pattern, a second list and a second parametrized function are purely additive, with nothing shared rewritten. **Asserting from a model of the artifact rather than from the artifact — the same error class already on record, committed one layer up, about cost rather than about content.**
- **A wrong model of `VACUUM INTO` was written into a Claude Code instruction and produced a 1-in-3 flaky assertion.** The instruction to enlarge the test seed assumed a longer copy widens the window in which a concurrent write can land inside the snapshot; it does not. Claude Code hit its stop condition and refused to weaken the assertion to force green — **and that refusal is what surfaced the mechanism.** A correctly specified stop condition converted a bad instruction into a discovery. The fix was to make the superset condition deterministic by committing known rows between baseline capture and VACUUM, which is also more faithful to production than the raced version.
- **Arithmetic self-check on the session's only unchecked number.** The pruning runway was drafted at ~457 days using 14 MB/day of generation growth; 95 MiB/day at the measured 6.7x ratio is 14.9 MB/day, giving ~443 days. "Near fifteen months" survives and the ruling is unaffected; the figure was ~3% optimistic. Recorded so it is not carried forward unexamined a third time.
- **The one-task-per-session rule was deliberately relaxed and then partly reclaimed.** Commit 2 — the `run_backup.bat` notify hook — was authorised as a gated second commit, a knowing exception recorded as reasoned rather than as drift. It is DROPPED under its own gate: commit 1 ran five Claude Code cycles against the one planned, `5b53a4b` cut the guarded failure rate from daily to near zero, and commit 2's only real proof is the next scheduled 05:00Z run. Requeued as the first task on the backup track, ahead of pruning, with `run_backup.bat` and `tests/test_wrapper_notify_exit_code.py` untouched and nothing half-done.
- **The `research-lab-files` connector failed on a schema dialect, and a long chat paste truncated a governance entry.** The connector rejects every call with `outputSchema` declaring JSON Schema draft-07 against a 2020-12-only validator — a client/server version mismatch, not a connection fault, and unaffected by restarting the client. Access was restored by connecting both trees to the device bridge instead. Separately, this entry's first placement landed inside the ratified 2026-08-11 entry and was truncated mid-word at the file's end; it was caught by reading the file back from disk rather than trusting the report that it had been saved. **A governance entry delivered as a chat block is a lossy channel; deliver it as a file.**
