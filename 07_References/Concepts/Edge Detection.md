---
title: '"Prediction Market Edge Detection — Technical Reference"'
---
---

---

---

## title: "Edge Detection" aliases: ["Edge Detection", "Mispricing Detection", "Prediction Market Edge Detection — Technical Reference"] vault_location: "01 Research/Prediction Markets" level: "Quantitative researcher reference" status: "AI-drafted v4 — E4, awaiting architect ratification per Invariant 3; NOT canonical until ratified" supersedes: "Edge Detection v3 (2026-07-07)" created: 2026-07-07 review: 2027-01-07 tags: [prediction-markets, edge-detection, statistical-arbitrage, calibration, forecast-verification, microstructure, multiple-testing, market-efficiency]

# Edge Detection

**Cross-links:** [[Prediction Markets]] · [[Kalshi Ticker Anatomy and Market Structure]] · [[Proper Scoring Rules and Calibration - Technical Reference (V2)]] · [[Log Score and Kelly Identity]] · [[Expected Value]] · [[Kelly Criterion]] · [[Effective Sample Size]] · [[Brier Decomposition - Worked Example]] · [[Bayesian Statistics]] · [[Machine Learning]] · [[Glossary]] · [[Open Questions]] · [[Research Lab Master Specification]] · [[Research Methodology v2 Canonical]]

> **Provenance (Invariant 3).** This is an AI-drafted synthesis. Every empirical claim is **E4 (testimony)** until the human opens the cited primary source and confirms it. Citations are given so they _can_ be checked, not because they have been. Effect sizes are reported as the sources state them, with per-claim verification flags where a number carries decision weight; none has been reproduced against primary data in this project. Nothing here becomes load-bearing before it is graded up. v4 integrates the adversarial review of 2026-07-07; the review transcript, not this document, is the record of what changed.

> **Scope discipline.** Reference document, not an ADR. It does not modify the methodology, the city-day unit, the reference ladder, or any settled decision. Machinery proposed here (thresholds, estimators, architecture) is _candidate_ design, ratified only through the normal ADR process.

---

## Definition

**Edge** has a fixed definition in the [[Glossary]]: **statistically significant positive skill versus the market-price reference, with date-clustered inference.** Not a raw price difference. Not backtested P&L. Not a good week.

The primitives, for a binary contract resolving $y \in {0,1}$ paying $1 on YES:

- **Market probability** $P_m \in (0,1)$: the market's probability report, extracted by the rule A4 ratifies (Q2). Until then, the working point estimate is the bid–ask midpoint; the spread is a first-order cost and uncertainty term, never ignored.
- **Model probability** $P_f$: the project's independently produced estimate (NWS-derived model rung of the reference ladder).
- **Disagreement**: $\Delta = P_f - P_m$. The raw material. _Not_ edge.
- **Edge**: a property of a _population_ of resolved forecasts — a statistically significant positive expected proper-score differential of $P_f$ over $P_m$, under dependence-robust (date-clustered) inference, out of sample, after multiplicity correction.

The motivating expected-value identity, stated at an _executable_ price. A YES purchase at the ask $a$ has

$$\text{EV}_{\text{YES}} = P_f(1-a) - (1-P_f),a = P_f - a,$$

which equals $\Delta$ only in the frictionless idealization $a = P_m$ (zero spread, zero fee). Nothing trades at the midpoint; the realistic buy-side EV is $P_f - a - \text{fee}$, and the sell side is symmetric at the bid. Under the idealization, expected value per contract equals the disagreement — _if $P_f$ is correct_. That conditional is the entire problem: $P_f$ is an estimate, $P_m$ is the aggregate belief of everyone else — including participants who may know more — and a single $\Delta$ is a difference of two noisy numbers. **Edge detection is the discipline of deciding when a population of disagreements constitutes real skill rather than model error, market noise, or the detector's own multiple testing.**

The connection to money is exact, not metaphorical. By the Kelly–log-score identity ([[Log Score and Kelly Identity]]), the expected log-growth of a Kelly bettor facing prices $p$ with beliefs $q$ against truth $r$ is

$$\mathbb{E}[\text{log-growth}] = D_{KL}(r ,|, p) - D_{KL}(r ,|, q),$$

i.e., the forecaster's expected log-score advantage over the market. **Edge detection here _is_ proper-score comparison.** This is why the calibration-based method (below) is the project's primary instrument: it measures the exact quantity that compounding wealth depends on.

**Scoring unit.** Because a city-day's ~6 mutually exclusive brackets form one discrete probability distribution, the primary scoring object is the **whole ladder, once per city-day** — the ranked probability score (Epstein, 1969) or the log score on the discrete distribution — not six separate binary scores. Ladder-level scoring dissolves the within-city-day bracket correlation by construction; per-bracket binary scores are retained as _diagnostics_ (they localize where a differential comes from) but never as the unit of inference. This convention is candidate input to A1.

---

## Why Edge Exists

The theoretical case that edge _can_ exist at all — that prices are not automatically correct — rests on three pillars.

**1. The Grossman–Stiglitz argument.** Grossman & Stiglitz (1980) showed, within a noisy rational-expectations model, that perfectly informationally efficient markets are impossible: if prices fully reflected all information, no one would be paid for gathering information, so no one would gather it, so prices could not reflect it. Equilibrium requires _some_ residual inefficiency — enough to compensate the marginal informed trader. A useful **heuristic inspired by (not implied by) this result**: expect edge, where it exists, to be commensurate with the cost of producing the information that generates it. The theorem does not deliver this as a quantitative law for an individual entrant; it is a budgeting consistency check, and this project uses it as such — a solo lab competes on information-production cost, and the sanity question is whether its cost is plausibly below the market's marginal informed trader's.

**2. Bounded arbitrage.** Even when mispricing is identified, correcting it requires capital, willingness to bear risk, and market structure that permits the trade (Shleifer & Vishny, 1997). Prediction markets add specific frictions: position limits (historically on PredictIt), price-dependent fees (Kalshi), thin books, and short horizons that limit how much capital sophisticated traders will commit. Documented inefficiencies often _persist because_ the frictions that reveal them also block exploiting them.

**3. Heterogeneous participants.** Prediction market prices aggregate traders with different information, different priors, and different objectives (hedging, entertainment, ideology). Whelan-style models of Kalshi's quote-driven structure are _consistent with_ the observed pricing patterns arising from modest belief disagreement plus a small systematic misperception of low probabilities (Bürgi, Deng & Whelan, 2025). Prices are a weighted average of beliefs, and the weights are set by willingness to trade, not by accuracy.

Against these stands the null hypothesis that must be the default: markets aggregate information well. The first-order evidence supports it, with a genuine dispute worth stating plainly. Election prediction-market prices have historically been competitive forecasters (Berg, Forsythe, Nelson & Rietz, IEM corpus; Wolfers & Zitzewitz, 2004), but Erikson & Wlezien (2008) showed that once raw polls are statistically projected — correcting the known systematic biases of early polls — poll-based forecasts _beat_ IEM prices over the same elections. The defensible synthesis is that market prices are **competitive with, not clearly superior to, well-constructed statistical forecasts** — which is precisely this project's framing: the question is never "are markets smart?" but "is this specific model rung sharper than this specific market rung, measured properly?" **The honest posture: edge exists at second order — in the residual the Grossman–Stiglitz equilibrium leaves, in specific biases at specific price ranges and horizons, net of costs. Never assume it; measure it.**

---

## Sources of Mispricing

A structured inventory, ordered roughly by evidential support in the literature. Each maps to a detection method later in the document.

|Source|Mechanism|Evidence quality|Project relevance|
|---|---|---|---|
|Favorite–longshot bias|Overpricing of low-probability contracts; misperception and/or skewness preference|**Strong**, replicated for decades across venues; now documented on Kalshi itself (pooled across categories)|Q1 — the first empirical target|
|Time-to-expiration miscalibration|FLB-direction miscalibration grows with horizon in the studied range (weeks to years); daily horizons lie outside the sample|Strong within its range (Page & Clemen 2013); **extrapolation to daily brackets is unanchored**|Q5|
|Slow information incorporation / underreaction|Prices underreact to new information under heterogeneous beliefs (Ottaviani & Sørensen 2015); for weather, the scheduled information is NWS forecast runs|Formal theory exists; venue-specific magnitude untested; equities post-announcement drift (Bernard & Thomas 1989) is analogy, not evidence|New-candidate question (sharper Q5)|
|Liquidity/inventory effects|Thin books, wide spreads, stale quotes distort the price-as-probability reading|Moderate; venue-specific (P.C. Tetlock 2008 on liquidity and pricing)|Q7|
|Structural/fee-induced distortion|Price-dependent fees and maker/taker asymmetry shift where quotes sit|Moderate (Kalshi-specific analysis exists)|Cost model, A4|
|Behavioral overreaction to salient news|Narrative-driven repricing beyond information content|Moderate in elections/sports; unknown for weather|Low priority|
|Cross-market incoherence|Bracket ladders violating sum-to-one or monotonicity|Logically certain when present; empirically rare and small after fees|Data-quality instrument first, alpha second|

Two disciplined observations. First, the sources with the strongest general evidence (FLB, horizon effects) are _calibration-level_ phenomena — detected by scoring populations of resolved prices, which is precisely what the V1 instrument does. Second, none of these has been established _in Kalshi weather brackets specifically_. The Bürgi–Deng–Whelan results pool across Kalshi's market categories; weather brackets are short-dated and fundamentals-driven in a way elections are not, and the Page–Clemen horizon relationship, while directionally suggestive of small biases at short horizons, was estimated on nothing as short-dated as a daily bracket. The prior on Q1 is "FLB plausible, direction known from pooled Kalshi data, magnitude in weather genuinely unknown" — a sharper prior, not an answer.

---

## Efficient Market Hypothesis vs Prediction Markets

**The EMH baseline.** Fama (1970) formalized efficiency in three forms: weak (prices reflect past prices), semi-strong (all public information), strong (all information including private). For a prediction market, semi-strong efficiency implies $P_m = \mathbb{P}(y=1 \mid \mathcal{F}_t)$ — the price is the correct conditional probability given public information at time $t$. Under that hypothesis, no model built on public data (NWS forecasts are public) can systematically outperform the price, and every $\Delta$ is model error.

**Why prediction markets are a favorable test bed for efficiency — and where they fail.** Prediction markets have properties that make them _more_ efficient than the EMH's usual habitat in some respects (binary payoffs, terminal resolution against verifiable facts, no discounted-cash-flow ambiguity) and _less_ in others (thin liquidity, retail-heavy participation, position frictions, no cross-sectional arbitrageurs enforcing relative pricing). The empirical record matches this split personality:

- **Aggregate calibration is good at first order.** Across venues and decades, pooled calibration curves hug the diagonal (IEM corpus; Wolfers & Zitzewitz, 2004). On Kalshi specifically, Bürgi, Deng & Whelan (2025) find prices informative and improving in accuracy as markets approach closing.
- **But market superiority over statistical forecasts is contested, not established.** Erikson & Wlezien (2008) on markets vs projected polls; Atanasov et al. (2017) find well-structured prediction _polls_ competitive with prediction markets in the Good Judgment Project. The relevant comparison is always market vs a specific well-built alternative — never market vs strawman.
- **Systematic local deviations exist.** The FLB is the most robust; it appears in Kalshi's pooled data despite the absence of the bookmaker and pari-mutuel mechanisms that explain it in racetrack settings, pointing toward misperception of small probabilities as the mechanism (Bürgi, Deng & Whelan, 2025).
- **Price ≠ probability without caveats.** Manski (2006) showed that with heterogeneous beliefs, the equilibrium price is not in general the mean belief; Wolfers & Zitzewitz (2006) established conditions under which prices approximate mean beliefs. Treat $P_m$ as an _excellent but imperfect_ probability report whose error structure is an empirical object — the premise of the V1 instrument.

**Adaptive rather than binary efficiency.** Lo's (2004) Adaptive Markets Hypothesis — a framework, not a tested theory, and one with known falsifiability criticisms — usefully reframes efficiency as an ecological, time-varying property: inefficiencies appear, are competed away, and can reappear as participant populations change. This is the right _frame_ for Q6 (is efficiency improving?), and Bürgi–Deng–Whelan already report some evidence that Kalshi's pricing bias is diminishing over time. Any edge estimated on old data must be treated as an estimate of a _decaying_ quantity (see § Regime Changes and § False Edge vs True Edge).

---

## Behavioral Sources of Edge

**Favorite–longshot bias (FLB).** The most replicated pricing anomaly in wagering markets: low-probability outcomes are overpriced relative to their true frequency, high-probability outcomes underpriced. Documented since Griffith (1949); surveyed in Thaler & Ziemba (1988) and Ottaviani & Sørensen (2008). Two families of explanation contend:

1. **Preference-based** — risk-love or skewness preference (bettors pay for lottery-like payoffs; Golec & Tamarkin 1998).
2. **Misperception-based** — probability weighting overweights small probabilities (Snowberg & Wolfers, 2010, use exotic-bet pricing to discriminate and find misperception fits better than risk-love).

**Direct Kalshi evidence.** Bürgi, Deng & Whelan analyze transaction-level Kalshi data (~314,000 contracts) and report: low-price contracts win far less often than break-even requires — buyers of contracts under 10¢ lose over 60% of their money — while contracts above 50¢ earn small positive returns; the pattern holds across market categories and appears in a venue where the classic bookmaker-manipulation and pari-mutuel mechanisms _cannot_ operate, strengthening the misperception interpretation. They also document a large microstructure split in average realized returns between **Takers (who cross the spread) and Makers (who post quotes)** — on the order of tens of percentage points, with Takers faring far worse and the FLB pattern much stronger on the Taker side. ⚑ _Verification flag:_ these effect sizes are transcribed from the paper's abstract and summary articles, not from its tables; the paper exists in at least two vintages (CESifo/UCD WP2025_19, 2025; GWU WP 2026-001, 2026) whose numbers may differ. Verify the exact figures against a specific version's tables before any downstream use, and record which version was verified.

**Three implications for this project, carefully bounded:**

1. **Q1's prior is sharpened, not resolved.** The pooled-Kalshi FLB says nothing decisive about weather brackets. The pre-registered calibration study proceeds unchanged; this literature sets the _directional_ prior and an effect-size ceiling, and it motivates pre-specifying the price-bucket analysis in Q1's registration.
2. **Spread-crossing costs are first-order on this venue and must be modeled explicitly.** The maker/taker return gap establishes that _how_ one transacts materially changes realized returns for the average participant. It does **not** establish that passive execution dominates for an informed, model-driven trader: the average Taker in that data is not drawn from the same population as a validated-signal trader, and passive quotes carry their own adverse-selection cost — limit orders are filled disproportionately when the counterparty is right (Glosten & Milgrom, 1985; Sandås, 2001). Which posture dominates for this project is an open empirical question for the eventual V3 execution-cost model, not a conclusion available from unconditional averages.
3. **Tail brackets are where the bias lives — and where the model is weakest.** FLB concentrates at low prices; the model rung's tails are exactly where residual history is thinnest (the A2 tail-policy problem). A naive detector will "find" its largest disagreements precisely where _both_ the market and the model are least trustworthy. This coincidence is a standing trap.

**Other behavioral candidates** (over/underreaction to news, availability/narrative effects, herding in thin books) are documented in political and sports markets but have low priors in weather brackets, which lack narrative content. They stay in the register as low-priority hypotheses, each a draw on the multiple-testing budget if tested.

---

## Information Asymmetry

**The adverse-selection frame.** In Kyle (1985) and Glosten & Milgrom (1985), market makers set prices knowing some counterparties are informed; the spread is compensation for adverse selection, and price impact reveals information. Translated to this project: **when the model disagrees with the market, the market's side of the disagreement may be the informed side.** A standing quote at an "attractive" price may be attractive because its poster knows something (a later model run, a mesoscale observation, settlement-station nuance) the pipeline hasn't ingested. The same logic runs in reverse for passive orders this project might one day post: resting quotes are picked off precisely when the counterparty knows more.

**Who could be informed in a weather bracket?** Unlike insider-trading settings, weather information is public — but _not uniformly ingested_. Asymmetry here is asymmetry of _processing_: participants running higher-resolution models, ingesting observations faster, or understanding settlement mechanics better (the DCR settlement source, local-standard-time windows, station idiosyncrasies documented in [[Kalshi Ticker Anatomy and Market Structure]]). Settlement-mechanics knowledge is a genuinely asymmetric information class, and the project's mastery of it (station verification, A6 reconciliation) is itself a candidate component of skill.

**Operational discipline.** Before treating any $\Delta$ as a candidate signal, ask the adverse-selection question explicitly: _what would the counterparty have to know for this price to be right?_ If the answer is "a newer forecast run than the one $P_f$ used," the disagreement is a data-latency artifact, not skill. The dual-timestamp architecture exists so this question is answerable: every comparison must pair the price with the information set actually available at the model's issuance time.

---

## Liquidity Effects

Thin markets distort every step of the measurement chain.

**Price extraction.** With wide or one-sided quotes, the midpoint is a poor probability estimate; with zero-volume brackets carrying 1¢/99¢ placeholder quotes (observed in this project's own 1a data — the origin of Q7), the "price" is not a belief at all. The market-forecast extraction rule (Q2, owned by A4) must define handling for wide, crossed, stale, and absent quotes _before_ any scoring, because changing the rule after seeing scores is p-hacking. Empirical support that liquidity conditions distort prediction-market pricing: P.C. Tetlock (2008).

**Effective edge shrinkage.** The tradeable quantity is not $\Delta$ but the net disagreement after explicit costs:

$$\Delta_{\text{net}} = (P_f - P_m) ;-; \tfrac{1}{2},\text{spread} ;-; \text{fee}(P_m),$$

where the fee is Kalshi's price-dependent formula evaluated at the actual price. This is a _cost identity only_; estimation uncertainty in $P_f$ is handled separately and properly as a lower confidence bound on edge (§ Risk Adjusted Edge), not as an ad-hoc penalty term inside the EV arithmetic. In thin brackets the spread term alone routinely exceeds plausible model skill. **A liquidity gate belongs in front of every detector**: minimum depth at top-of-book, maximum spread, minimum recent volume — parameters to be set empirically and pre-registered, not tuned to results.

**Depth vs displayed price.** Even a genuine $\Delta_{\text{net}} > 0$ is only worth the _size available at that price_. Marginal EV declines as the order walks the book. The correct object for sizing is the EV integrated over the depth curve, which is why the collector's capture of book depth (not just top-of-book) is flagged as a load-bearing data requirement.

**Liquidity as a signal confounder.** Documented biases interact with liquidity: FLB is strongest where longshots are cheap and books thin; stale quotes masquerade as mispricing (Q7). Every candidate signal must be checked for whether it is a _liquidity artifact wearing a mispricing costume_ — the placebo tests in § Robustness Testing operationalize this.

---

## Market Microstructure

**Kalshi's structure.** A CFTC-regulated central limit order book (CLOB), quote-driven, with price-dependent trading fees and a maker/taker distinction recorded at the trade level. This differs from pari-mutuel pools (racetracks), the IEM's double auction, Polymarket's hybrid AMM/book structure, and PredictIt's capped continuous market — which is why effect sizes from those venues do not transfer numerically.

**The canonical models and what they buy this project.**

- _Kyle (1985):_ informed traders optimally hide in noise flow; price impact measures how much information trades carry. Use: a conceptual basis for expecting _execution_ to move prices against the project in thin brackets — the cost model, not alpha.
- _Glosten & Milgrom (1985):_ the bid–ask spread as the market maker's defense against adverse selection. Use: spread width is partly an _information_ signal (how much the quoter fears informed flow), not just a cost; and any passive order this project posts inherits the adverse-selection exposure the model describes (see also Sandås, 2001, on adverse selection in limit order books).
- _Prediction-market-specific theory:_ Ottaviani & Sørensen (2015) formalize price formation under heterogeneous beliefs and show prices underreact to information and drift toward resolution — the directly relevant theoretical anchor for the "market incorporation speed of NWS runs" hypothesis (§ Time Series Considerations), replacing loose equities analogies. P.C. Tetlock (2008) provides field evidence linking liquidity to prediction-market pricing quality.
- _Flow-toxicity measures (PIN; Easley, Kiefer, O'Hara & Paperman, 1996, and the VPIN lineage):_ estimating the informed share of order flow. Use here: low. These require rich flow data and calibrate poorly in tiny markets; catalogued for completeness, deferred indefinitely.

**Microstructure findings specific to Kalshi.** The Bürgi–Deng–Whelan maker/taker asymmetry (§ Behavioral Sources, with its verification flag) is the most actionable microstructure fact currently in evidence — actionable in the precise sense that **transaction-mode costs are first-order on this venue and the execution-cost model must price them explicitly**. It does not by itself select an execution posture for an informed trader; that selection trades spread savings against adverse-selection cost on resting orders and is a registered empirical question for V3.

**Microstructure signals as alpha: expected value low.** Stale-price detection, order-imbalance signals, and short-horizon flow prediction are well-documented in liquid equities and sparsely evidenced in prediction markets. In a weather bracket trading a few hundred contracts a day, such signals are (a) small, (b) expensive to harvest, (c) latency-competitive, and (d) confounded by the scheduled-information structure of weather (prices _should_ jump on NWS runs). Microstructure's role in this project is **execution-cost modeling and data-quality diagnostics** — with one exception worth a registered study: the market's incorporation speed of new NWS runs.

---

## Calibration Errors

Calibration is the hinge between "good model" and "makes money," and between "biased market" and "exploitable market." For this project the governing tradition is the **meteorological forecast-verification literature** — the field that invented these problems (general framework: Murphy & Winkler, 1987; textbook treatment: Wilks, _Statistical Methods in the Atmospheric Sciences_) — with the ML calibration literature as a supplementary layer for binary-contract post-processing.

**Definitions.** A forecaster is _calibrated_ if events forecast at probability $x$ occur with frequency $x$: $\mathbb{E}[y \mid P = x] = x$. Calibration is necessary but nearly free to achieve alone (Foster & Vohra, 1998 — even an ignorant forecaster can be asymptotically calibrated), so it must be paired with _sharpness_: the paradigm is **maximize sharpness subject to calibration** (Gneiting, Balabdaoui & Raftery, 2007).

**The decomposition that structures everything.** Murphy (1973) decomposes the Brier score:

$$\text{BS} = \underbrace{\text{Reliability}}_{\text{calibration error}} - \underbrace{\text{Resolution}}_{\text{sharpness that discriminates}} + \underbrace{\text{Uncertainty}}_{\text{base-rate entropy, fixed}}.$$

A model beats the market by having lower reliability (better calibrated) and/or higher resolution (sharper while staying calibrated). The decomposition — worked in [[Brier Decomposition - Worked Example]] — tells you _which_ kind of advantage a score differential reflects, which matters because the two decay differently: a calibration advantage over a miscalibrated market is a bias-harvesting edge (durable while the bias persists); a resolution advantage is an information-production edge (durable while the pipeline is better).

**Why miscalibration destroys money even when direction is right.** Bet sizing (Kelly) consumes the probability, not the direction. A model saying 90% when truth is 70% is usually "right" yet systematically overbets; the log-score/Kelly identity converts that overconfidence directly into negative expected log-growth. Miscalibration is a compounding capital drain, not a cosmetic flaw.

**Producing calibrated probabilities from ensembles — the meteorological toolkit (A2's home field).** Raw ensemble output is not a calibrated probability distribution: spread systematically understates uncertainty (verify with rank histograms; Hamill, 2001). The canonical repairs are:

- **EMOS / non-homogeneous Gaussian regression** (Gneiting, Raftery, Westveld & Goldman, 2005): regress the predictive distribution's location and spread on ensemble statistics; the standard, parsimonious default for temperature.
- **Bayesian Model Averaging** (Raftery, Gneiting, Balabdaoui & Polakowski, 2005): a weighted mixture of member-centered kernels; more flexible, more parameters.
- Ensemble dressing and quantile-based methods as alternatives where distributional form is doubtful.

These operate on the _continuous temperature distribution_, upstream of bracket discretization — exactly where A2 lives.

**Post-hoc recalibration of binary/discrete contract probabilities — the ML toolkit,** applied downstream on held-out resolved city-days:

|Method|Parameters|Small-sample behavior|Scope note|
|---|---|---|---|
|Platt scaling (Platt, 1999)|2 (logistic)|Robust; parametric assumptions do real work|General-purpose default for binary probabilities|
|Temperature scaling (Guo et al., 2017)|1|Most robust; preserves ranking|Designed for classifier _logits_; evidence base is deep networks, not distributional pipelines — apply only where the model emits logit-like scores|
|Beta calibration (Kull et al., 2017)|3|Middle ground|Candidate|
|Bayesian binning (BBQ; Naeini et al., 2015)|Non-parametric + priors|Better than isotonic when small|Candidate|
|Isotonic regression (Zadrozny & Elkan, 2002)|Non-parametric|Overfits badly below ~1000s of observations|Deferred until sample supports it|

The ML literature's arc, stated with its caveat: classical models were often well calibrated (Niculescu-Mizil & Caruana, 2005); Guo et al. (2017) found modern deep classifiers accurate but overconfident, largely fixable by one-parameter scaling; Minderer et al. (2021) later found the newest architectures better calibrated again, so "modern models are overconfident" is a dated generalization, not a law. The transferable lessons: **measure calibration on held-out data rather than assuming it**, and prefer one-to-three-parameter fixes at this project's sample sizes.

**Metrics and diagnostics discipline.** Brier and log score are strictly proper — optimize and report them. ECE is a _diagnostic_, binning-sensitive and improper — report it across multiple binnings, never optimize it (Glossary caution). For reliability diagrams, naive binomial bands are known to be misleading; use resampling-based **consistency bands** (Bröcker & Smith, 2007) or, preferably, the CORP approach — isotonic-regression-based reliability diagrams with valid uncertainty quantification (Dimitriadis, Gneiting & Jordan, 2021). CORP is the candidate standard for A1.

---

## Forecast vs Market Divergence

The operational core: what to do with a stream of $(P_f, P_m, y)$ triples.

**The unit and the ledger.** The unit of evidence is the **city-day** (~150/month across five cities, not the naive bracket count — all ~6 brackets of a city-day are a single observation, scored at the ladder level per § Definition). Every model issuance and every extracted market probability is written to the prediction ledger with dual timestamps (event time, ingestion time). The ledger is the instrument's memory; without it there is no population, and without a population there is no edge in the defined sense.

**Divergence is a _queue_, not a finding.** A large standardized disagreement on a live city-day is an entry in a triage queue (A7), where the checklist runs: Is the price stale (Q7)? Did the model use the latest run the market has (adverse selection / latency)? Is the bracket a tail where A2's residual history is thin? Is the ladder coherent (normalization bug)? Only what survives triage — a **triaged divergence** — accrues to the population that eventually gets scored. No individual divergence, triaged or not, is ever called edge.

**Divergence content — the V2-gate question.** The eventual claim is not "divergences exist" but "divergences carry information": conditional on a triaged divergence of size $\Delta$, does the outcome side with the model often enough that a fee-paying position had positive expectation? Formally, regress realized score differentials on divergence size out of sample, or equivalently test whether the model's score advantage concentrates in high-$|\Delta|$ city-days. Either way, it is a _pre-registered population-level_ test.

---

## Measuring Edge

**Step 1 — standardize the disagreement, with the covariance term.** $P_f$ carries standard error $\sigma_f$; the extracted $P_m$ has dispersion $\sigma_m$. Because model and market are driven substantially by the _same_ public NWS information, their errors are positively correlated; the screening statistic must carry that covariance:

$$z = \frac{P_f - P_m}{\sqrt{\sigma_f^2 + \sigma_m^2 - 2\rho,\sigma_f \sigma_m}},$$

where $\rho = \operatorname{corr}(\varepsilon_f, \varepsilon_m)$ is an **empirical quantity**, estimable from the resolved population and closely related to Q3's correlation program. The independence version ($\rho = 0$) is a special case, not the definition; with $\rho > 0$ it overstates the denominator, and the error propagates into every power calculation built on it. Worked shape: with $\sigma_f = 4$, $\sigma_m = 3$ points and $\rho = 0.5$, the denominator is $\sqrt{16 + 9 - 12} \approx 3.6$, so a 3-point disagreement has $z \approx 0.83$ — still noise, but visibly different from the $\rho=0$ answer. The Master Spec R7 example ("a 3% advantage may be meaningless when uncertainty is ±5%") is the $\rho = 0$ instance of the same arithmetic.

**Component honesty.** $\sigma_f$: ensemble spread is a _floor_ (sampling variance, not misspecification); credible $\sigma_f$ adds the model's demonstrated out-of-sample calibration error on resolved city-days plus structural uncertainty. Understating $\sigma_f$ is the classic way disagreement strategies quietly lose money. $\sigma_m$: **no estimator is defined here** — it is owned by A4/Q2; a placeholder convention (half-spread plus short-window midpoint volatility) may be used for exploratory screening only, and $z$ is formally undefined until A4 ratifies the extraction rule and its dispersion measure.

**Step 2 — score the population.** For each resolved city-day $t$, compute the paired proper-score differential at the _ladder_ level,

$$d_t = S(\mathbf{P}_{m,t}, y_t) - S(\mathbf{P}_{f,t}, y_t),$$

with $S$ the discrete log score (P&L-relevant, via the Kelly identity) or the ranked probability score, and the other reported as the robustness companion (log score is unbounded and tail-sensitive; a single confident miss dominates — pre-register which is primary). Edge, in the Glossary sense, is $\mathbb{E}[d_t] > 0$ established by dependence-robust inference on ${d_t}$ (§ Statistical Detection Methods). Per-bracket binary scores are diagnostics for _localizing_ a differential, never the unit of inference.

**Step 3 — net of costs.** The tradeable object is $\Delta_{\text{net}}$ (§ Liquidity Effects). Costs enter _there_, not in $P_m$ — A4 keeps the market rung fee-free and records the cost band separately, so the same data serves both the measurement question (is there skill?) and the economic question (does skill survive costs?). Estimation uncertainty enters as a lower confidence bound on edge (§ Risk Adjusted Edge), not as a term inside the cost identity.

---

## Statistical Detection Methods

**The primary test family: paired score differentials, with lineage stated honestly.** Diebold & Mariano (1995) is the ancestor: test $H_0: \mathbb{E}[d_t] = 0$ using an autocorrelation-robust variance. Three qualifications are mandatory, and Diebold's own retrospective (Diebold, 2015) warns against overextending the original test:

1. **Small samples:** the asymptotic DM over-rejects; apply the Harvey, Leybourne & Newbold (1997) rescaling with $t_{n-1}$ reference. At this project's effective $n$, not optional.
2. **Panel structure:** this project's data is a city × day panel, not a single series; "DM with clustering" is _candidate bespoke machinery_ whose properties must be established (by simulation under the project's own dependence structure) in A1, not assumed. The modern framework for predictive-ability testing with estimated models and rolling schemes is Giacomini & White (2006) — the more appropriate citation for a walk-forward instrument; West (1996) governs inference when forecasts share estimated inputs.
3. **Nested comparisons:** when the model rung is compared against climatology (the ladder's floor), the forecasts are nested and DM-type statistics are non-standard; use the Clark & West (2007) adjustment.

**Dependence-robust inference — and the few-clusters trap.** The Glossary's date-clustered requirement is implemented by clustering at the date level or by block bootstrap. But cluster-robust variance estimators are asymptotic _in the number of clusters_: with the ~30 date-clusters/month available early in accrual (fewer under seasonal stratification), naive clustered standard errors are downward-biased and tests over-reject — anti-conservative exactly when the sample is smallest and the temptation to declare a finding is greatest. **Below a cluster-count threshold to be fixed in A1, the required implementation is the wild cluster bootstrap** (Cameron, Gelbach & Miller, 2008; practical guidance in MacKinnon & Webb, 2017). The direct precedent for this whole design problem — testing forecast-skill differences under spatially and temporally correlated weather samples — is Hamill (1999), which should be read before A1 is drafted.

**Resampling machinery.**

- _Block / stationary bootstrap_ (Politis & Romano, 1994) on the $d_t$ series for CIs on the score differential. Blocks must be **contiguous multi-date blocks**: whole dates kept intact (cross-city dependence) _and_ adjacent dates grouped (serial dependence across days). Date-sized blocks alone capture only the first.
- _Monte Carlo null diagnostics._ Simulating outcomes from $P_m$ and re-running the entire pipeline is a **joint-null diagnostic** — it tests "market perfectly calibrated _and_ no skill difference," not the skill null alone. Run the complementary simulations too: outcomes from $P_f$, and outcomes from a no-difference null (e.g., the average of the two forecasts). Together these calibrate the machinery's end-to-end false-positive behavior; none alone is a clean placebo.
- Sign-flip permutation on $d_t$ is **not** used: its validity requires the score differential to be symmetric about zero under the null, which proper-score differentials (log score especially) do not satisfy in general.

**Sequential monitoring.** A standing instrument scores new city-days monthly; repeatedly testing an accumulating sample at fixed $\alpha$ inflates false positives (optional stopping). The project's default design is the pre-registered decision date at pre-computed $n$ — register early, score late. If interim looks are ever wanted, they must be pre-specified via alpha-spending group-sequential boundaries (e.g., O'Brien–Fleming) or anytime-valid e-value methods (Ramdas, Grünwald, Vovk & Shafer, 2023). Whichever is chosen must be chosen _before_ data arrives; the same principle governs when a lockbox OOS window may be revisited (§ Out-of-Sample Validation).

---

## Bayesian Approaches

The frequentist machinery answers "could this differential arise by chance?" The Bayesian layer answers the question actually being asked: **"what is the probability the model has skill, and how large is it?"** — with honesty about small samples built in through the prior.

**Posterior over the score differential.** Model $d_t$ hierarchically at the date level (dates as clusters), prior on the skill parameter $\mu$ centered at _zero_ — the skeptical prior the efficiency literature earns. Report $\Pr(\mu > 0 \mid \text{data})$ and the posterior distribution of $\mu$ itself. The skeptical prior does automatically what multiple-testing corrections do manually: it shrinks small-sample enthusiasm toward zero.

**Shrinkage of disagreements — specified properly.** Individual disagreements are noisy draws around mostly-zero true mispricings, with **heteroskedastic** noise (a 3¢ tail bracket and a 45¢ center bracket have very different error scales) and bounded support near 0/1. The defensible construction: work in **log-odds space**, $\delta_i = \operatorname{logit}(P_{f,i}) - \operatorname{logit}(P_{m,i})$, with per-observation noise variance $\sigma_i^2$, and shrink

$$\hat{\delta}_i^{\text{shrunk}} = \left(1 - \frac{\sigma_i^2}{\sigma_i^2 + \hat{\tau}^2}\right)\delta_i,$$

where $\hat{\tau}^2$ is the estimated variance of _true_ log-odds mispricings across the population. Two caveats stated up front: estimating $\hat{\tau}^2$ when the $\sigma_i^2$ are themselves estimates is a genuine identification problem (empirical-Bayes methods handle it but not for free — Efron & Morris, 1975; Efron, 2010), and the whole construction is candidate machinery for A1, not adopted here. Its purpose is principled: the largest raw disagreements are disproportionately noise and tail-model artifacts, and an unshrunk maximum is an overestimate by selection.

**Bayesian model comparison as the V2 frame.** When multiple model-rung variants exist, comparison via out-of-sample log predictive density is simultaneously Bayesian model evaluation and exactly the proper-score comparison the instrument already performs — the frameworks coincide here, which is a feature.

**What Bayes does not license.** Priors do not substitute for pre-registration (a prior chosen after seeing data is p-hacking with extra notation), and posterior probabilities of skill are as vulnerable to multiple testing as p-values if many hypotheses are scanned and only winners reported. The Bayesian layer is a _reporting and shrinkage_ discipline inside the registered design, not an escape from it.

---

## Machine Learning Approaches

**Supervised learning, honestly scoped.** At ~150 city-days/month, the sane envelope is regularized logistic regression and shallow gradient boosting with strict time-respecting cross-validation. Neural approaches are dominated at this scale. Three application patterns, in descending order of value:

1. **Ensemble-to-probability conversion and recalibration** — the genuinely valuable one, and its best tools are meteorological (EMOS/NGR, BMA; § Calibration Errors), with small-parameter ML recalibration downstream on held-out resolved city-days.
2. **Residual modeling for the model rung** — learning the NWS-forecast error distribution per station/lead-time/season (A2 territory). This is where statistical-learning capacity is best spent, because it improves $P_f$ and $\sigma_f$ directly.
3. **"Mispricing classification"** — mostly circular: the label requires resolved outcomes and a proper score, at which point the score comparison _is_ the analysis. Deprecated as a framing.

**The binding constraint is calibration, not accuracy.** A high-AUC, poorly calibrated model sizes bets wrong and loses money while being directionally right. Measure calibration on held-out data; repair with few-parameter methods (§ Calibration Errors).

**Forecast combination, with its conditions.** If multiple forecast sources are ever pooled, extremized (log-odds) aggregation outperforms naive averaging **under conditions**: individually underconfident forecasters with overlapping information (Satopää et al., 2014; Baron, Mellers, Tetlock et al., 2014). When inputs are already sharp or information is asymmetric, extremizing over-corrects. State the conditions in any combining ADR.

**Unsupervised learning** (isolation forests, clustering, autoencoders): useful as **data-quality and regime-flagging tools** — incoherent bracket ladders, anomalous quote patterns, distributional drift in inputs. Weak as standalone alpha: an anomaly is only interesting if fundamentals did not move, and in weather they usually did (a new run arrived).

**Reinforcement learning: deferred, on the record.** RL needs orders of magnitude more samples than exist, is prone to reward hacking and backtest overfitting, and produces policies whose load-bearing claims cannot be human-verified in the Invariant 3 sense. Incompatible with both the data rate and the governance model for the foreseeable horizon.

**Leakage discipline for any ML component.** Feature construction must respect ingestion timestamps (a feature computed from data ingested after the prediction time is look-ahead leakage even if event-timestamped earlier); cross-validation must be time-ordered with purging of overlapping information between train and test (López de Prado, 2018, formalizes purged/embargoed CV for exactly this failure mode).

---

## Time Series Considerations

**Weather markets run on a scheduled-information clock.** NWS forecast runs arrive on a known cadence; the settlement observation accrues through the day; the DCR lands the following morning. Price dynamics decompose into (a) expected repricing on scheduled information, (b) mechanical convergence toward 0/1 as uncertainty resolves, and (c) everything else. Only (c) can contain inefficiency, and separating it from (a) and (b) is the central time-series discipline: **condition every price-behavior analysis on the forecast-issuance schedule.** A price jump coincident with a new run is information; a drift between runs with no news is a candidate anomaly.

**The most tractable time-based hypothesis** (a sharper, testable instance of Q5, flagged for architect entry): _does the market fully incorporate a new NWS run within X minutes, and is there predictable drift from pre-run prices to post-run fair value?_ Its theoretical anchor is Ottaviani & Sørensen (2015) — prediction-market prices underreact to information under heterogeneous beliefs and drift toward resolution; the equities post-announcement-drift literature (Bernard & Thomas, 1989) is a supporting analogy only. The dual-timestamp architecture makes the hypothesis testable without leakage, and it is pre-registerable as a single hypothesis.

**Horizon structure of calibration.** Page & Clemen (2013) provide the peer-reviewed anchor for horizon effects: within their sample (contracts weeks to years from expiration), FLB-direction miscalibration grows with time-to-expiration, and short-dated markets are the best-calibrated. Their finding is _consistent with_ small biases at daily horizons, **but the sample contains nothing as short-dated as a daily bracket, so Q5 is genuinely unanchored at this horizon** — which is exactly why Q5's within-day analysis (morning vs final-hour prices as different forecasts with different information sets) is worth running rather than assuming.

**Serial dependence in evaluation.** Score differentials $d_t$ inherit weather's spatial-temporal correlation: cities share synoptic systems within a date; adjacent days share regimes. All inference machinery (§ Statistical Detection Methods) must carry this dependence; it is the reason the Glossary definition hard-codes date clustering, and the reason the few-clusters correction there is mandatory.

---

## Regime Changes

Nonstationarity is not a nuisance here; it is a first-order property of the object being measured (Q6).

**Sources of regime change, in rough order of expected impact:**

1. **Participant-population shifts** — a new market-making firm or weather-specialist fund entering the venue can change efficiency abruptly; Kalshi's growth trajectory makes this likely rather than hypothetical. Field evidence that identifiable prediction-market biases attenuate as participants gain experience: Cowgill & Zitzewitz (2015).
2. **Venue changes** — fee-schedule revisions (Kalshi's fee structure has already changed historically), tick rules, new bracket structures; each is a documented, dated structural break to annotate in the data.
3. **Seasonal regime structure in the weather itself** — forecast skill and residual distributions differ by season and regime (monsoon Phoenix vs winter Chicago); the model rung must be seasonal, and pooled scoring across seasons must cluster or stratify accordingly.
4. **Endogenous decay** — any bias being exploited (by this project or others) shrinks; McLean & Pontiff (2016) document substantial post-publication decay of academic return predictors, and Timmermann & Granger (2004) give the theoretical frame of forecastability as a self-destroying property. Bürgi–Deng–Whelan's tentative finding that Kalshi's pricing bias is diminishing over time is this dynamic, live, on this venue.

**Detection machinery, matched to small samples:** rolling-window score differentials with explicit window-choice pre-registration; CUSUM-type monitoring of cumulative $d_t$ for drift; at most a single structural-break test (Bai–Perron style) treated as exploratory. With the project's data rate, the honest posture is _annotation over estimation_: known venue events are marked as breaks in the data; statistical break detection is a supplement, because the sample rarely supports estimating break dates precisely.

**Consequence for pooling.** Any edge estimate is a weighted average over regimes; if efficiency improved mid-sample, the pooled estimate overstates the _current_ edge. Report score differentials by period as a standard output, and treat "edge estimated on old data" as an upper bound on edge available now.

---

## False Edge vs True Edge

The base-rate problem, stated plainly: most detected edges are false. The prior for any newly detected trading signal should resemble the prior for a newly published return factor — a literature in which a large fraction of discoveries fail multiplicity-adjusted thresholds (Harvey, Liu & Zhu, 2016) and survivors decay after publication (McLean & Pontiff, 2016).

**Signatures that distinguish true edge:**

|Property|True edge|False edge|
|---|---|---|
|Mechanism|Identifiable, economically sensible, cost-consistent|Post-hoc story fitted to a pattern|
|Out-of-sample behavior|Persists at attenuated size|Vanishes or reverses|
|Parameter sensitivity|Robust to perturbation of thresholds/windows|Lives in one parameter cell|
|Concentration|Spread across many city-days|Driven by a handful of extreme observations|
|Cost survival|Positive after spread + fees at executable size|Positive only at midpoint|
|Data integrity|Survives the leakage audit and outcome-verification stress|Coincides with a timestamp or settlement subtlety|
|Behavior under scrutiny|Attenuates gracefully as $n$ grows|Was largest in the smallest sample|

**The seven deadly sins, with named antidotes:** overfitting (→ regularization, honest effective $n$); multiple testing (→ § Multiple Hypothesis Testing); data snooping (→ pre-registration, Invariant 1); selection bias (→ report all trials — the Analysis Run Log's row count is the honest denominator); look-ahead bias (→ dual timestamps; the highest-consequence bug class in the system); survivorship bias (→ score all launched markets, not just clean resolutions); test-set reuse (→ the OOS window is protected by the pre-specified revisit rule; § Out-of-Sample Validation).

**The winner's-curse structure of detection.** Conditional on a disagreement being selected _because it was large_, its expected true value is smaller than observed — selection inflates. This applies at the observation level (shrink large disagreements; § Bayesian Approaches) and the strategy level (adjust reported performance for the search that produced it; § Multiple Hypothesis Testing). Any reported edge that has not been shrunk at the observation level and multiplicity-adjusted at the strategy level is an overestimate by construction.

---

## Multiple Hypothesis Testing

A scanner evaluating hundreds of brackets daily will, under the null, "find edge" constantly. Untreated, the system is a false-positive generator with a dashboard. The quantitative-finance literature converged on this as _the_ central methodological problem of strategy research; its machinery imports with one important adaptation noted below.

**Motivating results (analogy, not machinery).** Harvey, Liu & Zhu (2016) show that after the accumulated multiplicity of factor research, conventional $t > 2$ is meaningless and a newly discovered effect should clear roughly $t > 3$ — a threshold derived from _that literature's_ test count, which does not transfer numerically here. The Deflated Sharpe Ratio (Bailey & López de Prado, 2014) corrects an observed Sharpe for the number of trials and non-normality — derived for Sharpe ratios specifically; "deflate the score differential" is an analogy, not an available theorem. The companion result (Bailey, Borwein, López de Prado & Zhu, 2014) shows the probability of selecting an overfit strategy grows rapidly with trials even when each trial is honest. The transferable **principle** from all three: the evidential bar is a function of the number of looks, including looks by others and looks you forgot.

**Correction machinery, in order of increasing suitability here:**

- _Bonferroni / Holm:_ control family-wise error rate; conservative under dependence — safe, low-power.
- _Benjamini–Hochberg (1995):_ controls the false discovery rate — the right frame for a _screening_ stage where some false positives are tolerable because a validation stage follows.
- _Dependence-aware bootstrap procedures — the designated candidate mechanism for this project:_ White's Reality Check (2000) asks exactly the right question for a strategy scan — _what is the probability the best of my $m$ candidates performs this well under the null that none has skill?_ — and Hansen's SPA (2005) is its studentized, less-conservative refinement; Romano & Wolf (2005) provide the stepdown generalization (survey: Romano, Shaikh & Wolf, 2008). These respect the _dependence among test statistics_, which matters twice here: correlated candidate signals make Bonferroni needlessly brutal, and — the adaptation — the effective number of independent tests is _smaller_ than the nominal count under correlation, so independence-based inflation factors (the $\sqrt{2\ln m}$ growth of a null maximum) overstate the correction. The bootstrap procedures get this right automatically because they resample the joint distribution.

**The project's layered defense, as designed:**

1. **Pre-registration (Invariant 1)** — one falsifiable hypothesis, registration date bounding the OOS window: the cleanest correction is $m = 1$, enforced.
2. **The Analysis Run Log** — every exploratory look appends a row; when a result is reported, the honest multiplicity denominator is _the log's row count_, not the number of registered hypotheses. This is the governance answer to "looks you forgot."
3. **BH-FDR at the screening layer; Reality-Check/SPA-style bootstrap at any confirmation layer that ever evaluates multiple candidate signals** — candidate machinery for the eventual standing scanner, to be ratified by ADR before implementation.

```text
# Candidate scanner discipline (pseudocode, ADR-pending)
for each scan_day:
    candidates = screen(all_markets, liquidity_gate, |z| ranking)   # descriptive only
    log_row(scan_day, n_markets_scanned, n_candidates)              # multiplicity ledger
# no candidate is ever "edge"; candidates feed registered studies,
# whose multiplicity accounting starts from the ledger's row count
```

---

## Robustness Testing

A result that clears its registered test earns _candidate_ status; robustness testing is how it earns belief. Each probe is pre-registerable as part of the study design.

**Perturbation analysis.** Re-run the analysis across a grid of the arbitrary choices: score (log vs RPS), extraction timestamp (per Q2/Q5 options), liquidity-gate settings, clustering scheme, calibration method. A true effect attenuates smoothly; a false one lives in one cell. Report the full grid, not the best cell.

**Placebo and negative-control tests.**

- _Joint-null and no-difference simulations_ (§ Statistical Detection Methods): outcomes generated from $P_m$, from $P_f$, and from a no-difference null; the machinery should find nothing in the last, and the first two bound its behavior when one side is miscalibrated.
- _Scrambled assignment:_ score the model against outcomes from the wrong city or a date-shifted series; any "skill" is leakage or bug.
- _Lagged-model control:_ score yesterday's forecast against today's market; if the stale model "wins," the timestamp discipline has failed somewhere.

**Outcome-error stress.** The outcome series itself can be wrong (settlement mislabels, DST-window subtleties, station discrepancies). Rerun headline results excluding every city-day with any settlement-reconciliation discrepancy (A6's output); a result that depends on the discrepant days is a data artifact until proven otherwise. Mislabeled outcomes do not merely add noise — they can bias score differentials.

**Subsample stability.** Score differentials by city, by season, by price bucket (tails vs center), by liquidity tercile. A genuine calibration edge should be diffuse or concentrated where the _mechanism_ predicts (e.g., FLB-harvesting concentrates in tails — which is also where the model is weakest, so tail-concentrated skill gets _extra_ scrutiny, not less).

**Combinatorial and walk-forward validation.** Walk-forward (expanding or rolling window, strictly time-ordered) is the honest simulation of live use. López de Prado's (2018) combinatorial purged cross-validation generates multiple OOS paths while purging overlapping information — a useful supplement when a single walk-forward path leaves too little test data, with the caveat that its independence assumptions strain under strong date clustering.

**Cost-stress testing.** Recompute economic conclusions at pessimistic executions: full spread crossing, depth-limited fills, fee at the exact price. An edge that survives only at midpoint is a paper artifact (the exact R7 trap).

---

## Out-of-Sample Validation

**The hierarchy of evidence, ascending:**

1. In-sample fit — not evidence.
2. Cross-validated in-sample — weak evidence, vulnerable to look-ahead in design choices made after seeing the data.
3. **True out-of-sample: pre-registered, then scored on data that did not exist at registration** — the project's standard. The registration date bounds the OOS window; accrual after registration is untouchable by design decisions.
4. Live paper record (the M8 ledger) — OOS plus execution realism.
5. Live capital at small size — the only test of fills, slippage, and adverse selection.

**Rules that keep OOS honest.** The default discipline: an OOS window supports one registered verdict, and unregistered re-analysis of the same window is in-sample by definition. The _principled_ exceptions are exactly the pre-specified sequential designs of § Statistical Detection Methods — alpha-spending interim looks or anytime-valid e-processes declared **at registration**. What remains prohibited without exception: deciding after seeing OOS results to look again, re-run variants, or "check one more thing" on the same window. Deviations from registration are recorded in dated addenda written _before_ viewing affected results. A failed OOS test is a result — recorded, graded, hypothesis killed or revised.

**Sample-size realism.** A1's power analysis governs when the registered question is _decidable_: with date-clustered effective $n$ far below raw city-day counts — and with the few-clusters correction making early inference _more_ conservative, not less — months of accrual precede any verdict. Register early, score late. The alternative — scoring early on underpowered data — produces exactly the noisy, retractable findings the methodology exists to prevent.

---

## Expected Value vs Statistical Significance

Two orthogonal questions, both mandatory, neither sufficient:

- **Significance:** is the score differential distinguishable from zero? (Protects against believing noise.)
- **Economic value:** is the implied $\Delta_{\text{net}}$ large enough to matter after costs at executable size? (Protects against trading truths that don't pay.)

The four-quadrant discipline:

||Economically large|Economically negligible|
|---|---|---|
|**Statistically significant**|Candidate finding → robustness gauntlet|True but useless (common for microstructure effects; Harvey–Liu–Zhu make the same point for factors — significance ≠ premium worth trading)|
|**Not significant**|_Dangerous quadrant_: big point estimate, wide interval — the sample is too small; accrue, don't trade|Nothing|

Two standing rules. First, report **effect sizes with intervals**, never bare p-values: the deliverable is "the model's log-score advantage is $X$ nats/city-day, 95% CI $[a, b]$, implying $Y$ points of gross edge before costs," not a star count. Second, the _decision-relevant_ quantity is the shrunk, multiplicity-adjusted, cost-adjusted expected net edge — significance is a gate, not the objective. A strategy can clear $p < 0.05$ and still have negative expected log-growth after fees; the fee arithmetic, not the p-value, decides whether V3's entry condition is ever met.

---

## Risk Adjusted Edge

Raw expected value ignores that the same EV at higher variance compounds worse and draws down deeper.

**The log-growth frame (native to this project).** For a Kelly-fraction bettor, expected log-growth already _is_ a risk-adjusted quantity — variance enters with a negative sign. For a single binary bet at fraction $f$ of bankroll on YES at price $p$ with believed probability $q$:

$$g(f) = q\ln!\big(1 + f,\tfrac{1-p}{p}\big) + (1-q)\ln(1-f),$$

maximized at the Kelly fraction $f^* = \frac{q - p}{1 - p}$. Estimation error in $q$ makes full Kelly systematically over-bet — the growth penalty for overestimating edge exceeds the penalty for underestimating it — hence **fractional Kelly** (½ or less) as the standard prescription (MacLean, Thorp & Ziemba, 2011). The fraction is a pre-registered policy choice, and all sizing is **gated behind validated edge and V3**; the mathematics is recorded here because _risk-adjusted ranking_ uses it before any trade exists.

**Uncertainty enters as a lower confidence bound — the proper home of the penalty.** The candidate object for ranking and for the V3 gate is not the point estimate $\hat{\Delta}_{\text{net}}$ but a _penalized_ version: the shrunk (§ Bayesian Approaches), multiplicity-adjusted (§ Multiple Hypothesis Testing) estimate minus a multiple of its standard error — equivalently, a lower confidence bound on net edge. Acting on the lower bound rather than the point estimate is the sizing-level analogue of the deflation principle, and it replaces any ad-hoc penalty term inside the EV arithmetic.

**Drawdown and ruin as constraints, not objectives.** Even positive-growth strategies experience long losing sequences; with ~150 city-days/month and clustered outcomes, a bad synoptic week is a correlated loss across the whole book. Position limits per city-day and per date (not just per market) follow directly from the correlation structure Q3 measures. Risk-adjusted edge without a correlation-aware exposure cap is an incomplete number.

---

## Practical Trading Considerations

All V3-gated; recorded now because data requirements (bid/ask, depth, trade-level maker/taker flags, fee-schedule versions) must be collected from day one even though trading is distant.

**Cost stack, itemized.** Half-spread at entry (and exit, if not held to settlement); Kalshi's price-dependent fee computed at the actual price (steepest, proportionally, for cheap contracts — compounding the FLB trap of buying longshots); adverse selection (fills arrive disproportionately when the counterparty is right — on _both_ aggressive and passive orders); opportunity cost of capital locked to settlement.

**Execution posture — an open question, honestly stated.** The Kalshi maker/taker evidence establishes that transaction mode is a first-order determinant of realized returns for the average participant (§ Behavioral Sources, with verification flag). It does not settle the posture for an informed trader: passive orders save the spread but bear adverse selection on fills; aggressive orders pay the spread but choose their moments. The eventual V3 execution-cost model must estimate both terms _for this project's own order flow_ — a registered empirical question, with the trade-level data capture it requires flagged as a collection-scope decision now.

**Capacity realism.** Weather brackets are small markets; a strategy's capacity is bounded by depth at prices where edge survives. This is not a defect for a measurement-first lab — but it caps the economic prize and therefore the rational engineering spend (the Grossman–Stiglitz-inspired budgeting check of § Why Edge Exists, applied to the project itself).

**Settlement mechanics as edge protection.** Positions settle against the NWS Daily Climate Report for a named station in local standard time; station verification (M1b gate) and settlement reconciliation (A6) are what keep the _outcome_ variable trustworthy — and what the outcome-error stress test (§ Robustness Testing) audits. A perfect detector scored against a wrong outcome series is worse than no detector.

---

## Engineering Implications for an Automated Trading System

Component architecture, mapped to the roadmap; only the V1 rows should exist near-term.

|Component|Purpose|Stage|Load-bearing requirements|
|---|---|---|---|
|Market Scanner / Collector|Enumerate and capture all brackets, 5 cities|V1|Append-only; dual timestamps; **bid/ask + depth + volume + trade-level maker/taker flags captured** (unresolved load-bearing claim: current collectors' capture of bid/ask and full issuance history is unverified); fee-schedule version recorded|
|Forecast Collector|NWS issuance history|V1|**Non-backfillable — highest accrual urgency in the project**; every run timestamped at ingestion|
|Prediction Ledger / Learning System|Record every $P_f$, $P_m$, outcome; score on resolution|V1|The instrument's memory and the philosophical core — without it, no population, no edge in the defined sense|
|Probability Engine|$P_f$ with honest $\sigma_f$|V2|Seasonal residual models per station/lead-time (A2), EMOS/BMA-class ensemble post-processing; explicit tail policy; rank-histogram diagnostics; post-hoc recalibration on held-out city-days|
|Edge Detection Engine|Standardized (covariance-aware), net disagreement; triage queue|V2|Implements § Measuring Edge; every look logged to the Analysis Run Log|
|Statistical Validation layer|Ladder-level score differentials; HLN-corrected tests; wild cluster bootstrap below A1's cluster threshold; block bootstrap; null-simulation suite|V2|A1's conventions; regeneration-checked (fire drill)|
|Ranking Engine|Order qualifying opportunities by penalized (lower-bound) expected log-growth|V3|Downstream of validation, never a substitute for it|
|Execution Engine|Order placement under an empirically estimated cost model (spread vs adverse-selection trade-off)|V3|Microstructure as cost model, not alpha; posture is a registered question, not a default|
|Monitoring / Alerting|Every job fails loudly|V1→M9|An instrument that degrades silently keeps emitting numbers; alerting-vs-accrual sequencing is a flagged open risk (TDD-001)|

**Cross-cutting engineering invariants:**

1. **Dual timestamps everywhere.** Look-ahead leakage is the highest-consequence bug class; every price, forecast, and feature carries event time and ingestion time, and every comparison joins on availability, not occurrence.
2. **Append-only with natural keys.** Corrections are new rows, never updates; idempotent re-runs produce no duplicates; "no data today" is distinguishable from "collector gap" (the gap-audit job's reason for existing).
3. **The detector writes to a queue, not a trade blotter.** Divergence events feed triage (A7); nothing downstream of an unresolved triage item.
4. **Provenance on every number.** Environment hash, code version, and registration link on every score row (Invariant 2: no orphan findings).
5. **Multiplicity is infrastructure.** The Analysis Run Log is a first-class table, not a habit.

---

## Common Mistakes

1. **Calling a price difference an edge.** $\Delta$ is a disagreement; edge is a validated population property. The vocabulary discipline is the error's vaccine.
2. **$\sigma_f$ from ensemble spread alone.** Understates uncertainty, overstates skill; verify spread honesty with rank histograms before believing any $z$.
3. **Ignoring the error correlation $\rho$ between model and market.** Both consume the same NWS information; the independence denominator is wrong by construction.
4. **Trading the tails where both model and market are worst.** FLB concentrates at low prices; so does the model's fabricated-tail risk. Largest disagreements ≠ best opportunities.
5. **Midpoint P&L.** Paper edge that evaporates at executable prices — cost-stress every economic claim, and state EV at the ask/bid, not the midpoint.
6. **Treating transaction mode as free.** Spread-crossing and adverse selection on resting orders are both first-order costs on this venue; neither posture is a free default.
7. **Uncorrected scanning.** Hundreds of daily tests at $\alpha = 0.05$ is a false-positive factory; the threshold must know the scan size — including the _forgotten_ looks in the Analysis Run Log.
8. **Naive cluster-robust inference on few clusters.** Anti-conservative exactly when the sample is smallest; wild cluster bootstrap below A1's threshold.
9. **Test-set necromancy.** Unregistered re-analysis of a spent OOS window; re-running variants until one passes.
10. **Leakage via timestamps.** Scoring prices against forecasts the market hadn't seen (or vice versa); the lagged-model placebo exists to catch this.
11. **Confusing convergence with skill.** Prices mechanically approach 0/1 near settlement; "the market got sharper" is not edge.
12. **Pooling across regimes.** Fee changes, participant shifts, and seasonal structure make pooled estimates stale-weighted; report by period.
13. **Optimizing an improper metric.** Tuning to ECE or a skill score directly invites gaming; optimize proper scores, report diagnostics (CORP reliability diagrams, multiple-binning ECE).
14. **Full Kelly on estimated probabilities.** Estimation error makes it systematically over-bet; fractional Kelly is the floor of prudence, and all sizing is V3-gated regardless.
15. **Building execution before the ledger.** A car before the odometer; the Learning System is the core, not the Execution Engine.

---

## Open Research Questions

This document does **not** create a parallel register. The canonical register is [[Open Questions]] (Q1–Q7); mappings and new candidates below (candidates are for architect entry, not self-registration).

**Canonical questions this document depends on:**

- **Q1** — market calibration / FLB in Kalshi weather brackets. _Updated context:_ Bürgi–Deng–Whelan establishes FLB on Kalshi pooled across categories (verification-flagged effect sizes); Q1 now asks whether it survives in short-dated, fundamentals-driven weather brackets — a horizon outside the Page–Clemen sample's support. Direction prior: longshots overpriced. Magnitude: unknown. Pre-registration unaffected; the price-bucket analysis should be pre-specified in Q1's registration.
- **Q2** — market-forecast extraction rule and its dispersion measure $\sigma_m$ (owned by A4); $z$ is formally undefined until it resolves.
- **Q3** — cross-city/cross-day correlation → effective sample size behind all inference here; the model–market error correlation $\rho$ (§ Measuring Edge) is a closely related empirical target and should be estimated in the same program.
- **Q4** — archive usability; determines A2's residual depth and hence the credibility of $\sigma_f$ (and thereby every $z$ in this document).
- **Q5** — calibration vs time-to-settlement; literature-adjacent (Page & Clemen 2013) but unanchored at daily horizons.
- **Q6** — efficiency drift; literature-anchored (McLean–Pontiff decay dynamics; Cowgill–Zitzewitz experience effects; Bürgi–Deng–Whelan's diminishing-bias finding).
- **Q7** — quote staleness bias; the liquidity-artifact confounder throughout.

**New candidates surfaced by this document:**

- _Candidate:_ Market incorporation speed of new NWS runs — drift from pre-run price to post-run fair value (sharper Q5; theoretically anchored in Ottaviani–Sørensen underreaction; the most tractable weather-specific hypothesis).
- _Candidate:_ Honest $\sigma_f$ decomposition for the model rung (ensemble + structural + calibration components; feeds A2) **and** the model–market error correlation $\rho$ (feeds A1's power analysis); without both, § Measuring Edge has no credible denominator.
- _Candidate:_ Which candidate signals survive Kalshi's price-dependent fees and spreads at executable depth (net-disagreement; overlaps A4's cost band).
- _Candidate:_ Does Kalshi's pooled FLB replicate in weather brackets specifically, and at what magnitude relative to pooled categories? (A refinement of Q1's analysis plan, not a new question.)
- _Candidate:_ Empirical execution-cost decomposition for this project's own order flow — spread paid on aggressive orders vs adverse selection borne on passive fills (requires trade-level and maker/taker data capture: a collection-scope decision with accrual urgency).

---

## References

Peer-reviewed and working-paper sources. **All E4 until human-verified per Invariant 3.** Entries are pointers for Lit-note verification, grouped by area, alphabetical within group.

**Prediction markets & efficiency**

- Arrow, K. et al. (2008). "The Promise of Prediction Markets." _Science_, 320.
- Atanasov, P., Rescober, P., Stone, E., Swift, S., Servan-Schreiber, E., Tetlock, P., Ungar, L. & Mellers, B. (2017). "Distilling the Wisdom of Crowds: Prediction Markets vs. Prediction Polls." _Management Science_, 63(3).
- Berg, J., Forsythe, R., Nelson, F. & Rietz, T. (2008). "Results from a Dozen Years of Election Futures Markets Research." _Handbook of Experimental Economics Results._
- Bürgi, C., Deng, W. & Whelan, K. (2025). "Makers and Takers: The Economics of the Kalshi Prediction Market." CESifo Working Paper / UCD WP2025_19; revised version circulated as GWU WP 2026-001. Cite and verify against a specific version.
- Cowgill, B. & Zitzewitz, E. (2015). "Corporate Prediction Markets: Evidence from Google, Ford, and Firm X." _Review of Economic Studies_, 82(4).
- Erikson, R. & Wlezien, C. (2008). "Are Political Markets Really Superior to Polls as Election Predictors?" _Public Opinion Quarterly_, 72(2).
- Manski, C. (2006). "Interpreting the Predictions of Prediction Markets." _Economics Letters_, 91.
- Page, L. & Clemen, R.T. (2013). "Do Prediction Markets Produce Well-Calibrated Probability Forecasts?" _Economic Journal_, 123(568), 491–513.
- Rhode, P. & Strumpf, K. (2004). "Historical Presidential Betting Markets." _JEP_, 18(2).
- Wolfers, J. & Zitzewitz, E. (2004). "Prediction Markets." _JEP_, 18(2).
- Wolfers, J. & Zitzewitz, E. (2006). "Interpreting Prediction Market Prices as Probabilities." NBER WP 12200.

**Favorite–longshot bias & behavioral**

- Golec, J. & Tamarkin, M. (1998). "Bettors Love Skewness, Not Risk, at the Horse Track." _JPE_, 106(1).
- Griffith, R.M. (1949). "Odds Adjustments by American Horse-Race Bettors." _Am. J. Psychology_, 62.
- Ottaviani, M. & Sørensen, P. (2008). "The Favorite–Longshot Bias: An Overview of the Main Explanations." In _Handbook of Sports and Lottery Markets._
- Snowberg, E. & Wolfers, J. (2010). "Explaining the Favorite–Longshot Bias: Is It Risk-Love or Misperceptions?" _JPE_, 118(4).
- Thaler, R. & Ziemba, W. (1988). "Anomalies: Parimutuel Betting Markets." _JEP_, 2(2).

**Market efficiency theory & persistence**

- Fama, E. (1970). "Efficient Capital Markets: A Review of Theory and Empirical Work." _J. Finance_, 25(2).
- Grossman, S. & Stiglitz, J. (1980). "On the Impossibility of Informationally Efficient Markets." _AER_, 70(3).
- Lo, A. (2004). "The Adaptive Markets Hypothesis." _J. Portfolio Management_, 30.
- McLean, R.D. & Pontiff, J. (2016). "Does Academic Research Destroy Stock Return Predictability?" _J. Finance_, 71(1).
- Shleifer, A. & Vishny, R. (1997). "The Limits of Arbitrage." _J. Finance_, 52(1).
- Timmermann, A. & Granger, C. (2004). "Efficient Market Hypothesis and Forecasting." _Int. J. Forecasting_, 20.

**Forecast verification & calibration (meteorological lineage)**

- Bröcker, J. & Smith, L.A. (2007). "Increasing the Reliability of Reliability Diagrams." _Weather and Forecasting_, 22.
- Dimitriadis, T., Gneiting, T. & Jordan, A. (2021). "Stable Reliability Diagrams for Probabilistic Classifiers." _PNAS_, 118(8). — CORP.
- Epstein, E.S. (1969). "A Scoring System for Probability Forecasts of Ranked Categories." _J. Applied Meteorology_, 8. — RPS.
- Gneiting, T., Balabdaoui, F. & Raftery, A. (2007). "Probabilistic Forecasts, Calibration and Sharpness." _JRSS-B_, 69.
- Gneiting, T. & Raftery, A. (2007). "Strictly Proper Scoring Rules, Prediction, and Estimation." _JASA_, 102.
- Gneiting, T., Raftery, A., Westveld, A. & Goldman, T. (2005). "Calibrated Probabilistic Forecasting Using Ensemble Model Output Statistics and Minimum CRPS Estimation." _Monthly Weather Review_, 133. — EMOS/NGR.
- Hamill, T. (1999). "Hypothesis Tests for Evaluating Numerical Precipitation Forecasts." _Weather and Forecasting_, 14. — inference under correlated weather samples; direct precedent for A1.
- Hamill, T. (2001). "Interpretation of Rank Histograms for Verifying Ensemble Forecasts." _Monthly Weather Review_, 129.
- Murphy, A. (1973). "A New Vector Partition of the Probability Score." _J. Applied Meteorology_, 12. — Brier decomposition.
- Murphy, A. & Winkler, R. (1987). "A General Framework for Forecast Verification." _Monthly Weather Review_, 115.
- Raftery, A., Gneiting, T., Balabdaoui, F. & Polakowski, M. (2005). "Using Bayesian Model Averaging to Calibrate Forecast Ensembles." _Monthly Weather Review_, 133.
- Wilks, D. _Statistical Methods in the Atmospheric Sciences._ Academic Press (current edition).

**Calibration & forecasting (statistical/ML lineage)**

- Baron, J., Mellers, B., Tetlock, P., Stone, E. & Ungar, L. (2014). "Two Reasons to Make Aggregated Probability Forecasts More Extreme." _Decision Analysis_, 11(2).
- Foster, D. & Vohra, R. (1998). "Asymptotic Calibration." _Biometrika_, 85.
- Guo, C., Pleiss, G., Sun, Y. & Weinberger, K. (2017). "On Calibration of Modern Neural Networks." _ICML._
- Kull, M., Silva Filho, T. & Flach, P. (2017). "Beta Calibration." _AISTATS._
- Mellers, B. et al. (2014). "Psychological Strategies for Winning a Geopolitical Forecasting Tournament." _Psychological Science_, 25(5).
- Mellers, B. et al. (2015). "Identifying and Cultivating Superforecasters as a Method of Improving Probabilistic Predictions." _Perspectives on Psychological Science_, 10(3).
- Minderer, M. et al. (2021). "Revisiting the Calibration of Modern Neural Networks." _NeurIPS._
- Naeini, M.P., Cooper, G. & Hauskrecht, M. (2015). "Obtaining Well Calibrated Probabilities Using Bayesian Binning." _AAAI._
- Niculescu-Mizil, A. & Caruana, R. (2005). "Predicting Good Probabilities with Supervised Learning." _ICML._
- Platt, J. (1999). "Probabilistic Outputs for Support Vector Machines." _Advances in Large Margin Classifiers._
- Satopää, V., Baron, J., Foster, D., Mellers, B., Tetlock, P. & Ungar, L. (2014). "Combining Multiple Probability Predictions Using a Simple Logit Model." _Int. J. Forecasting_, 30.
- Zadrozny, B. & Elkan, C. (2002). "Transforming Classifier Scores into Accurate Multiclass Probability Estimates." _KDD._

**Inference, multiple testing & backtest overfitting**

- Bailey, D. & López de Prado, M. (2014). "The Deflated Sharpe Ratio: Correcting for Selection Bias, Backtest Overfitting and Non-Normality." _J. Portfolio Management_, 40(5).
- Bailey, D., Borwein, J., López de Prado, M. & Zhu, Q.J. (2014). "Pseudo-Mathematics and Financial Charlatanism: The Effects of Backtest Overfitting on Out-of-Sample Performance." _Notices of the AMS_, 61(5).
- Benjamini, Y. & Hochberg, Y. (1995). "Controlling the False Discovery Rate." _JRSS-B_, 57.
- Cameron, A.C., Gelbach, J. & Miller, D. (2008). "Bootstrap-Based Improvements for Inference with Clustered Errors." _Review of Economics and Statistics_, 90(3). — wild cluster bootstrap.
- Clark, T. & West, K. (2007). "Approximately Normal Tests for Equal Predictive Accuracy in Nested Models." _J. Econometrics_, 138.
- Diebold, F. (2015). "Comparing Predictive Accuracy, Twenty Years Later: A Personal Perspective on the Use and Abuse of Diebold–Mariano Tests." _JBES_, 33(1).
- Diebold, F. & Mariano, R. (1995). "Comparing Predictive Accuracy." _JBES_, 13.
- Efron, B. (2010). _Large-Scale Inference: Empirical Bayes Methods for Estimation, Testing, and Prediction._ Cambridge.
- Efron, B. & Morris, C. (1975). "Data Analysis Using Stein's Estimator and Its Generalizations." _JASA_, 70.
- Giacomini, R. & White, H. (2006). "Tests of Conditional Predictive Ability." _Econometrica_, 74(6).
- Hansen, P.R. (2005). "A Test for Superior Predictive Ability." _JBES_, 23.
- Harvey, C., Leybourne, S. & Newbold, P. (1997). "Testing the Equality of Prediction Mean Squared Errors." _Int. J. Forecasting_, 13. — small-sample DM correction.
- Harvey, C., Liu, Y. & Zhu, H. (2016). "…and the Cross-Section of Expected Returns." _Review of Financial Studies_, 29(1).
- López de Prado, M. (2018). _Advances in Financial Machine Learning._ Wiley.
- MacKinnon, J. & Webb, M. (2017). "Wild Bootstrap Inference for Wildly Different Cluster Sizes." _J. Applied Econometrics_, 32.
- Politis, D. & Romano, J. (1994). "The Stationary Bootstrap." _JASA_, 89.
- Ramdas, A., Grünwald, P., Vovk, V. & Shafer, G. (2023). "Game-Theoretic Statistics and Safe Anytime-Valid Inference." _Statistical Science_, 38(4).
- Romano, J., Shaikh, A. & Wolf, M. (2008). "Formalized Data Snooping Based on Generalized Error Rates." _Econometric Theory / Test_ survey lineage.
- Romano, J. & Wolf, M. (2005). "Stepwise Multiple Testing as Formalized Data Snooping." _Econometrica_, 73.
- West, K. (1996). "Asymptotic Inference About Predictive Ability." _Econometrica_, 64.
- White, H. (2000). "A Reality Check for Data Snooping." _Econometrica_, 68.

**Microstructure & sizing**

- Bernard, V. & Thomas, J. (1989). "Post-Earnings-Announcement Drift: Delayed Price Response or Risk Premium?" _J. Accounting Research_, 27.
- Easley, D., Kiefer, N., O'Hara, M. & Paperman, J. (1996). "Liquidity, Information, and Infrequently Traded Stocks." _J. Finance_, 51. — PIN.
- Glosten, L. & Milgrom, P. (1985). "Bid, Ask and Transaction Prices in a Specialist Market with Heterogeneously Informed Traders." _JFE_, 14.
- Kyle, A. (1985). "Continuous Auctions and Insider Trading." _Econometrica_, 53.
- MacLean, L., Thorp, E. & Ziemba, W. (2011). _The Kelly Capital Growth Investment Criterion._ World Scientific.
- Ottaviani, M. & Sørensen, P. (2015). "Price Reaction to Information with Heterogeneous Beliefs and Wealth Effects: Underreaction, Momentum, and Reversal." _AER_, 105(1).
- Sandås, P. (2001). "Adverse Selection and Competitive Market Making: Empirical Evidence from a Limit Order Market." _RFS_, 14(3).
- Tetlock, P.C. (2008). "Liquidity and Prediction Market Efficiency." Working paper / SSRN.