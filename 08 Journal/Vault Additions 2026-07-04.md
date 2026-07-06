# Vault Additions — Session of 2026-07-04

**Purpose:** Convert today's knowledge-acquisition session (proper scoring rules & calibration) plus carryover items from Milestone 1a into permanent vault structure.
**Principle applied throughout:** every addition must either (a) be load-bearing for a future decision, or (b) prevent a known failure mode. Nothing is added for completeness' sake — folder and note sprawl is itself a failure mode for a years-long project.

---

## 1. New folders

**`07 Experiments/Templates`**
*Why:* Experiments are about to become real (Experiment #1 is proposed and pre-registration is pending). A template enforced by location — copy from Templates, fill, file — is the cheapest possible process control. One folder, one purpose.

**No other new folders.** Deliberate restraint: today generated notes, not new domains. The existing 00–09 structure absorbs everything below. Recommendation recorded so future sessions know the option was considered and rejected, not overlooked.

---

## 2. New permanent notes

**`01 Research/Probability/Proper Scoring Rules & Calibration — Technical Reference`** *(file the document delivered today)*
*Why:* The measurement theory for the entire project. Every model acceptance decision references it.

**`09 Resources/Research Papers/Scoring Rules Bibliography — Ranked`** *(file the document delivered today)*
*Why:* Separates "the field's canon" from "what we must actually read" — the distilled 6-item required list at the bottom is the actionable part.

**`01 Research/Probability/Log Score ↔ Kelly Identity`**
*Why:* The single most load-bearing result of the day — expected log-growth of a Kelly bettor against market price = expected log-score difference vs the market. It deserves standalone status because it will be cited from three directions: [[Kelly Criterion]], [[Expected Value]], and [[Edge Detection]]. Content: the derivation from the Technical Reference, extracted verbatim.

**`01 Research/Probability/Effective Sample Size`**
*Why:* Encodes the correlated-brackets trap: brackets within a city-day are one observation; city-days co-move regionally; honest n ≈ ≤150/month, not 900. This note is the standing defense against the project's most tempting future error (premature conclusions from inflated n). Every analysis must link to it.

**`04 Data Sources/Kalshi API/Ticker Anatomy & Market Structure`**
*Why:* Empirical findings from the 1a live run: `SERIES-DATE-T###` = threshold markets, `B###.#` = brackets; quotes exist without trades (bid/ask carries probability information at zero volume); `_dollars`/`_fp` field regime post-March-2026. Institutional memory that prevents re-derivation and guards against silently misreading tickers later.

**`01 Research/Probability/Brier Decomposition — Worked Example`** *(stub now, fill when pipeline data exists)*
*Why:* Formulas without a worked example on our own data don't stick. Creating the stub now records the intent and gives the 14-day dataset an immediate consumer.

---

## 3. Decision logs (entries for `00 Dashboard/Decision Log`)

Each entry: decision, date, rationale, revisit-trigger.

1. **Weather selected as first market category** (2026-07-03/04) — daily resolution maximizes sample accumulation; objective NWS settlement; free features. *Revisit if:* weather markets prove too efficient to be informative even as a testbed.
2. **SQLite, append-only, dual-timestamp storage; no credentials in the collection layer** (2026-07-03) — lookahead-bias prevention and credential-safety by construction. *Revisit if:* multi-machine or cloud migration.
3. **Evaluation standard: proper scores only — Brier AND log computed on everything; report skill scores, never optimize them** (2026-07-04) — propriety prevents selecting for dishonest models; skill scores are themselves improper. *Revisit:* effectively never; this is foundational.
4. **Unit of statistical evidence = city-day, with date-clustered inference** (2026-07-04) — brackets are dependent; naive n triples-to-sextuples apparent evidence. *Revisit if:* empirical correlation analysis shows city-days are nearly independent (would loosen, not tighten).
5. **Reference ladder for skill: climatology → NWS forecast → market price; "edge" defined as dependence-robust positive skill vs market** (2026-07-04) — makes the project's central term precise and testable. *Revisit:* only to add references, never to remove the market as the final bar.
6. **Knowledge sequencing: measurement before modeling** (2026-07-04) — scoring rules taught before any estimation topic; prevents building models with no legitimate grading system. Documents the ordering rationale for future contributors (including future-us).

*Why decision logs matter here:* the charter demands continuity across years. Rationale decays faster than decisions; the log preserves both plus the conditions under which each should be reopened.

---

## 4. Experiment templates (for `07 Experiments/Templates`)

**`Pre-Registered Experiment Template.md`** with mandatory sections:

- **Hypothesis** (falsifiable, stated before data inspection)
- **Event set** (which markets/cities/dates, fixed ex ante — the anti-cherry-picking clause)
- **Data extraction rules** (e.g., which price is "the market's forecast," at what timestamp)
- **Metrics** (proper scores only; decompositions planned in advance)
- **Inference plan** (clustering scheme, test or bootstrap procedure, significance threshold)
- **Success / failure criteria** (what result means what, decided in advance)
- **What would change my mind** (per the project Thinking Framework, step 6)
- **Results** (filled after — never edited above this line post-registration)
- **Post-mortem** (what we learned about method, not just outcome)

*Why:* Selection effects and multiple testing are the quiet killers of retail quant research. Pre-registration is the strongest cheap defense, and a template makes the discipline the default rather than a virtue that must be re-summoned each time. First user: Experiment #1.

---

## 5. Glossary additions (for a new `00 Dashboard/Glossary` note)

*Why a glossary at all:* precise shared vocabulary is what lets a years-long solo project stay consistent with itself; drift in what "edge" or "calibrated" means is drift in the research itself. One alphabetical note, one-to-two-line definitions, each linking to the full treatment.

Add today: **proper / strictly proper scoring rule · calibration (reliability) · sharpness · resolution · uncertainty term · Brier score · log score · Brier Skill Score (BSS) · RPS / CRPS · KL divergence · reliability diagram · ECE · Murphy decomposition · Kelly criterion · Kelly–log-score identity · favorite–longshot bias · city-day (unit of evidence) · reference ladder · climatology (as baseline) · Diebold–Mariano test · LMSR · pre-registration · midpoint (as market forecast proxy) · threshold vs bracket markets (Kalshi T/B tickers)**

---

## 6. Research questions (for `01 Research` — a standing `Open Questions` note, reviewed each sprint)

1. **Are Kalshi weather markets calibrated?** Is a favorite–longshot bias present? *(→ Experiment #1; the project's first empirical result.)*
2. **What is the correct market-forecast extraction rule?** Midpoint vs time-weighted midpoint vs microprice; treatment of wide/absent quotes. *(Blocks Experiment #1 pre-registration — must be answered first.)*
3. **What is the empirical cross-city, cross-day correlation of outcomes and score differentials?** *(Determines real statistical power and required collection duration.)*
4. **Are NCEI/IEM historical forecast archives usable for backfill?** *(Carryover from Milestone 1; if yes, multiplies sample size immediately — highest-leverage open item.)*
5. **How does market calibration vary with time-to-settlement?** (Morning prices vs final-hour prices are different forecasts.)
6. **Is market efficiency in these markets improving over time?** (Nonstationarity would silently invalidate pooled historical scoring.)
7. **Does quote staleness in thin brackets bias market scores, and in which direction?**

*Why:* the Thinking Framework's step 6 ("what new information would most change the estimate") deserves a permanent home rather than living scattered in session transcripts.

---

## 7. Future milestones (for `00 Dashboard/Master Roadmap`)

Listed with gates, per the one-milestone-at-a-time rule; only 1b is *active* next.

- **Milestone 1b — Storage + scheduled collection.** Gate to start: station-ID verification complete. Success: 14 consecutive days, zero silent failures, point-in-time join demonstrated. *(Already defined; restated for the roadmap.)*
- **Milestone 1c (optional) — Always-on collection host** (cheap VM or Raspberry Pi). Gate: 1b reveals laptop-availability gaps in the audit log. *Why:* fixes the known weakest link only if it proves to actually bite.
- **Milestone 1d (conditional) — Historical backfill module.** Gate: Research Question 4 answered yes. *Why:* highest-leverage sample-size multiplier; pointless to build before archives are verified usable.
- **Milestone 2 — Experiment #1: Market Calibration Study.** Gates: pre-registration complete (needs RQ2 answered) AND sufficient city-days collected per the Effective Sample Size note. *Why:* the first empirical product; model-free; directly informs whether and where edge is plausible.
- **Knowledge Milestone K2 — Climatology & Base Rates** (next teaching topic). *Why:* the reference floor every model must beat; first *modeling-side* knowledge.
- **Knowledge Milestone K3 — Market Efficiency & the Favorite–Longshot Literature** (Wolfers/Zitzewitz, Snowberg/Wolfers). Gate: after Experiment #1 design exists, so the literature is read with our own data questions in mind.
- **Milestone 3 — First probability model.** Gate: Experiment #1 complete + K2 done + acceptance criteria (positive BSS vs climatology with date-clustered CIs; reliability not materially worse than market) formalized in Edge Detection. *Why the gate:* the charter forbids assuming an edge; a model built before we know how the market scores is a model built blind.

---

## Summary of immediate vault actions (checklist)

- [ ] Create `07 Experiments/Templates` + Pre-Registered Experiment Template
- [ ] File the two documents delivered today (Technical Reference, Bibliography)
- [ ] Create: Kelly Identity note, Effective Sample Size note, Ticker Anatomy note, Brier Decomposition stub
- [ ] Add 6 Decision Log entries
- [ ] Create Glossary note, seed with today's ~24 terms
- [ ] Create Open Questions note, seed with 7 questions
- [ ] Update Master Roadmap with gated milestones 1b–3, K2–K3
- [ ] Add the 6 required readings as checkboxes in Learning Roadmap
