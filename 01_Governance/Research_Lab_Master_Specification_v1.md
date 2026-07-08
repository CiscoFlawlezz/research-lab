# Research Lab Master Specification

**Document ID:** RL-SPEC-001
**Version:** 1.0 (Draft for Architect Review)
**Status:** Proposed — becomes canonical upon acceptance and Git commit
**Date:** 2026-07-06
**Supersedes:** None. Sits above and references: `Mission.md`, `Rules.md`, `Thinking_Framework.md`, `Research_Methodology_v2_Canonical.md`
**Author of record:** Director of Quantitative Research (drafted); Lead Quantitative Research Architect (approval authority)

---

## 0. Document Governance

This specification is the primary governing document of the Research Lab. Where it conflicts with any other document except `Research_Methodology_v2_Canonical.md`, this document prevails. Where it conflicts with the Methodology's five Invariants, the Invariants prevail — the Invariants are constitutional; this specification is statutory.

Amendments to this document require: (1) a written rationale, (2) an ADR recording the decision and its revisit trigger, and (3) a version increment committed to Git. Silent edits are prohibited by Invariant 2 (no orphan findings) extended to governance artifacts: no orphan decisions.

---

## 1. Executive Overview

The Research Lab is a solo quantitative research platform whose product is **measured, auditable knowledge about probability divergence** — specifically, divergence between independently modeled probabilities and market-implied probabilities in prediction markets. Version 1 restricts the domain to Kalshi daily high-temperature markets across five U.S. cities (KXHIGHTPHX, KXHIGHNY, KXHIGHCHI, KXHIGHMIA, KXHIGHAUS), using National Weather Service forecasts and station observations as the primary modeling input and climatology as the reference baseline.

The goal is explicitly **not prediction** and not trading. The goal is to build an instrument capable of answering, with defensible statistics, three questions:

1. How well calibrated are our modeled probabilities? (Reliability, via Murphy decomposition of the Brier score.)
2. How well calibrated are market prices, treated as probability forecasts? (The same instrument pointed at the market.)
3. Where the two disagree, whose disagreement is information and whose is noise — and at what sample size can we tell the difference?

Everything else in this specification — the append-only database, the snapshot store, the pre-registration discipline, the Obsidian vault, the Git bootstrap — exists to make answers to those three questions **reproducible, auditable, and honest about uncertainty**. A finding that cannot be regenerated from snapshots by a stranger (or by the researcher in eighteen months) does not exist.

The platform is deliberately built infrastructure-first. Milestone 1a (live data pipeline: Kalshi candlesticks, NWS forecasts, station observations, SQLite append-only storage) is complete. Research output is gated behind completion of the reproducibility scaffolding, per the Bootstrap Checklist currently in progress.

### 1.1 A note on Mission.md — flagged inconsistency

`Mission.md` as written describes a broader ambition than the project's current governing intent: it names the stock market, "popular political public personal trading information," and profitability as objectives. Three problems, raised here per the mandate to challenge assumptions:

**First**, it conflicts with the stated project status ("Goal is NOT prediction... probability research platform that measures divergence"). A mission document that describes a different project than the one being built is a latent source of scope drift and should be revised, not silently ignored.

**Second**, "largely followed popular political public personal trading information" (i.e., tracking prominent individuals' disclosed trades) is a materially different research program from weather-market calibration: different data sources, different legal considerations, different statistical structure, and far weaker ground truth. It belongs, at most, in the Version 3+ expansion strategy (§13), explicitly deferred.

**Third**, "statistically profitable opportunities" is an outcome, not a mission. The defensible mission is the instrument: a platform that can *measure* divergence with known error bars. Profitability, if it ever becomes a goal, is a downstream application gated by the validation philosophy in §11.

**Recommendation:** Amend Mission.md to a two-sentence mission — "Build a reproducible research platform that measures divergence between modeled and market-implied probabilities, beginning with weather prediction markets. Findings must be auditable, pre-registered, and honest about sample size and uncertainty." — and move the broader ambitions to a `Future_Directions.md` note in the vault with decaying status. This is a proposed change, not a unilateral one; it requires your acceptance and an ADR.

---

## 2. System Philosophy

The Lab is governed by a small number of load-bearing beliefs. These are restated here because every architectural decision in §4–§8 traces back to one of them.

**Measurement precedes edge.** A single correct forecast proves nothing; a single wrong one disproves nothing. Probabilities can only be validated at the population level. Therefore the system's fundamental output is not "a trade idea" but a **calibration record**: a growing population of (forecast probability, market price, outcome) triples at the city-day grain, scored by proper scoring rules.

**The market is a forecaster, not an oracle.** Kalshi prices are treated as one more probability forecast on the reference ladder (climatology → NWS-derived model → market price), subject to the same Brier/Murphy scoring as our own model. Divergence is only interesting relative to how each rung of the ladder scores. If the market out-resolves the model everywhere, divergence is a measure of our error, not our opportunity.

**Honest n or no n.** The statistical unit is the **city-day**, capped at roughly 150 per month across five cities. Bracket-level outcomes within a city-day are mechanically correlated; counting them inflates n by an order of magnitude and manufactures false significance. Every statistical claim in the Lab must state its n in city-days.

**Data is evidence; evidence must be chain-of-custody.** Dual timestamps (event time and ingestion time), append-only storage, snapshot-what-you-cite, and environment capture exist so that any finding can be traced to the exact bytes and code that produced it. AI-generated content — including this document — is untrusted input until independently verified (Invariant 3) and carries an evidence grade (E1–E4) only after verification.

**Pre-commitment defeats hindsight.** Experiments are pre-registered before outcomes are known. The Prediction Ledger records forecasts before resolution. Hypotheses formed after seeing the data are labeled exploratory and cannot graduate to findings without fresh out-of-sample data.

**Infrastructure before research; boredom is a feature.** The most dangerous phase of a solo research project is the exciting one. The Lab front-loads the boring scaffolding precisely because a solo researcher has no colleague to catch the shortcut taken in month one that invalidates the finding in month nine.

---

## 3. Design Principles

These principles operationalize the philosophy. Each is stated with its rationale and, where useful, the failure mode it guards against.

**P1 — Append-only truth.** The database never updates or deletes observed facts; corrections are new rows with later ingestion timestamps. Guards against: silent history rewriting, the single most common source of irreproducible backtests.

**P2 — Dual timestamps everywhere.** Every record carries both when-it-happened and when-we-learned-it. Guards against: look-ahead bias, the second most common source of irreproducible backtests. All analysis must join on ingestion time when simulating what was knowable.

**P3 — Separation of collection, storage, analysis, and judgment.** The collection layer holds no credentials beyond what ingestion strictly requires and performs no interpretation. Analysis reads storage; it never writes to raw tables. Judgment (the Thinking Framework's eight steps) is a human-plus-AI layer that consumes analysis outputs and produces vault documents. Guards against: analysis code quietly "fixing" raw data; conclusions contaminating collection.

**P4 — Everything cited is snapshotted.** No vault note, Research Summary, or ADR may cite a live URL, API response, or AI output without a recoverable snapshot in the snapshot store, referenced by content hash or immutable path. Guards against: link rot, silent upstream revisions (NWS forecasts are revised; Kalshi rules pages change).

**P5 — One canonical home per fact.** Each concept lives in exactly one vault note; everything else links to it (anti-fragmentation, enforced via Maps of Content). Guards against: divergent copies of the same definition drifting apart.

**P6 — Stakes-based process, not effort-based.** Workflow rigor scales with the stakes of being wrong, not with how hard the task felt. A five-minute query that will anchor a finding gets full pre-registration; a week of plumbing gets a log entry.

**P7 — Decisions carry revisit triggers.** Every ADR states the observable condition under which the decision should be reconsidered. Guards against: both permanent ossification and unprincipled churn.

**P8 — Human-verifiable at every seam.** Explicit stop points, verification steps after every major operation, and artifacts delivered as full file content with placement instructions. The architect (you) must be able to confirm each state before the next transition. Guards against: compounding silent failures on a solo project with no second operator.

**P9 — Windows-native, honestly.** The platform runs on Windows 11 with Task Scheduler, not on an idealized Linux box. Paths with spaces are quoted; line endings are committed as-is per the Git bootstrap decisions. Guards against: environment drift between what is documented and what actually runs. (The risk this principle *accepts* is addressed in §10, R6.)

---

## 4. Complete Architecture

The Lab is four planes plus a governance spine. No plane may reach around another.

### 4.1 The four planes

**Plane 1 — Collection (machine, scheduled).**
Python collectors at `C:\Projects\weather-pipeline`, executed by Windows Task Scheduler. Three collector families: Kalshi market data (candlesticks, market metadata for the five ticker series), NWS forecasts (gridpoint/period forecasts for the five settlement stations), and NWS station observations (the ground truth that determines settlement). Collectors are dumb by design: fetch, stamp (event time + ingestion time), append, log. No credentials live in this layer beyond the NWS user-agent contact (Milestone 1b gate) and whatever Kalshi read access requires. Collector failures are logged and surfaced, never silently retried into gaps.

**Plane 2 — Storage (machine, passive).**
Two stores with different jobs. (a) The **SQLite append-only database** — structured, queryable, dual-timestamped time series: market prices, forecasts, observations, and derived-but-reproducible tables (clearly namespaced, always regenerable from raw). (b) The **snapshot store** — immutable captures of anything cited: API response bodies, Kalshi rules pages (the Milestone 1b station-verification gate depends on these), NWS documentation, AI outputs pending verification. Snapshots are addressed by content hash and never modified.

**Plane 3 — Analysis (machine, human-invoked).**
Read-only consumers of Plane 2. This is where scoring lives: Brier scores, Murphy decompositions (Reliability − Resolution + Uncertainty), log scores, reliability diagrams, and the reference-ladder comparisons at city-day grain. Analysis runs are parameterized, environment-captured, and emit artifacts (tables, figures, result files) that are themselves snapshotted when cited. Exploratory queries are permitted here freely — but their outputs cannot become findings without passing through Plane 4's pre-registration path.

**Plane 4 — Judgment and knowledge (human + AI, governed).**
The Obsidian vault at `C:\Users\myname\Obsidian\Research Lab`. Pre-registered experiment documents, Research Summaries, the Prediction Ledger, the Glossary, Open Questions, ADRs, MOCs, and the Bootstrap Log. Every note carries a lifecycle status (evergreen / decaying / deprecated) and, where applicable, an evidence grade. The Thinking Framework's eight steps execute here. AI (Claude) operates in this plane as Director of Quantitative Research: it drafts, challenges, and structures — and everything it asserts is Invariant-3 untrusted until verified.

### 4.2 The governance spine

**Git** version-controls both the pipeline repository and the vault (as separate repositories — see §7 and ADR requirement below). Git provides: tamper-evident history for the vault's findings, code state capture for every analysis run, and the mechanism by which "the code that produced finding F" is a commit hash rather than a memory. Environment capture (Python version, package pins, OS build) accompanies every analysis artifact.

**Boundary rules (normative):**
- Plane 1 never reads Planes 3–4. Collectors do not know what hypotheses exist.
- Plane 3 never writes to raw tables in Plane 2.
- Plane 4 never contains uncited quantitative claims. A number in the vault either links to a snapshot/analysis artifact or is explicitly labeled assumption.
- Retractions propagate downward and outward (Invariant 5): retract a snapshot → flag every analysis artifact that consumed it → flag every vault note that cited those artifacts.

---

## 5. Data Flow

The canonical flow, end to end, for one city-day:

**Step 1 — Scheduled collection.** Task Scheduler fires collectors on their cadences. Kalshi candlesticks for the day's active markets in each of the five series; NWS forecast issuances for each settlement station's grid; NWS observations as they post. Each fetch appends rows stamped with event time and ingestion time. Raw response bodies for anything likely to be cited are written to the snapshot store.

**Step 2 — Settlement truth.** The station observation stream yields the daily high for each city. This is the outcome variable. Milestone 1b's gate — verifying station IDs against Kalshi's official rules pages, with those pages snapshotted — exists because a mismatch here poisons every downstream score (§10, R1).

**Step 3 — Forecast extraction.** Analysis-plane jobs read forecasts *as of* chosen ingestion times (e.g., "last NWS issuance before market close") and convert them into probability distributions over the bracket/threshold structure of each market (ticker anatomy: T### thresholds, B###.# brackets). The conversion method is itself a pre-registered, versioned modeling choice.

**Step 4 — Market-implied probabilities.** The same jobs read Kalshi prices as of the same ingestion cutoffs and normalize them into implied probabilities, with explicit, documented treatment of bid-ask spread, fees, and incomplete bracket coverage. (Untreated, these silently convert microstructure noise into fake divergence — §10, R7.)

**Step 5 — Scoring at city-day grain.** For each city-day and each rung of the reference ladder (climatology, model, market), compute Brier and log scores against the settled outcome. Aggregate into rolling Murphy decompositions and reliability diagrams. n is counted in city-days, full stop.

**Step 6 — Ledger and divergence record.** Pre-registered forecasts enter the Prediction Ledger before resolution. Post-resolution, the ledger updates with outcomes and scores. Divergence observations (|model − market| above pre-registered thresholds) are recorded as *phenomena to explain*, not signals to act on.

**Step 7 — Judgment.** When a pre-registered question reaches its pre-registered n, the Thinking Framework runs: restate, facts, missing information, estimate, uncertainty, value-of-information, market comparison, and — only with expected value and uncertainty explicit — any recommendation. Output is a Research Summary in the vault, evidence-graded, linked into MOCs, citing only snapshots.

The reverse flow — retraction — follows Invariant 5 along exactly these edges, in reverse.

---

## 6. Database Philosophy

SQLite, append-only, dual-timestamped. This section records why, what it implies, and where it will break.

**Why SQLite is correct for V1.** One writer (the scheduler), one reader (the researcher), one machine, data volumes in the tens of megabytes per month. SQLite is a single file — which makes the entire raw history trivially snapshottable, trivially backed up, and free of a database server as a moving part or attack surface. For a reproducibility-first solo lab, "the database is a file you can hash" is a feature no client-server system matches.

**What append-only means precisely.** Raw tables receive INSERTs only. Upstream corrections (NWS revises an observation; Kalshi amends market metadata) arrive as new rows; the "current best" view is a query (latest ingestion time per key), never an UPDATE. Derived tables may be dropped and rebuilt freely because they are regenerable functions of raw tables plus versioned code — they are cache, not truth.

**What dual timestamps buy.** Every backtest-style question ("what did we know at market close on 2026-07-03?") is answerable exactly, by filtering on ingestion time. This is the difference between a calibration study and a look-ahead-contaminated anecdote.

**Where it will break, and the pre-registered triggers.** (1) Concurrent writers — if V2 adds collectors on overlapping schedules writing heavily, SQLite's single-writer lock becomes contention; trigger: observed lock timeouts in collector logs. (2) Analytical scale — reliability diagrams over years of tick-level candles may outgrow comfortable SQLite query performance; trigger: routine analysis queries exceeding minutes. (3) Multi-machine — any future second machine ends the single-file model; trigger: the decision itself. The pre-committed migration path is SQLite → DuckDB for analysis (reading the same file or Parquet exports) before any move to a server database; this preserves the file-based reproducibility property longest. Record as ADR with these triggers.

**Backup discipline.** The database file and snapshot store are backed up on a schedule, off-machine, with restore actually tested (an untested backup is a hypothesis, not a backup). This is a Bootstrap Checklist item if not already present — flagged in §10, R5.

---

## 7. Folder Structure

Two Git repositories, deliberately separate: code evolves by refactor; knowledge evolves by accretion. Mixing them makes both histories noisy and couples a code rollback to a knowledge rollback. (If you prefer a single repository, that is a defensible ADR — but decide it explicitly.)

### 7.1 Pipeline repository — `C:\Projects\weather-pipeline`

```
weather-pipeline/
├── README.md                  # What this is; how to run; links to spec & methodology
├── config.yaml                # Stations, tickers, cadences, NWS user-agent (1b gate)
├── .gitignore                 # DB files, snapshots, secrets, __pycache__, venv
├── environment/               # Environment capture: pinned requirements, OS notes
├── collectors/                # Plane 1: kalshi_markets, nws_forecasts, nws_observations
├── storage/                   # Schema definitions, migrations, append-only helpers
├── analysis/                  # Plane 3: scoring, murphy, reliability, ladder comparisons
├── scheduler/                 # Task Scheduler task definitions (exported XML) + docs
├── logs/                      # Collector & run logs (gitignored; retained on disk)
├── data/                      # SQLite file(s) (gitignored; backed up separately)
└── snapshots/                 # Content-addressed snapshot store (gitignored; backed up)
```

Data and snapshots are gitignored because Git is for code and text, not for multi-gigabyte binary history; their integrity is protected by the backup discipline and content hashing, not by Git.

### 7.2 Vault repository — `C:\Users\myname\Obsidian\Research Lab`

(Path contains a space; quote in all commands.)

```
Research Lab/
├── 00_MOC/                    # Maps of Content — the anti-fragmentation layer
├── 01_Governance/             # This spec, Methodology v2, Mission, Rules,
│                              #   Thinking Framework, Bootstrap_Log, ADRs/
├── 02_Glossary/               # One note per term (28 seeded)
├── 03_Open_Questions/         # Register (7 active) + one note per question
├── 04_Experiments/            # Pre-registrations (from template) + results, paired
├── 05_Research_Summaries/     # Graded findings; the Lab's actual output
├── 06_Prediction_Ledger/      # Forecast records: pre-resolution & resolved
├── 07_References/             # Annotated bibliography (scoring rules, 10 items)
└── 08_Archive/                # Deprecated notes — moved, never deleted
```

Numbering matches the walkthrough structure already in progress (Sections 3–7 pending); reconcile any naming differences during that walkthrough rather than renaming retroactively.

---

## 8. Module Responsibilities

Stated as contracts: what each module owns, what it must never do.

**Collectors (Plane 1).** Own: fetching, stamping, appending, snapshotting raw responses, logging success/failure. Must never: interpret, filter by hypothesis, retry silently into data gaps, or hold analysis logic. A collector that "cleans" data is a bug.

**Storage/schema module (Plane 2).** Owns: table definitions, the append-only insertion helpers, the "latest-as-of" query views, migration scripts (additive only for raw tables). Must never: expose an UPDATE/DELETE path on raw tables.

**Snapshot store.** Owns: content-hash addressing, immutability, an index mapping hashes to provenance (URL, fetch time, fetching component). Must never: permit overwrite; a changed document is a new snapshot.

**Scoring module (Plane 3).** Owns: Brier, log score, Murphy decomposition, reliability diagrams — implemented once, unit-verified against known worked examples from the vaulted bibliography before first use (verify-before-grade applies to code Claude writes, too). Must never: read anything except storage; write anything except versioned artifacts.

**Ladder module (Plane 3).** Owns: constructing the three reference forecasts per city-day (climatology from historical observations; model from NWS forecast conversion; market from normalized prices) at explicit ingestion-time cutoffs. Must never: mix cutoffs between rungs within a comparison.

**Prediction Ledger (Plane 4).** Owns: the pre-resolution record of every registered forecast, and its post-resolution scoring. Must never: accept a forecast after its outcome is knowable.

**Experiment machinery (Plane 4).** Owns: the pre-registration template, stakes-based track assignment, the pairing of registration to result. Must never: allow a result note without a prior registration note (exploratory work is labeled as such and lives outside 04_Experiments until registered and re-run).

**ADR log (governance spine).** Owns: every non-trivial decision, its rationale, alternatives considered, and revisit trigger. Must never: be updated in place — superseding ADRs reference their predecessors.

**Claude (Plane 4 role: Director of Quantitative Research).** Owns: drafting, structured challenge, methodology enforcement in dialogue, artifact production with placement instructions. Must never: be the sole source of any evidence-graded fact (Invariant 3); every quantitative claim Claude introduces enters as ungraded until independently verified.

---

## 9. Version Roadmap Through Version 3

Versions are gated by validation criteria, not calendar dates. A version does not begin until its predecessor's exit gate is met and recorded.

**Version 1 — The Instrument (current).**
Scope: five cities, daily-high markets, NWS + climatology + market ladder, full reproducibility scaffolding.
Work: complete Bootstrap Checklist §3+ (repo init, .gitignore, backup discipline); complete vault walkthrough §3–7; pass Milestone 1b gates (station IDs verified against snapshotted Kalshi rules pages; NWS user-agent configured); implement and verify the scoring module against worked examples; begin the Prediction Ledger.
Exit gate: three consecutive months of gap-audited data collection; ≥300 city-days scored across the full ladder; at least one pre-registered calibration study completed end-to-end (registration → data → scoring → graded Research Summary), regardless of what it finds. Finding "the market is well-calibrated and we have no edge" passes the gate — the gate tests the instrument, not the result.

**Version 2 — The Comparator.**
Scope: deepen, don't widen. Multiple forecast sources beyond NWS point forecasts (e.g., NWS ensemble/probabilistic products) to turn the model rung into a genuinely probabilistic forecaster; systematic divergence detection with pre-registered thresholds; paper-only Kelly-sized position ledger driven by the Kelly–log-score identity, to measure what following divergences *would* have done net of realistic fees and spreads; expansion of cities only if the exit-gate power analysis (below) demands more n.
Exit gate: a pre-registered study answering, with stated confidence, whether model-vs-market divergence has out-of-sample predictive content for outcomes after costs — in either direction. Requires a power analysis first: given city-day n accrual (~150/month), how many months until the study is decidable? If the answer is "years," V2's job is to shrink that (more cities, more markets per city) before testing.

**Version 3 — The Decision Layer (conditional).**
Scope: only if V2's gate finds durable, cost-surviving divergence content. Adds: a formal expected-value engine implementing Thinking Framework step 8; risk limits and fractional-Kelly sizing policy as pre-registered documents; possibly a second market domain chosen for statistical independence from weather (an explicit ADR weighing candidates). If V2 finds no edge, V3 is instead **The Observatory**: the platform continues as a calibration-measurement instrument, publishing (privately or publicly) reliability studies of prediction markets — which is a legitimate terminal state, per the mission (§1.1).
Exit gate: not defined here; defined by pre-registration at V3 entry.

Explicitly deferred beyond V3: stock markets, political-figure trading data, and every other item from the original Mission.md ambitions. Each requires its own domain audit before admission.

---

## 10. Risks

Ordered by expected damage to the mission (validity first, then continuity, then opportunity).

**R1 — Settlement-source mismatch (validity, severe).** If the station/element Kalshi actually settles against differs from what we collect (station ID, climate-day boundaries, rounding conventions, °F handling), every score is silently wrong. Mitigation: Milestone 1b gate with snapshotted rules pages; a standing reconciliation check comparing our computed settlement to Kalshi's actual settlement for every resolved market, alarming on any mismatch. This check is the single highest-value piece of code after the collectors themselves.

**R2 — n inflation and multiplicity (validity, severe).** The correlated-brackets trap, plus its subtler cousin: running many exploratory comparisons and pre-registering the one that already looks good ("pre-registration theater"). Mitigation: city-day accounting enforced in the scoring module itself (it should refuse to report bracket-level n as sample size); a rule that any hypothesis suggested by exploratory data must be tested on data collected *after* registration.

**R3 — Look-ahead leakage (validity, severe).** Analysis accidentally using data ingested after the decision cutoff (e.g., a revised NWS observation). Mitigation: P2 dual timestamps plus a convention that every analysis artifact states its ingestion-time cutoff in its metadata; periodic audit queries that recompute a sample of artifacts from raw data.

**R4 — Silent collection gaps (validity, moderate; compounds over time).** Task Scheduler misfires, machine asleep, API outages. Gaps bias calibration samples in non-random ways (outages correlate with weather events and market volatility). Mitigation: a daily gap-audit job that enumerates expected-vs-received collections and writes a completeness report; missingness is recorded and reported alongside every n.

**R5 — Single-machine catastrophe (continuity, severe).** Disk failure or ransomware destroys the database, snapshots, and vault simultaneously. Mitigation: scheduled off-machine backups of `data/`, `snapshots/`, and both Git repos, with a tested restore. Until this exists, it is the Lab's largest unmitigated risk and should be inserted into the Bootstrap Checklist.

**R6 — Environment fragility (continuity, moderate).** Windows updates, Python upgrades, Task Scheduler quirks, path-with-spaces bugs. Mitigation: environment capture per P9/§4.2; scheduler task definitions exported and versioned; the Bootstrap Log's verify-every-step discipline continued into operations.

**R7 — Microstructure mistaken for divergence (validity, moderate).** Thin weather markets: wide spreads, stale quotes, fee structures. Naive mid-price "implied probabilities" will diverge from any model, profitably-looking on paper and untradeable in fact. Mitigation: the §5 Step 4 normalization rules are pre-registered; V2's paper ledger applies realistic costs; liquidity metrics are collected alongside prices.

**R8 — Upstream change (continuity, moderate).** Kalshi API or ticker-structure changes; NWS endpoint or product changes. Mitigation: collectors alarm on schema anomalies rather than coercing them; snapshots preserve pre-change behavior for reconciliation.

**R9 — Solo-researcher failure modes (validity + continuity, chronic).** No reviewer, motivated reasoning, abandonment-and-return with lost context. Mitigation: the entire Plane 4 design — pre-registration as a commitment device, ADRs and the Bootstrap Log as external memory, Claude as a structured adversarial reviewer whose challenges are recorded, and lifecycle statuses so that stale notes announce themselves.

**R10 — Goal drift toward trading (mission, insidious).** The pull to act on the first exciting divergence, short-circuiting §11. Mitigation: the Prediction Ledger and paper-only V2 ledger give the itch a harmless outlet; V3's entry gate is the only sanctioned door to action.

---

## 11. Validation Philosophy

The Lab validates instruments, then forecasts, then claims of edge — in that order, and never out of order.

**Instrument validation.** Scoring code is verified against worked examples from the canonical bibliography before its first real use. The settlement reconciliation check (R1) validates the outcome variable continuously. Gap audits (R4) validate the sample frame. An instrument that fails validation quarantines everything it produced (Invariant 5).

**Forecast validation.** Calibration is population-level, at city-day grain, with pre-registered bin schemes for reliability diagrams and pre-registered minimum n before interpretation. The Murphy decomposition is the primary lens: reliability tells us whether stated probabilities mean what they say; resolution tells us whether they say anything; uncertainty contextualizes both. Single outcomes validate nothing — a principle already vaulted, restated here as normative.

**Edge validation (V2+).** A divergence claim must survive, in order: pre-registration; out-of-sample data collected after registration; realistic cost modeling; the correlated-brackets accounting; and a comparison against the boring alternative explanations mandated by Rules.md ("always consider alternative explanations") — stale quotes, settlement mismatch, look-ahead leakage, multiplicity. Only then is it eligible for an evidence grade above exploratory, and only pre-registered replication earns the top grades.

**Grading and honesty.** Every quantitative claim in the vault carries its evidence grade, its n in city-days, and its uncertainty statement, per Rules.md. "We don't know yet, and here is the n at which we will" is a first-class, publishable result of this Lab.

---

## 12. Technical Debt Strategy

Debt is permitted; hidden debt is not.

**The register.** A single vault note, `Technical_Debt_Register.md` (01_Governance), lists every known shortcut: what was skipped, why, the risk it carries, and its repayment trigger. Adding an entry is cheap and blame-free by design — the enemy is the unrecorded shortcut, not the recorded one.

**Classification.** Debt is triaged by what it threatens: *validity debt* (anything that could corrupt findings — e.g., an unverified scoring function, a missing reconciliation check) must be repaid before any dependent finding is graded, no exceptions; *continuity debt* (backup gaps, environment capture gaps) has a hard deadline; *convenience debt* (ugly code, manual steps) is repaid opportunistically at version boundaries.

**Version-boundary amnesty audits.** At each version gate, the register is reviewed in full: repay, formally accept (with ADR), or re-trigger each item. Nothing rolls forward silently.

**Anti-goldplating clause.** The inverse failure — polishing infrastructure to avoid the vulnerability of producing findings — is also debt (mission debt). The V1 exit gate's requirement of one completed end-to-end study exists specifically to force contact with reality.

---

## 13. Future Expansion Strategy

Expansion is admitted along three axes, in priority order, each with an admission test.

**Axis 1 — Depth in weather (default).** More cities, more market types within weather (e.g., low-temperature or precipitation series if Kalshi offers them), richer forecast sources. Admission test: a power analysis showing the addition materially shortens time-to-decidability for a registered question. Cheapest axis: same collectors, same settlement logic family, same statistical unit.

**Axis 2 — New market domains (V3+, conditional).** A second domain earns admission only with: verifiable ground truth of R1-manageable quality; a defensible statistical unit and honest n accrual rate; a modeling input independent of the market itself; and a written domain audit note. Domains with fuzzy settlement or reflexive dynamics (prices influencing the outcome) are presumptively rejected.

**Axis 3 — New capabilities (orthogonal).** Publication of calibration studies; a small dashboard over the analysis plane; multi-machine or cloud collection (triggering the §6 database ADR); collaboration (which would require formalizing what is currently solo convention — a forcing function worth welcoming if it arrives).

**Standing exclusions until explicitly re-admitted by ADR:** live capital deployment (gated solely behind V3 entry), stock-market analysis, and political-figure trading data (per §1.1 — different program, different audit).

The expansion strategy's governing heuristic: **the Lab expands its instrument's reach only as fast as it can keep every new claim auditable.** Any expansion that outruns the snapshot store, the settlement reconciliation, or the honest-n discipline is scope creep wearing ambition's clothes.

---

## Appendix A — Open items this specification creates

1. ADR: single vs. dual Git repositories (§7; this spec assumes dual).
2. ADR: SQLite migration triggers and DuckDB path (§6).
3. Bootstrap Checklist insertion: off-machine backup with tested restore (R5).
4. Mission.md amendment proposal (§1.1) — requires architect decision.
5. Settlement reconciliation check — schedule as first post-bootstrap coding task (R1).
6. Power analysis for V2 gate decidability — pre-register before V2 entry (§9).

## Appendix B — Relationship to existing documents

Rules.md is incorporated by reference as the conduct layer of Plane 4; every clause maps onto this spec (never guess → evidence grades; never fabricate → snapshot-what-you-cite; always explain uncertainty → §11 grading). Thinking_Framework.md is incorporated as the mandatory procedure for §5 Step 7. Research_Methodology_v2_Canonical.md remains constitutional; this spec claims no authority to amend the five Invariants.

---

*End of Research Lab Master Specification v1.0 (Draft). Acceptance requires: architect review, resolution of Appendix A item 4, and initial commit to `01_Governance/` once Bootstrap Checklist §3 (repository initialization) completes.*
