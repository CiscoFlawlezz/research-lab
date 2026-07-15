# Forecast Verification — Research Synthesis

**Vault location:** `07 References/Concepts` **Level:** Quantitative researcher reference (assumes probability theory, statistical inference, basic information theory) **Cross-links:** [[Proper Scoring Rules and Calibration - Technical Reference (V2)]] · [[Brier Decomposition - Worked Example]] · [[Effective Sample Size]] · [[Edge Detection]] · [[Prediction Markets]] · [[Log Score and Kelly Identity — Technical Reference (V2)]] · [[Kelly Criterion]] · [[Expected Value]] · [[Bayesian Statistics]] · [[Probability]] · [[National Weather Service]] · [[NOAA]] · [[Kalshi Ticker Anatomy and Market Structure]] · [[Kalshi API]] · [[Open Questions]] · [[Pre-Registered Experiment Template]] · [[Glossary]] **Status:** Version 2 (adversarial-review rewrite) — draft, ungraded pending Architect verification (Invariant 3) **Created:** 2026-07-08 (V1) · **Revised:** 2026-07-08 (V2)

> [!info] Version history **V2 (this document)** supersedes V1 entirely following adversarial peer review. Principal changes: the log-score boundary problem is now treated as a first-class unresolved design decision (§9.5); the likelihood connection of scoring is restored (§9.3); the Schervish representation and Murphy diagrams unify scoring with decision theory (§9.4, §18); the forecaster's dilemma joins the failure-mode canon (§14.7, §16.2, §19); the odds-normalization literature is surfaced for A4 (§15.8); rare-event, observation-error, and multivariate verification added (§14.5–14.7); §17 gains explicit power arithmetic; §21 rebuilt as numbered engineering directives; bibliography reorganized and expanded. Where V2 and V1 disagree, V2 governs; V1 should be deleted, not archived alongside (single-source rule).

> [!warning] Epistemic status (Invariant 3) This document is AI-drafted testimony, not evidence. Every bibliographic citation was produced from model knowledge without live retrieval and **must be independently verified (title, year, venue, page-level claims) before any statement here is cited as load-bearing in a registration or ADR**. Lower-confidence citations carry ⚑ per house convention; ★ marks the priority verification tier (entries directly feeding A-series decisions). The synthesis of _ideas_ is believed faithful to the literature; bibliographic metadata is the most fragile layer. Where this note and any ratified A-series document disagree, the A-series document governs.

---

## 1. Purpose of Forecast Verification

### 1.1 Why forecasts must be verified

A forecast is a claim about the future issued before the future is observed. Absent verification, forecast systems accumulate three pathologies documented across meteorology, economics, and judgment research: (i) **unfalsifiability drift** — vague or hedged forecasts no outcome can contradict; (ii) **selective memory** — issuers and consumers recall hits and forget misses (Fischhoff's hindsight-bias program; Tetlock's _Expert Political Judgment_, in which expert confidence exceeded accuracy across two decades of recorded forecasts; the Good Judgment Project's tournament results, Mellers et al. 2014, showing that disciplined scoring plus feedback measurably improves forecasters); and (iii) **incentive corruption** — under improper evaluation metrics, forecasters are rewarded for reporting something other than their beliefs (§9.2).

Verification replaces narrative with measurement. Its foundational modern statement is Murphy and Winkler (1987): verification is the analysis of the **joint distribution of forecasts and observations**, $p(f, x)$. Every verification statistic is a functional of this joint distribution or its factorizations (§3.1). This **distributions-oriented** framing subsumes the older measures-oriented approach and explains why single-number verification is always lossy: even the binary–binary joint distribution has three free parameters; a probabilistic forecast of a continuous outcome has infinitely many (Murphy 1991 on dimensionality). One number cannot be sufficient — hence the apparatus of decompositions (§10), diagrams (§11–§13), and score families (§9) rather than a single grade.

### 1.2 Scientific philosophy

Verification operationalizes falsifiability for probabilistic claims — with an asymmetry that structures this entire Lab. A deterministic forecast is refuted by one contrary outcome. A probability is refuted by **no** single outcome: a 90% forecast followed by non-occurrence is consistent with perfect calibration at frequency one-in-ten. Probabilistic forecasts are therefore testable **only at the population level**, against sequences of forecast–outcome pairs (Dawid 1982, 1984). This is the load-bearing idea of the Lab's architecture ([[Research Methodology v2]]; Spec §2): _measurement precedes edge because probabilities validate only in aggregate._

Two philosophical traditions coexist and should not be conflated:

- **Frequentist-operational** (dominant in meteorology): calibration is an observable long-run property of the forecast–outcome sequence; verification estimates it.
- **Subjectivist-coherentist** (de Finetti 1974; Savage 1954; Dawid 1982): probabilities are degrees of belief; verification asks whether the belief-generating mechanism is empirically well-calibrated even though each probability is a personal commitment. Dawid (1982) showed a coherent Bayesian _expects_ to be calibrated; impossibility results (Oakes 1985 ⚑) show no deterministic forecaster is guaranteed calibration against all sequences; Foster and Vohra (1998) showed asymptotic calibration is achievable by randomized forecasters _with no knowledge of the process_ — the theorem behind the standing rule that calibration alone is nearly free and never sufficient (§4.2).

A market price sits interestingly across both traditions: operationally it is a number to be verified like any forecast; interpretively it is an aggregate of subjective commitments backed by money (§15.1). The Lab's stance — the market is a forecaster, not an oracle — is the operational tradition applied without exemption.

### 1.3 Decision theory

Verification is ultimately justified by decisions: a forecast has value only insofar as some decision-maker acts differently, and better, because of it. The canonical bridge is the **cost–loss model** (Thompson 1952 ⚑; Murphy 1977; Katz and Murphy 1997): a decision-maker with protection cost $C$ and potential loss $L$ acts when forecast probability $p > C/L$; forecast value is the expected-expense reduction across users with different $C/L$. Richardson (2000) connected this to probabilistic verification (potential economic value curves, §18.2). Two deeper unifications now exist and are developed in §9.4 and §18.3: the **Schervish representation** — every proper score for binary events is a mixture of elementary cost–loss problems — and the **Kelly–log-score identity**, under which the log score is exactly the utility of a growth-optimal bettor. Verification theory and decision theory are not adjacent fields; they are two coordinate systems on the same object.

### 1.4 Forecast quality versus forecast value

Murphy (1993) distinguishes three types of goodness:

1. **Consistency (Type 1):** correspondence between the forecaster's judgment and the issued forecast — made incentive-compatible by strictly proper scoring (§9.2).
2. **Quality (Type 2):** correspondence between forecasts and observations — §3–§14.
3. **Value (Type 3):** incremental benefit to decision-makers — §18.

Quality and value are monotonically linked only in restricted senses (Murphy and Ehrendorfer 1987 ⚑): dominance in the sufficiency ordering (§6.3) implies weakly higher value for _every_ rational user, but a better scalar score does **not** guarantee higher value for a _given_ user, because users weight different regions of the joint distribution — made exact by the Schervish/Murphy-diagram machinery (§9.4). For this Lab: a model that Brier-dominates the market can still lose money if its advantage lives in brackets where spreads exceed the divergence; quality–value slippage is precisely what V2's paper ledger measures (Spec §9), and the ladder _scores → skill → cost-adjusted skill → paper P&L_ is a sequence of increasingly value-like measurements, each falsifiable against the previous.

### 1.5 Verification versus validation

This vault fixes the terminology as follows. **Verification**: ongoing empirical comparison of issued forecasts against subsequent observations — this document. **Validation**: the broader assessment that a system is fit for purpose — code correctness, data integrity, settlement reconciliation. The Lab validates in strict order: _instruments, then forecasts, then edge claims_ (Spec §11) — scoring code against worked examples before first use; the outcome variable continuously via settlement reconciliation; only then do verification statistics mean anything. The simulation-modeling literature sometimes reverses the two words; translate when reading it.

### 1.6 Historical development

In 1884 Sergeant J.P. Finley published tornado forecasts claiming 96.6% accuracy; Gilbert (1884) observed that _never forecasting a tornado_ would have scored 98.2%. The ensuing "Finley affair" produced within a few years most of the 2×2 contingency-table apparatus still in use — Gilbert's ratio of verification (the threat score), Peirce's (1884) $H - F$ skill score, Doolittle's association measure, Heidke's (1926 ⚑) chance-corrected score — and its moral is permanent: **raw accuracy without a reference is meaningless; skill is always relative to a baseline** (Murphy 1996 reviews the affair). This is the reference ladder's charter.

Subsequent milestones: Brier (1950) introduced the quadratic probability score; Sanders (1963) and Murphy (1972, 1973) developed its partition into reliability, resolution, and uncertainty; Murphy and Winkler (1987) unified the field under the joint-distribution framework; Talagrand, Anderson, and Hamill (mid-1990s–2001) built ensemble verification; Gneiting and Raftery (2007) consolidated proper-score theory; Gneiting, Balabdaoui, and Raftery (2007) stated the modern paradigm — **maximize sharpness subject to calibration**; Schervish (1989) and Ehm, Gneiting, Jordan, and Krüger (2016) supplied the decision-theoretic representation and its graphical form; Dimitriadis, Gneiting, and Jordan (2021) resolved the binning instability of reliability diagrams (CORP). The machine-learning community rediscovered calibration circa 2015–2017 (Guo et al. 2017) with partially independent vocabulary, now converging back toward the meteorological canon; conformal prediction (Vovk, Gammerman, and Shafer 2005) developed distribution-free coverage guarantees in parallel (§22).

---

## 2. Forecast Types

Verification methods are type-specific; applying a method to the wrong type produces numbers without meaning. Taxonomy follows Jolliffe and Stephenson (2012) and Wilks (2019, ch. 9).

**Deterministic (point) forecasts.** A single value: "high of 101°F." Verified by error statistics (ME, MAE, RMSE) and, categorized, by contingency tables. A subtlety with direct project relevance: the optimal point summary of a predictive distribution depends on the scoring function — the mean is optimal for squared error, the median for absolute error, a quantile for the corresponding pinball loss (Gneiting 2011 on _consistent_ scoring functions; Ehm et al. 2016 for their Choquet representations). NWS point temperature forecasts are point summaries of an implicit distribution; A2's task is to reconstruct a defensible distribution around them, and the choice of which functional the NWS point forecast _is_ (mean? median? mode of guidance?) is itself an empirical question for A2 ⚑.

**Probabilistic forecasts.** A probability (binary) or distribution (general) over outcomes; verified by proper scores, calibration diagnostics, and discrimination measures — this document's central subject.

**Categorical forecasts.** _Binary_: the 2×2 table and its derived measures (§7–§8). _Multi-category_: $K \times K$ tables; when categories are **ordered**, scores must respect the ordering (RPS) rather than treating categories as exchangeable. Kalshi bracket ladders are ordered multi-category structures; per-bracket Brier discards the ordering, RPS retains it.

**Continuous forecasts.** Real-valued outcomes; verified as points (error statistics) or distributions (CRPS, PIT).

**Ensemble forecasts.** A finite sample ${x_1, \dots, x_m}$ standing for a predictive distribution; verified by rank histograms (§12), fair/adjusted scores correcting finite-membership bias (Ferro, Richardson, and Weigel 2008 ⚑), and spread–error relationships. Not a V1 input; the designated V2 path to a genuinely probabilistic model rung.

**Threshold / exceedance forecasts.** $\Pr(X > t)$ for fixed $t$ — exactly Kalshi `T###` contracts; a bracket ladder is a differenced family of exceedances. Verification across all thresholds recovers the distribution and connects to CRPS: $$\mathrm{CRPS}(F, y) = \int_{-\infty}^{\infty} \big(F(t) - \mathbf{1}{y \le t}\big)^2 , dt = \int_{-\infty}^{\infty} \mathrm{BS}_t , dt.$$

**Prediction intervals.** (interval, nominal coverage) pairs; verified jointly and properly by the interval (Winkler) score: for a central $(1-\alpha)$ interval $[l, u]$, $$S_\alpha(l, u; y) = (u - l) + \tfrac{2}{\alpha}(l - y)\mathbf{1}{y < l} + \tfrac{2}{\alpha}(y - u)\mathbf{1}{y > u}$$ (Winkler 1972 ⚑; Gneiting and Raftery 2007 §6). A market bid–ask pair on a bracket is usefully read as an interval statement rather than a point probability (§15.4).

**Full distribution forecasts.** The maximal object $F$; verified by CRPS, log score, PIT (§13). The Lab's rungs emit discrete distributions over bracket partitions, so the natural scores are RPS (discrete CRPS) and the multicategory log score.

**Multivariate forecasts.** Joint distributions over vectors — five cities' highs on one day are one draw from a joint distribution, not five independent draws. Proper multivariate scores exist (energy score, Gneiting and Raftery 2007; variogram score, Scheuerer and Hamill 2015), with multivariate rank-histogram analogues (Gneiting et al. 2008 ⚑). V1 scores cities marginally and handles dependence at the _inference_ layer (date clustering, §17.3); multivariate scoring is the correct tool if cross-city structure itself ever becomes the research object (§22).

The type hierarchy matters because information is ordered: a distribution forecast implies every derived interval, exceedance, and point forecast, but not conversely. Verify at the richest type actually issued; verifying a distribution only through one derived binary event discards most of its content.

---

## 3. The Joint Distribution and the Attributes of Good Forecasts

### 3.1 The two factorizations

Murphy and Winkler (1987) factor the joint distribution two ways, and the entire attribute vocabulary falls out of the conditionals:

$$p(f, x) = \underbrace{p(x \mid f),p(f)}_{\text{calibration–refinement}} = \underbrace{p(f \mid x),p(x)}_{\text{likelihood–base rate}}.$$

The **calibration–refinement** factorization conditions on the forecast: $p(x \mid f)$ carries calibration (does reality agree with the stated probability?) and resolution (do the conditionals differ across forecasts?); $p(f)$ — the refinement or sharpness distribution — carries how boldly the forecaster speaks. The **likelihood–base-rate** factorization conditions on the observation: $p(f \mid x)$ carries discrimination (do forecasts differ between event and non-event cases?); $p(x)$ is the climatological difficulty of the game. Every attribute below is a functional of one of these factorizations, and every diagnostic in §10–§13 is an estimate of one of these conditionals. The two views are equivalent in population but their finite-sample estimates can disagree — the reason §7's ROC and §4's reliability can tell different stories on the same data.

### 3.2 The attributes

Let $p$ be the issued probability, $y \in {0,1}$ the outcome, $\bar o = \Pr(y{=}1)$ the base rate.

**Bias (unconditional).** $\mathbb{E}[f] - \mathbb{E}[x]$; for probabilities, $\bar p - \bar o$ or the frequency-bias ratio. Unconditional unbiasedness coexists with severe conditional miscalibration (compensating errors). §8.

**Calibration / reliability (conditional bias).** $\mathbb{E}[y \mid p = \pi] = \pi$ for all issued $\pi$: stated probabilities mean what they say. §4.

**Sharpness.** Concentration of $p(f)$ alone — no outcomes involved. §5.

**Resolution.** $\mathbb{E}_f\big[(\mathbb{E}[y \mid f] - \bar o)^2\big]$: how much the forecast _sorts reality_. Sharpness ratified by outcomes. §6.

**Discrimination.** Separation of $p(f \mid y{=}1)$ from $p(f \mid y{=}0)$ — ROC analysis and the discrimination diagram. §7.

**Accuracy.** Average case-level correspondence — Brier, log score, MAE. Scalar accuracy aggregates several attributes; the decompositions (§10) exhibit the arithmetic.

**Skill.** Accuracy relative to a reference, $\mathrm{SS} = 1 - S/S_{\mathrm{ref}}$ (negatively oriented $S$). The only honest headline number, because raw accuracy is dominated by predictand difficulty (the Finley lesson; the pooling trap, §14.4). Standing cautions: skill scores of proper scores are generally **not themselves proper** (Murphy 1973; Gneiting and Raftery 2007 §2.3) — report, never optimize; and skill differentials require dependence-aware inference (§17).

**Association.** Correlation between forecast and observation; diagnostic only (invariant to bias and scale error).

**Consistency (Murphy Type 1).** Enforced structurally by strictly proper scoring; in this Lab additionally by the absence of any reward for shading — the Prediction Ledger records, it does not pay.

**Information-set placement** (post-Murphy). A forecaster is only as good as its information set, and comparisons across nested information sets have known structure: with proper scoring, an ideal forecaster on a larger information set weakly dominates one on a smaller set, but _miscalibrated_ use of more information can score worse (Holzmann and Eulert 2014 ⚑). Lab relevance: the market's information set nominally contains the model's (traders can read NWS); a model victory therefore implies the market is either mis-aggregating or not attending — two different phenomena with different durabilities ([[Edge Detection]]).

**Robustness and stability.** Robustness: conclusions persist under perturbation of arbitrary analysis choices (score, binning, extraction rule) — the perturbation grid. Stability: quality is stationary across regimes; non-stationarity makes population-level verification a moving target (§15.7, §19).

**Actionability / economic value.** §18; operationalized here by the Kelly identity plus executable-price cost modeling.

The attributes are separately diagnosable, and the diagnosis matters because remedies differ: miscalibration is repaired by recalibration without new information; resolution deficits are repaired only by information. A model losing to the market on reliability has a statistics problem; on resolution, an information problem — the axis on which [[Edge Detection]]'s durability taxonomy is built.

---

## 4. Calibration

### 4.1 Definition and variants

For a binary forecaster issuing $p_i$ against events $y_i$, **calibration (reliability)** is $$\mathbb{E}[,y \mid p = \pi,] = \pi \quad \text{for all issued } \pi.$$ For predictive distributions of continuous outcomes, Gneiting, Balabdaoui, and Raftery (2007) distinguish three modes: **probabilistic calibration** (PIT values uniform — the practically testable mode, §13), **exceedance calibration** (every threshold hit with claimed frequency), and **marginal calibration** (average predictive CDF equals the empirical outcome CDF — the weakest mode, matching climate without matching cases). The modes form a partial order and GBR construct forecasters exhibiting each without the others: a calibration claim must state its mode. For the Lab's discrete bracket distributions, probabilistic calibration of the ladder distribution and event-level reliability of each derived exceedance are checked separately (rank/PIT checks vs. reliability diagrams). For quantile and interval forecasts, the corresponding notion is coverage at every level jointly; **conformal prediction** (Vovk, Gammerman, and Shafer 2005; Angelopoulos and Bates 2021 ⚑) achieves finite-sample marginal coverage distribution-free under exchangeability — an assumption our serially dependent city-days violate, which is why conformal methods appear in §22 rather than in the toolkit.

**Conditional calibration.** Calibration conditional on any information set available at issuance: $\mathbb{E}[y \mid p, \mathcal{G}] = p$. A forecaster can be unconditionally calibrated yet miscalibrated given season, city, or liquidity state — exactly the structure of _exploitable_ bias in a market, because a trader conditions. Auto-calibration (conditioning on the forecast itself; Tsyplakov 2013 ⚑) sits between marginal and fully conditional. Registered subgroup analyses (city, season, horizon) are conditional-calibration probes and carry §16.6's multiplicity obligations.

**Bayesian calibration.** Dawid (1982): a coherent Bayesian assigns probability one to being calibrated on sequences she expects. The theorem does not survive model misspecification — a wrong likelihood yields confident miscalibration. Practical reading: Bayesian machinery guarantees internal coherence, never external calibration; only verification supplies the latter.

### 4.2 Why calibration alone is nearly free

Foster and Vohra (1998): a randomized forecaster with no knowledge of the process can be asymptotically calibrated against every sequence. Corollaries: calibration certifies honesty of _scale_, not possession of _information_; a market can be beautifully calibrated while containing nothing beyond climatology; the paradigm must be _maximize sharpness subject to calibration_. Grey-literature Kalshi calibration studies reporting curves without resolution accounting are incomplete in exactly this sense — the standing grade applied to them in [[Prediction Markets]].

### 4.3 Scalar calibration measures

**REL** (Murphy decomposition term): $\sum_k \frac{n_k}{N}(\bar p_k - \bar o_k)^2$ — mean-squared vertical miss of the reliability diagram, in Brier units. **ECE**: $\sum_k \frac{n_k}{N}|\bar p_k - \bar o_k|$ (Naeini, Cooper, and Hauskrecht 2015; Guo et al. 2017). **MCE**: $\max_k |\bar p_k - \bar o_k|$. All inherit the binning pathology — estimates move materially with bin count and edges, and plug-in estimators are biased (Kumar, Liang, and Ma 2019; Vaicenavicius et al. 2019 ⚑; Nixon et al. 2019 on adaptive binning ⚑). House rule: any scalar calibration number is reported under at least two binning schemes, the registered scheme fixed before outcomes.

**The estimation frontier: CORP** (Dimitriadis, Gneiting, and Jordan 2021) replaces binning with isotonic regression of outcomes on forecasts (pool-adjacent-violators), yielding a reliability diagram and decomposition $\mathrm{BS} = \mathrm{MCB} - \mathrm{DSC} + \mathrm{UNC}$ that is optimal, reproducible, and binning-free. Recommended default for standing calibration reports, with a classical fixed-bin diagram retained for comparability with external studies.

**Distribution-level and quantile calibration.** PIT-based statistics (§13); GBR's marginal-calibration plot; for regression-style distributional forecasts, quantile-calibration recalibration (Kuleshov, Fenner, and Ermon 2018) is the ML-side analogue of meteorological post-processing.

### 4.4 Recalibration techniques

Recalibration maps issued probabilities through a learned link to restore reliability, spending no new information (resolution is at best preserved, in practice slightly degraded by estimation noise):

- **Platt scaling** (Platt 1999): parametric logistic map — sample-efficient, assumes sigmoidal miscalibration.
- **Isotonic regression** (Zadrozny and Elkan 2002): monotone nonparametric — flexible, data-hungry, CORP's engine.
- **Temperature scaling** (Guo et al. 2017): one-parameter logit rescaling — the minimal intervention.
- **Beta calibration** (Kull, Silva Filho, and Flach 2017): three-parameter family correcting Platt's restrictions on [0,1] scores.
- **Meteorological statistical post-processing** — the same operation at distribution level: MOS (Glahn and Lowry 1972), EMOS/NGR (Gneiting et al. 2005), BMA (Raftery et al. 2005), quantile mapping.

Two disciplines govern Lab use: recalibration maps are **versioned artifacts fitted strictly out-of-sample** (a map fitted through the evaluation window is leakage, §16.1); and a recalibrated forecaster is a _new registered forecaster_, scored from its registration date forward, never retro-applied (Engineering Playbook §6 registered-variant rule).

### 4.5 Interpretation discipline

Three standing cautions. Calibration is necessary, cheap, and insufficient (§4.2). Calibration estimates at small $n$ are noise — binomial SE $\sqrt{p(1-p)/n_k}$ gives ±14.5 pp at $n_k{=}10$, $p{=}0.7$; [[Effective Sample Size]] makes this a rejection rule. And apparent miscalibration can be manufactured upstream: settlement-source mismatch contaminating the outcome variable, or microstructure artifacts read as probabilities (stale quotes, fee displacement — R7); the A7 triage ladder exhausts these before "miscalibrated market" is entertained.

---

## 5. Sharpness

**Definition.** Sharpness is the concentration of the predictive distributions — a property of $p(f)$ alone: issued probabilities far from $\bar o$ in the binary case; narrow intervals or low predictive entropy in the distributional case. Natural summaries: the variance of issued probabilities, mean predictive interval width at fixed coverage, mean predictive entropy $\mathbb{E}[H(F_t)]$. A climatological forecaster is perfectly calibrated and maximally unsharp; an oracle is perfectly calibrated and maximally sharp; every real forecaster lives on the frontier between.

**Role in the paradigm.** _Maximize sharpness subject to calibration_ (GBR 2007) assigns asymmetric roles: calibration is a validity constraint on the probability scale; sharpness is the objective, because among calibrated forecasters every proper score ranks by sharpness/resolution — visible in the Murphy decomposition, where REL is the only term reducible without information and RES the only term rewarding it, and provable score-generically through the Bregman structure (§9.2, Bröcker 2009).

**Sharpness is not resolution.** Sharpness is outcome-free by construction; resolution is its outcome-ratified counterpart. A forecaster can be sharp without resolution — extreme probabilities uncorrelated with events — which log scoring punishes catastrophically and Kelly converts into overbetting and drawdown ([[Kelly Criterion]]). The sharpness diagram (distribution of issued probabilities, or of interval widths) should accompany every reliability diagram: the pair implements the paradigm audit in two plots, and a reliability diagram without its refinement distribution is uninterpretable (§11.1).

**Tradeoffs and distortions.** Recalibration typically flattens extremes toward the base rate — buying reliability with sharpness; whether the proper score improves depends on whether the surrendered sharpness was information or bravado. Comparisons of sharpness across different base rates or seasons are meaningless without the UNC context (§6.4; the pooling trap, §14.4). Market-specific distortion: price-dependent fees maximized near 50¢ mechanically discourage quotes mid-scale, distorting _displayed_ sharpness independent of belief — a structural effect A4's normalization must not read as conviction ([[Prediction Markets]]).

---

## 6. Resolution

### 6.1 Placement in the decomposition

Resolution is the second term of Murphy's (1973) partition (§10 for the full development): $$\mathrm{RES} = \frac{1}{N}\sum_k n_k(\bar o_k - \bar o)^2,$$ the variance of the conditional outcome frequencies around the base rate: whether the forecaster's distinctions sort reality. Bounded above by UNC, with equality only for a perfect discriminator. Worked numerics: [[Brier Decomposition - Worked Example]].

### 6.2 Resolution as information

Under the logarithmic score the decomposition's resolution term is the **mutual information** $I(f; y)$: the generalized decompositions (Bröcker 2009) exhibit REL and RES as expected Bregman divergences, which for the log score are KL divergences, giving $\mathrm{RES}_{\log} = \mathbb{E}_f, D_{KL}\big(p(y \mid f),|,p(y)\big) = I(f; y)$. Resolution is the verification-theoretic face of information gain (Roulston and Smith 2002 develop the ignorance-score version; Weijs, van Nooijen, and van de Giesen 2010 ⚑ the divergence-score decomposition). This grounds the edge taxonomy: a **resolution advantage is an information-production advantage**, durable while the pipeline is better; a reliability advantage is a statistics repair the counterparty can perform overnight ([[Edge Detection]]).

### 6.3 Sufficiency, incomparability, and its modern resolution

DeGroot and Fienberg (1983): forecaster A is _sufficient_ for B if B's forecasts are a stochastic garbling of A's; sufficiency implies A weakly dominates B under **every** proper score. But sufficiency is a partial order — many real pairs are incomparable, ranked differently by different proper scores. Two consequences, one classical and one modern. Classical: model-vs-market verdicts are score-dependent in principle, so the registered primary score is fixed in advance (log, for the Kelly identity) with RPS as registered secondary; score-shopping after results is a §16.4 offense. Modern: **Murphy diagrams** (Ehm, Gneiting, Jordan, and Krüger 2016; §9.4) make dominance _empirically checkable_ — plotting elementary-score differentials across all cost–loss thresholds shows whether one forecaster dominates under every proper score simultaneously or wins only under some weightings. A Murphy-diagram panel is therefore the registered robustness companion to any primary-score verdict: dominance across the diagram is a strictly stronger claim than a single score differential, and the diagram localizes _where on the probability scale_ an advantage lives — directly interpretable against fee structure and FLB region.

### 6.4 Relationship to entropy

UNC $= \bar o(1-\bar o)$ is the outcome's quadratic (Gini) entropy; under log scoring, the Shannon entropy $H(\bar o)$. The three-term structure reads: _difficulty of the world_ (UNC) − _information extracted_ (RES) + _dishonesty of scale_ (REL). Cross-city or cross-season comparisons must hold UNC constant or report it: Phoenix summer highs and Chicago shoulder-season highs are different games; pooling them manufactures resolution spuriously (§14.4).

---

## 7. Discrimination

### 7.1 The likelihood–base-rate view

Discrimination conditions on the outcome: compare $p(f \mid y{=}1)$ against $p(f \mid y{=}0)$ (§3.1). The **discrimination diagram** — the two conditional forecast densities overlaid — is the direct graphical estimate (Wilks 2019 ch. 9; Jolliffe and Stephenson 2012) and should be produced alongside ROC summaries: it shows _where_ separation lives, not only how much exists.

### 7.2 ROC analysis

The Relative Operating Characteristic (signal-detection theory; meteorological introduction Mason 1982; statistical properties Mason and Graham 2002 ⚑): sweep a threshold across forecast probability, plot hit rate $H$ against false-alarm rate $F$. $\mathrm{AUC} = \Pr(f_{y=1} > f_{y=0})$ — the probability a randomly chosen event received a higher forecast than a randomly chosen non-event; 0.5 is no skill. The Peirce skill score is the maximal $H - F$ over thresholds.

### 7.3 Relationship to calibration and decisions

ROC is **invariant to any monotone recalibration**. Virtue: it isolates _potential_ skill — the discrimination available to a user willing to recalibrate — and underlies potential economic value (Richardson 2000; §18.2). Vice: a wildly miscalibrated forecaster can have perfect AUC, so ROC can never certify that stated probabilities are usable _as probabilities_. For a system whose bet sizes are functions of stated probabilities (Kelly), calibration is not optional. House rule: ROC/AUC appears only alongside reliability measures, never in place of them.

### 7.4 Limitations

AUC on rare events is dominated by ranking among easy negatives (precision–recall alternatives matter under severe imbalance; roughly balanced bracket events gain little). Empirical ROC bands at city-day $n$ are wide and must be bootstrapped by date; AUC differences between forecasters on identical events are strongly dependent — paired designs (§17.2) apply here too.

---

## 8. Forecast Bias

### 8.1 Sources

_Meteorological point forecasts:_ model systematic error (radiation, boundary layer), station representativeness (forecast grid cell vs. the ASOS instrument that settles the market), seasonal-transition lag. NWS human-adjusted forecasts historically show small, structured biases relative to guidance, varying by station and season ⚑ — an A2 input to be _estimated from accrued data_, not assumed. _Probability forecasts:_ overconfidence at the extremes (Lichtenstein, Fischhoff, and Phillips 1982) and its mirror, hedging toward the base rate, observed in some operational PoP eras. _Markets:_ the favorite–longshot bias — longshots systematically **overpriced** — documented across venues and decades (Ali 1977; Thaler and Ziemba 1988; Snowberg and Wolfers 2010, whose pricing-kernel test discriminates risk-love from misperception and favors misperception in horse-race data). Whether FLB survives in Kalshi weather brackets _net of the price-dependent fee distortion that mimics it mechanically_ is Open Question 1; the fee confound means observed extreme-price bias cannot be read as behavioral without A4's cost model, and the normalization method itself shapes measured FLB (§15.8) — a circularity that must be broken by registration.

### 8.2 Measurement

Unconditional: mean error; $\bar p - \bar o$; frequency bias. Conditional: the reliability curve is the bias function $b(\pi) = \mathbb{E}[y \mid p = \pi] - \pi$; Type-II conditional bias $\mathbb{E}[f \mid x] - x$ reads the other factorization. All inherit §17's small-sample and dependence caveats.

### 8.3 Correction

Meteorology's post-processing canon (§4.4) is bias correction at scale: MOS regression, Kalman-filtered running corrections, EMOS/BMA, quantile mapping — all subject to out-of-sample fitting and versioning discipline. Market-side "correction" is not available to us: the market's bias, if real and cost-surviving, is not an error to fix but the object of study and, V3-conditionally, the harvestable edge.

---

## 9. Proper Scoring Rules

Full derivations (propriety proofs, Savage representation details, the Kelly identity) live in [[Proper Scoring Rules and Calibration - Technical Reference (V2)]] and [[Log Score and Kelly Identity — Technical Reference (V2)]]; this section carries the verification-theoretic placement plus three items with independent load: the likelihood connection, the decision-theoretic representation, and the boundary problem.

### 9.1 Propriety

$S(P, y)$ is **proper** if truthful reporting maximizes expected score, **strictly proper** if uniquely so (Brier 1950; Good 1952; Savage 1971; consolidated in Gneiting and Raftery 2007). The Savage representation: every proper binary score arises from a convex function $G$ via $S(p, y) = G(p) + G'(p)(y - p)$ (positively oriented), and the expected score gap of report $p$ under truth $q$ is the Bregman divergence $d_G(q, p) \ge 0$. Propriety makes Murphy's Type-1 goodness structural: under improper metrics — accuracy, hit rate, MAE on probabilities — the optimal report differs from the belief, and a pipeline built on one silently selects for distortion, typically overconfident distortion (Bröcker and Smith 2007a on the importance of being proper).

### 9.2 The working family

**Brier/quadratic** ($G(p) = -p(1-p)$ up to affine terms): bounded, decomposable, the verification workhorse. **Logarithmic** ($G(p) = p\ln p + (1-p)\ln(1-p)$): local, unbounded, the currency of compounding wealth (§9.3, §18.3). **RPS**: cumulative-distribution quadratic score over ordered categories — the bracket ladder's natural score, rewarding closeness in temperature space. **CRPS**: the continuous limit; an integral of threshold Brier scores; ensemble decomposition per Hersbach (2000). Selten (1998 ⚑) axiomatizes the quadratic score; Benedetti (2010 ⚑) argues axioms selecting the log score uniquely. Every proper score admits a reliability–resolution decomposition via its Bregman divergence (Bröcker 2009), so the §4–§6 diagnosis is score-generic.

### 9.3 Relationship to likelihood

The log score of a predictive distribution evaluated at the realized outcome **is** the log predictive likelihood; cumulative log score is the prequential log-likelihood of the forecast system (Dawid 1984). Consequences. (i) A mean log-score differential between two forecasters is a per-observation **log Bayes factor** between them as predictive models: log-score comparison is Bayesian model comparison performed out-of-sample, without priors over parameters because the forecasts arrive already integrated. (ii) Information-criterion model selection (AIC/BIC) is the penalized in-sample shadow of the same quantity; the Lab needs no penalty because all scoring is genuinely sequential-out-of-sample. (iii) The expected log-score shortfall under truth $q$ is $D_{KL}(q | p)$, tying the whole apparatus to information theory (Cover and Thomas 2006) and, through the Kelly identity, to growth. This triple identity — _log score = predictive likelihood = growth currency_ — is why the log score is the registered primary despite the boundary problem of §9.5.

### 9.4 The decision-theoretic representation: Schervish and Murphy diagrams

Schervish (1989): every proper score for binary events is a mixture of **elementary scores** — two-point cost–loss decision problems indexed by threshold $\theta \in (0,1)$: $$S(p, y) = \int_0^1 S_\theta(p, y), dH(\theta),$$ where $S_\theta$ penalizes acting/not-acting errors at threshold $\theta$ and $H$ is the score's mixing measure. The Brier score is the **uniform** mixture over $\theta$; the log score's mixing density is proportional to $1/[\theta(1-\theta)]$ — unbounded weight on the extremes. This is the precise sense in which "the log score cares about tails": it prices the decision problems of users with extreme cost–loss ratios heavily, which is simultaneously why it is the right currency for a bettor facing longshot prices and why it detonates at the boundary (§9.5).

Ehm, Gneiting, Jordan, and Krüger (2016) operationalize the representation: the **Murphy diagram** plots the elementary-score differential between two forecasters as a function of $\theta$. If one forecaster's curve dominates across all $\theta$, it is superior under _every_ proper score — an empirically checkable sufficiency-style dominance (§6.3) — and where the curves cross localizes, on the probability scale, which forecaster serves which decision-makers. Lab adoption (directive to A1): a Murphy-diagram panel with date-blocked confidence bands accompanies every registered model-vs-market verdict; dominance claims are stated as "dominant across the diagram" or "advantage concentrated in $\theta \in [\cdot,\cdot]$" — the latter mapping directly onto fee structure and the FLB region.

### 9.5 The boundary problem ⚠ (unresolved design decision)

The log score is unbounded: $S(p, y) \to -\infty$ as $p \to 0$ with $y = 1$. This is not a pathology of theory but of _our data_: normalized market-implied probabilities **will** touch 0 and 1 — a bracket with no bid, a 1¢ quote consumed by fee adjustment, a rounding artifact — and a single boundary case with an adverse outcome makes the market rung's cumulative log score, and every differential built on it, undefined or infinite. The candidate treatments, none innocent:

1. **Restrict log-score claims to interior events**, with the exclusion rule registered and its firing rate monitored — changes the event population and must be symmetric across rungs.
2. **Probability flooring/clipping at registered $\epsilon$** — renders the score improper in the floor region and makes results $\epsilon$-dependent; if adopted, sensitivity across an $\epsilon$-grid is mandatory reporting.
3. **Primary-score substitution** (Brier/RPS primary, log secondary on interior events) — surrenders the exact Kelly identity for the headline number.
4. **Treat boundary quotes as censored statements** ("$p \le$ 1 tick") rather than point probabilities — honest but requires interval-forecast scoring machinery (§2, interval score) not yet in the registered toolkit.

The Kelly identity inherits the problem in economic form: a 0-price against a realized outcome implies infinite log growth, bounded in reality by depth and fees — which suggests the _economically honest_ resolution couples the score floor to the executable-price floor (one tick plus fees), making option 2's $\epsilon$ a market constant rather than an arbitrary knob. **Status: this is an A1/A4 registered decision, flagged here as the most consequential unresolved measurement choice in the Lab.** V1 of this document failed to surface it; no verification result using the log score should be graded until the rule is ratified.

### 9.6 Score choice under misspecification

When both forecasters are misspecified — the permanent condition — different strictly proper scores can rank them differently even asymptotically (Patton 2020 ⚑; the sufficiency partial order of §6.3 is the population-level face of the same fact). This sharpens the pre-registration argument from hygiene to necessity: the primary score is part of the _definition_ of the research question, not a reporting convenience. It also elevates the Murphy diagram (§9.4) from robustness garnish to the honest summary when dominance fails.

---

## 10. Murphy Decomposition

### 10.1 Historical development

Brier (1950) proposed the quadratic score; Sanders (1963) first partitioned it into reliability and resolution in a study of subjective forecasts; Murphy (1972, 1973) formalized the canonical three-term partition and its skill-score corollaries; Murphy and Winkler (1987) re-derived it as the calibration–refinement factorization's arithmetic (§3.1), with the likelihood–base-rate factorization yielding the discrimination-side analogues. Generalizations: Murphy and Epstein (1989) related decomposition to correlation and conditional-bias terms in skill scores; Bröcker (2009) exhibited the decomposition for arbitrary proper scores via Bregman divergences; Stephenson, Coelho, and Jolliffe (2008) quantified the within-bin terms the textbook identity hides; Ferro and Fricker (2012 ⚑) supplied bias-corrected estimators; Dimitriadis, Gneiting, and Jordan (2021) made estimation binning-free (CORP); Ehm et al. (2016) decomposed along the orthogonal axis — across decision thresholds rather than across forecast bins (§9.4). The two decompositions answer different questions: Murphy's, _what kind of quality_ (calibration vs. information); Ehm's, _for whom_ (which decision-makers benefit).

### 10.2 Mathematics

Forecasts binned $k = 1,\dots,K$ (populations $n_k$, mean forecast $\bar p_k$, conditional frequency $\bar o_k$), base rate $\bar o$:

$$\mathrm{BS} ;=; \underbrace{\frac{1}{N}\sum_{k} n_k(\bar p_k - \bar o_k)^2}_{\text{REL}} ;-; \underbrace{\frac{1}{N}\sum_{k} n_k(\bar o_k - \bar o)^2}_{\text{RES}} ;+; \underbrace{\bar o(1-\bar o)}_{\text{UNC}}.$$

REL ≥ 0 (want 0); RES ∈ [0, UNC] (want large); UNC fixed by the world. The skill identity $$\mathrm{BSS} = \frac{\mathrm{RES} - \mathrm{REL}}{\mathrm{UNC}}$$ holds **exactly only when the reference is the in-sample base rate** $\bar o$ (sample climatology); against an external or out-of-sample climatological reference — the leakage-honest choice for the A8 rung — the identity acquires a correction term and the decomposition and the skill score must be reported as separate objects, not derived from one another. V1 of this document stated the identity without this condition; the condition is load-bearing precisely because A8's no-leakage rule _forbids_ the in-sample reference.

**Exactness caveat (within-bin terms).** The three-term identity assumes within-bin homogeneity; the full five-term version (Stephenson et al. 2008) adds within-bin variance and covariance terms that are not negligible with coarse bins and continuous forecasts. House practice: compute on the registered bin scheme _and_ via CORP, and reconcile — a materially binning-dependent decomposition is a finding about sample size, not about the forecaster.

### 10.3 Interpretation

The decomposition converts a grade into a diagnosis: REL repairable without information (§4.4), RES purchasable only with information, UNC the difficulty of the game. Comparative use is the Lab's core loop: paired model-vs-market differentials decompose into reliability and resolution differentials with different durabilities ([[Edge Detection]]: bias-harvesting vs. information-production edges) and different V3 implications — a REL edge on the market's side means our probabilities need recalibration before Kelly sizing; a RES deficit means the pipeline lacks information the market has.

### 10.4 Applications and limitations

Applications: decomposition terms tracked over time detect regime change (a decaying RES differential is an edge being arbitraged away); per-city decompositions localize information advantages; UNC normalizes cross-city comparison. Limitations: bin dependence (mitigated by CORP); small-sample estimator bias — REL biased up, RES biased down when conditional frequencies are estimated (Ferro and Fricker 2012 ⚑), so at city-day accrual rates early decompositions systematically flatter climatology and disparage sharp forecasters; and the arithmetic is score-specific — log-score decompositions (KL-divergence terms, §6.2) are computed in their own right, never assumed to mirror Brier's.

---

## 11. Reliability Diagrams

### 11.1 Construction

Partition $[0,1]$ into bins (equal-population superior to equal-width at skewed forecast distributions); plot ($\bar p_k$, $\bar o_k$) with marker area or an inset histogram giving $n_k$ — the **refinement distribution**, without which the diagram is uninterpretable. Plot the diagonal (perfect reliability), the horizontal at $\bar o$ (zero resolution), and the no-skill line bisecting them: points between no-skill line and diagonal contribute positive skill under the §10.2 identity (with its stated reference condition).

### 11.2 Interpretation

Slope < 1 mid-scale: overconfidence. Slope > 1: hedging. Vertical offset: unconditional bias. S-shapes: miscalibration concentrated at the extremes — where FLB or fee distortion would appear for a market rung, and where samples are thinnest; jointly the reason extreme-bin conclusions are the last to become significant and the first to be over-claimed.

### 11.3 Uncertainty

Point estimates without uncertainty are the diagram's chronic abuse. Remedies: **consistency bars** (Bröcker and Smith 2007b) — resample outcomes under the hypothesis of reliability ($y_i \sim \mathrm{Bern}(p_i)$) so the plot tests a hypothesis rather than decorating an estimate; and bootstrap bands resampling the verification set. The resampling unit here is the **date** (block bootstrap by day, cities and brackets intact), never the contract ([[Effective Sample Size]] standing consequence 2). Curves before hundreds of city-days per bin region are entertainment, not evidence.

### 11.4 Recommended stack

CORP diagrams (isotonic fit with associated uncertainty) as the primary object; classical binned diagram with consistency bars and refinement histogram as the comparability view; pre-registered binning; date-clustered uncertainty; explicit $n_k$ everywhere; a sharpness panel alongside (§5); no smooth interpolation through unweighted bin points; no cross-sample curve comparison without the UNC context.

---

## 12. Rank Histograms

**Purpose.** The ensemble reliability check (Anderson 1996; Talagrand, Vautard, and Strauss 1997; Hamill and Colucci 1997): rank the observation within the sorted $m$-member ensemble across cases; exchangeability of members and observation implies uniformity over the $m{+}1$ ranks.

**Shapes.** U: under-dispersion (the endemic raw-NWP failure). Dome: over-dispersion. Slope: bias. **Flatness is necessary, not sufficient** — Hamill (2001) constructs conditionally unreliable ensembles with compensating errors yielding flat histograms; remedy: stratified histograms (season, regime) plus PIT diagnostics.

**Failure modes.** Observation error inflates apparent under-dispersion (a perfect ensemble legitimately excludes an error-contaminated observation more often; corrections perturb members with the observation-error distribution — §14.6); serial dependence invalidates naive χ² uniformity tests (use date-blocked resampling); small-$m$ discretization. Multivariate extension: the multivariate rank histogram (Gneiting et al. 2008 ⚑) for joint five-city verification, relevant if cross-city structure becomes a research object (§2, §22). V1-operative use: the discrete rank/PIT check of bracket-ladder distributions against realized brackets; full ensemble use activates with V2's probabilistic rung.

---

## 13. PIT Histograms

**The transform.** If $Y \sim F$ continuous, $F(Y) \sim \mathrm{Uniform}(0,1)$ (Rosenblatt 1952). Applied prequentially (Dawid 1984): collect $u_t = F_t(y_t)$; uniformity is probabilistic calibration (§4.1). The PIT histogram is the continuous limit of the rank histogram with identical shape semantics.

**Formal testing.** Beyond visual inspection: Kolmogorov–Smirnov/Cramér–von Mises on $u_t$ require independence the series lacks — use date-blocked resampling for critical values; Berkowitz (2001) transforms $u_t$ to normality and tests jointly for uniformity and independence via likelihood ratio — the standard in density-forecast evaluation in economics, adaptable here with clustering caveats.

**Discrete outcomes — operative for this Lab.** Settlement temperatures reported in whole degrees and bracket outcomes are discrete; the naive continuous PIT on discrete outcomes produces spurious non-uniformity. Constructions: the **randomized PIT** (Brockwell 2007 ⚑) and the non-randomized uniform-version treatment for count data (Czado, Gneiting, and Held 2009). The A-series verification spec must state which construction is registered; this is a named A1 input, not a footnote.

**Usage.** PIT panels plus sharpness summaries implement the paradigm audit (GBR 2007); standard in the post-processing literature (Gneiting et al. 2005; Raftery et al. 2005).

---

## 14. Verification for Weather Forecasts

### 14.1 Temperature

Temperature is the friendliest major predictand: continuous, near-Gaussian short-lead errors, dense observation networks, no spatial-verification pathologies. Operational verification: ME/MAE/RMSE by station, lead, season for points; CRPS/PIT for probabilistic products. Project-bearing facts: NWS/MOS max-temperature errors at 1–2 day leads are of order 2–4°F MAE varying by station and season ⚑ (A2's residual anchor — to be _estimated from accrued data_); **persistence** (yesterday's high) is a legitimate cheap reference for a predictand with strong day-to-day correlation, and its candidacy as an auxiliary ladder rung below climatology is a registered A8 design question ⚑ — persistence beats climatology in stagnant regimes and loses badly across frontal passages, so its skill profile is itself regime-diagnostic. And the settlement variable is a specific station's official maximum from a specific product: _forecast verification_ and _settlement reconciliation_ compare against different truths, and conflating the model's grid target with the settling ASOS instrument is representativeness error masquerading as model bias (Spec R1; §14.6).

### 14.2 Precipitation, wind, ensembles

Precipitation forced the field's methodological innovation — intermittency, skew, the double-penalty problem for high-resolution models — producing neighborhood methods (Fractions Skill Score, Roberts and Lean 2008), object-based methods (SAL, Wernli et al. 2008; MODE), and the intercomparison literature (Ebert 2008; Gilleland et al. 2009). PoP forecasts are also the longest large-sample probability verification record in existence: U.S. PoP reliability across decades is the empirical proof that operational calibration at scale is achievable (Murphy and Winkler 1977). Wind adds vector verification; ensembles add rank histograms, spread–skill, and fair-score corrections (§2, §12) — V2-relevant.

### 14.3 Institutional practice: NWS and ECMWF

NWS: standing national verification of PoP, max/min temperature, and severe products against station observations, with public statistics; MOS and NBM guidance verified against the same stations; human value-over-guidance tracked (Baars and Mass 2005 ⚑; Novak et al. 2014 ⚑). ECMWF: headline scores (500 hPa anomaly correlation; CRPS for ensemble products) in annual verification reports; the ECMWF documentation and the Jolliffe–Stephenson volume are de facto operational standards. WMO's JWGFVR maintains community recommendations and the widely used verification FAQ ⚑. All institutional URLs/details are snapshot-before-cite per provenance discipline; this note must not fossilize living practice.

### 14.4 The pooling trap

Hamill and Juras (2006): pooling verification samples across locations/seasons with different base rates inflates apparent skill — the pooled reference is worse than per-stratum references, so a forecaster "beats climatology" merely by knowing which stratum it is in. Lab translation: five cities are scored against **per-city, per-season references**; any pooled skill number is a weighted aggregate of stratum-level skills, never a skill computed on the pooled sample. Load-bearing for A8's construction and for every cross-city headline.

### 14.5 Extremes and rare events

Two distinct problems. **(a) Scoring rare binary events:** standard contingency measures degenerate as $\bar o \to 0$; base-rate-robust extremal indices exist (extremal dependence indices EDI/SEDI, Ferro and Stephenson 2011) and are the recommended summary for tail-bracket hit behavior. **(b) Emphasizing regions of a distribution:** proper _weighted_ scores — threshold- and quantile-weighted CRPS (Gneiting and Ranjan 2011), censored/conditional likelihood scores (Diks, Panchenko, and van Dijk 2011 ⚑) — allow registered emphasis on tails **decided ex ante**. What is _not_ permissible is the ex-post version: see the forecaster's dilemma, §14.7. Tail brackets are simultaneously the FLB battleground, the thinnest-liquidity region, and the smallest-sample region; this triple coincidence makes tail verification the most error-prone activity in the entire program and the place where every discipline in this document binds at once.

### 14.6 Verification under observation and settlement error

Standard verification treats the observation as truth; when the observation is error-contaminated, apparent forecaster deficiencies are partly artifacts — under-dispersion diagnosed against noisy observations (§12), reliability curves distorted near sharp thresholds. The meteorological treatments perturb the verification framework with the observation-error distribution (Candille and Talagrand 2005 ⚑; Bowler 2006 ⚑; Saetra et al. 2004 ⚑). The Lab's version is sharper because the "observation" is a _settlement_: preliminary vs. final CLI revisions, DST-window subtleties, and the unresolved DCR-vs-max-of-hourlies source question mean the outcome variable has its own provenance and revision history. Operational consequences: dual-truth bookkeeping (verify against final values; simulate decisions against what was knowable when — dual timestamps already mandate this); settlement reconciliation as triage rung one (A7); and any residual outcome-error stress-test in robustness suites ([[Edge Detection]] outcome-error stress).

### 14.7 The forecaster's dilemma ⚠

Lerch, Thorarinsdottir, Ravazzolo, and Gneiting (2017): if evaluation is restricted to cases where an extreme outcome _occurred_, proper scores lose their propriety and the ranking rewards overforecasting — under outcome-conditioned evaluation, any honest forecaster is beaten by a doomsayer. The temptation is guaranteed here: "how did the model do on the days the tail bracket hit?" is exactly the improper slice, and media-style post-mortems of busted longshots are its market-side face. The proper alternatives: condition on _forecast-time information_ (regime, season — legitimate conditional verification, §4.1), or weight the score ex ante (twCRPS, §14.5). **Governance rule proposed for A1: outcome-conditioned score comparisons are inadmissible as evidence in any registered study; they may appear in exploratory notes only with the dilemma cited.** This failure mode is added to §19 and cross-referenced in §16.2 as the evaluation-side sibling of selection bias.

---

## 15. Verification for Prediction Markets

### 15.1 Prices as forecasts

The Lab's stance: a market price is **one more probability forecaster** on the reference ladder, subject to identical scoring — not an oracle (Spec §2). Supporting literature: prices aggregate dispersed information (Hayek 1945; Wolfers and Zitzewitz 2004); the Iowa Electronic Markets outperformed polls across decades (Berg, Nelson, and Rietz 2008 ⚑); the institutional case in Arrow et al. (2008). Standing caveats from the same literature: **price ≠ mean belief in general** — Manski (2006) derives wide bounds on belief heterogeneity consistent with a given price; Wolfers and Zitzewitz (2006) give conditions (log utility, particular belief distributions) under which price ≈ mean belief; and market-scoring-rule venues make the price-as-forecast reading exact by construction (Hanson 2003 — LMSR trading _is_ log-score improvement), whereas order-book venues like Kalshi make it an approximation requiring an extraction rule.

### 15.2 The market's verification-specific challenges

1. **Which price is the forecast?** Last trade is stale in thin brackets; the mid assumes symmetric spread information; the microprice weights by depth; executable prices differ by side. The extraction rule _defines the forecaster being verified_ (Open Question 2) — pre-registered in A4.
2. **When is it issued?** Prices are continuous; rungs are sampled at registered cutoffs. Morning and final-hour prices are different forecasters on different information sets (Q5); calibration deteriorates with horizon in prediction markets (Page and Clemen 2013 ⚑) — "the market is (mis)calibrated" is ill-posed without a horizon.
3. **Liquidity as measurement error.** Thin quotes reflect inventory and fee mechanics as much as belief; wide spreads make the mid a low-precision estimator of anything (R7). Staleness filters, depth thresholds, and liquidity covariates are the A4/A7 instruments.
4. **Settlement ambiguity.** §14.6 — an error class the weather-center literature rarely faces because centers control their own truth data.
5. **Self-defeating verification.** Published miscalibration invites its own arbitrage; market-verification results carry shelf lives NWP verification does not (§15.7; Grossman and Stiglitz 1980 for why _some_ inefficiency must persist to pay for information).

### 15.3 Market efficiency as the null

Semi-strong efficiency (Fama 1970) supplies the natural null: prices impound public information, so no model built on public inputs should out-resolve the market. For weather brackets the null is _maximally plausible_ — the public information is excellent and shared ([[Prediction Markets]]). The program does not assume the null false; it measures, and the V1 exit gate passes on "well-calibrated market, no edge" (Spec §9).

### 15.4 The probability scale: bounds, fees, intervals

The bid–ask pair is an interval statement; collapsing it to a point (mid, microprice) is an information-discarding modeling choice, and the interval score (§2) is the natural tool if the interval reading is ever verified directly ⚑ (methodological gap in the literature — §22). Price-dependent fees (order $0.07,P(1-P)$ per contract at Kalshi ⚑, maximized mid-scale) displace where quotes can profitably rest, distorting displayed sharpness (§5) and extreme prices (§8.1) independent of belief. Verification of the market-as-forecaster runs on the normalized, extraction-rule-defined vector with the rule's identity attached to every scored row: different rules yield different reliability curves for the same market.

### 15.5 Information timing

Dual timestamps (P2) defend against the market-specific look-ahead: scoring 10 a.m. prices against a model consuming the 12Z run completes an unfair race. All rungs sample at identical registered cutoffs on as-of views; the look-ahead swap test is the standing mechanical check (M5.T7).

### 15.6 State of the market-verification literature

Reasonably established: aggregate calibration of large liquid markets (elections, sports) is good but imperfect; FLB is pervasive across venues and decades; calibration varies with horizon and liquidity. Weak or absent: verification of exchange-traded _weather bracket_ markets (no peer-reviewed study located; grey-literature Kalshi analyses exist, unaudited); dependence-aware inference (pooled curves over correlated contracts are the norm — grade external claims accordingly); decomposition reporting (leaving the Foster–Vohra gap unaddressed); extraction-rule sensitivity analysis. The V1 instrument is methodologically ahead of the published record for this venue class, which raises the verification burden on our own claims and defines a legitimate Observatory publication lane (Spec §9).

### 15.7 Non-stationarity

Participant populations, fee schedules, and sophistication drift; a calibration property measured in year one may not exist in year two. Conclusions carry dates; standing scoring (M7) observes drift rather than assuming it away; decay is the default fate of any bias-harvesting finding ([[Edge Detection]]).

### 15.8 Overround normalization ⚠ (feeds A4)

A bracket ladder's raw implied probabilities do not sum to one; converting them to a probability vector is a modeling decision with a literature V1 failed to surface — developed for bookmaker odds, importable only with care:

- **Multiplicative normalization** (divide by the sum): the default everywhere and demonstrably distortionary at the extremes — it spreads the overround proportionally, which _misallocates_ it if the margin is concentrated in longshots (as FLB implies).
- **Power method / iterative variants**: normalize via $p_i^{\lambda}$ with $\lambda$ solving the sum constraint — concentrates the adjustment differently across the scale ⚑.
- **Shin's method** (Shin 1993): a structural model in which the bookmaker prices against a proportion $z$ of insider traders; inverting it yields de-margined probabilities that _correct FLB by construction_. Empirical comparisons in fixed-odds sports data find Shin and regression-based methods outperform basic normalization as probability estimators (Štrumbelj 2014 ⚑).

The importation caveat is structural: bookmaker overround is a monopolist's margin; a Kalshi ladder's sum-to-one failure arises from **bid–ask spreads, fee displacement, and incomplete coverage across independent order books** — a different generating process, so Shin's structural interpretation does not transfer literally. Consequences for A4: (i) the normalization method is a registered choice among named alternatives, not an unexamined division; (ii) **measured FLB is normalization-dependent** — Open Question 1 cannot be answered without stating the method, and running Q1 under two methods is a cheap, high-value registered sensitivity; (iii) a Kalshi-specific de-margining model (spread- and fee-aware rather than insider-proportion-based) is a publishable methodological gap (§22).

---

## 16. Verification Under Data Leakage and Selection

Leakage — outcome-era information contaminating the forecast era — is the dominant cause of irreproducible verification results in quantitative finance and applied ML. Each subsection names the structural countermeasure; this section's failures are the silent ones.

### 16.1 Temporal leakage / look-ahead

Using data not knowable at issuance: the later model run, the revised observation, the recalibration map fitted through the evaluation window. Countermeasures: dual timestamps (P2); as-of joins on ingestion time; the look-ahead swap test as a required unit test (M5.T7); climatology's leakage-ablation invariant (recompute with the evaluation window removed; identical result is a tested contract).

### 16.2 Selection, survivorship, and outcome-conditioning

Verifying on the convenient subset: markets that stayed liquid, days with clean settlement, contracts not delisted (survivorship canon: Brown et al. 1992 ⚑). The evaluation-side sibling is **outcome-conditioned scoring** — the forecaster's dilemma (§14.7) — where the subset is selected by the realized outcome itself, destroying propriety. Countermeasures: pre-registered event sets; daily gap audits (A11) making missing city-days visible facts; registered exclusion rules with monitored firing rates (a drifting exclusion rate is an alarm); the A1 inadmissibility rule for outcome-conditioned comparisons.

### 16.3 Publication and reporting bias

Field level: significant findings publish, nulls don't (Ioannidis 2005; Harvey, Liu, and Zhu 2016's factor-zoo demonstration). Lab level: the same force as selective self-reporting. Countermeasures: mandatory outcome recording regardless of result (Invariant 1 — the V1 gate passes on a null); the Analysis Run Log as an append-only record of every look.

### 16.4 The garden of forking paths

Gelman and Loken (2014): multiplicity accrues through data-dependent analysis choices even without explicit multiple testing — which score, which bins, which liquidity filter, chosen after glimpsing data. Countermeasure: registrations fix the full pipeline before outcomes; deviations are dated addenda; perturbation grids report all cells.

### 16.5 Backtest overfitting

Bailey, Borwein, López de Prado, and Zhu (2014 ⚑): the probability of backtest overfitting grows with configurations tried; reported performance requires trial-count haircuts. Lab translation: the multiplicity denominator for any reported result is the Analysis Run Log's row count, not the number of registered hypotheses.

### 16.6 Multiple testing

Family-wise control (Bonferroni, Holm); false-discovery control (Benjamini and Hochberg 1995); and — most apt for correlated evaluation families — bootstrap methods respecting joint dependence: White's (2000) Reality Check, Hansen's (2005) SPA, Romano and Wolf's (2005 ⚑) stepdown. Dependence _shrinks_ the effective number of independent tests, so independence-based corrections over-penalize; the bootstrap handles this automatically. For standing daily scanners generating open-ended candidate families, **online FDR** procedures (Ramdas and colleagues, 2017–2018 ⚑) are the emerging tool — operationally immature, ADR-gated (§22). Layered defense as already canonical in [[Edge Detection]]: $m{=}1$ by registration where possible; Run Log as the honest denominator; BH-FDR at screening; Reality-Check-class bootstrap at confirmation.

---

## 17. Statistical Significance in Verification

### 17.1 The estimation stance

Every verification statistic is an estimate from a finite, dependent sample; a score without an uncertainty statement is an anecdote with decimals. Standing references: Hamill (1999 ⚑) for resampling tests in verification; Jolliffe and Stephenson (2012, ch. 3, 11); Wilks (2019). House orientation: **confidence intervals over p-values** — the object of interest is the _size_ of a skill differential net of costs, not binary threshold exceedance; p-values appear where registrations demand decision rules.

### 17.2 Paired comparison: the Diebold–Mariano frame

For two forecasters on identical events, form per-event differentials $d_i = S(P^{(1)}_i, y_i) - S(P^{(2)}_i, y_i)$ and test $\mathbb{E}[d] = 0$ with dependence-robust variance (Diebold and Mariano 1995; small-sample correction Harvey, Leybourne, and Newbold 1997; conditional-ability reframing Giacomini and White 2006). Pairing removes the common outcome noise that dominates unpaired comparisons; it is the registered design for every model-vs-market claim. Two standard caveats. **Nested models:** DM's asymptotics fail when one forecast nests the other (Clark and West 2007 supply the correction) — not the model-vs-market case (neither nests the other), but operative for internal comparisons like "A2 versus A2-plus-one-predictor." **Purpose:** DM compares _forecasts as issued_, not underlying models or information sets (Diebold 2015 ⚑ on use and abuse) — which is exactly the Lab's question, but forbids reading a DM verdict as "our model class is better" rather than "our issued probabilities were better over this window."

### 17.3 Dependence and the effective sample size

Dependence has three layers here: brackets within a city-day (perfect — one temperature draw), cities within a day (synoptic co-movement), adjacent days (persistence). Standard errors must respect all three: **cluster by date** (each date one cluster across cities and brackets — the conservative registered default) or model the dependence explicitly (HAC/Newey–West kernels for the serial layer). For equicorrelated clusters of size $m$ with intra-class correlation $\rho$, $n_{\mathrm{eff}} = nm/(1 + (m-1)\rho)$; with $\rho \to 1$ within a city-day's brackets, the bracket dimension contributes nothing — the formal content of the city-day rule ([[Effective Sample Size]]: ≤ ~150 city-days/month, discounted further for spatial and temporal correlation; any high-hundreds $n$ after one month rejected on sight).

### 17.4 Bootstrap methods

The workhorse, because score distributions are skewed and analytic variances of decomposition terms are awkward. Dependence-respecting variants are mandatory: moving-block (Künsch 1989) and stationary (Politis and Romano 1994) bootstraps for the serial layer; for this Lab's structure, resample **dates** — each date carrying its cities and brackets intact — the block unit preserving both intra-day layers mechanically (Efron and Tibshirani 1993 for foundations). Consistency bands (§11.3), CIs on skill and decomposition terms, and Reality-Check-class corrections (§16.6) all run on the same date-blocked engine. Block length for multi-day persistence is a registered choice informed by Open Question 3's eventual lag-correlation measurement.

### 17.5 Bayesian approaches

Posterior inference on skill parameters: beta-binomial models per reliability bin; hierarchical partial pooling across cities/seasons — genuinely attractive at five cities, stabilizing per-city estimates without full pooling's Hamill–Juras trap; posterior predictive checks as the Bayesian face of consistency resampling. Costs: prior sensitivity must be reported, and dependence must still be modeled — a hierarchical likelihood assuming conditional independence at bracket level re-imports the false-$n$ error. Status: candidate methodology for A1, ADR-gated, prior-sensitivity mandatory.

### 17.6 Power and decidability

Power analysis is the V2 gate's own requirement (Spec §9). Mechanics, stated so the calculation is executable: let $\delta$ be the smallest registered-score differential worth detecting (net of costs, in score units per city-day) and $\sigma_d$ the date-clustered standard deviation of daily differentials estimated from accrued data. The required number of effective city-days at size $\alpha$ and power $1-\beta$ is $$n_{\mathrm{req}} \approx \left(\frac{(z_{1-\alpha} + z_{1-\beta}),\sigma_d}{\delta}\right)^{2},$$ and the decidability horizon is $n_{\mathrm{req}}$ divided by the _effective_ accrual rate (§17.3's discounts applied to ~150/month). Under-powered verification is not neutral: at low power, significant estimates are systematically exaggerated in magnitude and can carry the wrong sign (Type-M/Type-S errors, Gelman and Carlin 2014 ⚑) — the statistical mechanism behind "exciting early divergences." The decidability date is a first-class output of every registration (Engineering Playbook §11).

### 17.7 Dependence of skill itself

Score differentials, not only outcomes, are serially dependent — a model advantage during one synoptic regime persists for its duration — inflating naive precision; this is precisely why DM uses HAC variances. Regime-conditional verification is legitimate when registered; the same conditioning post hoc is §16.4's forking path, and conditioning on _outcomes_ is §14.7's dilemma.

---

## 18. Economic Value

### 18.1 Quality is not value

Murphy's Type-2/Type-3 distinction operationalized: value depends on the decision problem, and scalar-quality improvements need not deliver value to a given user (Murphy and Ehrendorfer 1987 ⚑). General theory: decision analysis (Murphy 1977; Katz and Murphy 1997).

### 18.2 Cost–loss, potential value, and the Schervish bridge

The static cost–loss model yields **potential economic value** $V(C/L)$: the fraction of the oracle's expense reduction achieved, traced across the $C/L$ spectrum (Richardson 2000; Zhu et al. 2002). Structure: the value curve's envelope over recalibration is governed by discrimination (ROC); realized value at stated probabilities by calibration — §7.3 in money. The modern unification: the value curve across $C/L$ and the Murphy diagram across $\theta$ (§9.4) are the same object up to normalization — elementary-score differentials _are_ user-by-user value differentials, and a proper score is a $H(\theta)$-weighted portfolio of users (Schervish 1989; Ehm et al. 2016). "Which forecast is better" has no user-free answer except under diagram-wide dominance — which is why the Lab reports the diagram, not only the registered scalar.

### 18.3 The trading translation: Kelly and the log score

For this Lab the user is a bettor and the bridge is exact: the expected log-growth rate of a Kelly bettor with beliefs $q$ against prices $r$ under truth $p$ equals the expected log-score differential, $D_{KL}(p|r) - D_{KL}(p|q)$ (Kelly 1956; Cover and Thomas 2006 ch. 6; derivation in [[Log Score and Kelly Identity — Technical Reference (V2)]]). Corollaries with governance force: **edge detection is score comparison**; the log score is the registered primary (subject to §9.5's boundary rule); the identity is _gross of costs_ — realized paper growth reconciles against identity-predicted growth minus fees, spreads, and discretization, which is M8.T5's monthly decomposition. Overconfidence is priced exactly: betting $q$ under truth $p$ costs $D_{KL}(p|q)$ in growth — the decision-theoretic reason calibration is non-negotiable for sizing even when discrimination is excellent. In the Schervish view, the log score's extreme-heavy mixing measure (§9.4) is the bettor's exposure to longshot decision problems: the FLB region is where the log score concentrates its attention _and_ where fees, thin depth, small samples, and the boundary problem concentrate theirs. That coincidence is the project's central measurement tension, and it is why tail-bracket claims face the highest evidentiary bar in the Lab.

### 18.4 Cost-sensitive evaluation

Realized value nets execution: the fee at the executable price, the spread at executable size, depth limits. A quality edge smaller than the cost wedge is real and worthless; the wedge varies by price level (fee maximized mid-scale) and bracket liquidity, so cost-adjusted verification is bracket-conditional. The measurement ladder — _scores → skill → cost-adjusted skill → paper P&L_ — is deliberate: each rung falsifiable against the previous, with the paper ledger (V2) as the realized-value instrument at executable prices, never mids.

---

## 19. Common Failure Modes

Consolidated register; each names its countermeasure.

1. **Overconfidence** — probabilities more extreme than warranted; maximally punished by log score and Kelly overbetting. Detection: reliability slope < 1. Remedy: registered recalibration variant (§4.4).
2. **Underconfidence / hedging** — sharpness surrendered; invisible to calibration checks, visible as resolution deficit (§6).
3. **Improper metrics** — accuracy, hit rate, MAE-on-probabilities as targets; selects for distortion (§9.1). Countermeasure: proper scores only, structurally.
4. **Boundary-corrupted scores** — log scores computed through 0/1 probabilities; undefined or infinite results, silently $\epsilon$-dependent if floored (§9.5). Countermeasure: the registered boundary rule; no log-score verdict graded before its ratification.
5. **Base-rate-free evaluation** — the Finley error; skill without a reference or with a pooled reference (§14.4). Countermeasure: the ladder; per-stratum references.
6. **Outcome-conditioned evaluation** — the forecaster's dilemma (§14.7); scoring only where the extreme occurred rewards doomsaying. Countermeasure: A1 inadmissibility rule; ex-ante weighted scores where tails deserve emphasis.
7. **Data leakage in all forms** — §16.1; dual timestamps, as-of joins, ablation and swap tests.
8. **False sample size** — bracket-level $n$; contract-level resampling ([[Effective Sample Size]]). Countermeasure: city-day units; date-blocked everything.
9. **Multiplicity laundering** — many looks, one reported (§16.3–16.6). Countermeasure: Run Log denominator; FDR/bootstrap corrections.
10. **Microstructure misread as belief** — stale quotes, fee displacement, mids as probabilities (R7); _and_ normalization-method artifacts read as FLB (§15.8). Countermeasure: A4 rules; A7 triage; dual-method Q1 sensitivity.
11. **Outcome-variable contamination** — settlement mismatch and revisions (§14.6). Countermeasure: reconciliation as triage rung one; dual-truth bookkeeping.
12. **Verification theater** — diagrams without bands, scores without CIs, calibration without resolution, registrations after peeking. Countermeasure: templates make the honest version the only executable version.
13. **Regime non-stationarity** — measured properties treated as permanent (§15.7). Countermeasure: standing scoring; dated conclusions; decay as default.
14. **Goal drift** — trading the first exciting divergence (Spec R10). Countermeasure: V-gates; the paper ledger as sanctioned outlet.

---

## 20. Best Practices — Synthesis

The convergent stack across meteorology (Jolliffe–Stephenson; Wilks; JWGFVR), statistics (the Gneiting school), econometrics (DM lineage), and ML calibration, as adopted here:

**Design before data.** Registration fixes predictand, event set, extraction and normalization rules, scores (with the boundary rule), bins, exclusions, clustering, thresholds; decidability date derived; prior looks disclosed. **Score properly.** Strictly proper scores as sole optimization targets; skill against pre-specified per-stratum references; decompositions attached to every headline; Murphy-diagram panel attached to every comparison verdict. **Diagnose, don't just grade.** CORP-first reliability diagrams with consistency bands and refinement histograms; sharpness panels; discrete-aware PIT; ROC only alongside calibration. **Respect dependence.** City-day units; date-clustered or date-block-bootstrapped uncertainty on every number; paired DM-class designs with HAC variances. **Guard the sample frame.** Completeness audits; registered exclusions with monitored firing rates; settlement reconciliation continuously; no outcome-conditioned slices. **Report against forking.** Full perturbation grids; all registered strata; nulls filed with the same ceremony as positives. **Version everything.** Recalibrations, references, extraction and normalization rules as dated registered artifacts; conclusions carry dates and regimes.

---

## 21. Implications for Research Lab — Engineering Directives

Rebuilt in V2 as numbered directives so that A-series authors and implementers can cite clauses. Each states its literature ground and its architectural home. Directives marked **[NEW]** originate in this review and are proposals until ratified.

**D-FV-1 (unit of evidence).** All inference at city-day grain, date-clustered or date-block-bootstrapped; bracket-level $n$ inadmissible. _Ground:_ §17.3 dependence arithmetic; clustered-inference canon. _Home:_ [[Effective Sample Size]] (already standing); A1.

**D-FV-2 (reference discipline).** Per-city, per-season references; pooled headlines only as weighted stratum aggregates; the market rung alone defines edge; "edge" vs. "disagreement Δ" vocabulary enforced. _Ground:_ §1.6, §14.4, §3.2-Skill. _Home:_ A8, [[Glossary]], [[Edge Detection]].

**D-FV-3 (score governance).** Log score registered primary; Brier/RPS registered secondaries; skill scores reported, never optimized; scoring code validated against worked examples pre-use. _Ground:_ §9.1–9.3. _Home:_ A1; Spec §11.

**D-FV-4 [NEW] (boundary rule).** No log-score result is gradable until A1/A4 ratify a boundary treatment (§9.5's four options); if flooring is chosen, $\epsilon$ ties to the executable-price floor and $\epsilon$-grid sensitivity is mandatory reporting. _Ground:_ §9.5. _Home:_ A1 §scores; A4 §normalization outputs.

**D-FV-5 [NEW] (Murphy-diagram companion).** Every registered forecaster-comparison verdict ships with a Murphy-diagram panel with date-blocked bands; dominance claims are diagram-wide or interval-localized, never bare scalars. _Ground:_ §9.4, §9.6, §18.2. _Home:_ A1 §reporting; M6 study template.

**D-FV-6 [NEW] (outcome-conditioning inadmissibility).** Outcome-conditioned score comparisons are inadmissible as registered evidence; tail emphasis is expressed ex ante via weighted scores (twCRPS/censored-likelihood class) or base-rate-robust indices (SEDI). _Ground:_ §14.5, §14.7. _Home:_ A1 §admissibility; [[Pre-Registered Experiment Template]].

**D-FV-7 [NEW] (normalization registration).** A4 selects its sum-to-one method from named alternatives (multiplicative, power, Shin-class, or a Kalshi-specific spread/fee-aware model) with rationale; Q1 (FLB) is answered under at least two registered methods; the normalization method's identity attaches to every scored market row. _Ground:_ §15.8, §8.1. _Home:_ A4; Open Question 1's registration.

**D-FV-8 (calibration reporting).** CORP-first diagrams; classical binned view for external comparability; two binning schemes for any scalar; consistency bands resampled by date; sharpness panel adjacent; minimum-$n$ gates before interpretation. _Ground:_ §4.3, §11. _Home:_ A1 §diagnostics; M7 standing reports.

**D-FV-9 [NEW] (discrete-PIT construction).** The verification spec names its discrete-PIT construction (randomized vs. non-randomized) before first distribution-level calibration claim; continuous PIT on integer outcomes is inadmissible. _Ground:_ §13. _Home:_ A1 §diagnostics.

**D-FV-10 (leakage contracts).** Dual timestamps; as-of joins; look-ahead swap tests; climatology ablation invariant; recalibration maps versioned and out-of-sample; registered variants scored from registration date only. _Ground:_ §16.1, §4.4. _Home:_ Engineering Playbook §6–§8 (already standing); M5 tests.

**D-FV-11 (multiplicity ledger).** The Run Log's row count is the multiplicity denominator; BH-FDR at screening; Reality-Check-class bootstrap at confirmation; online-FDR adoption for any standing scanner is ADR-gated. _Ground:_ §16.5–16.6. _Home:_ [[Edge Detection]] (already standing); future scanner ADR.

**D-FV-12 (decidability).** Every registration computes its decidability date via §17.6's formula from measured $\sigma_d$ and effective accrual; early runs permitted but indelibly logged. _Ground:_ §17.6. _Home:_ Engineering Playbook §11; M8.T6.

**D-FV-13 (value ladder).** Claims ascend _scores → skill → cost-adjusted skill → paper P&L_ in order; costs at executable prices, never mids; monthly reconciliation against the Kelly identity; paper results generate hypotheses, never validation (Invariant 1 has no paper-trading exemption). _Ground:_ §18. _Home:_ M8; Spec §9.

**D-FV-14 [NEW] (dual-truth settlement bookkeeping).** Verification against final settlement values; decision simulation against as-of-knowable values; revisions stored as new rows; settlement reconciliation remains triage rung one. _Ground:_ §14.6. _Home:_ A7; storage schema (already structurally supported by P1/P2).

**What V1-the-instrument must therefore produce** (unchanged in substance from this document's V1, restated against the directives): a growing population of (forecast, price, outcome) triples at city-day grain with normalization and extraction identities attached (D-FV-7); standing proper-score records with decompositions and Murphy diagrams across the full ladder (D-FV-3/5); CORP calibration reports with date-blocked bands (D-FV-8); completeness and settlement-reconciliation audits (D-FV-14); and one end-to-end pre-registered calibration study — the exit gate that tests the instrument, not the result.

---

## 22. Open Research Questions in the Literature

Where the field itself is unsettled — distinct from the Lab's Q1–Q7 register, though several map onto it.

1. **Small-$n$ decomposition estimation under dependence.** Bias corrections and CORP improved matters; behavior of decomposition terms under strong clustering (our regime) lacks definitive treatment. Bears on: earliest reportable decomposition.
2. **Discrete/mixed-outcome PIT standards.** Multiple constructions coexist; no single standard for integer-valued settlement variables. Bears on: D-FV-9.
3. **Verification under non-stationarity.** Rolling windows vs. weighting vs. change-point frameworks; no consensus. Bears on: standing-scoring design; edge-decay monitoring.
4. **Multiplicity for open-ended sequential candidate families.** Reality-Check-class tests assume fixed families; online FDR (Ramdas lineage ⚑) is promising, operationally immature. Bears on: the M7 scanner ADR.
5. **Prediction-market verification methodology.** Extraction-rule sensitivity, dependence-aware market calibration, decomposition reporting, interval-reading of bid–ask, and exchange-specific de-margining models (§15.8) are essentially absent from the record. The Lab is positioned to contribute — a legitimate Observatory output.
6. **Verification under strategic response.** Publishing a market's miscalibration invites its correction; game-theoretic verification is thin. Bears on: publication decisions.
7. **Serial dependence of score differentials.** Block-length selection and regime-conditional DM inference in weather-driven series remain craft. Bears on: A1's clustering scheme; Open Question 3.
8. **Boundary treatment for local scores on bounded-price venues.** No literature consensus on proper-score evaluation when the evaluated forecaster emits exact 0/1 (§9.5); the censored-statement reading is undeveloped. Bears on: D-FV-4; a possible methodological note from this Lab.
9. **Conformal methods under serial dependence.** Distribution-free coverage beyond exchangeability is an active frontier ⚑; if matured, conformal intervals become a model-rung post-processing candidate. Bears on: V2+ model rung options.
10. **Multivariate verification at small dimension.** Energy-score discrimination weaknesses and variogram-score tradeoffs at $d{=}5$ with strong cross-correlation are imperfectly mapped. Bears on: any future joint-cities research object.

---

## 23. Annotated Bibliography

> [!warning] Invariant 3 applies with full force Every entry is cited from model knowledge; ~150 entries is the honest ceiling rather than the directive's 250, because padding further would require fabrication risk. ⚑ marks lower drafter confidence in bibliographic details; ★ marks the priority verification tier (entries directly feeding A-series decisions). Bürgi–Deng–Whelan remains deliberately absent — it is E4-flagged in [[Edge Detection]] pending primary-source verification and enters this bibliography only after that verification.

### 23.1 Foundations and general frameworks

1. ★ Murphy, A. H., and R. L. Winkler (1987). "A general framework for forecast verification." _Monthly Weather Review_ 115. The joint-distribution framework; both factorizations (§3.1). The field's constitution.
2. ★ Murphy, A. H. (1993). "What is a good forecast? An essay on the nature of goodness in weather forecasting." _Weather and Forecasting_ 8. Consistency/quality/value; the attribute taxonomy.
3. Murphy, A. H. (1991). "Forecast verification: its complexity and dimensionality." _Monthly Weather Review_ 119 ⚑. Why scalar verification is lossy.
4. Murphy, A. H. (1996). "The Finley affair: a signal event in the history of forecast verification." _Weather and Forecasting_ 11. The origin controversy; the base-rate lesson.
5. ★ Jolliffe, I. T., and D. B. Stephenson, eds. (2012). _Forecast Verification: A Practitioner's Guide in Atmospheric Science_, 2nd ed. Wiley. The standard reference volume.
6. ★ Wilks, D. S. (2019). _Statistical Methods in the Atmospheric Sciences_, 4th ed. Elsevier. Ch. 9: the standard textbook treatment; discrimination diagrams.
7. Gneiting, T., and M. Katzfuss (2014). "Probabilistic forecasting." _Annual Review of Statistics and Its Application_ 1. The modern survey.
8. Dawid, A. P. (1984). "Statistical theory: the prequential approach." _JRSS-A_ 147. Sequential assessment; log score as prequential likelihood (§9.3); PIT's conceptual home.
9. Peirce, C. S. (1884). "The numerical measure of the success of predictions." _Science_ 4. The Peirce skill score.
10. Gilbert, G. K. (1884). "Finley's tornado predictions." _American Meteorological Journal_ 1 ⚑. The base-rate critique.
11. Heidke, P. (1926). Chance-corrected skill scoring (German original) ⚑. The Heidke skill score.
12. Doolittle, M. H. (1888). Association measures for the 2×2 table ⚑. Early contingency-table verification.

### 23.2 Proper scoring rules — theory

13. ★ Brier, G. W. (1950). "Verification of forecasts expressed in terms of probability." _Monthly Weather Review_ 78. The quadratic score.
14. Good, I. J. (1952). "Rational decisions." _JRSS-B_ 14. The logarithmic score.
15. ★ Savage, L. J. (1971). "Elicitation of personal probabilities and expectations." _JASA_ 66. The representation theorem; convex-$G$ construction (§9.1).
16. ★ Gneiting, T., and A. E. Raftery (2007). "Strictly proper scoring rules, prediction, and estimation." _JASA_ 102. The consolidation; CRPS, interval score, energy score.
17. ★ Schervish, M. J. (1989). "A general method for comparing probability assessors." _Annals of Statistics_ 17. Every proper binary score as a mixture of elementary cost–loss problems (§9.4). [V2 addition]
18. ★ Ehm, W., T. Gneiting, A. Jordan, and F. Krüger (2016). "Of quantiles and expectiles: consistent scoring functions, Choquet representations and forecast rankings." _JRSS-B_ 78. Murphy diagrams; empirically checkable dominance (§9.4, §18.2). [V2 addition]
19. Epstein, E. S. (1969). "A scoring system for probability forecasts of ranked categories." _Journal of Applied Meteorology_ 8. RPS.
20. Murphy, A. H. (1971). "A note on the ranked probability score." _Journal of Applied Meteorology_ 10 ⚑. RPS properties.
21. Matheson, J. E., and R. L. Winkler (1976). "Scoring rules for continuous probability distributions." _Management Science_ 22. CRPS's origin.
22. ★ Hersbach, H. (2000). "Decomposition of the continuous ranked probability score for ensemble prediction systems." _Weather and Forecasting_ 15. CRPS decomposition and computation.
23. Winkler, R. L. (1972). "A decision-theoretic approach to interval estimation." _JASA_ 67 ⚑. The interval score.
24. Winkler, R. L. (1996). "Scoring rules and the evaluation of probabilities." _Test_ 5 ⚑. Survey with elicitation focus.
25. Bröcker, J., and L. A. Smith (2007a). "Scoring probabilistic forecasts: the importance of being proper." _Weather and Forecasting_ 22. Impropriety corrupts evaluation.
26. Gneiting, T. (2011). "Making and evaluating point forecasts." _JASA_ 106. Consistent scoring functions for point summaries (§2).
27. Ferro, C. A. T., D. S. Richardson, and A. P. Weigel (2008). "On the effect of ensemble size on the discrete and continuous ranked probability scores." _Meteorological Applications_ 15 ⚑. Fair-score corrections.
28. Selten, R. (1998). "Axiomatic characterization of the quadratic scoring rule." _Experimental Economics_ 1 ⚑. Brier axiomatics. [V2 addition]
29. Benedetti, R. (2010). "Scoring rules for forecast verification." _Monthly Weather Review_ 138 ⚑. Axioms selecting the log score. [V2 addition]
30. ★ Gneiting, T., and R. Ranjan (2011). "Comparing density forecasts using threshold- and quantile-weighted scoring rules." _JBES_ 29. Proper ex-ante tail emphasis (§14.5). [V2 addition]
31. Diks, C., V. Panchenko, and D. van Dijk (2011). "Likelihood-based scoring rules for comparing density forecasts in tails." _Journal of Econometrics_ 163 ⚑. Censored/conditional likelihood scores. [V2 addition]
32. Patton, A. J. (2020). "Comparing possibly misspecified forecasts." _JBES_ 38 ⚑. Score choice changes rankings under misspecification (§9.6). [V2 addition]
33. Holzmann, H., and M. Eulert (2014). "The role of the information set for forecasting — with applications to risk management." _Annals of Applied Statistics_ 8 ⚑. Information-set nesting and proper scores (§3.2). [V2 addition]

### 23.3 Calibration, sharpness, decomposition

34. ★ Murphy, A. H. (1973). "A new vector partition of the probability score." _Journal of Applied Meteorology_ 12. The three-term decomposition.
35. Murphy, A. H. (1972). "Scalar and vector partitions of the probability score." _Journal of Applied Meteorology_ 11 ⚑ (two-part). Precursor partitions.
36. Sanders, F. (1963). "On subjective probability forecasting." _Journal of Applied Meteorology_ 2. The first reliability/resolution partition.
37. Murphy, A. H., and E. S. Epstein (1989). "Skill scores and correlation coefficients in model verification." _Monthly Weather Review_ 117. Skill-score decomposition.
38. ★ Gneiting, T., F. Balabdaoui, and A. E. Raftery (2007). "Probabilistic forecasts, calibration and sharpness." _JRSS-B_ 69. The paradigm paper; calibration modes; PIT diagnostics.
39. ★ Dawid, A. P. (1982). "The well-calibrated Bayesian." _JASA_ 77. Coherence implies expected calibration.
40. Oakes, D. (1985). "Self-calibrating priors do not exist." _JASA_ 80 ⚑. Impossibility counterpoint.
41. ★ Foster, D. P., and R. V. Vohra (1998). "Asymptotic calibration." _Biometrika_ 85. Calibration without knowledge; the insufficiency theorem (§4.2).
42. DeGroot, M. H., and S. E. Fienberg (1983). "The comparison and evaluation of forecasters." _The Statistician_ 32. Sufficiency/refinement ordering (§6.3).
43. Bröcker, J. (2009). "Reliability, sufficiency, and the decomposition of proper scores." _QJRMS_ 135. Bregman-generic decompositions.
44. Stephenson, D. B., C. A. S. Coelho, and I. T. Jolliffe (2008). "Two extra components in the Brier score decomposition." _Weather and Forecasting_ 23. Within-bin terms (§10.2).
45. Ferro, C. A. T., and T. E. Fricker (2012). "A bias-corrected decomposition of the Brier score." _QJRMS_ 138 ⚑. Small-sample estimator corrections.
46. ★ Dimitriadis, T., T. Gneiting, and A. I. Jordan (2021). "Stable reliability diagrams for probabilistic classifiers." _PNAS_ 118. CORP.
47. Bröcker, J., and L. A. Smith (2007b). "Increasing the reliability of reliability diagrams." _Weather and Forecasting_ 22. Consistency bars (§11.3).
48. Murphy, A. H., and R. L. Winkler (1977). "Reliability of subjective probability forecasts of precipitation and temperature." _JRSS-C_ 26. The landmark operational calibration record.
49. Tsyplakov, A. (2013). "Evaluation of probabilistic forecasts..." Working paper ⚑. Auto-calibration.
50. Lichtenstein, S., B. Fischhoff, and L. D. Phillips (1982). "Calibration of probabilities: the state of the art to 1980." In _Judgment under Uncertainty_. The human-overconfidence canon.
51. Weijs, S. V., R. van Nooijen, and N. van de Giesen (2010). "Kullback–Leibler divergence as a forecast skill score with classic reliability–resolution–uncertainty decomposition." _Monthly Weather Review_ 138 ⚑. Log-score decomposition (§6.2). [V2 addition]

### 23.4 ML calibration literature

52. Platt, J. (1999). "Probabilistic outputs for support vector machines..." In _Advances in Large Margin Classifiers_. Platt scaling.
53. Zadrozny, B., and C. Elkan (2002). "Transforming classifier scores into accurate multiclass probability estimates." _KDD_. Isotonic recalibration.
54. Niculescu-Mizil, A., and R. Caruana (2005). "Predicting good probabilities with supervised learning." _ICML_. Which learners miscalibrate and how.
55. Naeini, M. P., G. Cooper, and M. Hauskrecht (2015). "Obtaining well calibrated probabilities using Bayesian binning." _AAAI_. ECE's modern form.
56. ★ Guo, C., G. Pleiss, Y. Sun, and K. Q. Weinberger (2017). "On calibration of modern neural networks." _ICML_. Temperature scaling; the field's reawakening.
57. Kull, M., T. Silva Filho, and P. Flach (2017). "Beta calibration..." _AISTATS_. Beta calibration.
58. Kumar, A., P. Liang, and T. Ma (2019). "Verified uncertainty calibration." _NeurIPS_. Binning pathologies of ECE.
59. Nixon, J., et al. (2019). "Measuring calibration in deep learning." _CVPR workshops_ ⚑. Adaptive binning.
60. Vaicenavicius, J., et al. (2019). "Evaluating model calibration in classification." _AISTATS_ ⚑. Estimation-theoretic critique.
61. Kuleshov, V., N. Fenner, and S. Ermon (2018). "Accurate uncertainties for deep learning using calibrated regression." _ICML_. Quantile recalibration (§4.3). [V2 addition]
62. Vovk, V., A. Gammerman, and G. Shafer (2005). _Algorithmic Learning in a Random World_. Springer. Conformal prediction's foundation (§4.1, §22). [V2 addition]
63. Angelopoulos, A. N., and S. Bates (2021). "A gentle introduction to conformal prediction and distribution-free uncertainty quantification." arXiv ⚑. The modern tutorial. [V2 addition]

### 23.5 Ensembles, rank histograms, PIT

64. Anderson, J. L. (1996). "A method for producing and evaluating probabilistic forecasts from ensemble model integrations." _Journal of Climate_ 9. Rank histogram origin.
65. Talagrand, O., R. Vautard, and B. Strauss (1997). "Evaluation of probabilistic prediction systems." ECMWF workshop proceedings. The Talagrand diagram.
66. Hamill, T. M., and S. J. Colucci (1997). "Verification of Eta–RSM short-range ensemble forecasts." _Monthly Weather Review_ 125. Early operational practice.
67. ★ Hamill, T. M. (2001). "Interpretation of rank histograms for verifying ensemble forecasts." _Monthly Weather Review_ 129. Flatness insufficient; compensating errors.
68. Gneiting, T., A. E. Raftery, A. H. Westveld, and T. Goldman (2005). "Calibrated probabilistic forecasting using ensemble model output statistics and minimum CRPS estimation." _Monthly Weather Review_ 133. EMOS/NGR.
69. Raftery, A. E., T. Gneiting, F. Balabdaoui, and M. Polakowski (2005). "Using Bayesian model averaging to calibrate forecast ensembles." _Monthly Weather Review_ 133. BMA post-processing.
70. Rosenblatt, M. (1952). "Remarks on a multivariate transformation." _Annals of Mathematical Statistics_ 23. The PIT's origin (§13). [V2 addition]
71. Berkowitz, J. (2001). "Testing density forecasts, with applications to risk management." _JBES_ 19. Joint uniformity–independence LR test on PIT (§13). [V2 addition]
72. Czado, C., T. Gneiting, and L. Held (2009). "Predictive model assessment for count data." _Biometrics_ 65. Discrete PIT.
73. Brockwell, A. E. (2007). "Universal residuals: a multivariate transformation." _Statistics & Probability Letters_ 77 ⚑. Randomized PIT.
74. Wilks, D. S. (2004). "The minimum spanning tree histogram..." _Monthly Weather Review_ 132 ⚑. Multivariate rank precursor.
75. Gneiting, T., L. I. Stanberry, E. P. Grimit, L. Held, and N. A. Johnson (2008). "Assessing probabilistic forecasts of multivariate quantities..." _Test_ 17 ⚑. Multivariate rank histograms; energy-score practice (§2, §12). [V2 addition]
76. Scheuerer, M., and T. M. Hamill (2015). "Variogram-based proper scoring rules for probabilistic forecasts of multivariate quantities." _Monthly Weather Review_ 143. The variogram score (§2). [V2 addition]
77. Buizza, R., P. L. Houtekamer, et al. (2005). "A comparison of the ECMWF, MSC, and NCEP global ensemble prediction systems." _Monthly Weather Review_ 133 ⚑. Operational ensemble benchmark.

### 23.6 Weather-specific verification and observation error

78. Glahn, H. R., and D. A. Lowry (1972). "The use of Model Output Statistics (MOS) in objective weather forecasting." _Journal of Applied Meteorology_ 11. MOS.
79. ★ Hamill, T. M., and J. Juras (2006). "Measuring forecast skill: is it real skill or is it the varying climatology?" _QJRMS_ 132. The pooling trap (§14.4).
80. Roberts, N. M., and H. W. Lean (2008). "Scale-selective verification of rainfall accumulations..." _Monthly Weather Review_ 136. Fractions Skill Score.
81. Ebert, E. E. (2008). "Fuzzy verification of high-resolution gridded forecasts..." _Meteorological Applications_ 15. Neighborhood methods survey.
82. Gilleland, E., D. Ahijevych, B. G. Brown, B. Casati, and E. E. Ebert (2009). "Intercomparison of spatial forecast verification methods." _Weather and Forecasting_ 24. The spatial intercomparison.
83. Wernli, H., M. Paulat, M. Hagen, and C. Frei (2008). "SAL — a novel quality measure..." _Monthly Weather Review_ 136. Object-based verification.
84. Mason, I. B. (1982). "A model for assessment of weather forecasts." _Australian Meteorological Magazine_ 30. ROC in meteorology.
85. Mason, S. J., and N. E. Graham (2002). "Areas beneath the relative operating characteristics (ROC) and relative operating levels (ROL) curves." _QJRMS_ 128 ⚑. ROC statistics.
86. ★ Ferro, C. A. T., and D. B. Stephenson (2011). "Extremal dependence indices: improved verification measures for deterministic forecasts of rare binary events." _Weather and Forecasting_ 26. EDI/SEDI (§14.5). [V2 addition]
87. ★ Lerch, S., T. L. Thorarinsdottir, F. Ravazzolo, and T. Gneiting (2017). "Forecaster's dilemma: extreme events and forecast evaluation." _Statistical Science_ 32. Outcome-conditioned evaluation rewards overforecasting (§14.7). [V2 addition]
88. Candille, G., and O. Talagrand (2005). "Evaluation of probabilistic prediction systems for a scalar variable." _QJRMS_ 131 ⚑. Includes observation-error effects on probabilistic verification (§14.6). [V2 addition]
89. Bowler, N. E. (2006). "Explicitly accounting for observation error in categorical verification of forecasts." _Monthly Weather Review_ 134 ⚑. Observation-error correction (§14.6). [V2 addition]
90. Saetra, Ø., H. Hersbach, J.-R. Bidlot, and D. S. Richardson (2004). "Effects of observation errors on the statistics for ensemble spread and reliability." _Monthly Weather Review_ 132 ⚑. Observation error and rank histograms (§12, §14.6). [V2 addition]
91. Baars, J. A., and C. F. Mass (2005). "Performance of National Weather Service forecasts compared to operational, consensus, and weighted model output statistics." _Weather and Forecasting_ 20 ⚑. Human-vs-guidance verification.
92. Novak, D. R., et al. (2014). "Precipitation and temperature forecast performance at the Weather Prediction Center." _Weather and Forecasting_ 29 ⚑. Long-run operational record.
93. WMO JWGFVR. "Forecast Verification: Issues, Methods and FAQ." Maintained web resource ⚑. Snapshot before citing.
94. ECMWF. Annual verification reports and headline-score documentation ⚑. Snapshot before citing.
95. Murphy, A. H., and H. Daan (1985). "Forecast evaluation." In _Probability, Statistics, and Decision Making in the Atmospheric Sciences_ ⚑. Pre-1987 synthesis.

### 23.7 Prediction markets and betting-odds probabilities

96. Hayek, F. A. (1945). "The use of knowledge in society." _American Economic Review_ 35. Prices as information aggregators.
97. ★ Wolfers, J., and E. Zitzewitz (2004). "Prediction markets." _Journal of Economic Perspectives_ 18. The modern survey.
98. ★ Wolfers, J., and E. Zitzewitz (2006). "Interpreting prediction market prices as probabilities." NBER WP 12200. Conditions for price ≈ mean belief.
99. ★ Manski, C. F. (2006). "Interpreting the predictions of prediction markets." _Economics Letters_ 91. The bounds critique.
100. Arrow, K. J., et al. (2008). "The promise of prediction markets." _Science_ 320. The institutional case.
101. Berg, J., R. Forsythe, F. Nelson, and T. Rietz (2008). "Results from a dozen years of election futures markets research." In _Handbook of Experimental Economics Results_ ⚑. IEM record.
102. Hanson, R. (2003). "Combinatorial information market design." _Information Systems Frontiers_ 5 ⚑. LMSR; market-making as log-score elicitation (§15.1).
103. Ali, M. M. (1977). "Probability and utility estimates for racetrack bettors." _Journal of Political Economy_ 85. FLB measurement.
104. Thaler, R. H., and W. T. Ziemba (1988). "Anomalies: parimutuel betting markets." _Journal of Economic Perspectives_ 2. FLB survey.
105. ★ Snowberg, E., and J. Wolfers (2010). "Explaining the favorite–longshot bias: is it risk-love or misperceptions?" _Journal of Political Economy_ 118. The discrimination test; favors misperception.
106. ★ Shin, H. S. (1993). "Measuring the incidence of insider trading in a market for state-contingent claims." _Economic Journal_ 103. Structural de-margining; FLB-corrective by construction (§15.8). [V2 addition]
107. ★ Štrumbelj, E. (2014). "On determining probability forecasts from betting odds." _International Journal of Forecasting_ 30 ⚑. Empirical comparison of normalization methods; Shin-class outperforms basic normalization (§15.8). [V2 addition]
108. Page, L., and R. T. Clemen (2013). "Do prediction markets produce well-calibrated probability forecasts?" _Economic Journal_ 123 ⚑. Horizon-dependent calibration.
109. Rothschild, D. (2009). "Forecasting elections: comparing prediction markets, polls, and their biases." _Public Opinion Quarterly_ 73 ⚑. Debiasing market prices.
110. Servan-Schreiber, E., J. Wolfers, D. Pennock, and B. Galebach (2004). "Prediction markets: does money matter?" _Electronic Markets_ 14 ⚑. Real vs. play money.
111. Fama, E. F. (1970). "Efficient capital markets: a review of theory and empirical work." _Journal of Finance_ 25. The null's charter.
112. Grossman, S. J., and J. E. Stiglitz (1980). "On the impossibility of informationally efficient markets." _American Economic Review_ 70. Why some inefficiency must persist.
113. Tetlock, P. C. (2004). "How efficient are information markets? Evidence from an online exchange." Working paper / journal version ⚑. Exchange pricing efficiency.

### 23.8 Judgment and aggregation

114. Tetlock, P. E. (2005). _Expert Political Judgment_. Princeton UP. The long-horizon expert verification study.
115. Mellers, B., et al. (2014). "Psychological strategies for winning a geopolitical forecasting tournament." _Psychological Science_ 25 ⚑. The GJP evidence base. [V2 addition — replaces trade-book-only citation]
116. Tetlock, P. E., and D. Gardner (2015). _Superforecasting_. Crown. Trade synthesis of the above.
117. Kahneman, D., P. Slovic, and A. Tversky, eds. (1982). _Judgment under Uncertainty_. Cambridge UP. The bias canon.
118. Clemen, R. T. (1989). "Combining forecasts: a review and annotated bibliography." _International Journal of Forecasting_ 5. Averaging is hard to beat.
119. Ranjan, R., and T. Gneiting (2010). "Combining probability forecasts." _JRSS-B_ 72 ⚑. Linear pools are uncalibrated; recalibrated combining.

### 23.9 Statistical inference for forecast comparison

120. ★ Diebold, F. X., and R. S. Mariano (1995). "Comparing predictive accuracy." _JBES_ 13. The paired-differential test.
121. Harvey, D., S. Leybourne, and P. Newbold (1997). "Testing the equality of prediction mean squared errors." _International Journal of Forecasting_ 13. Small-sample correction.
122. ★ Giacomini, R., and H. White (2006). "Tests of conditional predictive ability." _Econometrica_ 74. Conditional comparison.
123. Clark, T. E., and K. D. West (2007). "Approximately normal tests for equal predictive accuracy in nested models." _Journal of Econometrics_ 138. The nested-model correction (§17.2). [V2 addition]
124. Diebold, F. X. (2015). "Comparing predictive accuracy, twenty years later." _JBES_ 33 ⚑. Use and abuse of DM.
125. Künsch, H. R. (1989). "The jackknife and the bootstrap for general stationary observations." _Annals of Statistics_ 17. Moving-block bootstrap.
126. Politis, D. N., and J. P. Romano (1994). "The stationary bootstrap." _JASA_ 89. Stationary bootstrap.
127. Newey, W. K., and K. D. West (1987). "A simple, positive semi-definite, heteroskedasticity and autocorrelation consistent covariance matrix." _Econometrica_ 55. HAC variance.
128. Hamill, T. M. (1999). "Hypothesis tests for evaluating numerical precipitation forecasts." _Weather and Forecasting_ 14 ⚑. Resampling tests in verification.
129. Efron, B., and R. J. Tibshirani (1993). _An Introduction to the Bootstrap_. Chapman & Hall. The bootstrap reference.
130. ★ Benjamini, Y., and Y. Hochberg (1995). "Controlling the false discovery rate." _JRSS-B_ 57. FDR.
131. ★ White, H. (2000). "A reality check for data snooping." _Econometrica_ 68. Bootstrap multiplicity.
132. Hansen, P. R. (2005). "A test for superior predictive ability." _JBES_ 23. SPA.
133. Romano, J. P., and M. Wolf (2005). "Stepwise multiple testing as formalized data snooping." _Econometrica_ 73 ⚑. Stepdown.
134. Ramdas, A., et al. (2017–2018). Online false discovery rate control (LORD/SAFFRON lineage) ⚑. Sequential-testing frontier (§16.6, §22). [V2 addition]
135. Gelman, A., and E. Loken (2014). "The statistical crisis in science." _American Scientist_ 102. Forking paths.
136. Gelman, A., and J. Carlin (2014). "Beyond power calculations: assessing Type S and Type M errors." _Perspectives on Psychological Science_ 9 ⚑. Low-power exaggeration (§17.6).
137. Ioannidis, J. P. A. (2005). "Why most published research findings are false." _PLoS Medicine_ 2. The base-rate argument for skepticism.
138. Harvey, C. R., Y. Liu, and H. Zhu (2016). "…and the cross-section of expected returns." _Review of Financial Studies_ 29. The factor zoo.
139. Bailey, D. H., J. Borwein, M. López de Prado, and Q. J. Zhu (2014). "Pseudo-mathematics and financial charlatanism..." _Notices of the AMS_ 61 ⚑. Backtest overfitting.
140. Sullivan, R., A. Timmermann, and H. White (1999). "Data-snooping, technical trading rule performance, and the bootstrap." _Journal of Finance_ 54 ⚑. Reality Check applied.
141. Brown, S. J., W. Goetzmann, R. G. Ibbotson, and S. A. Ross (1992). "Survivorship bias in performance studies." _Review of Financial Studies_ 5 ⚑. The survivorship canon (§16.2).

### 23.10 Decision theory, value, and Kelly

142. Thompson, J. C. (1952). "On the operational deficiencies in categorical weather forecasts." _Bulletin of the AMS_ 33 ⚑. Cost–loss origins.
143. Murphy, A. H. (1977). "The value of climatological, categorical and probabilistic forecasts in the cost–loss ratio situation." _Monthly Weather Review_ 105. Cost–loss value of probabilities.
144. Katz, R. W., and A. H. Murphy, eds. (1997). _Economic Value of Weather and Climate Forecasts_. Cambridge UP. The value volume.
145. ★ Richardson, D. S. (2000). "Skill and relative economic value of the ECMWF ensemble prediction system." _QJRMS_ 126. Potential economic value.
146. Zhu, Y., Z. Toth, R. Wobus, D. Richardson, and K. Mylne (2002). "The economic value of ensemble-based weather forecasts." _Bulletin of the AMS_ 83. Value curves for ensembles.
147. Murphy, A. H., and M. Ehrendorfer (1987). "On the relationship between the accuracy and value of forecasts..." _Weather and Forecasting_ 2 ⚑. Quality–value non-monotonicity.
148. ★ Kelly, J. L., Jr. (1956). "A new interpretation of information rate." _Bell System Technical Journal_ 35. Log-optimal betting.
149. Cover, T. M., and J. A. Thomas (2006). _Elements of Information Theory_, 2nd ed. Wiley. Ch. 6: gambling and side information.
150. Roulston, M. S., and L. A. Smith (2002). "Evaluating probabilistic forecasts using information theory." _Monthly Weather Review_ 130. Ignorance score; information deficits.
151. MacLean, L. C., E. O. Thorp, and W. T. Ziemba, eds. (2011). _The Kelly Capital Growth Investment Criterion_. World Scientific. The Kelly anthology.

### 23.11 Philosophy of probability

152. de Finetti, B. (1974). _Theory of Probability_, Vol. 1. Wiley. Operational subjectivism.
153. Savage, L. J. (1954). _The Foundations of Statistics_. Wiley. Subjective expected utility.
154. Hacking, I. (1975). _The Emergence of Probability_. Cambridge UP. Historical-philosophical context.

---

## Maintenance

**Update triggers.** (i) Verification of any ⚑ entry — replace flag with E-grade and date. (ii) Ratification of A1 — reconcile §9.5's boundary rule, §13's discrete-PIT choice, §17's clustering scheme, and the D-FV directives with A1's registered decisions; demote any conflicting statement here. (iii) Ratification of A4 — reconcile §15.8's normalization treatment and D-FV-7. (iv) Settlement-source resolution — update §14.1/§14.6. (v) First CORP and Murphy-diagram implementations — add worked cross-references. (vi) V2 ensemble rung — activate §12/§13 operationally; revisit §2's multivariate paragraph.

**Deprecation rules.** Where this synthesis and any ratified A-series document disagree, the A-series document governs; this note is literature context, never a registration source. Document-V1 is superseded in full and should be deleted from the vault, not retained alongside (single-source rule); this section's [NEW]-flagged directives are proposals pending Architect ratification, not standing policy.

**Verification queue.** ★ tier first (n = 30, of which 8 are V2 additions: Schervish 1989; Ehm et al. 2016; Gneiting–Ranjan 2011; Ferro–Stephenson 2011; Lerch et al. 2017; Shin 1993; Štrumbelj 2014 — plus re-confirmation of Dimitriadis et al. 2021); then entries feeding Open Question 1 (§23.7 FLB cluster); then lazily on first use. Bürgi–Deng–Whelan enters only after its own primary-source verification per [[Edge Detection]].