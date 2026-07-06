# Proper Scoring Rules & Probability Calibration

**Vault location:** `01 Research/Probability`
**Cross-links:** [[Edge Detection]] · [[Expected Value]] · [[Prediction Markets]] · [[Bayesian Statistics]] · [[Experiment Log]]
**Status:** Foundational — prerequisite for all modeling milestones
**Created:** 2026-07-04

---

## 1. Why this note exists

The project defines success as "measurable, testable, continuously improving probability estimates." This note defines *measurable*. Every model, backtest, and edge claim in this project will be graded by the concepts here. The single most likely failure mode of the whole project is not a broken model — it is **believing an edge exists when it doesn't**, and scoring rules are the primary defense.

Core principle to internalize before anything else:

> **A single outcome can never validate or refute a probability.** "I said 80% and it happened" proves nothing; 20% events happen one time in five. Probabilities are only testable in aggregate, over many resolved forecasts, with a proper scoring rule.

---

## 2. What is being scored

A **probabilistic forecast** for a binary event is a number p ∈ [0,1]. After resolution, the outcome o is 1 (happened) or 0 (didn't).

Two things in this project emit such forecasts:

1. **Our future models** — explicit probability estimates.
2. **The market itself** — a Kalshi bracket trading at $0.34 is a 34% probability claim. Market prices are forecasts and can be scored identically. *(Nuance: strictly, the bid/ask midpoint is the cleaner probability proxy; a last-trade price can be stale in thin markets — our own 1a test showed brackets with live quotes and zero trades.)*

This symmetry is the foundation of edge detection: **edge = our forecasts score better than the market's forecasts on the same events.**

---

## 3. The two virtues: calibration and sharpness

**Calibration (reliability).** Among all events assigned probability ~X%, roughly X% occur. Calibrated forecasters' numbers mean what they say.

**Sharpness (resolution).** How far forecasts deviate from the base rate. In a city with a 60% summer base rate of exceeding some threshold, always saying "60%" is perfectly calibrated and worthless. Skill = making confident calls (5%, 95%) that remain calibrated.

**The governing principle (Gneiting & Raftery's formulation, standard across forecast verification): maximize sharpness, subject to calibration.**

Failure modes in this vocabulary:
- **Overconfidence** = sharp but miscalibrated (says 95%, delivers 70%). The dangerous one — it looks skilled.
- **Underconfidence / base-rate hugging** = calibrated but not sharp. Safe, useless, no edge possible.

---

## 4. Proper scoring rules

A scoring rule is **proper** if honest reporting of your true belief optimizes your expected score, and **strictly proper** if honesty is the *unique* optimum. Improper rules pay you to lie — grade models with one and you will select for dishonest probabilities.

### 4.1 The canonical trap (worked example)

Score = |p − o| (mean absolute error). Suppose your true belief is q = 0.7. Expected penalty for reporting p:
E = q·(1−p) + (1−q)·p = q + p(1−2q).
With q = 0.7 this decreases in p, so the optimal report is **p = 1.0**, not 0.7. MAE is improper: it rewards exaggeration. "Percent correct" (hit rate) fails the same way — it ignores probability magnitudes and incentivizes 0/1 reporting.

### 4.2 Brier score (strictly proper)

BS = (1/N) · Σ (pᵢ − oᵢ)²

- Range 0 (perfect) to 1 (perfectly wrong). Lower is better.
- **Benchmark to memorize:** always forecasting 0.5 scores exactly **0.25**.
- Squared error → forgiving of a single confident miss, sensitive to systematic error.

**Murphy decomposition** (over binned forecasts):

BS = **Reliability** − **Resolution** + **Uncertainty**

| Term | Measures | Direction | Controlled by forecaster? |
|---|---|---|---|
| Reliability | Calibration error (gap between stated probs and observed frequencies) | Lower better | Yes |
| Resolution | Sharpness that pays off (how much outcome frequencies differ across forecast bins) | Higher better | Yes |
| Uncertainty | Base-rate variance, ō(1−ō) | Fixed | No |

The decomposition turns one opaque number into a diagnosis: *is the model miscalibrated, or just not sharp?* — which dictate opposite fixes (recalibrate vs. find better features).

### 4.3 Log score (strictly proper)

S = −ln(p) if o = 1; −ln(1−p) if o = 0. Lower is better.

Personality difference vs Brier: **infinite penalty for certain-and-wrong.** Assign 0% to something that happens and the log score is unbounded. Brier tolerates rare catastrophic misses; log score treats ruling things out as sacred. Practical consequence: models should never emit exactly 0 or 1.

**Project standard: compute both.** Divergence between them is itself diagnostic (usually indicates tail-probability behavior worth investigating).

### 4.4 Ranked Probability Score (for full bracket distributions)

Kalshi temperature events are ~6 **ordered** brackets. Scoring each bracket as an isolated binary throws away order information (missing by one bracket ≠ missing by four). The RPS fixes this: it is the mean squared difference between the forecast's *cumulative* distribution and the outcome's cumulative distribution across brackets. Proper, and it rewards being *close* in temperature space. Use per-bracket Brier for market-vs-model comparisons on individual contracts; use RPS to grade a model's whole temperature distribution.

---

## 5. Skill scores: all scores are relative

An absolute Brier number is nearly meaningless — predictability differs by city, season, and horizon. Meaning comes from comparison:

**BSS = 1 − (BS_forecast / BS_reference)**

- BSS > 0: better than reference. BSS = 0: no skill vs reference. BSS < 0: worse.

**This project's reference ladder:**
1. **Climatology** (historical base rates for that city/date) — the floor. Any model must beat it or it has learned nothing.
2. **The raw NWS forecast** converted to probabilities — beating this means adding value beyond the public forecast.
3. **The market price** — the only reference that matters for edge. A validated positive BSS against market prices *is* the statistical definition of edge this project seeks.

Important asymmetry (link: [[Expected Value]]): beating the market's Brier score is **necessary but not sufficient** for profitable trading — fees, spreads, and the specific prices available at execution time all take a cut. Score skill first; EV analysis is a separate later gate.

---

## 6. Calibration curves (reliability diagrams)

Construction: bin all forecasts (e.g., 0–10%, 10–20%, …), plot bin-average forecast (x) vs observed frequency (y). Perfect calibration = diagonal. Curve below diagonal = overconfidence at that range; above = underconfidence.

Read jointly with a **forecast histogram**: a beautiful diagonal with all mass piled at 50–60% is calibrated-but-not-sharp. The curve shows honesty; the histogram shows courage.

---

## 7. Sample size: the discipline section

### 7.1 Binomial noise is brutal

Observed frequency in a bin has standard error ≈ √(p(1−p)/n). At p = 0.7:
- n = 10 → SE ≈ 0.145 (a "70% bin" showing 50% or 90% is unremarkable)
- n = 50 → SE ≈ 0.065
- n = 200 → SE ≈ 0.032

Consequence: calibration curves need **hundreds of forecasts** before their shape is signal. Early curves are entertainment, not evidence.

### 7.2 The correlated-brackets trap (project-specific, critical)

Naive count: 5 cities × ~6 brackets × 30 days = 900 forecasts/month. **False.**
- The ~6 brackets of one city-day resolve from **one** temperature draw — one observation, not six.
- City-days are not fully independent either: regional weather systems (a heat dome over the Southwest) move multiple cities together on the same day.

Honest effective sample size: ≤ ~150 city-days/month, discounted for cross-city correlation. Rules for all future analysis:
1. The **city-day is the base unit** of evidence.
2. Uncertainty estimates must respect the dependence structure (block/cluster bootstrap by date, or explicit correlation modeling).
3. Any analysis quoting n in the hundreds after one month is double-counting and gets rejected.

### 7.3 Comparing two forecasters properly

To claim "model beats market," compare **paired score differences on the same events** (dᵢ = market score − model score), then test whether mean(d) > 0 with dependence-aware uncertainty (bootstrap resampling by date is the pragmatic default). Never compare two forecasters' scores computed on *different* event sets — question difficulty differences dominate.

---

## 8. Misconceptions and traps (checklist)

- ❌ "It happened, so my 85% was right." — Single outcomes validate nothing (§1).
- ❌ "90% hit rate = great forecaster." — Hit rate is improper; also meaningless without base rate (90% on 95%-base-rate events is *negative* skill).
- ❌ "Lower Brier in Miami than the Phoenix model's Brier → Miami model is better." — Never compare across event sets; use skill scores vs common references.
- ❌ "The calibration curve after 2 weeks shows we're overconfident at 80%." — Check bin counts; probably noise (§7.1).
- ❌ "900 data points this month." — City-days, not bracket-contracts (§7.2).
- ❌ Grading with any improper metric, ever, even informally in conversation — it quietly retrains intuition toward exaggeration.
- ⚠️ Selection effects: scoring only markets we chose to look at ≠ scoring all markets. Pre-register which markets/dates an experiment covers before seeing outcomes.

---

## 9. How this gets used (forward pointers, no commitments to build yet)

**Proposed Experiment #1 (model-free): Score the market itself.** Once the pipeline has accumulated data: Brier score and calibration curve of Kalshi closing prices (bid/ask midpoints) against settlements. Questions it answers: How calibrated are these markets? Is there a favorite-longshot bias (documented in many betting markets historically; whether it exists *here* is an open empirical question)? How efficient is the competition? This requires zero modeling and directly informs whether/where edge is plausible.

**Model acceptance criteria (future milestones, to be formalized):** any model must show (1) reliability term not materially worse than the market's, (2) positive BSS vs climatology with dependence-aware confidence intervals, before it earns comparison against market prices.

**What new information would most change this note:** verification of how thin-market quote staleness should be handled when scoring "the market" (midpoint vs last trade vs time-weighted) — flagged as an open methodological question to resolve before Experiment #1 runs.

---

## 10. Summary card

- Probabilities are only testable in aggregate → proper scoring rules.
- Proper = honesty is optimal. Brier (squared error, decomposable) + Log (tail-sensitive) — compute both. RPS for full bracket distributions.
- Maximize sharpness **subject to** calibration.
- Scores are only meaningful vs references: climatology → NWS → **market**. Positive skill vs market = the precise meaning of "edge."
- Evidence unit = **city-day**; respect correlation; distrust early calibration curves.
- Beating the market's score is necessary, not sufficient, for profit ([[Expected Value]]).
