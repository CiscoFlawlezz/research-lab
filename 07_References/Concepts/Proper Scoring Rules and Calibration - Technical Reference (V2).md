---

## title: "Proper Scoring Rules & Probability Calibration — Technical Reference" version: 2 status: "E4 — AI-drafted, pending Architect verification and canonization" supersedes: "Proper Scoring Rules & Calibration v1 (2026-07-04)" created: 2026-07-10 vault_location: "01 Research/Probability" tags: [scoring-rules, calibration, verification, canon-candidate]

# Proper Scoring Rules & Probability Calibration — Technical Reference (V2)

**Level:** Quantitative researcher reference. Assumes probability theory, basic information theory, and statistical inference. **Cross-links:** [[Probability]] · [[Bayesian Statistics]] · [[Forecast Verification]] · [[Edge Detection]] · [[Expected Value]] · [[Kelly Criterion]] · [[Prediction Markets]] · [[Effective Sample Size]] · [[Machine Learning]] · [[Brier Decomposition - Worked Example]] · [[Log Score and Kelly Identity]] **Provenance:** This document was drafted by an AI collaborator from first principles, using V1 and its adversarial audit as inputs. Per Invariant 3 it is **E4 testimony** until the Architect verifies it. Every citation carries an implicit ⚑ verification flag unless explicitly marked **[verified in audit session, 2026-07-10]** with a retrievable source. Bibliographic details must be checked against the originals before any claim here becomes load-bearing in a registration or ADR. **Math rendering:** LaTeX via Obsidian `$...$`.

---

## 1. Purpose and scope

This is the lab's canonical reference on the measurement theory of probabilistic forecasting: **proper scoring rules**, which make forecast evaluation incentive-compatible, and **calibration analysis**, which diagnoses _why_ a forecaster is good or bad. Everything the lab does — model acceptance, backtest verdicts, edge claims, the V1→V3 gates — ultimately reduces to statements about scores and their decompositions. This document defines the objects, states the theorems that justify them, fixes the lab's conventions, and specifies how the theory becomes pipeline code.

Boundaries with neighboring documents: statistical inference on score differences is _introduced_ here but formally owned by **A1 (Statistical Validity & Inference Framework)** once ratified; bet sizing beyond the Kelly–log-score identity is owned by [[Kelly Criterion]]; market microstructure is owned by [[Prediction Markets]]; engineering directives that operationalize this document live in [[Forecast Verification]] (D-FV series). Where this document states a _convention_ (Section 2, Section 13), that convention is authoritative here and referenced elsewhere — one home per convention, stated explicitly.

---

## 2. Conventions

All sign errors in verification pipelines trace to orientation ambiguity, and all growth-rate errors trace to unit ambiguity. The lab fixes both here, once.

**Orientation.** The theory sections of this document use **positive orientation** (higher score = better), which is the convention of Gneiting & Raftery (2007) and makes the entropy/divergence duality clean. The _reporting_ convention for the lab's standard metrics follows meteorological practice: Brier score, RPS, and CRPS are reported as **losses** (lower = better); log score is reported positively oriented as mean log likelihood (higher = better, always ≤ 0 for discrete outcomes). Skill scores are oriented so that positive = better than reference. Every table, plot, and stored score in the pipeline must carry an explicit orientation tag; the reconciliation suite (Section 14) checks it.

|Score|Stored orientation|Perfect value|Climatology value (binary, base rate $\bar o$)|Units|
|---|---|---|---|---|
|Log score $\frac1N\sum \ln p_i(y_i)$|higher better|$0$|$-H(\bar o)$ (nats)|nats/event|
|Ignorance score|lower better|$0$|$H_2(\bar o)$|bits/event|
|Brier score|lower better|$0$|$\bar o(1-\bar o)$|probability²|
|RPS (per event, $m$ brackets)|lower better|$0$|depends on climatological CDF|probability²|
|CRPS|lower better|$0$|$\mathbb{E}|X_{\text{clim}}-y|
|Skill scores (BSS, RPSS, CRPSS)|higher better|$1$|$0$|dimensionless|

**Units.** Natural logarithms (**nats**) are the lab's working unit for the log score. This is not aesthetic: the Kelly–log-score identity (Section 11.3) is denominated in nats — expected log-growth of wealth per event — and a silent $\ln$/$\log_2$ mismatch corrupts the growth interpretation by a factor of $\ln 2 \approx 0.693$. The **ignorance score** (Roulston & Smith 2002) is the same object in bits, negatively oriented: $\text{IGN} = -\log_2 p(y)$. Convert only at the reporting layer, never in storage.

**Notation.** $y$ denotes the realized outcome; for binary events $y \in {0,1}$ and $p \in [0,1]$ is the reported probability of $y=1$. $Q$ (or $q$ in the binary case) denotes the true/data-generating distribution — an idealization used in theory; nothing in the pipeline ever observes $q$. $S(P, y)$ is the score of report $P$ on outcome $y$; the same symbol extended to distributions, $S(P, Q) := \mathbb{E}_{y \sim Q}[S(P, y)]$, is the **expected score** — the overload is standard (Gneiting & Raftery 2007) and flagged here once. $F$ denotes a forecast CDF. Empirical means over $N$ scored events use bars.

---

## 3. Foundations

### 3.1 What a scoring rule is, and why the concept exists

A **scoring rule** is a function $S(P, y)$ that assigns a numerical reward to a probabilistic forecast $P$ when outcome $y$ materializes. The concept exists because probability forecasts have a unique verification problem that point forecasts do not: **a single outcome can never confirm or refute a probability**. If the forecast was $0.85$ and the event happened, the forecast may still have been terrible ($q$ was actually $0.99$) or excellent. A probability is a claim about a population and can only be graded against a population — the load-bearing idea of this lab's entire architecture. Scoring rules are the device that makes population-level grading incentive-compatible: they are designed so that, _in expectation_, the forecaster's best strategy is to report exactly what they believe.

This is not automatic, and the failure mode is silent. Most intuitive metrics — accuracy, hit rate, mean absolute error applied to probabilities, "how often was the favorite right" — are **improper**: a forecaster (or a model-selection loop) maximizing them is rewarded for reporting something _other_ than their true belief, typically a more extreme probability. An evaluation pipeline built on an improper metric systematically selects for distorted, usually overconfident, models while appearing rigorous. Because the distortion is in the _objective_, not in any single number, no amount of downstream statistical care repairs it. Propriety is the property that closes this hole at the root.

### 3.2 Decision-theoretic foundations and incentive compatibility

The deepest justification is decision-theoretic. Suppose a forecaster with subjective belief $Q$ must publicly report a distribution $P$ and is paid $S(P, y)$. The forecaster is an expected-utility maximizer (for the moment, risk-neutral in score units). Their problem is $\max_P S(P, Q) = \max_P \mathbb{E}_{y\sim Q} S(P, y)$. A scoring rule is an **incentive-compatible elicitation mechanism** when this maximization is solved by honesty:

- $S$ is **proper** if $S(Q, Q) \ge S(P, Q)$ for all $P, Q$ in the relevant class — truthful reporting is _an_ optimal strategy.
- $S$ is **strictly proper** if equality holds only when $P = Q$ — truthful reporting is the _unique_ optimal strategy.

For a binary event this reads: $\arg\max_{p} \big[ q,S(p,1) + (1-q),S(p,0) \big] = q$, uniquely for strict propriety.

The distinction matters operationally. Merely proper rules admit ties: a forecaster can deviate at zero expected cost, and an optimizer running on finite noisy data _will_ wander among the tied optima. Only **strictly** proper rules make honesty the unique attractor, which is why every score this lab optimizes against or tests with must be strictly proper. (Merely proper objects still appear legitimately in reporting — skill scores, Section 8.3 — but never as optimization targets.)

Two boundary caveats, both consequential:

1. **Propriety is an expectation property.** It disciplines the mean of the score distribution, not its tail behavior in any finite sample. In _tournament_ settings — where reward depends on score _rank_ rather than score _level_ — strictly proper rules no longer induce honesty: a trailing forecaster maximizes the probability of overtaking the leader by reporting extremized probabilities (variance-seeking), a result known from forecasting-competition analyses (Lichtendahl & Winkler 2007 ⚑). The lab's registered forecasters are paid in score levels, not ranks, precisely to avoid this.
2. **Risk neutrality in score units is assumed.** A risk-averse agent scored with a proper rule will hedge toward the base rate. This is irrelevant for the lab's models (code has no risk preferences) but relevant when interpreting _market_ prices as forecasts: market participants have real utility functions, which is one of the two standard explanations for the favorite–longshot bias (Section 11.1).

### 3.3 The elementary-decision interpretation (Schervish)

There is a second, complementary justification that explains _what a score is measuring in economic terms_. Schervish (1989) showed that every proper scoring rule for binary events is a mixture over a family of elementary two-action decision problems, indexed by a cost threshold $c \in (0,1)$: a decision-maker with cost ratio $c$ acts iff the stated probability exceeds $c$, and suffers a unit loss when the action is wrong. A proper score is a weighted average of these losses across thresholds; the choice of scoring rule is a choice of _weighting measure_ over which decision-makers you care about. The Brier score weights thresholds uniformly; the log score weights extreme thresholds ($c$ near 0 or 1) heavily — which is exactly why it is savage about tail miscalibration.

Two lab-relevant consequences. First, this justifies evaluating calibration across the _full_ $[0,1]$ range, not only at price levels that happen to trade: the score already implicitly aggregates decision-makers at every threshold. Second, it explains why different proper rules can _rank two forecasters differently_ without either rule being wrong: they weight the threshold spectrum differently. Divergence between Brier and log rankings is a diagnostic that the models differ specifically in the tails (Section 5.1–5.2).

---

## 4. Mathematical theory

### 4.1 Expected score, generalized entropy, and divergence (the Savage representation)

Propriety has an exact geometric characterization. Define the **(generalized) entropy** of a proper rule as its expected score under honesty, $G(Q) := S(Q, Q)$. Then (Savage 1971; McCarthy 1956 ⚑; Gneiting & Raftery 2007, Thm. 1):

> A binary scoring rule $S$ is proper **iff** there exists a convex function $G : [0,1] \to \mathbb{R}$ such that $$S(p, q) = G(p) + G'(p),(q - p),$$ i.e., the expected score of reporting $p$ under truth $q$ is the tangent line of $G$ at $p$, evaluated at $q$. (Where $G$ is not differentiable, a subgradient replaces $G'$.) $S$ is **strictly** proper iff $G$ is **strictly** convex.

The geometry _is_ the incentive argument: convexity is exactly the statement that every tangent line lies on or below the curve, so $S(p,q) \le G(q) = S(q,q)$ — honesty is optimal — with a strict gap whenever $G$ is strictly convex and $p \neq q$. The same structure holds on general outcome spaces with $G$ a convex functional on the space of probability measures and subtangents replacing tangent lines (Gneiting & Raftery 2007).

The honesty gap defines the score's **divergence**:

$$d(q, p) := S(q,q) - S(p,q) = G(q) - G(p) - G'(p)(q-p) ;\ge; 0,$$

which is precisely the **Bregman divergence** of $G$. Every strictly proper scoring rule induces a Bregman divergence and vice versa; the expected score _lost_ by misreporting is the divergence from truth to report. Three instances organize everything downstream:

|Rule|$G(q)$ (binary)|Divergence $d(q,p)$|
|---|---|---|
|Logarithmic|$q\ln q + (1-q)\ln(1-q)$ (negative Shannon entropy)|$D_{\mathrm{KL}}(q ,\|, p)$|
|Brier/quadratic|$-q(1-q)$ (negative variance)|$(q-p)^2$|
|Spherical|$\|q\|_2 = \sqrt{q^2 + (1-q)^2}$|$\|q\|_2 - \dfrac{\langle q, p\rangle}{\|p\|_2}$|

The table's first row is the hinge of the whole document: **the expected log-score advantage of truth over a report is exactly Kullback–Leibler divergence.** This single identity connects proper scoring to information theory (Section 10), to Bayesian model comparison (Section 9), and — through the Kelly identity — to compounding wealth (Section 11.3).

**Uncertainty as entropy.** $G(q)$ evaluated at the climatological base rate is the best achievable expected score with no case-specific information — the "uncertainty" floor that reappears as the UNC term of every score decomposition (Section 7). For Brier, $G(\bar o) = -\bar o(1-\bar o)$; positively restated in loss form, the constant climatological forecast $p = \bar o$ achieves Brier score exactly $\bar o(1-\bar o)$, and the constant $p = 0.5$ scores $0.25$ regardless of outcome. These two facts make skill-vs-climatology interpretable by inspection: $\text{BSS}_{\text{clim}} = (\text{RES} - \text{REL})/\text{UNC}$.

### 4.2 Locality — stated precisely

A scoring rule is **local** if it depends on the forecast only through the probability assigned to the outcome that materialized: $S(P, y) = s(P(y), y)$. The classical uniqueness result must be stated with its scope condition, because the imprecise version misleads in exactly this lab's setting:

> **For outcome spaces with three or more elements**, the logarithmic score is — up to affine transformation $a,S + b(y)$ — the unique (smooth) local strictly proper scoring rule. The discrete case is due to Savage (1971) **[verified in audit session, 2026-07-10: Yang 2020, _Theory and Decision_ 88:315–322, attributes the >2-events result to Savage]**; the density-forecast case, under smoothness, is due to Bernardo (1979) **[verified in audit session: survey treatments describe the log score as the only differentiable local rule of order 0, per Bernardo]**.

> **For binary events, every proper scoring rule is trivially local** — the probability assigned to the unrealized outcome is fully determined by the probability assigned to the realized one, so locality constrains nothing **[verified in audit session: standard, e.g. the scoring-rule literature summary "all binary scores are local"]**.

Consequences for this lab. On a _single_ Kalshi contract, locality does not discriminate between log and Brier; the operative differences are tail weighting (Section 3.3) and Kelly denomination (Section 11.3). Locality becomes substantive precisely when a _bracket set_ (≥3 ordered outcomes) is scored jointly — and there it interacts with a second property, **sensitivity to distance** (a score improves as forecast mass moves categorically closer to the realized bracket). Locality and sensitivity to distance are mutually exclusive: a local rule cannot see where the unrealized mass sits, so it cannot reward near-misses. The log score applied to the full bracket distribution is local and distance-blind; RPS deliberately sacrifices locality to gain distance sensitivity (Section 5.4). This is a genuine modeling choice, not a defect of either rule, and the lab's convention (Section 5.8) uses both for complementary purposes.

### 4.3 Why improper rules fail: the canonical worked example

Under absolute loss $|p - y|$ with true probability $q$, expected loss is $q(1-p) + (1-q)p = q + p(1-2q)$ — **linear** in $p$, minimized at $p=1$ when $q > \tfrac12$ and $p=0$ when $q < \tfrac12$. MAE-on-probabilities pays you to report certainty you do not have; there is no interior optimum because the implied "$G$" is not strictly convex. Accuracy and hit rate are the same degeneracy (they are affine in the reported probability's exceedance of $\tfrac12$). The lesson generalizes: _any_ evaluation whose expected value is linear in $p$ over some region admits corner solutions, and an optimizer will find them.

AUC deserves separate mention because it fails differently: it is a pure **discrimination** (ranking) measure, invariant to any strictly monotone transformation of the forecasts, and therefore silent on calibration. A model can post AUC 0.90 and be uselessly miscalibrated for pricing. AUC is not "wrong" — it upper-bounds what monotone recalibration can achieve, which makes it diagnostically useful (Section 12.2) — but it can never be the acceptance metric for a probability estimator.

### 4.4 Information gain and truthful updating

For the log score specifically, the expected score improvement of forecast $P_1$ over $P_0$ under truth $Q$ is

$$S_{\log}(P_1, Q) - S_{\log}(P_0, Q) = D_{\mathrm{KL}}(Q|P_0) - D_{\mathrm{KL}}(Q|P_1),$$

the reduction in divergence from truth — literally the **information gained** by moving from $P_0$ to $P_1$, in nats. Bernardo's (1979) reading: eliciting with the log score makes "maximize expected score" identical to "maximize expected information," which is why the log score arises naturally in Bayesian experimental design and why cumulative log scores compare models the way Bayes factors do (Section 9.2). No other strictly proper rule has this exact information semantics; others measure divergence in their own Bregman geometry.

---

## 5. The catalog of scoring rules

Each entry gives: definition, generating intuition, strengths, weaknesses, implementation guidance, and prediction-market relevance. Orientation per entry follows the reporting convention of Section 2.

### 5.1 Logarithmic score (and the ignorance score)

**Definition.** For a discrete forecast $P$ and realized outcome $y$: $S_{\log}(P, y) = \ln P(y)$ (higher better; always $\le 0$). Binary form: $S_{\log}(p, y) = y \ln p + (1-y)\ln(1-p)$. The **ignorance score** is the same rule in bits, loss-oriented: $\text{IGN} = -\log_2 P(y)$ (Roulston & Smith 2002). For density forecasts, $S_{\log}(f, y) = \ln f(y)$.

**Intuition.** You are scored on the log of the probability you assigned to what actually happened — your _surprisal_, negated. Generated by negative Shannon entropy; divergence is KL.

**Strengths.**

- Strictly proper on essentially any outcome space; the unique local rule for ≥3 outcomes (Section 4.2).
- The only rule whose units are the units of compounding wealth: mean log-score edge over the market **is** expected log growth of a Kelly bettor before costs (Section 11.3). For this lab, that makes log the _primary_ score, not one among many.
- Sample-additive log scores are log predictive likelihoods: cumulative comparison is Bayes-factor comparison (Section 9.2).
- Unbounded penalty for confident misses is a _feature_ for risk control: a model that assigns $p \approx 0$ to events that occur is exactly the model that bankrupts a log-utility bettor, and the score says so.

**Weaknesses.**

- The unbounded penalty makes empirical means heavy-tailed: a single $p = 10^{-6}$ miss dominates a month of good forecasts. Mean log scores therefore have high variance and slow CLT convergence when forecasts venture near 0/1 — inference (Section 8.4) must account for this, and the clipping policy (Section 13.2) must be registered because it changes comparisons in exactly the tail region the score exists to police.
- Not sensitive to distance on ordered outcomes (local ⇒ distance-blind).
- Undefined at $P(y) = 0$; requires an explicit numerical policy, never an ad-hoc `max(p, tiny)` scattered through code.

**Implementation.** Compute from log-probabilities end-to-end where the model natively produces them; clip reported probabilities to $[\varepsilon, 1-\varepsilon]$ with a single registered $\varepsilon$ (Section 13.2); store nats; convert to bits only at display.

**Market relevance.** The market's midpoint-implied probability is scoreable with $S_{\log}$ exactly like a model; the lab's edge definition is a log-score differential against the market reference (Section 11.4). Hanson's LMSR is this score turned into a market mechanism (Section 11.2).

### 5.2 Brier / quadratic score

**Definition (binary, loss form).** $\text{BS} = \frac1N \sum_i (p_i - y_i)^2 \in [0,1]$; per-event score $-(p-y)^2$ in positive orientation. Generated by $G(q) = -q(1-q)$; divergence $(q-p)^2$. **Multicategory quadratic form** (Brier's 1950 original): $\text{QS} = \sum_{j=1}^m (p_j - \mathbf 1{y=j})^2$, which ranges over $[0,2]$ — the binary $[0,1]$ bound does not carry over, a detail that matters when normalizing multi-bracket reports.

**Intuition.** Squared error on the probability scale; strictly proper because squared loss has a strictly convex generator. Punishes miscalibration quadratically, so it is tolerant of rare confident misses (bounded per-event loss).

**Strengths.** Bounded, low-variance, robust empirical means; the classical decomposition machinery (Section 7) was built for it; instantly interpretable reference points (climatology scores $\bar o(1-\bar o)$; the constant $0.5$ scores $0.25$).

**Weaknesses.** Insensitive to tail miscalibration — a model saying $10^{-6}$ versus $10^{-2}$ for a 1% event differ enormously in Kelly consequence and almost not at all in Brier. Not local (irrelevant for binary; Section 4.2). Not in wealth units.

**Implementation.** Trivial numerically. Report alongside log per lab convention: **divergence between Brier and log rankings is itself a diagnostic** that two models differ specifically in tail behavior (Schervish weighting, Section 3.3).

**Market relevance.** The workhorse of the market-calibration literature and of Experiment 1's headline table, because its decomposition (Section 7) is the standard instrument for asking "is this market reliable, and does it resolve?"

### 5.3 Spherical score

**Definition (discrete, positive orientation).** $S_{\text{sph}}(P, y) = P(y) \big/ |P|_2$ where $|P|_2 = (\sum_j P(j)^2)^{1/2}$. Strictly proper; generator $G(Q) = |Q|_2$.

**Role.** The third member of the classical strictly proper triad (quadratic, logarithmic, spherical), included for completeness and because it occasionally appears in elicitation literature. Bounded like Brier, non-local like Brier, with yet another Schervish threshold weighting. **No identified lab use case**; if a bounded rule is needed, Brier's decomposition ecosystem makes it strictly dominant for our purposes. Mention-and-dismiss is the deliberate treatment.

### 5.4 Ranked probability score (RPS)

**Definition.** For $m$ **ordered** categories with forecast vector $(p_1,\dots,p_m)$, cumulative forecast $F_k = \sum_{j\le k} p_j$, and cumulative outcome indicator $O_k = \mathbf 1{y \le k}$:

$$\text{RPS} = \sum_{k=1}^{m-1} (F_k - O_k)^2 \qquad \text{(loss; per event)}.$$

Introduced by Epstein (1969) **[verified in audit session: Epstein, "A scoring system for probability forecasts of ranked categories," _J. Appl. Meteor._ 8:985–987]**; shown strictly proper by Murphy (1969) and sensitive to distance by Murphy (1970) **[verified in audit session]**. It is exactly a sum of binary Brier scores on the $m-1$ nested threshold events ${y \le k}$ — which is also the cleanest proof of its propriety.

**Intuition.** Compare CDFs, not PMFs. Missing the realized temperature bracket by one bracket leaves most cumulative mass correct; missing by eight brackets leaves almost none. Scoring brackets as independent binaries discards the ordering; RPS restores it at the price of locality (Section 4.2).

**Strengths.** Strictly proper for ordered categoricals; sensitive to distance; decomposes threshold-by-threshold (each cumulative event has its own Murphy decomposition — diagnostically rich for bracket markets).

**Weaknesses / conventions trap.** Literature conventions differ: sum over $m-1$ terms (as above), sum over $m$ terms (the last is identically zero), or normalized by $m-1$. Because Kalshi bracket counts vary across series and dates, **unnormalized RPS values are not comparable across markets with different $m$.**

> **Lab convention (registered here):** per-event RPS is the unnormalized $\sum_{k=1}^{m-1}(F_k - O_k)^2$; any cross-market aggregation or comparison across differing bracket counts uses $\text{RPS}^\ast = \text{RPS}/(m-1)$ and says so in the column name. Skill form: $\text{RPSS} = 1 - \text{RPS}/\text{RPS}_{\text{ref}}$ computed on identical event sets only.

**Implementation.** Cumulative sums; no numerical hazards. Store $m$ with every score row.

**Market relevance.** RPS on the full bracket ladder is the lab's grading instrument for distribution-shaped market beliefs and for the model's full bracket output; per-contract Brier/log handle single-contract comparisons.

### 5.5 Continuous ranked probability score (CRPS)

**Definition.** For forecast CDF $F$ and realization $y$ (Matheson & Winkler 1976):

$$\text{CRPS}(F, y) = \int_{-\infty}^{\infty} \big(F(x) - \mathbf 1{x \ge y}\big)^2, dx ;=; \mathbb{E}_F|X - y| - \tfrac12, \mathbb{E}_F|X - X'|,$$

where $X, X' \sim F$ independently. The kernel (second) form **requires $F$ to have finite first moment** — trivially satisfied for temperature, but a canonical reference states its conditions. Loss-oriented; units are the units of the variable (°F here), which makes CRPS values directly interpretable as a generalized absolute error.

**Intuition.** The continuous limit of RPS: integrated squared distance between the forecast CDF and the degenerate "step at the outcome" CDF. Rewards distributions that are both **sharp** (steep CDF) and **centered** (step in the right place). For a point forecast (degenerate $F$), CRPS reduces exactly to absolute error — so CRPS strictly generalizes MAE to distributions and gives deterministic and probabilistic forecasts a common ruler.

**Strengths.** Strictly proper (for distributions with finite first moment); robust (bounded influence of outliers relative to log); defined for ensembles, parametric densities, and quantile sets alike; closed forms exist for common families (e.g., Gaussian: $\text{CRPS}(\mathcal N(\mu,\sigma^2), y) = \sigma{ z(2\Phi(z)-1) + 2\varphi(z) - \pi^{-1/2} }$ with $z = (y-\mu)/\sigma$ ⚑ verify constant before coding).

**Quantile view.** CRPS equals twice the pinball (quantile) loss integrated uniformly over quantile levels: $\text{CRPS}(F,y) = 2\int_0^1 \text{QS}_\alpha(F^{-1}(\alpha), y), d\alpha$ ⚑. Consequence: a model that outputs quantiles can be CRPS-scored by numerical quadrature over pinball losses, and per-quantile-level score profiles localize _where_ in the distribution a model wins — directly useful when the money question is tail brackets.

**Weaknesses.** Ensemble estimation of the kernel form is biased at small ensemble sizes (fair-CRPS corrections exist, Ferro 2014 ⚑); insensitive relative to log score in the extreme tails.

**Implementation.** Prefer closed forms where the forecast family admits them; otherwise the kernel form with the $O(n \log n)$ sorted-sample formula $\mathbb{E}|X-X'| = \frac{2}{n^2}\sum_i (2i - n - 1), x_{(i)}$ ⚑ rather than the naive $O(n^2)$ double sum.

**Market relevance and lab role.** The lab's model layer produces a **temperature distribution** per city-day and derives bracket probabilities from it. CRPS grades that underlying distribution; RPS grades the bracketized report; log/Brier grade single contracts. All three coexist by convention (Section 5.8), and the calibration diagnostic for the CRPS layer is the PIT histogram (Section 6.4) — adopting CRPS without PIT would be committing to grade distributions while owning no calibration instrument for them.

### 5.6 Weighted proper scoring rules

Sometimes specific regions of the outcome space carry the economic weight — for this lab, tail brackets, where the favorite–longshot question lives. The naive approach — restrict scoring to cases where the event of interest occurred — is **improper** and produces the "forecaster's dilemma": under selective verification of extremes, the misleadingly extreme forecaster wins (Lerch, Thorarinsdottir, Ravazzolo & Gneiting 2017, _Statistical Science_ ⚑). The proper alternative is to weight _inside_ the score:

**Threshold-weighted CRPS** (Gneiting & Ranjan 2011 ⚑):

$$\text{twCRPS}(F, y) = \int_{-\infty}^{\infty} \big(F(x) - \mathbf 1{x \ge y}\big)^2, w(x), dx,$$

with a **pre-specified, forecast-independent** weight function $w \ge 0$; propriety is preserved for any such $w$. Choosing $w$ as an indicator of the tail region emphasizes tail performance without breaking incentives.

**Lab stance.** twCRPS is flagged as V2+ tooling: not needed for the V1 measurement instrument, potentially decisive when tail-bracket edge becomes the specific hypothesis. The weight function is a pre-registration object — choosing $w$ after seeing where a model wins is the selection-effect trap in new clothing.

### 5.7 Multivariate scoring rules: energy, Dawid–Sebastiani, variogram

The lab's five cities co-move under shared synoptic systems; a _joint_ forecast over cities is a multivariate object. V1 scope treats cities marginally (with dependence handled in the _inference_ layer via date clustering), so multivariate scores are catalogued for completeness and routed to [[Future Directions]]:

- **Energy score** (Gneiting & Raftery 2007): $\text{ES}(F, \mathbf y) = \mathbb{E}|\mathbf X - \mathbf y| - \tfrac12 \mathbb{E}|\mathbf X - \mathbf X'|$ — the direct multivariate generalization of the CRPS kernel form. Strictly proper; known weakness: limited sensitivity to misspecified _correlation_ structure relative to marginals (Pinson & Tastu 2013 ⚑).
- **Dawid–Sebastiani score** (Dawid & Sebastiani 1999 ⚑): $\text{DSS}(F, \mathbf y) = \ln\det \Sigma_F + (\mathbf y - \boldsymbol\mu_F)^\top \Sigma_F^{-1} (\mathbf y - \boldsymbol\mu_F)$ — proper relative to the first two moments (the Gaussian log score up to constants); cheap, moment-based, not strictly proper beyond the Gaussian family.
- **Variogram score** (Scheuerer & Hamill 2015 ⚑): built from pairwise differences $|y_i - y_j|^p$; specifically more sensitive to dependence-structure errors, at the cost of being blind to a common additive bias.

**Lab stance.** If V2+ modeling ever issues _joint_ city forecasts (e.g., to trade cross-city spreads), the registered grading instrument should be energy score plus variogram score together — each covers the other's blind spot. Deliberately out of V1 scope; recorded here so the omission is a decision, not an oversight.

### 5.8 The lab's score-selection convention

|Object being graded|Registered score(s)|Diagnostic companion|
|---|---|---|
|Single contract probability (model or market)|Log (primary; nats), Brier (secondary)|Brier-vs-log rank divergence → tail investigation|
|Full bracket ladder (per market)|RPS (convention 5.4)|Per-threshold Brier decompositions|
|Underlying temperature distribution|CRPS|PIT histogram (6.4)|
|Skill reporting|BSS / RPSS / CRPSS vs fixed reference ladder|Never optimized against (8.3)|
|Tail-focused hypotheses (V2+)|twCRPS, pre-registered $w$|Forecaster's-dilemma check|
|Joint multi-city forecasts (V2+)|Energy + variogram|—|

---

## 6. Calibration and the attributes of forecast quality

### 6.1 Calibration defined, and the taxonomy of calibration notions

**Calibration** is a property of a forecast–outcome _pairing_, never of a forecast alone: forecasts are calibrated (reliable) if, conditional on the forecast, outcomes match it. For binary forecasts, informally, $\Pr(Y = 1 \mid \hat p = p) = p$ for all issued $p$ — among all the days you said "70%," it rained on 70%.

For distributional forecasts, "calibration" is not one property but several, and the distinctions were drawn in the same paper that supplies this lab's governing paradigm (Gneiting, Balabdaoui & Raftery 2007):

- **Probabilistic calibration:** the PIT values $Z = F(Y)$ are uniform on $[0,1]$ — the workhorse notion, checkable via the PIT histogram (Section 6.4).
- **Exceedance calibration:** conditional on the forecast's stated exceedance probabilities, realized exceedance frequencies match.
- **Marginal calibration:** the long-run average forecast CDF equals the empirical CDF of outcomes — the distributional analogue of "your average probability equals the base rate."

These notions are logically distinct: a forecaster can be marginally calibrated while probabilistically miscalibrated and vice versa. The lab's temperature-distribution layer requires probabilistic calibration (PIT-based) as the registered check; marginal calibration is the cheap first-pass sanity check (compare average forecast CDF against the climatological CDF).

The **governing paradigm** of modern verification: probabilistic forecasting should **maximize sharpness subject to calibration** (Gneiting, Balabdaoui & Raftery 2007). Calibration is the constraint — non-negotiable honesty of the probability scale; sharpness is the objective — say as much as the information allows.

### 6.2 Sharpness, resolution, discrimination, refinement — kept distinct

These four terms are systematically conflated in casual use; the lab keeps them separated because they demand different remedies.

- **Sharpness** is a property of the **forecasts alone**: the concentration of the predictive distributions. For binary forecasts, forecasts near 0 and 1 are sharp; for temperature distributions, narrow predictive densities are sharp. Sharpness says nothing about correctness — a forecaster who always says 0.99 in a 50% world is maximally sharp and maximally miscalibrated. (V1 glossed sharpness as "distance from the base rate"; that phrasing invites reading sharpness as intrinsically creditable. It is not. It is creditable only _subject to calibration_.)
- **Resolution** is a property of the **joint** forecast–outcome distribution: how much the conditional outcome frequency $\Pr(Y=1 \mid \hat p)$ _varies_ across issued forecast values, i.e., how well the forecasts sort occasions into genuinely different regimes. Resolution is where information lives; it is the term that "pays" in the decomposition (Section 7).
- **Discrimination** conditions the other way: how different the forecast distributions are, conditional on the outcome — the ranking notion measured by AUC. Under a strictly monotone recalibration, discrimination is invariant while reliability changes; hence the diagnostic recipe in Section 12.2.
- **Refinement** is the classical term (DeGroot & Fienberg 1983 ⚑) for the distribution of issued forecasts itself; among _calibrated_ forecasters, "more refined" (mass pushed toward 0/1) is strictly better, and the refinement ordering is the calibrated shadow of sharpness.

**The interaction, in one paragraph.** A calibrated forecaster with no resolution exists — it is climatology, issuing the base rate forever. A sharp forecaster with no calibration exists — it is a liar with conviction. Skill requires both: the decomposition (Section 7) makes the trade explicit as $\text{score} = \text{miscalibration} - \text{resolution} + \text{uncertainty}$, and the paradigm orders the priorities: first be calibrated (or recalibrate — Section 12), then fight for resolution (better features, better physics), because resolution cannot be added by any post-processing while calibration often can. A monotone recalibration can move reliability to near zero but leaves resolution (and AUC) essentially fixed: **resolution is the model; reliability is the paint.**

### 6.3 The Murphy–Winkler general framework

The organizing formalism for everything above (Murphy & Winkler 1987 ⚑): forecast verification is the study of the **joint distribution** $p(f, y)$ of forecasts and observations, with two canonical factorizations:

- **Calibration–refinement:** $p(f, y) = p(f), p(y \mid f)$ — the marginal distribution of issued forecasts (refinement/sharpness) times the outcome-given-forecast conditionals (calibration, resolution).
- **Likelihood–base rate:** $p(f, y) = p(y), p(f \mid y)$ — the climatology times the forecast-given-outcome conditionals (discrimination).

Every attribute in Section 6.2 is a functional of one factorization or the other, which is why they are distinct and why no single scalar can capture forecast quality. Scores compress $p(f,y)$ to a number; decompositions un-compress it just enough to act on.

### 6.4 Diagnostics: reliability diagrams, consistency bands, PIT and rank histograms

**Reliability diagrams** plot conditional observed frequency $\bar o_k$ against issued forecast $\bar p_k$ (by bin or, preferably, by the CORP method of Section 7.4 which removes binning choices). The diagonal is perfection; the vertical gaps are the reliability term. Two mandatory disciplines:

1. **Uncertainty bands before interpretation.** Bin frequencies carry binomial noise $\sqrt{p(1-p)/n_k}$: at $n_k = 10$, $p = 0.7$, the standard error is ±14.5 percentage points — early "miscalibration" at the lab's monthly sample sizes is mostly noise. Use **consistency bands** — resampling outcomes under the hypothesis that the forecasts are calibrated, then banding the diagram (Bröcker & Smith 2007 ⚑) — or CORP's built-in uncertainty quantification. Shapes are signal only after the bands say so.
2. **The diagram is per-forecaster, per-event-population.** Pooling across heterogeneous populations manufactures fake resolution (Section 8.2's Hamill–Juras trap).

**PIT histograms** are the calibration instrument for the distributional layer. Compute $Z_i = F_i(y_i)$ for each forecast CDF and realized value; under probabilistic calibration the $Z_i$ are i.i.d. uniform (continuous case). Read the shapes: ∪-shaped → underdispersed (overconfident distributions); ∩-shaped → overdispersed; sloped → biased. For discrete/ensemble forecasts the analogue is the **rank histogram**, with the standard caveat that flatness is **necessary, not sufficient**: mixtures of offsetting misspecifications can produce flat histograms from bad forecasts (Hamill 2001 ⚑). PIT uniformity should be tested with bands, not eyeballed, and serial dependence in the $Z_i$ (same synoptic system across days) biases naive uniformity tests — cluster by date, as everywhere else in this lab.

**Discretization note for temperatures.** Settlement temperatures are reported in whole degrees; the forecast CDF is continuous. Randomized PIT ($Z$ drawn uniformly on $[F(y^-), F(y)]$) is the standard fix for discreteness ⚑; the chosen variant is a registered convention.

---

## 7. The Murphy decomposition — classical form, modern form, and the reconciliation invariant

### 7.1 The three-component decomposition and its exactness condition

Stratify $N$ binary forecast–outcome pairs on the **distinct issued forecast values** $f_k$, with $n_k$ occasions, conditional outcome frequency $\bar o_k$, and base rate $\bar o$. Murphy (1973) showed the Brier score decomposes **exactly**:

$$\text{BS} ;=; \underbrace{\frac1N \sum_k n_k, (f_k - \bar o_k)^2}_{\text{Reliability (REL, ↓)}} ;-; \underbrace{\frac1N \sum_k n_k, (\bar o_k - \bar o)^2}_{\text{Resolution (RES, ↑)}} ;+; \underbrace{\bar o,(1 - \bar o)}_{\text{Uncertainty (UNC)}}.$$

REL is the calibration error made additive (squared gaps between what you said and what happened, weighted by how often you said it). RES is the payoff of sorting occasions into regimes that genuinely differ from climatology. UNC is the base-rate variance no forecaster controls — and it equals climatology's own Brier score, whence $\text{BSS}_{\text{clim}} = (\text{RES} - \text{REL})/\text{UNC}$: skill over climatology is exactly resolution net of miscalibration, in units of the problem's intrinsic difficulty.

**The exactness condition matters.** The identity above is exact only when stratifying on _identical_ forecast values. When continuous forecasts are grouped into bins — which is what any pipeline does with model outputs or market midpoints — the three terms **do not sum to the Brier score**.

### 7.2 Binned data: the two extra components

With binned forecasts, two additional within-bin terms are required — the pooled **within-bin variance** of the forecasts minus the **within-bin covariance** between forecasts and outcomes (Stephenson, Coelho & Jolliffe 2008, _Weather and Forecasting_ 23:752–757) **[verified in audit session, including the WBV/WBC identification of the extra terms]**:

$$\text{BS} = \text{REL} - \text{RES} + \text{UNC} + \text{WBV} - \text{WBC}.$$

Stephenson et al. combine the extras with RES into a **generalized resolution** less sensitive to bin choice. The engineering consequence is blunt: a pipeline that computes the three classical terms on binned data and reconciles against the directly computed Brier score **will find a discrepancy that is not a bug** — or worse, will not reconcile at all and ship components that silently disagree with the headline score. Hence the invariant in Section 7.6.

### 7.3 Estimator bias — a separate problem from exactness

Even with the exactness issue handled, the _plug-in estimators_ of REL and RES are biased upward in small bins (conditional frequencies estimated from few events overstate variation). Bias-corrected estimators exist (Ferro & Fricker 2012, _QJRMS_ 138:1954–1960 ⚑; variance estimation: Siegert 2014 ⚑). At this lab's early sample sizes (~150 city-days/month), uncorrected component estimates at monthly cadence are **descriptive only**; decomposition-based _claims_ wait for the sample the pre-registration says they need. Exactness (7.2) and bias (7.3) are different failures with different fixes; V1 conflated them.

### 7.4 The registered modern method: CORP

The lab's registered decomposition and reliability-diagram method is **CORP** (Dimitriadis, Gneiting & Jordan 2021, _PNAS_ 118(8):e2016191118) **[verified in audit session]**: fit nonparametric isotonic regression of outcomes on forecasts via the pool-adjacent-violators (PAV) algorithm; the reliability diagram is the graph of the PAV-recalibrated probabilities, and the score decomposes as

$$\text{score} = \text{MCB} - \text{DSC} + \text{UNC},$$

miscalibration, discrimination (resolution), and uncertainty. CORP's properties, each solving a problem this document has already named: **(i)** no binning choices — it is Consistent, Optimally binned, and Reproducible, eliminating the ECE-binning artifact class entirely; **(ii)** built-in uncertainty quantification by resampling or asymptotics — the bands of Section 6.4 come for free; **(iii)** the decomposition **generalizes to any proper scoring rule** — one method serves Brier and log alike **[verified in audit session: PNAS abstract states the CORP-based decomposition generalizes to any proper score]**; **(iv)** the isotonic fit _is_ the natural monotone recalibration map (Section 12), so diagnosis and remedy share one object. The generality in (iii) has a theoretical root worth recording: the reliability–resolution–uncertainty structure is a property of **every** proper score, not a Brier quirk (Bröcker 2009, _QJRMS_ 135:1512–1519 ⚑).

### 7.5 Decomposing the log score directly

Because log is the lab's primary score, its own decomposition avoids a units mismatch between diagnosis (Brier components) and objective (nats). The KL-based decomposition (Weijs, van Nooijen & van de Giesen 2010, _MWR_ 138:3387–3399 ⚑) has the same three-part structure with information-theoretic identities: **UNC is the Shannon entropy** $H(\bar o)$ of the climate; **RES is the mutual information** between forecast and outcome; **REL is the expected KL divergence** from the conditional outcome frequencies to the issued forecasts. Skill in nats = information about the outcome, minus the nats you waste on miscalibration. This is the cleanest single statement of what the lab's edge metric is measuring (and it is the bridge lemma between Sections 7, 10, and 11).

### 7.6 Engineering implications

1. **Reconciliation invariant (registered):** for every decomposition run, components must sum to the independently computed total score within a stated floating-point tolerance. With CORP this holds exactly by construction; with any binned method the WBV/WBC terms must be included for the check to pass. A reconciliation failure is a pipeline defect, full stop.
2. **One method, pre-registered:** CORP for binary components (Brier and log); threshold-wise CORP for RPS diagnostics. Method switches are re-registrations.
3. **Diagnosis dictates remedy:** high MCB → recalibrate (Section 12) — and re-register the recalibrated forecaster as a new forecaster, per standing governance law; low DSC → no post-processing can help; the model lacks information — features, physics, data.
4. **Component claims obey the same inference discipline as score claims:** date-clustered uncertainty, pre-registered sample thresholds (Sections 8.4, and A1 when ratified).

---

## 8. Forecast verification practice

### 8.1 Verification philosophy: consistency, quality, value

Murphy (1993, "What is a good forecast?" _Weather and Forecasting_ ⚑) distinguishes three kinds of forecast "goodness," and the lab's document architecture mirrors the trichotomy:

- **Consistency** — the forecast reflects the forecaster's actual beliefs. Proper scoring rules are the mechanism that makes consistency incentive-compatible (this document, Sections 3–4).
- **Quality** — the correspondence between forecasts and observations. Scores, calibration, decompositions (this document, Sections 5–7).
- **Value** — the economic benefit to a decision-maker. Owned by [[Expected Value]] and [[Kelly Criterion]]; connected to quality by the Kelly identity (Section 11.3) and _only_ by it — in general, quality improvements do not map monotonically to value for every user (Murphy & Ehrendorfer 1987 ⚑).

The necessary-vs-sufficient structure of the lab's edge claim lives exactly on the quality/value boundary: score-edge (quality) is necessary for profit (value); sufficiency additionally requires clearing event-dependent costs at executable prices (Section 11.3).

### 8.2 Reference forecasts: climatology, persistence, and two classical traps

Absolute scores are incomparable across event sets — Miami city-days are intrinsically more predictable than Chicago's in some months, and any score mixes forecaster skill with question difficulty. Skill is therefore always **relative to a reference**. The standard references:

- **Climatology** — the long-run outcome distribution for the event class. The lab's base reference; its Brier score is UNC, making it the canonical difficulty normalizer.
- **Persistence** — "tomorrow = today." A demanding reference at short horizons for autocorrelated variables like temperature; a weak one at long horizons. Persistence-relative skill isolates whether a model adds anything beyond the atmosphere's own memory.
- **The market price** — the lab's distinctive third rung (Section 11.4). Climatology → NWS-derived model → market: each rung asks a sharper question.

**Trap 1 — in-sample references.** Computing skill against a climatology _estimated on the evaluation sample itself_ flatters the forecaster (the reference is handicapped by its own estimation noise, and subtler biases arise even in expectation; Mason 2004 ⚑). References must be **fixed out-of-sample before evaluation** — for this lab, a pre-registered climatology window per city per calendar period.

**Trap 2 — pooling across heterogeneous climatologies.** Pooling five cities (or two seasons) with different base rates into one skill computation manufactures fake resolution: the "forecaster" gets credit merely for knowing that Phoenix is hot and Chicago is not, which climatology already knew (Hamill & Juras 2006, "Is it real skill or is it the varying climatology?" _QJRMS_ ⚑). **Lab rule:** skill is computed within city (and, where feasible, within season) against the city-specific reference, then aggregated with pre-registered weights. Pooled headline numbers are reported only alongside the stratified ones.

### 8.3 Skill scores — useful, and improper

$$\text{BSS} = 1 - \frac{\text{BS}_{\text{fcst}}}{\text{BS}_{\text{ref}}}, \qquad \text{similarly RPSS, CRPSS.}$$

Skill scores normalize difficulty and are the correct _reporting_ format. But ratio-form skill scores are generally **improper** (the classical observation traces to Murphy; modern treatment in Gneiting & Raftery 2007 ⚑): optimizing BSS directly can differ subtly from optimizing BS, because the denominator couples events. The rule is mechanical: **proper scores for optimization and testing; skill scores for reporting.** Small-sample skill scores are additionally biased toward "no skill" and their sampling distributions are awkward — inference belongs on paired score differentials, never on skill-score point estimates.

### 8.4 Inference on score differences

The lab's claims are comparative — "forecaster A outscores forecaster B" — so the inferential object is the paired differential $d_i = S_A(i) - S_B(i)$ on the **same events**, tested for $\mathbb{E}[d] > 0$ with dependence-robust uncertainty. The framework of record is Diebold–Mariano (1995), with three lab-specific annotations:

1. **The dependence structure is cross-sectional first, serial second.** Vanilla DM with HAC standard errors handles serial dependence in a single differential series. The lab's dominant dependence is _cross-sectional_: up to five cities and ~6 brackets resolving from correlated (brackets: identical) draws on the same date. The estimator that matches the declared dependence model is **date-clustered** — cluster-robust variance or block/cluster bootstrap resampling whole dates — not HAC alone. (The honest sample-size unit is the city-day, further discounted for cross-city correlation; see [[Effective Sample Size]].)
2. **Small samples distort DM.** At the lab's early effective sample sizes, apply the Harvey–Leybourne–Newbold small-sample correction ⚑ and prefer bootstrap-based intervals over asymptotic normal ones.
3. **DM compares forecasts, not models** (Diebold 2015 ⚑) — which for this lab is a _feature_: the market's forecast stream is exactly the object of interest, with no model behind it that we could or should refit.

Heavy-tailed log-score differentials (Section 5.1) further favor bootstrap inference. All of Section 8.4 is a placeholder-with-interest for **A1 (Statistical Validity & Inference Framework)**: when A1 is ratified it owns test choice, multiplicity control (BH-FDR per the lab's standing approach), and power analysis; this document then defers to it by link. Flagging the dependency now prevents dual ownership later.

### 8.5 Meteorological practice and standards

Operational weather verification — the WMO's guidance and the practice codified in Jolliffe & Stephenson's _Forecast Verification_ (2nd ed. 2012 ⚑) and Wilks's _Statistical Methods in the Atmospheric Sciences_ ⚑ — converges on the same toolbox this document registers: Brier and decomposition for probability-of-event products, reliability diagrams with uncertainty bands, RPS/RPSS for ordered categories, CRPS for continuous variables, rank/PIT histograms for ensembles, and skill always against explicit references. ⚑ The specific current WMO recommendation documents should be pulled and cited by number before this paragraph is treated as load-bearing; the substantive point — that the lab's conventions match mainstream operational verification rather than inventing bespoke metrics — is robust. The one lab deviation from meteorological habit is deliberate: log score as primary (for its Kelly denomination), where meteorology defaults to Brier/CRPS.

---

## 9. Bayesian connections

### 9.1 Propriety from expected utility

Proper scoring is Bayesian decision theory run in reverse. A Bayesian holding posterior predictive $Q$ and facing payoff $S(P, y)$ chooses the report maximizing posterior expected utility; propriety is precisely the condition that this choice is $P = Q$. Elicitation with a strictly proper rule therefore reveals the posterior predictive distribution — the entire content of the forecaster's beliefs about the observable. There is no separate "Bayesian theory of scoring rules"; propriety _is_ the expected-utility characterization (Savage 1971; Bernardo & Smith 1994 ⚑).

### 9.2 Log score, predictive likelihood, and Bayes factors

Cumulative log scores are log predictive likelihoods: for a forecast system issuing $P_t(\cdot \mid \text{data}_{<t})$ sequentially,

$$\sum_{t=1}^{T} \ln P_t(y_t) ;=; \ln \prod_t P_t(y_t) ;=; \ln p(y_1, \dots, y_T \mid \text{system}),$$

by the chain rule — the log of the _prequential_ (predictive-sequential) likelihood of everything that happened (Dawid 1984 ⚑). Consequently the cumulative log-score **difference** between two forecast systems is the log **Bayes factor** between them as predictive models. When this lab says "the model out-log-scores the market by $x$ nats per city-day," it is reporting the rate at which evidence accumulates for the model over the market in a Bayesian model comparison — the same arithmetic that drives posterior odds. Brier has no such identity; this, along with Kelly denomination, is why log is primary.

The empirical-risk view gives the same object a frequentist name: minimizing mean negative log score _is_ maximum likelihood; the log score's centrality is the centrality of likelihood itself.

### 9.3 Posterior predictive forecasting and updating

The lab's model layer, done Bayesianly, issues posterior predictive distributions: $F_{\text{pred}}(y) = \int F(y \mid \theta), \pi(\theta \mid \text{data}), d\theta$ — parameter uncertainty propagated into forecast dispersion, which is exactly what CRPS and PIT then grade. Two standing facts connect updating to scoring. First, coherent updating is what the log score rewards in expectation: under truth $Q$, incorporating information that moves $P_0$ to $P_1$ pays $D_{\mathrm{KL}}(Q|P_0) - D_{\mathrm{KL}}(Q|P_1)$ nats (Section 4.4). Second, over-tight posteriors (ignored parameter or model uncertainty) show up as ∪-shaped PIT histograms and unbounded log-score losses on tail events — the diagnostics and the epistemics agree about what sin looks like.

### 9.4 The well-calibrated Bayesian, and calibration's cheapness

Two classical results bracket what calibration can and cannot certify:

- **Dawid (1982):** a coherent Bayesian _expects_ to be calibrated — computed on their own posterior, the anticipated calibration check passes. Self-assessed calibration is therefore weak evidence; only out-of-sample, adversarially chosen verification counts.
- **Foster & Vohra (1998):** a _randomized_ forecaster can achieve asymptotic calibration against **any** outcome sequence, with zero predictive knowledge. (Deterministic forecasters cannot — Oakes 1985 ⚑ — which is why the construction needs randomization.)

Jointly: **calibration is nearly free, and resolution is everything.** The Foster–Vohra forecaster is calibrated and has _no resolution whatsoever_; climatology is its honest deterministic cousin. The lab's edge claim is therefore, in decomposition language, a **resolution claim** — that the model sorts city-days into regimes the market's prices do not distinguish — policed for honesty by the reliability term. This sentence is the lab's entire hypothesis in the vocabulary of this document.

---

## 10. Information theory

### 10.1 Surprisal, entropy, cross-entropy

The negative log score $-\ln P(y)$ is the **surprisal** of the outcome under the forecast — the information content, in nats, of what happened, measured against what you believed. Its expectation under truth $Q$ is the **cross-entropy** $H(Q, P) = -\mathbb{E}_Q \ln P(y)$, which splits as

$$H(Q, P) = H(Q) + D_{\mathrm{KL}}(Q | P):$$

irreducible uncertainty plus the penalty for believing $P$ when the world runs on $Q$. Mean negative log score is exactly the ML community's "cross-entropy loss" — one object, three vocabularies (meteorology's ignorance, statistics' negative log likelihood, ML's cross-entropy); the lab treats the terms as synonyms to prevent boundary confusion.

### 10.2 The coding interpretation

By the source-coding theorem, a probability model $P$ defines a code with lengths $-\log_2 P(y)$ bits; the expected excess length of coding $Q$-distributed data with $P$'s code is $D_{\mathrm{KL}}(Q|P)$ bits. A forecaster's ignorance score is the length of the message needed to tell them what happened. Out-scoring the market by $x$ bits per event means: the market would need $x$ more bits per event than you to describe reality. Compression, prediction, and gambling are the same optimization — the third leg is Kelly (Section 11.3), and Cover & Thomas's gambling chapters make the triangle rigorous.

### 10.3 Mutual information and resolution

The log-score decomposition (Section 7.5) identifies its resolution term with the **mutual information** $I(\hat p,; Y)$ between issued forecasts and outcomes, and its uncertainty term with the outcome entropy $H(Y)$. Skill over climatology in nats is then _information extracted about the outcome, net of miscalibration waste_. This gives the lab's Δ-vs-edge distinction an information-theoretic restatement: **disagreement** is a difference between two reports; **edge** is demonstrated excess mutual information with settlement reality, at population scale, surviving dependence-honest inference.

### 10.4 Why the logarithm emerges everywhere

Four independent requirements each force the log:

1. **Locality** on ≥3-outcome spaces (Section 4.2) — uniquely the log family.
2. **Additivity of evidence** — the only score under which independent events' scores add to the score of the joint, matching how likelihoods and code lengths compose.
3. **Bayes consistency** — cumulative score differences = log Bayes factors (Section 9.2); no other rule reproduces posterior-odds arithmetic.
4. **Growth optimality** — log utility is the unique utility whose maximization yields maximal asymptotic capital growth rate (Kelly 1956; Breiman 1961 ⚑), and its induced forecast evaluation is the log score (Section 11.3).

That four unrelated desiderata select one functional form is the strongest available argument that the lab's primary metric is not a stylistic choice.

---

## 11. Prediction market applications

### 11.1 Prices are forecasts; market calibration is an empirical question

A binary contract's price (suitably extracted — Section 11.5) is the market's probability report, scoreable and decomposable exactly like a model's. Market calibration is therefore not an assumption but a **testable property**, and the betting-markets literature has tested it for a century: the canonical anomaly is the **favorite–longshot bias** — longshots systematically _overpriced_, favorites _underpriced_ — documented across racetrack and betting markets (Thaler & Ziemba 1988 ⚑). The two standard explanatory families are **risk preference** (bettors derive utility from skewed payoffs) and **probability misperception** (small probabilities overweighted), disentangled empirically in Snowberg & Wolfers (2010, _JPE_ ⚑), whose evidence favors misperception in their setting. Directionality matters and has been previously mis-stated in vault materials (since corrected): the bias, where present, means _low-priced_ contracts are on average even less likely to pay than their price implies.

Whether any such pattern exists in Kalshi weather brackets is **unknown** — weather markets differ from racetracks in participant mix, in the availability of a public high-quality forecast (NWS), and in the mechanical bracket structure. That question is Experiment 1's target, not an assumption of anything downstream.

### 11.2 Market mechanisms built from scoring rules: the LMSR

Hanson's Logarithmic Market Scoring Rule market maker (Hanson 2003, 2007 ⚑) is the log score converted into a trading mechanism: cost function $C(\mathbf q) = b \ln \sum_i e^{q_i / b}$ over outstanding quantities $\mathbf q$, instantaneous prices the softmax $p_i = e^{q_i/b}/\sum_j e^{q_j/b}$. The defining accounting identity of any _market scoring rule_: each trader who moves the market's report from $P_{\text{old}}$ to $P_{\text{new}}$ receives, at settlement, exactly $S(P_{\text{new}}, y) - S(P_{\text{old}}, y)$ — **profit equals the improvement in the market's log score that the trade produced**. The market's final price is a sequentially shared forecast whose accuracy was paid for, trade by trade, in score units.

Kalshi runs a central limit order book, not an LMSR; no mechanical identity forces CLOB prices to be good forecasts. But the _conceptual_ equivalence survives the mechanism change, because it re-enters through the trader's side:

### 11.3 The Kelly–log-score identity

**Setting.** One binary contract; YES pays $1; market price $r \in (0,1)$; both sides tradeable; frictionless (fees and spread deferred two paragraphs). A log-utility (Kelly) trader with belief $p$ facing a complete two-outcome market allocates wealth so terminal wealth is proportional to belief: fraction $p$ into YES at price $r$, fraction $1-p$ into NO at price $1-r$ (the Cover–Thomas horse-race allocation). Wealth growth factor: $p/r$ if $Y=1$; $(1-p)/(1-r)$ if $Y=0$.

**Identity.** Under true probability $q$:

$$\mathbb{E}_q[\ln \text{growth}] = q \ln\frac{p}{r} + (1-q)\ln\frac{1-p}{1-r} = \underbrace{\big[q\ln p + (1-q)\ln(1-p)\big]}_{\text{your expected log score}} - \underbrace{\big[q\ln r + (1-q)\ln(1-r)\big]}_{\text{market's expected log score}} = D_{\mathrm{KL}}(q|r) - D_{\mathrm{KL}}(q|p).$$

**Consequences.** (i) Positive expected log growth ⇔ your log score beats the market's on those events: _edge detection is score comparison_, exactly. (ii) The market is unbeatable in expectation by any belief iff $r = q$ — within this model, price-equals-truth is the definition of efficiency. (iii) Your maximum extractable growth rate is capped by $D_{\mathrm{KL}}(q|r)$, the market's own divergence from truth: you cannot win more than the market is wrong, and you win it all only by being exactly right.

**Scope conditions — the identity is powerful because it is narrow.** The derivation assumes:

1. **A complete two-outcome market, full wealth deployed, one event at a time.** With the lab's actual structure — multiple correlated city-day markets resolving simultaneously — per-market Kelly is not jointly optimal and expected growth does **not** decompose as a sum of per-market identities; joint sizing is a portfolio problem owned by [[Kelly Criterion]].
2. **Known belief $p$.** With estimated $\hat p \ne p$, full Kelly systematically overbets — the growth penalty for overestimating edge is asymmetric — and the standard remedy, fractional Kelly, converts the identity into an inequality (you harvest a known fraction of the score edge in exchange for variance reduction). Details: [[Kelly Criterion]].
3. **Frictionlessness.** Real costs — Kalshi's trading fee and the effective half-spread — are **event-dependent**, not a constant drag: the fee schedule varies with price level (⚑ **verify the current Kalshi fee formula against the primary source before any cost model is registered**; do not trust any document's recollection of its functional form, including this one), and effective spread varies with liquidity, moneyness, and time to settlement. The tradeable condition is therefore _score-edge exceeding an event-dependent cost threshold at executable prices_ — the precise quality/value boundary (Section 8.1), and the sufficiency half of the lab's necessary-vs-sufficient edge doctrine.

None of these caveats weakens the identity's role as the lab's conceptual spine: score edge remains **necessary** for log-growth profit under every relaxation, which is exactly what a V1 measurement instrument needs it to be.

### 11.4 The lab's operational translation

- **Reference ladder for skill:** climatology → NWS-derived model → **market price**. Each rung is a fixed, pre-registered reference; positive, dependence-robust log/Brier skill versus the market rung is the lab's formal definition of **edge**. Raw price–model divergence is **disagreement (Δ)**; it earns the name _edge_ only after surviving the population-level inference of Section 8.4 under A1's rules.
- **Necessary vs sufficient:** score edge is necessary for profit; sufficiency requires clearing event-dependent costs (11.3, condition 3) — out of scope until the V3 gate.
- **Experiment 1 (model-free market audit):** calibration analysis (CORP) + Brier/log scores of Kalshi closing midpoints against settlements, per city and pooled-with-stratification (8.2, Trap 2), with date-clustered uncertainty. It answers "how efficient is the competition?" before any model exists, and its price-extraction rule must be fixed pre-analysis (11.5).

### 11.5 Market-probability extraction — a registered convention, not an afterthought

Scoring "the market" requires deciding what the market's forecast _is_. Last trade in a thin market is stale (the lab's own 1a reconnaissance found live quotes with zero volume). Candidates: bid–ask midpoint at a defined timestamp; time-weighted midpoint over a window; microprice (size-weighted). Each choice changes scores; wide, crossed, or absent quotes near settlement need explicit handling rules (score-and-flag, exclude-and-log, or impute — each with different selection risks). **The choice is a pre-registration object**: fixed before scoring, recorded with dual timestamps, applied uniformly. Currently an open Unknown (Section 19); the default pending registration is the bid–ask midpoint at a defined snapshot time with explicit exclusion rules for degenerate quotes.

---

## 12. Machine learning calibration and recalibration

### 12.1 The methods

When the decomposition says MCB is the problem (and DSC is worth keeping), recalibration maps raw model outputs $s$ to calibrated probabilities $\hat p = g(s)$ using held-out data. The standard family, in order of increasing flexibility:

- **Platt scaling** (Platt 1999 ⚑): logistic map $g(s) = \sigma(as + b)$, two parameters. Works in low-data regimes; assumes the miscalibration is sigmoid-shaped — misspecified when it is not (e.g., one tail fine, the other broken).
- **Beta calibration** (Kull, Silva Filho & Flach 2017 ⚑): three-parameter family derived from Beta likelihood ratios, strictly generalizing Platt for probability-valued inputs; fixes Platt's inability to leave already-calibrated forecasts alone. The parametric default for binary probability inputs.
- **Temperature scaling** (Guo et al. 2017 ⚑): single parameter dividing logits before softmax; the modern neural-network default. Strictly monotone, hence AUC/discrimination-preserving by construction; too rigid to fix asymmetric miscalibration.
- **Isotonic regression** (Zadrozny & Elkan 2002 ⚑): nonparametric monotone fit via PAV — the same algorithm as CORP, which is why diagnosis and remedy share an object (Section 7.4). Most flexible; most data-hungry; on small samples it memorizes noise (a step function through the training outcomes), so it demands strictly held-out fitting data and, at this lab's early n, comes _after_ the parametric options, not before.

**Selection heuristic:** sample size and miscalibration shape choose the method — monotone-and-simple (temperature/Platt) → beta → isotonic as data grows and diagnosed shape demands. All recalibration fitting is out-of-sample relative to evaluation, always.

### 12.2 Evaluating probabilistic models — the combined recipe

The three-instrument diagnosis, each instrument answering one question:

1. **Proper score (log primary)** — is the model better overall, with dependence-honest inference on paired differentials?
2. **CORP decomposition** — _why_: MCB (fixable by recalibration) vs DSC (fixable only by a better model)?
3. **AUC / discrimination** — the ceiling check: since monotone recalibration preserves AUC while repairing reliability, good-AUC-bad-reliability means recalibrate; bad AUC means no recalibration can save it — return to features and physics.

On ECE: the popular expected calibration error $\sum_k \frac{n_k}{N}|\bar o_k - \bar p_k|$ is binning-sensitive and non-reproducible across implementation choices (a well-documented ML-literature complaint, e.g. Naeini et al. 2015 ⚑; Guo et al. 2017 ⚑). The lab's registered miscalibration scalar is **CORP's MCB**, which eliminates the artifact class rather than sensitivity-testing around it. If ECE is ever reported for comparability with external work, it is reported with multiple binnings and labeled non-canonical.

### 12.3 Governance: recalibrated forecasters are new forecasters

A recalibration map fitted on data is a modeling decision made after seeing outcomes. **Standing law, restated here where a future reader will look for it:** a recalibrated forecaster is a **new registered forecaster**, scored only from its registration date forward. Post-hoc recalibration of an existing forecaster's history is a governance violation — it is exactly the "improve the forecast after the fact" move that proper scoring exists to make expensive, smuggled in through the evaluation layer.

---

## 13. Computational considerations

### 13.1 Floating point and log-domain arithmetic

- Work in **log-probabilities end-to-end** wherever the model natively produces them; exponentiate only at the display layer.
- For $p$ near 1, compute $\ln(1-p)$ via `log1p(-p)`, never `log(1-p)` — catastrophic cancellation begins around $p > 1 - 10^{-8}$ in float64.
- Normalize multi-bracket log-probability vectors with **log-sum-exp** (subtract the max before exponentiating); never normalize in probability space when values span many orders of magnitude.
- Float64 throughout the scoring path. Mean aggregation over the lab's N is numerically benign at float64; pairwise/Kahan summation is cheap insurance if score tables grow past ~$10^7$ rows.

### 13.2 The clipping policy (registered convention)

The log score is undefined at $P(y)=0$ and explosive near it. The lab's policy:

1. All probabilities entering a log score are clipped to $[\varepsilon, 1-\varepsilon]$ with a **single registered $\varepsilon$** (proposed default $\varepsilon = 10^{-6}$; ratify in the relevant registration, not ad hoc in code).
2. Every clipping event is **counted and logged** per forecaster per period. Clipping is not neutral bookkeeping: it truncates exactly the tail penalties the log score exists to impose, and a forecaster whose scores depend materially on $\varepsilon$ has a tail problem the headline number is hiding. A sensitivity line (scores at $\varepsilon$, $10\varepsilon$, $\varepsilon/10$) accompanies any log-score claim where clipping fired.
3. Market-implied probabilities at the boundary (price 0 or 1, or degenerate quotes) route through the extraction rules of 11.5, not through silent clipping.

### 13.3 Costs and complexity

All scores here are $O(N)$ or $O(N \log N)$ (sorted-sample CRPS); PAV/CORP is $O(N \log N)$ dominated by the sort; bootstrap inference is embarrassingly parallel over resamples. Nothing in this document is computationally binding at the lab's scale; the binding constraints are statistical (effective sample size) and calendrical (the accrual clock), never CPU.

### 13.4 Pipeline invariants (the reconciliation suite)

Registered checks that run with every scoring batch; any failure blocks publication of the batch:

1. Decomposition components sum to the directly computed score within tolerance (Section 7.6).
2. Orientation tags present and consistent with the sign of perfect-forecast scores (Section 2).
3. Unit tags: nats stored for log; bits only at display; RPS rows carry $m$.
4. Climatology identities hold on reference forecasts: reference Brier = UNC within tolerance; reference skill = 0 exactly.
5. Clipping-event counts reported; sensitivity line triggered when nonzero.
6. Every score row carries dual timestamps (event time, ingestion time) and the extraction-rule version (11.5) — provenance per Invariants 2–4.

---

## 14. Engineering guidance: building the verification pipeline

The theory above compresses into a build order and a set of contracts. (Operational detail belongs to the D-FV directive series in [[Forecast Verification]]; this section states the architecture-level requirements that those directives implement. Where a convention is stated _here_ — orientation, units, RPS normalization, clipping, reconciliation — this document is its home.)

**Data contracts.** A scored event row is: event identifier (city-day, bracket set version), forecaster identifier (registered, versioned), forecast payload (probability vector or distribution parameters), extraction-rule version for market forecasters, outcome from the settlement source of record, dual timestamps, and score values with orientation/unit tags. Rows are append-only per Invariant 4; corrections are new rows with supersession links, never edits.

**Separation of layers.** (1) _Collection_ writes raw forecasts and outcomes with provenance; it computes nothing. (2) _Scoring_ is a pure function of collected rows — deterministic, versioned, re-runnable to identical output. (3) _Diagnosis_ (decomposition, diagrams, PIT) runs on scored rows. (4) _Inference_ (differentials, clustering, multiplicity) runs on diagnosis outputs under A1's rules. A bug class is eliminated by each separation: collection cannot be contaminated by model output; scores cannot drift with library versions unnoticed; inference cannot silently redefine the metric it tests.

**Registration before computation.** For every evaluation: event set, forecasters, scores, references, extraction rule, clustering scheme, $\varepsilon$, decomposition method, and sample-size gates are fixed **before** outcomes are examined. The pre-registration template ([[Pre-Registered Experiment Template]]) already enforces this; this document supplies the menu the template's fields draw from.

**Small-n discipline.** At ~150 city-days/month: monthly decompositions and diagrams are descriptive (bands mandatory, claims forbidden); paired-differential claims wait for pre-registered effective-sample thresholds; isotonic recalibration waits for the data volume its variance demands (12.1). The instrument runs from day one; the _claims_ start when the pre-registration says the power exists.

---

## 15. Common misconceptions

1. **"Calibration means accuracy."** No. Calibration is the honesty of the probability scale; climatology is perfectly calibrated and maximally uninformative. Accuracy-style language (hit rate) is not even proper (4.3).
2. **"Sharper is better."** Only subject to calibration. Unconditional sharpness is confidence, not knowledge; the paradigm's word order — sharpness _subject to_ calibration — is load-bearing (6.1–6.2).
3. **"The 85% call was right."** Single outcomes neither validate nor refute probabilities; probabilities are population claims graded on populations (3.1). This misconception is the psychological root of hindsight-driven self-deception, and scores exist to replace it with arithmetic.
4. **"A good classifier is a good probability estimator."** Classification metrics (accuracy, F1, AUC) are invariant to monotone distortions of probability; pricing is not. AUC 0.9 with broken reliability prices contracts wrongly on every trade (4.3, 12.2).
5. **"Log score's harshness on tail misses is a defect."** For this lab it is the point: the log score's tail penalty _is_ the Kelly bettor's ruin, priced in nats (5.1, 11.3). Bounded scores are gentler precisely where trading is deadliest.
6. **"Probability estimates express confidence."** A probability is a claim about event frequency in a reference population, not a feeling about one's model; model confidence belongs in the posterior over parameters, and it widens the predictive distribution rather than shading a point probability (9.3).
7. **"Scores can be compared across event sets."** Question difficulty dominates; only paired differentials on shared events, or skill against fixed references, compare forecasters (8.2–8.4).
8. **"REL−RES+UNC always sums to the Brier score."** Only under stratification on identical forecast values; binned pipelines need the two within-bin terms or CORP (7.1–7.4).
9. **"Recalibration is free hygiene."** It is a new model, registered as such and scored from registration (12.3).
10. **"The market being hard to beat means the market is calibrated."** Efficiency and calibration are related but distinct claims; the favorite–longshot literature documents persistent _systematic_ miscalibration coexisting with practical unbeatability after costs (11.1, 11.3 condition 3).

---

## 16. Research Lab integration

- **[[Probability]]** — supplies the population-claim foundation (3.1); this document supplies its measurement operationalization.
- **[[Bayesian Statistics]]** — Section 9 is the bridge: propriety from expected utility, log score as prequential likelihood, Bayes factors as cumulative score differences.
- **[[Forecast Verification]]** — the D-FV engineering directives implement Sections 6–8 and 13–14; conventions registered here are referenced there, one home each.
- **[[Edge Detection]]** — consumes the formal edge definition (11.4): dependence-robust positive skill vs the market reference, Δ ≠ edge.
- **[[Expected Value]]** — owns sufficiency: costs, capacity, execution (11.3 condition 3; 8.1 value).
- **[[Kelly Criterion]]** — owns sizing: fractional Kelly, simultaneous correlated markets, estimation risk (11.3 conditions 1–2).
- **[[Prediction Markets]]** — owns microstructure; consumes 11.1–11.2, 11.5.
- **[[Machine Learning]]** — Section 12; the recalibration methods and the evaluation recipe.
- **Market Normalization (A4)** — the extraction conventions of 11.5 and the probability-vector normalization rules interlock with A4's spec; cross-check at A4 ratification.
- **[[Effective Sample Size]]** — the clustering and power question underlying 8.4; the city-day unit.
- **A1 (pending)** — will own all inference mechanics referenced in 8.4; this document defers on ratification.

## 17. Historical development

The field's arc, in the contributors the lab's shelves already cite. **Brier (1950)** introduced the quadratic score for weather probabilities — verification as arithmetic rather than narrative. **Good (1952)** proposed logarithmic scoring and tied it to rational decision and information; **McCarthy (1956 ⚑)** and then **Savage (1971)** supplied the convex-analysis characterization of _all_ proper rules, turning a collection of examples into a theory. **Epstein (1969)** and **Murphy (1969–1973)** built the ordered-category and decomposition machinery inside meteorology — Murphy's 1973 partition remains the working diagnostic half a century on, and **Murphy & Winkler (1987)** reframed verification as the study of the joint forecast–outcome distribution, the frame Section 6 still uses. **Winkler** (with Matheson, 1976) contributed CRPS and decades of elicitation results; **Dawid (1982, 1984)** connected calibration to Bayesian coherence and founded prequential analysis; **Bernardo (1979)** fixed the log score's information-theoretic uniqueness. **Foster & Vohra (1998)** proved calibration achievable without knowledge, sharpening what verification can certify. **Gneiting & Raftery (2007)** synthesized everything into the modern framework — propriety on general spaces, the score catalog, kernel scores — and **Gneiting, Balabdaoui & Raftery (2007)** stated the sharpness-subject-to-calibration paradigm; the Gneiting school's subsequent program (weighted rules, multivariate scores, CORP) is where Sections 5.6–5.7 and 7.4 come from. In parallel, **Hanson (2003, 2007)** turned scoring rules into market mechanisms, closing the loop this lab trades inside: markets as forecasters, forecasters as bettors, one measurement theory for both.

## 18. Current research frontiers

Recorded so future-facing choices are deliberate (all ⚑; verify state of the art before relying):

- **Distributional regression and probabilistic ML** — models emitting full predictive distributions natively (distributional forests/boosting, conformal prediction, quantile networks), CRPS/pinball-trained; directly relevant to the temperature-distribution layer.
- **Uncertainty-aware deep learning** — ensembles, Bayesian NN approximations, and post-hoc calibration at scale; the ECE-critique literature (which the lab sidesteps via CORP) remains active.
- **Multivariate verification** — energy/variogram-score sensitivity studies, copula-based post-processing; the joint-city question of 5.7.
- **Isotonic-based verification** — the CORP program's extensions beyond binary (quantiles, means, distributions) and its e-value/sequential-testing cousins for anytime-valid calibration monitoring — potentially significant for the lab's rolling monitoring, where fixed-n tests fit awkwardly.
- **Ensemble verification under serial dependence** — stratified rank histograms and dependence-honest PIT testing, matching the lab's clustering problem.
- **Scoring-rule market design** — automated market makers descended from LMSR in modern prediction/crypto markets; relevant to understanding competitor behavior more than to measurement.

## 19. Unknowns (open questions this document does not settle)

1. **Kalshi weather-market calibration** — no evidence either way; Experiment 1's target.
2. **Market-forecast extraction rule** — midpoint vs time-weighted vs microprice; degenerate-quote handling; must be fixed pre-analysis (11.5).
3. **Effective sample size** — magnitude of cross-city/serial correlation in outcomes and score differentials; sets power and required accrual duration.
4. **Decomposition stability at lab n** — whether component estimates are decision-grade monthly or only quarterly+; CORP's uncertainty quantification will answer this empirically.
5. **Nonstationarity** — market efficiency plausibly drifts (participant sophistication, fee changes); old-data scores may misrepresent current competition.
6. **Historical forecast archives** (NCEI/IEM) — could multiply sample size; unverified (open Milestone-1 task).
7. **Kalshi fee functional form** — required for the cost threshold in 11.3; ⚑ primary-source verification pending.

## 20. Limitations of the framework itself

- **Propriety is an expectation property**: finite samples and rank-based reward settings can reintroduce incentives to deviate (3.2).
- **Calibration is nearly free** (Foster–Vohra); it is necessary, not sufficient; resolution is where information lives (9.4).
- **Scores measure quality, not value** — except via the Kelly identity, and that under its stated scope conditions (8.1, 11.3).
- **Decomposition estimators are biased at small n** even when exact in form (7.3).
- **No cross-event-set comparability**; shared events or fixed references only (8.2).
- **Stationarity underlies all inference on differentials**; regime change (market structure, climate trend in the underlying) degrades it — and note the underlying here has a _known secular trend_, so climatology windows are themselves a modeling choice.
- **Every theorem here conditions on the outcome being well-defined and exogenous** — settlement-source subtleties (the CLI-vs-raw-obs distinction, F1) live upstream of this document and can invalidate scores no matter how properly computed.

## 21. Annotated bibliography

_(All entries ⚑ pending primary-source verification per project rules, except where marked verified. Tiered by load-bearing weight for this lab.)_

**Tier 1 — the spine (read fully, verify first):**

- **Gneiting, T. & Raftery, A.E. (2007).** "Strictly proper scoring rules, prediction, and estimation." _JASA_ 102:359–379. The modern synthesis: Savage representation on general spaces, the score catalog, kernel scores. The single most important reference behind Sections 3–5.
- **Gneiting, T., Balabdaoui, F. & Raftery, A.E. (2007).** "Probabilistic forecasts, calibration and sharpness." _JRSS-B_ 69:243–268. The paradigm (maximize sharpness s.t. calibration) and the calibration taxonomy of 6.1; PIT theory.
- **Murphy, A.H. (1973).** "A new vector partition of the probability score." _J. Appl. Meteor._ 12:595–600. The decomposition (7.1).
- **Dimitriadis, T., Gneiting, T. & Jordan, A.I. (2021).** "Stable reliability diagrams for probabilistic classifiers." _PNAS_ 118(8):e2016191118. **[verified in audit session]** CORP: the lab's registered decomposition/diagram method (7.4).
- **Savage, L.J. (1971).** "Elicitation of personal probabilities and expectations." _JASA_ 66:783–801. Propriety's convex characterization; discrete locality uniqueness (>2 outcomes) **[attribution verified in audit session]**.
- **Kelly, J.L. (1956).** "A new interpretation of information rate." _Bell Syst. Tech. J._ 35:917–926. The growth–information identity behind 11.3.
- **Diebold, F.X. & Mariano, R.S. (1995).** "Comparing predictive accuracy." _JBES_ 13:253–263. Inference on score differentials (8.4); pair with Diebold (2015) "Comparing predictive accuracy, twenty years later," _JBES_, and Harvey, Leybourne & Newbold (1997), _Int. J. Forecasting_, for the small-sample correction.

**Tier 2 — theory and diagnostics:**

- **Brier, G.W. (1950).** "Verification of forecasts expressed in terms of probability." _Mon. Wea. Rev._ 78:1–3. Origin of the quadratic score; note the original is the multicategory $[0,2]$ form (5.2).
- **Good, I.J. (1952).** "Rational decisions." _JRSS-B_ 14:107–114. The logarithmic score.
- **Bernardo, J.M. (1979).** "Expected information as expected utility." _Ann. Statist._ 7:686–690. Log score's information semantics; smooth-case locality (4.2, 4.4).
- **Schervish, M.J. (1989).** "A general method for comparing probability assessors." _Ann. Statist._ 17:1856–1879. Threshold-mixture representation (3.3).
- **Epstein, E.S. (1969).** "A scoring system for probability forecasts of ranked categories." _J. Appl. Meteor._ 8:985–987. **[verified in audit session]** RPS origin; with **Murphy (1969, 1970, 1971)** for propriety and sensitivity to distance.
- **Matheson, J.E. & Winkler, R.L. (1976).** "Scoring rules for continuous probability distributions." _Manage. Sci._ 22:1087–1096. CRPS.
- **Murphy, A.H. & Winkler, R.L. (1987).** "A general framework for forecast verification." _Mon. Wea. Rev._ 115:1330–1338. The joint-distribution frame and both factorizations (6.3).
- **Murphy, A.H. (1993).** "What is a good forecast? An essay on the nature of goodness in weather forecasting." _Wea. Forecasting_ 8:281–293. Consistency/quality/value (8.1).
- **Stephenson, D.B., Coelho, C.A.S. & Jolliffe, I.T. (2008).** "Two extra components in the Brier score decomposition." _Wea. Forecasting_ 23:752–757. **[verified in audit session]** Exactness under binning (7.2).
- **Bröcker, J. (2009).** "Reliability, sufficiency, and the decomposition of proper scores." _QJRMS_ 135:1512–1519. Decomposition generality (7.4).
- **Bröcker, J. & Smith, L.A. (2007).** "Increasing the reliability of reliability diagrams." _Wea. Forecasting_ 22:651–661. Consistency bands (6.4).
- **Ferro, C.A.T. & Fricker, T.E. (2012).** "A bias-corrected decomposition of the Brier score." _QJRMS_ 138:1954–1960. Small-bin bias (7.3).
- **Weijs, S.V., van Nooijen, R. & van de Giesen, N. (2010).** "Kullback–Leibler divergence as a forecast skill score with classic reliability–resolution–uncertainty decomposition." _Mon. Wea. Rev._ 138:3387–3399. Log-score decomposition; RES = mutual information (7.5, 10.3).
- **Dawid, A.P. (1982).** "The well-calibrated Bayesian." _JASA_ 77:605–610; and **Dawid (1984)**, "Present position and potential developments: … the prequential approach," _JRSS-A_ 147:278–292. Sections 9.2, 9.4.
- **Foster, D.P. & Vohra, R. (1998).** "Asymptotic calibration." _Biometrika_ 85:379–390; with **Oakes, D. (1985)**, "Self-calibrating priors do not exist," _JASA_. Calibration's cheapness (9.4).
- **Hamill, T.M. (2001).** "Interpretation of rank histograms for verifying ensemble forecasts." _Mon. Wea. Rev._ 129:550–560. Flatness necessary-not-sufficient (6.4).
- **Hamill, T.M. & Juras, J. (2006).** "Measuring forecast skill: is it the real skill or is it the varying climatology?" _QJRMS_ 132:2905–2923. The pooling trap (8.2).
- **Mason, S.J. (2004).** "On using 'climatology' as a reference strategy in the Brier and ranked probability skill scores." _Mon. Wea. Rev._ 132:1891–1895. In-sample reference bias (8.2).
- **Gneiting, T. & Ranjan, R. (2011).** "Comparing density forecasts using threshold- and quantile-weighted scoring rules." _JBES_ 29:411–422; with **Lerch et al. (2017)**, "Forecaster's dilemma," _Statist. Sci._ 32:106–127. Weighted rules (5.6).
- **Scheuerer, M. & Hamill, T.M. (2015).** "Variogram-based proper scoring rules." _Mon. Wea. Rev._ 143:1321–1334; with **Dawid & Sebastiani (1999)** and **Pinson & Tastu (2013)**. Multivariate (5.7).

**Tier 3 — markets, ML calibration, texts:**

- **Hanson, R. (2003, 2007).** LMSR papers (_Inf. Syst. Frontiers_; _J. Prediction Markets_). Markets as scoring rules (11.2).
- **Thaler, R. & Ziemba, W. (1988).** "Anomalies: parimutuel betting markets." _J. Econ. Perspect._ 2:161–174; **Snowberg, E. & Wolfers, J. (2010).** "Explaining the favorite–long shot bias…" _JPE_ 118:723–746. The bias and its mechanisms (11.1).
- **Wolfers, J. & Zitzewitz, E. (2004).** "Prediction markets." _J. Econ. Perspect._ 18:107–126. Economics of the asset class.
- **Platt (1999); Zadrozny & Elkan (2002); Guo, Pleiss, Sun & Weinberger (2017); Kull, Silva Filho & Flach (2017); Naeini, Cooper & Hauskrecht (2015).** The recalibration/ECE canon (12.1–12.2).
- **Winkler, R.L. (1994).** "Evaluating probabilities: asymmetric scoring rules." _Manage. Sci._ 40:1395–1405. Baseline-adjusted scores for strong-reference comparison; optional tooling adjacent to 8.2.
- **Roulston, M.S. & Smith, L.A. (2002).** "Evaluating probabilistic forecasts using information theory." _Mon. Wea. Rev._ 130:1653–1660. Ignorance score (5.1).
- **Cover, T. & Thomas, J.** _Elements of Information Theory_, 2nd ed., chs. 5–6, 16. The compression–gambling–prediction triangle (10.2, 11.3), rigorous.
- **Jolliffe, I.T. & Stephenson, D.B. (eds., 2012).** _Forecast Verification: A Practitioner's Guide in Atmospheric Science_, 2nd ed.; **Wilks, D.S.**, _Statistical Methods in the Atmospheric Sciences_. The applied verification toolbox (8.5).
- **Bernardo, J.M. & Smith, A.F.M. (1994).** _Bayesian Theory_. Wiley. Decision-theoretic foundations (9.1).
- **Tetlock, P. & Gardner, D.**, _Superforecasting_; **Silver, N.**, _The Signal and the Noise_ (weather chapter — why NWS-anchored competition is strong). Accessible context, non-load-bearing.

---

## Appendix A — Disposition of the adversarial audit (2026-07-10)

Independent evaluation of each audit finding against the literature; the audit's own citations were re-checked where verifiable this session.

**Accepted in full:** C1 (locality scope and attribution — confirmed against Yang 2020 and standard treatments; corrected in 4.2 and extended with the distance-sensitivity tradeoff); C2 (V1's truncated sentence — the intended climatology-BS = UNC identity is now stated and used, 4.1, 7.1); C3 (decomposition exactness — confirmed against Stephenson et al. 2008; CORP registered, 7.2–7.4); M1 (event-dependent costs, 11.3, with the fee form left ⚑ rather than asserted); M2 (Kelly scope conditions, 11.3); M3 (bibliography: Epstein/Murphy lineage added and verified; Murphy–Winkler 1987 added; the erroneous "Foster & Hart" pointer replaced by the intended ML-calibration canon); M4 (sharpness redefined correctly; four-way attribute contrast, 6.2); M5 (PIT + calibration taxonomy added, 6.1, 6.4); M6 (recalibration methods treated; governance law restated, 12); M7 (numerical policy and conventions given a single home, 2, 13); M8 (clustering-first inference framing; HLN; A1 dependency flagged, 8.4). Minor and nice-to-have items adopted: orientation/units table, RPS convention and propriety statement, CRPS moment condition, AUC-recalibration link, Foster–Vohra resolution framing, log-score decomposition, Bröcker 2009, spherical mention-and-dismiss, multivariate routing, Murphy 1993, Winkler 1994 (bibliography only).

**Accepted with modification:** the audit's recollection of the Kalshi fee functional form is _not_ reproduced anywhere in this document — V2 states only that costs are price-dependent and flags the schedule for primary-source verification (19.7), which is the stricter position. The audit's suggested power-analysis subsection (n7) is deferred to A1 rather than added here, to respect single-ownership of inference mechanics.

**Rejected:** none. No audit finding was contradicted by the literature consulted. One audit emphasis was _downgraded_: its Part 3 ranked PIT above the locality fix; V2 treats the locality fix as co-equal because it corrects a live false inference rather than filling a gap.

## Appendix B — Changelog from V1

Corrected: locality claim (scope + attribution); sharpness definition; decomposition exactness; "constant drag" cost claim; truncated Brier sentence; "Foster & Hart" reference. Added: conventions and units (§2), Schervish section promoted (§3.3), full score catalog including spherical/weighted/multivariate (§5), calibration taxonomy and PIT (§6), CORP and log-score decompositions (§7.4–7.5), Murphy 1993 / Mason 2004 / Hamill–Juras traps (§8), Bayesian and information-theory chapters (§9–10), Kelly scope conditions (§11.3), extraction-rule section (§11.5), ML recalibration chapter (§12), numerical policy and reconciliation suite (§13), pipeline architecture (§14), misconceptions (§15), history and frontiers (§17–18), annotated tiered bibliography (§21). Retained from V1 (verbatim in substance, rewritten in wording): the Kelly identity derivation, the improper-metrics worked example, the reference ladder, Experiment 1, the Unknowns list (extended), and the self-deception framing — V1's strongest material.

**Canonization checklist for the Architect:** (1) spot-verify Tier-1 bibliography against originals; (2) resolve ⚑ on the Kalshi fee schedule and WMO guidance references; (3) ratify the registered conventions (§2 orientation/units, §5.4 RPS, §7.4 CORP, §13.2 ε, §13.4 invariants) or amend before stamping; (4) confirm boundary assignments with [[Forecast Verification]] and A1 to prevent dual ownership; (5) grade and stamp.
