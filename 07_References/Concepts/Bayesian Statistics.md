---
type: reference
status: seed
created: 2026-07-07
---
# Bayesian Statistics — Technical Reference

**Vault location:** `07_References/Probability & Statistics` **Level:** Quantitative researcher reference (assumes probability theory, calculus, linear algebra, basic information theory) **Cross-links:** [[Probability]] · [[Expected Value]] · [[Proper Scoring Rules and Calibration - Technical Reference (V2)]] · [[Forecast Verification]] · [[Kelly Criterion]] · [[Prediction Markets]] · [[Edge Detection]] · [[Machine Learning]] · [[Effective Sample Size]] · [[Log Score and Kelly Identity — Technical Reference (V2)]] **Status:** Reference — draft testimony, ungraded **Evidence grade:** E4 (unverified AI testimony per Invariant 3). Framework-level content is standard textbook material; specific attributions, dates, and numerical claims retain E4 flags until Architect verification against primary sources. **Created:** 2026-07-09 **Note on math rendering:** formulas use LaTeX; Obsidian renders `$...$` natively.

---

## Overview

Bayesian statistics is the branch of statistical inference in which probability quantifies **degree of belief** and all inference proceeds by a single mechanism: conditioning beliefs on observed data via Bayes' theorem. Where frequentist inference asks "how would this procedure behave over hypothetical repetitions of the experiment," Bayesian inference asks "given what I believed before and what I have now observed, what should I believe?" The output of a Bayesian analysis is not a point estimate with an error bar but a full **posterior distribution** over the unknowns — a complete probabilistic representation of remaining uncertainty, ready to be pushed through a loss function to make decisions.

For this laboratory, Bayesian statistics is not one methodology among several. It is the native language of the entire enterprise:

- Kalshi bracket prices are (approximately) **aggregated posterior beliefs** of market participants.
- NWS probabilistic forecasts are (approximately) **posterior predictive distributions** from physical models plus statistical post-processing.
- [[Edge Detection]] is a comparison between two belief distributions and reality, adjudicated by proper scoring rules.
- The [[Kelly Criterion]] is Bayesian decision theory with log utility.
- Calibration studies in [[Forecast Verification]] are empirical audits of whether stated posteriors behave like probabilities.

Every load-bearing quantity in the V1–V3 roadmap is a probability, and Bayesian statistics is the theory of what probabilities _are_, how they should be _updated_, and how they should be _used_. This document is the canonical reference for that theory.

---

## 1. Historical Development

**Thomas Bayes (1701–1761).** The theorem's namesake proved a special case — inference on a binomial proportion with a uniform prior — in _An Essay towards Solving a Problem in the Doctrine of Chances_, published posthumously (1763) by Richard Price. Bayes' actual contribution was narrow: given $n$ trials and $k$ successes, what is the probability the underlying chance lies in an interval? His construction (a ball rolled on a table) is recognizably the Beta-Binomial model of §8. Price's framing — using the result to argue about induction and causes — is arguably the first statement of Bayesian _epistemology_.

**Pierre-Simon Laplace (1749–1827).** Laplace independently discovered and vastly generalized the theorem, stating "inverse probability" in its modern form and applying it at industrial scale: celestial mechanics, demographic ratios (the famous analysis of birth-sex ratios in Paris), jurisprudence, and error theory. His _rule of succession_ — after $k$ successes in $n$ trials, estimate the next-trial probability as $(k+1)/(n+2)$ — is the uniform-prior posterior mean and remains a useful shrinkage estimator. For roughly a century, "probability" essentially _meant_ Laplacean inverse probability.

**The frequentist interregnum (c. 1900–1950).** Fisher, Neyman, and Pearson displaced inverse probability, largely because of discomfort with priors: Fisher regarded the uniform prior as arbitrary (it is not invariant under reparameterization — a uniform prior on $\theta$ is not uniform on $\theta^2$), and the new machinery of significance tests, confidence intervals, and maximum likelihood required no prior at all. This objection — _where does the prior come from?_ — remains the central criticism of Bayesian methods and is treated seriously in §5.

**Harold Jeffreys (1891–1989).** A geophysicist, Jeffreys rebuilt Bayesian inference as a formal system in _Theory of Probability_ (1939), introducing invariant ("Jeffreys") priors that answer Fisher's reparameterization objection, and developing Bayes factors for hypothesis comparison. Jeffreys represents the **objective Bayesian** school: probability as rational degree of belief constrained by symmetry and invariance principles, not personal opinion.

**Bruno de Finetti (1906–1985).** De Finetti supplied the opposite foundation: probability is _purely_ subjective — "probability does not exist" as an objective quantity — but subjective beliefs are constrained by **coherence**. His representation theorem (1931) shows that exchangeable sequences behave _as if_ generated by an unknown parameter with a prior over it, giving subjectivists a rigorous reason to use parametric models and priors without believing in "true parameters." His operational definition of probability as fair betting odds makes de Finetti the single most directly relevant foundational figure for prediction market research: a market price _is_ a de Finetti probability elicited at scale.

**Leonard Savage (1917–1971).** _The Foundations of Statistics_ (1954) derived both subjective probability and expected-utility maximization jointly from axioms of rational preference, completing the decision-theoretic foundation (§10). Savage's axioms imply that a rational agent acts as if maximizing expected utility under a personal probability measure — the theoretical charter for any autonomous trading agent.

**Dennis Lindley (1923–2013).** Lindley systematized and evangelized the Savage program, proved influential results (Lindley's paradox on Bayesian–frequentist testing divergence; the Cromwell's rule injunction against dogmatic 0/1 priors), and predicted the 21st-century Bayesian resurgence. Cromwell's rule matters operationally: a model that assigns exactly zero probability to any achievable temperature bracket can never update toward it and suffers unbounded log-score loss — see [[Proper Scoring Rules and Calibration - Technical Reference (V2)]].

**Edwin Jaynes (1922–1998).** A physicist, Jaynes unified Bayesian inference with information theory: probability theory as "extended logic" (developed from Cox's theorem, which derives probability axioms from consistency requirements on plausible reasoning), and the **maximum entropy principle** for constructing priors from constraints (_Probability Theory: The Logic of Science_, 2003, posthumous). Jaynes supplies the cleanest information-theoretic reading of §14.

**Judea Pearl (1936–).** Pearl imported Bayesian reasoning into AI via **Bayesian networks** (_Probabilistic Reasoning in Intelligent Systems_, 1988) — factoring joint distributions on directed acyclic graphs — then went beyond probability into formal causality (_Causality_, 2000; the do-calculus). §13 covers the graphical machinery.

**Andrew Gelman (1965–).** Gelman represents the modern **pragmatic** synthesis: hierarchical models, weakly informative priors, posterior predictive checking, and a workflow view in which models are fit, checked, criticized, and expanded iteratively (_Bayesian Data Analysis_, with Carlin, Stern, Dunson, Vehtari, Rubin; 3rd ed. 2013). Notably, Gelman's philosophy is closer to falsificationism than to subjective Bayesian orthodoxy: the prior and likelihood are provisional model assumptions to be tested, not sacred beliefs.

**David Spiegelhalter (1953–).** Spiegelhalter carried Bayesian methods into medical statistics, model comparison (DIC), and public risk communication — the applied tradition demonstrating that Bayesian machinery survives contact with regulators, clinicians, and messy institutional data.

**Synthesis.** The historical arc is: theorem (Bayes) → general method (Laplace) → exile over priors (Fisher/Neyman) → three rehabilitations (Jeffreys' invariance, de Finetti/Savage's decision theory, Jaynes' information theory) → computational revolution (MCMC, 1990s; Gelfand & Smith 1990 is the standard landmark) → modern probabilistic inference as a routine engineering tool (Stan, PyMC, and the probabilistic programming ecosystem, §19). The prior problem was never "solved"; it was domesticated by hierarchical modeling, weak-information defaults, and sensitivity analysis.

---

## 2. Philosophical Foundations

### 2.1 The Bayesian interpretation of probability

In the Bayesian view, probability is a **numerical measure of degree of belief** held by an agent about a proposition, conditional on the agent's information. Probability is therefore always conditional and always relative to an information state: $P(A \mid \mathcal{I})$. Two agents with different information may rationally hold different probabilities for the same event — a fact that is not a bug but the entire premise of trading: an edge, if it exists, is a _justified_ difference between our conditional probability and the market's (see [[Edge Detection]] for why "justified" requires population-level validation, never single outcomes).

Three sub-schools:

- **Subjective (de Finetti, Savage, Lindley):** probabilities are personal; the only constraint is coherence. Operationalized via betting: your probability for $A$ is the price $p$ at which you are indifferent between buying and selling a contract paying 1 if $A$. This is _literally_ the structure of a Kalshi binary contract.
- **Objective/logical (Jeffreys, Jaynes, Cox):** given the same information, rational agents should hold the same probabilities; priors are determined by symmetry, invariance, or maximum entropy.
- **Pragmatic (Gelman, mainstream applied practice):** priors and likelihoods are modeling assumptions, judged by predictive performance and posterior predictive checks rather than philosophical pedigree.

### 2.2 Coherence and Dutch Book arguments

The **Dutch Book theorem** (Ramsey 1926; de Finetti 1937) states: if an agent's betting prices violate the probability axioms, a bookmaker can construct a portfolio of bets — each individually acceptable to the agent — that guarantees the agent a sure loss. Conversely, prices satisfying the axioms admit no such book. The **dynamic** Dutch Book argument (Teller, Lewis) extends this to updating: an agent who updates by any rule other than conditionalization is vulnerable to a sure-loss strategy across time.

Engineering reading: coherence is an _arbitrage condition_. A set of Kalshi bracket prices for one city-day that sums to more than $1 (after fees) is an incoherent belief state, and the arbitrage against it is precisely the Dutch Book. Internal consistency of our own model's output — bracket probabilities summing to 1, monotone CDFs, no negative probabilities — is not aesthetic hygiene; it is immunity to being Dutch-booked by the market. The pipeline should validate coherence of every emitted probability vector as an invariant.

Criticisms: the Dutch Book argument assumes the agent must post two-sided prices and accept all bets, which real agents (and real market makers) do not; it establishes that _incoherence is exploitable_, not that _degrees of belief must be probabilities_ in some deeper metaphysical sense. Alternative foundations (Cox's theorem, Savage's representation theorem, accuracy-dominance arguments due to Joyce) reach the same axioms from different premises, which is itself evidence of robustness.

### 2.3 Comparison with rival frameworks

**Frequentism.** Probability is long-run relative frequency in a repeatable experiment; parameters are fixed unknowns, not random; inference is via procedures with guaranteed operating characteristics (Type I error, coverage). Strengths: no priors required; pre-registered error control is institutionally auditable (this is why the lab's own experiment protocol in the [[Pre-Registered Experiment Template]] borrows frequentist discipline — pre-registration, fixed analysis plans — even when the estimand is Bayesian). Weaknesses: answers pertain to the _procedure_, not the observed data ("95% of intervals constructed this way cover the truth" ≠ "this interval contains the truth with probability 0.95"); violates the **likelihood principle** (inference depends on unobserved data via the sampling plan — the stopping-rule problem); no direct way to state $P(\text{hypothesis} \mid \text{data})$, which is the quantity a trader actually needs.

**Likelihoodism (Edwards, Royall).** The likelihood function is the sole carrier of evidence; evidence for $H_1$ over $H_2$ is the likelihood ratio; no priors, no posteriors. It honors the likelihood principle but provides no mechanism for turning evidence into belief or action — it stops one step short of a decision, which makes it insufficient alone for an autonomous trading system, though likelihood ratios are the correct _evidence-accounting_ object (§3.3).

**Fiducial inference (Fisher).** Fisher's attempt to obtain posterior-like statements without priors by "inverting" pivotal quantities. Generally regarded as incoherent outside special cases (it can violate probability axioms); its modern descendants (confidence distributions, generalized fiducial inference) are an active but niche research area. Included here for completeness: when a method promises posterior probabilities without priors, the prior is usually hidden, not absent.

### 2.4 Standing criticisms of Bayesianism

Taken seriously, the strongest objections are: (i) **prior subjectivity** — two analysts can reach different conclusions from the same data, which complicates institutional and adversarial settings; (ii) **catch-all hypothesis problem** — the posterior is only as good as the model space; Bayes cannot assign probability to models never written down (directly relevant to model misspecification, §18); (iii) **computational cost** — exact posteriors are usually intractable (§9); (iv) **old evidence problem** — conditioning on already-known facts is philosophically awkward; (v) **calibration is not guaranteed** — a coherent subjective Bayesian can be badly miscalibrated against reality (Dawid 1982); coherence constrains _internal consistency_, and only empirical verification constrains _external correspondence_. Point (v) is the philosophical justification for the lab's entire [[Forecast Verification]] program: we never trust a posterior because it is a posterior; we score it.

---

## 3. Bayes' Theorem

### 3.1 Derivation

From the definition of conditional probability, $P(A \mid B) = P(A \cap B)/P(B)$ and symmetrically $P(B \mid A) = P(A \cap B)/P(A)$. Equating the two expressions for the joint:

$$P(A \mid B) = \frac{P(B \mid A),P(A)}{P(B)}.$$

For a parameter $\theta$ and data $y$, with the law of total probability expanding the denominator:

$$\underbrace{p(\theta \mid y)}_{\text{posterior}} = \frac{\overbrace{p(y \mid \theta)}^{\text{likelihood}};\overbrace{p(\theta)}^{\text{prior}}}{\underbrace{\int p(y \mid \theta'),p(\theta'),d\theta'}_{\text{evidence } p(y)}} ;\propto; p(y \mid \theta),p(\theta).$$

The derivation is two lines; the content is the _interpretation_: the theorem is the unique coherent rule for revising a belief distribution in light of data (per the dynamic Dutch Book and related theorems, §2.2).

### 3.2 Odds form and likelihood ratios

For two hypotheses $H_1, H_0$:

$$\underbrace{\frac{P(H_1 \mid y)}{P(H_0 \mid y)}}_{\text{posterior odds}} = \underbrace{\frac{p(y \mid H_1)}{p(y \mid H_0)}}_{\text{Bayes factor / LR}} \times \underbrace{\frac{P(H_1)}{P(H_0)}}_{\text{prior odds}}.$$

Taking logs makes evidence _additive_: $\log \text{posterior odds} = \log \text{LR} + \log \text{prior odds}$. Independent pieces of evidence contribute additive log-likelihood-ratio increments ("weight of evidence," Good 1950; measured in bits if $\log_2$). This is the correct mental model for information flowing into a market price and for accounting how much each feature moves a forecast.

The odds form also exposes the anatomy of base-rate neglect: a strong likelihood ratio applied to extreme prior odds still yields extreme posterior odds. In bracket terms: a model signal with LR = 10 in favor of an outer temperature bracket whose climatological prior is 0.5% moves the posterior only to ≈ 4.8% — still a longshot. Failing to respect this is one mechanistic story behind the favorite–longshot bias documented in [[Prediction Markets]].

### 3.3 Sequential updating

If observations $y_1, y_2, \ldots$ arrive over time and are conditionally independent given $\theta$:

$$p(\theta \mid y_{1:t}) \propto p(y_t \mid \theta); p(\theta \mid y_{1:t-1}).$$

**Yesterday's posterior is today's prior.** Batch and sequential processing give identical answers (order-invariance under conditional independence) — a coherence property with a direct engineering payoff: streaming updates of a forecast as new NWS model cycles arrive are mathematically equivalent to refitting from scratch, so an incremental pipeline is licensed by the theory. When observations are _not_ conditionally independent (weather observations across adjacent days are not), the factorization must model the dependence explicitly or the sequential shortcut silently double-counts information — the same correlation problem that motivates city-days as the honest unit in [[Effective Sample Size]].

### 3.4 Graphical intuition

Picture the prior as a density over $\theta$ and the likelihood as a second (unnormalized) function scoring how well each $\theta$ explains the data. The posterior is their pointwise product, renormalized: mass survives only where _both_ prior and likelihood are non-negligible. Consequences visible immediately from this picture: (i) a prior that is zero somewhere can never recover mass there (Cromwell's rule); (ii) as data accumulate the likelihood term sharpens and dominates any fixed, everywhere-positive prior (Bernstein–von Mises, §7); (iii) prior–likelihood _conflict_ — modes far apart with little overlap — produces a posterior in the overlap region that may be sharper than honest, which is a diagnostic red flag rather than a gift (§18).

### 3.5 Bayes' theorem as an information-updating rule

The theorem is best understood not as a formula about events but as **the** consistent mapping from (information state, new data) → (new information state). Three framings converge: decision-theoretically, conditionalization is the unique update rule immune to dynamic Dutch Books; information-theoretically, the posterior is the distribution that minimizes KL divergence from the prior subject to the constraint of respecting the observed data (§14); and in Zellner's (1988) formulation, Bayes' theorem is an "optimal information processing rule" — output information equals input information, with no leakage and no fabrication. For a trading system, this last property is the design target: the pipeline should neither destroy information it has paid to collect nor hallucinate information it does not have. Departures from Bayes-consistent updating are, in this precise sense, either waste or fabrication.

---

## 4. Bayesian Inference

### 4.1 The objects

A full Bayesian analysis specifies a **joint distribution** $p(\theta, y) = p(\theta),p(y \mid \theta)$ and then computes conditionals of interest:

- **Prior** $p(\theta)$: belief about parameters before the data at hand (§5).
- **Likelihood** $p(y \mid \theta)$: the observation model, viewed as a function of $\theta$ with $y$ fixed (§6).
- **Posterior** $p(\theta \mid y)$: the complete inferential output (§7).
- **Posterior predictive** $p(\tilde y \mid y) = \int p(\tilde y \mid \theta), p(\theta \mid y), d\theta$: the distribution of _future observables_, integrating over parameter uncertainty. This — not the posterior over parameters — is the object a forecaster ships. A Kalshi bracket probability is a posterior predictive probability: $P(\tilde y \in [a, b) \mid \text{data})$.
- **Evidence / marginal likelihood** $p(y) = \int p(y \mid \theta),p(\theta),d\theta$: the prior-averaged probability of the data. Irrelevant for parameter estimation (it is a constant in $\theta$) but central to model comparison: the Bayes factor between models is a ratio of evidences, and evidence automatically encodes an Occam penalty — a model that spreads prior mass over many datasets it could explain assigns less to the one actually observed.

### 4.2 The pipeline

The canonical modern workflow (Gelman et al.; Box's loop) is iterative, not one-shot:

1. **Model specification** — choose likelihood and priors from domain knowledge; document them _before_ seeing outcome data (the lab's Invariant 1 pre-registration discipline is exactly this step made auditable).
2. **Prior predictive check** — simulate data from $p(\tilde y) = \int p(\tilde y \mid \theta)p(\theta)d\theta$ and confirm the prior does not generate absurdities (e.g., a prior over daily-high temperature parameters that routinely simulates 150°F in Chicago is wrong _before any data arrive_).
3. **Computation** — obtain the posterior exactly (conjugacy, §8) or approximately (MCMC/VI, §9).
4. **Diagnostics** — verify the computation converged (§19); a wrong answer computed confidently is the worst outcome.
5. **Posterior predictive check** — simulate replicate data from the fitted model and compare against observed data on test statistics that matter (tail frequencies, autocorrelation, bracket hit rates). Systematic discrepancy → model criticism → revise and repeat.
6. **Decision** — push the posterior (predictive) through the loss function (§10); for this lab, through fee-adjusted expected value and fractional Kelly sizing.

The pipeline's non-negotiable property: **uncertainty is carried end-to-end.** Point estimates are extracted, if at all, only at the final decision step, by an explicit loss function — never silently in the middle by taking a mean and pretending it is known.

---

## 5. Priors

### 5.1 Taxonomy

**Informative priors** encode genuine domain knowledge: climatological temperature distributions for a station-month are an informative prior for that market's outcome, before any forecast information arrives. In this lab, climatology-as-prior is not optional coloring — it is the explicit baseline layer of the reference ladder (climatology → NWS → market) in [[Edge Detection]].

**Weakly informative priors** (Gelman school) encode only the _scale_ of plausibility — enough to regularize and rule out absurd values, deliberately weaker than full knowledge. Example: a $\mathrm{Normal}(0, 5^2)$ prior on a standardized regression coefficient. These are the pragmatic default in applied work: they stabilize computation, tame small-sample variance, and are hard to accuse of smuggling in conclusions.

**Noninformative / flat priors** attempt neutrality via uniformity. The classical objection stands: flatness is not invariant to reparameterization, so "no information" is ill-defined. Flat priors on unbounded spaces are improper (do not integrate to 1); improper priors sometimes yield proper posteriors, but this must be _proved_, not assumed, and improper priors invalidate Bayes factors (the marginal likelihood inherits an arbitrary constant).

**Jeffreys priors** solve invariance by construction: $p(\theta) \propto \sqrt{\det I(\theta)}$, where $I(\theta)$ is the Fisher information. Invariant under reparameterization; for a Bernoulli proportion it is $\mathrm{Beta}(\tfrac12, \tfrac12)$, which up-weights the extremes relative to uniform. Behaves poorly in high dimensions, which motivated Bernardo's **reference priors** (maximize expected KL divergence between prior and posterior — the "let the data speak loudest" prior, derived rather than asserted).

**Empirical Bayes** estimates the prior from the data itself (typically by maximizing the marginal likelihood over prior hyperparameters). Philosophically impure — the data are used twice — but often an excellent approximation to full hierarchical Bayes when the number of parallel units is large, and computationally cheap. The James–Stein shrinkage phenomenon is empirical Bayes in disguise.

**Hierarchical priors** are the modern resolution of most prior anxiety. Instead of fixing prior parameters, place a distribution over them: $y_{cj} \sim p(y \mid \theta_c)$, $\theta_c \sim p(\theta \mid \phi)$, $\phi \sim p(\phi)$. For this lab the archetype is immediate: per-city bias parameters $\theta_c$ for five cities, partially pooled through shared hyperparameters $\phi$. Cities with less data are shrunk toward the group mean; cities with abundant data are allowed to individuate. Partial pooling is adaptively learned from the data rather than chosen between the false extremes of "pool everything" and "pool nothing" — and it is the principled answer to estimating five city-level effects from limited city-days.

### 5.2 How priors affect inference — and criticisms

The posterior is a compromise between prior and likelihood weighted by their informativeness; schematically, for conjugate-normal cases the posterior mean is a precision-weighted average of prior mean and data mean. Hence: with abundant data the prior washes out (Bernstein–von Mises); with scarce data the prior dominates — which is precisely when the lab operates (early accrual, ≤150 city-days/month). **Prior sensitivity analysis is therefore mandatory, not decorative, at this project's sample sizes**: refit under a bracketing family of priors and report how conclusions move. If a claimed edge survives only under one flattering prior, it is not a finding; it is a prior echo.

Standing criticisms, with honest responses: (i) _subjectivity_ — answered partially by weak-information defaults, hierarchical structure, sensitivity analysis, and pre-registration of priors; (ii) _unfalsifiability of the prior_ — answered by prior predictive checks, which make the prior an empirical claim; (iii) _garbage-in_ — no answer exists; a dogmatic prior (Cromwell violation) cannot be rescued by data. Operational rule: every prior in the lab's model registry is a pre-registered, documented, checkable artifact with a stated rationale — priors are code.

---

## 6. Likelihood Functions

### 6.1 Construction and interpretation

The likelihood $L(\theta; y) = p(y \mid \theta)$ is the observation model re-read as a function of parameters with data fixed. Construction _is_ modeling: choosing a Gaussian likelihood for temperature errors versus a skew-t with heavier tails is a substantive scientific claim about the error process, and the wrong choice biases every downstream posterior probability, especially in the outer brackets where the money is.

**Likelihood is not probability.** $L(\theta; y)$ does not integrate to 1 over $\theta$; only ratios of likelihoods at different $\theta$ values are meaningful, and $L$ carries no belief content until multiplied by a prior. Confusing "the likelihood of $\theta$ is high" with "$\theta$ is probable" is the transposed conditional fallacy — the same error as reading a p-value as $P(H_0 \mid \text{data})$. This confusion is listed in §18 as a first-class pitfall because it recurs in informal reasoning about model fit.

### 6.2 Sufficiency and exponential families

A statistic $T(y)$ is **sufficient** for $\theta$ if $p(y \mid T, \theta)$ does not depend on $\theta$ — $T$ captures everything the data say about the parameter (Fisher–Neyman factorization: $p(y\mid\theta) = g(T(y), \theta),h(y)$). **Exponential families**, $p(y \mid \eta) = h(y)\exp{\eta^\top T(y) - A(\eta)}$, are exactly the families with fixed-dimensional sufficient statistics under i.i.d. sampling (Pitman–Koopman–Darmois), and they include Bernoulli, binomial, Poisson, Gaussian, gamma, and multinomial. Practical consequences: (i) conjugate priors exist mechanically for exponential families (§8); (ii) sufficiency licenses aggressive data compression — the pipeline can store $(n, \sum y, \sum y^2)$ per cell instead of raw vectors _when the model is trusted_, though this lab's Invariant 4 (append-only raw storage) correctly refuses to rely on that: sufficiency is model-relative, and a changed model resurrects the need for raw data.

### 6.3 Likelihood and forecasting

The bridge to [[Forecast Verification]] is exact: the **log score** of a probabilistic forecast is the log-likelihood of the outcome under the forecast distribution. Maximizing out-of-sample log-likelihood, minimizing KL divergence to the data-generating process, and maximizing the expected log score are the same optimization (§14, §16). A forecaster is, formally, a likelihood engineer.

---

## 7. Posterior Distributions

### 7.1 The posterior as complete answer

The posterior $p(\theta \mid y)$ carries all remaining uncertainty. Summaries — mean, median, mode (MAP), variance — are projections chosen by an implicit loss function (§10): the posterior mean minimizes squared-error loss, the median absolute loss, the mode 0–1 loss. Reporting a point estimate without naming its loss function is an unstated decision.

**Credible intervals.** A 95% credible interval is a set containing 95% of posterior mass — a direct probability statement about the parameter given the data. Two constructions: equal-tailed (2.5% in each tail) and highest posterior density (HPD; shortest interval, appropriate for skewed posteriors).

**Contrast with confidence intervals.** A 95% _confidence_ interval is a realization of a procedure that covers the true value in 95% of hypothetical repetitions; it licenses no probability statement about _this_ interval. The Bayesian statement is the one users invariably want and mistakenly believe the frequentist interval provides. The two often numerically coincide (flat priors, regular models, large $n$ — Bernstein–von Mises: the posterior converges to a normal centered at the MLE with variance $I(\hat\theta)^{-1}/n$), which is why the distinction is easy to forget and occasionally expensive to remember: they diverge exactly in the small-sample, informative-prior, boundary-parameter regimes.

### 7.2 Posterior predictive checks (PPC)

Simulate replicated datasets $y^{\mathrm{rep}} \sim p(\tilde y \mid y)$ and compare to the observed data via test statistics $T$; the posterior predictive p-value $P(T(y^{\mathrm{rep}}) \geq T(y) \mid y)$ near 0 or 1 flags misfit _in the direction $T$ measures_. PPCs are the Bayesian falsification instrument: they cannot confirm a model, but they localize how it fails. For this lab the mandated $T$s are the ones money cares about: outer-bracket exceedance frequencies, verification-vs-forecast spread ratios, and lag-1 autocorrelation of forecast errors (the correlation structure that determines effective sample size). A model that passes mean-error PPCs and fails tail PPCs is precisely the model that looks fine and loses money on longshots.

---

## 8. Conjugate Priors

A prior family is **conjugate** to a likelihood if the posterior remains in the family — updating reduces to updating hyperparameters in closed form. Conjugacy is an algebraic accident of exponential families (§6.2) with outsized engineering value: exact, instant, streaming-friendly inference.

**Beta-Binomial.** $\theta \sim \mathrm{Beta}(\alpha, \beta)$, $k \mid \theta \sim \mathrm{Binomial}(n, \theta)$ ⟹ $\theta \mid k \sim \mathrm{Beta}(\alpha + k, \beta + n - k)$. Hyperparameters are pseudo-counts: the prior is worth $\alpha + \beta$ imaginary trials. Posterior mean $\frac{\alpha + k}{\alpha + \beta + n}$ interpolates prior mean and sample frequency. Laplace's rule of succession is $\alpha = \beta = 1$. **Lab use:** any binary event frequency estimated from limited counts — e.g., empirical calibration of "market favorite wins" per bracket position — should be Beta-smoothed rather than raw-frequency, and the pseudo-count choice documented.

**Gamma-Poisson.** $\lambda \sim \mathrm{Gamma}(\alpha, \beta)$, $y_i \mid \lambda \sim \mathrm{Poisson}(\lambda)$ ⟹ $\lambda \mid y \sim \mathrm{Gamma}(\alpha + \sum y_i,; \beta + n)$. The posterior predictive is negative binomial — Poisson with gamma-mixed rate — the canonical model for overdispersed counts (e.g., data-gap events per collector per week in the gap-audit).

**Normal-Normal.** Known variance $\sigma^2$: $\mu \sim \mathrm{N}(\mu_0, \tau_0^2)$, $y_i \sim \mathrm{N}(\mu, \sigma^2)$ ⟹ posterior mean is the precision-weighted average $\left(\frac{\mu_0}{\tau_0^2} + \frac{n\bar y}{\sigma^2}\right)\big/\left(\frac{1}{\tau_0^2} + \frac{n}{\sigma^2}\right)$, posterior precision the sum of precisions. **Precisions add; information is additive.** This single formula is the skeleton of Kalman filtering, of forecast combination by inverse-variance weighting (§17), and of every shrinkage intuition in the project. With unknown variance, the conjugate family is Normal–Inverse-Gamma and the predictive is Student-t — fatter tails than any plug-in Gaussian, which is the mathematically honest way parameter uncertainty widens forecast intervals.

**Dirichlet-Multinomial.** $\boldsymbol\pi \sim \mathrm{Dirichlet}(\boldsymbol\alpha)$, counts $\mathbf{n} \mid \boldsymbol\pi \sim \mathrm{Multinomial}$ ⟹ $\boldsymbol\pi \mid \mathbf{n} \sim \mathrm{Dirichlet}(\boldsymbol\alpha + \mathbf{n})$. The direct generalization of Beta-Binomial to $K$ categories — and Kalshi temperature markets are $K$ ordered brackets. Dirichlet smoothing of empirical bracket frequencies is the correct climatological baseline estimator at small $n$; note, however, that the Dirichlet ignores bracket _ordering_ (adjacent brackets are not a priori more similar than distant ones), so an ordering-aware prior (e.g., logistic-normal with correlated adjacent categories, or a smoothed parametric temperature distribution discretized into brackets) is strictly better for this domain and should be preferred once implemented.

**Why conjugacy matters computationally.** Closed-form posteriors cost microseconds, are exactly reproducible, require no convergence diagnostics, and update in streams (each observation is a hyperparameter increment — §3.3 realized in code). The modern role of conjugacy: default estimator for simple sub-problems, building block inside Gibbs samplers (§9), and the fast path that makes hierarchical models tractable via semi-conjugate structure. Rule of thumb for the lab: **use conjugate machinery wherever the model is honestly that simple; never simplify the model to preserve conjugacy.**

---

## 9. Bayesian Computation

The central obstacle: the posterior is known only up to the intractable normalizing constant $p(y)$. All of Bayesian computation is strategies for characterizing $p(\theta \mid y) \propto p(y\mid\theta)p(\theta)$ without computing the integral.

### 9.1 Markov chain Monte Carlo (MCMC)

Construct a Markov chain whose stationary distribution is the posterior; run it; treat (post-warmup, thinned-or-not) draws as dependent samples. Guarantees are asymptotic; the effective sample size of correlated draws — the same concept, mathematically, as the city-day discounting in [[Effective Sample Size]] — governs Monte Carlo error via $\mathrm{SE} \approx \sigma / \sqrt{\mathrm{ESS}}$.

**Metropolis–Hastings (1953/1970).** Propose $\theta' \sim q(\theta' \mid \theta)$; accept with probability $\min!\left(1, \frac{p(\theta'\mid y),q(\theta \mid \theta')}{p(\theta \mid y),q(\theta' \mid \theta)}\right)$ — the unknown normalizer cancels in the ratio, which is the entire trick. Simple, universal, and inefficient in high dimensions: random-walk proposals explore a $d$-dimensional posterior in $O(d)$-worse time, with a delicate step-size tradeoff (small steps → high acceptance, slow exploration; large steps → rejections).

**Gibbs sampling (Geman & Geman 1984; Gelfand & Smith 1990).** Cycle through full conditionals $p(\theta_j \mid \theta_{-j}, y)$, sampling each in turn — no tuning, no rejections, ideal when semi-conjugacy makes conditionals closed-form (hierarchical normal models). Fails badly under strong posterior correlation: the coordinate-wise moves crawl along diagonal ridges.

**Hamiltonian Monte Carlo (HMC).** Augment with momentum variables and simulate Hamiltonian dynamics using gradients $\nabla_\theta \log p(\theta \mid y)$; distant proposals are accepted with high probability because the dynamics approximately conserve the Hamiltonian. Scales far better with dimension than random-walk methods; cost is gradient availability (automatic differentiation solved this) and two tuning parameters (step size, path length).

**NUTS (Hoffman & Gelman 2014).** The No-U-Turn Sampler adapts HMC's path length automatically (recursively doubles the trajectory until it begins to double back) and adapts step size during warmup. NUTS is the default engine of Stan and PyMC and the de facto standard for continuous-parameter posteriors of moderate dimension. **Default recommendation for this lab's offline model fitting.**

**Sequential Monte Carlo (SMC) / particle filters.** Propagate a weighted particle population through a sequence of distributions (time steps, or tempered bridges from prior to posterior); resample when weights degenerate. The native tool for **online** state-space inference — exactly the shape of "update the latent forecast-bias state as each day's observation arrives" — and for marginal-likelihood estimation as a byproduct.

### 9.2 Deterministic approximations

**Laplace approximation.** Gaussian fit at the posterior mode with covariance $[-\nabla^2 \log p(\theta\mid y)|_{\hat\theta}]^{-1}$. One optimization plus one Hessian; accurate when the posterior is unimodal and roughly Gaussian (large-$n$ regular models, per Bernstein–von Mises); the workhorse inside INLA for latent Gaussian models.

**Variational inference (VI).** Turn integration into optimization: choose a tractable family $q_\phi$ and minimize $\mathrm{KL}(q_\phi ,|, p(\theta \mid y))$, equivalently maximize the evidence lower bound $\mathrm{ELBO} = \mathbb{E}_q[\log p(y, \theta)] - \mathbb{E}_q[\log q_\phi]$. Orders of magnitude faster than MCMC and scalable to massive data via stochastic gradients (SVI; ADVI automates the family choice). Known systematic defect: the exclusive KL direction makes $q$ **mode-seeking and variance-underestimating** — VI posteriors are characteristically overconfident. For a system whose product _is_ calibrated uncertainty, this is not a footnote: **VI output must never feed trading decisions without downstream empirical recalibration against [[Forecast Verification]] diagnostics.**

### 9.3 Comparison and best practices

|Method|Cost|Bias|Scales in $d$|Scales in $n$|Use when|
|---|---|---|---|---|---|
|Conjugate|trivial|none|—|streaming|model is honestly conjugate|
|Laplace|1 optimization|asymptotically small|good|good|unimodal, near-Gaussian|
|MH (random walk)|cheap/iter|none (asymptotic)|poor|poor|low-$d$, quick studies|
|Gibbs|cheap/iter|none (asymptotic)|fair|fair|semi-conjugate hierarchies|
|HMC/NUTS|gradient/iter|none (asymptotic)|good|fair|default for continuous models|
|SMC|particles×steps|small (controllable)|fair|streaming|sequential/online problems|
|VI|optimization|**systematic (underdispersion)**|excellent|excellent|speed-critical, recalibrated downstream|

Modern consensus workflow: prototype in a probabilistic programming language with NUTS; validate computation with $\widehat R$, ESS, divergence counts, and simulation-based calibration (§19); reach for VI or Laplace only when NUTS is too slow, and then audit the approximation against a NUTS run on a subsample. At this lab's data scale (hundreds of city-days, low-dimensional models), **NUTS is affordable for everything in V1–V2; VI is a premature optimization.**

---

## 10. Bayesian Decision Theory

### 10.1 The framework

Inference produces beliefs; decision theory turns beliefs into actions. Ingredients: an action space $\mathcal{A}$, states $\theta$, and a **loss function** $L(\theta, a)$ (equivalently a utility $U = -L$). The **posterior expected loss** of action $a$ is

$$\rho(a \mid y) = \int L(\theta, a), p(\theta \mid y), d\theta,$$

and the **Bayes action** minimizes it: $a^* = \arg\min_a \rho(a \mid y)$. Savage's theorem (§1) says any coherent preference ordering is representable this way; the complete-class theorems say, conversely, that essentially every admissible frequentist decision rule is a Bayes rule under _some_ prior — the frameworks reunite at the decision layer.

The separation is architecturally important: **beliefs and preferences are independent modules.** The posterior does not know about fees, bankroll, or risk appetite; the loss function does not know about data. A pipeline that entangles them (e.g., a model trained to directly output trade sizes) cannot be audited, recalibrated, or re-used across contract types. The lab's layering — forecast layer emits probabilities, decision layer applies fee-adjusted EV thresholds and Kelly sizing — is this theorem as system architecture.

### 10.2 Standard losses and their estimators

Squared error → posterior mean; absolute error → posterior median; 0–1 loss → posterior mode; asymmetric linear (pinball) loss at level $\tau$ → posterior $\tau$-quantile. The practical lesson runs in reverse: whenever a system reports a single number, ask which loss it silently assumed. A MAP estimate fed into an EV calculation imports a 0–1 loss nobody chose.

### 10.3 Connection to trading

A binary contract at price $r$ paying $1, with our posterior probability $p$ for YES:

- **Risk-neutral EV:** buy YES iff $p > r$ (before fees; after fees the threshold shifts by the fee schedule — the fee-adjusted inequality is the lab's minimum trade filter).
- **Log utility of wealth** ⟹ maximize $\mathbb{E}[\ln W]$ ⟹ the [[Kelly Criterion]]: optimal fraction $f^* = \frac{p - r}{1 - r}$ for a binary contract. Kelly is not an add-on to Bayesian decision theory; it _is_ Bayes-optimal action under log utility. The [[Log Score and Kelly Identity — Technical Reference (V2)]] closes the loop: expected log-growth against the market equals the expected log-score advantage of our forecast over the price — **edge in the scoring sense and growth in the bankroll sense are one quantity.**
- **Risk aversion beyond log** and estimation error in $p$ motivate _fractional_ Kelly: betting $\lambda f^*$, $\lambda \in (0,1)$, is equivalent to shrinking the posterior toward the market price — a Bayesian hedge against our own model's overconfidence. Given that $p$ is itself an estimate with a posterior, the honest EV integrates over that uncertainty; treating $\hat p$ as known systematically overstates edge (the "estimation-risk" analogue of §18's overconfidence pitfalls).

Decision-theoretic framing also disciplines _abstention_: "no trade" is an action with zero loss variance, and it is Bayes-optimal whenever the posterior probability interval straddles the fee-adjusted breakeven. A system without a principled abstention rule is not a decision system; it is a compulsion.

---

## 11. Bayesian Forecasting

A **probabilistic forecast** is a predictive distribution over a future observable, and the Bayesian posterior predictive (§4.1) is its canonical construction: $p(\tilde y \mid y) = \int p(\tilde y \mid \theta),p(\theta \mid y),d\theta$. Two distinct uncertainties are automatically combined — **aleatoric** (the irreducible randomness in $p(\tilde y \mid \theta)$) and **epistemic** (parameter uncertainty in $p(\theta \mid y)$). Plug-in forecasting, $p(\tilde y \mid \hat\theta)$, discards the epistemic term and is therefore systematically overconfident; the Student-t predictive of the Normal–Inverse-Gamma model (§8) is the textbook demonstration that honest predictive tails are fatter than plug-in tails. Almost every naive forecasting system is sharp for the wrong reason.

**Ensembles as Monte Carlo posteriors.** Numerical weather prediction ensembles — many integrations from perturbed initial conditions and physics — are best read as approximate samples from a predictive distribution. Raw ensembles are famously **underdispersive** (spread < error, i.e., overconfident) and biased; the statistical repair layer is Bayesian post-processing (§17). The general principle: an ensemble is a sample, not a distribution; turning samples into calibrated probabilities is an inference problem in its own right.

**Sequential revision.** Forecasts for a fixed target date should evolve as a **martingale**: today's forecast is the conditional expectation of tomorrow's ($\mathbb{E}[p_{t+1} \mid \mathcal{F}_t] = p_t$ for a coherent updater). Systematic drift patterns — forecasts that predictably rise into settlement, or oscillate with model cycles — are violations of coherent updating and, when they appear in _market prices_, are precisely the exploitable dynamic inefficiencies the lab's disagreement metric Δ is designed to surface over time. State-space models with filtering (Kalman for linear-Gaussian; particle filters generally; _Bayesian Forecasting and Dynamic Models_, West & Harrison 1997) are the classical machinery for forecast evolution.

**Forecast combination.** Given several forecasters (climatology, NWS, raw model output, the market itself), Bayesian combination ranges from inverse-variance weighting (§8's precisions-add rule) through **Bayesian model averaging** (§16) to regression-based blends (linear opinion pools, beta-calibrated pools). Empirical regularity worth pre-registering as a hypothesis rather than assuming: simple equal-weight combinations are hard to beat at small samples because weight estimation itself consumes effective sample size.

---

## 12. Bayesian Machine Learning

**Bayesian linear regression.** Gaussian prior on weights + Gaussian likelihood ⟹ closed-form Gaussian posterior and predictive; ridge regression is the MAP estimate ($\ell_2$ regularization ≡ Gaussian prior — the Rosetta stone connecting regularized ML to Bayes). The lab's first-generation disagreement models (Δ regressed on features with honest uncertainty) need nothing fancier, and the closed form makes them auditable.

**Gaussian processes (GPs).** A prior directly over _functions_: $f \sim \mathcal{GP}(m, k)$ with any finite set of evaluations jointly Gaussian under kernel $k$. Exact posterior in closed form; predictive variance grows away from data — the model _knows where it is ignorant_, the property most ML models lack and trading systems need. Cost is $O(n^3)$ in observations, irrelevant at this lab's scale for years. Canonical uses here: smooth calibration curves (forecast probability → observed frequency) with uncertainty bands, and station-level bias surfaces over day-of-year. Reference: Rasmussen & Williams 2006.

**Bayesian neural networks (BNNs).** Priors over network weights; exact posteriors intractable; approximations include variational Bayes (Blundell et al. 2015), MC dropout as approximate VI (Gal & Ghahramani 2016), Laplace approximations, and — empirically strongest — **deep ensembles** (Lakshminarayanan et al. 2017), which are only loosely Bayesian but dominate calibration benchmarks. Sober assessment for this lab: BNNs are V3+ material at best; at ≤150 city-days/month the effective sample sizes cannot feed a network, and the uncertainty quality of approximate BNN posteriors is an open research problem (§21), not a settled tool.

**Bayesian optimization.** GP surrogate over an expensive black-box objective + acquisition function (expected improvement, UCB) trading exploration against exploitation. The right tool for tuning pipeline hyperparameters against _backtest_ objectives with few evaluations — with the standing caveat that optimizing a single score invites the forecaster's-dilemma failure mode (Lerch et al. 2017) already flagged in the lab's governance: any objective under optimization pressure needs adversarial companion metrics.

**Probabilistic graphical models** — covered next.

---

## 13. Bayesian Networks

A **Bayesian network** is a directed acyclic graph (DAG) whose nodes are random variables and whose joint distribution factorizes as $p(x_1,\ldots,x_n) = \prod_i p(x_i \mid \mathrm{pa}(x_i))$. The graph encodes **conditional independence** (d-separation): missing edges are the model's substantive claims. Value is threefold: (i) _economy_ — a sparse factorization needs exponentially fewer parameters than a full joint; (ii) _modularity_ — local conditional models can be built, tested, and replaced independently; (iii) _transparent assumptions_ — the independence claims are drawable and therefore auditable.

For this lab, the natural DAG is a documentation and design instrument before it is a fitted model:

$$\text{synoptic state} \to \text{NWS forecast} \to \text{market price}; \quad \text{synoptic state} \to \text{realized temperature}; \quad \text{station siting} \to \text{realized temperature}.$$

Drawing it forces the key questions into the open — does the market condition on anything beyond the public forecast? is settlement-station idiosyncrasy (the reason NWS station verification is on the critical path) independent of the forecast error? — and each question is an edge that data can test.

**Causal interpretation.** A Bayesian network is causal only under additional assumptions (Pearl): arrows as mechanisms, no unmeasured confounding for the relevant queries. Then interventions $do(X = x)$ differ from observations, and the do-calculus computes intervention distributions from observational ones when identifiable. The trading-relevant instance is self-referential: _observing_ a price move is evidence about the world; _causing_ one (our own market impact, at size) is not. A system that learns from prices it itself moved confuses seeing with doing — negligible at V2 paper scale, a real design constraint for any V3 sizing that is non-trivial relative to Kalshi book depth.

Inference in networks: exact (variable elimination, junction tree — exponential in treewidth) or approximate (loopy belief propagation, MCMC). At this project's model sizes, exactness is affordable.

---

## 14. Information Theory Connections

**Entropy** $H(P) = -\sum_x p(x)\log p(x)$ measures the uncertainty of a distribution — the expected surprise, or the irreducible average code length for outcomes drawn from $P$.

**KL divergence** $D_{\mathrm{KL}}(P | Q) = \sum_x p(x)\log\frac{p(x)}{q(x)} \geq 0$ measures the inefficiency of believing $Q$ when reality is $P$: the expected extra log-loss (equivalently, extra code length; equivalently, forgone Kelly growth) paid by the wrong distribution. It is asymmetric and not a metric — the direction matters, as VI's mode-seeking pathology (§9.2) demonstrates.

**Cross entropy** $H(P, Q) = H(P) + D_{\mathrm{KL}}(P|Q)$ decomposes expected log-loss into irreducible uncertainty plus divergence. Minimizing cross entropy (the ubiquitous ML loss) is minimizing KL to the data distribution is maximizing expected log score — three communities, one objective.

**Mutual information** $I(X;Y) = D_{\mathrm{KL}}(p(x,y),|,p(x)p(y))$: the expected entropy reduction about $X$ from observing $Y$. This is the information-theoretic definition of **feature value**: a covariate with negligible mutual information with the settlement outcome, conditional on features already used, cannot improve any proper score no matter how sophisticated the model consuming it.

**Bayesian surprise** $D_{\mathrm{KL}}(\text{posterior} ,|, \text{prior})$: how far one observation moved beliefs. As a monitoring statistic per update, it is a principled anomaly detector — an observation producing extreme surprise is either very informative or evidence of data corruption, and at this lab's ingestion layer the second explanation deserves the first look (a 40°F "observation" in July Phoenix is a parser bug before it is a weather event).

**Why Bayesian inference "minimizes uncertainty."** Several exact statements: (i) conditioning cannot increase expected entropy — $\mathbb{E}_Y[H(\theta \mid Y)] \leq H(\theta)$, information never hurts _in expectation_ (individual observations can increase uncertainty, correctly); (ii) the posterior is the minimum-KL update from the prior consistent with the data (Zellner: Bayes as optimal information processing); (iii) expected log-score improvement from a forecast over a baseline equals the mutual information the forecast captures. The lab's central quantity inherits this: **the expected log-score gap between our forecast and the market price — the population-level object behind Δ — is an information measure: it is exactly the KL-metered information we possess that the price does not, and by the [[Log Score and Kelly Identity — Technical Reference (V2)]] it is also the growth rate of optimally-invested capital.** Edge, information, and growth are three readings of one number. This is the single most load-bearing identity in the laboratory.

---

## 15. Bayesian Statistics in Prediction Markets

**Prices as probabilities.** A binary contract paying $1 trades at price $r \in (0,1)$; de Finetti's operational definition (§2.1) reads $r$ directly as the market's degree of belief. Caveats before that reading is quantitative: fees and spread widen the band of prices consistent with one belief; margin/interest introduces small distortions; risk preferences of the marginal trader can shift prices from probabilities (though for small-stakes, short-horizon, weather-idiosyncratic contracts, risk-neutral pricing is a defensible approximation — the risk is uncorrelated with wealth); and documented biases (favorite–longshot) are systematic departures catalogued in [[Prediction Markets]].

**Belief aggregation.** Under classical rational-expectations results (Aumann's agreement theorem; no-trade theorems à la Milgrom–Stokey), common-knowledge disagreement cannot persist among rational agents with common priors — so persistent trading itself signals heterogeneous priors, noise traders, or hedging demand. Constructively, market microstructure models (Kyle 1985; Glosten–Milgrom 1985) show prices converging toward aggregated information as informed traders trade against market makers who update — the market maker in Glosten–Milgrom is _explicitly a Bayesian_, setting bid/ask as posterior expectations conditional on the direction of order flow.

**Bayesian market makers.** Hanson's **logarithmic market scoring rule (LMSR)** makes the connection exact: an automated market maker whose price function is derived from the log scoring rule, so that each trade is equivalent to the trader replacing the market's forecast with their own and being paid the score difference. Trading against an LMSR _is_ being scored by the log rule; a Kelly-optimal informed trader against such a market extracts exactly their KL-divergence information advantage (§14). Kalshi runs a limit order book, not an LMSR, but the equivalence remains the correct idealized model of what "trading on information" means.

**Updating beliefs from prices.** A price is data. The Bayesian trader's full model treats the observed price as a noisy, possibly biased signal of the aggregate information set: $r = g(\text{information}) + \text{microstructure noise}$, and conditions on it: $p(\text{outcome} \mid \text{our features}, r)$. Two corollaries the lab has already institutionalized: (i) raw disagreement $\Delta = p_{\text{ours}} - r$ is _not_ edge — under the market-efficiency null, conditioning on $r$ should make our residual information negligible, and only population-level scoring with date-clustered inference (per [[Edge Detection]]) can reject that null; (ii) the humility prior — absent validated evidence, the market price is the best available posterior, and the rational default belief is $p = r$. Every claimed deviation from that default carries the burden of proof, denominated in city-days.

**Market efficiency as a Bayesian hypothesis.** "The price correctly aggregates all available information" is itself a testable model: it predicts prices are calibrated (reliability diagrams on settled contracts), martingale-evolving (§11), and unbeatable by any measurable strategy on fee-adjusted log score. V1's calibration studies are exactly the audit of this hypothesis — measuring the market's own posterior quality before presuming to beat it.

---

## 16. Bayesian Calibration

**Calibration** (external validity of stated probabilities): among all occasions a forecaster says "70%," the event should occur ≈70% of the time. Formally, forecasts $\hat p$ are calibrated if $P(Y = 1 \mid \hat p = p) = p$. The **reliability diagram** plots observed frequency against forecast probability by bins; deviations from the diagonal localize over/under-confidence. Full treatment, estimators, and the Murphy decomposition live in [[Proper Scoring Rules and Calibration - Technical Reference (V2)]] and [[Forecast Verification]]; this section covers the specifically Bayesian angles.

**Coherence does not imply calibration.** Dawid's prequential analysis (1982) proved that a Bayesian who _believes their own model_ expects to be calibrated — but expectation under a misspecified model is worthless as a guarantee. A coherent agent with a wrong model is confidently, coherently miscalibrated. Consequence: **calibration is an empirical property, checked against settled outcomes, never a theorem about our pipeline.** This is the Bayesian statistics document formally deferring to the [[Forecast Verification]] program as the higher court.

**Posterior calibration of the computation itself.** Before checking the model against the world, check the _inference_ against the model: **simulation-based calibration (SBC)** (Talts et al. 2018) draws $\theta \sim$ prior, simulates data, fits the posterior, and checks that the rank of the true $\theta$ among posterior draws is uniform. Non-uniform ranks mean the sampler or the implementation is wrong — a bug detector that requires no real data and belongs in the CI suite of any model the lab ships.

**Recalibration.** When a forecaster (ours, NWS's, or the market) is systematically miscalibrated, a learned monotone map $\hat p \mapsto c(\hat p)$ (Platt scaling, isotonic regression, beta calibration) repairs reliability while preserving discrimination ordering. Bayesian bonus: fit the recalibration map with uncertainty (e.g., a GP or a Beta regression with posterior bands), so that recalibrated probabilities near sparse bins are honestly wide rather than spuriously precise.

**Bayesian model averaging (BMA).** With models $M_k$, posterior model probabilities $P(M_k \mid y) \propto p(y \mid M_k)P(M_k)$ weight the combined predictive: $p(\tilde y \mid y) = \sum_k P(M_k \mid y), p(\tilde y \mid y, M_k)$. Within-model parameter uncertainty and between-model uncertainty are handled in one framework — the reason BMA became the standard post-processor in meteorology (§17). Known limitation (the _M-open_ problem): BMA assumes the true model is in the candidate set and asymptotically concentrates all weight on the candidate closest in KL — even when all candidates are wrong. **Stacking** on out-of-sample predictive scores (Yao, Vehtari, Simpson, Gelman 2018) optimizes the combination for predictive performance directly and is the modern recommendation when the goal is forecasting rather than identifying a true model — which is this lab's situation exactly.

---

## 17. Weather Forecast Applications

Modern operational meteorology is one of the largest deployed Bayesian(-spirited) inference systems in existence, and the lab's underlying assets — NWS temperature forecasts — are its outputs.

**Data assimilation as recursive Bayes.** Initializing a numerical weather model means estimating the atmospheric state from heterogeneous observations plus the previous forecast. The forecast-as-prior, observations-as-likelihood, analysis-as-posterior cycle _is_ sequential Bayesian updating (§3.3) at dimension $\sim 10^9$: 3D/4D-Var computes a MAP estimate under Gaussian assumptions; the **ensemble Kalman filter** (Evensen) propagates a sample approximation of the posterior. Every NWS forecast the pipeline ingests is downstream of this Bayesian cycle.

**Ensemble prediction systems** (ECMWF ENS, NOAA GEFS) integrate perturbed members to sample forecast uncertainty. Raw ensembles are biased and **underdispersive** — verifying observations fall outside the ensemble range too often — so raw member frequencies are _not_ usable probabilities. This is a fortunate fact for this project: it means the raw physics output requires a statistical layer, and the quality of that layer is where forecast-quality variation (and therefore potential market disagreement) lives.

**Statistical post-processing — the layer where Bayes is explicit:**

- **BMA for ensembles** (Raftery, Gneiting, Balabdaoui, Polakowski 2005): the predictive is a mixture of per-member kernels (Gaussian for temperature) with weights and spreads fit on a rolling training window — the canonical calibrated-PDF construction for exactly our variable of interest.
- **EMOS / nonhomogeneous Gaussian regression** (Gneiting et al. 2005): a single Gaussian predictive with mean affine in the ensemble mean and variance affine in the ensemble spread, typically fit by minimizing CRPS. Less flexible than BMA, more robust at small samples.
- Both are optimized under the **maximize sharpness subject to calibration** paradigm (Gneiting, Balabdaoui & Raftery 2007) — the same paradigm [[Forecast Verification]] adopts for judging every forecaster in this project, the market included.

**Temperature specifics.** Daily-max temperature post-processing must handle station-specific systematic bias (siting, elevation, urban heat island — the reason settlement-station identity is a critical-path verification task), seasonally varying error variance, and day-of-year effects; hierarchical Bayesian formulations pool across stations and seasons to estimate these from limited data (§5.1's partial pooling, applied literally). The discretization step — calibrated continuous PDF → Kalshi bracket probabilities — is then a pure integration, with the ordering-aware considerations of §8's Dirichlet discussion.

**Why meteorology went Bayesian.** The forecasting problem has every feature that selects for Bayesian treatment: genuinely probabilistic loss structure downstream (users make threshold decisions), multiple information sources demanding principled combination, small effective samples for rare events, and a decades-long verification culture (Brier 1950 was a meteorologist) that empirically punishes overconfidence. The lab operates in the same selection environment.

---

## 18. Common Pitfalls

1. **Confusing likelihood with probability** (§6.1). _Mitigation:_ enforce vocabulary in code and docs — objects named `posterior_prob` must integrate to 1 over hypotheses; likelihoods never do.
2. **Overconfident priors / Cromwell violations.** Zero-probability regions are unrecoverable; near-zero prior mass on outer temperature brackets is how a model gets log-score-destroyed by one heat event. _Mitigation:_ heavy-tailed priors and predictives (Student-t over Gaussian); floor bracket probabilities only via the _model_, never by post-hoc clipping that breaks coherence.
3. **Poor prior selection at small $n$.** At ≤150 city-days/month the prior is a live ingredient for quarters, not a formality. _Mitigation:_ pre-registered priors with written rationale; prior predictive checks; mandatory sensitivity analysis bracketing each prior; report conclusions as robust/fragile to the bracket.
4. **Skipping posterior predictive checks.** A converged sampler on a wrong model yields precise nonsense. _Mitigation:_ PPCs on money-relevant statistics (tail exceedances, error autocorrelation) as a release gate for any model version.
5. **Prior sensitivity ignored → silent conclusions laundering.** _Mitigation:_ as (3); additionally, any headline claim in a lab report carries its sensitivity range or an explicit E-flag.
6. **Model misspecification generally** (the M-open world). All our models are wrong; Bayes conditions _within_ the model space. _Mitigations:_ stacking over BMA (§16); posterior predictive criticism as a standing process; humility prior toward the market price as the default belief (§15).
7. **Bayesian overfitting.** Rich hierarchies and flexible likelihoods can chase noise; the marginal-likelihood Occam penalty operates only across the model space you wrote down. _Mitigation:_ out-of-sample proper-score evaluation (LOO-CV via PSIS; Vehtari, Gelman, Gabry 2017) as the arbiter, never in-sample fit; strict train/eval separation along _time_, respecting date clustering.
8. **Double-counting correlated evidence** (§3.3). Adjacent brackets, adjacent days, and multiple forecasts derived from the same model cycle are not independent observations. _Mitigation:_ city-day accounting ([[Effective Sample Size]]) everywhere a count appears; date-clustered standard errors in all inference.
9. **Treating the posterior of an estimated probability as the probability.** Plugging $\hat p$ into Kelly ignores estimation risk and overbets. _Mitigation:_ integrate EV/Kelly over the posterior of $p$, or shrink via fractional Kelly with documented $\lambda$.
10. **Computation trusted without diagnostics.** _Mitigation:_ §19's gate — no posterior enters the vault or the decision layer without its diagnostic block attached.

---

## 19. Computational Engineering

**Log-space everything.** Likelihoods of many observations underflow double precision rapidly ($10^{-320}$ is a few hundred i.i.d. terms away). All probability arithmetic in the pipeline is in log space: products → sums; normalizations and marginalizations → `logsumexp` with max-subtraction; never `exp()` early. Probabilities near 1 use `log1p`/complement representations to preserve precision where $1 - p$ is the meaningful quantity — for outer brackets, it always is.

**Floating point discipline.** Float64 throughout inference (float32 is an ML-training convenience, not an inference standard); explicit tolerance policy for coherence checks (bracket vectors sum to 1 within $10^{-9}$, renormalize and log if within tolerance, ALARM if outside — mapping onto `core/errors.py` event codes); no equality comparisons on floats in tests.

**MCMC convergence diagnostics — the mandatory block.** For every fitted model: split-$\widehat R < 1.01$ on all quantities of interest (Vehtari et al. 2021 revision of Gelman–Rubin); bulk-ESS and tail-ESS adequate (tail-ESS is the one that matters for the credible-interval endpoints trading decisions consume); zero or investigated divergent transitions for HMC/NUTS (divergences signal posterior geometry the sampler cannot traverse — reparameterize, e.g., non-centered hierarchies, rather than raise `adapt_delta` and hope); trace and rank plots archived. **A posterior without its diagnostics is testimony without provenance** — the computational analogue of Invariant 2, and the diagnostic block should be stored alongside the samples with the same append-only discipline.

**Reproducibility.** Seeded RNGs with seeds logged; pinned environments (`uv` lockfiles); model code, prior hyperparameters, data snapshot hash, and sampler configuration recorded per run — a fitted posterior is a derived artifact whose full provenance chain must reconstruct it bit-for-bit or explain why not.

**Probabilistic programming frameworks.** Stan (mature NUTS, best diagnostics culture; interfaces via CmdStanPy); **PyMC** (Python-native, PyTensor backend — lowest-friction fit for this lab's stack); NumPyro (JAX; fastest for many models, leaner ecosystem); TensorFlow Probability (heavyweight; not indicated here). Recommendation: PyMC as the lab default, CmdStanPy as the cross-check implementation for any model whose outputs gate a trading decision — two independent implementations agreeing is cheap insurance against the silent-wrong-answer failure class. Conjugate updates (§8) are hand-rolled in `numpy` with property-based tests, not framework calls.

---

## 20. Connections to Other Research Lab Documents

- **[[Probability]]** — supplies the measure-theoretic substrate; this document fixes the _interpretation_ (degree of belief) and the update rule on top of it.
- **[[Expected Value]]** — posterior expected loss (§10) is the general form; fee-adjusted EV per contract is its trading instantiation, with the posterior predictive supplying the probabilities.
- **[[Proper Scoring Rules and Calibration - Technical Reference (V2)]]** — scoring rules are the _elicitation and audit_ mechanism for the posteriors this document constructs; log score = predictive log-likelihood is the bridge identity (§6.3, §14).
- **[[Forecast Verification]]** — the empirical court where Bayesian outputs are judged; Dawid's result (§16) is why no posterior is exempt from it.
- **[[Kelly Criterion]]** — Bayes-optimal action under log utility (§10.3); fractional Kelly is posterior shrinkage toward the market.
- **[[Log Score and Kelly Identity — Technical Reference (V2)]]** — the theorem making edge (score gap), information (KL), and growth (log wealth) one quantity (§14).
- **[[Prediction Markets]]** — prices as aggregated de Finetti probabilities (§15); microstructure and bias catalogue for the noise model around $r$.
- **[[Edge Detection]]** — the population-level, date-clustered validation program that alone converts disagreement Δ into edge; Bayesianly: the hypothesis test between "market-efficient null" and "residual-information alternative."
- **[[Machine Learning]]** — regularization ≡ priors, cross entropy ≡ log score, GPs/BNNs (§12); statistical learning theory's generalization bounds are the frequentist complement to posterior predictive honesty.
- **[[Effective Sample Size]]** — the correlation-discounted counting that governs both MCMC error (§9.1) and evidential accounting in city-days (§18.8): one concept, two appearances.
- **Decision Theory / Information Theory** (references pending as standalone notes) — §10 and §14 serve as the vault's working treatments until dedicated notes exist; per the empty-placeholder rule, they are backlog rows, not stubs.

---

## 21. Current Research Frontiers

- **Bayesian deep learning.** The gap between principled BNN posteriors and what is computable remains wide; deep ensembles outperform most "more Bayesian" approximations on calibration benchmarks, and _why_ is contested (loss-landscape multimodality vs. genuine posterior approximation). Cold posteriors, priors over functions rather than weights, and Laplace-approximation revivals are active threads.
- **Scalable inference.** Stochastic-gradient MCMC, distributed/federated posteriors, amortized inference (train a network to emit posteriors — **simulation-based inference**, Cranmer et al. 2020) for models with intractable likelihoods. SBI is genuinely relevant to weather post-processing where the "likelihood" of an NWP system is only available as simulation.
- **Uncertainty-aware AI.** Conformal prediction — distribution-free, finite-sample coverage guarantees wrapped around any point forecaster — is the pragmatic frontier competitor to fully Bayesian intervals; conformalized quantile regression and its weighted variants for non-exchangeable (time-series) data are directly applicable to bracket forecasting and cheap to implement. Watch this literature; it may deliver V2-usable calibrated intervals with fewer assumptions than the Bayesian route.
- **Probabilistic forecasting at scale.** Neural weather models (GraphCast, Pangu-Weather lineage, and their ensemble/probabilistic successors) are displacing parts of the NWP stack; their probabilistic calibration is an open question with direct medium-term relevance to what the "NWS forecast" input to this pipeline will even _be_. E4-flagged and fast-moving; verify current state before relying on any specific claim.
- **Bayesian reinforcement learning.** Thompson sampling — act by sampling from the posterior over models and acting optimally against the sample — is the cleanest exploration/exploitation principle and the natural frame for a V3 agent deciding how much capital to allocate to _learning_ (probing markets) versus _earning_.
- **Bayesian optimization** — maturing into standard tooling (BoTorch/Ax); multi-fidelity and safety-constrained variants relevant to expensive backtest tuning.
- **Causal Bayesian inference.** Merging Pearl's identification machinery with Bayesian estimation uncertainty; proximal causal inference and sensitivity analysis for unobserved confounding. Relevant wherever the lab asks "would prices have differed if the forecast had differed" — a causal, not associational, question.
- **Open problems** worth tracking: principled Bayesian model criticism in M-open settings; calibration guarantees under distribution shift (climate nonstationarity is a slow-motion instance the lab will eventually face); posterior computation with formal accuracy certificates.

---

## 22. Engineering Takeaways

**Core principles.**

1. Probability is conditional degree of belief; every probability in the system is $P(\cdot \mid \text{information set})$, and the information set should be explicit in code and provenance.
2. The posterior predictive — not the parameter posterior, not a point estimate — is the shipped product of a forecasting system.
3. Yesterday's posterior is today's prior; streaming and batch must agree, and disagreement is a bug detector.
4. Beliefs and preferences are separate modules: forecast layer emits probabilities, decision layer applies losses. Never entangle them.
5. Coherence is internal consistency (immunity to Dutch Books); calibration is external correspondence (checked only empirically). A system needs both, and neither implies the other.
6. Expected log-score edge = KL information advantage = Kelly growth rate. One number, three dashboards.

**Best practices.** Pre-register priors with rationale; prior predictive checks before data, posterior predictive checks before release; sensitivity analysis at small $n$ (which for this lab means: for the foreseeable future); full diagnostic blocks archived with every posterior; log-space arithmetic; seeded, pinned, hash-stamped reproducibility; out-of-sample proper scores as the only arbiter of model quality; humility prior $p = r$ as the default belief the evidence must defeat.

**Common design mistakes.** Point estimates extracted mid-pipeline; VI uncertainty consumed without recalibration; conjugacy-driven model simplification; correlated evidence counted as independent; Kelly sizing on $\hat p$ without estimation risk; optimizing one scoring rule without adversarial companions; building model sophistication before the measurement instrument (V1) has proven the lab can observe reality — the roadmap's ordering is itself a Bayesian-workflow prescription.

**For probabilistic systems generally.** Make the model criticizable: priors as reviewable code, independence assumptions as drawable graphs, diagnostics as CI gates, and every emitted probability traceable to (data snapshot, model version, prior version, sampler config, seed). Uncertainty that cannot be audited is decoration.

---

## 23. Annotated Bibliography

_(Canonical references; bibliographic details from memory — E4, spot-check against originals when filing, per project rules. Ranked within tiers; Tier 1 = highest long-term study priority for this lab.)_

### Tier 1 — study these

1. **Gelman, Carlin, Stern, Dunson, Vehtari & Rubin — _Bayesian Data Analysis_, 3rd ed. (2013).** The applied canon: hierarchical models, model checking, computation, workflow. The single most useful book for what this lab actually does.
2. **Gneiting & Raftery (2007), "Strictly proper scoring rules, prediction, and estimation," _JASA_.** The bridge between this document and the verification program; already Tier 1 in the scoring-rules note.
3. **McElreath — _Statistical Rethinking_, 2nd ed. (2020).** The best pedagogy on Bayesian model-building judgment; causal DAG integration; code-first.
4. **Raftery, Gneiting, Balabdaoui & Polakowski (2005), "Using Bayesian model averaging to calibrate forecast ensembles," _Monthly Weather Review_.** The founding paper of the exact post-processing task this lab's forecast layer performs.
5. **Jaynes — _Probability Theory: The Logic of Science_ (2003).** The information-theoretic worldview; read for depth of understanding, not for methods.

### Tier 2 — foundational works (read about them; read originals selectively)

6. **Bayes (1763), "An Essay towards Solving a Problem in the Doctrine of Chances."** Historical; the Beta-Binomial special case.
7. **Laplace (1774/1812), memoirs and _Théorie analytique des probabilités_.** Inverse probability generalized; rule of succession.
8. **de Finetti (1937), "La prévision: ses lois logiques, ses sources subjectives."** Exchangeability, coherence, probability-as-betting — the philosophical foundation of reading market prices as beliefs.
9. **Savage — _The Foundations of Statistics_ (1954).** Subjective expected utility from axioms; the charter for autonomous decision agents.
10. **Jeffreys — _Theory of Probability_, 3rd ed. (1961).** Invariant priors; Bayes factors.
11. **Cox (1946), "Probability, frequency and reasonable expectation," _Am. J. Physics_.** Probability as extended logic — the derivation Jaynes builds on.

### Tier 3 — modern methods references

12. **Murphy, K. — _Probabilistic Machine Learning_ (2022/2023, 2 vols.).** Encyclopedic modern reference; successor to _Machine Learning: A Probabilistic Perspective_ (2012).
13. **Bishop — _Pattern Recognition and Machine Learning_ (2006).** Graphical models, VI, Bayesian linear/logistic regression; aging but lucid.
14. **Rasmussen & Williams — _Gaussian Processes for Machine Learning_ (2006).** The GP canon; free online.
15. **Kruschke — _Doing Bayesian Data Analysis_, 2nd ed. (2015).** Gentlest rigorous on-ramp; useful for onboarding, not for depth.
16. **Hoffman & Gelman (2014), "The No-U-Turn Sampler," _JMLR_.** What the default engine actually does.
17. **Vehtari, Gelman & Gabry (2017), "Practical Bayesian model evaluation using LOO-CV and WAIC," _Statistics and Computing_.** PSIS-LOO; the out-of-sample arbiter.
18. **Yao, Vehtari, Simpson & Gelman (2018), "Using stacking to average Bayesian predictive distributions," _Bayesian Analysis_.** Why stacking beats BMA in M-open forecasting.
19. **Talts et al. (2018), "Validating Bayesian inference algorithms with simulation-based calibration," arXiv.** SBC; belongs in CI.

### Tier 4 — forecasting, markets, and domain

20. **West & Harrison — _Bayesian Forecasting and Dynamic Models_, 2nd ed. (1997).** State-space/DLM machinery for forecast evolution.
21. **Gneiting, Balabdaoui & Raftery (2007), "Probabilistic forecasts, calibration and sharpness," _JRSS-B_.** The governing verification paradigm.
22. **Hanson (2003/2007), LMSR papers.** Markets as scoring rules; the idealized model of information trading.
23. **Wolfers & Zitzewitz (2004), "Prediction markets," _J. Economic Perspectives_.** Economics survey; complements [[Prediction Markets]].
24. **Glosten & Milgrom (1985), "Bid, ask and transaction prices…," _J. Financial Economics_.** The Bayesian market maker.
25. **Dawid (1982), "The well-calibrated Bayesian," _JASA_.** Why coherence ≠ calibration; the license for the verification program.
26. **Lerch et al. (2017), "Forecaster's dilemma," _Statistical Science_.** The governance-level scoring failure mode, already canonical in this vault.

### Tier 5 — probabilistic programming and frontiers

27. **Stan Development Team — Stan User's Guide & Reference Manual** (living document). Best practices encoded as documentation.
28. **Salvatier, Wiecki & Fonnesbeck (2016), "Probabilistic programming in Python using PyMC3," _PeerJ CS_** (and current PyMC docs) — the lab-default framework.
29. **Blei, Kucukelbir & McAuliffe (2017), "Variational inference: A review for statisticians," _JASA_.** VI's promises and pathologies, honestly stated.
30. **Cranmer, Brehmer & Louppe (2020), "The frontier of simulation-based inference," _PNAS_.** Where inference goes when likelihoods are simulators.
31. **Angelopoulos & Bates (2023), "Conformal prediction: A gentle introduction," _Foundations and Trends in ML_.** The assumption-light competitor for calibrated intervals; pragmatic V2 relevance.

---

## Limitations of this document

- Produced as AI testimony (E4). Framework-level content is standard-textbook material; **all specific attributions, dates, equation constants, and empirical claims require verification against primary sources before any is cited in a ratified analysis.**
- No literature search was performed against post-cutoff publications; frontier sections (§21) decay fastest.
- Section 20's Decision Theory and Information Theory links point to notes that do not yet exist; per the placeholder rule they are recorded here as backlog items, not created as stubs.
- This document defines no experiments and grades no evidence; it is reference material only, subordinate to the canonical methodology in `Research_Methodology_v2_Canonical.md` wherever they might appear to conflict.