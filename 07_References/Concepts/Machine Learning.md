---
type: reference
status: seed
created: 2026-07-07
---
---

title: Machine Learning aliases:

- ML
- Statistical Learning
- Machine Learning Reference tags:
- machine-learning
- statistics
- forecasting
- prediction-markets
- quantitative-finance
- reference
- canon-candidate status: E4 — unverified AI testimony, pending Architect verification (Invariant 3) version: "1.0" supersedes: Machine_Learning.md (empty stub)

---

# Machine Learning — Technical Reference

> **Epistemic status.** This document is AI-produced literature synthesis and enters the vault as **E4 testimony**. Framework-level mathematics (definitions, theorems, standard results such as the bias–variance decomposition or the Bellman equations) is textbook-standard and low-risk; **all specific attributions, publication dates, competition results, empirical effect sizes, and numerical constants carry an implicit ⚑ and must be verified against primary sources before any becomes load-bearing in a registration, ADR, or graded analysis.** Where this document and a ratified A-series artifact disagree, the A-series artifact governs. Where it overlaps [[Probability]], [[Bayesian_Statistics]], [[Proper_Scoring_Rules_and_Calibration_-_Technical_Reference]], or [[Forecast_Verification]], those documents are canonical for their subject matter and this note is the integrating layer.

> **Position in the corpus.** This is the vault's reference on _learning from data as an engineering discipline_. It sits between the mathematical layer ([[Probability]], [[Bayesian_Statistics]], [[Expected_Value]]) and the application layer ([[Forecast_Verification]], [[Edge_Detection_v4]], [[Prediction_Markets]], [[Kelly_Criterion]]). Its central editorial commitment, stated up front so the reader can audit for it: **the Lab's data regime (~150 city-days/month, five cities, binary-bracket outcomes) is a small-data, high-verification regime, and the document's recommendations are conditioned on that regime.** Methods that dominate benchmark leaderboards on millions of examples are treated as literature to understand, not defaults to deploy. The governing question throughout is not "what is the most powerful model?" but "what is the most powerful model whose failure modes we can detect with the sample sizes we will actually have?"

> **Scope guard (V-gate discipline).** Sections on reinforcement learning, execution, and autonomous trading (§7, §12, §21) are **V3-horizon literature context**. Nothing in them authorizes trading-side implementation; V1 is a measurement instrument, and the only ML this document endorses for V1/V2 is the forecasting and calibration machinery of §5, §8–§11, §14–§16.

---

## 1. Historical Development

Dates and attributions in this section are conventional and flagged ⚑ as a block; as with [[Expected_Value]] §1, the arc is the load-bearing content, not the chronology.

Machine learning did not descend from a single discipline. It is the confluence of three streams — **statistics** (inference from samples), **optimization** (finding good parameters efficiently), and **computer science** (representing and searching hypothesis spaces at scale) — and most of its recurring controversies are boundary disputes among the three.

**Turing (1950 ⚑)** posed the founding question in _Computing Machinery and Intelligence_: rather than programming intelligence directly, build a "child machine" and educate it — learning as the route to capability. **Arthur Samuel's checkers program (1959 ⚑)** made this operational and coined the term "machine learning": a program that improved its evaluation function from self-play, decades before the same idea reappeared in modern reinforcement learning. Samuel's system already contained the essential loop the Lab should recognize: a parameterized value estimate, feedback from outcomes, and iterative adjustment — the same loop, formalized, that drives temporal-difference learning (§7).

The statistical stream matured through **Vladimir Vapnik** and Alexey Chervonenkis, whose work from the late 1960s onward (systematized in Vapnik's _The Nature of Statistical Learning Theory_, 1995 ⚑) asked the question statistics had under-formalized: _under what conditions does minimizing error on a sample control error on the population?_ The answer — uniform convergence governed by the capacity (VC dimension) of the hypothesis class — is the intellectual foundation of §3 and, transitively, of the Lab's insistence that a probability can only be graded against a population ([[Probability]], [[Forecast_Verification]]). Support vector machines were the constructive product of this theory.

**Judea Pearl** contributed two revolutions. Bayesian networks (_Probabilistic Reasoning in Intelligent Systems_, 1988 ⚑) gave probabilistic reasoning a computational substrate — graphs encoding conditional independence, enabling tractable inference — and rehabilitated probability inside an AI community then dominated by logic. His later causal work (_Causality_, 2000 ⚑) drew the line this vault relies on implicitly everywhere: **prediction and intervention are different problems**, and a model that forecasts superbly under passive observation can fail completely when the system is acted upon. For a lab whose V3 horizon involves _acting_ in a market its models were fit to observe, this is not philosophy; it is a warning label (§22.3).

The connectionist stream — **Hinton, LeCun, Bengio** — kept neural networks alive through two "AI winters." Backpropagation's popularization (Rumelhart, Hinton & Williams, 1986 ⚑), LeCun's convolutional networks for digit recognition (1989–1998 ⚑), and Bengio's neural language models (2003 ⚑) established that composed differentiable functions trained by gradient descent could learn useful representations. The 2012 ImageNet result (Krizhevsky, Sutskever & Hinton ⚑) converted this from minority position to dominant paradigm, earning the trio the 2018 Turing Award ⚑. The honest summary for the Lab: deep learning's victories are overwhelmingly in regimes of **abundant data and rich input structure** (images, audio, text, global weather fields). Neither describes a five-city daily-max dataset.

**Michael Jordan** (the statistician) bridged the streams, developing variational inference, graphical models, and mixture-of-experts architectures, and training a generation that treats ML as _computational statistics_ rather than as artifact engineering. **David MacKay** (_Information Theory, Inference, and Learning Algorithms_, 2003 ⚑) unified the Bayesian and information-theoretic views — learning as compression, model comparison as evidence evaluation — and his treatment of Occam's razor as an automatic consequence of Bayesian marginal likelihood is the cleanest available account of why simpler models should win in small-data regimes. **Christopher Bishop** (_Pattern Recognition and Machine Learning_, 2006 ⚑) wrote the field's canonical probabilistic synthesis; alongside **Hastie, Tibshirani & Friedman** (_The Elements of Statistical Learning_, 2001/2009 ⚑) and **Kevin Murphy** (_Probabilistic Machine Learning_, 2022–2023 ⚑), it defines the textbook canon of §26.

The arc that matters: the field began by asking _whether_ machines could learn, spent its middle decades establishing _when_ learning generalizes, and currently oscillates between scaling empiricism (bigger models, more data) and a counter-current re-emphasizing uncertainty, causality, and reliability. The Lab's needs sit squarely in the counter-current.

---

## 2. Mathematical Foundations

Each discipline below is essential in a specific, identifiable way; a failure to understand _why_ each is present produces a recognizable class of engineering error.

**Probability theory** is the object language. A learned model in this vault's context _is_ a conditional distribution $p(y \mid x)$, and everything the Lab does — scoring, calibration, edge measurement — operates on distributions, not point predictions. The canonical treatment is [[Probability]]; the load-bearing imports here are conditional probability and the law of total expectation (which underwrites the decomposition of forecast error, §14), independence and exchangeability (which determine what "effective sample size" means — see [[Effective_Sample_Size]]), and the distinction between a probability model and a frequency observed in data. The recognizable error from weak probability foundations: treating a model's output score as a probability without ever testing calibration (§15).

**Statistics** supplies the inferential discipline: estimators and their sampling distributions, bias and variance, confidence procedures, hypothesis testing, and — critically for the Lab — the multiple-comparisons problem. Machine learning without statistics degenerates into leaderboard-chasing: selecting among many models on the same finite validation set is itself a multiple-testing procedure, and the winner's measured advantage is biased upward (the "winner's curse" of model selection; cf. D-FV-11's multiplicity ledger in [[Forecast_Verification]]). The recognizable error: reporting the best validation score of dozens of runs as if it were an unbiased estimate of skill.

**Linear algebra** is the representation language. Data are matrices; models are (often) linear maps composed with nonlinearities; covariance structure, principal components, and kernel methods are spectral objects. Understanding rank, conditioning, and the singular value decomposition is what separates "the regression failed" from "the design matrix is ill-conditioned because two lag features are nearly collinear" — a situation guaranteed to arise with temperature lag features, which are strongly autocorrelated (§13).

**Calculus and optimization** are the training engine. Learning is almost always cast as minimizing an empirical objective; gradients are how high-dimensional objectives are minimized; convexity is the property that determines whether the minimum found is the minimum that exists. The recognizable error: treating optimizer output as ground truth without asking whether the objective was the right one (§18) — the entire theory of proper scoring rules ([[Proper_Scoring_Rules_and_Calibration_-_Technical_Reference]]) exists because optimizing the _wrong_ objective produces confidently miscalibrated forecasts.

**Information theory** supplies the currency in which forecast quality, model complexity, and market edge are all denominated. The log score is the negative log-likelihood; its expectation is cross-entropy; the gap between a forecaster and the truth is a KL divergence; and the [[Log_Score_and_Kelly_Identity]] shows that expected log-score improvement over the market _is_ the expected growth rate of Kelly-optimal capital. This identity is the single tightest connection between ML model quality and economic value anywhere in the corpus: **a model that improves log score against market-implied probabilities has, by identity, positive expected log-growth betting against those prices** (before costs — and §12 will insist on "before costs" loudly). MacKay's textbook is the canonical bridge; MDL (minimum description length) reframes model selection as compression and independently motivates the same complexity penalties that Bayesian evidence provides.

The disciplines are not modular. The bias–variance tradeoff (§3) is statistics; its resolution by regularization is optimization; the amount of regularization warranted is governed by sample size (statistics again) and expressible as a prior (probability); and the whole account can be re-derived as a statement about description length (information theory). An engineer fluent in only one dialect will systematically misdiagnose failures expressible only in another.

---

## 3. Learning Theory

Statistical learning theory answers the question every section after this one silently assumes has an answer: _why should performance on data we have predict performance on data we do not?_

### 3.1 The formal setup

Data pairs $(x_i, y_i)$ are drawn i.i.d. from an unknown distribution $\mathcal{D}$. A learner selects a hypothesis $h$ from a class $\mathcal{H}$ to minimize the **risk** $R(h) = \mathbb{E}_{\mathcal{D}}[\ell(h(x), y)]$ for a loss $\ell$. The risk is unobservable; the learner observes only the **empirical risk** $\hat{R}_n(h) = \frac{1}{n}\sum_i \ell(h(x_i), y_i)$.

**Empirical risk minimization (ERM)** selects $\hat{h} = \arg\min_{h \in \mathcal{H}} \hat{R}_n(h)$. The central question is when $\hat{R}_n(\hat{h}) \approx R(\hat{h})$ — note the subtlety: for a _fixed_ $h$, the law of large numbers makes $\hat{R}_n(h) \to R(h)$ trivially, but $\hat{h}$ was _chosen using the data_, so its empirical risk is optimistically biased. Uniform convergence over $\mathcal{H}$ is required, and whether it holds depends on the **capacity** of $\mathcal{H}$.

### 3.2 VC dimension and generalization bounds

The **VC dimension** of a binary hypothesis class is the size of the largest point set the class can shatter (realize all $2^m$ labelings of). Vapnik–Chervonenkis theory yields bounds of the schematic form

$$R(\hat{h}) \le \hat{R}_n(\hat{h}) + O!\left(\sqrt{\frac{d_{VC},\log(n/d_{VC}) + \log(1/\delta)}{n}}\right)$$

with probability $1-\delta$. Three practical readings:

1. **Generalization gap scales like $\sqrt{d_{VC}/n}$.** Capacity is affordable only in proportion to sample size. At the Lab's accrual rate (~150 city-days/month), the affordable capacity for _any_ graded claim is small — this is the learning-theoretic restatement of the vault's "city-day is the honest unit" principle.
2. **The bounds are worst-case and numerically loose** — often vacuous for deep networks that nonetheless generalize. Modern theory (margin bounds, Rademacher complexity, PAC-Bayes, algorithmic stability) tightens the account, and the empirical phenomena of benign overfitting and double descent (§22) show that _which_ interpolating solution the optimizer finds matters as much as raw capacity. The direction of the classical guidance survives; its constants do not.
3. **Capacity is a property of the entire search process, not the final model.** A "simple" logistic regression selected from 400 feature subsets by validation score has the effective capacity of the search, not of the winning model. This is the theory-side justification for the Run Log multiplicity denominator ([[Edge_Detection_v4]], D-FV-11): the ledger records the true size of the hypothesis space searched.

**Structural risk minimization (SRM)** operationalizes the bound: arrange hypothesis classes in a nested hierarchy of increasing capacity $\mathcal{H}_1 \subset \mathcal{H}_2 \subset \cdots$, minimize empirical risk within each, and select the level minimizing the _bound_ (empirical risk plus capacity penalty). Every practical regularization path — ridge with varying $\lambda$, trees with varying depth, early stopping by epoch — is SRM in engineering clothing.

### 3.3 Bias–variance tradeoff

For squared loss, expected prediction error at a point decomposes exactly:

$$\mathbb{E}\big[(y - \hat{f}(x))^2\big] = \underbrace{\big(f(x) - \mathbb{E}[\hat{f}(x)]\big)^2}_{\text{bias}^2} + \underbrace{\mathbb{E}\big[(\hat{f}(x) - \mathbb{E}[\hat{f}(x)])^2\big]}_{\text{variance}} + \underbrace{\sigma^2}_{\text{irreducible}}$$

where the expectation is over training samples. Flexible models have low bias and high variance; rigid models the reverse; sample size shifts the optimal point toward flexibility. The decomposition is the supervised-learning sibling of the Murphy decomposition in [[Forecast_Verification]] (REL − RES + UNC): both split achievable error into a component the modeler controls, a component the modeler can improve only with better information, and a floor set by the world. The irreducible term deserves emphasis in this domain: **daily maximum temperature has genuine meteorological unpredictability at the bracket resolution Kalshi trades**, and no amount of model sophistication removes UNC. A model family should be enlarged only when there is evidence the current family's _bias_ — not the world's noise — dominates the error.

### 3.4 Sample complexity and its Lab consequences

Sample complexity theory asks how many examples are needed to guarantee risk within $\epsilon$ of optimal with confidence $1-\delta$; answers scale with capacity and $1/\epsilon^2$. The inverse-square scaling is the brutal fact of the Lab's life: **halving the uncertainty on a skill estimate requires quadrupling the city-days**, and city-days accrue at fixed wall-clock rate. This is the learning-theory derivation of two standing principles: the accrual clock is the binding constraint, and decidability dates are computable mechanically from accrual rate (A1's design requirement). It also implies a model-selection policy stated here as a directive candidate: _at V1/V2 sample sizes, prefer the smallest model class not demonstrably bias-dominated, and treat every enlargement of the class as a registered, multiplicity-counted event._

---

## 4. Types of Machine Learning

The standard taxonomy divides by _what supervisory signal exists_. The divisions matter because they determine what can be validated, and the Lab's methodology is validation-first.

**Supervised learning** — labeled pairs $(x, y)$; learn $p(y \mid x)$ or a point map. Assumption: training and deployment distributions match (violated in practice; §19). This is the Lab's home regime: features (forecast products, lags, climatology, market state) → outcome (settled bracket), with the enormous advantage that **every city-day yields an unambiguous label from the NWS CLI settlement source**. Ground truth is cheap, objective, and arrives daily. Most industrial ML would envy this.

**Unsupervised learning** — data without labels; learn structure (clusters, densities, low-dimensional manifolds). Its validation problem is intrinsic: without labels there is no ground truth to score against, so unsupervised outputs in this vault are **exploratory instruments, never graded evidence** (§6).

**Self-supervised learning** — labels manufactured from the data itself (predict masked tokens, next frames). This is the engine of modern foundation models, including the AI-weather models of §11. Its relevance to the Lab is as a _consumer_: the Lab may ingest products of self-supervised systems (e.g., forecast fields) as features, but will not train them.

**Semi-supervised learning** — few labels, many unlabeled examples. Largely inapplicable here, since labels are not the scarce resource; _time_ is.

**Reinforcement learning** — no labels at all, only rewards from sequential interaction; learn a policy (§7). Its assumptions (explorable environment, cheap trials, stationary-enough dynamics) are almost maximally violated by live trading with real capital, which is why §21 treats RL for execution as a far-horizon research topic rather than a plan.

A comparison worth internalizing: the taxonomy is really a spectrum of **supervision cost versus assumption load**. Supervised learning buys the strongest guarantees at the price of labels; RL buys autonomy at the price of assumptions that finance rarely satisfies. The Lab, unusually blessed with free labels, should spend its complexity budget where the guarantees are.

---

## 5. Supervised Learning

### 5.1 Regression and classification

**Regression** predicts continuous targets; **classification** predicts categories. The Lab's problem is natively both: daily maximum temperature is continuous, but the traded object is a discrete bracket. Two modeling routes exist, and the choice is consequential:

1. **Distributional regression** — model the full predictive distribution of $T_{max}$ (e.g., a Gaussian or skewed density with parameters depending on features), then integrate over bracket boundaries to obtain bracket probabilities. Advantages: probabilities across brackets are automatically coherent (sum to one, monotone in the natural ordering); one model serves every bracket definition Kalshi might list; distribution shape is inspectable. This is the standard approach in statistical weather post-processing (EMOS/NGR; §11).
2. **Direct classification** — model each bracket (or the full categorical distribution over brackets) directly. Advantages: no distributional-form assumption; the model optimizes exactly the object scored. Disadvantages: separate per-bracket models can produce incoherent probabilities requiring renormalization (and normalization method is itself governed — D-FV-7); ordinal structure must be imposed rather than inherited.

Current best practice in the forecasting literature favors route 1 for temperature-like targets, with route 2 as a robustness check ⚑. The routes coincide asymptotically; at Lab sample sizes the parametric structure of route 1 is a variance-reduction device, i.e., a prior earning its keep.

### 5.2 Probabilistic prediction and its primacy

The vault's position, inherited from [[Forecast_Verification]] and restated here as ML doctrine: **the target object is always the predictive distribution, never the point forecast or the argmax class.** A trading decision consumes a probability (via [[Expected_Value]] and [[Kelly_Criterion]]); classification accuracy discards exactly the information the decision needs. Two models with identical accuracy can have wildly different value: one that says 0.51 when the market says 0.50 and one that says 0.80 when the market says 0.50 have the same argmax but incomparable economics. Losses used in training must therefore be **proper scoring rules** (log loss, Brier) so that the model is incentivized to report its true conditional distribution — the propriety theory is owned by [[Proper_Scoring_Rules_and_Calibration_-_Technical_Reference]]; the engineering consequence here is simply: _never train on, select by, or report accuracy as a primary metric_ (D-FV-3 alignment).

### 5.3 Ranking

Ranking losses (pairwise, listwise; AUC-type objectives) optimize _ordering_ rather than calibrated levels. Their place in a trading system is upstream triage — ordering candidate market-days by expected informativeness or by divergence magnitude for research attention — never downstream sizing, which requires calibrated levels. A model can rank perfectly and be arbitrarily miscalibrated.

### 5.4 Calibration as a first-class supervised objective

Deferred to §15, but the placement principle belongs here: calibration is not a post-hoc nicety; it is half of the Murphy decomposition (REL) and the half most correctable by the modeler. A supervised pipeline in this Lab is not complete until its output has passed the calibration diagnostics of [[Forecast_Verification]] D-FV-8 on out-of-sample data — and any recalibration layer is itself a registered forecaster, scored only from its registration date (the standing recalibration rule).

---

## 6. Unsupervised Learning

Unsupervised methods answer "what structure is in these data?" — a question with no ground truth, hence no grading. Their honest role in this Lab is instrumentation: they generate hypotheses, compress features, and flag anomalies for _human_ attention.

**Clustering** (k-means, hierarchical, Gaussian mixtures, DBSCAN) partitions data by similarity. Every algorithm embeds a geometry assumption (k-means: convex, isotropic clusters; DBSCAN: density-connected regions), and results are sensitive to feature scaling — clustering unscaled features clusters by whichever feature has the largest units. Plausible Lab uses: grouping city-days by synoptic regime as an exploratory lens on when forecast errors correlate (relevant to [[Effective_Sample_Size]] — correlated errors shrink effective n), or segmenting market microstructure conditions. Output status: exploratory, always.

**Dimensionality reduction.** PCA finds orthogonal directions of maximal variance — optimal linear compression, and the standard first response to collinear feature blocks (a temperature lag block is a textbook case). Nonlinear methods (t-SNE, UMAP) are visualization instruments whose distortions (t-SNE preserves local, sacrifices global structure) make them unsuitable as feature pipelines under governance — coordinates change run to run absent careful seeding, offending reproducibility (§20).

**Anomaly detection** (robust z-scores, isolation forests, one-class methods) is the unsupervised family with the clearest _operational_ (not research) role: data-quality alarms. A settlement value inconsistent with observations, a market snapshot with impossible spread, an ingestion gap — these are anomalies in the pipeline-monitoring sense, and simple robust statistics on well-understood quantities beat learned detectors here because **an alarm must be explainable to be actionable**. This aligns with the divergence-triage ladder (A7): boring explanations first.

**Density estimation** (kernel density estimates, mixtures) estimates $p(x)$ directly. Its rigorous Lab use is climatological: the empirical/smoothed distribution of $T_{max}$ by city and season _is_ a density estimate, and it is the bottom rung of the reference ladder (climatology → NWS-derived model → market-implied). Bandwidth/smoothing choices are registration-relevant because they change the climatology forecaster's scores.

**Representation learning** — learning features rather than engineering them — is the deep-learning story (§17). At Lab scale, engineered features from meteorologically meaningful quantities will beat learned representations; the sample sizes to learn representations from scratch do not exist here.

---

## 7. Reinforcement Learning

_V3-horizon literature context. Nothing here is V1/V2 implementation guidance._

### 7.1 The formalism

A **Markov Decision Process (MDP)** is $(\mathcal{S}, \mathcal{A}, P, R, \gamma)$: states, actions, transition kernel $P(s' \mid s, a)$, reward $R(s,a)$, discount $\gamma \in [0,1)$. A **policy** $\pi(a \mid s)$ maps states to action distributions; the objective is expected discounted return. The **value function** $V^\pi(s)$ and **action-value function** $Q^\pi(s,a)$ satisfy the **Bellman equations**:

$$V^\pi(s) = \mathbb{E}_{a \sim \pi}\Big[ R(s,a) + \gamma, \mathbb{E}_{s' \sim P}\big[ V^\pi(s') \big] \Big]$$

and the optimal value satisfies the Bellman optimality equation with a max over actions. Everything in RL is a method for solving these equations when $P$ and $R$ are unknown and experienced only through interaction.

### 7.2 The algorithm families

**Value-based methods.** Q-learning updates $Q(s,a) \leftarrow Q(s,a) + \alpha,[,r + \gamma \max_{a'} Q(s',a') - Q(s,a),]$ — off-policy temporal-difference learning, convergent in the tabular case under standard conditions (Watkins & Dayan, 1992 ⚑). With function approximation, replay buffers, and target networks it becomes DQN (Mnih et al., 2015 ⚑). Known pathology: the "deadly triad" of function approximation + bootstrapping + off-policy data can diverge (Sutton & Barto, 2018 ⚑), and max-based updates are optimistically biased (motivating double Q-learning ⚑).

**Policy-gradient and actor–critic methods.** Directly parameterize $\pi_\theta$ and ascend $\nabla_\theta \mathbb{E}[\text{return}]$ via the policy-gradient theorem; an actor–critic pairs the policy (actor) with a learned value baseline (critic) to reduce gradient variance. PPO (Schulman et al., 2017 ⚑) is the workhorse for its stability. These handle continuous action spaces (position sizes!) naturally but are notoriously sample-hungry and seed-sensitive — published deep-RL results are famously hard to reproduce (Henderson et al., 2018 ⚑), an evidentiary property the Lab should weigh heavily.

**Model-based RL** learns $\hat{P}$ and plans against it, buying sample efficiency at the price of compounding model error over planning horizons. Its philosophical structure — _learn a world model, then optimize decisions against it_ — is in fact the architecture the Lab already has: forecaster (world model) + [[Kelly_Criterion]] (decision rule). Framing it this way clarifies what end-to-end RL would change: it would collapse the model/decision separation that makes each part independently verifiable.

### 7.3 Why sequential trading is formally RL and practically not

Trading is sequential decision-making under uncertainty — an MDP on paper (state: positions, prices, forecasts; actions: orders; reward: log-wealth increments, which makes Kelly the myopic-optimal policy under i.i.d. opportunities, per [[Log_Score_and_Kelly_Identity]]). The practical case against learning the policy directly, in this domain, is decisive at current scale:

1. **Sample starvation.** RL needs millions of transitions; the Lab accrues ~150 terminal outcomes a month.
2. **No safe exploration.** Exploration means losing real money in live markets; simulators inherit every bias of the data used to build them.
3. **Non-stationarity.** Market microstructure drifts; policies overfit to regimes.
4. **Verification asymmetry.** A forecaster can be scored against settlements (proper scoring, D-FV-3); a policy's quality estimate has variance dominated by a handful of large P&L events — exactly the low-power evidence regime the methodology exists to avoid.

The registered position this section supports: **decision rules at V3 should be _derived_ (Kelly-fractional sizing from verified probabilities, with registered risk constraints), not _learned_.** RL literature remains worth tracking for execution-level problems (order placement within the day) where per-decision data is more abundant — see §22.

---

## 8. Bayesian Machine Learning

Canonical foundations live in [[Bayesian_Statistics]]; this section covers the ML-specific machinery and states why the Bayesian view is disproportionately valuable at Lab scale.

### 8.1 Inference as the learning rule

Bayesian ML replaces "find the best parameters" with "compute the distribution over parameters": $p(\theta \mid \mathcal{D}) \propto p(\mathcal{D} \mid \theta), p(\theta)$. Predictions marginalize rather than plug in:

$$p(y^* \mid x^_, \mathcal{D}) = \int p(y^_ \mid x^*, \theta), p(\theta \mid \mathcal{D}), d\theta$$

This **posterior predictive distribution** is the correct object to hand to [[Expected_Value]] and [[Kelly_Criterion]] machinery, because it carries _both_ sources of uncertainty: aleatoric (the world's noise — irreducible, the UNC term) and epistemic (the model's ignorance — shrinks with data). The distinction is decision-relevant, not academic: **epistemic uncertainty is precisely the "estimation risk" that motivates fractional Kelly** ([[Kelly_Criterion]]) — betting full Kelly on a plug-in point estimate ignores parameter uncertainty and systematically over-bets. A Bayesian pipeline makes the shrinkage principled rather than a fudge factor.

The exact integral is intractable outside conjugate families; the approximation families are MCMC (asymptotically exact, expensive, diagnosable via R-hat/ESS — see [[Bayesian_Statistics]]), variational inference (fast, biased toward underdispersed posteriors — a dangerous bias direction for a lab whose sin-to-avoid is overconfidence ⚑), and the Laplace approximation (cheap, local).

### 8.2 Gaussian Processes

A **Gaussian Process** defines a distribution directly over functions: any finite set of function values is jointly Gaussian with mean $m(x)$ and covariance $k(x, x')$. Conditioning on observations yields closed-form posterior mean and variance (Rasmussen & Williams, 2006 ⚑). Properties that make GPs unusually well-matched to this Lab:

- **Honest error bars by construction** — predictive variance grows away from observed data, exactly the behavior wanted from a model that will be asked about unusual synoptic situations.
- **Small-data native** — GPs are competitive at $n$ in the hundreds-to-thousands, which is the Lab's regime for years; the classical $O(n^3)$ cost that motivates sparse approximations is simply not binding here.
- **Assumptions legible in the kernel** — smoothness, seasonality (periodic kernels), and lag structure are stated, inspectable modeling commitments, registrable in the pre-registration sense.

Weaknesses: kernel misspecification produces confident wrongness (the error bars are conditional on the kernel); discrete/non-Gaussian likelihoods require approximation. GPs are a serious candidate for the V2 NWS-derived forecaster's error model and should be on the registered shortlist ⚑ (shortlisting is an Architect decision).

**Bayesian optimization** — GP-modeled objective plus an acquisition function (expected improvement, UCB) — is the sample-efficient way to tune hyperparameters when each evaluation is an expensive walk-forward backtest (§20). It is meta-level machinery: it optimizes the pipeline, not the forecast.

### 8.3 Bayesian neural networks and deep uncertainty

BNNs place priors over network weights; exact inference is hopeless, and the practical approximations are variational BNNs, MC dropout (Gal & Ghahramani, 2016 ⚑), **deep ensembles** (Lakshminarayanan et al., 2017 ⚑), and SWAG-type posterior approximations ⚑. The empirical literature's repeated finding: deep ensembles — just retraining from different seeds and averaging predictive distributions — match or beat fancier approximate posteriors on uncertainty quality (Ovadia et al., 2019 ⚑). The Lab-relevant summary: if a neural model is ever justified (it is not, at V1/V2 tabular scale), its uncertainty should come from ensembling, and even then §15's calibration verification applies with full force, because _none_ of these methods guarantees calibration; they only tend to help.

### 8.4 The doctrinal point

Bayesian methods do not remove the obligation to verify. A posterior predictive is a _claim_; [[Forecast_Verification]] grades claims against settlements regardless of the elegance of their derivation. The Bayesian advantage is that its claims come with self-reported uncertainty that _can be checked_ (PIT histograms, coverage tests — D-FV-9), and that its complexity control (marginal-likelihood Occam effect, MacKay ⚑) is automatic rather than ad hoc. Bayes proposes; the settlement disposes.

---

## 9. Major Algorithm Families

Organized not as a catalog but by the question each family answers well. For every family: intuition, strengths, weaknesses, Lab verdict.

### 9.1 Linear models

$\hat{y} = w^\top x + b$, fit by least squares or maximum likelihood; regularized variants penalize $|w|_2^2$ (ridge — shrinks, handles collinearity) or $|w|_1$ (lasso — sparsifies, selects). Ridge is exactly MAP estimation under a Gaussian prior; lasso under a Laplace prior — regularization _is_ prior information (§2's non-modularity in action).

Strengths: maximal interpretability; coefficients have units; well-understood inference; graceful small-$n$ behavior under regularization; fast enough to refit inside every cross-validation fold (which §14 will demand). Weaknesses: linearity in features (mitigated by feature engineering — the model is linear in _parameters_, not in raw inputs); leverage sensitivity. **Lab verdict: the default baseline for every supervised task in the vault, and the bar every complex model must beat out-of-sample, with the beat surviving D-FV-11 multiplicity accounting.**

### 9.2 Logistic regression

The linear model composed with a sigmoid, fit by maximizing Bernoulli log-likelihood — which makes it the minimal model _natively trained on a proper scoring rule_ (the log score). Its outputs are probabilities by construction and are empirically among the best-calibrated of any uncalibrated model family (Niculescu-Mizil & Caruana, 2005 ⚑). Convex objective, unique optimum, standard errors available. Pathology worth knowing: perfect separation drives coefficients to infinity; the fix is regularization or a weakly-informative prior (Gelman et al., 2008 ⚑). **Lab verdict: the default probabilistic classifier; a regularized logistic model on meteorological features is very plausibly the V2 registered forecaster's engine, and beating it should be treated as a genuinely surprising result requiring evidence, not an assumption.**

### 9.3 Decision trees

Recursive axis-aligned partitioning, greedy impurity minimization (CART: Breiman et al., 1984 ⚑). Interpretable, nonlinear, interaction-discovering, scale-invariant — and high-variance to the point of unusability alone: small data perturbations restructure the tree entirely. Their raw probability estimates (leaf frequencies) are poorly calibrated. Trees matter as components, not models.

### 9.4 Random forests

Bagging (bootstrap aggregation) over trees plus per-split feature subsampling decorrelates the ensemble; averaging slashes variance (Breiman, 2001 ⚑). Strengths: robust off-the-shelf accuracy on tabular data; little tuning; out-of-bag error as a free validation estimate; permutation importance for feature triage. Weaknesses: probability estimates need recalibration (characteristic sigmoid distortion — pushed away from 0/1 ⚑); cannot extrapolate beyond the convex hull of training targets (relevant for record-heat days — a forest trained on history _cannot predict a new record_, a structural failure mode for exactly the days when brackets are most mispriced ⚑); memory-heavy relative to the data sizes here. **Lab verdict: a strong nonlinear benchmark and a feature-importance instrument; recalibrate before any probability leaves it.**

### 9.5 Gradient boosting

Stagewise additive modeling: each tree fits the _gradient of the loss_ at current predictions (Friedman, 2001 ⚑); modern implementations (XGBoost ⚑, LightGBM ⚑, CatBoost ⚑) add second-order steps, clever regularization, and native handling of missing values. Empirical status: the dominant family on tabular problems, including most tabular ML competitions ⚑, and a repeated finding in the recent literature is that **well-tuned gradient boosting still beats deep learning on typical tabular tasks** (Grinsztajn et al., 2022 ⚑; Shwartz-Ziv & Armon, 2022 ⚑). Boosting can optimize log loss directly (proper) and supports quantile/distributional objectives (NGBoost ⚑ and successors emit full predictive distributions). Weaknesses: more hyperparameters than anything above it in this list — which at Lab scale means more multiplicity to ledger; overfits if unregularized; probability calibration good-but-verify. **Lab verdict: the ceiling of model complexity plausibly justifiable at V2; admissible only under pre-registered hyperparameter protocol and walk-forward validation, with its full tuning search counted in the multiplicity denominator.**

### 9.6 Support vector machines

Maximum-margin separators; the kernel trick buys nonlinearity; SRM incarnate (Cortes & Vapnik, 1995 ⚑). Historically pivotal; practically superseded for this Lab's purposes because raw SVM outputs are _not probabilities_ (Platt scaling exists precisely to repair this — §15) and gradient boosting dominates them on tabular data. Verdict: understand, don't deploy.

### 9.7 Naive Bayes

Generative classifier assuming conditional feature independence. Almost always false; often decent _ranking_ anyway; probabilities characteristically extreme (independence double-counts correlated evidence — the same pathology as treating correlated city-days as independent evidence, [[Effective_Sample_Size]]). Verdict: pedagogical value only here.

### 9.8 Neural networks

Composed affine-plus-nonlinearity layers; universal approximators in the limit ⚑; trained by backpropagated SGD. Deferred to §17; the verdict preview: wrong tool for small tabular problems, essential to understand because the _inputs_ the Lab consumes (AI weather models) are made of them.

### 9.9 Gaussian Processes

Covered in §8.2; listed here to place them in the comparison: the family that converts "small data" from a liability into its design point.

### 9.10 Hidden Markov models

Latent discrete state evolving as a Markov chain, observations emitted conditionally; inference by forward–backward, fitting by EM (Rabiner, 1989 ⚑). The natural formalism for **regime structure** — e.g., synoptic regimes governing forecast-error statistics, or market liquidity regimes. Verdict: exploratory instrument for regime hypotheses; any regime-conditional claim graduating to registered status must pre-specify the regime definition (else regime choice is a researcher degree of freedom — a multiplicity leak).

### 9.11 The comparison that matters

|Family|Native probabilities?|Small-$n$ behavior|Interpretability|Lab role|
|---|---|---|---|---|
|Ridge/linear|via error model|excellent|maximal|baseline (continuous)|
|Logistic|**yes**|excellent|high|baseline (probabilistic)|
|Random forest|recalibrate|good|medium|nonlinear benchmark|
|Gradient boosting|good-but-verify|good|medium-low|complexity ceiling (V2)|
|Gaussian process|**yes + epistemic**|**design point**|kernel-legible|error-model candidate|
|Deep nets|no (verify hard)|poor|low|not at this scale|

---

## 10. Time-Series Machine Learning

Everything the Lab predicts is a time series, and time series break the i.i.d. assumption §3's theory was built on. Two consequences dominate: **validation must respect time's arrow** (walk-forward, §14), and **effective sample size is smaller than row count** (autocorrelation means consecutive city-days share information — [[Effective_Sample_Size]] is the vault's canonical treatment).

### 10.1 Classical autoregressive and state-space models

**AR/ARIMA** (Box & Jenkins, 1970 ⚑): the target as a linear function of its own lags plus moving-average error terms, with differencing for trend. Their enduring value is as _humbling baselines_ — the M-competitions repeatedly found simple statistical methods and combinations beating sophisticated entrants (Makridakis et al. ⚑), a finding every ML practitioner should sit with. For daily $T_{max}$, the appropriate classical baseline includes deterministic seasonality (harmonics on day-of-year) plus AR structure on anomalies.

**State-space models** posit a latent state with linear-Gaussian dynamics and noisy observations; the **Kalman filter** computes exact posteriors recursively, and its structure — predict, observe, update, with explicit variance bookkeeping — is the cleanest mental model for _any_ sequential belief-updating system, including how a forecaster's output should assimilate the latest NWS issuance. Non-Gaussian/nonlinear extensions (extended/unscented KF, particle filters) trade exactness for generality. Structural time-series framings (trend + seasonality + regression effects, e.g., BSTS ⚑) are the Bayesian member of this family and compose naturally with §8.

### 10.2 Recurrent architectures

RNNs process sequences through a hidden state; vanilla RNNs suffer vanishing/exploding gradients over long horizons (Bengio et al., 1994 ⚑). **LSTM** (Hochreiter & Schmidhuber, 1997 ⚑) and the lighter **GRU** (Cho et al., 2014 ⚑) add gating to preserve gradient flow. They dominated sequence learning for two decades and remain reasonable at moderate scale, but they are data-hungry relative to anything the Lab will possess, and their point forecasts require an added distributional head (e.g., DeepAR's likelihood outputs ⚑) to be usable under this vault's probabilistic mandate.

### 10.3 Transformers and temporal fusion

**Transformers** (Vaswani et al., 2017 ⚑) replace recurrence with attention — direct, learnable pairwise interactions across all time steps — enabling parallel training and long-range dependency capture. The **Temporal Fusion Transformer** (Lim et al., 2021 ⚑) is the forecasting-specific design: variable-selection networks, static covariate encoders, quantile outputs, interpretable attention. These architectures matter enormously _upstream_ — they are the substance of the AI weather models in §11 — and almost not at all for the Lab's own tabular fitting, where their parameter counts are absurd against hundreds of city-days. A sobering strand of literature: simple linear models have repeatedly embarrassed sophisticated transformer forecasters on standard long-horizon benchmarks (Zeng et al., 2023, "Are Transformers Effective for Time Series Forecasting?" ⚑) — the M-competition lesson, rediscovered.

### 10.4 The Lab's sequence-modeling posture

Stated plainly: **the hard sequence modeling has already been done by NWP centers and AI-weather groups; the Lab's edge candidate is not out-forecasting the atmosphere but out-calibrating the market's use of public forecasts.** The sequence models the Lab itself fits should be small: seasonality-aware error models on top of NWS products, AR structure on forecast errors, state-space assimilation of intraday issuances. The deep sequence literature is consumed here as _supplier due diligence_, not as a build list.

---

## 11. Forecasting Applications

The domain where ML-for-probabilistic-forecasting is most mature is the Lab's own domain: weather.

### 11.1 The NWP stack and where learning enters

Operational forecasting rests on **numerical weather prediction**: physics-based atmospheric simulation (GFS, ECMWF-IFS, and regional models ⚑), made probabilistic by **ensemble prediction** — perturbing initial conditions and physics to produce 20–50 member forecasts whose spread estimates uncertainty (raw ensembles are characteristically **underdispersive**: too confident ⚑). Learning enters at well-defined seams:

1. **Statistical post-processing / MOS.** Model Output Statistics (Glahn & Lowry, 1972 ⚑) regress station outcomes on model output, correcting systematic bias. The probabilistic generation: **EMOS/NGR** (Gneiting et al., 2005 ⚑) fits a full predictive distribution (e.g., Gaussian for temperature) with parameters linear in ensemble mean and spread, trained by minimizing CRPS or log score; **Bayesian Model Averaging** post-processing (Raftery et al., 2005 ⚑) mixes member-centered kernels. This literature is the direct technical ancestor of the Lab's V2 forecaster: _the NWS-derived model on the reference ladder is, in genre, a post-processing model._
2. **Forecast blending.** Weighted combination of models/centers, weights fit on rolling verification. Simple performance-weighted blends are hard to beat (§16).
3. **AI-NWP.** Since 2022–2023, ML models trained on reanalysis (GraphCast ⚑, Pangu-Weather ⚑, FourCastNet ⚑; ECMWF's AIFS entering operations ⚑) match or beat physics-based deterministic skill at a fraction of inference cost, with probabilistic successors (e.g., GenCast ⚑) extending to ensembles. Status for the Lab: potential upstream _inputs_, with two cautions — smoothness biases can damp extremes (bracket tails!) ⚑, and their availability/latency/licensing must clear the same provenance bar as any data source (Invariants 2–3).

### 11.2 Uncertainty quantification and verification culture

Weather forecasting is the field that _invented_ the Lab's evaluation stack — Brier (1950 ⚑), Murphy's decompositions and "what is a good forecast?" (1993 ⚑), Gneiting's propriety synthesis (2007 ⚑), Hamill's small-sample cautions (1999 ⚑) — all canonical in [[Forecast_Verification]]. The paradigm sentence, from Gneiting: **maximize sharpness subject to calibration.** A forecaster is improved by becoming more decisive only insofar as reliability is not sacrificed. Every model the Lab fits is graded under this paradigm, full stop.

### 11.3 Post-processing practice notes (engineering-relevant, all ⚑ pending A-series ratification)

- Train post-processing on **forecast–observation pairs matched by lead time**; skill and error structure vary strongly with lead.
- Seasonal nonstationarity is first-order for temperature: rolling or season-stratified training windows, or harmonic covariates.
- CRPS-trained and log-score-trained EMOS differ in tail behavior; the registered primary score (D-FV-3: log) should be the training objective for coherence, with CRPS reported.
- Station-level idiosyncrasy (siting, instrumentation) is real; per-station intercepts are cheap and usually earn their df. The settlement station is fixed per city (Milestone 1b) — model _that station_, not the metro area.

---

## 12. Prediction Market Applications

Market-mechanics canon lives in [[Prediction_Markets]] and divergence methodology in [[Edge_Detection_v4]]; this section maps ML tasks onto the market problem and states where ML is load-bearing versus decorative.

### 12.1 Probability estimation — the core task

The Lab's central ML problem in one sentence: **produce a calibrated $\hat{p}(\text{bracket} \mid \text{information at time } t)$ that is independent of the market, so its divergence from the market-implied probability is a measurement rather than an echo.** Independence is a data-discipline property, not a modeling property: if market prices enter the feature set, the model partially reproduces the market and Δ is contaminated. Feature provenance rules (§13) exist to protect this.

### 12.2 Market prices as forecasts to beat, not truths to learn

A prediction market price is itself a forecast — an aggregation of participants' information, distorted by fees, spreads, discreteness (1-cent ticks on Kalshi), inventory effects, and documented biases (favorite–longshot: longshots overpriced, favorites underpriced — direction per the corrected vault canon, [[Prediction_Markets]] ⚑). Three ML-relevant consequences:

1. **Market-implied probability is a modeled quantity**, not a read-off: de-vigging/normalization method (multiplicative, power, Shin-class, spread-aware) changes the number, which is why D-FV-7 requires the method's identity to attach to every scored row and why Q1-class questions must be answered under ≥2 registered normalizations.
2. **The market is the strongest baseline.** Decades of forecast-comparison literature find market/consensus prices very hard to beat (economic-derivatives and Iowa-markets strands ⚑). The Lab's null hypothesis is always "the market is at least as skilled as our model," and [[Edge_Detection_v4]]'s machinery exists to reject it honestly or not at all.
3. **Edge ≠ disagreement.** Δ is a per-event observable; edge is a _population-level, statistically validated_ property of a forecaster–market pair (Diebold–Mariano-class comparison, BH-FDR across the question ledger, per A1/[[Edge_Detection_v4]]). ML produces the forecasts; it does not get to declare the edge.

### 12.3 Downstream tasks (V3-horizon, literature posture only)

**Mispricing detection** is §12.1 plus §12.2's statistics — no separate ML system needed; a separate "mispricing classifier" trained on past Δ would be a look-ahead machine. **Market making** (Avellaneda–Stoikov inventory models ⚑; LMSR/AMM literature for subsidized markets, Hanson ⚑) and **order execution** (optimal execution à la Almgren–Chriss ⚑; RL for placement, §22) are rich literatures whose Kalshi-scale applicability is limited by thin books and wide spreads — in thin markets, _taking_ liquidity at bounded cost is the realistic posture, and the ML-relevant quantity is a **fill/impact model**: the mapping from intended size to achieved price. **Liquidity prediction** (spread/depth as a function of time-to-settlement, time-of-day, volatility of the underlying forecast) is a legitimate V2-adjacent measurement task, because executable-price floors feed the boundary rule (D-FV-4).

### 12.4 Costs are not an afterthought

The [[Log_Score_and_Kelly_Identity]] converts log-score improvement into growth _gross of costs_. Fees, spread crossing, discreteness, and adverse selection are subtracted after. A model whose gross edge is smaller than round-trip cost has no edge, however significant its Diebold–Mariano statistic; the economic filter is as registrable as the statistical one. This is the quantitative-finance literature's most consistent lesson — most published "anomalies" shrink or die after costs and multiplicity (Harvey, Liu & Zhu, 2016 ⚑; McLean & Pontiff, 2016 ⚑) — imported here as a standing prior.

---

## 13. Feature Engineering

At Lab scale, feature engineering is where domain knowledge enters the model, and it is governed by the same provenance discipline as everything else.

**The prime directive: every feature must be computable strictly from information available at forecast-issuance time, enforced by the dual-timestamp/as-of-join machinery (D-FV-10), not by researcher conscientiousness.** Leakage through features is the most common way backtests lie (§19), and temperature data offers abundant traps: a "daily mean" computed over the whole day leaks the afternoon max; a station observation ingested late leaks revised values; a climatological normal computed over a window including the target year leaks the target.

**Feature construction, domain-first.** The high-value features here are meteorologically meaningful: NWS point-forecast values by lead time; ensemble mean and spread; forecast revisions between issuances (a momentum-like signal on the forecast itself); climatological anomaly of the forecast; day-of-year harmonics; station-specific bias terms; persistence (yesterday's max); and, kept strictly out of the _independent_ forecaster, market-state features (spread, depth, time-to-close) for the _execution-side_ models of §12.3. Two feature families, two provenance lanes — mixing them is the echo failure of §12.1.

**Lag and temporal features.** Lags of observations and of forecast errors capture autocorrelation; windows must be trailing and as-of-joined. Encode cyclical time as $\sin/\cos$ pairs, not raw integers. Beware creating many correlated lags: collinearity inflates variance of linear fits (ridge mitigates) and dilutes tree-importance measures.

**Normalization.** Standardize features for regularized/kernel/neural models (penalties and distances are unit-sensitive); trees don't care. The non-negotiable: **scaling parameters are fit on training folds only and applied forward** — fitting a scaler on the full dataset is leakage, small but real, and the kind of small-but-real the methodology exists to exclude.

**Interactions and embeddings.** Explicit interaction terms (e.g., spread × lead-time) keep linear models honest against nonlinearity claims. Embeddings — learned dense representations of categorical variables — are the deep-learning approach to categories; with five cities, one-hot encoding plus per-city intercepts is strictly more appropriate (an embedding over five categories is an obfuscated one-hot with extra parameters).

**Feature selection.** Filter (correlation screens), wrapper (search — expensive and multiplicity-explosive), embedded (lasso, tree importance). At Lab scale the honest method is **embedded selection inside each validation fold, with the selection procedure pre-registered** — selecting features on the full dataset before "validation" is selection leakage (Ambroise & McLachlan, 2002 ⚑), one of the classic ways published models fail to replicate. Every feature-set variant tried is a row in the multiplicity ledger.

---

## 14. Model Evaluation

Evaluation is where this document hands off to [[Forecast_Verification]], the canonical treatment. Here: the ML-side mechanics and the reasons classification metrics are demoted.

### 14.1 Splits that respect time

Random train/test splits and vanilla k-fold cross-validation assume exchangeability; time series violate it, and random splits let the model train on the future of its own test set — a leakage mechanism, not a conservative approximation. The Lab-appropriate scheme is **walk-forward (rolling-origin) validation**: train on data through time $t$, predict $t+1 \ldots t+h$, roll forward, aggregate scores (Tashman, 2000 ⚑; Bergmeir & Benítez, 2012 ⚑). Refinements that matter here: leave a **purge gap** between train and test when features contain windows that would otherwise straddle the boundary (López de Prado, 2018 ⚑); block by _date_ across cities, never by row, because the five cities' same-day outcomes are correlated (continental weather regimes) — same-day rows in both train and test is cross-sectional leakage and also the reason resampled uncertainty bands must be date-blocked (D-FV-8's "resampled by date").

### 14.2 The metric hierarchy

Per D-FV-3: **log score registered primary; Brier/RPS registered secondaries; skill scores reported, never optimized.** CRPS serves distributional-regression models on the continuous target before bracketing. The classification-metric family — accuracy, ROC-AUC, precision/recall — is diagnostic-only, for three reasons worth stating as doctrine:

1. **Improper.** Accuracy at a threshold is optimized by hedged, distorted probabilities; it does not incentivize truthful distributions ([[Proper_Scoring_Rules_and_Calibration_-_Technical_Reference]]).
2. **Decision-blind.** [[Expected_Value]]/[[Kelly_Criterion]] machinery consumes probability _levels_; AUC measures ranking and is invariant to any monotone distortion of levels — a model can have AUC 0.75 and be economically worthless through miscalibration.
3. **Base-rate fragile.** Accuracy against 12% base-rate brackets is dominated by "never" prediction; and _outcome-conditioned_ metric slicing is inadmissible as registered evidence outright (D-FV-6).

ROC/PR curves retain one honest use: quick triage of whether a candidate feature carries any ordering signal at all, upstream of the real evaluation.

### 14.3 Scores are estimates

A mean log score over $n$ city-days is a sample mean with sampling error, autocorrelation, and cross-city correlation. Comparisons therefore run through paired-difference machinery (Diebold–Mariano with autocorrelation-robust variance ⚑) and the multiplicity ledger — A1's jurisdiction. The ML habit this kills, deliberately: "model B's validation score is higher, ship it." At ~150 city-days/month, most single-month score differences between reasonable models will be noise, and the decidability-date discipline exists so nobody pretends otherwise.

---

## 15. Calibration

### 15.1 The concept and its diagnostics

A forecaster is **calibrated** if among events assigned probability $p$, the long-run outcome frequency is $p$. Diagnostics: **reliability diagrams** (binned forecast vs. observed frequency — CORP/isotonic-based construction preferred over ad-hoc binning, with classical binned view for comparability, consistency bands resampled by date, sharpness panel adjacent, minimum-$n$ gates: D-FV-8 verbatim); **PIT histograms** for distributional forecasts, with the discrete-outcome construction named in advance (D-FV-9 — continuous PIT on integer-degree outcomes is inadmissible).

Calibration is necessary, not sufficient: the climatology forecaster is perfectly calibrated and has zero resolution. Murphy's decomposition assigns each its term; Gneiting's paradigm ("sharpness subject to calibration") assigns the optimization order.

### 15.2 Recalibration methods

- **Platt scaling** (Platt, 1999 ⚑): fit a one-dimensional logistic map on model scores. Two parameters — appropriate for small calibration sets; assumes a sigmoidal distortion shape.
- **Isotonic regression** (Zadrozny & Elkan, 2002 ⚑): monotone nonparametric map. Flexible; needs materially more data; overfits small calibration sets (step-function artifacts).
- **Temperature scaling** (Guo et al., 2017 ⚑): single-parameter softmax sharpening/flattening — the neural-network favorite; included for literacy.
- **Beta calibration** (Kull et al., 2017 ⚑): a middle point on the flexibility spectrum.

Selection heuristic at Lab scale: Platt/beta first; isotonic only when the calibration set is large enough that its steps are smooth — and "large enough" is measured in _date-blocked effective_ sample size.

### 15.3 Governance interface

The vault's standing rule binds here with full force: **a recalibrated forecaster is a new registered forecaster, scored only from its registration date.** Fitting a recalibration map on past data and applying it retroactively to claim historical skill is exactly the look-ahead the rule prohibits. Recalibration maps are versioned, out-of-sample-fit artifacts (D-FV-10). Additionally: recalibration must not silently launder resolution problems — if a model needs aggressive recalibration, the finding is "the model is miscalibrated," which is diagnostic information about the model family, and it goes in the note.

---

## 16. Ensemble Learning

### 16.1 Why combining wins

Averaging $M$ forecasters with individual error variance $\sigma^2$ and pairwise error correlation $\rho$ yields combined error variance $\sigma^2\left(\rho + \frac{1-\rho}{M}\right)$: the benefit is bounded by correlation, so **diversity is the active ingredient**, not member count. This one formula explains the entire empirical record: bagging works because bootstrap-plus-feature-subsampling manufactures decorrelation (§9.4); boosting works by a different route (each member fixes the residual structure of the last — bias reduction rather than variance); **stacking** (Wolpert, 1992 ⚑) learns combination weights with a meta-learner, and its non-negotiable rule is that the meta-learner trains only on out-of-fold predictions — training it in-sample is self-referential leakage.

**Bayesian model averaging** weights models by posterior evidence — principled, but its known pathology is over-concentration on one model as data grow when _all_ models are wrong (the M-open problem ⚑); **stacking of predictive distributions** (Yao et al., 2018 ⚑) is the modern Bayesian-workflow recommendation. Simplest and most durable of all: the **equal-weight or performance-weighted linear opinion pool**, which forecasting research from Bates & Granger (1969 ⚑) through the M4/M5 competitions ⚑ finds embarrassingly hard to beat — estimated "optimal" weights carry estimation variance that eats their theoretical advantage at realistic sample sizes ("forecast combination puzzle" ⚑).

### 16.2 Lab application

The reference ladder is itself a candidate ensemble: climatology, NWS-derived model, and (evaluation-only) market-implied probability are three forecasters with meaningfully different information sets. A registered blend of the Lab's own forecasters (climatology + post-processed NWS) with performance-based weights fit walk-forward is a natural V2 artifact — with the ensemble registered _as its own forecaster_ (composition, weighting rule, window — all pre-specified), because an ensemble whose membership is adjusted post hoc is an unregistered forecaster wearing a registered one's name. Combining with the market's probability, by contrast, produces a better _forecast_ but destroys the independence that makes Δ a measurement — the §12.1 echo rule again; a market-blended forecaster can exist only as an explicitly separate, clearly-labeled object, never as the divergence instrument.

---

## 17. Deep Learning

Treated deliberately as _literacy, not toolkit_ for this Lab. The reader needs to understand deep learning because the upstream weather-model ecosystem is made of it and because "why not a neural net?" is a question the Architect will face repeatedly and should be able to answer from principles.

**Multilayer perceptrons** stack affine maps and nonlinearities; depth composes features hierarchically; universal-approximation theorems guarantee expressivity in the limit ⚑ while saying nothing about learnability from finite data — the gap where all the practical difficulty lives. **CNNs** encode translation structure through weight sharing — the inductive bias that made vision tractable and that AI-NWP inherits for gridded atmospheric fields. **RNN/LSTM/GRU**: §10.2. **Attention/Transformers** (§10.3) replace recurrence with content-based routing; **foundation models** scale self-supervised pretraining to internet corpora, exhibiting in-context abilities and (relevant to forecasting) zero-shot time-series models (TimeGPT, Chronos, Moirai ⚑) whose tabular-forecasting performance is promising-but-contested in current literature ⚑.

**Where deep learning wins**: abundant data with exploitable structure (spatial grids, sequences, text), where architecture encodes the right invariances — hence AI-NWP's genuine success (§11.1), operating on decades of gridded reanalysis. **Where simpler models win**: small tabular data — the Grinsztajn/Shwartz-Ziv line of results (§9.5 ⚑), plus every M-competition finding on parsimony. The Lab's supervised problem is a few-thousand-row tabular problem _at best_, years from now. The decision principle, stated once and reusable: **match model capacity to effective sample size and inductive bias to data structure; the Lab has tiny n and tabular structure, so the answer is regularized linear/GBM/GP, and the burden of proof for anything deeper is a pre-registered, multiplicity-counted, walk-forward-validated beat of the boosted baseline.** No such result exists in the vault; until one does, deep learning is upstream-supplier literature.

Two literacy notes with governance relevance: (i) deep models' raw probabilities are characteristically **overconfident** and require temperature scaling (Guo et al., 2017 ⚑) — if the Lab ever consumes a vendor's neural probability product, calibration verification against settlements is mandatory before it touches a registered pipeline; (ii) deep training is **seed-sensitive** — run-to-run variance from initialization alone can exceed claimed method improvements ⚑ — so any deep-learning claim, internal or vendor, that lacks multi-seed evidence is a single anecdote.

---

## 18. Optimization

Optimization is the engine room; its failure modes masquerade as modeling failures.

**Gradient descent** steps along $-\nabla_\theta \hat{R}(\theta)$; convergence for convex objectives is classical, and _convexity is the property to check first_ — ridge, lasso, logistic regression, and linear SVMs are convex (the optimum found is _the_ optimum; optimizer choice affects speed only), while trees are fit by greedy search and neural nets are non-convex (the optimum found is _an_ optimum, entangled with initialization and schedule). **Stochastic gradient descent** uses minibatch gradient estimates — the noise is a feature (escapes saddle points, implicitly regularizes ⚑) and a cost (tuning burden). **Adam** (Kingma & Ba, 2015 ⚑) adapts per-parameter step sizes; robust default for deep nets; known to sometimes generalize worse than tuned SGD in vision ⚑ — a reminder that the optimizer is part of the model's effective prior. **Second-order methods** (Newton, L-BFGS) use curvature; L-BFGS is exactly right for the smooth convex problems at Lab scale, and standard library defaults (e.g., scikit-learn's logistic solvers ⚑) already use it — one of several ways the small-data regime quietly removes whole categories of difficulty.

**Regularization** rejoins optimization to learning theory: an L2 penalty is a Gaussian prior, an L1 penalty a sparsity prior, and **early stopping** is implicit regularization (the optimization path from small weights outward traces a regularization path ⚑). The engineering rule: regularization strength is a hyperparameter _selected by walk-forward validation inside the registered protocol_, never eyeballed on the test period.

The Lab-specific summary: with convex objectives at small scale, optimization is a solved sub-problem, and any observed training instability should be diagnosed first as a _data_ problem (unscaled features, collinearity, separation) rather than an optimizer problem.

---

## 19. Common Failure Modes

The section to reread before every registration. Each failure mode: mechanism, detection, mitigation.

**Overfitting.** Model memorizes noise; train–validation gap large. Detect: learning curves, walk-forward degradation. Mitigate: capacity control, regularization, and _sample-size honesty_ — [[Effective_Sample_Size]] discounting before deciding a validation set is big enough to select on.

**Underfitting.** Bias-dominated; both train and validation error high relative to the irreducible floor. Detect: residual structure (seasonality left in residuals is the classic tell here). Mitigate: features first, capacity second.

**Data leakage.** Information unavailable at prediction time enters training. The whole taxonomy: _feature leakage_ (future-computed features), _selection leakage_ (features/hyperparameters chosen on data that includes the test period — Ambroise & McLachlan ⚑), _preprocessing leakage_ (scalers/imputers fit on full data), _cross-sectional leakage_ (same-date rows across the split), _target leakage_ (a feature that is the label in disguise — e.g., an "observed high so far" field for a day whose max has already occurred). Detection is structural, not vigilant: dual timestamps, as-of joins, and **look-ahead swap tests** (deliberately corrupt a feature with future data; if the pipeline's guards don't catch it, the guards are broken) — D-FV-10 is the standing contract. Kaggle-era lore and replication literature agree that leakage is the leading cause of "too good to be true" results ⚑; the Lab's prior on any dramatic backtest should be _leakage until proven otherwise_ — rung-ordered with the other boring explanations in the A7 triage ladder.

**Concept drift and distribution shift.** The world changes: _covariate shift_ ($p(x)$ moves — new forecast-product version changes feature distributions), _concept drift_ ($p(y|x)$ moves — NWS model upgrades change the error structure the post-processor learned; station instrumentation changes; climate trend shifts the bracket base rates), _prior-probability shift_ (seasonal base-rate swings, guaranteed here). Detect: monitored rolling scores with alarm thresholds (§20), population-stability metrics on features, and — the domain-specific one — **watching upstream announcements**: NWS model transitions are _scheduled, public events_ ⚑ that should enter the vault as dated provenance facts, converting a silent drift into an anticipated regime boundary. Mitigate: rolling retraining windows (registered cadence), version-stamped upstream products, per-regime evaluation.

**Label noise.** Rare here by design — CLI settlement is authoritative — but not zero: report corrections and the Milestone-1b subtleties (11 AM ET delays, DST day-boundaries, F3) mean _provisional vs. final_ settlement values must be distinguished in the schema. A label pipeline that overwrites provisional with final in place violates append-only (Invariant 4); both belong in the record with their ingestion timestamps.

**The meta-failure: researcher degrees of freedom.** Every mitigation above can be silently defeated by trying many variants and reporting the survivor. The only cure is the one the Lab already runs: pre-registration, append-only run logs, and multiplicity-adjusted inference. ML tooling makes trying variants _cheap_; governance makes them _counted_. Both facts are permanent.

---

## 20. Computational Engineering

Production ML is a data-engineering discipline with a model inside. The Lab's advantages: tiny scale (no distributed anything needed), existing governance (most "MLOps" prescriptions are Invariants the vault already has).

**Reproducibility.** A result is reproducible when _code version + data snapshot + environment + seeds_ are jointly sufficient to regenerate it. Concretely: pinned environments (lockfiles), seeds recorded in run metadata, data referenced by snapshot/checksum rather than by "the table" (append-only storage makes as-of reconstruction possible — Invariant 4 doing double duty), and deterministic pipelines wherever feasible. The Experiment template's "environment (versions, seeds, model+date if AI-assisted)" field is exactly this.

**Feature pipelines.** One code path computes features for training, validation, and (eventually) live scoring — dual implementations _will_ skew. Features are computed by as-of queries against the append-only store; the pipeline's unit tests include the look-ahead swap tests of §19.

**Experiment tracking.** Every fitted model run gets a row: config hash, data snapshot ref, seed, scores, artifacts. At Lab scale a SQLite table + committed config files beats heavyweight platforms — and this table _is_ the multiplicity ledger's denominator feed (D-FV-11), which is the deepest reason it must be complete: an untracked experiment is an uncounted hypothesis.

**Hyperparameter optimization.** Grid for ≤2 parameters; random search dominates grid in higher dimensions (Bergstra & Bengio, 2012 ⚑); Bayesian optimization (§8.2) when each evaluation is an expensive walk-forward. Non-negotiables: the search space and budget are pre-specified in the protocol; the search runs inside the outer validation loop (nested validation), never on the final test period; the _entire search_ is one ledgered research act.

**GPU/distributed training.** Not applicable at Lab scale; noted only so its absence is a decision, not an oversight. If AI-NWP inference is ever run locally, that is the one plausible GPU use ⚑.

**Deployment and monitoring.** The V1/V2 "deployment" is a scheduled batch job: features → forecasts → storage, timestamped before market snapshots (issuance-time discipline). Monitoring is score-based and drift-based: rolling log score vs. registered expectation, feature-distribution stability, upstream-product version watch, pipeline-health alarms (ntfy.sh per the ops plan). The alarm philosophy from §6 applies: monitored quantities must be explainable, thresholds registered, alerts triaged through A7's ladder.

**Model governance.** The vault already exceeds industry norms: registration = model cards with teeth; append-only stores = lineage; Architect grading = human-in-the-loop review; ADRs = change management. The one standard MLOps artifact worth adopting explicitly is the **model registry entry**: for each registered forecaster — identity, version, training-data snapshot, feature list, protocol link, registration date, status (active/retired/superseded). A retired forecaster's scores remain in the record forever (append-only); retirement is a status, not a deletion.

---

## 21. Machine Learning for Autonomous Trading

_V3-horizon. This section defines the shape of the eventual system and the trust boundaries — it authorizes nothing._

### 21.1 The pipeline decomposition

The defensible architecture separates concerns so each is independently verifiable:

1. **Signal generation / probability estimation** — the registered forecaster (§5, §11). _ML-appropriate, and the only stage where ML is load-bearing._ Its verification story is complete: proper scores against settlements, calibration diagnostics, population-level comparison to market.
2. **Edge validation** — statistics, not ML ([[Edge_Detection_v4]], A1). ML has no role; this stage exists to discipline stage 1's outputs.
3. **Portfolio construction / sizing** — _derived_, not learned: fractional Kelly from validated probabilities ([[Kelly_Criterion]]), with correlation handling for simultaneous city-day exposures (five same-day positions are not five independent bets — the [[Effective_Sample_Size]] logic, now in P&L space) and hard registered constraints (max exposure per market/day/city).
4. **Risk management** — rule-based and boring by design: exposure caps, drawdown triggers, kill switches, anomaly-triggered halts. **Never learned.** A risk layer must fail predictably; learned components fail creatively.
5. **Execution** — cost/fill modeling (§12.3) informing limit placement. Modest ML admissible (fill-probability models) because per-order data accrues faster than per-settlement data and errors are bounded by order size.

### 21.2 Online, adaptive, and continual learning

**Online learning** updates models per-observation, with regret guarantees from adversarial analysis (online convex optimization ⚑) — theoretically elegant, and governance-hostile in raw form: a continuously mutating model is unregisterable. The reconcile: **discrete registered updates** — scheduled retrains under a pre-specified rule ("refit monthly on trailing 24 months") make the _update policy_ the registered object, auditable and reproducible, capturing most adaptation value. Truly continual within-registration adaptation should be confined to slow-moving, low-risk components (e.g., a bias-correction intercept with registered update dynamics — a Kalman-style state, §10.1, whose update rule is itself the fixed, registered thing). **Continual learning**'s catastrophic-forgetting literature ⚑ is largely a big-model problem; at Lab scale, full retrains are cheap and forgetting is solved by retraining on all data.

### 21.3 Where ML should and should not be trusted — the summary table

|Stage|ML role|Why|
|---|---|---|
|Probability estimation|**Core**|Verifiable against settlements at population scale|
|Edge validation|None|Statistics' job; ML here = self-grading|
|Sizing|None (derived)|Kelly is the solved decision theory; learning it re-derives it badly from tiny data|
|Risk limits|**Never**|Must fail predictably|
|Execution modeling|Modest|Bounded errors, faster data accrual|
|Monitoring/anomaly|Simple methods only|Alarms must be explainable|

The principle underneath the table: **trust ML in proportion to the verifiability of its output, not the sophistication of its method.** Probability estimates are verifiable in months at Lab accrual rates; policy quality is verifiable in years if ever. Allocate ML to the verifiable stages, and let derivation and rules cover the rest.

---

## 22. Current Research Frontiers

Tracked for consumption and threat-awareness, not adoption. Each entry: what it is, current status ⚑ (all frontier characterizations are dated to this document's writing and decay quickly), Lab relevance.

**Foundation models & probabilistic transformers.** Zero-shot time-series foundation models (Chronos, TimesFM, Moirai, TimeGPT ⚑) and distribution-emitting architectures. Status: rapid progress, contested tabular/one-series performance ⚑. Lab relevance: cheap challenger baselines someday; also _competition_ — if such tools sharpen retail forecasting broadly, market prices sharpen, and measured Δ shrinks. Edge is adversarial and decays (McLean & Pontiff's post-publication decay finding, imported from equities ⚑).

**AI-NWP evolution.** Ensemble/probabilistic AI weather (GenCast-class ⚑), km-scale models, direct-from-observation forecasting bypassing reanalysis ⚑. The single frontier most likely to change the Lab's _inputs_ materially. Watch: extremes fidelity (bracket tails), station-level (vs. grid) skill, access terms.

**Causal ML.** Pearl's do-calculus meeting ML (invariant risk minimization, causal discovery ⚑). Lab relevance today: conceptual hygiene — the forecaster predicts under observation; V3 acts on the market; small size keeps the intervention effect negligible, but the assumption "our trading does not move the price we measure" is a _causal_ assumption that should be recorded as such, with a size threshold that would invalidate it.

**Uncertainty-aware AI.** Conformal prediction is the standout: distribution-free finite-sample coverage guarantees for prediction sets (Vovk et al. ⚑; Angelopoulos & Bates tutorial ⚑), with time-series adaptations (adaptive conformal ⚑) weakening the exchangeability requirement. Directly relevant as a _wrapper_ giving guaranteed-coverage temperature intervals alongside the parametric predictive distribution — a cheap, registrable honesty check. Strongest near-term adoption candidate in this section ⚑.

**RL for finance.** Execution and market-making papers accumulate ⚑; reproducibility and sim-to-real gaps remain the field's own acknowledged weakness ⚑. Lab posture: §7.3 stands.

**Online/continual learning.** Regret-bounded adaptation, drift-aware training. Relevance via §21.2's registered-update-policy reconciliation.

**Retrieval-augmented learning.** Predictions conditioned on retrieved analogs — intriguingly close to the meteorological _analog method_, one of forecasting's oldest ideas ⚑. A GP or kernel view already gives the Lab this flavor without new machinery.

**Physics-informed ML.** Physics constraints as losses/architecture (PINNs ⚑); hybrid physics-ML forecasting. Upstream-relevant (better NWP), not Lab-buildable.

**Unresolved problems the literature admits to** (all ⚑): why overparameterized models generalize (benign overfitting/double descent — theory incomplete); reliable UQ for deep nets (ensembles as embarrassing SOTA); distribution-shift robustness without shift examples; benchmark overfitting at the community level (the field's own multiplicity crisis, unledgered).

---

## 23. Connections to Other Research Lab Documents

This section makes the import/export structure explicit, in both directions, so contradictions are findable by search.

**[[Probability]]** — _imports_: conditional probability, expectation and its laws, exchangeability, the population-grading principle ("a probability is a claim about a population"). _Exports back_: nothing; Probability is upstream canon. Every $p(y \mid x)$ in this document is a Probability-§ conditional distribution; ML adds only the estimation machinery.

**[[Bayesian_Statistics]]** — _imports_: priors, posteriors, predictive distributions, MCMC/VI diagnostics, model comparison via evidence. _This document adds_: the ML-specific instantiations (GPs, BNNs, Bayesian optimization) and the doctrinal mapping from epistemic uncertainty to fractional Kelly (§8.1). Where treatments overlap, [[Bayesian_Statistics]] governs inference; this note governs application.

**[[Expected_Value]]** — the bridge object: a calibrated $\hat{p}$ from §5/§15 plus contract prices yields EV per [[Expected_Value]]'s machinery; miscalibration enters EV calculations as a systematic bias, which is why §15 sits upstream of any EV claim.

**[[Kelly_Criterion]] and [[Log_Score_and_Kelly_Identity]]** — the identity is this document's economic north star: expected log-score improvement over market prices _equals_ expected Kelly log-growth (gross of costs). Consequences flowing back into ML practice: the training/registered-primary score should be the log score (coherence between what is optimized, what is verified, and what compounds); epistemic uncertainty motivates fractional sizing; and model comparison in log-score units is directly interpretable as growth-rate difference.

**[[Proper_Scoring_Rules_and_Calibration_-_Technical_Reference]]** — owns propriety theory; this document consumes it as the non-negotiable constraint on training objectives (§5.2) and evaluation metrics (§14.2).

**[[Forecast_Verification]]** — the governing document for everything in §14–§15; the D-FV directives cited throughout (D-FV-3 score governance, D-FV-4 boundary rule, D-FV-6 outcome-conditioning inadmissibility, D-FV-7 normalization registration, D-FV-8 calibration reporting, D-FV-9 discrete PIT, D-FV-10 leakage contracts, D-FV-11 multiplicity ledger) are binding on every ML artifact this document contemplates. Where this note and Forecast Verification differ in emphasis, Forecast Verification governs.

**[[Edge_Detection_v4]]** — consumes the forecasters this document describes and applies the edge-vs-disagreement discipline (§12.2); the multiplicity ledger it maintains is fed by §20's experiment tracking.

**[[Prediction_Markets]]** — owns market mechanics, microstructure, normalization methods, and the favorite–longshot canon; §12 is the ML-facing adapter to that document.

**[[Effective_Sample_Size]]** — the quiet load-bearer: appears in this document at every point where "n" is written (validation-set sufficiency §14, calibration-set sufficiency §15.2, cross-city correlation §14.1, simultaneous-position sizing §21.1). Any sample-size argument in an ML registration should cite it.

**Weather forecast model documents ([[National_Weather_Service]], [[NOAA]])** — supply the provenance facts (products, issuance schedules, station identities, model-transition histories) that §13's features and §19's drift monitoring depend on. F1's lesson (CLI product ≠ raw obs) is the template for the precision required when an ML feature claims to "be" an NWS quantity.

**Statistical learning theory and decision theory** — no dedicated vault notes exist yet ⚑; §3 of this document is the interim home for the former, and [[Expected_Value]] + [[Kelly_Criterion]] jointly cover the operative fragment of the latter. If either topic earns a dedicated note later, this section is the seam to update.

---

## 24. Practical Engineering Guidelines

Consolidated implementation guidance, phrased to be actionable at the current milestone horizon. Items marked **[directive candidate]** are proposed for A-series ratification; nothing here self-ratifies.

### 24.1 Algorithm selection by problem characteristics

Select by regime, not popularity. The decision procedure:

1. **Count effective n** (date-blocked, autocorrelation-discounted). Under ~1,000 effective observations: regularized linear/logistic, GP, or classical time-series structure. 1,000–10,000: add gradient boosting to the candidate set. Only beyond that does anything deeper enter the conversation, and tabular structure still argues against it (§17).
2. **Identify the output object.** Bracket probabilities → distributional regression over $T_{max}$ first (coherence for free), direct categorical second as robustness check (§5.1).
3. **Name the inductive bias.** Seasonality, station effects, lead-time dependence, forecast-anchoring — encode known structure as features/kernels rather than hoping capacity discovers it.
4. **Fix the baseline ladder before fitting anything**: climatology → persistence-augmented climatology → raw NWS product → post-processed NWS (EMOS-class) → challenger. Each rung must beat the previous _out-of-sample, walk-forward, multiplicity-counted_ to justify its complexity. **[directive candidate]**
5. **Pre-commit the search budget**: model families, hyperparameter spaces, feature sets, and number of runs, written down before the first fit. **[directive candidate]**

### 24.2 The probabilistic forecasting pipeline (reference shape)

```
append-only store ──as-of query──► feature builder ──► model (registered) ──► predictive distribution
      ▲                                  │                                          │
  ingestion                     look-ahead swap tests                       bracket integration
  (dual timestamps)                     (CI)                                        │
                                                                            calibration layer
                                                                       (versioned, own registration)
                                                                                    │
                                                                        forecast log (timestamped
                                                                        BEFORE market snapshot)
                                                                                    │
                                                                     verification (D-FV suite, A1)
```

Properties the shape enforces: one feature code path; issuance-time discipline (forecasts logged before the market state they will be compared to); recalibration as an explicit, separately-registered stage; verification outside the model's own loop.

### 24.3 Production infrastructure, Lab-sized

SQLite + WAL, scheduled batch jobs, committed configs, seeds in run metadata, lockfiled environments, experiment rows in a tracked table, CI running the leakage swap tests, score-and-drift monitors with registered thresholds alerting via ntfy.sh. Explicitly rejected at this scale, as decisions: GPU infrastructure, distributed training, streaming feature stores, model-serving platforms, continuous (per-observation) model mutation. Simplicity here is not a compromise; it is the verifiability budget being spent where it pays.

### 24.4 Model governance and continuous retraining

- One registry entry per registered forecaster (§20's schema); status transitions are append-only events.
- Retraining is a **policy, registered once** — cadence, window, trigger conditions — not a per-instance judgment call. Each retrain instance logs its snapshot refs and produces a _new version_ scored from its own effective date (the recalibration rule generalized). **[directive candidate]**
- Upstream product versions (NWS model transitions, product format changes) are first-class dated facts in the vault; every trained model records which upstream versions its training window spans.
- Monitoring verdicts route through the A7 triage ladder before anyone says "drift," and _certainly_ before anyone says "edge decay."

### 24.5 Validation and monitoring, consolidated

Walk-forward with purge gaps, date-blocked everywhere; nested search inside outer validation; log score primary per D-FV-3; calibration per D-FV-8/9; every comparison through A1's inference machinery; every run in the ledger. If a proposed evaluation shortcut conflicts with any of these, the shortcut loses.

---

## 25. Engineering Takeaways

The distillation. Each principle earned its place somewhere above.

1. **Match capacity to effective sample size; encode structure as bias, not capacity.** The Lab's n is small and will stay small in wall-clock terms; parsimony is not a style preference, it is arithmetic (§3.4, §17).
2. **The predictive distribution is the product.** Point forecasts and class labels are lossy projections of the object every downstream consumer — EV, Kelly, verification — actually needs (§5.2).
3. **Train, select, and verify on proper scores; let the log score be primary end-to-end.** Coherence between objective, evaluation, and economics is free alignment; incoherence is a standing source of subtle bugs (§14.2, §23-Kelly).
4. **Calibration is verified, never assumed — and a recalibrated model is a new model.** No model family guarantees calibration; several reliably violate it in known directions (§9, §15, §17).
5. **The market is the baseline, and beating baselines is a statistical claim.** Δ is an observation; edge is an inference that must survive DM-class testing, multiplicity accounting, and costs (§12).
6. **Leakage is the default explanation for good news.** Structural defenses (dual timestamps, as-of joins, swap tests, purged walk-forward) beat vigilance; dramatic backtests are guilty until proven innocent (§19).
7. **Every experiment is a hypothesis; count them all.** Untracked runs are unledgered multiplicity — the experiment tracker is an epistemic instrument, not bookkeeping (§20, D-FV-11).
8. **Ensembles win through diversity; simple combination rules win through estimability.** Equal or performance weights, fit walk-forward, registered as their own forecaster (§16).
9. **Trust ML in proportion to output verifiability.** Probabilities are verifiable monthly; policies are verifiable never-soon. Learn the forecast; derive the decision; hard-code the risk limits (§21).
10. **Uncertainty has two kinds, and the epistemic kind prices the model's own ignorance.** It is the mathematically honest basis for fractional Kelly and the reason Bayesian/GP machinery earns its complexity at small n (§8).
11. **Simplicity is a reliability technology.** Every component removed is a failure mode, a leak path, and a multiplicity source removed. The boring stack is the strong stack (§20, §24.3).
12. **Common mistakes, named for the checklist**: accuracy as a primary metric; random splits on time series; scalers fit on full data; features selected before the fold; validation reused until it becomes training; regime definitions chosen after seeing regimes; the best of 40 runs reported as the estimate; market prices leaking into the "independent" forecaster; a risk limit implemented as a model.

---

## 26. Annotated Bibliography

Ranked within tiers. **[Essential]** = core reading for any quantitative researcher or engineer on this project. All bibliographic details ⚑ (editions/years to be verified at acquisition; graded per §3.2's source tiers on entry).

### Tier 1 — Foundational texts

- **Hastie, Tibshirani & Friedman, _The Elements of Statistical Learning_ (2nd ed., 2009)** ⚑ **[Essential]** — The canonical statistical treatment of supervised learning; the bias–variance, regularization, boosting, and validation chapters are the direct scholarly backing for §3, §9, §14. Freely available from the authors ⚑.
- **Bishop, _Pattern Recognition and Machine Learning_ (2006)** ⚑ **[Essential]** — The probabilistic synthesis; best single source for the Bayesian view of standard models (§8–§9).
- **Murphy, K., _Probabilistic Machine Learning: An Introduction_ (2022) and _Advanced Topics_ (2023)** ⚑ — The modern encyclopedic replacement/complement to Bishop; use as reference, not cover-to-cover.
- **MacKay, _Information Theory, Inference, and Learning Algorithms_ (2003)** ⚑ **[Essential]** — The information-theoretic unification (§2); the Occam/evidence chapters justify this Lab's parsimony doctrine from first principles. Freely available ⚑.
- **Vapnik, _The Nature of Statistical Learning Theory_ (2nd ed., 2000)** ⚑ — The primary source for §3; read after ESL's gentler treatment.
- **Sutton & Barto, _Reinforcement Learning: An Introduction_ (2nd ed., 2018)** ⚑ — Canonical RL; required literacy for §7/§21 even under this Lab's RL-skeptical posture. Freely available ⚑.
- **Rasmussen & Williams, _Gaussian Processes for Machine Learning_ (2006)** ⚑ **[Essential given §8.2's shortlisting]** — The GP bible; freely available ⚑.
- **Gelman et al., _Bayesian Data Analysis_ (3rd ed., 2013)** ⚑ — Bridges to [[Bayesian_Statistics]]; the workflow chapters inform §8.4.

### Tier 2 — Forecasting and verification (closest to Lab practice)

- **Gneiting & Raftery, "Strictly Proper Scoring Rules, Prediction, and Estimation," _JASA_ (2007)** ⚑ **[Essential]** — The propriety synthesis; co-canonical with [[Proper_Scoring_Rules_and_Calibration_-_Technical_Reference]].
- **Gneiting, Raftery, Westveld & Goldman, "Calibrated Probabilistic Forecasting Using Ensemble MOS and Minimum CRPS Estimation," _Monthly Weather Review_ (2005)** ⚑ **[Essential]** — EMOS/NGR; the genre-defining paper for the V2 forecaster (§11.1).
- **Raftery et al., "Using Bayesian Model Averaging to Calibrate Forecast Ensembles," _MWR_ (2005)** ⚑ — The BMA post-processing alternative.
- **Murphy, A.H., "What Is a Good Forecast?," _Weather and Forecasting_ (1993)** ⚑ **[Essential]** — The three-goodness framework; short, permanent.
- **Hamill, "Hypothesis Tests for Evaluating Numerical Precipitation Forecasts," _Weather and Forecasting_ (1999)** ⚑ — Small-sample verification caution; the spiritual ancestor of the decidability discipline.
- **Wilks, _Statistical Methods in the Atmospheric Sciences_ (4th ed., 2019)** ⚑ — The domain's methods handbook; MOS, verification, and post-processing chapters.
- **Makridakis, Spiliotis & Assimakopoulos, "The M4 Competition: Results, Findings, Conclusion" (2020) and the M5 papers (2022)** ⚑ — The empirical record behind §10.1's humility and §16's combination findings.
- **Diebold & Mariano, "Comparing Predictive Accuracy," _JBES_ (1995)** ⚑ — The comparison test A1 builds on; read with Diebold's 2015 retrospective ⚑.

### Tier 3 — Algorithms and methods (primary sources)

- **Breiman, "Random Forests," _Machine Learning_ (2001)** ⚑ — And read alongside: Breiman, "Statistical Modeling: The Two Cultures" (2001) ⚑, the essay version of this document's central tension.
- **Friedman, "Greedy Function Approximation: A Gradient Boosting Machine," _Annals of Statistics_ (2001)** ⚑ **[Essential]** — The boosting framework §9.5 rests on; Chen & Guestrin's XGBoost paper (2016) ⚑ for the modern implementation.
- **Grinsztajn, Oyallon & Varoquaux, "Why Do Tree-Based Models Still Outperform Deep Learning on Tabular Data?" (NeurIPS 2022)** ⚑ — The load-bearing empirical citation for §17's verdict; verify against the current literature before it becomes load-bearing, as this is an active research question ⚑.
- **Niculescu-Mizil & Caruana, "Predicting Good Probabilities with Supervised Learning" (ICML 2005)** ⚑ **[Essential]** — The calibration-by-model-family map behind §9's per-family calibration notes.
- **Guo et al., "On Calibration of Modern Neural Networks" (ICML 2017)** ⚑ — Overconfidence and temperature scaling.
- **Platt (1999); Zadrozny & Elkan (2002); Kull, Silva Filho & Flach (2017)** ⚑ — The recalibration method trio of §15.2.
- **Wolpert, "Stacked Generalization" (1992); Bates & Granger, "The Combination of Forecasts" (1969); Yao et al., "Using Stacking to Average Bayesian Predictive Distributions" (2018)** ⚑ — The combination literature of §16.
- **Lakshminarayanan et al., "Simple and Scalable Predictive Uncertainty Estimation Using Deep Ensembles" (NeurIPS 2017); Ovadia et al., "Can You Trust Your Model's Uncertainty?" (NeurIPS 2019)** ⚑ — Deep UQ status per §8.3.
- **Angelopoulos & Bates, "A Gentle Introduction to Conformal Prediction" (2023)** ⚑ — Entry point for §22's strongest adoption candidate.
- **Hochreiter & Schmidhuber (1997); Vaswani et al. (2017); Lim et al., TFT (2021); Zeng et al. (2023)** ⚑ — The sequence-modeling arc of §10, including its deflationary endpoint.

### Tier 4 — Finance, markets, and validation discipline

- **López de Prado, _Advances in Financial Machine Learning_ (2018)** ⚑ — Purged cross-validation, backtest overfitting, deflated performance metrics; read as a catalogue of ways financial ML lies to its authors. Tier-4 practitioner source; claims individually verifiable.
- **Harvey, Liu & Zhu, "…and the Cross-Section of Expected Returns," _RFS_ (2016); McLean & Pontiff, "Does Academic Research Destroy Stock Return Predictability?," _JF_ (2016)** ⚑ **[Essential]** — The multiplicity crisis and post-publication decay, empirically; the standing prior of §12.4 and §22.
- **Wolfers & Zitzewitz, "Prediction Markets," _JEP_ (2004)** ⚑ — Survey bridge to [[Prediction_Markets]]'s primary literature.
- **Hanson, "Combinatorial Information Market Design" (2003, LMSR)** ⚑; **Avellaneda & Stoikov (2008)**; **Almgren & Chriss (2001)** ⚑ — The §12.3 market-making/execution shelf; V3-horizon.

### Tier 5 — Historical and conceptual

- **Turing, "Computing Machinery and Intelligence," _Mind_ (1950)** ⚑; **Samuel, "Some Studies in Machine Learning Using the Game of Checkers," _IBM Journal_ (1959)** ⚑; **Pearl, _Causality_ (2nd ed., 2009)** ⚑; **Rumelhart, Hinton & Williams, "Learning Representations by Back-Propagating Errors," _Nature_ (1986)** ⚑.

**Acquisition priority for the Lab, if reading time is the constraint** ⚑: Gneiting & Raftery (2007) → EMOS (2005) → Murphy (1993) → Niculescu-Mizil & Caruana (2005) → ESL chapters 2, 3, 7, 10, 15 → Harvey/Liu/Zhu (2016) → MacKay chapters 28 (Occam) and 36–37 → Rasmussen & Williams chapters 1–2, 5. That sequence covers the verification spine, the model canon, the multiplicity discipline, and the small-data toolkit, in that order of urgency.

---

_End of document. Version 1.0 — E4 testimony pending Architect verification. All ⚑ flags outstanding; none of this document's specific attributions, dates, or empirical claims is load-bearing until individually verified per Invariant 3._