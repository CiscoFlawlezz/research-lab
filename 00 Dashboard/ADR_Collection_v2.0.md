# Research Lab — Architecture Decision Record Collection

**Document ID:** ADR-COLLECTION-001
**Version:** 2.0 (Canonical upon architect acceptance and Git commit)
**Status:** Evergreen (governing document)
**Date:** 2026-07-06
**Supersedes:** ADR Collection v1.0 in full
**Governed by:** `Research_Methodology_v2_Canonical.md` (constitutional) and `Research_Lab_Master_Specification_v1.md` RL-SPEC-001 (statutory). Where this collection conflicts with either, they prevail in that order. This collection records the *decisions* those documents rest on, with alternatives, tradeoffs, and revisit triggers — the layer the Spec's §0 requires for amendments ("no orphan decisions").
**Author of record:** Director of Quantitative Research (drafted); Lead Quantitative Research Architect (approval authority)
**Invariant 3 notice:** This document is AI-drafted and is untrusted input until architect-verified. It records decisions, not findings; any factual claim herein that later anchors a graded finding must be independently verified first.

---

## Errata — what v1.0 got wrong and how v2.0 corrects it

Per Rules.md (never guess; always explain why; separate facts from assumptions), the differences from v1.0 are recorded here rather than silently absorbed.

**E1 — Provenance error (process).** v1.0 asserted no Master Specification existed in the Project. The Spec is now present; whether it was absent at drafting time or missed cannot be verified from my side, because I cannot see file timestamps and cannot retrieve files from past sessions. The correctable error is that the claim was stated categorically when it was only observable-at-that-moment. **Fix:** v2.0 adds ADR-021 (AI context boundaries as a working convention), and all provenance claims in this document are scoped ("as visible to me at drafting time").

**E2 — Coverage gaps (substance, largest defect).** v1.0 documented twelve decisions but missed at least seven major architectural decisions the Spec makes explicit: the four-plane architecture with boundary rules (§4), the content-addressed snapshot store (§4.1/§8), dual Git repositories (§7, Appendix A.1), the pre-committed SQLite→DuckDB migration path (§6, Appendix A.2), off-machine backup with tested restore (R5, Appendix A.3), validation-gated versioning (§9), and the settlement reconciliation check (R1, Appendix A.5). **Fix:** ADRs 013–020 added.

**E3 — Misattributed provenance (framing).** v1.0 presented dual repositories and a DuckDB analytical layer as reviewer recommendations. The Spec had already reasoned to both (§7, §6). Convergence is mildly reassuring, but v1.0's framing implied the decisions originated in review when they were already architecture. **Fix:** ADRs 015 and 016 attribute correctly and add the ADR-grade challenge the Spec's Appendix A requests.

**E4 — A technically wrong suggestion.** v1.0's ADR-002 mentioned Git-LFS as a viable handling for the SQLite file. The Spec (§7.1) is explicit and correct: data and snapshots are gitignored; their integrity comes from backup discipline and content hashing, *not* Git. Git-LFS would put multi-gigabyte binary history on the remote, couple data retention to a code host, and add a proprietary-ish dependency for zero audit benefit. **Fix:** removed; ADR-006 and ADR-017 now carry the correct division of labor.

**E5 — Under-specified enforcement.** v1.0's ADR-010 (city-day) relied on convention. The Spec (R2) demands enforcement *in the scoring module itself* — it must refuse to report bracket-level n as sample size. v1.0's ADR-003 likewise proposed UPDATE/DELETE triggers as an optional strengthening; the Spec's P1 makes engine-level enforcement the norm. **Fix:** both upgraded from suggestion to requirement.

**E6 — Missing risk linkage.** v1.0's risks were locally reasoned but not tied to the Spec's ranked risk register (R1–R10). **Fix:** every ADR now cites the R-numbers it mitigates or accepts, so the risk register and the decision record audit each other.

What v1.0 got *right* and v2.0 preserves: the twelve original decision subjects and numbering (stable references), the eleven-field schema, the maintenance protocol, the Mission.md tension flag (independently raised by the Spec §1.1 — now formalized as ADR-020), and the three standing audits, which are retained and expanded.

---

## How to read this document

Schema per ADR: Title, Status, Context, Problem, Alternatives Considered, Decision, Rationale, Tradeoffs, Risks, Future Implications, Revisit Conditions.

**Status values:** Proposed · Accepted · Accepted (implementation in progress) · Accepted (dormant until trigger) · Superseded by ADR-XXX · Deprecated.

**Maintenance protocol:**
1. ADRs are append-only in spirit: never rewrite an accepted ADR; supersede it with a new one and update only the status line (Spec §8, ADR log contract).
2. When any ADR is first superseded, split this collection into one file per ADR in the same folder so statuses evolve independently.
3. Every non-trivial architectural decision gets an ADR *before* implementation (Spec §0, P7).
4. Revisit Conditions are binding triggers. When one fires, log it in `Bootstrap_Log.md` and open review. Version-boundary amnesty audits (Spec §12) review every ADR's triggers alongside the Technical Debt Register.

---

## Index

| ADR | Title | Status | Spec anchor |
|---|---|---|---|
| 001 | Weather markets as Version 1 domain | Accepted | §1, §9, §13 |
| 002 | SQLite as the data storage backend | Accepted | §6 |
| 003 | Append-only storage with dual timestamps | Accepted | P1, P2, §6 |
| 004 | Obsidian as the knowledge layer | Accepted | §4.1 Plane 4, §7.2 |
| 005 | Claude as research analyst, not autonomous decision-maker | Accepted | §8, Invariant 3 |
| 006 | Git as governance spine; GitHub as private remote | Accepted (implementation in progress) | §4.2, §7 |
| 007 | Python on native Windows as the runtime environment | Accepted | P9 |
| 008 | Probability evaluation over outcome prediction | Accepted | §1, §2, §11 |
| 009 | No credentials in the collection layer | Accepted | P3, §4.1 Plane 1 |
| 010 | City-day as the statistical unit | Accepted | §2, R2 |
| 011 | Pre-registration as a non-negotiable invariant | Accepted | Invariant 1, §2 |
| 012 | Windows Task Scheduler for pipeline automation | Accepted | §4.1 Plane 1, R4 |
| 013 | Four-plane architecture with normative boundary rules | Accepted | §4 |
| 014 | Content-addressed immutable snapshot store | Accepted | §4.1 Plane 2, §8, Invariant 4 |
| 015 | Dual Git repositories (pipeline and vault) | Accepted (per Spec Appendix A.1) | §7 |
| 016 | Pre-committed SQLite→DuckDB analytical migration path | Accepted (dormant until trigger) | §6, Appendix A.2 |
| 017 | Off-machine backup with tested restore | Accepted (implementation required before research output) | R5, Appendix A.3 |
| 018 | Validation-gated versioning (gates, not dates) | Accepted | §9, §12 |
| 019 | Settlement reconciliation check as first post-bootstrap code | Accepted (implementation scheduled) | R1, Appendix A.5 |
| 020 | Mission.md amendment | Proposed — awaiting architect decision | §1.1, Appendix A.4 |
| 021 | AI context boundaries: vault and Git as sole system of record | Accepted | §2, R9 |

---

## ADR-001 — Weather markets as the Version 1 domain

**Status:** Accepted

**Context.** Mission.md as written spans prediction markets, equities, and politician-trade tracking. The Spec (§1) restricts Version 1 to five Kalshi daily-high series (KXHIGHTPHX, KXHIGHNY, KXHIGHCHI, KXHIGHMIA, KXHIGHAUS) with NWS forecasts and station observations as modeling input and climatology as baseline, and defers everything else (§13 standing exclusions).

**Problem.** Which domain gives the fastest, cleanest path to validating the *instrument* — the calibration-measurement platform — while the methodology is itself unproven?

**Alternatives considered.**
1. *Political/election markets.* Liquid and prominent, but resolution cycles run months, ground truth entangles with polling disputes, and the information environment is adversarial. Years to adequate city-day-equivalent n.
2. *Equities, including politician-trade following.* Continuous prices, no discrete resolution, disclosure lags, survivorship problems, edge confounded with beta. The Spec (§1.1) correctly identifies this as a different research program.
3. *Economic-data markets (CPI, Fed).* Objective settlement but ~monthly events; n accrues an order of magnitude too slowly.
4. *Sports.* High frequency, but no independent authoritative "forecast agency" analogous to NWS, and a sophisticated counterparty pool.
5. *Weather (chosen).* Daily resolution; settlement against official station observations (verifiable ground truth of R1-manageable quality, per §13's own admission test); a free, authoritative, market-independent forecast input; ~150 city-days/month across five cities.

**Decision.** Weather daily-high markets, five cities, are the exclusive V1 domain.

**Rationale.** Weather maximizes calibration throughput per unit time while satisfying every §13 Axis-2 admission test *retroactively applied to the founding domain*: verifiable ground truth, defensible statistical unit, model input independent of the market, no reflexivity (prices cannot change the temperature — the cleanest possible non-reflexive domain). It validates the instrument cheaply: if snapshotting, dual timestamps, and the ledger can't handle five weather series, they can't handle anything.

**Tradeoffs.** Weather edges, if any, are likely small and capacity-constrained; the domain may never be economically significant. The Spec accepts this explicitly: V3 has a legitimate terminal state as The Observatory (§9).

**Risks.** Mitigates R2 (via ADR-010's unit) and avoids reflexive-domain risk entirely. Accepts: Kalshi could restructure or delist weather series (R8); the market may be efficiently priced by participants holding the same NWS data — a null result, which the V1 exit gate explicitly accepts as passing (§9).

**Challenge before acceptance.** The strongest attack is opportunity cost: if the *mission* were profit, weather is plausibly the wrong hill. But the Spec (§1.1, §2) defines the product as the instrument, not the edge — and for instrument validation, weather dominates every alternative on ground-truth quality and n-accrual. Challenge fails. The residual tension is with Mission.md's text, not with the decision — formalized as ADR-020.

**Future implications.** Ticker parsing, station verification, and ledger schemas are weather-specific at the edges, domain-general at the core; §13 Axis-1 expansion (more cities/market types) reuses everything.

**Revisit conditions.** (1) V1 exit gate met (§9: three gap-audited months, ≥300 scored city-days, one end-to-end pre-registered study). (2) Kalshi materially changes weather market structure (R8 alarm). (3) A §9 V2 power analysis demands more n than weather can supply.

---

## ADR-002 — SQLite as the data storage backend

**Status:** Accepted

**Context.** Milestone 1a is complete: live pipeline at `C:\Projects\weather-pipeline`, SQLite backend, append-only dual-timestamp storage, Task Scheduler automation. The Spec (§6) supplies the load profile: one writer, one reader, one machine, tens of megabytes per month.

**Problem.** What storage engine serves a solo, single-machine, reproducibility-first pipeline?

**Alternatives considered.**
1. *PostgreSQL.* Concurrency and types the workload doesn't need, purchased with a running service, its own backup discipline, and an attack surface.
2. *Flat CSV/Parquet files.* Portable, but append-only integrity, dedup, and as-of joins become homegrown untested logic — the kind Invariant 3 exists to distrust.
3. *DuckDB as primary store.* Superb analytics, but its role here is querying, not decades-proven crash-safe transactional durability; see ADR-016 for its correct place.
4. *Cloud databases.* Import credentials, network dependency, and vendor terms into Plane 1, violating P3 and ADR-009.
5. *SQLite (chosen).*

**Decision.** SQLite is the durable store for all collected data.

**Rationale.** The Spec's formulation is the load-bearing one: **"the database is a file you can hash"** (§6). A single-file ACID store makes the entire raw history snapshottable, backupable, and integrity-checkable by content hash — the same primitive the snapshot store (ADR-014) uses, so one verification discipline covers both. Zero administration removes a whole class of R6 environment fragility. Every capability a server database adds is capacity this workload does not use.

**Tradeoffs.** Single-writer lock; slower columnar analytics at scale; no replication (handled instead by ADR-017 backups).

**Risks.** Mitigates R6 (fewer moving parts). Accepts three pre-registered failure modes with observable triggers (§6): writer contention, analytical scale, multi-machine — each routed to ADR-016's migration path rather than ad-hoc reaction. Corruption risk mitigated by WAL mode plus tested-restore backups (ADR-017).

**Challenge before acceptance.** The only serious challenge is "start with DuckDB/Parquet and skip the migration." Rejected: transactional append-only ingestion with dual timestamps is SQLite's home turf, and DuckDB can read SQLite files later — the migration path is cheap precisely *because* SQLite was chosen first. Challenge strengthens the decision.

**Correction from v1.0 (E4):** the SQLite file is never Git-tracked, by LFS or otherwise; it is gitignored (§7.1) and protected by ADR-017 and content hashing.

**Future implications.** Backup (ADR-017) treats `data/` as data; analysis performance complaints route to ADR-016, not to schema hacks.

**Revisit conditions.** Exactly the §6 triggers, recorded in ADR-016: observed lock timeouts in collector logs; routine analysis queries exceeding minutes; any second machine.

---

## ADR-003 — Append-only storage with dual timestamps

**Status:** Accepted

**Context.** P1 (append-only truth) and P2 (dual timestamps everywhere) are Spec design principles. NWS revises forecasts and observations; Kalshi amends metadata; both without preserving history for us.

**Problem.** How is evolving external data stored so any past analysis is exactly reconstructible and look-ahead bias is structurally impossible?

**Alternatives considered.**
1. *Mutable upsert (latest wins).* Destroys revision history; makes calibration-by-lead-time impossible and audits unfalsifiable. The Spec names silent history rewriting the single most common source of irreproducible backtests (P1).
2. *Periodic snapshots of a mutable store.* Preserves points, loses paths; doubles machinery.
3. *Event-sourcing frameworks.* Correct semantics, disproportionate complexity for one operator.
4. *Append-only rows, dual-timestamped (chosen).* Every row carries event time and ingestion time; corrections are new rows; "current best" is a latest-as-of *query view*, never an UPDATE (§6, §8 storage contract).

**Decision.** Raw tables receive INSERTs only. Every record carries when-it-happened and when-we-learned-it. Derived tables are droppable cache, regenerable from raw plus versioned code.

**Rationale.** Dual timestamps answer both questions the ladder requires — "what did NWS say at lead L?" and "what was knowable at the cutoff?" — making every backtest-style question exact (P2's guard against look-ahead, the second most common irreproducibility source). Append-only is Invariant 5's substrate: nothing disappears, so retraction paths are traversable. Point-in-time honesty falls out for free.

**Tradeoffs.** Monotonic growth (trivial at §6 volumes); every analysis query must join on ingestion time — a recurring source of subtle bugs, mitigated by R3's convention that every artifact states its cutoff in metadata plus periodic recomputation audits.

**Risks.** Directly mitigates R3 (look-ahead leakage). The residual risk is human: a debugging UPDATE quietly breaking the guarantee.

**Upgrade from v1.0 (E5):** engine-level enforcement is now *required*, not suggested — SQLite triggers raising on UPDATE/DELETE against raw tables ship with the schema (Plane 2 contract, §8: "must never expose an UPDATE/DELETE path on raw tables"). Convention is not a control.

**Challenge before acceptance.** "Append-only is ideology; just be careful." Rejected on R9 grounds: a solo researcher has no colleague to catch the careless mutation, so the guarantee must live in the engine. Challenge fails.

**Future implications.** All analysis code is written against as-of views from day one; the R3 audit (recompute a sample of artifacts from raw) becomes a standing job.

**Revisit conditions.** (1) Storage growth crossing ADR-016 triggers. (2) An external requirement forcing deletion — would be met with documented tombstones, never silent deletes.

---

## ADR-004 — Obsidian as the knowledge layer

**Status:** Accepted

**Context.** Plane 4 (§4.1) requires a vault with lifecycle statuses, evidence grades, MOCs, glossary, open questions, ledger, ADRs, and the Bootstrap Log. The vault lives at `C:\Users\myname\Obsidian\Research Lab` (space in path — quote everywhere), relocated off OneDrive deliberately. The Methodology mandates a query plugin as infrastructure.

**Problem.** What system holds the knowledge corpus so links, lifecycle, and auditability survive for years, under Git, with one operator?

**Alternatives considered.**
1. *Notion/Coda.* Strong databases, but proprietary storage and cloud dependency break the Git audit chain — the corpus stops being files you can hash and commit. Disqualifying under P4/§4.2.
2. *Plain Markdown + Git, no app.* Maximally durable, but backlinks, graph, and templates are what make Invariant 2 (no orphan findings) and P5 (one canonical home per fact) *cheap enough to actually obey* solo. Discipline that depends on grep loses to a busy week (R9).
3. *Jupyter as knowledge base.* Conflates computation (Plane 3) with judgment (Plane 4), violating P3's separation; notorious under version control.
4. *Self-hosted wiki.* A server and database to administer for one user; pure R6 surface.
5. *Obsidian (chosen).* Plain Markdown on local disk — option 2's durability retained in full — plus the linking machinery that operationalizes P5 and the MOC layer.

**Decision.** Obsidian over a plain-Markdown vault. The *files*, not the app, are the system of record.

**Rationale.** Only option simultaneously: (a) plain files Git can version and hash, (b) zero-server, (c) rich enough in linking to enforce anti-fragmentation as a habit rather than a chore. Lock-in is near zero — if Obsidian vanishes, the corpus is intact Markdown with standard wikilinks.

**Tradeoffs.** Soft dependency on community plugins (the query plugin); weaker tabular/database features than Notion; the path space is a standing footgun (P9 acknowledges; convention: quote always).

**Risks.** Mitigates R9 (external memory for the solo researcher). Accepts plugin abandonment (mitigation: queries are conveniences; links are plain text) and workspace-file churn under Git (mitigation: ADR-015's vault `.gitignore`).

**Challenge before acceptance.** "The plugin mandate contradicts the durability argument." Partially valid — resolved by rule: any plugin whose *data* cannot be reconstructed from the Markdown itself is rejected; plugins may add views, never truth. With that rule, challenge fails.

**Future implications.** §7.2's numbered folder structure is normative; naming differences found during the walkthrough (Sections 3–7 pending) are reconciled then, not by retroactive renames.

**Revisit conditions.** (1) Obsidian licensing changes affecting local vaults. (2) Critical plugin abandonment without replacement. (3) Corpus scale exceeding the file model's queryability.

---

## ADR-005 — Claude as research analyst, not autonomous decision-maker

**Status:** Accepted

**Context.** Claude operates in Plane 4 as Director of Quantitative Research. The Spec's §8 contract: Claude owns drafting, structured challenge, methodology enforcement in dialogue, and artifact production — and must never be the sole source of any evidence-graded fact (Invariant 3).

**Problem.** What role can an AI system safely hold inside a research program whose entire product is epistemic rigor?

**Alternatives considered.**
1. *Autonomous agent (commits findings, eventually trades).* Collapses the hypothesis/finding distinction; a confabulation enters the record with the authority of data; violates Rules.md with no checkpoint. Also directly feeds R10 (goal drift toward trading).
2. *No AI.* Forfeits the one structural mitigation the Spec lists for R9's "no reviewer" problem: Claude as a recorded adversarial reviewer.
3. *AI as analyst behind a human verification gate (chosen).*

**Decision.** Claude drafts, challenges, structures, and produces artifacts with placement instructions. Everything Claude asserts is ungraded until independently verified. Claude never commits to the ledger, never grades its own claims, never executes anything.

**Rationale.** The LLM failure mode — fluent, confident, wrong — is exactly the input failure a calibration lab cannot tolerate. The verification gate converts AI from epistemic risk into epistemic multiplier: more hypotheses generated and stress-tested than one human could, with only verified material accruing authority. This very document demonstrated the mechanism twice: v1.0's provenance error (Errata E1) was catchable *only because* the architect reviews everything; and verify-before-grade applies equally to code Claude writes (§8: scoring module unit-verified against worked bibliography examples before first use).

**Tradeoffs.** The human gate is a bottleneck and a recurring time cost; real-time autonomous monitoring is deliberately forgone.

**Risks.** Mitigates R9. The live risk is **verification fatigue** — the gate degrading into rubber-stamping, silently converting this architecture into alternative 1 without any decision being made. Mitigation (standing audit, retained from v1.0): quarterly spot-audit of a random sample of previously verified AI claims; record hit rate in the Bootstrap Log or its successor.

**Challenge before acceptance.** "The gate's cost exceeds its value once trust is established." Rejected: trust established is precisely when fatigue risk peaks; the spot-audit exists to measure, not assume, the gate's continuing value. Challenge fails but sets a revisit condition.

**Future implications.** Any future automation is classified against this ADR: information-gathering automation compatible; decision-executing automation requires a superseding ADR and is additionally gated behind V3 entry (§9).

**Revisit conditions.** (1) Spot-audits over a full version cycle catching zero errors across a large sample — evidence either that the gate is redundant *or* that auditing itself has degraded; the review must distinguish which. (2) Machine-checkable verification (e.g., auto-verified citations against snapshots) maturing for a defined claim subset.

---

## ADR-006 — Git as governance spine; GitHub as private remote

**Status:** Accepted (implementation in progress — Bootstrap Checklist §3 pending: repo init and `.gitignore`)

**Context.** The Spec (§4.2) makes Git the governance spine: tamper-evident vault history, code-state capture per analysis run, "the code that produced finding F is a commit hash." Git for Windows is installed with recorded settings (Notepad editor, `main` default, as-is line endings, Credential Manager). Identity configuration confirmation is the current stop point.

**Problem.** How are code and knowledge versioned, and how is that history protected off-machine?

**Alternatives considered.**
1. *Cloud sync (OneDrive) as "versioning."* Already rejected in practice via the vault relocation; no commit semantics, no messages, and sync engines fighting Git over the same files is a known corruption vector.
2. *Local Git only.* Full history, zero survival of disk loss — R5 unmitigated for the repos.
3. *Self-hosted remote (NAS/second machine).* Viable but adds administered hardware; availability becomes the researcher's job (R6).
4. *Git + private GitHub remotes (chosen).* Off-site, zero-administration, standard toolchain; every clone is a full history copy, so GitHub loss ≠ history loss.

**Decision.** Git locally for both repositories (see ADR-015); private GitHub remotes for off-site copies of *code and text*. Data and snapshots are explicitly out of Git's scope (§7.1) and are protected by ADR-017.

**Rationale.** Git is the version-control analog of append-only storage: an immutable, message-annotated history — P1 applied to code and knowledge. The commit hash is the Git-native form of Invariant 4: methodology documents and findings are cited at a hash. GitHub adds durability with no server to run. The as-is line-ending choice was correct for a Markdown-heavy single-platform setup (no CRLF churn in diffs).

**Tradeoffs.** Third-party dependency for the remote (bounded: full local history); private-repo contents subject to GitHub terms.

**Risks.** Mitigates part of R5 (repos) and R9 (external memory). Residual risks and their controls, binding on Bootstrap §3: (a) `*.sqlite*`, `snapshots/`, `logs/`, `data/` gitignored — never in any repo (E4 correction); (b) `config.yaml` contains the NWS contact email and any future secrets — commit `config.example.yaml`, gitignore the real file; (c) vault repo ignores `.obsidian/workspace*` and plugin caches (ADR-015).

**Challenge before acceptance.** "A research vault on a US cloud host is a confidentiality risk for strategy research." Considered: repos are private, contents are methodology and calibration findings rather than live positions (none exist pre-V3), and the alternative (option 3) trades a bounded confidentiality risk for an unbounded continuity risk. Accepted with eyes open; revisit condition set.

**Future implications.** Commit discipline joins the audit chain: every analysis artifact records the commit hash of the code that produced it (§4.2 environment capture).

**Revisit conditions.** (1) GitHub terms change materially for private research data. (2) Live trading begins (V3) — confidentiality calculus changes; re-evaluate host or encryption-at-rest. (3) Collaboration begins (branch/review policy needs its own ADR).

---

## ADR-007 — Python on native Windows as the runtime environment

**Status:** Accepted

**Context.** P9 is explicit: "Windows-native, honestly." The pipeline is built, live, and Milestone-1a-verified on Windows 11; Task Scheduler automates it; paths with spaces are quoted; line endings committed as-is.

**Problem.** What language/OS combination runs collection and analysis?

**Alternatives considered.**
1. *Python on WSL2.* Closer to the data ecosystem's Linux norm, cron over Task Scheduler — but adds a virtualization layer, complicates Windows-side vault access, and would discard a *verified working* pipeline for a hypothetical improvement.
2. *Cloud collection (VPS/serverless).* Better uptime, but imports credentials, cost, and remote administration during a phase whose product is methodology, not production reliability; conflicts with ADR-009's spirit.
3. *R / Julia / Rust / JS.* R strong on statistics, weak on pipelines; Rust/JS trade away iteration speed; Julia's ecosystem thinner here. Python is the lingua franca of the forecast-verification literature the Lab is built on.
4. *Python on native Windows (chosen).*

**Decision.** Python 3 on Windows 11, natively.

**Rationale.** Empirical verification over assertion: this environment is not hypothetically adequate — it is demonstrated adequate, end to end, against all five tickers and both NWS feeds. P9's honesty framing is the right one: document the environment that actually runs, and capture it (pinned requirements, OS notes, `environment/` in the repo) rather than pretending to an idealized Linux box that would itself drift from reality. Migration now would spend scarce effort for no verified benefit, violating one-milestone-at-a-time.

**Tradeoffs.** Minority platform in the Python data ecosystem (occasional wheel issues, path/encoding edges); Task Scheduler clunkier than cron; personal-machine uptime bounds completeness.

**Risks.** P9 explicitly accepts R6 (environment fragility); mitigations are environment capture, exported scheduler XML under version control, and the Bootstrap Log's verify-every-step discipline continued into operations. Collection gaps route to R4's machinery (ADR-012).

**Challenge before acceptance.** This remains the ADR where a better *eventual* decision most plausibly exists — WSL2 or a small always-on collector would improve completeness and ecosystem fit. But the correct sequencing is measurement first: R4's daily gap-audit will produce the completeness data. Decide from the report, not from preference. Challenge deferred with a numeric trigger, not dismissed.

**Future implications.** Every script quotes paths; every registered experiment runs only after environment capture exists (Methodology prerequisite).

**Revisit conditions.** (1) Gap-audit shows >5% of scheduled collections missed in any month (threshold to be confirmed at gap-audit pre-registration). (2) A required dependency loses Windows support. (3) Multi-machine collection (also fires ADR-016's trigger 3).

---

## ADR-008 — Probability evaluation over outcome prediction

**Status:** Accepted

**Context.** The Spec's §1 states it flatly: the goal is not prediction and not trading; the product is measured, auditable knowledge about probability divergence. §2: measurement precedes edge; the market is a forecaster, not an oracle. §11 orders validation: instruments, then forecasts, then edge claims — never out of order.

**Problem.** Is the Lab's unit of output a predicted outcome, or an evaluated probability?

**Alternatives considered.**
1. *Outcome prediction (hit rates).* Statistically bankrupt for this purpose: single outcomes validate nothing (vaulted principle, restated as normative in §11); hit rates ignore confidence and payoff; optimizing accuracy rewards overconfident point forecasts.
2. *P&L backtesting as primary metric.* Economically ultimate but dominated at small n by variance and staking choices; confounds probability skill with bet sizing; rewards lucky overbetting. Also the royal road to R10.
3. *Proper-scoring evaluation on a reference ladder (chosen).* Brier and log scores per city-day per ladder rung (climatology → NWS-derived model → market); Murphy decomposition (Reliability − Resolution + Uncertainty) as the primary lens; economics connected only via the Kelly–log-score identity.

**Decision.** The Lab's fundamental output is the calibration record: (forecast, price, outcome) triples at city-day grain, scored by proper rules against the full ladder. Recommendations, if ever, arrive only through Thinking Framework step 8 with expected value and uncertainty explicit, gated behind §11's ordering.

**Rationale.** Proper scoring rules are the only evaluation regime under which honest probability reporting is the optimal strategy — the incentive structure of the research matches its epistemic goals. Murphy separates "meaning what you say" (reliability) from "saying anything" (resolution), diagnosing *why* a rung wins, not merely whether. The ladder disciplines interpretation: if the market out-resolves the model everywhere, divergence measures our error, not our opportunity (§2) — a sentence that should hang over the whole project. The Kelly–log-score identity then makes the eventual economic question *reduce to* the calibration question, which is exactly Mission.md's own "not to simply predict outcomes" clause, taken seriously.

**Tradeoffs.** Slow gratification: months to interpretable n at ≤~150 city-days/month; divergences are logged as *phenomena to explain, not signals to act on* (§5 step 6), which requires temperament.

**Risks.** Mitigates R2 and R10 structurally. Residual: Goodhart on the chosen scoring rule (mitigated by pre-registration fixing metric and bin schemes before data); microstructure noise masquerading as divergence, R7 (mitigated by §5 step 4's pre-registered normalization of spreads, fees, and incomplete bracket coverage).

**Challenge before acceptance.** "This is epistemic perfectionism; a trading shop would just backtest." True, and that shop would learn nothing distinguishable from luck at this n — which is the point of §12's anti-goldplating clause running the *other* way: the V1 exit gate forces one completed end-to-end study precisely so measurement discipline produces contact with reality rather than avoiding it. Challenge fails.

**Future implications.** The Prediction Ledger schema captures, at commitment time and never reconstructed: stated probability, both timestamps, all ladder values at the same ingestion cutoff (ladder module contract: never mix cutoffs within a comparison), and resolution. When trading ever begins, scoring-rule evaluation continues on live positions — live P&L never replaces calibration as the health metric.

**Revisit conditions.** (1) The primacy of proper scoring: none — load-bearing for the mission. (2) Specific rules may be extended by ADR if pre-registered analyses need variants (e.g., CRPS over full temperature distributions).

---

## ADR-009 — No credentials in the collection layer

**Status:** Accepted

**Context.** P3 and the Plane 1 contract (§4.1, §8): collectors are dumb by design — fetch, stamp, append, log — holding no credentials beyond the NWS user-agent contact (a Milestone 1b gate) and whatever Kalshi read access strictly requires. Milestone 1a confirmed all required data flows from public endpoints.

**Problem.** Does the always-running scheduled layer authenticate to anything?

**Alternatives considered.**
1. *Authenticated Kalshi from day one.* Prepares for execution nobody is allowed to do yet (V3-gated); parks exchange credentials inside a long-running automated process for zero current benefit.
2. *Secrets manager now.* The right pattern when credentials exist; premature machinery before they do.
3. *Credential-free collection (chosen).* The collection layer physically cannot trade, cancel, or read account data.

**Decision.** Plane 1 holds no credentials beyond the NWS contact string. Any future authenticated capability lives in a separate component with its own ADR, never merged into scheduled collection.

**Rationale.** Defense in depth rhyming with ADR-005: just as Claude cannot act autonomously, the pipeline cannot act at all. A bug, compromised dependency, or hijacked scheduled task can at worst read public data. Blast radius of the always-on component is minimized *by construction*, and the code repo stays trivially safe to host remotely (ADR-006).

**Tradeoffs.** Public rate limits only; no account-side data archived in V1 — acceptable, as no account activity exists.

**Risks.** Mitigates a slice of R6 and the security face of R5. Accepts: public endpoint terms could tighten (R8) — which fails loudly as ingestion gaps, never silently.

**Challenge before acceptance.** The real threat is *erosion*, not the current design: the day V3 authorizes trading, the convenient move is bolting keys onto the existing pipeline. This ADR exists largely to make that shortcut a visible violation. No stronger alternative identified; challenge fails.

**Future implications.** Execution architecture, if V3's gate ever opens, starts as a separate process with a separate credential store and its own ADR.

**Revisit conditions.** (1) V3 entry gate met. (2) Public endpoints becoming insufficient for required data (fires as R8 schema/availability alarms).

---

## ADR-010 — City-day as the statistical unit

**Status:** Accepted

**Context.** §2 "Honest n or no n" and R2. Each city-day market comprises multiple thresholds (T###) and brackets (B###.#) resolved by a single realized temperature — the correlated-brackets trap: naive counting inflates n by an order of magnitude and manufactures significance.

**Problem.** What is one independent observation?

**Alternatives considered.**
1. *Each bracket/threshold contract.* Seductive n, fraudulent confidence intervals — the within-day outcomes are near-deterministic functions of one temperature.
2. *Each city-day (chosen).* One realized daily high per city per day; ≤~150/month across five cities. Cross-city same-day correlation exists but is far weaker than within-city bracket correlation.
3. *Each calendar day, cities pooled.* Maximally conservative; discards genuine cross-city independence (PHX and MIA are nearly unrelated most days) and starves the analysis for no honesty gain.

**Decision.** The statistical unit is the city-day. All n, confidence intervals, and power analyses are denominated in city-days. Per-bracket scores may be computed but are aggregated to city-day before any inference.

**Upgrade from v1.0 (E5):** enforcement moves from convention into code, per R2's mitigation: **the scoring module itself refuses to report bracket-level counts as sample size.** The honest-n rule is a property of the instrument, not a habit of the operator.

**Rationale.** Honest n is the foundation under every number the Lab will ever produce; fixing the unit *before* results exist removes the future temptation to choose whichever unit flatters a finding. R2's subtler cousin — pre-registration theater, registering the comparison that already looks good — is handled jointly with ADR-011's rule: hypotheses suggested by exploratory data are tested only on data collected after registration.

**Tradeoffs.** Power accrues slowly; genuinely bracket-level structure (e.g., tail-bracket pricing) requires careful within-unit treatment rather than pooling.

**Risks.** Mitigates R2 (severe). Accepts residual cross-city correlation on synoptic-scale days (heat domes, continental fronts) mildly inflating effective n. Mitigation, retained from v1.0 and now bound into the template: the pre-registered analysis template includes a day-level clustered-standard-error robustness check by default, and — since the data will exist — cross-city outcome correlation is itself measured, converting an assumption into an estimate.

**Challenge before acceptance.** Option 3's conservatism was re-examined and rejected again: it treats a measurable correlation as if it were total. Measure, cluster, report. Challenge fails.

**Future implications.** Ledger and analysis schemas key on (city, date). Any §13 Axis-2 domain must present its equivalent unit analysis *in the domain audit, before collection begins*.

**Revisit conditions.** (1) Measured cross-city correlation materially exceeding the robustness check's tolerance. (2) Domain expansion (new unit analysis required).

---

## ADR-011 — Pre-registration as a non-negotiable invariant

**Status:** Accepted

**Context.** Invariant 1 (constitutional). §2: pre-commitment defeats hindsight. The vault holds the Pre-Registered Experiment Template; §8's experiment machinery contract forbids result notes without prior registration notes; the Prediction Ledger refuses forecasts after outcomes are knowable.

**Problem.** How does a solo researcher — no reviewers, no adversarial replication, total freedom to re-run quietly — prevent self-deception via forking paths, outcome switching, and hindsight bias?

**Alternatives considered.**
1. *Integrity plus Rules.md.* Values without mechanism; the garden of forking paths defeats good intentions reliably.
2. *Post-hoc exploratory/confirmatory labeling.* The labeling itself is hindsight-biased; unenforceable.
3. *Pre-registration with Git timestamping (chosen).* Hypothesis, unit, metric, bins, sample window, and decision criteria committed before the data window; the commit hash is the tamper-evident timestamp.
4. *External registries (OSF).* Public tamper-evidence at the price of publicizing strategy research; private-remote Git commits provide equivalent internal evidence.

**Decision.** Every confirmatory analysis is pre-registered from the template and Git-committed before its data window. Exploratory work is free, encouraged, permanently labeled exploratory, lives outside `04_Experiments` until registered, and graduates only via fresh out-of-sample data collected after registration.

**Rationale.** Pre-registration is the only known mechanism making forking-paths bias *structurally* impossible rather than discouraged — and it is more critical solo than institutionally, because no colleague will notice the outcome switch (R9). It composes: Git supplies tamper-evidence (ADR-006), append-only data guarantees the registered window can't be re-cut (ADR-003), proper scoring fixes the metric family (ADR-008), and stakes-based track assignment (P6) prevents the discipline from being either skipped when it matters or gold-plated when it doesn't — a five-minute query that anchors a finding gets full registration; a week of plumbing gets a log entry.

**Tradeoffs.** Real friction; promising exploratory results wait a full confirmation cycle. The friction is the point.

**Risks.** Mitigates R2's multiplicity face and R9. Residual: registration theater — vague registrations permitting any result. Mitigation: the template requires numeric decision criteria, the specific ladder comparison, the bin scheme, and minimum n before interpretation (§11), all in advance.

**Challenge before acceptance.** "This is a lab, not a journal; speed matters." Fails at this stage because V1's product is a validated instrument (§9): an unvalidated edge claim has negative value — it consumes capital of both kinds. Post-V1, a lighter registration tier for incremental analyses may be introduced by ADR under P6.

**Future implications.** The funnel is: Open Questions → exploratory → registration → finding → ledger. The §9 V2 gate's power analysis is itself pre-registered before V2 entry (Appendix A.6).

**Revisit conditions.** (1) Version-boundary audit of friction cost vs. errors caught; consider tiering. (2) The invariant's existence for edge claims: never.

---

## ADR-012 — Windows Task Scheduler for pipeline automation

**Status:** Accepted

**Context.** Plane 1 runs on schedule (§4.1); collector failures are logged and surfaced, never silently retried into gaps; R4 mandates a daily gap-audit comparing expected vs. received collections.

**Problem.** What triggers scheduled collection on the chosen environment (ADR-007)?

**Alternatives considered.**
1. *Long-running Python daemon (APScheduler).* One more custom always-on process to crash, leak, and monitor; survives nothing the OS scheduler doesn't.
2. *cron via WSL2.* Imports ADR-007's rejected complexity through a side door and requires WSL to be running.
3. *Cloud schedulers.* Rejected with cloud collection generally.
4. *Windows Task Scheduler (chosen).* Native, reboot-surviving, session-independent, zero additional software.

**Decision.** Task Scheduler triggers all collection runs. Task definitions are exported as XML and version-controlled in `scheduler/` (§7.1) — the scheduler's configuration is code, not clicks.

**Rationale.** The scheduler should be the most boring, most native component available. Its known weaknesses — opaque failures, quiet misconfiguration — are mitigated where it matters: ingestion timestamps in the append-only store are ground truth for whether runs happened, so scheduler failure is *detectable in the data*, and R4's gap-audit converts detection into a standing daily report whose missingness figures are published alongside every n. The Spec sharpens why this matters beyond completeness: outages correlate with weather events and market volatility, so gaps bias the calibration sample *non-randomly* — missingness is a validity issue, not a bookkeeping one.

**Tradeoffs.** Clunky UI; awkward logging; headless-run environment quirks (working directory, user context, quoting — the vault-space lesson applies to pipeline invocations too).

**Risks.** Mitigates R4 jointly with the gap-audit. Accepts: sleep/power settings suppressing runs (configure wake timers; measure what remains); mid-run reboots from Windows updates (harmless under append-only — re-runs append, never corrupt).

**Challenge before acceptance.** "Just use a daemon with retries." Rejected: silent retries into gaps are *specifically prohibited* by the Plane 1 contract, because a retry that papers over an outage destroys the missingness record R4 depends on. The boring choice is also the honest one. Challenge fails.

**Future implications.** The gap-audit report is the evidence stream feeding ADR-007's revisit trigger.

**Revisit conditions.** (1) ADR-007's gap threshold. (2) Any migration off native Windows supersedes this ADR automatically.

---

## ADR-013 — Four-plane architecture with normative boundary rules

**Status:** Accepted *(new in v2.0 — Errata E2)*

**Context.** The Spec (§4) organizes the Lab as four planes — Collection (machine, scheduled), Storage (machine, passive), Analysis (machine, human-invoked), Judgment/Knowledge (human + AI, governed) — plus the Git governance spine, with normative boundary rules: no plane reaches around another.

**Problem.** A solo project has no organizational boundaries; every separation must be architectural or it doesn't exist. How is contamination between data, analysis, and conclusion prevented when one person (plus one AI) touches everything?

**Alternatives considered.**
1. *Monolith (scripts that fetch, analyze, and write conclusions).* The default gravity of solo projects. Fails P3 catastrophically: analysis "fixes" raw data in passing; hypotheses leak into collection choices; nothing is auditable because everything touches everything.
2. *Two layers (pipeline vs. notebook).* Better, but leaves the two worst seams unguarded: analysis writing into storage, and uncited numbers flowing into knowledge.
3. *Four planes with normative boundaries (chosen).* Collection never reads Planes 3–4 (collectors do not know what hypotheses exist); Analysis never writes raw tables; the vault never contains uncited quantitative claims — a number either links to a snapshot/artifact or is labeled assumption; retractions propagate along exactly these edges, in reverse (Invariant 5).

**Decision.** The four-plane structure and all §4.2 boundary rules are adopted as normative. Module contracts (§8) are the per-component expression of the same boundaries; "a collector that cleans data is a bug" is the standing example.

**Rationale.** Each boundary kills a specific, named failure mode: hypothesis-blind collectors prevent conclusions from contaminating what gets collected; read-only analysis prevents code from quietly rewriting evidence; the no-uncited-numbers rule makes the vault auditable sentence by sentence. The architecture is the organizational chart the solo researcher doesn't have — separation of duties implemented in structure because it cannot be implemented in staffing (R9).

**Tradeoffs.** Ceremony: some tasks that would be one script become two components and a handoff. That cost is accepted deliberately (§2: boredom is a feature).

**Risks.** Mitigates R3, R9, and the validity face of R2. Residual: boundary erosion under time pressure — the quick script that reads the vault to decide what to collect. Mitigation: boundary violations are validity debt in the Technical Debt Register (§12) and block grading of dependent findings, no exceptions.

**Challenge before acceptance.** "Four planes is enterprise cosplay for one person and five weather markets." The scale critique misreads what the planes cost: they are directory boundaries and read/write rules, not services and teams — near-zero overhead, and the failure modes they prevent (look-ahead, contaminated collection, unsourced claims) are precisely the ones that have historically invalidated solo quantitative research. Challenge fails.

**Future implications.** Every new capability declares its plane before implementation; anything wanting to live in two planes is two components.

**Revisit conditions.** (1) A boundary rule blocking legitimate work repeatedly (log instances; amend by superseding ADR, never by silent exception). (2) Collaboration or multi-machine operation, which would re-derive the boundaries as actual interfaces.

---

## ADR-014 — Content-addressed immutable snapshot store

**Status:** Accepted *(new in v2.0 — Errata E2)*

**Context.** Invariant 4 (snapshot-what-you-cite) and P4: no vault note, Research Summary, or ADR may cite a live URL, API response, or AI output without a recoverable snapshot. The Spec (§4.1, §8) specifies the mechanism: immutable captures addressed by content hash, with a provenance index (URL, fetch time, fetching component); a changed document is a new snapshot, never an overwrite. Milestone 1b's station-verification gate depends on snapshotted Kalshi rules pages.

**Problem.** Cited sources rot: NWS revises forecasts and documentation; Kalshi edits rules pages; AI outputs are unreproducible by nature. How does every citation stay recoverable for the life of the Lab?

**Alternatives considered.**
1. *Cite live URLs.* Guarantees eventual unauditability; silent upstream revision is R1's favorite disguise.
2. *Ad-hoc saved copies (PDFs in folders).* Better than nothing; but path-addressed copies get renamed, edited, and duplicated — no integrity guarantee, no dedup, no provenance.
3. *Web archive services.* Useful supplements, but third-party, non-comprehensive (API responses, AI outputs), and outside the audit boundary.
4. *Content-addressed local store (chosen).* Every snapshot filed under its content hash; an index maps hash → provenance; immutability enforced (no overwrite path exists); backed up off-machine (ADR-017), gitignored (§7.1) since integrity comes from hashing, not Git.

**Decision.** All cited material — API response bodies, rules pages, NWS documentation, analysis artifacts when cited, and AI outputs pending verification — enters the content-addressed snapshot store. Citations reference hashes or immutable paths.

**Rationale.** Content addressing gives three properties at once: *integrity* (the hash proves bytes are unaltered), *deduplication* (identical fetches are one object), and *citation permanence* (the reference cannot dangle while the store survives). It also makes retraction tractable: Invariant 5's cascade — retract snapshot → flag consuming artifacts → flag citing notes — requires stable identifiers to traverse, and hashes are the stablest identifiers there are. Storing AI outputs pending verification operationalizes Invariant 3: the exact untrusted input is preserved, so verification is verification *of something fixed*.

**Tradeoffs.** Snapshot discipline is friction on every citation; the store grows monotonically; hash-named files are human-opaque without the index (the index is therefore load-bearing and itself backed up).

**Risks.** Mitigates R1 (rules pages), R8 (pre-change behavior preserved for reconciliation), and P4's link-rot failure generally. Residual: the index diverging from the store (mitigation: a periodic integrity job re-hashes objects and reconciles the index — cheap and mechanical).

**Challenge before acceptance.** "Overkill; just save PDFs." The counter is Milestone 1b itself: the single highest-severity risk in the register (R1, settlement mismatch) is gated on rules pages *as they existed at verification time*. If Kalshi silently edits a rules page after verification, only a hash-addressed snapshot proves what was verified against. The store is not archival tidiness; it is the evidence room for the Lab's most severe risk. Challenge fails.

**Future implications.** Snapshotting becomes a collector responsibility (§5 step 1: raw response bodies likely to be cited are snapshotted at ingestion), so citation-readiness is default, not retrofit.

**Revisit conditions.** (1) Store size or object count outgrowing flat-directory practicality (introduce sharded directories — an implementation change, not a decision change). (2) A need for third-party-verifiable timestamps (would add, e.g., published hash digests — supplement, not replacement).

---

## ADR-015 — Dual Git repositories (pipeline and vault)

**Status:** Accepted *(new in v2.0 — requested by Spec Appendix A.1; resolves the §7 assumption)*

**Context.** The Spec assumes two repositories — `C:\Projects\weather-pipeline` and the vault — and explicitly flags single-vs-dual as requiring an ADR. Bootstrap §3 (initialization, `.gitignore`) is the immediate next step, so this decision must be settled now.

**Problem.** One repository or two, for artifacts with fundamentally different change patterns?

**Alternatives considered.**
1. *Single repository (vault as subdirectory of the project, or vice versa).* One history, one remote, one backup target. But: code evolves by refactor (rewrites, reverts, branches); knowledge evolves by accretion (append, supersede, never delete). Mixing them makes both histories noisy, couples a code rollback to a knowledge rollback (reverting a bad pipeline change must never appear to revert a finding), and forces one `.gitignore` to serve two unrelated hygiene problems.
2. *Dual repositories (chosen).* Pipeline repo and vault repo, each with its own history, remote, and ignore rules.
3. *Monorepo with sparse tooling.* Solves problems this project doesn't have at the cost of tooling it shouldn't need.

**Decision.** Two repositories. Pipeline: `C:\Projects\weather-pipeline` with `.gitignore` covering `data/`, `snapshots/`, `logs/`, `__pycache__/`, virtual environments, real `config.yaml` (commit `config.example.yaml`). Vault: `C:\Users\myname\Obsidian\Research Lab` (quote the space) with `.gitignore` covering `.obsidian/workspace*`, plugin caches, and OS cruft (`Thumbs.db`, `desktop.ini`).

**Rationale.** The change-pattern argument decides it: a commit in the pipeline repo means "the instrument changed"; a commit in the vault repo means "knowledge changed." Keeping those semantics unmixed makes both histories *readable as narratives* — which is what the governance spine is for (§4.2). The two also have different retraction semantics (code reverts are normal; knowledge deletions are prohibited — Archive, never delete, §7.2) and different sensitivity profiles, which separate remotes keep independently manageable.

**Tradeoffs.** Two remotes, two backup targets, two histories to search; cross-repo references (a finding citing the code commit that produced it) are by hash string, not by Git-native link — acceptable, since environment capture already records hashes as text.

**Risks.** Mitigates history-coupling noise and halves the blast radius of any repo mishap. Residual: cross-repo hash references have no referential-integrity check (mitigation: the R3 recomputation audit exercises them naturally — a dangling hash fails the recompute).

**Challenge before acceptance.** "Solo scale; one repo is simpler." Simpler today, noisier forever: history quality is a compounding asset in a project whose product is auditability. The one-time cost of a second `git init` buys permanently separable narratives. Challenge fails.

**Future implications.** Bootstrap §3 executes twice, deliberately: init, ignore, first commit, remote — pipeline first (it exists and is verified), vault second (walkthrough Sections 3–7 pending).

**Revisit conditions.** (1) Cross-repo referencing proving error-prone in practice (logged instances). (2) Collaboration tooling that materially prefers a monorepo (unlikely at any foreseeable scale).

---

## ADR-016 — Pre-committed SQLite→DuckDB analytical migration path

**Status:** Accepted (dormant until trigger) *(new in v2.0 — requested by Spec §6 and Appendix A.2)*

**Context.** §6 pre-registers where SQLite will break and commits, in advance, to the migration path: SQLite → DuckDB for analysis (reading the same file or Parquet exports) *before* any move to a server database.

**Problem.** Storage decisions revisited under pressure are revisited badly. What is the escape path, decided now while nothing is on fire?

**Alternatives considered (as future paths).**
1. *SQLite → PostgreSQL.* Solves concurrency, but abandons the file-you-can-hash property (§6) at the first sign of trouble, when the actual pressure is almost certainly analytical read performance, not write concurrency.
2. *SQLite → Parquet + query engine ad hoc.* Uncommitted; would be improvised under pressure — the exact failure this ADR exists to prevent.
3. *SQLite (durable store) → DuckDB (analytical layer) (chosen).* DuckDB reads SQLite files directly and exports Parquet; columnar performance for reliability diagrams over years of candles; zero change to the ingestion path or the durability story.

**Decision.** The pre-committed path is: keep SQLite as the durable append-only store; when triggers fire, add DuckDB as a read-only Plane 3 analytical layer over the same file (or over Parquet exports regenerated from it). A server database is considered only if DuckDB-level measures prove insufficient, via a superseding ADR.

**Triggers (verbatim from §6, binding):**
1. Observed lock timeouts in collector logs (writer contention).
2. Routine analysis queries exceeding minutes (analytical scale).
3. Any second machine (the decision itself is the trigger).

**Rationale.** Pre-commitment defeats hindsight for infrastructure exactly as for hypotheses (§2): deciding the migration while calm prevents the panic-Postgres that costs the reproducibility property. The chosen path preserves "the database is a file you can hash" longest, changes nothing in Plane 1, and respects the P3 boundary — the analytical layer is read-only by construction.

**Tradeoffs.** DuckDB adds a dependency to environment capture when activated; two query dialects in Plane 3 during transition.

**Risks.** Mitigates the panic-migration failure mode and part of R6. Residual: triggers firing unnoticed (mitigation: trigger 1 is visible in collector logs the gap-audit already reads; trigger 2 is visible to the operator by definition; trigger 3 is a decision).

**Challenge before acceptance.** "Why ADR a migration that may never happen?" Because the alternative is deciding it during an outage or a deadline — and because Appendix A.2 correctly identifies an undocumented escape path as a latent decision someone will eventually make silently, violating §0. Dormant ADRs are cheap; improvised migrations are not. Challenge fails.

**Future implications.** Analysis code should prefer standard SQL where costless, easing eventual dual-engine reads.

**Revisit conditions.** The three triggers above; additionally, DuckDB's SQLite-reading capability materially changing (verify at activation time — Invariant 3 applies to this ADR's own technical claims before they are relied on).

---

## ADR-017 — Off-machine backup with tested restore

**Status:** Accepted — implementation required; inserted into Bootstrap Checklist; blocks V1 exit gate *(new in v2.0 — requested by Spec R5 and Appendix A.3)*

**Context.** R5 names the Lab's largest unmitigated risk: disk failure or ransomware destroying database, snapshots, and vault *simultaneously*, on one machine. Git remotes (ADR-006) protect code and vault text only; `data/` and `snapshots/` are gitignored by design.

**Problem.** Every byte of evidence currently lives on one Windows machine. What survives its loss?

**Alternatives considered.**
1. *Git remotes only (status quo).* Protects both repos' text; loses every collected observation and every snapshot — i.e., loses the evidence while keeping the claims. Unacceptable on its face.
2. *Cloud sync (OneDrive/Dropbox) over data directories.* Continuous but sync ≠ backup: ransomware-encrypted or corrupted files sync too, and version retention is vendor policy, not Lab policy. Also re-imports the sync-vs-Git conflict the vault relocation escaped.
3. *Scheduled off-machine backups with periodic tested restore (chosen).* Versioned copies of `data/`, `snapshots/`, and both repos to at least one off-machine target (external drive and/or cloud object storage), on a schedule, with restore actually exercised.

**Decision.** A scheduled backup job copies the SQLite file(s), the snapshot store (objects and index), and fresh clones/bundles of both repos off-machine. Retention keeps multiple generations (ransomware defense: yesterday's encrypted garbage must not overwrite last month's good copy). **A restore test is performed before the V1 exit gate and at every version boundary thereafter** — per the Spec's own line, which deserves permanence: *an untested backup is a hypothesis, not a backup.*

**Rationale.** The Lab's entire epistemology reduces to recoverable evidence: Invariant 4 is void if the snapshot store can vanish; the calibration record is void if `data/` can. R5 is ranked severe-continuity for exactly this reason. Backup is not an operational nicety here — it is the physical substrate of every methodological guarantee in this collection.

**Tradeoffs.** Modest cost (storage target, scheduled job, restore-drill time); one more scheduled task to gap-audit (do so: backup runs are collections too — audit expected-vs-completed).

**Risks.** Mitigates R5 (the register's largest unmitigated item until this ships). Residual: single off-machine target still correlates with local disasters (mitigation: prefer one physical + one cloud target when convenient; record the choice); backup job failure going unnoticed (mitigation: fold into the R4 gap-audit report).

**Challenge before acceptance.** "Defer until there's more data worth protecting." Backwards: the cost of implementing now is hours; the cost of implementing after loss is the project. Also self-defeating — Milestone 1a data plus the vault *is already* months of unreproducible history (market prices at past timestamps cannot be re-fetched). Challenge fails decisively. If anything, v1.0 erred by leaving this inside ADR-006's risk notes rather than elevating it; the Spec's Appendix A.3 is correct that it warrants standalone force.

**Future implications.** Restore drills join the version-boundary amnesty audit (§12); backup completeness appears in the gap-audit report.

**Revisit conditions.** (1) Data volume outgrowing the target (mechanical fix). (2) Multi-machine operation (backup topology redesign, jointly with ADR-016 trigger 3).

---

## ADR-018 — Validation-gated versioning (gates, not dates)

**Status:** Accepted *(new in v2.0 — Errata E2; Spec §9)*

**Context.** §9 defines V1 (Instrument) → V2 (Comparator) → V3 (Decision Layer *or* Observatory), each opened only when the predecessor's exit gate is met and recorded. V1's gate: three consecutive gap-audited months; ≥300 city-days scored across the full ladder; one pre-registered study completed end-to-end — with the explicit clause that a null finding passes, because the gate tests the instrument, not the result.

**Problem.** Solo projects drift on two currents: calendar pressure ("it's been six months, ship something") and excitement pressure ("this divergence looks tradeable, skip ahead"). What governs progression?

**Alternatives considered.**
1. *Calendar milestones.* Guarantee that whatever exists at the date gets promoted, validated or not — institutionalized R10.
2. *Discretionary progression.* "I feel ready" is motivated reasoning with a steering wheel (R9).
3. *Pre-registered exit gates with recorded evidence (chosen).* Progression is a checkable predicate over auditable artifacts.

**Decision.** Versions are gated by validation criteria, never dates. Gates are pre-registered before the version begins (V3's gate is explicitly defined only at V3 entry); gate satisfaction is recorded with evidence in the vault; the §12 amnesty audit runs at every boundary.

**Rationale.** This is pre-registration (ADR-011) applied to the *project itself* — the same mechanism, one level up. The gate design encodes two deep commitments: the null-result clause makes the instrument's honesty independent of what it finds (killing the incentive to torture data toward a gate-passing "edge"), and the V3 fork legitimizes The Observatory as a terminal state, which is the structural antidote to R10 — the project does not *need* an edge to exist to have succeeded. The anti-goldplating clause (§12) guards the opposite failure: polishing infrastructure forever to avoid the vulnerability of producing a finding; the end-to-end-study requirement forces contact with reality.

**Tradeoffs.** Progress can stall on a gate for reasons partly outside control (e.g., a collection outage breaking the three-consecutive-months clock); gates must be amended by ADR, not waived in the moment.

**Risks.** Mitigates R10 (insidious) and R9. Residual: gate-shopping — reinterpreting ambiguous criteria post hoc (mitigation: gates state numeric criteria; ambiguities discovered mid-version are resolved by ADR *before* the evidence exists to favor either reading).

**Challenge before acceptance.** "Gates are academic; opportunity is time-sensitive." The premise smuggles in the conclusion that there is an opportunity — which is precisely the unvalidated claim. An edge that cannot survive three months of instrument validation was noise; an edge that can will still be structural when the gate opens. Challenge fails.

**Future implications.** Every version's first artifact is its gate registration; every version's last artifact is its gate-satisfaction record plus amnesty audit.

**Revisit conditions.** (1) A gate proven mis-specified by evidence (amend by superseding ADR with rationale). (2) External structural change (e.g., Kalshi discontinuing weather markets) invalidating a gate's premises — triggers re-registration, not waiver.

---

## ADR-019 — Settlement reconciliation check as first post-bootstrap code

**Status:** Accepted (implementation scheduled — first coding task after Bootstrap completes) *(new in v2.0 — Spec R1 and Appendix A.5)*

**Context.** R1, ranked most severe in the register: if the station, climate-day boundary, rounding convention, or unit handling Kalshi actually settles against differs from what we collect, *every score is silently wrong* — the instrument measures nothing while appearing to measure calibration. Milestone 1b's gate (verify station IDs against snapshotted Kalshi rules pages) checks this once, statically.

**Problem.** Static verification catches today's mismatch. What catches next quarter's — a rules revision, a station change, a rounding-convention edge case that only appears at .5°F?

**Alternatives considered.**
1. *Milestone 1b static verification only.* Necessary, insufficient: verifies configuration at a point in time against documents that can change (R8).
2. *Periodic manual spot-checks.* Unscheduled diligence decays (R9); manual comparison misses systematic small biases.
3. *Continuous automated reconciliation (chosen).* For every resolved market, compute our settlement from our observation data and compare with Kalshi's actual settlement; alarm on any mismatch.

**Decision.** A standing reconciliation job runs over every resolved city-day market: our-computed settlement vs. Kalshi-reported settlement. Any mismatch alarms and quarantines affected city-days from scoring until explained. Per the Spec, this is *the single highest-value piece of code after the collectors themselves*, and it is scheduled as the first post-bootstrap coding task.

**Rationale.** This check converts R1 from a trust assumption into a continuously tested empirical claim — the validation-philosophy §11 principle ("instrument validation... validates the outcome variable continuously") realized in code. Its diagnostic power is total for its domain: agreement across hundreds of city-days is strong evidence the entire settlement pathway (station, boundaries, rounding, units) is correct end to end; a single mismatch localizes a severe defect *before* it contaminates a finding. Cost is trivial — both quantities already exist in the database.

**Tradeoffs.** Requires collecting Kalshi's reported settlement outcomes (a small collector addition); occasional false alarms from late observation revisions (handled naturally: dual timestamps distinguish revision from mismatch).

**Risks.** Mitigates R1 (the register's top item) continuously, and R8 partially (a rules change surfaces as a reconciliation break). Residual: the window between Bootstrap completion and the check shipping is unprotected beyond Milestone 1b's static gate — hence "first coding task," not "soon."

**Challenge before acceptance.** "Milestone 1b already covers this." It covers *initial configuration*; it cannot cover drift, revisions, or conventions that only manifest on realized edge cases (a 100.5°F day tests rounding in a way no rules page reading can). Static and continuous verification are complements; the severe rank of R1 justifies both. Challenge fails.

**Future implications.** Every §13 Axis-2 domain audit must specify its equivalent reconciliation before admission — this ADR becomes the template for "verifiable ground truth of R1-manageable quality."

**Revisit conditions.** (1) Kalshi ceasing to publish settlement values in retrievable form (would force redesign and re-rank R1 upward). (2) Persistent unexplained mismatches (fires Invariant 5 quarantine on affected scores and opens an incident review).

---

## ADR-020 — Mission.md amendment

**Status:** Proposed — awaiting architect decision *(formalizes Spec §1.1 and Appendix A.4; supersedes the informal flag in v1.0's ADR-001)*

**Context.** Mission.md names stock markets, politician-trade tracking, and "statistically profitable opportunities" as objectives. The Spec (§1.1) raises three specific objections: it conflicts with the actual project ("the goal is explicitly not prediction and not trading"); politician-trade tracking is a materially different research program (different data, legal considerations, statistical structure, weaker ground truth); and profitability is an outcome, not a mission. The Spec proposes a two-sentence replacement and requires an architect decision plus ADR — this is that ADR.

**Problem.** The project's topmost document describes a different project than the one every other governing document builds. Mission-architecture divergence is a latent source of scope drift (R10) and a standing invitation to fragmentation.

**Alternatives considered.**
1. *Leave Mission.md unchanged.* The divergence remains authoritative-looking; every future prioritization argument can cite the mission against the architecture. Worst option.
2. *Delete the broad ambitions.* Loses genuinely held long-term intent; also violates the archive-never-delete ethos (§7.2).
3. *Amend Mission.md to the Spec's two-sentence instrument mission; move broader ambitions to `Future_Directions.md` with decaying status (chosen, as proposed by §1.1).* The mission states what the Lab *is*; the ambitions are preserved, dated, lifecycle-marked, and explicitly gated behind §13's admission tests.

**Decision (proposed).** Adopt alternative 3 verbatim from §1.1: Mission.md becomes — "Build a reproducible research platform that measures divergence between modeled and market-implied probabilities, beginning with weather prediction markets. Findings must be auditable, pre-registered, and honest about sample size and uncertainty." — and `Future_Directions.md` (03_Open_Questions or 01_Governance; recommend 01_Governance, decaying status) receives the equities/politician-trade/profitability ambitions with pointers to §13's standing exclusions.

**Rationale.** A mission that matches the architecture makes every downstream document self-consistent; a mission that doesn't is a fork in the project's identity that will be exploited by the most motivated future reading (R10 is *insidious* precisely because it recruits the mission's own words). The amendment loses nothing: the ambitions survive, honestly labeled as futures rather than objectives.

**Tradeoffs.** The mission narrows on paper. That is the point; whether it is *desirable* is the architect's call, not the Director's — hence Proposed.

**Risks.** Mitigates R10 at its root. Residual if adopted: none identified. Residual if rejected: this ADR should then be revised to *Accepted-as-amended* documenting how the broad mission and V1 scope are reconciled — the intolerable outcome is silence.

**Challenge before acceptance.** The strongest case for the status quo: "the broad mission is the actual ambition; the Spec is a phase plan, and missions should outlive phases." Fair — but that position is *exactly* alternative 3 with different labels: state the durable ambition somewhere honest (`Future_Directions.md`), state the operative mission in Mission.md, and let §13's gates connect them. The disagreement dissolves under precision. The proposal stands.

**Future implications.** If adopted: amendment committed with this ADR referenced; Bootstrap Log entry; `Future_Directions.md` created during the vault walkthrough. If rejected: revise this ADR with the architect's rationale — no orphan decisions in either direction.

**Revisit conditions.** V2 exit gate (§9): if durable divergence content is found, the mission conversation legitimately reopens with evidence in hand; if V3 becomes The Observatory, the amended mission is already correct.

---

## ADR-021 — AI context boundaries: vault and Git as sole system of record

**Status:** Accepted *(new in v2.0 — arising from the E1 incident)*

**Context.** During this collection's drafting, two facts about the AI collaborator's memory became operationally relevant: (1) Claude cannot retrieve files it produced in past sessions — deliverables exist for Claude only within the session that produced them, plus summarized memory afterward; (2) Claude cannot verify Project-file timestamps, so claims about what was present when are observations, not records. The E1 provenance error is the incident report.

**Problem.** A collaborator with session-scoped memory and no filesystem history participates in producing permanent governing documents. What conventions prevent that architecture from injecting provenance errors into the record?

**Alternatives considered.**
1. *No convention; handle ad hoc.* Guarantees E1 recurs in less visible forms.
2. *Re-upload everything every session.* Maximally safe, maximally tedious; most sessions need summaries, not verbatim texts.
3. *Explicit convention (chosen):* the vault and Git are the sole system of record; Claude's context and memory are working buffers; anything Claude must work on *verbatim* is re-uploaded or pasted that session; Claude scopes all provenance claims ("as visible to me now") and flags when it is working from memory summaries rather than documents in hand.

**Decision.** Adopt the convention. Corollaries: (a) deliverables are canonical only once placed in the vault and committed — Claude's output message is a draft transmission, not a record; (b) when a session depends on a prior deliverable's exact text, the architect re-uploads it or Claude states explicitly that it is working from summary; (c) Claude states its evidence basis when making claims about project state.

**Rationale.** This is Invariant 3 and P4 applied to the AI's *own memory*: an unverifiable recollection is untrusted input exactly as an unverified citation is. The convention also strengthens the architecture's existing commitments rather than adding new machinery — it is one more reason the vault-plus-Git spine, not any participant's memory (human memory has the same failure modes on longer timescales — R9's abandonment-and-return), is where truth lives.

**Tradeoffs.** Occasional re-upload friction; slightly more verbose provenance language from Claude.

**Risks.** Mitigates R9's context-loss face and prevents E1-class errors from entering graded material. Residual: memory summaries silently diverging from vault truth (mitigation: when a discrepancy between Claude's stated understanding and the vault is noticed, the vault wins and the discrepancy is logged).

**Challenge before acceptance.** "This over-formalizes a chat limitation." The E1 incident is the rebuttal: an unscoped provenance claim entered a governing-document draft on the first attempt. Cheap conventions that intercept known failure modes are exactly what this Lab is made of. Challenge fails.

**Future implications.** If Anthropic tooling later provides verifiable past-session retrieval, corollary (b) relaxes by superseding ADR; the system-of-record principle does not.

**Revisit conditions.** (1) Tooling changes to Claude's memory/file access (verify capabilities before relying — Invariant 3). (2) The convention's friction demonstrably exceeding its catch rate over a version cycle.

---

## Cross-cutting observations from this review

1. **One idea, many faces.** Append-only storage, content-addressed snapshots, Git history, pre-registration, verify-before-grade, credential-free collection, gated versions, and now AI context boundaries are all the same principle in different materials: *make it structurally impossible to quietly rewrite the past.* Test every future decision against that principle first.
2. **Three ADRs carry immediate action into Bootstrap §3:** ADR-015's two-repository initialization with the specified `.gitignore` contents; ADR-003's UPDATE/DELETE prohibition triggers shipping with the schema; ADR-017's backup job insertion into the checklist (Spec Appendix A.3).
3. **One ADR awaits the architect:** ADR-020 (Mission.md). Per Spec §0 and the acceptance clause of RL-SPEC-001 itself, resolving it is a precondition of the Spec's own acceptance — it should be decided before or alongside the first governance commit.
4. **Standing audits now total five:** quarterly AI-claim spot-audit (ADR-005), daily gap-audit including backup runs (ADR-012, ADR-017), day-level clustering robustness check in the analysis template (ADR-010), snapshot-store integrity re-hash (ADR-014), and continuous settlement reconciliation (ADR-019).
5. **Spec Appendix A status after this collection:** A.1 resolved (ADR-015); A.2 resolved (ADR-016); A.3 decided, implementation pending (ADR-017); A.4 proposed for decision (ADR-020); A.5 decided, scheduled (ADR-019); A.6 remains open — the V2 power analysis is pre-registered at V2 entry, not now.

---

*End of ADR Collection v2.0. Acceptance requires architect review (Invariant 3), resolution of ADR-020, and commit to the vault repository once Bootstrap Checklist §3 completes. v1.0 is superseded in full; per §7.2, move it to 08_Archive rather than deleting it.*
