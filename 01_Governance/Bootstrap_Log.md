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