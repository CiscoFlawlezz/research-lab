---

## title: "Probability" aliases: ["Probability", "Probability Theory — Technical Reference", "Foundations of Probability"] vault_location: "07_References/Concepts" level: "Quantitative researcher reference (foundational — assumes calculus, basic set theory)" status: "AI-drafted V1 — E4 testimony, ungraded pending Architect verification per Invariant 3; NOT canonical until ratified" supersedes: "Probability.md transclusion stub (bare embed of the Proper Scoring Rules and Calibration reference)" created: 2026-07-09 review: 2027-01-09 tags: [probability, foundations, bayes, random-variables, distributions, information-theory, calibration, prediction-markets, weather-forecasting, numerical-stability]

# Probability — Research Synthesis

**Vault location:** `07_References/Concepts` **Level:** Foundational quantitative reference. Everything else in the Research Lab's technical corpus imports this document by reference. **Cross-links:** [[Bayesian Statistics]] · [[Expected Value]] · [[Kelly Criterion]] · [[Log Score and Kelly Identity]] · [[Proper Scoring Rules and Calibration - Technical Reference]] · [[Brier Decomposition - Worked Example]] · [[Forecast Verification]] · [[Prediction Markets]] · [[Edge Detection]] · [[Effective Sample Size]] · [[Machine Learning]] · [[Kalshi Ticker Anatomy and Market Structure]] · [[National Weather Service]] · [[Glossary]] · [[Open Questions]] **Status:** Version 1 — draft, ungraded pending Architect verification (Invariant 3) **Created:** 2026-07-09

> [!warning] Epistemic status (Invariant 3) This document is AI-drafted testimony, not evidence. It was produced from model knowledge without live retrieval, following the same convention as [[Forecast Verification]] V2. Every bibliographic citation **must be independently verified (title, year, venue, page-level claims) before any statement here is cited as load-bearing in a registration or ADR**. Lower-confidence citations carry ⚑ per house convention; ★ marks the priority verification tier. The mathematics in §1–§11 is textbook-stable and the lowest-risk layer; bibliographic metadata and empirical claims (§12–§13) are the most fragile. Where this note and any ratified A-series document disagree, the A-series document governs.

> [!info] Supersession note This document replaces the prior `Probability.md`, which was a bare transclusion of [[Proper Scoring Rules and Calibration - Technical Reference]]. Existing `[[Probability]]` backlinks throughout the vault now resolve here. Per the single-source rule, the stub should be deleted, not archived alongside.

> [!note] Scope discipline Reference document, not an ADR. Nothing here modifies the methodology, the city-day unit, the reference ladder, or any settled decision. The engineering directives in §19 are _proposals_ pending Architect ratification, flagged [NEW] where they are not already standing policy elsewhere.

---

## 1. Foundations of Probability

### 1.1 Randomness and uncertainty are not the same thing

The literature distinguishes **aleatory uncertainty** (irreducible variability in the world — whether tomorrow's atmosphere delivers a KPHX high of 41 °C or 42 °C) from **epistemic uncertainty** (ignorance that more information could reduce — what the settlement value _already was_ before the CLI product is read). The distinction is standard in risk analysis and uncertainty quantification (O'Hagan 2004 ⚑; Der Kiureghian and Ditlevsen 2009 ⚑) and is operationally load-bearing here: a Kalshi bracket trading _after_ the day's maximum has physically occurred but _before_ settlement publication carries almost purely epistemic uncertainty, and the correct probability model for that regime is a model of information revelation, not of weather. Probability theory, remarkably, handles both with one calculus — this is a feature of the subjectivist reading (§2) and a point of philosophical contention under the frequentist reading.

**Implementation implication.** The pipeline's dual-timestamp discipline (event time vs. record time) is precisely what lets analysis later distinguish "the market was uncertain about the weather" from "the market was uncertain about the settlement feed." Collapse those timestamps and the two regimes become indistinguishable in the data forever.

### 1.2 Sample spaces, outcomes, events

The **sample space** $\Omega$ is the set of all possible outcomes of an experiment; an **outcome** $\omega \in \Omega$ is one complete resolution; an **event** $A \subseteq \Omega$ is a set of outcomes. For a daily-high market, a natural $\Omega$ is the set of possible official maxima (in practice: integer °F over a physically plausible range, because settlement is against a rounded CLI value — see [[Kalshi Ticker Anatomy and Market Structure]]). Each bracket contract is an _event_: "max ∈ [93, 94]" is a subset of $\Omega$.

Three modeling facts follow immediately and matter constantly:

1. **The brackets of one city-day partition (approximately) one sample space.** They are events over the _same_ $\omega$, which is why their probabilities are mechanically coupled and why the honest unit of analysis is the city-day, not the contract ([[Effective Sample Size]]).
2. **The choice of $\Omega$ is a modeling act, not a discovery.** Modeling the settlement value (integer, post-rounding) versus the physical maximum (continuous) gives different spaces; the settlement space is the one the market resolves on. Mismatching them creates representativeness error ([[Forecast Verification]] §14).
3. **Events, not outcomes, are what get priced.** Markets never price $\omega$; they price subsets. All bracket arithmetic is event arithmetic.

### 1.3 Sigma-algebras, conceptually

A **σ-algebra** $\mathcal{F}$ on $\Omega$ is a collection of events closed under complement and countable union, containing $\Omega$ itself. Formally it exists to make measure theory consistent on uncountable spaces (not every subset of $\mathbb{R}$ can be assigned a length — Vitali sets); practically, for the discrete spaces this project trades on, $\mathcal{F}$ can safely be the full power set and the machinery is invisible.

The conceptual payload worth keeping is different: **a σ-algebra is an information structure.** The sub-σ-algebra generated by the observations available at time $t$ formalizes "what is knowable at $t$." Filtrations ${\mathcal{F}_t}$ — increasing families of σ-algebras — are the standard formalization of information arriving over time (Billingsley 1995; Durrett 2019), and they are the correct mental model for the pipeline's as-of joins: a forecast issued at $t$ may be conditioned only on $\mathcal{F}_t$. **Look-ahead leakage is, in this language, conditioning on a σ-algebra you were not entitled to.** The leakage tests in the Engineering Playbook are checks that the code respects the filtration.

### 1.4 Probability measures and the Kolmogorov axioms

A **probability measure** is a function $P: \mathcal{F} \to [0,1]$ satisfying Kolmogorov's axioms (Kolmogorov 1933 ★):

1. **Non-negativity:** $P(A) \ge 0$ for all $A \in \mathcal{F}$.
2. **Unit measure:** $P(\Omega) = 1$.
3. **Countable additivity:** for pairwise disjoint $A_1, A_2, \dots$, $;P!\left(\bigcup_i A_i\right) = \sum_i P(A_i)$.

Everything else — complements, inclusion–exclusion, conditional probability, Bayes — is a theorem of these three. Finite additivity suffices for finite spaces; countable additivity is what makes limit theorems (§10) work. De Finetti famously resisted countable additivity on operational grounds (de Finetti 1974 ★); the mainstream, and this Lab, adopt it.

### 1.5 Why probability is internally consistent — and why that matters commercially

Two classical results justify the axioms rather than merely asserting them:

- **The Dutch book theorem** (Ramsey 1926 ★; de Finetti 1937 ★): if an agent posts betting prices on events that violate the axioms, a bookmaker can construct a portfolio of bets against those prices that guarantees the agent a loss in every state of the world. Coherence — conformity to the axioms — is exactly immunity to sure loss.
- **Cox's theorem** (Cox 1946 ⚑; Jaynes 2003 ★): any system of plausible reasoning satisfying modest consistency desiderata is isomorphic to probability theory. (The precise technical conditions needed have been debated — Halpern 1999 ⚑ exhibits counterexamples to loose statements of the theorem — but the qualitative conclusion is standard.)

The commercial reading is direct. **A set of bracket prices for one city-day that violates additivity is a Dutch book sitting in the order book** — buy the whole partition below $1.00 net of fees, or sell it above. This is the entire logical foundation of the sum-to-one diagnostics that A4 must specify: deviation of $\sum_k P_m^{(k)}$ from 1 is either fees, spread, normalization artifact, or free money, and the pipeline's job is to say which ([[Forecast Verification]] §15.8, D-FV-7).

**Common implementation mistakes.** (i) Normalizing bracket probabilities to sum to one _before_ recording the raw prices, destroying the very deviation that carries information. Raw first, normalized as a derived column, method ID attached (already Lab policy). (ii) Treating axiom-consistency of _model_ output as automatic: a model that produces per-bracket probabilities independently (e.g., one logistic model per bracket) will not sum to one and needs an explicit, registered normalization of its own.

---

## 2. Probability as a Language of Uncertainty

Probability's mathematics is settled; its _interpretation_ is not, and the disagreement is not academic — each interpretation licenses different inferences, and this project uses several deliberately.

### 2.1 Frequentism

Probability is the limiting relative frequency of an event in infinitely repeated trials (von Mises 1928 ⚑). **Succeeds:** gives probability an operational, verifiable meaning; underwrites the entire verification apparatus — calibration _is_ a frequency claim ("of the days I said 70 %, ~70 % occurred"), checkable only in aggregate. **Fails:** single cases ("probability KPHX exceeds 110 °F _tomorrow_") have no literal infinite ensemble; the reference class must be constructed, and reference-class choice is exactly the pooling trap ([[Forecast Verification]] §14.4 — pooled base rates fabricate skill). Strict frequentism also cannot assign probabilities to fixed-but-unknown facts (a settled-but-unpublished CLI max), which this project must do daily.

### 2.2 Bayesian / subjective interpretation

Probability is a coherent agent's degree of belief, operationalized as betting rates (Ramsey 1926 ★; de Finetti 1937 ★; Savage 1954 ★). **Succeeds:** handles single cases and epistemic uncertainty natively; makes "the market's probability" a meaningful phrase — a price _is_ a betting rate, so prediction markets are subjectivism made institutional; updating has a mandatory rule (Bayes, §8). **Fails:** priors are inputs, not outputs — two coherent agents may disagree forever given the same data if their priors differ enough; "coherence" alone does not confer accuracy. The corrective is _calibration testing_: subjective probabilities earn trust only by passing frequentist audits. **The Lab's working stance is exactly this hybrid — Bayesian in production, frequentist in verification** — and it is the mainstream position in modern forecasting (Gneiting and Katzfuss 2014 ★; Dawid 1982 ★ on the "well-calibrated Bayesian").

### 2.3 Objective, logical, and propensity readings

- **Objective/chance:** probabilities are physical features of systems (quantum decay rates). Weather sits awkwardly here — the atmosphere is (classically) deterministic chaos, so "the probability of rain" is epistemic at bottom, induced by uncertain initial conditions (Lorenz 1963 ★; §12).
- **Logical:** probability as partial entailment, a unique rational credence given evidence (Keynes 1921 ⚑; Carnap 1950 ⚑; Jaynes 2003 ★ via maximum entropy). Elegant; foundered on the non-uniqueness of "uninformative" priors. Survives as MaxEnt, a useful _tool_ for constructing baselines rather than a complete foundation.
- **Propensity:** probability as a disposition of a chance setup (Popper 1959 ⚑). Handles single cases but is widely judged circular as an analysis (Humphreys 1985 ⚑ — propensities don't invert the way Bayes requires).

### 2.4 What the Lab commits to

No metaphysical commitment is required — only an operational one, and it is already implicit in the Glossary's definitions: **forecast probabilities are subjective/Bayesian objects; their validation is frequentist and population-level; no single outcome ever validates or refutes a probability.** That last clause is Invariant-adjacent: it is the foundational idea under the whole research architecture, and every interpretation dispute this project will ever have (e.g., "the market was wrong, it said 20 % and it happened") dissolves into it.

---

## 3. Core Probability Rules

All derivable from the axioms; derivations sketched because the derivations _are_ the implementation tests.

### 3.1 Complement, union, intersection

- **Complement:** $A \cup A^c = \Omega$, disjoint, so $P(A^c) = 1 - P(A)$. In market terms: NO price ≈ 1 − YES price, before fees and spread. Persistent violation is microstructure, not probability.
- **Addition rule (inclusion–exclusion):** $P(A \cup B) = P(A) + P(B) - P(A \cap B)$. Derivation: write $A \cup B$ as the disjoint union $A \cup (B \setminus A)$ and $B = (A\cap B) \cup (B \setminus A)$; apply additivity twice. For disjoint events the intersection term vanishes — bracket probabilities for one city-day _add_ because brackets are disjoint by construction.
- **General inclusion–exclusion** for $n$ events alternates signs over all intersection orders; it explodes combinatorially, which is why implementations prefer complements ("P(at least one)" = 1 − P(none)) whenever independence or exchangeability permits.

### 3.2 Conditional probability and the multiplication rule

$$P(A \mid B) = \frac{P(A \cap B)}{P(B)}, \qquad P(B) > 0.$$

This is a _definition_ under Kolmogorov (and a _primitive_ under some subjectivist axiomatizations — Rényi 1955 ⚑; the difference matters only at measure-zero edge cases). Rearranged, the **multiplication rule**: $P(A \cap B) = P(A \mid B),P(B)$, chaining to $P(A_1 \cap \cdots \cap A_n) = \prod_i P(A_i \mid A_1, \dots, A_{i-1})$ — the chain rule underlying every autoregressive model and every likelihood function the Lab will ever compute.

### 3.3 Law of total probability

For a partition ${B_k}$ of $\Omega$: $$P(A) = \sum_k P(A \mid B_k), P(B_k).$$

Derivation: $A = \bigcup_k (A \cap B_k)$ disjointly; apply additivity and the multiplication rule. This is the **mixture** identity — marginal probability is a prior-weighted average of conditionals — and it is the mathematical skeleton of ensemble forecasting (§12): a 51-member ensemble's event probability is (in the crudest reading) $\sum_k P(A \mid \text{member } k) \cdot \frac{1}{51}$.

**Implementation.** Total-probability identities are free consistency tests. Any pipeline quantity computable two ways (marginal directly, and as a mixture over a partition) should be computed both ways in tests; disagreement beyond float tolerance is a bug. This generalizes the sum-to-one check.

### 3.4 Bayes' theorem (statement; full treatment §8)

From symmetry of the multiplication rule: $$P(H \mid E) = \frac{P(E \mid H), P(H)}{P(E)}, \qquad P(E) = \sum_k P(E \mid H_k) P(H_k).$$

One line of algebra; the entire logic of learning from evidence. Deferred to §8.

---

## 4. Random Variables

### 4.1 Definition and the three species

A **random variable** is a measurable function $X: \Omega \to \mathbb{R}$ — a number attached to each outcome. "Measurable" means events like ${X \le x}$ are in $\mathcal{F}$, so they can be assigned probability; for the Lab's discrete spaces this is automatic. The randomness lives in $\omega$, not in $X$; $X$ is deterministic bookkeeping. This resolves a chronic confusion: "the daily max is random" means the _outcome_ is unresolved, not that the mapping from atmosphere to number is fuzzy.

- **Discrete:** countable support; described by a **probability mass function (PMF)** $p(x) = P(X = x)$, $\sum_x p(x) = 1$. The settlement variable (integer °F) is discrete. Bracket indicators $Y_k = \mathbf{1}{X \in B_k}$ are Bernoulli — the atomic object of the entire project.
- **Continuous:** $P(X = x) = 0$ for every point; described by a **density (PDF)** $f$ with $P(a < X \le b) = \int_a^b f(x),dx$. The _physical_ temperature maximum is naturally modeled continuously.
- **Mixed:** distributions with both point masses and continuous parts. Precipitation is the canonical meteorological example (an atom at exactly zero, a continuous tail above); censored and rounded variables are mixed or discrete images of continuous ones. **Rounding a continuous forecast distribution to the integer settlement grid is a discretization the model must own explicitly** — probability mass for bracket $[93, 94]$ under a continuous model is $F(94.5) - F(92.5)$ under NWS-style rounding conventions, and off-by-half-degree boundary errors here are a classic silent bug (this interacts with the boundary conventions documented in [[Kalshi Ticker Anatomy and Market Structure]] and must match the ticker's actual bracket-edge rules, not a guessed rounding rule ⚑ — verify per-series).

### 4.2 CDFs unify everything

The **cumulative distribution function** $F(x) = P(X \le x)$ exists for every random variable — discrete, continuous, mixed — and is right-continuous, non-decreasing, with limits 0 and 1. Discrete variables have staircase CDFs; continuous ones have absolutely continuous CDFs with $f = F'$ a.e. **The CDF is the correct universal interface for forecast distributions in code**: every distributional forecast the pipeline stores should expose $F$, because (i) bracket probabilities are CDF differences, (ii) the PIT (probability integral transform, [[Forecast Verification]] §13) is $F(y)$, (iii) quantiles are $F^{-1}$, and (iv) the CRPS is an integral of $(F(x) - \mathbf{1}{y \le x})^2$. A2's forecast-to-probability conversion is, in this language, the construction of a per-station, per-lead-time predictive CDF.

### 4.3 Why densities are not probabilities

$f(x)$ is probability _per unit length_, not probability: it can exceed 1 (a Uniform(0, 0.1) has density 10), it has units (per °F), and it changes under variable transformation by a Jacobian factor while probabilities do not. Only integrals of densities are probabilities. Three practical corollaries:

1. **Never compare densities across differently scaled variables** (°F vs. °C densities differ by a factor of 9/5) — but probabilities of corresponding events agree.
2. **Likelihoods are densities**, hence not probabilities; the log-likelihood differences the Lab computes are legitimate, raw likelihood values are unit-dependent and meaningless alone.
3. **"The most likely value" (density mode) can be nearly probability-free** for a sharp continuous variable once mapped to brackets — mode-based reasoning and bracket-probability reasoning can rank brackets differently for skewed distributions. Price brackets from integrated mass, never from the mode.

---

## 5. Expectation

### 5.1 Definition and the weighted-average reading

$$\mathbb{E}[X] = \sum_x x,p(x) \quad\text{or}\quad \int x f(x),dx,$$

defined when $\mathbb{E}[|X|] < \infty$. Expectation is the probability-weighted average — the center of mass of the distribution — and, by the LLN (§10), the long-run average of repeated realizations. The general form, $\mathbb{E}[g(X)] = \sum_x g(x) p(x)$ (the "law of the unconscious statistician"), is how every score, payoff, and fee expectation in the Lab is computed: **a proper score's expectation under the forecaster's own belief is the object proper-ness constrains** ([[Proper Scoring Rules and Calibration - Technical Reference (V2)]]), and a contract's expected P&L is $\mathbb{E}[\text{payoff}] - \text{price} - \text{fees}$ ([[Expected Value]]).

### 5.2 Linearity — the most-used theorem in the building

$$\mathbb{E}[aX + bY] = a,\mathbb{E}[X] + b,\mathbb{E}[Y] \quad \textbf{always},$$

independence not required. Consequences used daily: portfolio expected value adds across positions _even when the positions are correlated brackets of the same city-day_; the expected number of realized brackets in any set is the sum of their probabilities. **What linearity does not give:** $\mathbb{E}[g(X)] \ne g(\mathbb{E}[X])$ for nonlinear $g$ (Jensen's inequality gives the direction for convex/concave $g$). Feeding a _mean_ temperature forecast through a nonlinear bracket rule and calling the output a bracket probability is the canonical version of this error — the entire reason A2 must produce distributions, not point forecasts.

### 5.3 Variance, moments, and higher moments

$\mathrm{Var}(X) = \mathbb{E}[(X - \mathbb{E}X)^2] = \mathbb{E}[X^2] - (\mathbb{E}X)^2$; standard deviation is its root, in the variable's own units. The $k$-th central moments standardize into **skewness** (asymmetry) and **kurtosis** (tail weight). Operationally: forecast-error distributions for temperature are _not_ reliably Gaussian — skewness and heavy tails vary by station, season, and regime, which is why A2's distributional-form decision (M5.T3) is an ADR with an explicit tail policy and not a default `scipy.stats.norm` call. Variance of a Bernoulli($p$) is $p(1-p)$, maximal at $p = 1/2$ — binary outcomes are noisiest exactly where markets are most uncertain, which drives the sample-size arithmetic in [[Effective Sample Size]] and [[Forecast Verification]] §17.

### 5.4 Covariance and correlation

$\mathrm{Cov}(X, Y) = \mathbb{E}[XY] - \mathbb{E}X,\mathbb{E}Y$; correlation $\rho = \mathrm{Cov}/(\sigma_X \sigma_Y) \in [-1, 1]$ measures _linear_ association only ($\rho = 0$ does not imply independence; $Y = X^2$ with symmetric $X$ has $\rho = 0$). Variance of a sum: $\mathrm{Var}(X + Y) = \mathrm{Var}(X) + \mathrm{Var}(Y) + 2,\mathrm{Cov}(X, Y)$.

**This formula is why the honest unit is the city-day.** Bracket outcomes within a city-day are strongly negatively/positively structured (exactly one bracket of a partition realizes; adjacent-day temperatures are positively correlated; cross-city weather shares synoptic drivers). The variance of a monthly score average over 900 contract-rows is _not_ $\sigma^2/900$; the covariance terms inflate it toward the city-day-count scaling, ≤150/month. Every inferential procedure in the Lab that assumes independent rows silently drops these covariance terms and overstates evidence — the root cause behind date-clustered inference as a standing rule ([[Edge Detection]], D-FV-2 context).

---

## 6. Independence

### 6.1 Definitions, in increasing strength

- **Pairwise independence:** $P(A_i \cap A_j) = P(A_i)P(A_j)$ for every pair.
- **Mutual independence:** the product rule holds for _every finite subcollection_, not just pairs. Strictly stronger — Bernstein's classic three-event example is pairwise but not mutually independent.
- **Conditional independence:** $X \perp Y \mid Z$ iff $P(X, Y \mid Z) = P(X \mid Z)P(Y \mid Z)$. Neither implies nor is implied by marginal independence.

### 6.2 Why the distinctions matter in this project

1. **Cross-city daily outcomes are not independent** — synoptic-scale systems span the CONUS, so PHX/AUS or NYC/CHI same-day outcomes share drivers. They may be _approximately conditionally independent given the synoptic state_, which is the structure a hierarchical model would exploit ([[Machine Learning]]), but unconditional independence assumptions across cities on the same date are wrong and anti-conservative. Date-clustering is the model-free defense.
2. **Serial dependence:** consecutive days at one station are positively correlated (persistence — the very reason persistence is a ladder rung). Effective sample size per city is below calendar-day count; the ~300 city-day V1 gate already prices this in qualitatively, and formal block treatment lives in [[Effective Sample Size]].
3. **Products of marginals fabricate certainty.** Multiplying per-bracket or per-day probabilities as if mutually independent understates the probability of correlated bad events (e.g., "model loses in all five cities today" is far more likely than the product of marginals when the model shares one biased input — a single NBM bias hits everywhere at once).
4. **Independence claims are assumptions to be registered, never defaults.** Any test statistic whose null distribution presumes i.i.d. rows must be flagged at registration and defended or replaced (block bootstrap, cluster-robust variance).

---

## 7. Conditional Probability as Information

### 7.1 Conditioning is re-normalization on a smaller world

$P(\cdot \mid B)$ is a genuine probability measure on the restricted space where $B$ occurred: zero out the outcomes outside $B$, rescale by $P(B)$. All probability is conditional on _something_ — the unconditional-looking $P(A)$ conditions on background knowledge silently. Writing the conditioning explicitly is not pedantry; it is what the dual-timestamp schema does structurally: every stored probability in the Lab is implicitly $P(\cdot \mid \mathcal{F}_{t_{\text{record}}})$, and the record timestamp _is_ the conditioning statement.

### 7.2 Evidence and posterior beliefs

Conditioning is the mathematics of information update. Before evidence $E$: prior $P(H)$. After: posterior $P(H \mid E)$. The update is not optional or stylistic — any other rule is Dutch-bookable in sequential settings (Teller 1973 ⚑; Skyrms 1987 ⚑ for diachronic coherence, with genuine philosophical debate around the edges). A market's price path over a trading day is, under the efficient-market reading, a visible trajectory of posteriors as forecasts, observations, and order flow arrive (§13).

### 7.3 Graphical intuition and its limits

Conditional-independence structure is what probabilistic graphical models draw (Pearl 1988 ★; Koller and Friedman 2009 ⚑): nodes are variables, missing edges are conditional-independence claims. Two intuitions transfer even without ever fitting a graphical model. **(i) Explaining away:** two independent causes of a common observed effect become _dependent_ once the effect is observed — if a bracket's price jumped and either a new model run or a fat-finger order could explain it, confirming one lowers the probability of the other. This is the probabilistic logic of A7's divergence-triage ladder: boring explanations, once confirmed, absorb the evidence. **(ii) Conditioning on a collider fabricates correlation:** selecting city-days _because_ they showed large |Δ| induces spurious structure among the causes of Δ — a selection-bias mechanism that pre-registration and the multiplicity ledger exist to contain.

### 7.4 Conditioning pathologies worth knowing by name

- **Simpson's paradox:** an association can reverse under aggregation. Direct Lab relevance: per-city, per-season skill can each be positive while pooled skill is negative, or vice versa — the pooling trap again ([[Forecast Verification]] §14.4). Report stratified first, aggregate second.
- **Berkson's paradox:** the collider effect above, in its classical selection form.
- **Borel–Kolmogorov paradox:** conditioning on probability-zero events is representation-dependent for continuous variables. Practical rule: condition on positive-probability events (intervals, data records), which the discrete settlement space does automatically.

---

## 8. Bayes' Theorem

### 8.1 Derivation and anatomy

From $P(H \cap E) = P(H \mid E)P(E) = P(E \mid H)P(H)$:

$$\underbrace{P(H \mid E)}_{\text{posterior}} ;=; \frac{\overbrace{P(E \mid H)}^{\text{likelihood}};\overbrace{P(H)}^{\text{prior}}}{\underbrace{P(E)}_{\text{evidence}}}, \qquad P(E) = \sum_k P(E \mid H_k),P(H_k).$$

The denominator is the law of total probability over a hypothesis partition — the same mixture identity from §3.3, now read as a normalizer. Bayes is one line of algebra; its content is the _discipline_ of separating what you believed (prior), what the data would look like under each hypothesis (likelihood), and refusing to let either masquerade as the other.

### 8.2 Odds form and log-odds form — the implementation-grade versions

For hypothesis vs. complement, with odds $O(H) = P(H)/P(H^c)$:

$$O(H \mid E) = \underbrace{\frac{P(E \mid H)}{P(E \mid H^c)}}_{\text{likelihood ratio } LR} \times; O(H), \qquad \log O(H \mid E) = \log LR + \log O(H).$$

The odds form eliminates the normalizer; the log-odds form makes **evidence additive**: independent pieces of evidence contribute summed log-likelihood-ratios ("weight of evidence," Good 1950 ⚑; Turing's Banburismus is the storied wartime application ⚑). Three engineering payoffs:

1. **Sequential updating is a running sum** — numerically stable, order-independent for conditionally independent evidence, trivially resumable from a stored state.
2. **Logistic regression is Bayes in log-odds clothing**: the logit link _is_ log-odds, which is why calibrated binary models and Bayesian updates speak the same language ([[Machine Learning]]).
3. **Kalshi prices live on (0,1) but reason lives in log-odds.** Comparing $P_f = 0.97$ vs. $P_m = 0.99$ as "2 points of disagreement" and $0.51$ vs. $0.53$ as "the same 2 points" is a category error; in log-odds the first gap is ≈ 1.1 nats, the second ≈ 0.08. Δ measured in probability space compresses the tails exactly where fee structure and the favorite–longshot literature say the action is (Q1; [[Edge Detection]]). Whether Δ should be _registered_ in probability or log-odds space is an A-series decision; both should be computed.

### 8.3 A worked example in the project's own terms

Prior: NWS-derived model says bracket B realizes with $P(H) = 0.30$ (odds 3:7). Evidence: the 18Z observation shows the running max already inside B with hours of heating left; suppose the registered likelihood model says such an observation is 4× more likely if B ultimately realizes than if not ($LR = 4$). Posterior odds $= 4 \times 3/7 = 12/7$; posterior $\approx 0.632$. The market, meanwhile, has moved from $0.28 to $0.55. The _comparison of two posterior trajectories_ — the model's and the market's, timestamp-aligned — is the entire empirical object of V1's observational studies. (Numbers illustrative, not empirical claims.)

### 8.4 Where Bayes connects to forecasting practice

Ensemble post-processing (EMOS/BMA — Gneiting et al. 2005 ★; Raftery et al. 2005 ★) is applied Bayes: raw ensembles are systematically biased and underdispersive, and post-processing is a learned likelihood correction. Data assimilation — the initialization of every NWP run — is Bayes at scale (Kalman filtering and variational methods are Gaussian-linear special cases). The [[Bayesian Statistics]] note owns estimation machinery (conjugacy, MCMC, hierarchical models); this section owns only the theorem and its logic.

---

## 9. Probability Distributions — the Working Zoo

For each: where it comes from, where it appears in this project. Parameterization conventions follow the most common textbook forms; **code must pin the library's convention explicitly** (scipy's `scale` vs. rate, e.g.) — parameterization mismatch is a top-five silent bug class.

|Distribution|Genesis|Role in this project|
|---|---|---|
|**Bernoulli($p$)**|Single binary trial|The atom: one bracket, one city-day. Variance $p(1-p)$ drives all power arithmetic.|
|**Binomial($n, p$)**|Sum of $n$ i.i.d. Bernoullis|Calibration-bin counts _if_ rows were independent — which they are not across brackets/days; use as the naive baseline that clustering corrects.|
|**Geometric($p$)**|Trials to first success|Waiting-time reasoning: expected days until first occurrence of a rare bracket outcome; run-length sanity checks on streaks (§14, gambler's fallacy).|
|**Poisson($\lambda$)**|Rare-event counts; binomial limit $np \to \lambda$|Counts of threshold exceedances per season; arrival counts (trades, quote updates) as a first-order microstructure model.|
|**Uniform**|Maximal ignorance on an interval|PIT: a calibrated continuous forecast's $F(Y)$ is Uniform(0,1) — the basis of distribution-level verification ([[Forecast Verification]] §13). Randomization device.|
|**Normal($\mu, \sigma^2$)**|CLT; maximum entropy given mean & variance|Forecast-error working model (to be _tested_, not assumed — M5.T3); asymptotic null distributions of test statistics; Gaussian copulas as a dependence starting point ⚑.|
|**Beta($\alpha, \beta$)**|Distribution _on_ probabilities; Bernoulli's conjugate prior|Priors/posteriors over a bracket probability; Beta-binomial for over-dispersed calibration counts; order-statistics of uniforms (PIT band construction).|
|**Gamma($k, \theta$)**|Waiting times; sums of exponentials; positive skewed quantities|Positive-valued residual components; conjugate machinery for Poisson rates.|
|**Exponential($\lambda$)**|Memoryless waiting time|Inter-arrival baseline for quote/trade events; memorylessness is the _testable null_ against clustering (real order flow clusters — deviation is signal about microstructure).|
|**Student-$t_\nu$**|Normal with unknown variance; heavy tails|Robust alternative for forecast residuals — the concrete competitor A2 must consider against the Gaussian; small-sample inference.|
|**Logistic**|Log-odds-linear latent model|The link distribution of logistic regression/Platt scaling; structurally central to recalibration maps ([[Machine Learning]], [[Proper Scoring Rules and Calibration - Technical Reference (V2)]]).|

Two zoo-level lessons. **(i) Distributions are hypotheses.** Every named family in the pipeline is a registered, falsifiable modeling choice with a diagnostic (PIT, residual QQ) attached — "we assumed Normal" is only acceptable with "and here is the test that would have caught it failing." **(ii) Tails are where families disagree.** Families agreeing in the bulk diverge by orders of magnitude at 3–4σ; bracket markets _price the tails explicitly_ (deep OTM brackets), so family choice is not aesthetic — it is directly P&L- and log-score-relevant, and the log score's unboundedness (D-FV-4 boundary problem) makes tail misspecification catastrophic rather than merely costly.

---

## 10. Limit Theorems

### 10.1 Laws of large numbers

**Weak LLN:** sample means of i.i.d. variables with finite mean converge in probability to $\mathbb{E}[X]$. **Strong LLN** (Kolmogorov): almost-sure convergence under the same first-moment condition. This is the license behind the entire verification enterprise: _observed frequencies estimate probabilities, eventually._ Three qualifications the Lab lives by:

1. **"Eventually" is quantitative.** At $p \approx 0.3$, the standard error of a frequency estimate over $n$ _effective_ observations is $\sqrt{p(1-p)/n} \approx 0.46/\sqrt{n}$: ±5 points needs $n \approx 84$; ±2 points needs $n \approx 525$. City-days, not contracts (§5.4). This arithmetic — not optimism — set the ≥300 city-day V1 gate, and [[Forecast Verification]] §17 carries the full power analysis.
2. **The i.i.d. premise is false in raw form** — serial and cross-sectional dependence (§6) slow convergence; dependent-data LLNs (ergodic theorems) still deliver consistency but at reduced effective $n$.
3. **LLN says nothing about any single case** — the bridge from "70 % of such days" to "this day" is an interpretive act (§2), not a theorem.

### 10.2 Central limit theorem

Standardized sums of i.i.d. finite-variance variables converge in distribution to Normal (Lindeberg–Lévy; Lindeberg–Feller relaxes identical distribution under a negligibility condition; martingale and mixing CLTs cover dependence ⚑). Consequences: (i) test statistics for score differences are asymptotically Gaussian _under correct variance estimation_ — and the correct variance under clustering is the cluster-robust one, which is precisely where naive analyses fail; (ii) CLT convergence is slowest in the tails and for skewed summands — Berry–Esseen bounds ⚑ quantify this — so bootstrap methods (which [[Edge Detection]] already mandates at confirmation tier) are preferred over normal approximations for the Lab's modest effective samples.

### 10.3 Concentration of measure

Non-asymptotic guarantees: Markov, Chebyshev, and exponential-tail inequalities (Hoeffding 1963 ★; Bernstein; McDiarmid ⚑; survey in Boucheron, Lugosi, Massart 2013 ⚑). Hoeffding for bounded variables: $P(|\bar X_n - \mu| \ge t) \le 2\exp(-2nt^2)$ for $[0,1]$-valued summands — scores and probabilities qualify. Uses: finite-sample sanity bounds on calibration-bin deviations before asymptotics are trusted; the theoretical backbone of concentration-based monitoring alarms (a bin deviating beyond a Hoeffding band at small $n$ is _actually_ surprising, not just asymptotically so). The independence requirement again limits direct use — bounds apply per-cluster or via martingale versions (Azuma) — but as **order-of-magnitude reality checks against premature excitement they are the cheapest anti-p-hacking tool available**: if a claimed effect at $n = 40$ city-days sits inside the Hoeffding band of pure noise, the discussion is over before it starts.

### 10.4 Implication for calibration studies, stated once

Calibration is a property of a _population_ of forecasts (Dawid 1982 ★). The limit theorems say the population property becomes visible at a rate of $1/\sqrt{n_{\text{eff}}}$ and no faster. Every design decision downstream — accrual-first sequencing, the city-day unit, minimum-$n$ gates on reliability diagrams (D-FV-8), the refusal to grade single outcomes — is this one paragraph, applied.

---

## 11. Information Theory Connections

### 11.1 Surprisal and entropy

Define the **surprisal** of an outcome with probability $p$ as $-\log p$: rare events carry more information. Shannon **entropy** is expected surprisal, $H(P) = -\sum_x p(x) \log p(x)$ (Shannon 1948 ★) — the irreducible average uncertainty of a source, maximal at the uniform distribution, zero at a point mass. Units: nats (natural log, the Lab's convention via the log score) or bits (log₂). A five-bracket market with probabilities $(0.05, 0.25, 0.40, 0.25, 0.05)$ has entropy ≈ 1.33 nats; the sharper the market, the lower its entropy — **entropy is the natural sharpness measure for bracket distributions**, complementing the resolution term of the Brier decomposition ([[Brier Decomposition - Worked Example]]).

### 11.2 Cross-entropy, KL divergence, and the log score

For true distribution $P$ and forecast $Q$:

$$\underbrace{H(P, Q)}_{\text{cross-entropy}} = -\sum_x p(x)\log q(x) = H(P) + \underbrace{D_{\mathrm{KL}}(P ,|, Q)}_{\ge 0,; =0 \text{ iff } P = Q}.$$

The decomposition is the whole story: cross-entropy = irreducible uncertainty + divergence penalty for forecasting $Q$ when truth is $P$. Gibbs' inequality ($D_{\mathrm{KL}} \ge 0$) is proved by Jensen on $-\log$. Now the connection this section exists for: **the expected log score of forecast $Q$ is exactly the cross-entropy $H(P, Q)$**, so minimizing expected log score is minimizing KL divergence to the truth — strict propriety of the log score _is_ Gibbs' inequality wearing a scoring-rule hat ([[Log Score and Kelly Identity]]; [[Proper Scoring Rules and Calibration - Technical Reference (V2)]]). KL asymmetry ($D_{\mathrm{KL}}(P|Q) \ne D_{\mathrm{KL}}(Q|P)$) is not a defect; the forward direction penalizes assigning near-zero $q$ to events that happen — the same asymmetry that makes the log score unbounded at the boundary (D-FV-4) and makes Kelly bettors bankrupt-averse.

### 11.3 Mutual information

$I(X; Y) = D_{\mathrm{KL}}(P_{XY} | P_X P_Y)$ — the information one variable carries about another; zero iff independent; invariant to invertible marginal transforms (unlike correlation). Conceptual uses here: (i) an upper bound on what _any_ model could extract from a feature set about outcomes; (ii) the data-processing inequality ($X \to Z \to Y$ implies $I(X;Y) \le I(X;Z)$) formalizes an accepted truth — **no post-processing manufactures information absent from the inputs**; recalibration reshapes, it does not create skill. (iii) The rate at which side information improves Kelly growth is bounded by mutual information (Kelly 1956 ★; Cover and Thomas 2006 ★ ch. 6) — the deep identity making "edge" an information-theoretic quantity, developed in [[Log Score and Kelly Identity]].

---

## 12. Probability in Weather Forecasting

### 12.1 Why weather forecasts are probabilistic at all

The atmosphere is deterministic chaos: infinitesimal initial-condition errors grow exponentially (Lorenz 1963 ★), so beyond a few days the _only_ honest forecast is a distribution. Uncertainty is epistemic in origin (initial conditions, model error) but operationally irreducible. This resolved a decades-long debate — probability entered operational forecasting through PoP in 1965 ⚑ and ensembles in 1992 (ECMWF/NCEP ⚑) — and produced the longest calibrated probability record in any applied field: decades of U.S. PoP forecasts verifying as reliable (Murphy and Winkler 1977 ★; [[Forecast Verification]] §14.2). **The existence proof matters strategically: institutional weather probabilities are _good_.** The Lab's thesis is not "NWS is wrong"; it is that a market's translation of good forecasts into bracket prices may leak — a much narrower, more falsifiable claim.

### 12.2 Ensembles and uncertainty quantification

An ensemble runs the model $K$ times from perturbed initial conditions (and/or perturbed physics); the member spread estimates flow-dependent uncertainty. Raw ensembles are systematically **underdispersive** (member spread understates true uncertainty) and biased — hence statistical post-processing (EMOS: Gneiting et al. 2005 ★; BMA: Raftery et al. 2005 ★) to convert members into calibrated predictive CDFs. Lab relevance is direct: A2 is a post-processing problem — NWS/NBM point or gridded guidance in, per-station predictive CDF out, residual-trained. V1 uses forecast-vs-settlement residuals (the M5 audits establish depth); ensemble inputs are a V2 rung.

### 12.3 Confidence calibration as an institutional practice

"Calibration" in forecasting = reliability: among all forecasts of $p$, the event occurs with frequency $p$. Institutional practice treats it as the _first_ virtue and sharpness as the objective _subject to_ it — "maximize sharpness subject to calibration" (Gneiting, Balabdaoui, Raftery 2007 ★). The Lab inherits this ordering wholesale; an uncalibrated sharp model is not an edge candidate, it is a liability with good marketing.

---

## 13. Probability in Prediction Markets

### 13.1 Prices as probabilities — the claim and its fine print

A binary contract paying $1 on YES trading at price $\pi$ _invites_ the reading $\pi = P(\text{YES})$. The theoretical support: under risk-neutrality and frictionless trading, price equals the marginal trader's expectation of the payoff, i.e., the event probability (Wolfers and Zitzewitz 2004 ★). The fine print, each item a standing Lab concern:

- **Manski bounds:** with heterogeneous beliefs and budget constraints, price identifies only a _set_ of belief distributions, not the mean belief (Manski 2006 ★); Wolfers–Zitzewitz 2006 ★ give conditions under which price ≈ mean belief. Price is an aggregate statistic of beliefs, not anyone's belief.
- **Fees and discreteness:** Kalshi's fee schedule and 1-cent tick shift the actionable probability away from the quoted price; the _executable_ probability differs from mid ([[Kalshi Ticker Anatomy and Market Structure]]; A4's domain).
- **Spread and staleness:** in thin brackets the last trade is history, not belief; the mid of a wide market is a weak point estimate with wide implicit error bars — record the spread as first-class data, always (standing policy).
- **Risk preferences and hedging:** prices can embed risk premia; for small-stakes weather brackets this is plausibly minor ⚑ but is an assumption, not a fact.
- **Favorite–longshot bias:** the best-documented systematic deviation between betting prices and frequencies (Ali 1977 ★; Thaler and Ziemba 1988 ★; Snowberg and Wolfers 2010 ★) — longshots overpriced, favorites underpriced, across many market types. Whether Kalshi weather brackets exhibit FLB is registered Open Question Q1 and must be answered under ≥2 normalization methods (D-FV-7).

### 13.2 Sum-to-one, redundancy, and internal coherence

A full bracket partition should price to $1.00; deviations decompose into fees, spread, and genuine incoherence (§1.5). Because brackets are events on one sample space, _cross-bracket_ coherence checks (monotonicity of cumulative prices, no negative implied bracket mass) are free arbitrage-logic diagnostics that require no weather model at all — pure probability axioms as a scanner. These checks are V1-legitimate observational studies: they test the _market's_ internal consistency, not the Lab's forecasting skill.

### 13.3 Market efficiency, aggregation, and what "beating the market" requires

Prices aggregate dispersed information (Hayek 1945 ★); the efficient-market reading says public information is already impounded. The Lab's falsifiable version: **the market-price rung of the reference ladder is the rung to beat, with date-clustered inference, after fees, at executable prices** ([[Edge Detection]] — the Glossary's definition of edge). Calibration of market prices themselves (do 30-cent brackets realize 30 % of the time?) is a population-level empirical question the V1 corpus is being accrued to answer — and note the reflexivity: a well-calibrated market can _still_ be beaten on sharpness, and a miscalibrated one can still be unbeatable after costs. Calibration and exploitability are different properties; conflating them is a category error this document exists to prevent.

---

## 14. Common Misconceptions — the Failure Canon

Each entry: the error, why it is tempting, the corrective, and where it bites this project.

**14.1 Probability vs. odds.** $p = 0.75$ is odds 3:1, not "75-to-25 ≈ 3." Harmless until fees or Kelly fractions are computed on the wrong scale — Kelly is an odds-space formula; feeding it probabilities where it expects net odds mis-sizes every position ([[Kelly Criterion]]). Corrective: one conversion utility, unit-tested, used everywhere; no inline ad-hoc conversions.

**14.2 Probability vs. confidence.** "90 % confident" in colloquial and even statistical usage (confidence intervals!) is not a posterior probability. A frequentist 90 % CI is a statement about the _procedure's_ long-run coverage, not a 90 % probability that this interval contains the truth. The Lab's registered claims must state which object they are; the Methodology's numeric-confidence convention should be read as subjective probability and audited by calibration, closing the loop honestly.

**14.3 Probability vs. frequency.** Frequency is data; probability is model. They converge under the LLN's conditions, at $1/\sqrt{n_{\text{eff}}}$, and a 12-sample frequency of 0.42 is not "the probability is 0.42." The corrective is already constitutional: population-level validation only, with $n_{\text{eff}}$ arithmetic attached.

**14.4 Expected-value misconceptions.** (i) EV is not the typical outcome — a +EV longshot loses most days; over- and under-weighting this is the source of both gambler's ruin and premature strategy abandonment. Decision-relevant is the _distribution_ of terminal outcomes under repeated play, which is exactly Kelly's domain. (ii) $\mathbb{E}[g(X)] \ne g(\mathbb{E}[X])$ (§5.2). (iii) EV computed at unexecutable prices is fiction — mid-price EV vs. executable EV is a standing distinction ([[Expected Value]], [[Edge Detection]]).

**14.5 Base-rate neglect.** Ignoring the prior when evidence arrives (Kahneman and Tversky 1973 ★; Bar-Hillel 1980 ⚑). The Lab's structural defense: climatology is the _first_ rung of the reference ladder — every model and market probability is compared against the base rate before anything else, and a "signal" that merely rediscovers climatology is caught by the ablation invariant (D-FV-10 context).

**14.6 Conjunction fallacy.** Judging $P(A \cap B) > P(A)$ (Tversky and Kahneman 1983 ★). Machine-checkable in the pipeline: no compound event may be assigned probability exceeding any of its components; this belongs in model-output validation alongside sum-to-one.

**14.7 Gambler's fallacy and its inverse.** Independent (or near-independent) sequences do not self-correct; five hot days do not make a cold one "due" — _but_ weather is positively autocorrelated, so the naive fallacy and the naive hot-hand correction are both wrong here, in opposite directions. The corrective is empirical: measured serial correlation per station/season, not intuition in either direction.

**14.8 The single-outcome verdict** (the Lab's cardinal sin, named last for emphasis). "The market said 20 % and it happened, so the market was wrong." No. A 20 % forecast is _refuted by 20-percent-events happening far more or less than 20 % of the time in aggregate_, never by one resolution. This is §2.4, §10.4, and Invariant-level doctrine in one sentence; the forecaster's dilemma ([[Forecast Verification]] §14.7 — conditioning evaluation on extreme outcomes rewards overforecasting) is its evaluation-side twin.

---

## 15. Computational Considerations

### 15.1 Floating point is not the real line

IEEE-754 doubles have ~15–16 significant decimal digits, relative epsilon $\approx 2.2 \times 10^{-16}$. Consequences for probability code: (i) $0.1 + 0.2 \ne 0.3$ — never test probabilities with `==`; use tolerances chosen consciously; (ii) **catastrophic cancellation** when subtracting near-equal numbers — computing $1 - p$ for $p \approx 1$ loses precision exactly where the log score explodes; libraries provide `log1p(x)` for $\log(1+x)$ and `expm1` for a reason, and complementary-probability code paths should work with the _smaller_ of $(p, 1-p)$; (iii) summation order matters — `math.fsum` or Kahan summation for long score accumulations, not naive `+=` loops (Goldberg 1991 ★; Higham 2002 ⚑).

### 15.2 Underflow and log-space arithmetic

Products of many probabilities underflow to 0.0 fast ($0.1^{330}$ is below the smallest positive double). The standard, non-negotiable fix: **store and combine log-probabilities**; products become sums; normalize with the **log-sum-exp** trick, $\log \sum_i e^{a_i} = m + \log \sum_i e^{a_i - m}$ with $m = \max_i a_i$, which is exact in exchange for one subtraction and immune to overflow/underflow. Every likelihood, every joint probability, every posterior in the pipeline lives in log space until the final human-readable conversion. (This dovetails with §8.2's log-odds updating — the numerics and the epistemics prefer the same coordinates.)

### 15.3 Decimal vs. float — a boundary rule

Two different value domains flow through this system and must not share a type: **money** (prices in cents, fees, P&L) and **probability/score mathematics**. Money is exact decimal arithmetic — Python `Decimal` or integer cents — because $0.01 must mean $0.01 and fee formulas must round the way Kalshi's documentation rounds ⚑ (verify the official rounding rule; do not infer it). Transcendental math (`log`, `exp`) is float-domain — `Decimal` neither supports it well nor benefits. The boundary is architectural: **prices enter as exact decimals, are converted to float once at the analysis boundary with the conversion function unit-tested, and results never round-trip back into money types implicitly.** Storage: integers (cents) or TEXT in SQLite for money columns; SQLite REAL is IEEE-754 double and fine for probabilities.

### 15.4 Normalization, clipping, and honest zeros

Renormalizing a probability vector (`v / v.sum()`) silently launders upstream bugs — a vector summing to 0.83 _deserved an exception_, not a rescue. Policy: assert closeness to 1 within a registered tolerance, log the raw deviation as data (it is an A4-relevant measurement when the vector is market-derived), then normalize with the method ID attached. Clipping probabilities away from {0, 1} before taking logs is a _modeling decision with score consequences_ (the ε-floor of D-FV-4), not a numerics detail — the ε must be registered, and ε-grid sensitivity reported. A model that emits exact 0.0 for a possible event is broken upstream; clipping hides the breakage.

### 15.5 Implementation recommendations (summary)

1. Log-space for all probability products and likelihoods; log-sum-exp for normalization.
2. `log1p`/`expm1` near the boundaries; work with $\min(p, 1-p)$ in complementary code.
3. Money in `Decimal`/integer cents; probabilities in float; one tested conversion boundary.
4. No `==` on floats; registered tolerances; `math.fsum` for long accumulations.
5. Sum-to-one is an assertion plus a logged measurement, never a silent rescue.
6. Seed and version every stochastic computation (bootstrap draws are experiments; Invariant 2 provenance applies).
7. Property-based tests (Hypothesis) for probability invariants: outputs in [0,1], monotone CDFs, complement identities, total-probability identities (§3.3).

---

## 16. How This Document Supports the Rest of the Corpus

This is the root of the dependency tree; each downstream note imports specific sections rather than "probability in general."

- **[[Bayesian Statistics]]** — owns estimation (priors, conjugacy, hierarchical models, computation); imports §7–§8 (conditioning, Bayes, odds form) and §2's interpretation stance.
- **[[Expected Value]]** — imports §5 wholesale (definition, linearity, Jensen), §14.4's misconception canon, §15.3's money/float boundary.
- **[[Kelly Criterion]]** — imports §5 (expectation of log wealth), §8.2 (odds space), §11 (growth = information rate), §14.4 (distribution-of-outcomes thinking).
- **[[Proper Scoring Rules and Calibration - Technical Reference (V2)]]** — imports §5.1 (expected score as the constrained object), §11.2 (log score = cross-entropy; propriety = Gibbs), §10.4 (population-level validation).
- **[[Log Score and Kelly Identity]]** — is the developed form of §11.2–§11.3's Kelly–information identity.
- **[[Forecast Verification]]** — imports §10 (limit theorems behind every convergence claim), §4.2 (CDF/PIT machinery), §6 (dependence structure driving clustered inference), §2.4 (validation stance).
- **[[Prediction Markets]]** — is the institutional expansion of §13; §1.5's Dutch-book logic grounds its arbitrage sections.
- **[[Edge Detection]]** — imports §5.4 (covariance → city-day unit), §8.2 (Δ in probability vs. log-odds space), §10.3 (concentration bounds as anti-excitement tools), §13.3 (what beating the market means).
- **[[Machine Learning]]** — imports §6.1 (conditional independence), §7.3 (graphical intuition), §9 (the zoo as model components), §11 (cross-entropy as the loss).
- **[[Effective Sample Size]]** — is the quantitative development of §5.4 + §6.2 + §10.1's dependence-discounted counting.

---

## 17. Historical Development

Compressed to the arc that explains _why the field has its current shape_; dates are conventional and verification-tier ⚑ as a block.

Probability began as correspondence about gambling (Pascal–Fermat, 1654) and was first systematized around expectation (Huygens 1657). **Jakob Bernoulli** (_Ars Conjectandi_, 1713) proved the first LLN and framed probability as applicable to civil and moral matters — the first claim that the calculus covers epistemic uncertainty. **Bayes** (1763, published posthumously by Price) and, far more systematically, **Laplace** (1774–1812) built inverse probability — inference from effects to causes — and Laplace's _Théorie analytique_ made probability a working scientific instrument (CLT included). The 19th century applied it (Gauss, least squares, error theory); the early 20th century split it: **Fisher** built a frequentist inference machinery (likelihood, sufficiency, experimental design) while rejecting inverse probability's priors; **Kolmogorov** (1933) axiomatized the mathematics measure-theoretically, deliberately silent on interpretation — the axioms' interpretive neutrality is why §2's dispute could continue _inside_ a shared formalism. The subjectivist counter-reformation — **Ramsey** (1926), **de Finetti** (1937: exchangeability, Dutch books, "probability does not exist" — meaning: objectively), **Savage** (1954: subjective expected utility) — rebuilt Bayesianism on operational foundations, and **Jaynes** (2003, posthumous) pushed the logical reading via maximum entropy. In parallel **Shannon** (1948) discovered that probability's $-\log p$ structure _is_ the mathematics of communication, creating information theory and — via **Kelly** (1956) — its identity with growth-optimal gambling. The modern synthesis relevant to this Lab (calibration as empirical discipline: Dawid 1982; proper scoring as elicitation: Savage 1971, Gneiting and Raftery 2007; probabilistic forecasting as the norm: Gneiting and Katzfuss 2014) is the field's return, with measure-theoretic rigor, to Bernoulli's original ambition: graded belief about the actual world, held accountable by frequencies.

---

## 18. Open Research Questions (field-level, Lab-relevant)

1. **Uncertainty quantification for ML/AI systems** — calibration of deep models is unsolved in distribution shift; conformal prediction (Vovk et al. 2005 ⚑; Angelopoulos and Bates 2023 ⚑) offers distribution-free coverage guarantees and is a live candidate for V2+ model wrappers.
2. **Probabilistic programming** — languages (Stan, PyMC, NumPyro) that separate model specification from inference; maturity is high for the hierarchical models a five-city structure invites, but diagnostics for inference failure remain an active area.
3. **Aggregation and market microstructure** — when and how prices identify belief distributions (post-Manski), optimal automated market making (LMSR descendants), and manipulation resistance remain open; directly relevant to interpreting thin-bracket quotes.
4. **Verification under dependence and small effective samples** — e-values and anytime-valid inference (Ramdas et al. 2023 ⚑; Grünwald et al. ⚑) allow optional stopping without α-spending, a genuinely attractive fit for a lab that accrues data continuously and peeks weekly; adoption would be ADR-gated (extends D-FV-11's online-FDR discussion).
5. **Forecast evaluation beyond univariate scores** — multivariate calibration, weighted scores for tails, and score decompositions (CORP: Dimitriadis et al. 2021 ★) are consolidating now; the Lab's verification spec should track this literature at review dates.

---

## 19. Engineering Takeaways — Directives

House format: numbered directives, each with ground and home. All are **[NEW] proposals** pending ratification except where they restate standing policy.

**D-PR-1 (population-level validation).** No probability is graded by a single outcome; every skill or calibration claim carries its $n_{\text{eff}}$ in city-days. _Ground:_ §2.4, §10.4, §14.8. _Home:_ restates standing doctrine (Methodology; [[Effective Sample Size]]).

**D-PR-2 (coherence as free diagnostics).** Sum-to-one, complement, monotone-cumulative, and conjunction checks run on every stored probability vector — market-derived and model-derived alike; deviations are logged as measurements, never silently normalized. _Ground:_ §1.5, §3.3, §13.2, §15.4. _Home:_ A4 (market side); model-output validation spec (model side). [NEW in scope: applying to model outputs symmetrically.]

**D-PR-3 (log-space arithmetic).** Likelihoods, probability products, and posteriors are computed and stored in log space; normalization via log-sum-exp; `log1p`/`expm1` at boundaries. _Ground:_ §15.1–§15.2. _Home:_ Engineering Playbook numerics section. [NEW]

**D-PR-4 (money/probability type boundary).** Exact decimal (or integer-cent) types for money; float for probability math; a single unit-tested conversion boundary; Kalshi's official fee-rounding rule verified from primary documentation before first P&L computation. _Ground:_ §15.3. _Home:_ storage schema + Engineering Playbook. [NEW]

**D-PR-5 (distributions are registered hypotheses).** Every named distributional family in production carries a registered diagnostic that would detect its failure (PIT, residual tests); tail policy stated ex ante per M5.T3. _Ground:_ §9, §12.2. _Home:_ A2's ADR; restates M5.T3's intent.

**D-PR-6 (dual-space disagreement).** Δ is computed and stored in both probability and log-odds space; which is the registered primary is an A-series decision, made before confirmatory analysis. _Ground:_ §8.2. _Home:_ A1/A4 interface. [NEW]

**D-PR-7 (concentration sanity gate).** Before any divergence advances past A7's triage, its magnitude is checked against a finite-sample concentration band at current $n_{\text{eff}}$; inside the band, the finding is noise by declaration. _Ground:_ §10.3. _Home:_ A7 appendix. [NEW]

**D-PR-8 (filtration discipline).** Every stored probability's conditioning information is its record timestamp; leakage tests verify that no computation reads data with record-time later than the forecast's issuance. _Ground:_ §1.3, §7.1. _Home:_ restates Engineering Playbook leakage contracts (D-FV-10 kin).

---

## 20. Further Reading — Annotated Bibliography

★ = priority verification tier (feeds A-series decisions or is load-bearing above). ⚑ = lower-confidence citation metadata; verify before citing. **All entries are unverified model-knowledge citations per the epistemic-status block.**

### 20.1 Foundational texts

1. ★ Kolmogorov, A. N. (1933). _Grundbegriffe der Wahrscheinlichkeitsrechnung_ (English: _Foundations of the Theory of Probability_, Chelsea 1950). The axioms.
2. Feller, W. (1968). _An Introduction to Probability Theory and Its Applications_, Vol. 1, 3rd ed. Wiley. The classic discrete-first treatment; unmatched for combinatorial intuition.
3. Billingsley, P. (1995). _Probability and Measure_, 3rd ed. Wiley. The standard measure-theoretic reference.
4. Durrett, R. (2019). _Probability: Theory and Examples_, 5th ed. Cambridge UP. The modern graduate standard; free online edition exists ⚑.
5. Grimmett, G., and D. Stirzaker (2001). _Probability and Random Processes_, 3rd ed. Oxford UP. Breadth with processes; strong problem sets.
6. Blitzstein, J., and J. Hwang (2019). _Introduction to Probability_, 2nd ed. CRC. The best-taught modern intro; the right on-ramp for any future collaborator.

### 20.2 Interpretation and foundations

7. ★ Ramsey, F. P. (1926). "Truth and probability." In _The Foundations of Mathematics_ (1931). Betting-rate subjectivism; the first Dutch-book argument.
8. ★ de Finetti, B. (1937). "La prévision: ses lois logiques, ses sources subjectives." _Annales de l'Institut Henri Poincaré_ 7. Exchangeability; coherence. (English translation in Kyburg and Smokler 1964 ⚑.)
9. ★ Savage, L. J. (1954). _The Foundations of Statistics_. Wiley. Subjective expected utility axiomatized.
10. ★ Jaynes, E. T. (2003). _Probability Theory: The Logic of Science_. Cambridge UP. The logical/MaxEnt reading, opinionated and generative.
11. Cox, R. T. (1946). "Probability, frequency and reasonable expectation." _American Journal of Physics_ 14 ⚑. Cox's theorem.
12. Hájek, A. "Interpretations of probability." _Stanford Encyclopedia of Philosophy_ ⚑ (living document — snapshot before citing). The best single survey of §2's terrain.
13. Hacking, I. (1975). _The Emergence of Probability_. Cambridge UP. The history behind §17.

### 20.3 Bayesian statistics

14. ★ Gelman, A., et al. (2013). _Bayesian Data Analysis_, 3rd ed. CRC. The applied reference; hierarchical models the Lab will eventually want.
15. McElreath, R. (2020). _Statistical Rethinking_, 2nd ed. CRC. The best pedagogical bridge from probability to applied Bayes.
16. Bernardo, J. M., and A. F. M. Smith (1994). _Bayesian Theory_. Wiley. The rigorous foundation.

### 20.4 Information theory

17. ★ Shannon, C. E. (1948). "A mathematical theory of communication." _Bell System Technical Journal_ 27. The founding paper.
18. ★ Cover, T. M., and J. A. Thomas (2006). _Elements of Information Theory_, 2nd ed. Wiley. Ch. 2 (entropy/KL) and Ch. 6 (gambling) are this document's §11 in full.
19. MacKay, D. J. C. (2003). _Information Theory, Inference, and Learning Algorithms_. Cambridge UP. Free online; the inference–information bridge.

### 20.5 Forecasting and verification (probability-facing selections; full treatment in [[Forecast Verification]])

20. ★ Gneiting, T., F. Balabdaoui, and A. E. Raftery (2007). "Probabilistic forecasts, calibration and sharpness." _JRSS-B_ 69. The modern paradigm statement.
21. ★ Gneiting, T., and A. E. Raftery (2007). "Strictly proper scoring rules, prediction, and estimation." _JASA_ 102. The scoring-rule canon.
22. ★ Dawid, A. P. (1982). "The well-calibrated Bayesian." _JASA_ 77. Calibration as the frequentist audit of subjective probability.
23. ★ Murphy, A. H., and R. L. Winkler (1977). "Reliability of subjective probability forecasts of precipitation and temperature." _JRSS-C_ 26. The PoP calibration record.
24. ★ Gneiting, T., and M. Katzfuss (2014). "Probabilistic forecasting." _Annual Review of Statistics and Its Application_ 1. The survey.
25. ★ Gneiting, T., A. E. Raftery, A. H. Westveld, and T. Goldman (2005). "Calibrated probabilistic forecasting using ensemble model output statistics..." _Monthly Weather Review_ 133. EMOS.
26. ★ Raftery, A. E., T. Gneiting, F. Balabdaoui, and M. Polakowski (2005). "Using Bayesian model averaging to calibrate forecast ensembles." _Monthly Weather Review_ 133. BMA.
27. ★ Lorenz, E. N. (1963). "Deterministic nonperiodic flow." _Journal of the Atmospheric Sciences_ 20. Why forecasts are distributions.

### 20.6 Prediction markets

28. ★ Wolfers, J., and E. Zitzewitz (2004). "Prediction markets." _Journal of Economic Perspectives_ 18. The survey.
29. ★ Wolfers, J., and E. Zitzewitz (2006). "Interpreting prediction market prices as probabilities." NBER WP 12200. Price ≈ mean belief conditions.
30. ★ Manski, C. F. (2006). "Interpreting the predictions of prediction markets." _Economics Letters_ 91. The bounds critique.
31. ★ Snowberg, E., and J. Wolfers (2010). "Explaining the favorite–long shot bias: is it risk-love or misperceptions?" _Journal of Political Economy_ 118. FLB mechanisms — feeds Q1.
32. ★ Hayek, F. A. (1945). "The use of knowledge in society." _American Economic Review_ 35. Prices as aggregators.

### 20.7 Decision theory, gambling, growth

33. ★ Kelly, J. L., Jr. (1956). "A new interpretation of information rate." _Bell System Technical Journal_ 35. Growth = information.
34. Savage, L. J. (1971). "Elicitation of personal probabilities and expectations." _JASA_ 66. Scoring rules as elicitation.
35. Kahneman, D., and A. Tversky (1973). "On the psychology of prediction." _Psychological Review_ 80 ★. Base-rate neglect.
36. Tversky, A., and D. Kahneman (1983). "Extensional versus intuitive reasoning: the conjunction fallacy..." _Psychological Review_ 90 ★.

### 20.8 Computational probability and numerics

37. ★ Goldberg, D. (1991). "What every computer scientist should know about floating-point arithmetic." _ACM Computing Surveys_ 23. The canonical numerics paper.
38. Higham, N. J. (2002). _Accuracy and Stability of Numerical Algorithms_, 2nd ed. SIAM ⚑. The reference behind §15.1's summation advice.
39. Boucheron, S., G. Lugosi, and P. Massart (2013). _Concentration Inequalities_. Oxford UP ⚑. §10.3 in full.
40. Hoeffding, W. (1963). "Probability inequalities for sums of bounded random variables." _JASA_ 58 ★. The workhorse bound.

**Most authoritative, if only five are verified first:** #1 (Kolmogorov), #18 (Cover–Thomas), #20 (Gneiting–Balabdaoui–Raftery), #28 (Wolfers–Zitzewitz 2004), #37 (Goldberg).

---

## Maintenance

**Update triggers.** (i) Verification of any ★/⚑ entry — replace flag with E-grade and date. (ii) Ratification of A2 — reconcile §9's distributional guidance and D-PR-5 with A2's registered choices; A2 governs. (iii) Ratification of A4 — reconcile §13.1–§13.2 and D-PR-2's market-side scope; A4 governs. (iv) Any anytime-valid-inference ADR (§18 item 4) — update §10 and D-PR-7. (v) First production implementation of D-PR-3/D-PR-4 — add file-path cross-references. (vi) Semiannual review (frontmatter date) — check §18 against the field.

**Deprecation rules.** Where this note and any ratified A-series document or ADR disagree, the ratified document governs; this note is foundational context, never a registration source. The prior `Probability.md` transclusion stub is superseded in full and should be deleted, not archived alongside (single-source rule). §19's directives are proposals pending Architect ratification except where marked as restating standing policy.

**Verification queue.** ★ tier first (n = 26), prioritizing the five named above; then entries feeding registered Open Questions (Q1: #31, #30, #29); then ⚑ entries lazily on first use. The mathematics of §1, §3–§11 may be verified against any one graduate text (#3 or #4) in a single pass rather than per-claim.