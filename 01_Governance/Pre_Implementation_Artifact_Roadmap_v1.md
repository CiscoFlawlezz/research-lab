# Pre-Implementation Artifact Roadmap & Frontier-Session Allocation

**Document ID:** RL-ROADMAP-001
**Version:** 1.0 (Draft — Invariant 3: ungraded until verified)
**Date:** 2026-07-06
**Placement:** `00_Dashboard/`
**Purpose:** Enumerate every document, specification, methodology, ADR, statistical framework, and operating procedure that should exist before implementation begins, ranked for allocation of remaining frontier-model (Fable 5) sessions.
**Governing documents:** Research Methodology v2 (constitutional), Research Lab Master Specification v1.0.

---

## 1. Allocation doctrine

Frontier capability is a scarce, possibly expiring resource. It should be spent where three properties coincide: the artifact is **hard to produce** (deep derivation, adversarial reasoning, anticipation of subtle failure modes), **cheap to verify** (a weaker model or the researcher can check it once it exists), and **durable** (it governs many downstream decisions rather than one). It should *not* be spent on work that is mechanical, easily reproduced, or cheap to redo if wrong.

One property overrides all scoring below: **irreversibility.** Data not collected today cannot be backfilled. Any artifact whose absence causes permanent data loss outranks its own scores. This creates exactly one sequencing exception, identified in §4.

Scoring dimensions, each rated 1–5:
- **L** — Long-term leverage (how much downstream work it governs)
- **W** — Difficulty for weaker models to reproduce
- **R** — Risk if designed incorrectly
- **F** — Dependency on frontier-level reasoning

---

## 2. The roadmap

### Tier 1 — Frontier-mandatory (spend Fable 5 sessions here)

---

**A1. Statistical Validity & Inference Framework** — L5 W5 R5 F5

The single document that determines whether the Lab's findings will be statistics or numerology. Must specify: (a) the *effective* sample size problem — city-day is the honest counting unit, but city-days are not independent across cities on the same calendar day (synoptic weather systems correlate NY–CHI strongly, and market-wide sentiment correlates everything), so effective n is smaller than city-day n and the framework must say how much and how estimated; (b) the machinery for comparing forecasters — paired score differentials on identical city-day sets, block-resampling schemes that respect both temporal and cross-city correlation, and the conditions under which a score difference is interpretable; (c) multiplicity control across cities, ladder rungs, and cutoff times; (d) minimum-n and decidability rules that every pre-registration must import; (e) pre-committed reliability-diagram binning.

*Why Fable 5:* This is the artifact weakest models get confidently wrong — they will hand you an i.i.d. t-test and call it rigor. Errors here are subtle, systemic, and embed themselves in every pre-registration that imports the framework. Wrongness is technically recoverable (re-analysis from raw data) but reputationally and motivationally expensive: it retracts every downstream finding at once (Invariant 5). Highest combined score on all four criteria. **Verdict: consumes a full frontier session, and deserves it more than anything else on this list.**

---

**A2. Forecast-to-Probability Conversion Methodology (ADR + method specification)** — L5 W5 R4 F5

Defines the model rung of the reference ladder: how an NWS point forecast becomes a probability distribution over Kalshi's bracket/threshold structure. Must cover: error-distribution estimation from historical forecast-vs-observation residuals per station; distributional form and tail behavior (bracket markets pay disproportionate attention to tails); lead-time dependence; discretization onto T###/B###.# structures; seasonality handling; and the honest alternatives considered with their tradeoffs.

*Why Fable 5:* Genuine statistical modeling judgment with several defensible-looking wrong answers (e.g., homoskedastic Gaussian errors ignoring seasonal and lead-time structure). R is 4 rather than 5 only because the pipeline stores *raw* forecasts — a bad conversion can be redesigned and re-run over stored history without data loss. **Verdict: full frontier session.**

---

**A3. Collection Sufficiency Audit** — L4 W3 R5 F4 — **sequencing exception, see §4**

A systematic answer to: *is the pipeline collecting, today, every field that any V1–V3 analysis will need?* Candidates for gaps: bid/ask spread and depth (candlesticks alone may hide the microstructure that A4 needs); order-book or last-trade granularity around chosen cutoff times; the full NWS forecast *issuance history* rather than latest-only (look-ahead discipline requires knowing every issuance's ingestion time); NWS probabilistic/gridded products V2 will want (ensemble-derived fields cannot be backfilled); market metadata revisions; settlement announcements as published by Kalshi (needed by the reconciliation check).

*Why Fable 5:* The hard part is not auditing what exists — it is anticipating what Version 2 and 3 analyses will require, which demands the architect's whole-project view. W is only 3 because a weaker model could execute a checklist; the frontier value is *writing* the checklist. R is 5 because every gap is permanent: history not captured is gone. **Verdict: frontier session — and the first one, despite not having the highest total score, because irreversibility beats importance on a running clock.**

---

**A4. Market-Implied Probability Normalization Specification** — L4 W4 R4 F4

Pre-registered rules converting Kalshi prices into probabilities: mid vs. microprice vs. last-trade; fee incorporation; staleness thresholds; treatment of incomplete bracket coverage and sum-to-one violations; the liquidity metrics recorded alongside every implied probability. Guards R7 — microstructure noise masquerading as divergence, the most seductive false positive this Lab will face.

*Why Fable 5:* Requires market-microstructure judgment weaker models fake badly, and it feeds directly into what A3 must confirm is being collected. **Verdict: frontier session; can share a session with A3 since they co-determine each other.**

---

### Tier 2 — Frontier-preferred (use Fable 5 if sessions remain; verify hard regardless)

---

**A5. Scoring Verification Fixture Set** — L4 W3 R5 F3

Worked numerical examples — small synthetic forecast/outcome sets with Brier scores, log scores, and full Murphy decompositions computed step by step — that become permanent unit-test fixtures. All future scoring code, written by anyone, is correct iff it reproduces these numbers.

*Why this tier:* High leverage and high risk, but the *production discipline matters more than the model*: fixtures must be generated by executed code cross-checked against the vaulted bibliography's worked examples, never by any model's mental arithmetic — frontier models included. A frontier session adds value in choosing adversarial edge cases (degenerate forecasts, single-bin outcomes, decomposition identities) more than in the arithmetic itself. **Verdict: half a frontier session for edge-case design; execution is mechanical.**

---

**A6. Settlement Verification Protocol & Reconciliation Check Specification** — L4 W2 R5 F3

The Milestone 1b procedure: per-city verification of station ID, climate-day boundary, rounding and unit conventions against snapshotted Kalshi rules pages, plus the specification of the standing check comparing computed settlement to Kalshi's published settlement for every resolved market, alarming on mismatch.

*Why this tier:* Highest single validity risk in the project (R1), but the work is adversarial *diligence*, not deep derivation. A frontier model reads fine print marginally better; a careful human with a checklist reads it well enough, and the reconciliation check catches residual errors empirically. **Verdict: protocol design in half a frontier session; execution with any model or none.**

---

**A7. Divergence Triage Protocol (Alternative-Explanations Checklist)** — L4 W3 R3 F3

Operationalizes Rules.md ("always consider alternative explanations") into a standing ordered checklist every observed divergence must survive before being treated as a phenomenon: settlement mismatch → data gap → look-ahead leakage → stale quote/spread artifact → multiplicity → then, and only then, candidate signal. Includes required evidence for clearing each rung.

*Why this tier:* High reuse, moderate depth. A frontier model enumerates failure modes more completely; the structure itself is straightforward. **Verdict: bundle into the A1 session's final hour — the checklist is largely a corollary of the inference framework.**

---

**A8. Climatology Baseline Construction Specification** — L3 W3 R3 F3

Defines the ladder's bottom rung: data source and period for station climatology, window construction (day-of-year smoothing), leakage rules (climatology must be computable strictly from data before the forecast date), and refresh policy.

*Why this tier:* Well-trodden methodology with textbook answers; errors are visible and recoverable. **Verdict: does not merit a dedicated frontier session; append to the A2 session, since the two rungs share residual-history plumbing.**

---

### Tier 3 — Meta-leverage (frontier-optional, strategically timed)

---

**A9. Model Transition & AI Collaboration Protocol** — L5 W4 R3 F3

The handoff document: what any *future, possibly weaker* model must be given per task class (context pack contents, governing-document excerpts), what task classes weaker models are barred from (anything touching A1–A4 design), mandatory verification standards per artifact class, and the standing instruction set that preserves this Lab's working discipline across model generations.

*Why this tier:* Directly serves the motivation behind this roadmap — it multiplies the value of every future session with any model. F is only 3 because the frontier model's advantage here is self-knowledge and completeness, not derivation. **Verdict: worth one short frontier session near the end of the Fable 5 window, once Tier 1 artifacts exist and can be referenced by it.**

---

**A10. Study 1 Pre-Registration** — L5 W4 R4 F4

The first end-to-end calibration study registration: question, ladder comparison, cutoffs, bins, minimum effective n, decidability date, all importing A1/A2/A4/A8 by reference.

*Why this tier despite high scores:* **Blocked.** It cannot responsibly be written before A1 and A2 exist; a pre-registration that guesses its own inference machinery is pre-registration theater. **Verdict: frontier session, but sequenced after Tier 1 — likely the last major Fable 5 artifact.**

---

### Tier 4 — Any model, or no model (do not spend Fable 5 here)

---

**A11. Gap-Audit & Data-Quality SOP** — L3 W2 R3 F2. Daily expected-vs-received completeness accounting and missingness reporting. Template work once A3 defines what "complete" means.

**A12. Residual small ADRs** — L2 W1 R2 F1. Ratify repo structure as-built; SQLite→DuckDB triggers (already drafted in Master Spec §6); scheduler conventions. Transcription of decisions already made.

**A13. Register seeding** — L2 W1 R2 F1. Technical Debt Register and risk register instantiation from Master Spec §10/§12. Copy-and-structure work.

**A14. Vault walkthrough Sections 3–7** — L2 W1 R1 F1. File placement and linking. Explicitly the wrong use of a frontier session; interleave as low-energy work.

---

## 3. Summary ranking for Fable 5 allocation

| Rank | Artifact | L | W | R | F | Session cost |
|---|---|---|---|---|---|---|
| 1* | A3 Collection Sufficiency Audit | 4 | 3 | 5 | 4 | 1 (shared w/ A4) |
| 2 | A1 Statistical Validity & Inference Framework | 5 | 5 | 5 | 5 | 1 full |
| 3 | A2 Forecast→Probability Conversion (+A8) | 5 | 5 | 4 | 5 | 1 full |
| 4 | A4 Market Normalization Spec | 4 | 4 | 4 | 4 | shared w/ A3 |
| 5 | A10 Study 1 Pre-Registration | 5 | 4 | 4 | 4 | 1 (after 1–4) |
| 6 | A9 Model Transition Protocol | 5 | 4 | 3 | 3 | 0.5 (last) |
| 7 | A5 Scoring Fixtures (edge-case design) | 4 | 3 | 5 | 3 | 0.5 |
| 8 | A6 Settlement Protocol (design only) | 4 | 2 | 5 | 3 | 0.5 |
| 9 | A7 Divergence Triage Checklist | 4 | 3 | 3 | 3 | bundle w/ A1 |
| 10–13 | A11–A14 | ≤3 | ≤2 | ≤3 | ≤2 | none |

\* Rank 1 by sequencing (irreversibility), not by total score. A1 is the highest-leverage artifact; A3 is the most urgent.

Estimated total frontier budget: **five to six focused sessions** covers everything above the line. Everything else survives contact with any competent model plus your verification discipline.

## 4. The sequencing exception, stated plainly

A1 outscores A3 on every dimension except one that is not a dimension: **time.** Every week without the sufficiency audit is a week in which possibly-incomplete data accrues irreplaceably. The audit is also the cheapest Tier 1 item. Therefore: A3+A4 first (one session), then A1, then A2+A8, then A5/A6/A7 halves, then A10, then A9. If only *one* Fable 5 session remained, it should go to A1 — the audit's checklist could be approximated; the inference framework could not.

---

*End RL-ROADMAP-001 v1.0 draft. Enters vault ungraded; graded upon architect verification per Invariant 3.*
