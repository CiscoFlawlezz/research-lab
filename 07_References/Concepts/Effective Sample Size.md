# Effective Sample Size

**Vault location:** `07_References/Concepts` **Cross-links:** [[Probability]] · [[Forecast Verification]] · [[Proper Scoring Rules and Calibration - Technical Reference (V2)]] · [[Edge Detection]] · [[Kelly Criterion]] · [[Bayesian Statistics]] · [[Statistical Learning Theory]] · [[Machine Learning]] · [[Expected Value]] · [[Open Questions]] **Status:** V2 complete rewrite — **E4, pending Architect ratification.** The Standing Rule in §0 is carried verbatim from V1 (2026-07-04) and remains operative regardless of this draft's ratification status. **Created:** 2026-07-04 · **Rewritten:** 2026-07-15 **Notation:** Lab standard — qq q true distribution, pp p lab forecast, rr r market-implied; information in nats.

> [!abstract] Epistemic status The mathematics in §§1–4 and §6 is standard, textbook-grade material restated for this Lab's structure; individual citations carry ⚑ flags as unverified testimony per Invariant 3. §5's _bracket-layer_ discount is exact (a theorem about the data-generating structure, not an estimate). §5's _cross-city_ and _serial_ discounts are unknown empirical quantities awaiting [[Open Questions]] Q3; every number attached to them below is explicitly hypothetical. Nothing in this document is derived from Lab data, because the relevant Lab data does not yet exist.

---

## 0. The Standing Rule (operative; unchanged from V1)

**The unit of statistical evidence in this project is the city-day.** All standard errors, confidence intervals, and hypothesis tests must respect the dependence structure: **cluster by date, or block-bootstrap by date.**

Standing consequences:

1. Any analysis quoting nn n in the high hundreds after one month of collection is double-counting → **rejected on sight**.
2. Reliability diagrams must carry bootstrap/consistency bands, resampled **by date**, never by contract.
3. Model-vs-market comparisons use paired score differentials on identical events with date-clustered inference (Diebold–Mariano style or block bootstrap) — see [[Forecast Verification]] §17.
4. Collection-duration requirements for any experiment are derived from _city-day_ counts. This is the quantitative reason patience is load-bearing in the charter, not decorative.
5. Every sample-size argument anywhere in the Lab — validation-set sufficiency, calibration-bin counts, capacity budgets (D-SLT-1), Kelly confidence schedules — uses dependence-corrected neffn_{\text{eff}} neff​, never nominal row counts.

Everything below is the _why_, the _how much_, and the _how to measure_.

---

## 1. What Effective Sample Size Measures

### 1.1 Definition

Fix an estimand θ\theta θ (a mean score, a calibration frequency, a score differential) and an estimator θ^\hat\theta θ^ computed from nn n observations. The **effective sample size** is the number of hypothetical IID observations that would give the same estimator the same variance:

neff  =  n⋅Var(θ^iid)Var(θ^),n_{\text{eff}} \;=\; n \cdot \frac{\mathrm{Var}\big(\hat\theta_{\text{iid}}\big)}{\mathrm{Var}\big(\hat\theta\big)},neff​=n⋅Var(θ^)Var(θ^iid​)​,

where Var(θ^iid)\mathrm{Var}(\hat\theta_{\text{iid}}) Var(θ^iid​) is the variance the estimator _would_ have if the nn n observations were independent with the same marginals. Equivalently, for a sample mean of a stationary sequence with marginal variance σ2\sigma^2 σ2,

Var(Xˉ)  =  σ2neff.\mathrm{Var}(\bar X) \;=\; \frac{\sigma^2}{n_{\text{eff}}}.Var(Xˉ)=neff​σ2​.

The reciprocal ratio d=n/neffd = n / n_{\text{eff}} d=n/neff​ is the **variance inflation factor**, called the **design effect** (deff) in the survey literature (⚑ Kish 1965). All three objects — neffn_{\text{eff}} neff​, VIF, deff — are one concept in three currencies.

**Intuition.** nn n counts rows in a table. neffn_{\text{eff}} neff​ counts _independent looks at the world_. Dependence means some rows partially repeat information already carried by other rows; the repeated portion contributes nothing to variance reduction. ESS is the row count after deleting the redundancy.

### 1.2 Information versus observations

The Fisher-information reading makes the same point without variances: for a parametric model, the information carried by nn n dependent observations is generally less than nn n times the per-observation information, because the conditional information of observation kk k given observations 1,…,k−11,\dots,k-1 1,…,k−1 shrinks as dependence rises. In the limit of perfect dependence, observation 2 has zero conditional information — you already knew it. This is the entropy-rate view: a dependent process has H(Xk∣X<k)<H(Xk)H(X_k \mid X_{<k}) < H(X_k) H(Xk​∣X<k​)<H(Xk​), and evidence accrues at the conditional rate, not the marginal rate ([[Information Theory for Forecasting]]). The Lab's accrual clock runs on conditional information, and the wall-clock constraint on V1 exit is exactly this: independent looks at weather cannot be manufactured, only waited for.

### 1.3 ESS is a property of (data, estimator, estimand) — never of data alone

There is no such thing as "the ESS of our dataset." The same dependent dataset has different effective sizes for different targets:

- Positive autocorrelation _reduces_ ESS for estimating a **mean** but can _help_ when estimating a **change or trend** (differencing cancels the shared component).
- The ESS for a **variance** or a **tail quantile** differs from the ESS for the mean of the same series, because different features of the dependence structure govern each estimator's sampling variance.
- Within this Lab: the city-day is the honest unit for **outcome-resolved claims** (calibration, skill, score differentials — anything graded against settlements). Claims about **microstructure** (spread dynamics, quote staleness, depth) resolve at the quote level and may have a different honest unit; that unit must be argued per-claim, not inherited from this rule. What is _never_ correct is inheriting the nominal row count.

Every registered analysis must therefore state its estimand, its estimator, and the dependence structure it corrects for. "We used neffn_{\text{eff}} neff​" without those three is not compliance.

### 1.4 When neff=nn_{\text{eff}} = n neff​=n, when less, when more

- **Equal:** IID sampling, or dependence structure orthogonal to the estimator (rare; must be shown, not assumed).
- **Less (the Lab's regime):** positive dependence of any of the forms in §2. This is the overwhelmingly common case for observational time-space data.
- **More:** _negative_ dependence. Stratified sampling achieves deff < 1 by construction (⚑ Cochran 1977); antithetic Monte Carlo variates are designed for it; well-tuned NUTS chains sometimes exhibit anti-correlated draws with reported ESS above the raw draw count — a legitimate readout, not a diagnostic bug ([[Bayesian Statistics]] §19). No naturally occurring layer of this Lab's data is negatively dependent for mean-type estimands; treat any n^eff>n\widehat{n}_{\text{eff}} > n neff​>n on Lab data as a red flag for estimator error first.

---

## 2. Why Dependence Destroys Information

The mechanism is one line of algebra ([[Probability]] §5.4). For identically distributed X1,…,XnX_1,\dots,X_n X1​,…,Xn​ with variance σ2\sigma^2 σ2 and correlations ρij\rho_{ij} ρij​:

Var ⁣(1n∑iXi)  =  σ2n[ 1+2n∑i<jρij].\mathrm{Var}\!\left(\frac{1}{n}\sum_i X_i\right) \;=\; \frac{\sigma^2}{n}\Bigg[\,1 + \frac{2}{n}\sum_{i<j}\rho_{ij}\Bigg].Var(n1​i∑​Xi​)=nσ2​[1+n2​i<j∑​ρij​].

Independence sets the bracketed term to 1 and delivers the familiar σ2/n\sigma^2/n σ2/n. Positive correlations add (n2)\binom{n}{2} (2n​) nonnegative terms that the naive formula silently drops. Every inferential procedure that assumes independent rows — a tt t-test on 900 contract-rows, a binomial CI on a calibration bin filled with same-day brackets — drops exactly these covariance terms and understates its own variance by the factor in brackets. Nothing about the estimator's _point value_ changes; only the claimed precision is wrong. That is what makes the error insidious: the numbers look identical, and only the error bars lie.

The forms this takes in practice:

- **Temporal autocorrelation** — persistence in weather, in scores, in market behavior; adjacent days share information.
- **Spatial / cross-sectional correlation** — five cities under one continental synoptic pattern; a heat dome is one event wearing five costumes.
- **Clustering / repeated measures** — multiple rows generated by one underlying draw: brackets within a city-day (the extreme case, §5.1), repeated intraday snapshots of one contract (§5.4), multiple forecasts derived from one NWP model cycle.
- **Hierarchical / longitudinal structure** — city-level effects shared across all of a city's days; season-level effects shared across all days in a season. Partial pooling ([[Bayesian Statistics]]) _models_ this structure; ESS accounting _prices_ it when it is left unmodeled.

---

## 3. The Canonical Formulations

Different literatures derived ESS for their own dependence structures. The formulas differ because the structures differ; choosing the right one is choosing the right model of the redundancy.

### 3.1 Time-series ESS (serial autocorrelation)

For a stationary sequence with autocorrelation function ρk\rho_k ρk​, the exact finite-nn n variance of the mean is

Var(Xˉ)=σ2n[ 1+2∑k=1n−1(1−kn)ρk],\mathrm{Var}(\bar X) = \frac{\sigma^2}{n}\left[\,1 + 2\sum_{k=1}^{n-1}\Big(1-\frac{k}{n}\Big)\rho_k\right],Var(Xˉ)=nσ2​[1+2k=1∑n−1​(1−nk​)ρk​],

giving asymptotically

neff  ≈  n1+2∑k=1∞ρk  =  nτ,n_{\text{eff}} \;\approx\; \frac{n}{1 + 2\sum_{k=1}^{\infty}\rho_k} \;=\; \frac{n}{\tau},neff​≈1+2∑k=1∞​ρk​n​=τn​,

where τ\tau τ is the **integrated autocorrelation time** — the number of steps the process takes to produce one effectively independent draw. (⚑ Standard; see Hamilton 1994 for the spectral view: τ=2πf(0)/σ2\tau = 2\pi f(0)/\sigma^2 τ=2πf(0)/σ2, the long-run variance ratio, which is exactly what HAC/Newey–West estimators target.)

**AR(1) closed form.** If ρk=ρk\rho_k = \rho^k ρk​=ρk, then ∑ρk=ρ/(1−ρ)\sum \rho_k = \rho/(1-\rho) ∑ρk​=ρ/(1−ρ) and

neff=n 1−ρ1+ρ.n_{\text{eff}} = n\,\frac{1-\rho}{1+\rho}.neff​=n1+ρ1−ρ​.

Calibration points: ρ=0.3⇒neff≈0.54 n\rho = 0.3 \Rightarrow n_{\text{eff}} \approx 0.54\,n ρ=0.3⇒neff​≈0.54n; ρ=0.5⇒n/3\rho = 0.5 \Rightarrow n/3 ρ=0.5⇒n/3; ρ=0.7⇒0.18 n\rho = 0.7 \Rightarrow 0.18\,n ρ=0.7⇒0.18n. Daily maximum temperatures exhibit strong positive lag-1 correlation; **score differentials** (the object A1 actually tests) are typically much less autocorrelated than raw outcomes because differencing two forecasts of the same event cancels shared weather — one of the reasons paired designs are registered policy ([[Forecast Verification]] §17.2). Which ρ1\rho_1 ρ1​ governs the Lab's power calculations is precisely Q3's target: the autocorrelation _of the score differential series_, not of temperature.

**Assumptions:** stationarity; summable autocorrelations; mean-type estimand. Fails under nonstationarity (seasonality must be removed or modeled first) and long memory (∑ρk=∞\sum\rho_k = \infty ∑ρk​=∞, where Var(Xˉ)\mathrm{Var}(\bar X) Var(Xˉ) decays slower than any 1/neff1/n_{\text{eff}} 1/neff​ — flag if score series ever suggest this ⚑).

### 3.2 Clustered data: the design effect (Kish)

Observations arrive in GG G clusters of size mm m with intra-class correlation ρICC\rho_{\text{ICC}} ρICC​ (correlation between two members of the same cluster; clusters independent). Then for the grand mean,

d  =  1+(m−1) ρICC,neff=Gm1+(m−1)ρICC.d \;=\; 1 + (m-1)\,\rho_{\text{ICC}}, \qquad n_{\text{eff}} = \frac{Gm}{1+(m-1)\rho_{\text{ICC}}}.d=1+(m−1)ρICC​,neff​=1+(m−1)ρICC​Gm​.

(⚑ Kish 1965.) Two limits anchor intuition: ρICC=0\rho_{\text{ICC}} = 0 ρICC​=0 gives neff=Gmn_{\text{eff}} = Gm neff​=Gm (clustering harmless); ρICC=1\rho_{\text{ICC}} = 1 ρICC​=1 gives neff=Gn_{\text{eff}} = G neff​=G — **each cluster is one observation**, however many rows it contains. Unequal cluster sizes worsen the effect (replace mm m with a size-weighted term ⚑).

### 3.3 Unequal-weight ESS (a different Kish formula — do not conflate)

For a _weighted_ mean of independent observations with weights wiw_i wi​,

neff=(∑iwi)2∑iwi2.n_{\text{eff}} = \frac{\big(\sum_i w_i\big)^2}{\sum_i w_i^2}.neff​=∑i​wi2​(∑i​wi​)2​.

This measures information lost to weight dispersion, **not** to dependence — the observations here are independent. The two Kish formulas answer different questions and are routinely confused in applied work. In this Lab the weighting form appears if analyses ever weight city-days (by liquidity, by market volume); it _compounds with_, and does not substitute for, the clustering correction.

### 3.4 Cluster-robust inference: the asymptotics run on clusters

Cluster-robust ("sandwich") standard errors do not require estimating ρICC\rho_{\text{ICC}} ρICC​; they estimate the cluster-level variance directly and are the model-free implementation of §3.2. The crucial fine print: their asymptotic justification is in the **number of clusters GG G**, not the number of rows (⚑ Cameron & Miller 2015). Test statistics should be referred to tG−1t_{G-1} tG−1​-type references, and with few clusters (rule of thumb: G≲40G \lesssim 40 G≲40–50, worse when unbalanced) even that is anti-conservative — wild-cluster bootstrap is the standard repair (⚑ Cameron, Gelbach & Miller 2008). **Lab translation:** clustering by date makes each _date_ one cluster; after one month, G≈30G \approx 30 G≈30. A month of data is thirty clusters — small-GG G territory. This is an independent argument, on top of §5, for why early inference must be humble and bootstrap-based.

For purely serial dependence on a single series, the HAC/Newey–West family (⚑ Newey & West 1987) plays the analogous role: kernel-weighted long-run variance with a bandwidth choice that is the smoothing analogue of block length.

### 3.5 Spatial ESS

For nn n sites with spatial correlation matrix RR R, the ESS for the field mean is neff=1⊤R−11n_{\text{eff}} = \mathbf{1}^\top R^{-1} \mathbf{1} neff​=1⊤R−11 under a common-mean Gaussian model ⚑, and dedicated corrections exist for correlation _between two_ spatial fields (⚑ Clifford, Richardson & Hémon 1989 — directly relevant if the Lab ever correlates two cross-city quantities). At five cities, formal spatial modeling is overkill; the equicorrelation approximation of §5.2 plus date-clustering (which absorbs _arbitrary_ same-day cross-city dependence, model-free) is the registered posture. The spatial literature matters here mainly as a warning: spatial correlation ranges for synoptic-scale weather are continental, so "our cities are far apart" is not an independence argument.

### 3.6 MCMC ESS

The Monte Carlo error of a posterior mean estimated from correlated chain draws is SE≈σ/neff\mathrm{SE} \approx \sigma/\sqrt{n_{\text{eff}}} SE≈σ/neff​​ with neff=NM/τn_{\text{eff}} = NM/\tau neff​=NM/τ across MM M chains of length NN N — §3.1's formula wearing computational clothes; the concept is _identical_ to city-day discounting ([[Bayesian Statistics]] §9.1). Modern practice (⚑ Vehtari, Gelman, Simpson, Carpenter & Bürkner 2021): estimate τ\tau τ with Geyer's initial-sequence truncation (⚑ Geyer 1992) combined across split chains; report **bulk-ESS** (center of the posterior) and **tail-ESS** (quantiles) separately — tail-ESS governs the credible-interval endpoints that decisions consume and is the binding diagnostic for this Lab. The mandatory diagnostic block is specified in [[Bayesian Statistics]] §19; this section exists so that "ESS" in an MCMC context and "ESS" in an evidential-accounting context are visibly one concept.

### 3.7 Choosing among formulations

|Structure|Formula|Key assumption|Lab use|
|---|---|---|---|
|Serial only|n/τn/\tau n/τ; AR(1): n1−ρ1+ρn\frac{1-\rho}{1+\rho} n1+ρ1−ρ​|stationarity, summable ρk\rho_k ρk​|day-to-day layer, per city|
|Equal clusters|n/[1+(m−1)ρICC]n/[1+(m-1)\rho_{\text{ICC}}] n/[1+(m−1)ρICC​]|clusters independent|brackets in a city-day; cities in a day (approx.)|
|Weights|(∑w)2/∑w2(\sum w)^2/\sum w^2 (∑w)2/∑w2|independence!|weighted analyses only|
|Cluster-robust / block bootstrap|nonparametric|asymptotics in GG G|**registered default: cluster/block by date**|
|MCMC|NM/τNM/\tau NM/τ, bulk & tail|chain stationarity|posterior diagnostics|

When layers combine (brackets in city-days in correlated dates), closed-form deffs multiply only approximately and only under independence _between_ layers. The registered default — date-clustered inference and date-blocked bootstrap — sidesteps the multiplication by treating the largest dependent unit as the resampling atom. Closed forms are for planning and intuition; resampling is for reported inference.

---

## 4. Statistical Consequences of Getting It Wrong

### 4.1 False precision, quantified

If the true variance of an estimator is dd d times the naively computed one, every reported standard error is understated by d\sqrt{d} d​, a nominal 95% CI has actual coverage 2Φ(1.96/d)−12\Phi(1.96/\sqrt{d}) - 1 2Φ(1.96/d​)−1, and a nominal 5% two-sided test has actual size 2(1−Φ(1.96/d))2\big(1 - \Phi(1.96/\sqrt{d})\big) 2(1−Φ(1.96/d​)):

|deff dd d|Actual coverage of "95%" CI|Actual size of "5%" test|
|---|---|---|
|1|95%|5%|
|2|≈ 83%|≈ 17%|
|3|≈ 74%|≈ 26%|
|4|≈ 67%|≈ 33%|
|6|≈ 58%|≈ 42%|

The last row is the Lab's bracket layer alone. **An analysis that treats 900 contract-rows as independent runs its "5% significance" tests at a ≈ 42% false-positive rate.** Edge detection under that regime would manufacture discoveries roughly every other month from pure noise — the precise failure mode [[Edge Detection]]'s machinery exists to prevent, and the single most important number in this document.

### 4.2 Power analysis and study duration

Required sample size for fixed power scales _linearly_ in deff: detecting a score-differential of standardized size δ\delta δ at level α\alpha α and power 1−β1-\beta 1−β requires neff≈(zα/2+zβ)2/δ2n_{\text{eff}} \approx (z_{\alpha/2}+z_\beta)^2/\delta^2 neff​≈(zα/2​+zβ​)2/δ2 **effective** observations, hence d×d \times d× that many rows, hence d×d \times d× the naive calendar time at fixed accrual rate. Because the Lab cannot buy city-days (non-backfillable data; accrual ≈ 150 city-days/month _before_ cross-city and serial discounts), deff feeds directly into decidability dates. Registered power analyses must state the deff they assume and cite this document; the V1 gate (≥ 300 gap-audited city-days over 3 months) already prices the discount qualitatively, and Q3's measurement will let it be priced quantitatively.

### 4.3 Calibration studies (retained from V1)

Binomial noise at small nn n is brutal. The standard error of an observed frequency is p(1−p)/neff\sqrt{p(1-p)/n_{\text{eff}}} p(1−p)/neff​​:

|neffn_{\text{eff}} neff​ in calibration bin|SE at p=0.7p = 0.7 p=0.7|
|---|---|
|10|±14.5 pp|
|50|±6.5 pp|
|200|±3.2 pp|

A "70% bin" showing 50% or 90% observed frequency at neff=10n_{\text{eff}} = 10 neff​=10 is _unremarkable noise_. Calibration curves need hundreds of **effective** forecasts per bin region before their shape is signal; early curves are entertainment, not evidence. Worse, bins fill with dependent rows non-uniformly — same-day brackets of one city can land in one bin together — so a bin's nominal count can overstate its effective count by more than the global deff. Hence Standing Consequence 2: consistency bands resampled by date, which get the bin-level accounting right automatically.

### 4.4 Scoring rules, skill comparisons, model evaluation

Mean log scores, Brier scores, and skill scores are sample means of dependent series; everything in §3.1 applies to their standard errors. Diebold–Mariano tests already include a HAC long-run variance for exactly this reason, and forecast-verification practice has known since ⚑ Hamill (1999) that ignoring serial correlation in verification data materially inflates apparent significance. Paired designs shrink the _variance_ of the differential but do not remove its _serial and cross-sectional_ dependence — pairing and clustering solve different problems and both are required ([[Forecast Verification]] §17.2–17.3).

### 4.5 Cross-validation and learning-theoretic budgets

Random K-fold CV on dependent data leaks information between train and test folds: a fold containing July 14 while July 13 and 15 sit in training is graded on partially-known answers, biasing skill estimates optimistically. Temporal blocking with embargo is the repair, and the embargo width should be set by the measured dependence length — this is D-SLT-2's content, consuming this document. Likewise every generalization bound of the form capacity/n\sqrt{\text{capacity}/n} capacity/n​ in [[Statistical Learning Theory]] and every "affordable capacity" argument in [[Machine Learning]] §24.1 must run on neffn_{\text{eff}} neff​ (D-SLT-1): capacity purchased against nominal nn n is leverage taken against evidence that does not exist.

### 4.6 Kelly sizing and evidential confidence

[[Kelly Criterion]] §8 establishes that overbetting is catastrophic while underbetting is cheap, and that estimation error in pp p dominates sizing sophistication. ESS enters twice. First, the sampling error of every calibration estimate feeding the sizing layer is governed by neffn_{\text{eff}} neff​, not row count — an edge "significant" at nominal nn n can be indistinguishable from zero at honest neffn_{\text{eff}} neff​, in which case the LCB-shrinkage sizers of Kelly §8.3 correctly output **zero stake**. Second, the evidence-scaled fraction schedule c(n)=cmax⁡ n/(n+n0)c(n) = c_{\max}\, n/(n+n_0) c(n)=cmax​n/(n+n0​) of Kelly §8.4 must be evaluated at n=neffn = n_{\text{eff}} n=neff​; feeding it nominal counts inflates cc c exactly when confidence is least deserved. Overstated ESS is therefore not an academic error here — it converts directly into oversized positions, on the catastrophic side of the Kelly asymmetry.

---

## 5. The Lab's Dependence Structure: Three Layers Plus One

Nominal count: 5 cities × ~6 brackets × 30 days = **900** contract-rows per month. The honest accounting proceeds layer by layer, and it matters which parts are theorems and which are estimates.

### 5.1 The bracket layer — exact, a theorem about the data, not an estimate

All ~6 temperature brackets for Phoenix on July 4 resolve from a single realized Tmax⁡T_{\max} Tmax​. The six outcome indicators are a _deterministic measurable function_ of one categorical draw (the binned temperature); they satisfy the exact linear constraint ∑jYj=1\sum_j Y_j = 1 ∑j​Yj​=1; and the σ-algebra they generate equals the σ-algebra of the single binned observation. Jointly, the six rows carry **exactly one** outcome observation — not "six highly correlated" ones. The Kish formula recovers this as the ρICC→1\rho_{\text{ICC}} \to 1 ρICC​→1 limit (deff = 6, neff=Gn_{\text{eff}} = G neff​=G), but the functional-degeneracy statement is stronger: no estimator of any outcome-resolved quantity can extract more than one observation's information from one city-day, whatever the bracket count, and however brackets are re-partitioned.

Corollary for scoring: the correct evaluation object is the **bracket probability vector scored once per city-day** — multiclass log score or RPS on the partition ([[Forecast Verification]]) — not six Bernoulli scores. Scoring brackets separately is counting the same coin flip six times.

**900 rows/month → ≤ ~150 city-days/month. This step is exact.**

### 5.2 The cross-city layer — empirical, open (Q3)

Regional weather systems move multiple cities together on the same date: a heat dome over the Southwest is one synoptic event expressed in Phoenix and Austin simultaneously; the five cities may be approximately conditionally independent _given the synoptic state_ ([[Probability]] §6.2), but unconditional same-day independence is false. Under an equicorrelation approximation with same-day outcome-level correlation ρc\rho_c ρc​ across 5 cities, each date contributes

neff/day=51+4ρc∈[1, 5].n_{\text{eff/day}} = \frac{5}{1+4\rho_c} \in [1,\,5].neff/day​=1+4ρc​5​∈[1,5].

ρc\rho_c ρc​ is unknown and is one of Q3's two targets. Two structural remarks: ρc\rho_c ρc​ is plausibly larger within geographic pairs (PHX–AUS) than across the set, and — critically — the correlation that matters for A1 is that of _score differentials_, which is expected to be smaller than the correlation of raw outcomes (shared weather partially cancels in paired differencing) but not zero (forecast systems share model cycles, so their errors co-move too).

### 5.3 The serial layer — empirical, open (Q3)

Weather persists; scores and score differentials may too. Under an AR(1) approximation with lag-1 correlation ρ1\rho_1 ρ1​ of the daily aggregate, multiply by (1−ρ1)/(1+ρ1)(1-\rho_1)/(1+\rho_1) (1−ρ1​)/(1+ρ1​) (§3.1). Same caveat: the operative ρ1\rho_1 ρ1​ is the score-differential autocorrelation, not the temperature autocorrelation, and NWP model-cycle sharing means it need not vanish even where weather-noise cancels.

### 5.4 The snapshot layer — a trap, currently avoidable, soon not

Market data adds a fourth layer the outcome data lacks: **multiple intraday quotes on one contract are near-duplicated observations of one outcome.** Scoring the market at ten timestamps produces ten rows and approximately zero additional outcome-resolved information — the ten forecasts differ (information arrives intraday, Q5), but they resolve against one settlement, so for calibration and skill accounting they collapse toward one observation per (contract, day), i.e., still the city-day. Related traps: liquidity clusters in time (active periods oversampled by quote-triggered collection), and forecast issuance clusters (multiple lab forecasts derived from one NWP model cycle share that cycle's errors and are not independent evidence about the pipeline's skill). Any Q2/Q5 design that scores multiple timestamps must either pick one registered timestamp per market or treat the timestamp dimension as a _within-cluster_ dimension, never as replication.

### 5.5 The honest arithmetic

Layers 5.2 and 5.3 combine with 5.1 multiplicatively only as an approximation (deffs multiply exactly only when layers are independent of one another); the registered inference procedure — cluster or block by date — handles both intra-date layers exactly and the serial layer up to block length. For planning purposes, the approximate monthly effective count is

neff  ≈  150⏟exact×11+4ρc⏟Q3×1−ρ11+ρ1⏟Q3.n_{\text{eff}} \;\approx\; \underbrace{150}_{\text{exact}} \times \underbrace{\frac{1}{1+4\rho_c}}_{\text{Q3}} \times \underbrace{\frac{1-\rho_1}{1+\rho_1}}_{\text{Q3}}.neff​≈exact150​​×Q31+4ρc​1​​​×Q31+ρ1​1−ρ1​​​​.

> [!warning] Hypothetical values — not measurements The rows below are illustrative algebra to size the stakes of Q3. No Lab data informs them; using any row as an input to a registered analysis before Q3 resolves is fabrication.

|ρc\rho_c ρc​|ρ1\rho_1 ρ1​|neffn_{\text{eff}} neff​/month (of 900 nominal)|
|---|---|---|
|0|0|150|
|0.25|0.2|≈ 50|
|0.5|0.3|≈ 27|

The spread of that column is the argument for measuring Q3 early: the difference between 150 and 27 effective observations per month is the difference between a two-month and a year-long decidability horizon for the same claim.

### 5.6 Nonstationarity is not dependence, and needs its own accounting

Seasonality, climate trend, NWS model upgrades, and market-efficiency drift (Q6) violate the _stationarity_ assumed by every formula above. They do not merely shrink neffn_{\text{eff}} neff​; they change what the pooled estimand _means_ (a full-year pooled calibration mixes winter and summer regimes). The ESS framework prices redundancy, not drift. Drift is handled by stratification, rolling windows, and the registered-forecaster re-registration discipline — cross-referenced, not solved, here.

---

## 6. Practical Estimation

### 6.1 What Q3 must produce

Two numbers with uncertainty attached, both computed on **score-differential series** (the inferential object) and reported alongside the same quantities for raw outcomes (the intuition object): the cross-city same-day correlation ρ^c\hat\rho_c ρ^​c​ and the lag-structure ρ^k\hat\rho_k ρ^​k​ of the date-level aggregate. Estimation routes, in increasing model commitment: (i) the ratio of date-clustered to naive standard errors on a pilot estimand — this ratio, squared, _is_ a direct deff estimate and needs no correlation model; (ii) empirical cross-city correlation matrices and lag-window (Bartlett/Newey–West-type) estimates of τ\tau τ with reported bandwidth sensitivity; (iii) parametric AR/ICC fits as summaries only. Route (i) is the primary deliverable because it is assumption-free and directly answers "how wrong would naive inference have been."

### 6.2 ESS estimates are themselves noisy — and biased in the dangerous direction

Estimated autocorrelations at small nn n are noisy and truncation-sensitive; underestimating the tail of ρk\rho_k ρk​ _overestimates_ neffn_{\text{eff}} neff​ — the error lands on the anti-conservative side. Standard defenses: Geyer-style truncation rules (⚑ Geyer 1992) rather than fixed lag cutoffs; reporting n^eff\hat n_{\text{eff}} n^eff​ under multiple bandwidths/block lengths as mandatory sensitivity analysis; and the standing asymmetry rule — **measured near-independence loosens the discount only after the measurement itself has adequate effective sample size**; a noisy estimate of ρ≈0\rho \approx 0 ρ≈0 from thirty dates does not discharge the conservative floor. The floor moves on evidence, and the evidence is graded by the same rules it seeks to relax.

### 6.3 Block bootstrap: the registered inference engine

For reported inference, resampling replaces closed forms ([[Forecast Verification]] §17.4). The family: **moving-block** (⚑ Künsch 1989), **circular** (wraps the series to fix edge under-sampling ⚑), and **stationary** (random geometric block lengths; ⚑ Politis & Romano 1994). The Lab's atom is the **date** — each resampled date carries all its cities and brackets intact, which handles both intra-date layers _exactly_, by construction, with zero modeling. Block length ℓ\ell ℓ then only needs to cover the serial layer: ℓ\ell ℓ must exceed the dependence length of the date-level series, with automatic selection rules available (⚑ Politis & White 2004) and theoretical ℓ∝n1/3\ell \propto n^{1/3} ℓ∝n1/3 scaling (⚑ Hall, Horowitz & Jing 1995) as a cross-check. Until Q3 measures the dependence length, block-length sensitivity (report at ℓ\ell ℓ and 2ℓ2\ell 2ℓ minimum) is mandatory in any bootstrap-based claim. With G≈30G \approx 30 G≈30 dates after month one, remember §3.4: thirty blocks is few; intervals should be treated as approximate and claims as provisional regardless of what the bands show.

### 6.4 Verify the machinery by simulation

Before any deff estimate or bootstrap procedure is used in a registered analysis, validate it on synthetic data with _known_ dependence: simulate city-day outcomes with chosen ρc,ρ1\rho_c, \rho_1 ρc​,ρ1​, confirm the procedure recovers them and that nominal 95% intervals cover ≈ 95%. This is cheap, decisive, and the only way to catch implementation errors in inference code — a coverage simulation is to an inference procedure what the test suite is to a collector. Simulation results are labeled as such and never mingle with empirical estimates (no-fabricated-statistics rule).

---

## 7. Common Mistakes

1. **Assuming IID because the rows are in one table.** Row count is a storage fact, not a statistical one.
2. **Scoring brackets as independent Bernoullis.** They are one categorical observation (§5.1). Score the vector once.
3. **Treating every contract, bracket, or timestamp as equal evidence.** Evidence is counted at the largest dependent unit, and units differ in the information they carry.
4. **Ignoring cross-city same-day correlation** because cities are "far apart." Synoptic correlation ranges are continental (§3.5).
5. **Ignoring serial correlation in verification series** — the oldest error in forecast verification (⚑ Hamill 1999) and still the most common.
6. **Computing one "dataset ESS" and reusing it for every estimand** (§1.3).
7. **Using nominal nn n in CIs, tests, power analyses, calibration bins, capacity budgets, or Kelly confidence schedules.** The respective consequences are quantified in §4; the Kelly case converts directly into overbetting.
8. **Conflating the two Kish formulas** — weighting ESS assumes independence; it does not price clustering (§3.3).
9. **Trusting a large n^eff\hat n_{\text{eff}} n^eff​ from a short series.** ESS estimates are anti-conservatively biased when autocorrelation tails are truncated (§6.2).
10. **Forgetting that cluster-robust asymptotics run on the number of clusters.** Thirty dates is thirty observations for asymptotic purposes, however many rows they contain (§3.4).
11. **Treating nonstationarity as if ESS discounting fixes it.** It doesn't (§5.6).
12. **Loosening the conservative floor on a noisy near-zero correlation estimate.** The relaxation evidence is graded by the same effective-sample-size rules (§6.2).

---

## 8. Connections

- **[[Probability]]** §5.4 and §6 supply the variance-of-sums identity and the independence taxonomy this document is built on; single-homed there, consumed here.
- **[[Forecast Verification]]** §17 implements this document: paired differentials (17.2), date-clustered SEs and the equicorrelation bound (17.3), date-blocked bootstrap (17.4). Where implementation details conflict, FV governs the procedure and this document governs the accounting.
- **[[Proper Scoring Rules and Calibration - Technical Reference (V2)]]** — bin counts and consistency bands consume §4.3; the "score the vector once" rule of §5.1 fixes the scoring object.
- **[[Edge Detection]]** — the ≈ 42% false-positive arithmetic of §4.1 is the quantitative case for its population-level, multiplicity-counted machinery; decidability dates inherit §4.2.
- **[[Kelly Criterion]]** — §8.2/§8.4 there consume neffn_{\text{eff}} neff​ from here; the asymmetry doctrine (overbetting catastrophic) is the decision-theoretic reason this document's floor is conservative.
- **[[Bayesian Statistics]]** — MCMC ESS (§3.6 here, §9.1/§19 there) is the same mathematics; hierarchical models are the _modeling_ response to the dependence this document _prices_.
- **[[Statistical Learning Theory]] / [[Machine Learning]]** — D-SLT-1 (capacity budgets on neffn_{\text{eff}} neff​) and D-SLT-2 (temporal blocking with measured embargo) are this document's directives in learning-theory clothing; ML §14–15 sample-sufficiency arguments cite here.
- **[[Expected Value]] / Decision Theory** — value-of-information calculations should price _effective_ observations; a data-collection option that adds correlated rows adds less EVSI than its row count suggests.
- **[[Information Theory for Forecasting]]** — the entropy-rate reading of §1.2; evidence accrues at the conditional-information rate.
- **[[Open Questions]]** Q3 (the two correlations), Q5/Q2 (snapshot layer), Q6 (nonstationarity caveat).

---

## 9. What Would Change This Note

Empirical measurement of cross-city and serial correlation in outcomes **and in score differentials** (Q3), delivered with the estimation discipline of §6. Evidence of near-independence — itself adequately powered under this document's own accounting — would _loosen_ the discount, never tighten the rule's floor: cluster-by-date remains the default even at measured ρ≈0\rho \approx 0 ρ≈0, because it is nearly free and robust to regime change. Discovery of long memory in score series, or a snapshot-layer design entering registration (Q2/Q5), would trigger targeted revision of §3.1 and §5.4 respectively.

---

## 10. References

All ⚑ per Invariant 3 (AI-drafted citations = E4 testimony; flags discharged individually by the Architect). ★ = suggested priority reads.

1. ⚑ ★ Kish, L. (1965). _Survey Sampling_. Wiley. — Design effect; weighting ESS.
2. ⚑ Cochran, W. G. (1977). _Sampling Techniques_, 3rd ed. Wiley. — Cluster and stratified sampling variances.
3. ⚑ Newey, W. K., & West, K. D. (1987). "A simple, positive semi-definite, heteroskedasticity and autocorrelation consistent covariance matrix." _Econometrica_ 55. — HAC long-run variance.
4. ⚑ Hamilton, J. D. (1994). _Time Series Analysis_. Princeton. — Spectral/long-run variance view of §3.1.
5. ⚑ Künsch, H. R. (1989). "The jackknife and the bootstrap for general stationary observations." _Annals of Statistics_ 17. — Moving-block bootstrap.
6. ⚑ Politis, D. N., & Romano, J. P. (1994). "The stationary bootstrap." _JASA_ 89.
7. ⚑ Politis, D. N., & White, H. (2004). "Automatic block-length selection for the dependent bootstrap." _Econometric Reviews_ 23.
8. ⚑ Hall, P., Horowitz, J. L., & Jing, B.-Y. (1995). "On blocking rules for the bootstrap with dependent data." _Biometrika_ 82.
9. ⚑ Efron, B., & Tibshirani, R. (1993). _An Introduction to the Bootstrap_. Chapman & Hall. — Foundations.
10. ⚑ Davison, A. C., & Hinkley, D. V. (1997). _Bootstrap Methods and Their Application_. Cambridge. — Ch. 8 for dependent data.
11. ⚑ ★ Cameron, A. C., & Miller, D. L. (2015). "A practitioner's guide to cluster-robust inference." _Journal of Human Resources_ 50. — Few-clusters problem; §3.4.
12. ⚑ Cameron, A. C., Gelbach, J. B., & Miller, D. L. (2008). "Bootstrap-based improvements for inference with clustered errors." _REStat_ 90. — Wild cluster bootstrap.
13. ⚑ ★ Hamill, T. M. (1999). "Hypothesis tests for evaluating numerical precipitation forecasts." _Weather and Forecasting_ 14. — Serial correlation in verification; the field's canonical warning.
14. ⚑ Diebold, F. X., & Mariano, R. S. (1995). "Comparing predictive accuracy." _JBES_ 13. — HAC-based forecast comparison (details owned by [[Forecast Verification]]).
15. ⚑ Clifford, P., Richardson, S., & Hémon, D. (1989). "Assessing the significance of the correlation between two spatial processes." _Biometrics_ 45. — Spatial ESS.
16. ⚑ Geyer, C. J. (1992). "Practical Markov chain Monte Carlo." _Statistical Science_ 7. — Initial-sequence autocorrelation truncation.
17. ⚑ ★ Vehtari, A., Gelman, A., Simpson, D., Carpenter, B., & Bürkner, P.-C. (2021). "Rank-normalization, folding, and localization: an improved R^\widehat R R…" _Bayesian Analysis_ 16. — Bulk/tail ESS.
18. ⚑ Gelman, A., et al. (2013). _Bayesian Data Analysis_, 3rd ed. — MCMC ESS in context.
19. ⚑ Wilks, D. S. (2019). _Statistical Methods in the Atmospheric Sciences_, 4th ed. — Verification-side treatment of dependent data.
