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


