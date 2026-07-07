---
title: '"Prediction Market Edge Detection — Technical Reference"'
---
---

---

## title: "Prediction Market Edge Detection — Technical Reference" aliases: ["Edge Detection", "Mispricing Detection"] vault_location: "01 Research/Prediction Markets" level: "Quantitative researcher reference" status: "Audited draft (v2) — E4, awaiting architect ratification per Invariant 3; NOT canonical" supersedes: "Edge Detection v1 (2026-07-04)" audited: 2026-07-04 track: "Full" created: 2026-07-04 review: 2027-01-04 tags: [prediction-markets, edge-detection, statistical-arbitrage, calibration, microstructure]

# Prediction Market Edge Detection — Technical Reference

**Cross-links:** [[Prediction Markets]] · [[Market Microstructure]] · [[Statistical Arbitrage]] · [[Bayesian Forecasting]] · [[Machine Learning]] · [[Calibration]] · [[Risk Management]] · [[Automated Trading Systems]] · [[Proper Scoring Rules and Calibration - Technical Reference]] · [[Log Score and Kelly Identity]] · [[Expected Value]] · [[Kelly Criterion]] · [[Effective Sample Size]] · [[Glossary]] · [[Open Questions]] · [[Market Normalization Spec]] · [[Research Lab Master Specification]]

> **Provenance note (Invariant 3).** This document is an AI-drafted synthesis. Every empirical claim in it is **E4 (testimony)** until the human opens the cited primary source and confirms it. Citations are given so they _can_ be checked, not because they have been. Effect sizes quoted from literature are reported as the source stated them; none has been reproduced against primary data in this project. Do not let any conclusion here become load-bearing before it is graded up. The document's job is to structure the search, name the methods, and flag the traps — not to license trades.

> **Scope discipline.** This is a reference document, not an ADR and not a redesign. It does not modify the [[Research Methodology v2 Canonical|methodology]], the city-day unit, the [[reference ladder]], or any settled decision. Where it proposes machinery (scoring functions, thresholds, architecture), those are _candidate_ designs to be ratified through the normal ADR process before implementation, not adopted by being written here.

> **Audit note (v2, 2026-07-04).** This version supersedes the v1 draft after a self-audit against the governing corpus. Material corrections: (1) **terminology** — "edge" is now used only in the [[Glossary]] sense (validated population-level skill with date-clustered inference); the raw quantity $P_f - P_m$ is renamed **disagreement** $\Delta$ throughout, so the document no longer calls a single price difference "edge"; (2) **settlement source corrected** — the v1 draft wrongly flagged DCR-vs-max-hourly as unresolved; it is resolved to the NWS Daily Climate Report per [[Kalshi Ticker Anatomy and Market Structure]] (§11); (3) **question register** — v1 invented a parallel "Open Question 1–8" list; §13 now maps to the canonical [[Open Questions]] Q1–Q7 and marks only genuinely new items as candidates for architect entry. No new research was added; scope unchanged.

---

## 1. Executive Summary

**What edge detection is, in this project's terms.** _Edge_ has a fixed definition in the [[Glossary]]: **statistically significant positive skill versus the market-price reference, with date-clustered inference** — not a raw price difference, not backtested P&L. The raw quantity $\Delta = P_f - P_m$ (the model–market _disagreement_) is the raw material, not the edge. It is a point estimate of a difference between two noisy estimates, one of which ($P_m$) is the aggregate belief of everyone else in the market, including people who may know more than the model. Edge detection is the discipline of deciding when a _population_ of such disagreements constitutes real, significant skill against the market rung of the [[reference ladder]] — rather than an artifact of model error, market noise, or the detector's own multiple-testing. Throughout this document, $\Delta = P_f - P_m$ is called **disagreement**; the word **edge** is reserved for the Glossary sense (validated population-level skill).

**The strongest known methods, in order of evidential support.**

1. **Calibration-based edge** — comparing model and market as forecasters via proper scores over a population of resolved events. This is the only method that ties directly to P&L through the log-score/Kelly identity already established in [[Log Score and Kelly Identity]], and the only one this project can validate with its own instrument. Highest confidence, because it is _measurement_, not prediction.
2. **Cross-market consistency (arbitrage) detection** — exploiting that mutually exclusive and exhaustive contracts must have probabilities summing to $1$ (plus fees), and that logically related contracts must obey coherence constraints. Highest _certainty per opportunity_ (some are near-deterministic), lowest _frequency_ and often smallest size after fees. Strong theoretical basis, thin empirical margins on modern venues.
3. **Behavioral/structural biases** — favorite–longshot bias, over/underreaction, partisan and narrative bias. Robust in older betting and political markets; **unknown and unproven in Kalshi weather markets**, which is exactly the project's [[Open Questions]] Q1.
4. **Microstructure and time-based signals** — stale prices, order-flow imbalance, resolution-proximity convergence. Well-documented in equities; sparsely studied and likely weak-and-fleeting in low-volume weather brackets.

**Evidence quality.** The academic literature on prediction-market efficiency and forecasting is genuinely strong (peer-reviewed, replicated across venues and decades). The literature on _systematically extracting profit after costs from modern, relatively efficient venues_ is much weaker, thinner, and contaminated by survivorship and publication bias. Treat "markets are well-calibrated in aggregate" as well-supported; treat any specific "here is a persistent, profitable inefficiency" as guilty until proven, because a published exploitable edge is a self-defeating artifact.

**Expected practical value for this project.** Modest and conditional, and — critically — _not the point yet_. Per the project charter, profitability is gated behind V3; V1 is measurement, V2 is forecasting. The correct use of edge detection now is as the **measurement instrument's verdict function**: does an independently modeled probability score better than the market's on resolved city-days, at the population level, with dependence-robust inference? Everything downstream (ranking, execution, sizing) is premature until that population-level question is answered yes with a pre-registered, out-of-sample test.

---

## 2. Mathematical Definition of Edge Detection

### 2.1 The primitives

For a binary contract resolving $y \in {0,1}$, paying $1 on YES:

- **Market probability** $P_m$: the price (in dollars, $\in (0,1)$) is the market's probability report. Use the **midpoint** of bid and ask as the point estimate; the spread is a first-order cost and uncertainty term, never ignored.
- **Model probability** $P_f$: the project's independently produced estimate (NWS-derived model rung, per the reference ladder).
- **Disagreement**: $\Delta = P_f - P_m$ (the raw material; _not_ "edge" in the Glossary sense).
- **Expected value of a YES purchase** at price $c = P_m$ (ignoring fees for the moment): $$\text{EV}_{\text{YES}} = P_f \cdot (1 - c) - (1 - P_f)\cdot c = P_f - c = P_f - P_m = \Delta.$$

So under this idealization, **expected value per contract equals the disagreement** — _if $P_f$ is correct_. That conditional is the whole problem: the identity makes a difference of two noisy numbers look like money, but $P_f$ is an estimate, and a disagreement is only _edge_ once a population of them demonstrates significant skill against the market (Glossary definition; §7). This is why the project never treats a single $\Delta$ as actionable.

### 2.2 Uncertainty adjustment — the part that actually matters

$P_f$ is an estimate with a standard error $\sigma_f$; $P_m$ is a moving target with its own dispersion $\sigma_m$ (spread, depth, time-variation). The quantity to test is not $\Delta$ itself but a **standardized disagreement**: $$z = \frac{P_f - P_m}{\sqrt{\sigma_f^2 + \sigma_m^2}}.$$ A 3-point disagreement with $\sqrt{\sigma_f^2+\sigma_m^2} = 5$ points has $|z| \approx 0.6$ — indistinguishable from noise. The Master Spec R7 example ("a detected 3% probability advantage may be meaningless if uncertainty is ±5%") is precisely this.

**Where does $\sigma_f$ come from?** This is the hard, honest part. It is _not_ the spread of an ensemble alone (that captures sampling variance, not model misspecification). Credible $\sigma_f$ must include: (i) the model's demonstrated out-of-sample calibration error on resolved city-days, (ii) parameter/structural uncertainty, and (iii) the base-rate reminder that on any single event the probability cannot be validated. A model that reports $\sigma_f$ from its ensemble alone will systematically _understate_ its uncertainty and _overstate_ its edge. This is the single most common way probability-disagreement strategies quietly lose money.

### 2.3 Confidence intervals and the population reminder

A disagreement on one city-day is not testable, and edge (Glossary sense) is undefined at $n=1$. **Probabilities validate only at the population level** — the load-bearing idea of the whole architecture ([[Research Lab Master Specification]] §2, "measurement precedes edge"). So edge as a statistical object is a property of a _distribution of forecasts vs prices_, evaluated by a proper score over many resolved events, with **date-clustered inference** (the Glossary definition's explicit requirement) via the [[Effective Sample Size|effective sample size]]: city-days are correlated within a day across cities and within a city across nearby days, an empirical magnitude tracked as [[Open Questions]] Q3; naive $N$ overstates precision.

### 2.4 Transaction costs and risk-adjusted net disagreement

The candidate tradeable object is the **net, risk-adjusted disagreement**: $$\Delta_{\text{net}} = \underbrace{(P_f - P_m)}_{\text{raw}} ;-; \underbrace{\tfrac{1}{2},\text{spread}}_{\text{execution}} ;-; \underbrace{\text{fee}(P_m)}_{\text{venue}} ;-; \underbrace{\lambda,\sigma_f}_{\text{uncertainty penalty}}.$$

Kalshi charges a price-dependent trading fee (a function of $P_m$ and contract count), so the fee term is not a constant and must be computed at the actual price, not approximated. The fee and spread inputs come from the market-rung record produced by [[Market Normalization Spec]] (A4), which keeps $P_m$ fee-free and records the cost band separately — cost enters _here_, not in $P_m$. Only when $\Delta_{\text{net}} > 0$ _and_ the standardized disagreement clears a pre-registered, multiplicity-corrected threshold, _and_ a population of such cases shows significant skill (§7), is there **edge**. Sizing, if it ever happens, is a **fractional Kelly** question (see [[Kelly Criterion]], gated until edge is validated per the Glossary) — a V3 concern, out of scope here beyond noting that full Kelly on a mis-estimated disagreement is a fast way to ruin.

---

## 3. Taxonomy of Edge Detection Methods

Six categories. For each: theoretical basis, empirical evidence (graded E4 pending verification), mathematical approach, required data, expected effectiveness _for this project specifically_, and failure modes. The recurring theme: methods with the strongest general-market evidence are often the weakest fit for low-volume weather brackets, and vice versa.

### Category 1 — Probability Disagreement Detection

**Theoretical basis.** If an independent model is better calibrated than the market on a class of events, its disagreements with price carry information. This is the project's core thesis and the _only_ category whose validation is native to the instrument being built.

**Mathematical approach.** Compute $P_f$ (Bayesian posterior, forecasting model, ensemble, or expert aggregate) and standardized disagreement $z$ (§2.2). But the decision rule is not "trade when $z$ large today" — it is "over resolved history, does $P_f$ log-score better than $P_m$?" via the identity in [[Log Score and Kelly Identity]]: expected log-growth of a Kelly bettor equals expected log-score difference between forecast and price. **Edge detection here _is_ score comparison.**

**Sub-methods and required data.**

- _Bayesian models_ — posterior over the outcome given priors + evidence; required data: prior climatology, likelihood from NWS forecasts. Naturally produces $\sigma_f$.
- _Forecasting models_ — NWS-derived model rung; required data: forecast issuance history (non-backfillable — highest accrual urgency).
- _Ensemble forecasts_ — spread gives a _floor_ on $\sigma_f$, not the whole of it.
- _Expert aggregation_ — extremized averaging (log-odds pooling) beats naive averaging in the forecasting literature (Satopää et al.); relevant if multiple forecast sources are combined.
- _ML predictions_ — see §7; calibration, not accuracy, is the binding constraint.

**How large must disagreement be?** Not a fixed number. It must clear (a) the standardized-edge threshold $|z| > z^_$ where $z^_$ is set by the multiple-testing correction over the number of markets scanned (§9), and (b) $\text{Edge}_{\text{net}} > 0$ after costs. A useful mental anchor: with realistic $\sigma_f$ on weather brackets, raw edges below ~5–8 points are usually noise or cost.

**Expected effectiveness.** _This is the whole project._ Confidence that it is the right method: high. Confidence that it will be _profitable_: unknown by design — that is the V3 gate, not an assumption.

**Failure modes.** Overstated $\sigma_f$ → phantom edges; the market knowing something the model doesn't (adverse selection — the market's disagreement may be the informed side); look-ahead leakage if forecast timestamps are not honored (dual-timestamp architecture exists to prevent exactly this); treating the model as ground truth instead of testing it.

### Category 2 — Statistical Mispricing Detection

**Theoretical basis.** Prices that deviate from their own historical/model-implied behavior may be mispriced. This is anomaly detection on the price series, _not_ on the outcome.

**Mathematical approach.** z-score of current price vs a rolling reference; deviation from historical probability ranges; mean-reversion models (Ornstein–Uhlenbeck on the price or its logit); regression-residual analysis (price on fundamentals, flag large residuals); isolation forests / other anomaly detectors on a feature vector.

**Required data.** Time series of prices per market, plus a reference model to deviate _from_. Without an independent reference, "deviation from historical range" just detects volatility, not mispricing.

**Distinguishing true mispricing from normal volatility.** The core difficulty. A large price move is only an edge if the _fundamentals didn't move_. Weather brackets legitimately reprice hard when a new forecast run arrives — that is information, not inefficiency. The discipline: condition on forecast issuance. A price move _between_ forecast updates, with no news, is a candidate anomaly; a price move _coincident with_ a new NWS run is expected repricing. Confusing the two is the dominant failure mode of this whole category.

**Expected effectiveness.** Low-to-moderate for this project. Weather-bracket price series are short, thin, and jump on scheduled forecast releases — poor terrain for mean-reversion and z-score methods designed for liquid, continuously-informed series. Real risk of fitting noise.

**Failure modes.** Mistaking scheduled information arrival for inefficiency; overfitting anomaly detectors on short series; mean-reversion strategies that are actually short-volatility bets that blow up on the one real move.

### Category 3 — Market Microstructure Edge Detection

**Theoretical basis.** Order books and trade flow carry information about price formation and short-lived dislocations. Deep, well-replicated literature — in _equities and futures_.

**Signal families.**

- _Liquidity:_ bid/ask spread, market depth, order imbalance $\frac{V_{\text{bid}} - V_{\text{ask}}}{V_{\text{bid}} + V_{\text{ask}}}$, volume concentration, liquidity shocks.
- _Price formation:_ stale prices (no update despite new information), delayed reaction to forecast releases, inefficient updates, temporary dislocations.
- _Order flow:_ aggressive buying/selling (market-order imbalance), informed-trading indicators (e.g., VPIN-style flow toxicity), volume–price relationships.

**Required data.** Full order book with timestamps, trade prints, and — for this project — bid/ask capture in the collector (flagged as an unresolved load-bearing claim: it is not confirmed the current collectors capture bid/ask and full issuance history).

**Evidence.** Strong in financial markets (Easley, O'Hara, Kyle-model lineage). In prediction markets specifically: much thinner, and the venues differ (Kalshi CLOB vs Polymarket AMM/order-book hybrids vs PredictIt). Microstructure edges that exist in liquid markets may simply not be present, or not be capturable after fees, in a weather bracket trading a few hundred contracts a day.

**Expected effectiveness.** Low for this project's _stated_ goal (measuring model-vs-market divergence), potentially relevant only much later for _execution_ (minimizing slippage when entering a position you already decided to take). Microstructure is more useful here as an execution-cost model than as an alpha source.

**Failure modes.** Importing equity-microstructure intuitions into a market too thin to support them; treating stale prices as edge when they're just illiquidity you can't trade against without moving the price; latency arms races the project cannot and should not enter.

### Category 4 — Cross-Market Arbitrage Detection

**Theoretical basis.** Logic, not prediction. Mutually exclusive and exhaustive brackets of one event must have prices summing to $1$ (plus fees). Logically related contracts must obey coherence: if A ⊆ B, then $P(A) \le P(B)$. Violations are _near-certain_ mispricings.

**Mathematical approach.**

- _Sum-to-one check_ on an event's bracket ladder: flag $\left|\sum_i P_{m,i} - 1\right| > \text{fee band}$.
- _Constraint optimization:_ find the cheapest portfolio of contracts that guarantees a payout regardless of outcome (a linear program over the outcome simplex).
- _Graph-based detection:_ nodes = contracts, edges = logical relations; negative-cost cycles = arbitrage (Bellman–Ford analogue).
- _Probability consistency checking:_ enforce Fréchet/coherence bounds across related markets.

**Worked shape of the "70% / 40%" example.** If Market A ("high ≥ 100°") implies 70% and Market B ("high ≥ 102°") implies 40%, coherence requires $P(\ge 102) \le P(\ge 100)$, which _holds_ here (40 ≤ 70) — so no violation. A violation would be B > A, or a bracket ladder summing to, say, 1.12 net of fees. The detector's job is to encode these relations and scan for breaches.

**Required data.** Simultaneous prices across all related contracts, same timestamp. Timestamp alignment is essential — apparent arbitrage across stale quotes is not arbitrage.

**Expected effectiveness.** Highest certainty per opportunity, but modern venues are watched by bots; durable, sizeable, fee-surviving arbitrage is rare and fleeting. For this project, the _coherence check is most valuable as a data-quality and sanity instrument_ — a bracket ladder that doesn't sum to ~1 signals a collection or normalization bug (relevant to the Market Normalization Spec, A4) at least as often as a real edge.

**Failure modes.** Stale-quote pseudo-arbitrage; ignoring fees that eat the whole margin; execution risk (both legs must fill); mistaking a normalization bug for alpha.

### Category 5 — Time-Based Edge Detection

**Theoretical basis.** Information arrives over a market's life; efficiency may vary with time-to-resolution.

**Analysis targets.** Early-market inefficiency (thin, few informed traders), late-market convergence (price → outcome as uncertainty resolves), information-arrival timing (scheduled NWS runs), resolution proximity, volatility cycles.

**Questions and what the literature suggests.** Markets are often _most inefficient early_ (little volume, wide spreads) and converge as resolution nears; edge tends to _decay_ as information is incorporated. For weather specifically, the dominant clock is the **forecast-release schedule**: predictability is highest right after a fresh run (model has maximal information) and the market's own lag in incorporating a new run — if any — is the most plausible time-based edge. Whether such a lag exists on Kalshi is empirical and unknown.

**Required data.** Event-time vs ingestion-time on every price and forecast (the dual-timestamp architecture is what makes this analyzable without look-ahead leakage).

**Expected effectiveness.** Moderate as a _research question_, low as a near-term alpha source. The clean version — "does the market fully price a new NWS run within X minutes?" — is a legitimate, pre-registerable study. It is also easy to fool yourself on with leakage.

**Failure modes.** Look-ahead leakage (the cardinal sin — using a forecast timestamped after the price you're evaluating); confusing convergence (mechanical) with edge; overfitting time-of-day effects on a short sample.

### Category 6 — Behavioral Mispricing Detection

**Theoretical basis.** Human traders introduce systematic, persistent biases.

**Documented biases and effect sizes (all E4, from general markets — NOT weather).**

- _Favorite–longshot bias:_ longshots systematically overpriced (Thaler & Ziemba 1988; mechanism debated, risk-love vs misperception, Snowberg & Wolfers 2010). This is the project's [[Open Questions]] **Q1** for weather brackets — presence is unproven here.
- _Over/underreaction:_ markets over- or under-adjust to news; documented in political and sports markets.
- _Narrative / availability bias:_ salient stories move prices beyond their informational content.
- _Political / partisan bias:_ documented in election markets (e.g., PredictIt studies).
- _Herd behavior:_ momentum and cascades in thin markets.

**Quantification.** Effect sizes in the low-single-digit to low-double-digit percentage-point range appear in the betting literature, but persistence and post-fee profitability are the open questions, and effects shrink as markets professionalize.

**Expected effectiveness.** Unknown for weather. Weather brackets have _less_ obvious narrative/partisan content than elections, but favorite–longshot-type miscalibration is plausible and testable. This is the natural first empirical study and is already [[Open Questions]] Q1 — do not pre-suppose the answer.

**Failure modes.** Assuming biases documented in horse racing or elections transfer to weather; multiple-testing across many candidate biases; effects that existed historically but have been arbitraged away.

---

## 4. Feature Engineering for Edge Detection Models

Predictive value is **hypothesized**, not measured; "Confidence" is confidence that the feature is _worth testing_, not that it works. Data sources map to the project's actual pipeline.

|Feature|Description|Hyp. Predictive Value|Data Source|Confidence|
|---|---|---|---|---|
|**Market — current price (midpoint)**|Bid/ask midpoint = $P_m$|Baseline (it _is_ the target)|Kalshi API|High|
|Market — probability movement|Δ price over window|Low–Med (mostly noise/info)|Kalshi API|Med|
|Market — realized volatility|Std of price over window|Low–Med|Kalshi API|Med|
|Market — bid/ask spread|Ask − bid|Med (cost + uncertainty proxy)|Kalshi API (must capture)|High|
|Market — volume|Contracts traded|Med (liquidity gate)|Kalshi API|Med|
|Market — liquidity/depth|Size at top levels|Med (execution)|Kalshi order book|Med|
|Market — order imbalance|(bid−ask vol)/(sum)|Low–Med|Kalshi order book|Low|
|**Temporal — time to resolution**|Hours to settlement|Med (convergence, decay)|Derived|Med|
|Temporal — price velocity/momentum|dP/dt|Low|Kalshi API|Low|
|Temporal — market age|Time since open|Low–Med (early inefficiency)|Derived|Low|
|**External — forecast issuance recency**|Time since last NWS run|**Med–High** (the weather clock)|NWS (non-backfillable)|Med|
|External — polling / econ / sports|Domain signals|N/A for weather|—|—|
|External — weather model spread|Ensemble dispersion|**Med–High** ($\sigma_f$ floor)|NOAA/NWS ensembles|Med|
|**Model — model−market disagreement**|$P_f - P_m$|**High** (the core signal)|Model + Kalshi|High|
|Model — standardized disagreement $z$|Disagreement / combined SE|**High**|Derived|High|
|Model — forecast confidence|$1/\sigma_f$|High (gates the above)|Model|Med|
|Model — ensemble variance|Ensemble spread|Med ($\sigma_f$ input)|NOAA ensembles|Med|
|Model — historical calibration error|OOS reliability of $P_f$|**High** (realistic $\sigma_f$)|Prediction ledger|High|

The load-bearing rows are the **model-based** ones. Market and temporal features are mostly execution-cost and gating inputs, not alpha. The single most important feature is _historical calibration error_, because it is what converts an ensemble spread into an honest $\sigma_f$.

---

## 5. Machine Learning Approaches to Edge Detection

### 5.1 Supervised learning

**Models.** Logistic regression (interpretable baseline; strong prior in forecasting because it's naturally probabilistic and easy to calibrate), random forest, gradient boosting / XGBoost (strong tabular performers), neural networks (rarely worth it on small tabular data with few hundred city-days/month).

**Applications.** Predicting price movement (hard, low signal), classifying "mispriced" markets (requires a mispricing label, which is circular — you need resolved outcomes and a proper score to define the label), probability calibration (the genuinely useful one).

**The binding constraint.** For a betting application, **calibration dominates accuracy**. A model with high AUC but poor calibration will size bets wrong and lose money even when directionally right (§6). Prefer models that output calibrated probabilities, or post-calibrate them (§6). With ~150 city-days/month, sample size is small; heavy models overfit; regularized logistic / gradient boosting with strict cross-validation is the sane envelope.

### 5.2 Unsupervised learning

Clustering, anomaly detection, autoencoders, isolation forests — purpose: finding unusual market _states_ (a bracket ladder that doesn't cohere, a price far from model). Genuinely useful as a **data-quality and regime-flagging tool**, weak as a standalone alpha source (an anomaly is not an edge unless you know the fundamental didn't move — the Category 2 problem).

### 5.3 Reinforcement learning

Automated agents, reward = risk-adjusted P&L, exploration/exploitation. **Not recommended for this project in the foreseeable horizon.** RL needs enormous samples, is exquisitely prone to reward hacking and backtest overfitting, and offers no interpretability for a governance framework that treats every load-bearing claim as needing human verification. A city-day-per-day data rate is fundamentally incompatible with sample-hungry RL. Named here for completeness and to record the decision to defer it.

---

## 6. Calibration Research

Calibration is the hinge between "good model" and "makes money." Fully developed in [[Proper Scoring Rules and Calibration - Technical Reference]]; summarized here for the edge-detection context.

**Why an accurate-but-miscalibrated model fails financially.** Bet sizing (Kelly, [[Kelly Criterion]]) is a function of the _probability_, not the direction. If a model says 90% when the truth is 70%, it is often "right" (the event usually happens) yet systematically overbets, and the log-growth identity turns that overconfidence into negative expected growth. **Miscalibration is not a cosmetic flaw; it is a direct, compounding drain on capital.** The log-score/Kelly identity ([[Log Score and Kelly Identity]]) makes this exact: edge = log-score advantage, and a miscalibrated forecaster's log-score advantage over the market can be negative even when its hit-rate is high.

**Calibration methods.** Isotonic regression (non-parametric, flexible, data-hungry — risky on small samples), Platt scaling (logistic recalibration; robust on small data — usually the right default here), Bayesian calibration (priors regularize small-sample estimates), ensemble calibration.

**Metrics.** Brier score (proper), log loss (proper; the P&L-relevant one), expected calibration error (diagnostic, _improper_ — never optimize it directly, per the Glossary caution on skill scores and ECE).

**Practical stance for this project.** Validate market calibration first ([[Open Questions]] Q1), then model calibration, using proper scores over resolved city-days with effective-sample-size-corrected inference. Post-calibrate the model (Platt as default) before any edge claim. An un-calibrated model has no business generating an edge number.

---

## 7. Statistical Validation Framework

This is where real edges are separated from artifacts. The methodology's Invariants (pre-registration, verify-before-grade) are the backbone; the statistics below are the muscle.

**Required tests.**

- _Out-of-sample testing_ — non-negotiable. In-sample edge is not evidence.
- _Walk-forward validation_ — expanding/rolling window respecting time order; the honest simulation of live use.
- _Bootstrap analysis_ — CIs on score differences; **block bootstrap** to respect city-day correlation ([[Effective Sample Size]]).
- _Monte Carlo_ — null distribution of "edge" under no-skill to size false-positive rates.
- _Hypothesis testing_ — Diebold–Mariano on paired score differentials (dependence-robust variance) is the standard tool and is already in the Glossary.
- _Bayesian posterior evaluation_ — posterior over edge/skill, honest about small samples.

**False-edge prevention (the seven deadly sins).**

1. _Overfitting_ — too many parameters on too few city-days.
2. _Multiple testing_ — scanning many markets/biases inflates false positives; correct with Bonferroni/BH or a pre-registered single hypothesis (§9).
3. _Data snooping_ — reusing the same data to both form and test a hypothesis.
4. _Selection bias_ — reporting the strategy that worked out of many tried.
5. _Look-ahead bias_ — using information not available at decision time; the dual-timestamp architecture exists to prevent this and is the highest-consequence bug class in the whole system.
6. _Survivorship bias_ — evaluating only markets that resolved/remained.
7. _Data-snooping via reuse of the test set_ — the OOS set is spent the first time you look at it; walk-forward discipline protects it.

**The multiple-testing point deserves emphasis.** A scanner evaluating hundreds of markets daily will, under the null, "find edge" constantly. Any threshold must be set with the number of simultaneous tests in mind, or the system is a false-positive generator with a dashboard. Pre-registration (Invariant 1) is the cleanest defense: one falsifiable hypothesis, registration date bounding the OOS window.

---

## 8. Edge Threshold Determination

**How large before trading?** The threshold is a _net, standardized, multiplicity-corrected_ quantity, not a raw percentage.

A candidate opportunity qualifies only if **all** hold:

1. $\text{Edge}_{\text{net}} = (P_f - P_m) - \tfrac{1}{2}\text{spread} - \text{fee}(P_m) - \lambda\sigma_f > 0$.
2. Standardized edge $|z| = |P_f - P_m| / \sqrt{\sigma_f^2 + \sigma_m^2} > z^_$, with $z^_$ set from the multiple-testing correction over the scan size.
3. Liquidity sufficient to enter/exit at ~midpoint without material impact.
4. The model's historical calibration on this class of city-days supports the $\sigma_f$ used.

The project's own example is the template: _a 3-point raw edge is meaningless when uncertainty is ±5 points and the spread costs 1 point._ The threshold's job is to make that arithmetic mandatory rather than optional.

---

## 9. Ranking and Scoring Edge Opportunities

The prompt's candidate form: $$\text{Score} = \text{ProbAdvantage} \times \text{Confidence} \times \text{Liquidity} \times \text{TimeFactor} - \text{RiskPenalty}.$$

This is reasonable as an intuition but multiplicative ad-hoc scores hide their assumptions. A principled alternative grounded in this project's existing machinery:

**Rank by expected log-growth net of costs.** For each qualifying opportunity, the [[Log Score and Kelly Identity]] gives an expected log-growth contribution as a function of $(P_f, P_m, \text{costs})$. Ranking by _expected fractional-Kelly log-growth after fees and after the uncertainty penalty_ is theoretically grounded (it is the quantity a growth-optimal bettor maximizes), naturally incorporates confidence (via $\sigma_f$ shrinking effective edge), liquidity (via realized execution cost), and time (via how the edge decays to resolution), and does not require inventing multiplicative weights.

The multiplicative score can serve as a fast pre-filter; the log-growth quantity should be the actual ranking key. Whichever is used, the ranking is downstream of validation — you rank _among opportunities that already passed §7 and §8_, never as a substitute for that gate.

---

## 10. Automated Trading Architecture

Research → components. This mirrors the project's V1→V2→V3 roadmap; only the first three exist or should exist near-term.

|Component|Purpose|Roadmap stage|Notes|
|---|---|---|---|
|**Market Scanner**|Continuously enumerate/collect all relevant markets (5 cities, bracket ladders)|V1|Append-only, dual-timestamp; capture bid/ask + issuance history|
|**Probability Engine**|Independent $P_f$ per city-day, with honest $\sigma_f$|V2|NWS-derived rung; ensemble → calibrated posterior|
|**Edge Detection Engine**|Compare $P_f$ vs $P_m$; compute net, standardized disagreement|V2|Implements §2, §8|
|**Opportunity Ranking Engine**|Sort qualifying edges by expected log-growth|V3|§9; downstream of validation|
|**Execution Engine**|Enter/exit minimizing slippage|V3|Microstructure as _cost model_, not alpha|
|**Learning System**|Track whether detected edges were real; feed calibration|V1→ongoing|The prediction ledger; this is the instrument's memory|

The **Learning System is the philosophical core**, not the Execution Engine. It is the prediction ledger that records every forecast and price and later scores them — the mechanism by which the project earns the right to claim an edge exists at all. Building execution before this exists is building a car before the odometer.

---

## 11. Real-World Evidence

**Kalshi** — CFTC-regulated US event exchange; CLOB microstructure; the project's venue. Weather markets settle against the **NWS Daily Climate Report (DCR)** for one named station per city, in local standard time (window shifts under DST), per [[Kalshi Ticker Anatomy and Market Structure]] (Milestone 1a finding). This defines the outcome $y$. The remaining open item is not _which report_ but _station verification_ per market (tracked in `config.yaml`, untrusted until flipped) and reconciliation against Kalshi's published settlement value (A6). Efficiency of weather brackets: largely unstudied; the project's contribution.

**Polymarket** — crypto-settled; large election volume; documented episodes of both sharp aggregation and idiosyncratic dislocation; different microstructure (AMM/order-book hybrid), so microstructure findings don't transfer cleanly to Kalshi.

**PredictIt** — capped positions and fees; well-studied partisan/longshot biases in political markets; the caps themselves prevent full arbitrage, which is _why_ biases persisted — a caution that documented inefficiency often depends on frictions that also block exploiting it.

**Iowa Electronic Markets** — the foundational academic prediction market; long literature showing election-market prices often beat polls, establishing baseline efficiency.

**Good Judgment Project** — not a market but the reference on _forecasting skill_: superforecasters, extremizing aggregation, the value of calibration and updating. Most relevant lesson: disciplined probabilistic forecasting with feedback beats intuition — which is the process this project is trying to instrument.

**Synthesis.** The documented pattern across venues: markets are _hard to beat in aggregate_, inefficiencies are _real but small, frictional, and prone to disappearing once published_, and the durable edge is in _superior calibrated forecasting with rigorous feedback_, not in microstructure tricks or one-off arbitrage. That synthesis is exactly why this project is built as a measurement instrument first.

---

## 12. Engineering Recommendations

Priority / Expected Value / Complexity / Research Confidence, tuned to _this_ project's roadmap.

|Method|Priority|Exp. Value|Complexity|Research Conf.|
|---|---|---|---|---|
|Calibration-based edge (Cat 1) — model-vs-market proper-score comparison|**High**|High|Med|**High**|
|Prediction ledger / Learning System|**High**|High (enabling)|Med|**High**|
|Market calibration study ([[Open Questions]] Q1, favorite–longshot)|**High**|Med|Low|**High**|
|Cross-market coherence check (Cat 4) — as data-quality + rare arb|Med|Low–Med|Low|Med|
|Time-based: market lag after NWS runs (Cat 5)|Med|Low–Med|Med|Med|
|Behavioral biases beyond Q1 (Cat 6)|Low|Unknown|Med|Low|
|Statistical anomaly detection (Cat 2)|Low|Low|Med|Low|
|Microstructure alpha (Cat 3)|Low|Low|High|Low|
|Microstructure as _execution cost model_ (Cat 3)|Med (V3)|Med|Med|Med|
|Reinforcement learning agent|**Defer**|Unknown|High|Low|

**The one-line recommendation:** build the measurement instrument (scanner + probability engine + prediction ledger), answer [[Open Questions]] Q1 with a pre-registered calibration study, and let every "edge" claim be a proper-score verdict at the population level before anything touches execution.

---

## 13. Open Research Questions

This document does **not** create a parallel question register. The canonical register is [[Open Questions]] (Q1–Q7); the items this document bears on map to it directly, and only genuinely new items are proposed as additions (marked _new candidate_ — to be entered by the architect, not by this document).

**Already in the canonical register — this document depends on their resolution:**

- **Q1** (market calibration; favorite–longshot bias) — the first empirical target; §3 Category 6 and §11 both defer to it.
- **Q2** (correct market-forecast extraction rule) — owned by [[Market Normalization Spec]] (A4); every $P_m$ in this document assumes Q2 is answered.
- **Q3** (cross-city / cross-day correlation of outcomes and score differentials) — sets the effective sample size behind §2.3 and §7.
- **Q5** (how market calibration varies with time-to-settlement) — the substance of §3 Category 5.
- **Q6** (is market efficiency improving over time?) — the nonstationarity caveat behind "self-defeating edge."
- **Q7** (does quote staleness bias market scores?) — a Category 2 / microstructure hazard; owned jointly with A4 §5.

**New candidates this document surfaces (for architect entry, not self-registration):**

- _new candidate:_ Does the market fully incorporate a new NWS forecast run, and how fast? (A sharper, testable instance of Q5 — the most tractable weather-specific disagreement hypothesis.)
- _new candidate:_ What is an honest $\sigma_f$ for the model rung, decomposed into ensemble, structural, and calibration components? (Feeds A2; without it, §2.2 has no credible denominator.)
- _new candidate:_ Which candidate signals survive Kalshi's price-dependent fees and spreads? (Net-disagreement; overlaps A4's cost band.)

_Note: the settlement-source question that a prior draft listed here is resolved (NWS DCR, §11) and has been removed._

---

## 14. References

Prioritizing peer-reviewed and quantitative sources. **All E4 until human-verified per Invariant 3.** Full bibliographic details to be confirmed at Lit-note stage; entries below are pointers, not verified citations.

- Wolfers, J. & Zitzewitz, E. (2004). "Prediction Markets." _Journal of Economic Perspectives._ — foundational efficiency survey.
- Snowberg, E. & Wolfers, J. (2010). "Explaining the Favorite–Longshot Bias." _Journal of Political Economy._ — risk-love vs misperception.
- Thaler, R. & Ziemba, W. (1988). "Anomalies: Parimutuel Betting Markets." _Journal of Economic Perspectives._ — favorite–longshot survey.
- Gneiting, T., Balabdaoui, F. & Raftery, A. (2007). "Probabilistic forecasts, calibration and sharpness." _JRSS-B._ — the calibration/sharpness paradigm.
- Gneiting, T. & Raftery, A. (2007). "Strictly Proper Scoring Rules, Prediction, and Estimation." _JASA._ — proper scores.
- Diebold, F. & Mariano, R. (1995). "Comparing Predictive Accuracy." _J. Business & Economic Statistics._ — the DM test.
- Satopää, V. et al. (2014). "Combining multiple probability predictions using a simple logit model." _Int. J. Forecasting._ — extremized aggregation.
- Tetlock, P. & Gardner, D. (2015). _Superforecasting._ — Good Judgment Project synthesis.
- Easley, D. & O'Hara, M. (various). Market microstructure / informed trading (Kyle 1985; PIN/VPIN lineage).
- Berg, Forsythe, Nelson & Rietz. Iowa Electronic Markets research corpus — election markets vs polls.
- Manski, C. (2006). "Interpreting the predictions of prediction markets." _Economics Letters._ — price-as-probability caveats.
- Ledoit, O. & Wolf, M. — bootstrap/inference for financial performance comparison (block bootstrap relevance).
- Bailey, D. & López de Prado — backtest overfitting, deflated Sharpe, multiple-testing in trading research.

---

## Next topic (queued)

**[[Market Normalization Spec]]** (project artifact A4) — how raw Kalshi bracket prices become a coherent, fee-adjusted, sum-to-one probability distribution per city-day. This is the necessary bridge between Category 4's coherence checks and any $P_m$ used in edge detection, and it is flagged as an irreversibility-first priority (ideal window is _before_ collection normalization habits set). Type **continue** to draft it.

_Alternative queued topic:_ **[[Statistical Validity and Inference Framework]]** (A1) — the effective-sample-size-corrected, multiple-testing-aware inference layer that §7 depends on.