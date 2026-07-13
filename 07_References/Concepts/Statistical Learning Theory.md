title: "Statistical Learning Theory — Technical Reference" aliases:

- SLT
- Statistical Learning Theory
- Learning Theory
- Generalization Theory vault_location: "07_References/Concepts" level: "Quantitative researcher reference (assumes probability theory, basic linear algebra, familiarity with the vault's scoring and verification corpus)" status: "E4 — AI-drafted testimony, ungraded pending Architect verification per Invariant 3; NOT canonical until ratified" version: "1.0" created: 2026-07-12 review: 2027-01-12 tags: [statistical-learning-theory, generalization, vc-dimension, pac-learning, regularization, cross-validation, machine-learning, forecasting, prediction-markets, canon-candidate]

---

# Statistical Learning Theory — Research Synthesis

**Vault location:** `07_References/Concepts` **Level:** Quantitative researcher reference. Sits directly beneath [[Machine_Learning]] in the dependency graph: that document is the _engineering_ reference for learning from data; this one is the _mathematical_ reference for why learning from data works at all. **Cross-links:** [[Probability]] · [[Bayesian_Statistics]] · [[Information_Theory_for_Forecasting]] · [[Machine_Learning]] · [[Proper_Scoring_Rules_and_Calibration_-_Technical_Reference]] · [[Forecast_Verification]] · [[Prediction_Markets]] · [[Edge_Detection_v4]] · [[Market_Microstructure]] · [[Weather_Forecast_Models]] · [[Expected_Value]] · [[Kelly_Criterion]] · [[Effective_Sample_Size]] · [[Log_Score_and_Kelly_Identity]] · [[Glossary]] **Status:** Version 1 — draft, **E4** (AI-drafted testimony), ungraded pending Architect verification and canonization (Invariant 3) **Created:** 2026-07-12

> [!warning] Epistemic status (Invariant 3) This document is AI-drafted testimony, not evidence. It is a literature synthesis produced from model knowledge without live retrieval. The core mathematics (decompositions, definitions, the schematic form of the classical bounds) is textbook-stable and the lowest-risk layer; **every specific attribution, publication year, named theorem constant, and empirical claim carries an implicit ⚑ and must be verified against primary sources before any becomes load-bearing in a registration, ADR, or graded analysis.** ★ marks the priority verification tier — entries that would feed A1 (Statistical Validity & Inference Framework) or a registered model-selection convention. Canonizing this document does **not** discharge individual ⚑ flags. Where this document and any ratified A-series artifact disagree, the A-series artifact governs.

> [!info] Ownership boundaries (single-home convention) This document **owns** the vault's generalization-theory layer: empirical vs. expected risk, uniform convergence, capacity measures (VC dimension, Rademacher complexity, and relatives), ERM/SRM, PAC learning, the theory of regularization and of cross-validation as estimators. Upon ratification, [[Machine_Learning]] §3 ("The statistical learning frame") becomes a _summary_ that defers here for depth; the two must not drift — a ⚑ maintenance flag is raised on that section pending the handoff edit. This document **does not own**: scoring-rule orientation, units, and clipping ([[Proper_Scoring_Rules_and_Calibration_-_Technical_Reference]]); verification inference, Murphy decomposition, DM-style tests ([[Forecast_Verification]]); the information-theoretic vocabulary itself ([[Information_Theory_for_Forecasting]]); algorithm engineering and deployment posture ([[Machine_Learning]]); statistical inference conventions for the Lab (**A1**, once ratified); bet sizing ([[Kelly_Criterion]], V3-gated).

> [!note] Scope guard (V-gate discipline) Nothing in this document authorizes model-building beyond what the roadmap gates permit. V1 is a measurement instrument; the learning theory here informs _how the V2 forecaster will be selected, regularized, and validated_ and _why the Lab's sample-size discipline is not optional_. Sections touching trading-system learning (§17, parts of §22) are V3-horizon literature context. Engineering directives in §23 and the D-series proposals at the end are **proposals pending Architect ratification**.

> [!note] The one-sentence version Statistical learning theory is the mathematical answer to a single question: _when does performance on the data you have predict performance on the data you have not seen?_ Everything in this document — capacity, regularization, validation, evaluation — is machinery for making that inference honest. It is the same question the Lab asks of a forecaster ("is this skill or luck?") and the same question [[Edge_Detection_v4]] asks of a divergence ("is this edge or noise?"), stated at the level of models rather than claims.

---

## 1. Historical Development

Dates and attributions in this section are conventional and flagged ⚑ as a block; as in [[Machine_Learning]] §1, the arc is the load-bearing content, not the chronology.

### 1.1 Fisher and the pre-history: inference before prediction

**Ronald Fisher** (1920s–1930s ⚑) built the edifice this field later had to partially dismantle: maximum likelihood, sufficiency, the analysis of variance, experimental design. Fisher's program was _inference_ — recovering the parameters of an assumed data-generating mechanism — and its success was so complete that for half a century "statistics" meant parametric inference under a correctly specified model. Two Fisherian commitments matter for this document's story. First, the likelihood principle concentrated attention on _in-sample fit_ as the criterion of quality. Second, the assumed-model framework left no native vocabulary for the question SLT would later ask: _what happens when the model class does not contain the truth and the criterion is out-of-sample prediction?_ Fisher also, in fairness, seeded the answer: his work on discriminant analysis (1936 ⚑) is arguably the first supervised classification method, and his insistence on randomization anticipates the i.i.d. sampling assumptions on which all classical learning bounds rest.

### 1.2 Geisser and the predictivist turn

**Seymour Geisser** (from the 1970s ⚑) is the under-credited hinge. His "predictive sample reuse" papers (Geisser 1975 ⚑; Stone 1974 ⚑ independently and near-simultaneously — the standard joint attribution for cross-validation ★) argued that the proper target of statistical analysis is the _observable future_, not the unobservable parameter. Predict, then check the prediction: parameters are scaffolding. This predictivist stance — Geisser's _Predictive Inference_ (1993 ⚑) is its book-length statement — is philosophically the closest ancestor of the Lab's own methodology: a probability is graded against realized outcomes over a population ([[Probability]]), not against agreement with a theory. Cross-validation, now the workhorse of applied model selection (§11), entered statistics as an expression of this philosophy, not as an engineering trick.

### 1.3 Vapnik, Chervonenkis, and the mathematics of generalization

Working in Moscow from the late 1960s ⚑, **Vladimir Vapnik** and **Alexey Chervonenkis** asked the question that gives this document its subject: _under what conditions does minimizing error on a finite sample control error on the underlying distribution — uniformly over a class of candidate models?_ Their 1971 paper ⚑ ★ on the uniform convergence of relative frequencies established that the answer is governed not by the number of parameters but by a combinatorial capacity measure — the VC dimension (§8). The theory matured over two decades into structural risk minimization (§7) and, constructively, the support vector machine (Boser, Guyon & Vapnik 1992 ⚑; Cortes & Vapnik 1995 ⚑). Vapnik's _The Nature of Statistical Learning Theory_ (1995, 2nd ed. 2000 ⚑) and the encyclopedic _Statistical Learning Theory_ (1998 ⚑) are the canonical statements. The philosophical core, stated repeatedly by Vapnik, is worth engraving: **do not solve a harder problem than you need to as an intermediate step**. Estimating a full density in order to make a binary decision wastes sample on structure the decision never uses. The Lab's analogue: the V1 instrument measures divergence; it does not need, and should not build, a full generative model of the atmosphere to do so.

### 1.4 Valiant and computational learning theory

**Leslie Valiant's** 1984 paper ⚑ ★ "A Theory of the Learnable" founded PAC learning (§9) by adding computation to the statistical question: a class is learnable only if a _polynomial-time_ algorithm achieves the statistical guarantee. This fused learning theory with complexity theory and produced boosting as its most consequential practical offspring: Schapire's 1990 proof ⚑ that weak learnability implies strong learnability was an existence theorem that Freund & Schapire's AdaBoost (1997 ⚑) made algorithmic — theory generating practice in the cleanest example the field owns.

### 1.5 Breiman and the two cultures

**Leo Breiman** — probabilist turned consultant turned Berkeley statistician — supplied both the field's most successful algorithms (CART, 1984 ⚑; bagging, 1996 ⚑; random forests, 2001 ⚑) and its most famous provocation. "Statistical Modeling: The Two Cultures" (2001 ⚑ ★) contrasted the _data-modeling culture_ (assume a stochastic model, do inference — Fisher's descendants) with the _algorithmic-modeling culture_ (treat the mechanism as unknown, judge by predictive accuracy — Vapnik's and Geisser's descendants) and argued the profession's near-exclusive commitment to the former had made it irrelevant to the largest problems. The essay reads today as a victory speech delivered before the victory: predictive accuracy on held-out data is now the default criterion across the sciences. The Lab sits deliberately _between_ the cultures: algorithmic in judging forecasters by out-of-sample score, data-modeling in demanding interpretable, verifiable claims about why any edge exists.

### 1.6 The synthesizers: Hastie, Tibshirani, Friedman, Jordan, Murphy

The 2000s consolidated. **Hastie, Tibshirani & Friedman's** _The Elements of Statistical Learning_ (2001, 2nd ed. 2009 ⚑) unified the statistics and machine-learning literatures under one notation and one criterion — expected prediction error — and its treatment of model selection (Ch. 7 ⚑) remains the standard applied reference for §11's material. Tibshirani's lasso (1996 ⚑) and Friedman's gradient boosting (2001 ⚑) made regularization and stagewise fitting central practice. **Michael Jordan's** school connected graphical models, variational inference, and Bayesian nonparametrics to the learning-theory tradition, arguing the frequentist/Bayesian split is largely a division of labor rather than a war (§15). **Kevin Murphy's** textbooks (2012; 2022–2023 ⚑) are the current encyclopedic synthesis under an explicitly probabilistic unification: learning as posterior inference, prediction as posterior predictive computation.

### 1.7 The modern rupture and repair

Deep learning broke the classical bounds' _quantitative_ authority — networks with parameters vastly exceeding sample counts generalize anyway (Zhang et al. 2017 ⚑, "Understanding deep learning requires rethinking generalization" ★) — and the field's active frontier (§22) is the repair: margin and norm-based bounds, PAC-Bayes, algorithmic stability, implicit regularization of SGD, benign overfitting, double descent (Belkin et al. 2019 ⚑). The classical theory's _qualitative_ authority survives intact, and for the Lab's regime it is not merely qualitative: at ~150 city-days/month, the sample sizes are exactly those for which the classical worst-case theory was built, and the modern exceptions (massive overparameterization on massive data) are the regime the Lab will never occupy.

---

## 2. What Is Statistical Learning?

### 2.1 The formal problem

There is an unknown probability distribution D\mathcal{D} D over pairs (x,y)∈X×Y(x, y) \in \mathcal{X} \times \mathcal{Y} (x,y)∈X×Y. A learner receives a finite sample S={(x1,y1),…,(xn,yn)}S = \{(x_1, y_1), \ldots, (x_n, y_n)\} S={(x1​,y1​),…,(xn​,yn​)} drawn i.i.d. from D\mathcal{D} D, a **hypothesis class** H\mathcal{H} H of candidate functions h:X→Yh: \mathcal{X} \to \mathcal{Y} h:X→Y (or, for probabilistic forecasting, h:X→Δ(Y)h: \mathcal{X} \to \Delta(\mathcal{Y}) h:X→Δ(Y), distributions over outcomes), and a **loss function** ℓ(h(x),y)\ell(h(x), y) ℓ(h(x),y) measuring the cost of predicting h(x)h(x) h(x) when the truth is yy y. The learner outputs h^∈H\hat{h} \in \mathcal{H} h^∈H. Quality is the **risk** (expected loss on a fresh draw):

R(h)=E(x,y)∼D[ℓ(h(x),y)].R(h) = \mathbb{E}_{(x,y) \sim \mathcal{D}}\big[\ell(h(x), y)\big].R(h)=E(x,y)∼D​[ℓ(h(x),y)].

Everything in this document is commentary on the gap between R(h^)R(\hat{h}) R(h^) — which is what matters and is unobservable — and quantities computable from SS S.

**Supervised learning** is the above: labeled pairs, learn the input–output relation. The Lab's V2 forecaster is supervised learning with xx x = (NWP/NBM-derived features, station, date covariates), yy y = settled bracket outcome or realized CLI maximum temperature, and ℓ\ell ℓ = a proper scoring rule ([[Proper_Scoring_Rules_and_Calibration_-_Technical_Reference]]). **Unsupervised learning** receives only xix_i xi​ and seeks structure — density estimation, clustering, dimension reduction. It is theoretically harder to even _pose_ (no ground truth means no risk in the supervised sense) and plays a supporting role for the Lab at most: exploratory structure-finding whose outputs are hypotheses for registration, never findings.

### 2.2 Inference vs. prediction

Statistical **inference** asks: what is the parameter θ\theta θ of the mechanism that generated the data? Statistical **prediction** asks: what will the next observation be? The distinction is not pedantic. Inference presumes the model class contains (or usefully approximates) the truth and evaluates procedures by fidelity to θ\theta θ; prediction makes no such presumption and evaluates by realized loss. A misspecified model can be excellent for prediction (ridge regression deliberately biases θ^\hat{\theta} θ^ to predict better) and a faithful inference can predict poorly (an unbiased estimate with enormous variance). Shmueli's "To Explain or to Predict?" (2010 ⚑) is the standard modern statement. The Lab is a _prediction_ shop with an _inference_ conscience: forecasters are graded purely by predictive score, but every claim of edge is an inferential claim about a population parameter (the expected score gap) and must be tested as one — this dual identity is precisely why A1 blocks A2 and A4.

### 2.3 Learning from finite samples

The defining constraint of the entire field is finiteness. With infinite data, empirical frequencies are probabilities, empirical risk is risk, and there is nothing to prove. With finite data, three quantities compete: the **sample size** nn n, the **capacity** of H\mathcal{H} H, and the achievable **precision** of any statement about RR R. The fundamental trade — capacity purchased only in proportion to n\sqrt{n} n​, precision improving only as 1/n1/\sqrt{n} 1/n​ — recurs in every section below. For the Lab this is not an abstraction: nn n is city-days, city-days accrue at a fixed wall-clock rate (~150/month across five cities, fewer after [[Effective_Sample_Size]] corrections for spatial and temporal dependence), and the accrual clock is therefore the binding constraint on every learning-theoretic guarantee the Lab can ever hold.

### 2.4 Theory vs. engineering

Statistical learning _theory_ answers: what is achievable in principle, under what assumptions, with what guarantees? Machine learning _engineering_ answers: what works on this dataset with this compute budget by Friday? [[Machine_Learning]] is the vault's engineering document. This one is the theory document, and the division of labor is deliberate: theory tells the Lab which engineering shortcuts are safe (early stopping is principled — it is SRM, §7) and which are self-deception (selecting the best of forty backtests and reporting its p-value — the capacity of the _search_ is what generalizes, §8.4). When theory and benchmark practice conflict, the Lab's small-nn n, high-stakes-per-claim regime sides with theory.

---

## 3. Generalization

### 3.1 The four errors

Fix a loss ℓ\ell ℓ and a learned hypothesis h^\hat{h} h^ trained on sample SS S of size nn n.

- **Training error (empirical risk on the training set):** R^S(h^)=1n∑i=1nℓ(h^(xi),yi)\hat{R}_S(\hat{h}) = \frac{1}{n}\sum_{i=1}^n \ell(\hat{h}(x_i), y_i) R^S​(h^)=n1​∑i=1n​ℓ(h^(xi​),yi​). Computable, and systematically _optimistic_: h^\hat{h} h^ was chosen to make this small.
- **Test error:** the empirical risk on an independent sample never used in fitting or selection. An unbiased estimate of R(h^)R(\hat{h}) R(h^) — _provided it is used exactly once_ (§11.5).
- **Expected risk / generalization error:** R(h^)=ED[ℓ(h^(x),y)]R(\hat{h}) = \mathbb{E}_{\mathcal{D}}[\ell(\hat{h}(x), y)] R(h^)=ED​[ℓ(h^(x),y)], the population quantity. This is what the Lab means by "skill": a claim about the population of future city-days, gradeable only against that population ([[Probability]]).
- **Generalization gap:** R(h^)−R^S(h^)R(\hat{h}) - \hat{R}_S(\hat{h}) R(h^)−R^S​(h^). The whole of classical learning theory is the study of this gap's distribution.

### 3.2 Why the gap exists: selection, not sampling

For a _fixed_ hypothesis hh h, the law of large numbers gives R^S(h)→R(h)\hat{R}_S(h) \to R(h) R^S​(h)→R(h), and concentration inequalities (Hoeffding ⚑: for bounded loss, Pr⁡[∣R^S(h)−R(h)∣>ϵ]≤2e−2nϵ2\Pr[|\hat{R}_S(h) - R(h)| > \epsilon] \le 2e^{-2n\epsilon^2} Pr[∣R^S​(h)−R(h)∣>ϵ]≤2e−2nϵ2) quantify the rate. The gap problem arises because h^\hat{h} h^ is not fixed — it was *selected using SS S*. Selection converts a sampling problem into a maximum-of-fluctuations problem: among many hypotheses whose empirical risks fluctuate around their true risks, the minimizer of empirical risk is preferentially the one whose fluctuation was luckiest. The larger the class searched, the luckier the winner looks. This is the identical mechanism by which [[Edge_Detection_v4]]'s selection-inflation arises — scanning many city-day divergences and reporting the largest — and by which portfolio optimizers become "error maximizers" ([[Expected_Value]] §11.2). One phenomenon, three literatures. The remedy is also shared: account for the size of the search (uniform convergence over H\mathcal{H} H; the Run Log multiplicity denominator; out-of-sample confirmation).

### 3.3 Uniform convergence

The classical resolution bounds the gap _simultaneously over the whole class_:

Pr⁡[sup⁡h∈H∣R(h)−R^S(h)∣>ϵ]≤(capacity-dependent term)⋅e−c nϵ2.\Pr\Big[\sup_{h \in \mathcal{H}} \big|R(h) - \hat{R}_S(h)\big| > \epsilon\Big] \le \text{(capacity-dependent term)} \cdot e^{-c\,n\epsilon^2}.Pr[h∈Hsup​​R(h)−R^S​(h)​>ϵ]≤(capacity-dependent term)⋅e−cnϵ2.

If the supremum is controlled, then _whatever_ hypothesis the learner selects — by any rule, however data-dependent — its empirical risk is a faithful estimate up to ϵ\epsilon ϵ. For finite H\mathcal{H} H, a union bound gives the capacity term as ∣H∣|\mathcal{H}| ∣H∣ and the gap scales as log⁡∣H∣/n\sqrt{\log|\mathcal{H}| / n} log∣H∣/n​: _doubling the number of models tried costs only an additive constant in log-capacity, but the log must be paid._ For infinite classes, cardinality is replaced by combinatorial capacity (VC dimension, §8) or empirical capacity (Rademacher complexity, §8.5). Uniform convergence is sufficient but not necessary for generalization — algorithmic stability and PAC-Bayes give alternative routes (§9.5, §22) — but it remains the right first lens for the Lab because the Lab's model classes are small and its searches enumerable.

### 3.4 Why out-of-sample is the objective

The centrality of unseen-data performance is not a stylistic preference; it follows from what a forecast _is_. A forecaster's value to the Lab is entirely prospective: the expected score on city-days not yet observed. In-sample fit conflates that prospective quantity with memorization of noise, and the conflation is _always_ in the flattering direction. The Lab's institutional embodiments of this section are already in place: pre-registration (the forecaster is frozen before the grading window), the dual-timestamp discipline (only information available at issuance time enters the forecast), and the rule that recalibrated forecasters are _new_ forecasters scored from registration date only. Each is a mechanism for guaranteeing that measured performance is genuinely out-of-sample. Learning theory is the mathematical reason those rules are not bureaucratic overhead.

---

## 4. Bias–Variance Tradeoff

### 4.1 The decomposition

For squared loss with y=f(x)+εy = f(x) + \varepsilon y=f(x)+ε, E[ε]=0\mathbb{E}[\varepsilon] = 0 E[ε]=0, Var⁡(ε)=σ2\operatorname{Var}(\varepsilon) = \sigma^2 Var(ε)=σ2, the expected prediction error at a point xx x, averaged over training samples, decomposes exactly:

ES[(y−f^S(x))2]=(f(x)−ES[f^S(x)])2⏟bias2+ES[(f^S(x)−ES[f^S(x)])2]⏟variance+σ2⏟irreducible.\mathbb{E}_S\big[(y - \hat{f}_S(x))^2\big] = \underbrace{\big(f(x) - \mathbb{E}_S[\hat{f}_S(x)]\big)^2}_{\text{bias}^2} + \underbrace{\mathbb{E}_S\big[(\hat{f}_S(x) - \mathbb{E}_S[\hat{f}_S(x)])^2\big]}_{\text{variance}} + \underbrace{\sigma^2}_{\text{irreducible}}.ES​[(y−f^​S​(x))2]=bias2(f(x)−ES​[f^​S​(x)])2​​+varianceES​[(f^​S​(x)−ES​[f^​S​(x)])2]​​+irreducibleσ2​​.

**Bias** is systematic error from the model class's inability to represent ff f: rigidity. **Variance** is sensitivity of the fitted model to the particular training sample drawn: instability. **Irreducible error** is the world's own noise — no model touches it. For 0–1 loss and for proper scoring rules the decomposition is not exact in this clean additive form (Domingos 2000 ⚑ gives a unified treatment; the log-score analogue routes through the Murphy decomposition's REL/RES/UNC — see [[Forecast_Verification]]), but the qualitative structure — a rigidity term, an instability term, a floor — is universal.

### 4.2 The trade and what actually moves it

Enlarging the model class lowers bias and raises variance; more data lowers variance at fixed bias, shifting the optimal complexity upward. Three engineering consequences:

1. **Complexity is licensed by sample size, not by ambition.** At Lab sample sizes, variance dominates almost everywhere, which is why shrinkage, small model classes, and strong priors ([[Bayesian_Statistics]]) are the default posture, and why "the model seems too simple" is not, by itself, an argument.
2. **Diagnose before enlarging.** A model family should be expanded only on evidence that _bias_ dominates: systematic, sign-consistent residual structure that survives out-of-sample (e.g., the forecaster is cold-biased in Phoenix summers across every validation fold). Random-looking residuals mean variance or noise dominates, and enlargement will hurt.
3. **The floor is real and large in this domain.** Daily maximum temperature at bracket resolution has genuine meteorological unpredictability — synoptic-scale chaos, mesoscale timing, the settlement pipeline's own quantization (the ★-flagged half-degree rounding question). UNC in the Murphy decomposition is the empirical estimate of this floor, and the Lab's climatology rung of the reference ladder is, in bias–variance terms, the zero-variance, maximal-bias baseline that any candidate must beat _after_ paying its variance cost.

### 4.3 Averaging as variance surgery

The decomposition explains why ensembling works: averaging MM M models with individual variance vv v and pairwise correlation ρ\rho ρ yields variance ρv+(1−ρ)v/M\rho v + (1-\rho)v/M ρv+(1−ρ)v/M — bias unchanged, variance reduced toward the correlation floor. Bagging, random forests, and NWP ensemble post-processing (EMOS/BMA, [[Weather_Forecast_Models]]) are all this identity wearing different clothes. The correlation floor is the operative caveat for the Lab: models trained on the same 150 city-days/month with overlapping features are highly correlated, and stacking five of them buys far less than the naive 1/M1/M 1/M suggests ([[Effective_Sample_Size]] logic, applied to models rather than observations).

---

## 5. Overfitting and Underfitting

### 5.1 Definitions and causes

**Overfitting:** the model captures sample-specific noise as if it were structure; training error keeps falling while generalization error rises. Causes: capacity large relative to nn n, unregularized optimization run to convergence, repeated adaptive reuse of the same validation data, feature sets grown by in-sample search, and — the version specific to research programs rather than single models — _researcher_ degrees of freedom (trying many specifications and reporting the best, i.e., overfitting the analyst to the data). **Underfitting:** the model class cannot represent the predictable structure; both training and generalization error are high and close together. Causes: excessive rigidity, over-regularization, features that omit the relevant information (e.g., a temperature forecaster with no access to model guidance).

### 5.2 Symptoms and detection

The diagnostic instrument is the **train–validation gap trajectory**. Large and growing gap → overfitting; small gap with high absolute error → underfitting; the learning-curve version (error vs. nn n) distinguishes "needs more data" (curves still converging) from "needs a better class" (curves plateaued together above the noise floor). In probabilistic-forecasting terms the symptoms have sharper names: an overfit forecaster is typically **overconfident** — predictive distributions too narrow, PIT histograms U-shaped, reliability diagrams with slope < 1 — while an underfit forecaster is **underconfident or unresolved** — near-climatological output, reliability fine, resolution (RES) near zero. This mapping (overfitting ↔ miscalibration-by-overconfidence; underfitting ↔ zero resolution) is the single most useful translation between this document and [[Forecast_Verification]], because it means the Lab's _existing_ verification suite is already an overfitting detector.

### 5.3 Prevention

The complete toolkit, each item developed in its own section: restrict capacity ex ante (§7), regularize (§10), validate honestly with temporal structure respected (§11), stop early (§10.4), ensemble (§4.3), and — the layer above all models — pre-register the specification and count the searches (§8.4; Analysis Run Log). A concrete domain example of each failure mode: an overfit bracket forecaster memorizes that the three hottest June city-days in the training window fell in Phoenix on ridge-pattern days and assigns near-certainty to the analogous bracket on the next ridge day — scoring catastrophically under log score when mesoscale cloud cover intervenes. An underfit forecaster outputs monthly climatology for every city-day and is never _badly_ wrong but contains zero information beyond the ladder's first rung — measurable as a KL divergence from climatology of ~0 ([[Information_Theory_for_Forecasting]]).

### 5.4 The subtle modern caveat

Interpolating models (zero training error) do not _necessarily_ overfit — benign overfitting and double descent (§22.2) are real phenomena in heavily overparameterized regimes with particular optimizers ⚑. The Lab should know this literature exists and should also know it does not apply at n∼102n \sim 10^2 n∼102–10310^3 103 with tabular features: in the Lab's regime the classical monotone story is the operative one, and "but deep nets interpolate and generalize" is not an admissible argument in any Lab model review.

---

## 6. Empirical Risk Minimization (ERM)

### 6.1 The principle

ERM is the induction principle underlying most of applied machine learning: choose

h^ERM=arg⁡min⁡h∈HR^S(h)=arg⁡min⁡h∈H1n∑i=1nℓ(h(xi),yi).\hat{h}_{\mathrm{ERM}} = \arg\min_{h \in \mathcal{H}} \hat{R}_S(h) = \arg\min_{h \in \mathcal{H}} \frac{1}{n}\sum_{i=1}^n \ell(h(x_i), y_i).h^ERM​=argh∈Hmin​R^S​(h)=argh∈Hmin​n1​i=1∑n​ℓ(h(xi​),yi​).

Substitute the empirical distribution for the true one and optimize. Maximum likelihood is ERM with ℓ=−log⁡p\ell = -\log p ℓ=−logp; least squares is ERM with squared loss; fitting a probabilistic forecaster by minimizing mean log score is ERM with the negative log score as loss — which is why the propriety of the loss ([[Proper_Scoring_Rules_and_Calibration_-_Technical_Reference]]) matters at _training_ time and not only at evaluation time: training on an improper score teaches the model to hedge dishonestly, baking miscalibration into the optimum itself.

### 6.2 When ERM works: the consistency conditions

ERM is **consistent** — R(h^ERM)→inf⁡h∈HR(h)R(\hat{h}_{\mathrm{ERM}}) \to \inf_{h \in \mathcal{H}} R(h) R(h^ERM​)→infh∈H​R(h) as n→∞n \to \infty n→∞ — if and only if uniform convergence holds over H\mathcal{H} H (Vapnik & Chervonenkis's key theorem, the "key theorem of learning theory" in Vapnik's own terminology ⚑ ★). The standard decomposition locates ERM's role precisely. Writing h∗=arg⁡min⁡HR(h)h^* = \arg\min_{\mathcal{H}} R(h) h∗=argminH​R(h) and R∗R^* R∗ for the Bayes risk (best possible over all functions):

R(h^)−R∗=[R(h^)−R(h∗)]⏟estimation error+[R(h∗)−R∗]⏟approximation error.R(\hat{h}) - R^* = \underbrace{\big[R(\hat{h}) - R(h^*)\big]}_{\text{estimation error}} + \underbrace{\big[R(h^*) - R^*\big]}_{\text{approximation error}}.R(h^)−R∗=estimation error[R(h^)−R(h∗)]​​+approximation error[R(h∗)−R∗]​​.

Estimation error is the statistical price of finite nn n (controlled by capacity and sample size — the variance side of §4). Approximation error is the structural price of the class chosen (the bias side). ERM addresses only the first term; nothing inside ERM speaks to whether H\mathcal{H} H was well chosen.

### 6.3 Assumptions, stated for auditing

1. **I.i.d. sampling from a fixed D\mathcal{D} D.** The Lab violates this twice: city-days are temporally dependent (synoptic regimes persist for days) and spatially dependent (five cities share continental weather), and the distribution is nonstationary (seasons; climate trend; NWS model upgrades — [[Weather_Forecast_Models]]). Consequences: effective sample size is smaller than nominal nn n ([[Effective_Sample_Size]]), naive bounds are anti-conservative, and validation must be temporal (§11.4). None of this invalidates the framework; it changes the constants and the bookkeeping, and A1's job is to own that bookkeeping.
2. **The loss evaluated is the loss that matters.** Training on RMSE and judging by bracket log score optimizes the wrong functional (§13.6).
3. **The class is fixed before the data are seen.** Every data-driven enlargement of H\mathcal{H} H — adding features after peeking, trying "one more model family" — silently grows the class and invalidates the nominal guarantee. The Analysis Run Log is the Lab's mechanism for making the _true_ H\mathcal{H} H auditable.

### 6.4 Why ERM alone is insufficient

Three independent reasons. **(i) Overfitting:** with capacity large relative to nn n, the empirical minimizer chases noise; uniform convergence fails and consistency with it. **(ii) Silence on class choice:** ERM cannot trade estimation against approximation error because it sees only the former — the trade requires a principle _above_ ERM, which is exactly what SRM (§7) and regularization (§10) supply. **(iii) Optimization is not identification:** even when the empirical minimum generalizes, modern practice rarely finds the exact minimizer; which near-minimizer the optimizer returns matters (implicit regularization, §22), so "ERM" as implemented is algorithm-dependent. The honest summary: ERM is the engine, capacity control is the governor, and a governor-less engine at Lab sample sizes destroys itself quickly and quietly.

---

## 7. Structural Risk Minimization (SRM)

### 7.1 Vapnik's framework

SRM formalizes the governor. Arrange hypothesis classes in a nested structure of increasing capacity,

H1⊂H2⊂⋯⊂Hk⊂⋯ ,d1≤d2≤⋯\mathcal{H}_1 \subset \mathcal{H}_2 \subset \cdots \subset \mathcal{H}_k \subset \cdots, \qquad d_1 \le d_2 \le \cdotsH1​⊂H2​⊂⋯⊂Hk​⊂⋯,d1​≤d2​≤⋯

(capacities dkd_k dk​, e.g. VC dimensions). Within each Hk\mathcal{H}_k Hk​, run ERM; across levels, select the kk k minimizing the **guaranteed risk** — empirical risk plus the capacity-dependent confidence term from the uniform-convergence bound:

k∗=arg⁡min⁡k[R^S(h^k)+Ω ⁣(dkn,δ)].k^* = \arg\min_k \left[ \hat{R}_S(\hat{h}_k) + \Omega\!\left(\frac{d_k}{n}, \delta\right) \right].k∗=argkmin​[R^S​(h^k​)+Ω(ndk​​,δ)].

The structure must be chosen _before_ seeing the data (else the choice of structure is itself unaccounted capacity). As nn n grows, the penalty shrinks and k∗k^* k∗ drifts upward: SRM automatically licenses richer models as evidence accumulates — the formal version of the Lab's staged posture, in which model ambition is gated by accrued city-days rather than by calendar enthusiasm.

### 7.2 SRM in engineering clothing

Almost every practical model-selection device is SRM with a particular structure and a particular (usually implicit) penalty: polynomial degree ladders; ridge/lasso paths indexed by λ\lambda λ (decreasing λ\lambda λ = increasing capacity); tree depth or leaf-count ladders; boosting round counts; early-stopping epoch ladders; and information criteria (AIC/BIC ⚑) as analytic stand-ins for the penalty term. Cross-validation (§11) is the empirical sibling: it replaces the theoretical penalty with a direct estimate of out-of-sample risk. The theoretical penalties are worst-case and loose; CV estimates are tighter but noisy and themselves selectable-over. Mature practice — and the recommended Lab default — uses a _pre-registered_ structure with CV-based selection along it and the run counted in the Log: SRM's discipline with CV's constants.

### 7.3 Why SRM improves generalization

Because it optimizes an upper bound on the true risk rather than a downward-biased estimate of it. The empirical risk of the level-kk k winner is optimistic by an amount growing in dkd_k dk​; adding the penalty re-centers the comparison so that levels compete on estimated _population_ performance. The proof-level guarantee is that SRM is universally consistent over the structure ⚑; the practice-level payoff is subtler and worth stating for the Lab: SRM turns "which model?" from a taste dispute into an arithmetic one, with the sample size appearing explicitly in the answer. When a future review asks why V2 fielded a small EMOS-style forecaster instead of a gradient-boosted 200-feature machine, the answer is a number: at that nn n, the penalty term of the larger class exceeded its empirical-risk advantage.

---

## 8. VC Dimension

### 8.1 Shattering and the definition

Let H\mathcal{H} H be a class of binary classifiers h:X→{0,1}h: \mathcal{X} \to \{0, 1\} h:X→{0,1}. A finite set {x1,…,xm}\{x_1, \ldots, x_m\} {x1​,…,xm​} is **shattered** by H\mathcal{H} H if for every one of the 2m2^m 2m possible labelings there exists an h∈Hh \in \mathcal{H} h∈H realizing it. The **VC dimension** dVC(H)d_{VC}(\mathcal{H}) dVC​(H) is the size of the largest shatterable set (infinite if arbitrarily large sets shatter). It measures the class's ability to _fit arbitrary noise_: a class that can shatter mm m points can perfectly memorize any labeling of them, so agreement with data on ≤dVC\le d_{VC} ≤dVC​ points carries no evidence whatsoever about the world.

Canonical values ⚑: thresholds on R\mathbb{R} R: dVC=1d_{VC} = 1 dVC​=1; intervals: 2; linear separators in Rp\mathbb{R}^p Rp (with bias): p+1p + 1 p+1; axis-aligned rectangles in R2\mathbb{R}^2 R2: 4. Instructive pathologies: {x↦sign⁡(sin⁡(ωx))}\{x \mapsto \operatorname{sign}(\sin(\omega x))\} {x↦sign(sin(ωx))}, a one-parameter family, has infinite VC dimension ⚑ — **capacity is not parameter count** — while margin-constrained linear separators can have VC dimension far _below_ the ambient dimension ⚑, the fact that makes SVMs work in high dimensions and makes regularized linear models the right default for the Lab's wide-ish feature tables.

### 8.2 The growth function and Sauer's lemma

The **growth function** ΠH(m)\Pi_{\mathcal{H}}(m) ΠH​(m) counts the labelings of the worst-case mm m points that H\mathcal{H} H can realize. Sauer's lemma ⚑ ★: if dVC=d<∞d_{VC} = d < \infty dVC​=d<∞, then ΠH(m)≤∑i=0d(mi)=O(md)\Pi_{\mathcal{H}}(m) \le \sum_{i=0}^{d}\binom{m}{i} = O(m^d) ΠH​(m)≤∑i=0d​(im​)=O(md) — the count is either 2m2^m 2m forever (infinite capacity) or _polynomial_ beyond dd d. This phase transition is the theorem's soul: a finite-capacity class, past its VC dimension, can no longer chase every noise pattern, and the union-bound argument of §3.3 goes through with ΠH(2n)\Pi_{\mathcal{H}}(2n) ΠH​(2n) replacing ∣H∣|\mathcal{H}| ∣H∣, yielding

R(h^)≤R^S(h^)+O ⁣(dVClog⁡(n/dVC)+log⁡(1/δ)n)w.p. 1−δ.R(\hat{h}) \le \hat{R}_S(\hat{h}) + O\!\left(\sqrt{\frac{d_{VC}\log(n/d_{VC}) + \log(1/\delta)}{n}}\right) \quad \text{w.p. } 1 - \delta.R(h^)≤R^S​(h^)+O(ndVC​log(n/dVC​)+log(1/δ)​​)w.p. 1−δ.

Finite VC dimension is moreover _equivalent_ to distribution-free learnability of the class (the fundamental theorem of statistical learning ⚑ ★; Blumer, Ehrenfeucht, Haussler & Warmuth 1989 ⚑) — capacity is not merely sufficient to control, it is the exact currency.

### 8.3 Reading the bound honestly

Three readings, in descending order of reliability. **(i) The scaling is trustworthy:** the gap grows like d/n\sqrt{d/n} d/n​; capacity is affordable in proportion to sample size, and halving uncertainty costs quadruple the data. **(ii) The constants are not:** the bounds are worst-case over all distributions and are frequently vacuous at practical sizes (predicting gap >1> 1 >1 for losses bounded by 1). They are design guides, not confidence intervals — Lab inference on realized score gaps comes from A1's machinery, never from a VC bound. **(iii) The distribution-free character cuts both ways:** the guarantee's universality is why it is loose; distribution-aware capacities (§8.5) trade universality for tightness.

### 8.4 Capacity of the search, not the model

The most consequential practical lesson in this document. The object whose capacity governs generalization is the _effective hypothesis class actually searched_, including every data-informed choice: features tried, transforms considered, hyperparameter grids swept, model families auditioned, and — for a research program — analyses run and abandoned. A logistic regression selected from 400 feature subsets by validation score has the capacity of the 400-fold search, roughly log⁡400≈6\log 400 \approx 6 log400≈6 bits of selection pressure, not the capacity of one 10-parameter model. This is the learning-theoretic derivation of the Analysis Run Log ([[Edge_Detection_v4]], D-FV-11): the Log _is_ the Lab's measured ∣H∣|\mathcal{H}| ∣H∣, the multiplicity denominator that keeps the union bound honest. Uncounted searches are unpaid capacity, and unpaid capacity is how research programs — not just models — overfit.

### 8.5 Beyond VC: modern capacity measures

**Rademacher complexity** ⚑ measures the class's ability to correlate with random signs _on the actual data_: RS(H)=Eσ[sup⁡h1n∑iσih(xi)]\mathfrak{R}_S(\mathcal{H}) = \mathbb{E}_\sigma\big[\sup_{h}\frac{1}{n}\sum_i \sigma_i h(x_i)\big] RS​(H)=Eσ​[suph​n1​∑i​σi​h(xi​)]. Distribution-dependent, hence tighter; directly bounds the generalization gap; and empirically estimable. **Covering numbers / metric entropy** ⚑ measure how many balls of radius ϵ\epsilon ϵ are needed to cover H\mathcal{H} H — the route to bounds for real-valued and margin-based classes. **Fat-shattering dimension** ⚑ extends shattering to regression at scale γ\gamma γ. **Algorithmic stability** (Bousquet & Elisseeff 2002 ⚑) abandons class capacity altogether: if the _algorithm's_ output changes little when one training point is replaced, it generalizes — the cleanest theoretical account of why ridge-type regularization works, and a lens under which small, heavily-shrunk Lab models are provably safe almost independent of the feature count. The Lab needs the _concepts_ here more than the theorems: they are the vocabulary in which A1 can state why the fielded model class is defensible.

---

## 9. PAC Learning

### 9.1 The definition

Valiant's frame ⚑ ★: a class H\mathcal{H} H is **PAC-learnable** if there is an algorithm and a polynomial m(⋅,⋅)m(\cdot,\cdot) m(⋅,⋅) such that for every distribution D\mathcal{D} D, every accuracy ϵ>0\epsilon > 0 ϵ>0 and confidence δ>0\delta > 0 δ>0, given n≥m(1/ϵ,1/δ)n \ge m(1/\epsilon, 1/\delta) n≥m(1/ϵ,1/δ) i.i.d. examples the algorithm outputs h^\hat{h} h^ with

Pr⁡[R(h^)≤inf⁡h∈HR(h)+ϵ]≥1−δ.\Pr\big[R(\hat{h}) \le \inf_{h \in \mathcal{H}} R(h) + \epsilon\big] \ge 1 - \delta.Pr[R(h^)≤h∈Hinf​R(h)+ϵ]≥1−δ.

"Probably" is δ\delta δ (the sample might be unlucky); "approximately" is ϵ\epsilon ϵ (exactness is never promised); "correct" is relative to the best in class, not to truth. The definition's honesty is its virtue: _no learning system can promise more than probable approximate correctness_, and any vendor, paper, or internal enthusiasm claiming otherwise is wrong before the details are examined.

### 9.2 Sample complexity

For finite classes (realizable case): m=O ⁣(1ϵ[ln⁡∣H∣+ln⁡1δ])m = O\!\big(\frac{1}{\epsilon}[\ln|\mathcal{H}| + \ln\frac{1}{\delta}]\big) m=O(ϵ1​[ln∣H∣+lnδ1​]); agnostic (noisy) case: O ⁣(1ϵ2[ln⁡∣H∣+ln⁡1δ])O\!\big(\frac{1}{\epsilon^2}[\ln|\mathcal{H}| + \ln\frac{1}{\delta}]\big) O(ϵ21​[ln∣H∣+lnδ1​]). For infinite classes, ln⁡∣H∣\ln|\mathcal{H}| ln∣H∣ becomes dVCd_{VC} dVC​, and the agnostic rate m=Θ ⁣(dVC+ln⁡(1/δ)ϵ2)m = \Theta\!\big(\frac{d_{VC} + \ln(1/\delta)}{\epsilon^2}\big) m=Θ(ϵ2dVC​+ln(1/δ)​) ⚑ is tight. The structural facts to internalize: capacity enters _linearly_, accuracy enters _inverse-quadratically_ (in the realistic noisy case), and confidence enters only _logarithmically_ — demanding 99.9% rather than 95% confidence is cheap; demanding twice the accuracy is fourfold expensive; and every unit of model capacity must be bought with proportional data.

### 9.3 Relevance to forecasting systems

Translating to Lab units makes the frame concrete. The Lab's "accuracy" ϵ\epsilon ϵ is a score-gap resolution: distinguishing a forecaster 0.02 log-score units better than the ladder from one merely equal to it. Inverse-quadratic scaling in ϵ\epsilon ϵ plus the dependence-shrunk effective nn n ([[Effective_Sample_Size]]) is precisely why decidability dates are computable in advance from the accrual rate — the PAC frame is the theoretical chassis under A1's design requirement that every registered question carry a mechanical estimate of _when_ it becomes answerable. It also supplies the correct pessimism about small edges: an edge of ϵ\epsilon ϵ needs O(1/ϵ2)O(1/\epsilon^2) O(1/ϵ2) effective city-days to certify, so halving the claimed edge quadruples the wait, and claims below the resolution the clock can fund within the roadmap horizon are undecidable-by-construction and should not be registered as decidable questions.

### 9.4 Agnostic learning and the death of realizability

Original PAC assumed some h∈Hh \in \mathcal{H} h∈H is _perfect_ (realizable). Agnostic PAC (Haussler 1992 ⚑; Kearns, Schapire & Sellie 1994 ⚑) drops this: compete with the best in class under arbitrary noise. All Lab problems are agnostic — no feature set makes bracket outcomes deterministic — and the agnostic rate (1/ϵ21/\epsilon^2 1/ϵ2, not 1/ϵ1/\epsilon 1/ϵ) is the operative one everywhere above. Computational PAC results (hardness of agnostically learning even halfspaces ⚑) also temper expectations: statistically learnable does not mean efficiently learnable, though the convex surrogates of practice (logistic loss for 0–1) dissolve most of the issue for Lab-scale models.

### 9.5 PAC-Bayes, briefly

PAC-Bayes bounds (McAllester 1999 ⚑; Catoni ⚑) blend the frameworks: fix a prior PP P over H\mathcal{H} H before seeing data, learn a posterior QQ Q, and bound the QQ Q-average risk by the QQ Q-average empirical risk plus [KL(Q∥P)+ln⁡(n/δ)]/(2n)\sqrt{[\mathrm{KL}(Q\|P) + \ln(n/\delta)]/(2n)} [KL(Q∥P)+ln(n/δ)]/(2n)​ (schematic ⚑). Capacity is now _how far the learner moved from its prior_, measured in KL — the same currency as edge itself ([[Log_Score_and_Kelly_Identity]]), a coincidence that is not one: information acquired and generalization risk are the same ledger read from two sides. PAC-Bayes is the frequentist certificate one can wrap around a Bayesian procedure, and the natural theoretical home for a future, formal statement of the Lab's "priors as capacity control" practice (§10.6, §15).

---

## 10. Regularization

### 10.1 The unified view

Regularization is capacity control implemented as penalized optimization:

h^λ=arg⁡min⁡h∈H[R^S(h)+λ Ω(h)],\hat{h}_\lambda = \arg\min_{h \in \mathcal{H}} \Big[\hat{R}_S(h) + \lambda\, \Omega(h)\Big],h^λ​=argh∈Hmin​[R^S​(h)+λΩ(h)],

with Ω\Omega Ω a complexity functional and λ≥0\lambda \ge 0 λ≥0 trading fit against simplicity. Every regularizer is simultaneously: (i) a soft constraint defining an SRM-style nested structure (level sets of Ω\Omega Ω); (ii) a Bayesian prior (Ω=−log⁡π(h)\Omega = -\log \pi(h) Ω=−logπ(h) up to constants, so the penalized optimum is the MAP estimate); and (iii) a variance-reduction device accepting bias (§4). These are three descriptions of one object, and fluency in translating among them is the practical skill.

### 10.2 L2 (ridge / Tikhonov)

Ω(w)=∥w∥22\Omega(w) = \|w\|_2^2 Ω(w)=∥w∥22​. Shrinks all coefficients smoothly toward zero; never exactly zero. Equivalent to a Gaussian prior; stabilizes ill-conditioned design matrices (the numerical and the statistical pathology are the same pathology); has closed form for linear models; and under the stability lens (§8.5) carries the cleanest generalization guarantees of any method in this document. **Lab default for any linear or linear-in-features probabilistic model.**

### 10.3 L1 (lasso) and Elastic Net

Ω(w)=∥w∥1\Omega(w) = \|w\|_1 Ω(w)=∥w∥1​ (Tibshirani 1996 ⚑). The corner geometry of the ℓ1\ell_1 ℓ1​ ball drives coefficients _exactly_ to zero: regularization and feature selection in one act. Equivalent to a Laplace prior. Caveats that matter at Lab scale: among correlated features (and NWP-derived features are _deeply_ correlated — the same model runs feed many of them) the lasso selects one representative near-arbitrarily, making the selected set unstable across folds; selection consistency requires strong conditions ⚑ (irrepresentable condition) that correlated meteorological features will not meet. **Elastic Net** (Zou & Hastie 2005 ⚑), α∥w∥1+(1−α)∥w∥22\alpha\|w\|_1 + (1-\alpha)\|w\|_2^2 α∥w∥1​+(1−α)∥w∥22​, keeps sparsity while borrowing ridge's grouping behavior — the sane default when sparsity is wanted at all. Standing Lab caution: treat lasso-selected feature sets as _hypotheses about relevance_, not findings; the selection event itself is capacity (§8.4) and belongs in the Run Log.

### 10.4 Early stopping

Halting iterative fitting (boosting rounds, gradient steps) before convergence. For linear models under gradient descent, early stopping is provably close to ridge with λ∝1/t\lambda \propto 1/t λ∝1/t ⚑ — the optimization path _is_ a regularization path, traversed from simple to complex, and the stopping epoch is the SRM level. Practical requirements: a temporally clean validation set to choose the stopping point (§11.4), and the honesty to count the stopping-point choice as one more selected hyperparameter.

### 10.5 Dropout, conceptually

Randomly zeroing units during neural-network training (Srivastava et al. 2014 ⚑); interpretable as an implicit ensemble over subnetworks and, in linear approximation, as an adaptive ℓ2\ell_2 ℓ2​ penalty ⚑. Included for literacy: the Lab's V1/V2 model classes do not reach the regime where dropout is the tool, but the _principle_ — deliberately injected noise as a complexity penalty — recurs in bagging's resampling and in ensemble post-processing.

### 10.6 Bayesian regularization

The prior is the regularizer, stated honestly and in full: not just a penalty on the mode but a distribution whose posterior propagates _how much_ shrinkage the data resisted. Hierarchical priors implement adaptive, data-calibrated shrinkage — the partial pooling across the Lab's five cities ([[Bayesian_Statistics]]) is exactly this: each city's parameters shrink toward the cross-city mean by an amount the data determine, which is regularization with the tuning parameter itself inferred rather than grid-searched. Marginal likelihood embodies an automatic Occam penalty (MacKay ⚑). For the Lab, the Bayesian formulation is usually preferable to raw penalties for the same reason distributions are preferable to points everywhere else in the vault: the uncertainty _around_ the shrunk estimate is load-bearing downstream (EV intervals, sizing at V3).

### 10.7 Why regularization improves generalization — the summary argument

All three faces give the same verdict. SRM face: the penalty is the capacity term of the bound, made differentiable. Bayesian face: the prior spends the model's limited evidence-capacity on plausible regions. Stability face: penalization bounds the fitted model's sensitivity to any single observation, and stable algorithms generalize. The empirical face, from the Lab's own domain: regularized post-processing (EMOS-style with few parameters, shrunk) is the _reigning champion_ of operational probabilistic temperature forecasting ([[Weather_Forecast_Models]]) — not a compromise accepted for lack of data, but the method that wins at the data sizes this domain actually has.

---

## 11. Cross-Validation

### 11.1 What CV estimates

Cross-validation estimates the expected out-of-sample risk of a _fitting procedure_ (not of one fitted model): partition the data, repeatedly fit on part and score on the rest, average. K-fold CV at KK K folds estimates the risk of the procedure trained on n(1−1/K)n(1-1/K) n(1−1/K) points — slightly pessimistic for the model trained on all nn n. The estimate's variance is dominated by the overlap between training sets across folds; leave-one-out (LOO) is nearly unbiased but high-variance and expensive; K∈{5,10}K \in \{5, 10\} K∈{5,10} is the conventional compromise ⚑ (ESL Ch. 7 ⚑).

### 11.2 Holdout and stratification

**Holdout** — one train/validation split — is the simplest and, with abundant data, sufficient; at Lab sizes a single split wastes too much information and inherits the luck of one partition. **Stratified** variants preserve outcome-class proportions per fold — material when brackets settle YES rarely (tail brackets), where naive folds can contain zero positive cases and scores degenerate.

### 11.3 The i.i.d. assumption, again, and why standard CV fails here

Standard K-fold randomly assigns observations to folds, which _presumes exchangeability_. Under temporal dependence, random folds place tomorrow in the training set and today in the validation set: the model is scored on days whose synoptic regime it has effectively already seen. The result is systematically optimistic risk estimates — leakage by dependence rather than by explicit feature contamination. For the Lab this is not an edge case; it is the central case. Five same-day city-days share a continent's weather; adjacent days share a regime. Random-fold CV numbers on this data are **inadmissible as evidence** and should be treated as a red flag in any analysis review.

### 11.4 Temporal validation: the Lab's required schemes ★

**Rolling-origin evaluation** (forecast-origin cross-validation; Tashman 2000 ⚑; Bergmeir & Benítez 2012 ⚑): fit on data through time tt t, score on t+ht+h t+h, advance the origin, repeat — expanding or sliding window. This exactly simulates operational deployment and respects both timestamps of the dual-timestamp discipline: the training set is what was _recorded_ by the origin, the target is what _happened_ after. **Blocked CV with embargoes**: where fold-style efficiency is wanted, use contiguous temporal blocks and delete a buffer ("embargo") of days between train and validation blocks wide enough to exhaust the dependence length (regime persistence, a few days to ~2 weeks ⚑ — the operative width is an empirical question the Lab's own data will answer and should be an early registered measurement). **Purging** any training example whose _label_ period overlaps a validation example's information window (the finance formulation — López de Prado 2018 ⚑ — transposes directly). Directive candidate, stated plainly: _all Lab model-selection and skill estimates use rolling-origin or embargoed-block schemes; random-fold CV is prohibited on city-day data._

### 11.5 What CV cannot do

Three limits, each a live hazard. **(i) CV is an estimator, not a guarantee** — it has sampling variance, and at effective-nn n in the low hundreds that variance is large; a CV win of 0.005 log-score units between two candidates is typically noise, and A1's inference machinery (paired comparisons on identical city-days, DM-style tests per [[Forecast_Verification]]) is what turns CV differences into claims. **(ii) Adaptive reuse burns the estimate**: selecting among many candidates by CV score makes the winner's CV score optimistically biased by exactly the selection mechanism of §3.2 — CV moves the overfitting problem up one level rather than eliminating it. Remedies: nested CV for an honest post-selection estimate ⚑; a final untouched temporal holdout spent _once_; and the Run Log counting every consultation. **(iii) CV validates under the data you have** — it is silent about distribution shift (§22.4); no resampling scheme certifies performance under a climate regime, station relocation, or NWS model suite the sample does not contain.

### 11.6 A reference validation protocol for the Lab ★

Stated concretely so a future registration can adopt it by reference rather than re-derive it. **(1) Freeze the feature roster and model structure** from meteorological reasoning (§12.3, §17.3) and record them. **(2) Reserve a terminal temporal holdout** — the most recent contiguous block, sized by the decidability arithmetic of §9.3 — that no procedure touches until final grading; it is spent exactly once. **(3) On the remainder, run expanding-window rolling-origin evaluation**: initial training window of at least one full seasonal cycle where accrual permits (else the seasonal covariates carry the burden and the limitation is recorded); origin advanced daily; forecasts issued at the operational issuance time using only records with ingestion timestamps before it (P2 join). **(4) Apply the embargo**: validation targets within the measured dependence length of any training city-day are excluded from score aggregation. **(5) Select hyperparameters inside the loop** (nested rolling-origin), never on the aggregate. **(6) Log every variant scored** as a Run Log entry with the query hash, seed, and code commit (§19). **(7) Grade the single selected procedure once on the terminal holdout**, dependence-adjusted per A1, and report that number with its Run Log denominator attached. The protocol's cost is almost entirely compute — which is free at Lab scale (§19) — and its product is the only kind of skill estimate this document recognizes as evidence-grade-eligible.

---

## 12. Feature Selection

### 12.1 The three families

**Filter methods** rank features by a model-free relevance statistic — correlation with the target, or **mutual information** I(Xj;Y)I(X_j; Y) I(Xj​;Y) ([[Information_Theory_for_Forecasting]] owns the estimator caveats: MI estimation is hard in small samples, and ranking by _estimated_ MI inherits selection inflation). Cheap, model-agnostic, blind to interactions and redundancy: two features individually informative may be redundant jointly; two individually useless may be jointly decisive. **Wrapper methods** search feature subsets by fitting the actual model and scoring by (properly temporal) CV — forward selection, backward elimination, **recursive feature elimination** (fit, drop weakest, refit). Most faithful to the deployed model; most expensive; and _maximally capacity-consuming_ — a wrapper search over subsets is a large hypothesis class in the §8.4 sense and must be counted as such. **Embedded methods** perform selection inside fitting — lasso/Elastic Net coefficients, tree split choices, boosting's feature usage — inheriting the model's inductive bias and costing one fit.

### 12.2 The selection event is the hazard

The unifying warning: _any_ data-driven selection performed on the same data later used for skill estimation contaminates that estimate. The canonical crime is selecting features on the full dataset and then cross-validating the model — the folds are no longer out-of-sample with respect to the _selection_, and the resulting optimism is large and well-documented ⚑ (the "selection before validation" leak; ESL Ch. 7's cautionary example ⚑). The rule: **selection lives inside the (temporal) validation loop**, fold by fold, or on a period disjoint from all evaluation.

### 12.3 Connection to edge detection

Feature selection and [[Edge_Detection_v4]] are the same statistical problem at different altitudes. A feature screen asks "which of pp p candidate signals carries information about outcomes?"; edge detection asks "which of many candidate divergences carries information about mispricing?" Both scan a family of noisy statistics and preferentially report the extreme; both require multiplicity accounting (the Run Log is the shared ledger), shrinkage of the winners toward zero, and out-of-sample confirmation before anything is believed. The Lab's structural advantage is that its feature space is _theory-constrained_: candidate features derive from a known causal pipeline (NWP guidance → temperature → CLI settlement), so the prior over "possibly relevant" is narrow — a luxury equity-factor research lacks and squanders. Discipline candidate: the V2 feature roster is pre-registered from meteorological reasoning first; data-driven additions are individually registered, counted, and confirmed out-of-sample before entering the fielded model.

---

## 13. Model Evaluation

> [!info] Ownership note Conventions (score orientation, units, clipping, reliability-diagram binning) are owned by [[Proper_Scoring_Rules_and_Calibration_-_Technical_Reference]]; inference on scores is owned by [[Forecast_Verification]] and, once ratified, A1. This section positions the metrics within learning theory — which functional each estimates, and when each is the right target.

### 13.1 Calibration and discrimination

The two orthogonal virtues. **Calibration** (reliability): among city-days assigned probability pp p, the event occurs with frequency →p\to p →p. **Discrimination** (resolution/sharpness given calibration): the forecaster's probabilities _vary_ informatively across cases rather than hugging the base rate. The Murphy decomposition (Brier = REL − RES + UNC) makes the two additive and separately estimable; Gneiting's paradigm — _maximize sharpness subject to calibration_ ⚑ ★ — is the Lab's stated objective for any forecaster. Learning-theory mapping (§5.2): overfitting manifests as miscalibration (overconfidence); underfitting as vanishing resolution.

### 13.2 Proper scoring rules

A scoring rule is **proper** if truthful reporting of one's actual belief maximizes expected score, **strictly proper** if uniquely so. Propriety is the incentive-compatibility constraint that makes a score a legitimate _training loss_ (§6.1) and a legitimate _evaluation target_ simultaneously. The Lab's suite: **Log score** — strictly proper, local, unbounded; the KL/Kelly connection ([[Log_Score_and_Kelly_Identity]]) makes it the score whose gaps _are_ growth rates, hence the primary Lab score. **Brier score** — strictly proper, bounded, decomposable (Murphy); the robust companion score. **CRPS** — strictly proper for full predictive distributions of a continuous variable (the temperature itself, before bracketing); generalizes MAE to distributions and collapses to it for point forecasts ⚑; the natural score for the _distributional_ layer of the V2 forecaster, with bracket probabilities derived downstream.

### 13.3 Classification-style metrics

**ROC/AUC** measure pure _ranking_ ability — threshold-free discrimination, calibration-blind: a forecaster reporting p/10p/10 p/10 for every event has the same AUC as one reporting pp p. **Precision/recall** suit rare-event retrieval framings under asymmetric costs. Both are _improper_ as training targets for probabilities and neither is a Lab headline metric; both are admissible as _diagnostics_ (AUC as a resolution snapshot; precision/recall for tail-bracket alarm behavior).

### 13.4 Point-forecast metrics

**RMSE** estimates fidelity to the conditional _mean_ (squared loss is elicited by the mean); **MAE** to the conditional _median_. Both discard distributional information and neither can grade a probability. Their legitimate Lab role is upstream sanity-checking of the temperature point forecast inside the pipeline, never grading of the probabilistic product. Choosing between them is choosing a functional: for skewed temperature error distributions the mean/median distinction is material, and mixing them across analyses invites silent inconsistency.

### 13.5 When each metric is appropriate — the decision table

Probabilistic bracket forecasts, headline: **log score** (primary), **Brier** (companion), both vs. the reference ladder as skill scores. Full-distribution temperature forecasts: **CRPS**. Calibration audit: reliability diagrams + PIT histograms + decomposition. Ranking diagnostic: AUC. Pipeline point-forecast QC: MAE/RMSE, one chosen and registered. The general principle: **the evaluation metric is part of the experimental design** — chosen for the functional it elicits, registered before data are scored, and never swapped post hoc because an alternative flatters the result (metric-shopping is multiplicity, and belongs in the Run Log like any other search).

### 13.6 Train on what you grade

A final learning-theory point that binds §6 to this section: the loss minimized in training should be the score used in grading (or a strictly proper surrogate eliciting the same functional). Training on RMSE and grading on log score optimizes the conditional mean while being judged on full-distribution fidelity — the model is aimed at the wrong target, and no amount of data fixes a misaimed objective.

---

## 14. Statistical Learning in Forecasting

### 14.1 Probabilistic forecasting as distributional regression

Modern forecasting is supervised learning whose output is a _distribution_: learn x↦F^(⋅∣x)x \mapsto \hat{F}(\cdot \mid x) x↦F^(⋅∣x), graded by proper scores. The learning-theoretic apparatus transfers wholesale — capacity now counts the richness of the family of conditional distributions; regularization shrinks distributional parameters; CV becomes rolling-origin scoring of predictive distributions. The Lab's central objects (bracket probability vectors) are exactly this, with the bracketing map applied to a continuous predictive distribution as the final, purely deterministic step.

### 14.2 Ensembles and post-processing

NWP ensembles ([[Weather_Forecast_Models]]) supply a physics-generated sample from forecast uncertainty; statistical post-processing corrects their known deficiencies (bias, underdispersion). **EMOS/NGR** (Gneiting et al. 2005 ⚑ ★) — a regularized, few-parameter distributional regression trained by minimum CRPS — and **BMA post-processing** (Raftery et al. 2005 ⚑) are the genre-defining methods, and their success is a standing empirical vindication of this document's small-model thesis: at operational sample sizes, low-capacity distributional regression with domain-informed structure beats high-capacity alternatives. The V2 forecaster's design space is essentially the space of EMOS-style variants, and this document supplies the vocabulary for defending that restriction.

### 14.3 Forecast combination

Combining forecasts from distinct sources almost always improves on the average member and often on the best ⚑ — the "forecast combination puzzle" is that the _simple average_ is stubbornly hard to beat, because estimating optimal combination weights reintroduces estimation variance that small samples cannot fund (Bates & Granger 1969 ⚑; Timmermann 2006 ⚑; the M-competition record ⚑). Learning-theory reading: equal weights are the zero-capacity combiner; trained weights are a model whose capacity must be paid for like any other. Lab posture: the reference ladder's rungs may eventually be combined, but the default combiner is the simple or climatologically-weighted average, with trained weights admitted only through the registered-model gate.

### 14.4 Model averaging and uncertainty

Averaging over models (Bayesian model averaging, §15.2; stacking ⚑) propagates _structural_ uncertainty — the honest admission that the model class itself is uncertain. At Lab scale the material point is smaller and sharper: **whatever single model is fielded, its parameter uncertainty must flow into the issued probabilities** (posterior predictive, not plug-in — [[Bayesian_Statistics]]), because plug-in forecasts are systematically overconfident and the overconfidence is _scored_ — it appears directly as reliability failure and log-score loss on tail brackets.

### 14.5 Hindcasts, reforecasts, and the training-data multiplier

Meteorology owns a data trick the Lab should understand precisely because its limits are subtle. **Reforecasts** — running a _frozen_ version of the current NWP model over decades of historical initial conditions (Hamill et al. ⚑) — manufacture training pairs for post-processing far beyond the operational record, and reforecast-trained EMOS-class models measurably improve tail calibration ⚑, exactly where Lab brackets are scored hardest. Two caveats govern its use. First, the multiplier applies to the _forecast-error climatology_, not to the Lab's market-side data: no reforecast lengthens the Kalshi price record, so V1's market-facing sample remains clock-bound — the accrual clock is not escapable, only the meteorological side is. Second, a reforecast is valid training data only for the model version that generated it; operational upgrades (§22.4's monitored changepoints) stale it, and using guidance-error statistics across a model-suite boundary is a form of distribution shift with a known date. Whether NOAA/NWS reforecast archives cover the Lab's stations, variables, and the currently operational suite is an empirical acquisition question — flagged ★ as a candidate early investigation, since a positive answer materially relaxes the training-data constraint on the V2 forecaster while leaving every market-side sample-size argument in this document intact.

---

## 15. Bayesian Learning

### 15.1 Learning as posterior updating

The Bayesian frame replaces "select h^\hat{h} h^" with "maintain a distribution over H\mathcal{H} H": prior π(h)\pi(h) π(h), likelihood from the data, posterior π(h∣S)\pi(h \mid S) π(h∣S), and predictions from the **posterior predictive**

p(y∣x,S)=∫p(y∣x,h) π(h∣S) dh,p(y \mid x, S) = \int p(y \mid x, h)\, \pi(h \mid S)\, dh,p(y∣x,S)=∫p(y∣x,h)π(h∣S)dh,

which averages over remaining parameter uncertainty rather than conditioning on a point estimate. Full treatment in [[Bayesian_Statistics]]; this section states the learning-theory relationships.

### 15.2 Bayesian model averaging and hierarchical learning

**BMA** extends the average over model _classes_: p(y∣S)=∑kp(y∣S,Mk) p(Mk∣S)p(y \mid S) = \sum_k p(y \mid S, M_k)\, p(M_k \mid S) p(y∣S)=∑k​p(y∣S,Mk​)p(Mk​∣S), with posterior model weights driven by marginal likelihoods and their built-in Occam penalty (MacKay ⚑). Honest caveats from the literature: BMA weights assume the true model is in the candidate set (M-closed); under misspecification (M-open — always, in practice) **stacking** on out-of-sample predictive score (Yao et al. 2018 ⚑) is often better calibrated toward the actual goal. **Hierarchical learning** is the Bayesian implementation of "share strength across related units": city-level parameters drawn from a common population distribution, yielding adaptive partial pooling — the five-city structure is the textbook use case, and hierarchical shrinkage is how the Lab buys five cities' worth of stability without pretending the cities are identical.

### 15.3 Bayes vs. frequentist learning — the working comparison

The frames answer different questions with different guarantees. Frequentist learning theory (this document's spine) gives **worst-case, distribution-free, pre-experiment** guarantees over repeated sampling — no prior needed, but bounds are loose and statements are about procedures, not about this dataset. Bayesian learning gives **in-model, post-data, this-dataset** statements — exact and decision-ready, but conditional on prior and likelihood being adequate, with no external warranty against misspecification. They meet in the middle more than the polemics suggest: regularization is MAP (§10.1); marginal likelihood enacts SRM's parsimony; PAC-Bayes wraps frequentist certificates around posteriors (§9.5); and Bayesian procedures can be _frequentist-calibrated_ — checked for coverage over repeated use, which is precisely what the Lab's verification layer does to its forecasters. **Lab division of labor (already implicit in the corpus, stated here explicitly): Bayesian machinery for _estimation and prediction_ (shrinkage, pooling, predictive distributions); frequentist machinery for _auditing_ (calibration checks, score-gap tests, error control under multiplicity, A1).** The forecaster may be Bayesian; the referee is frequentist.

### 15.4 Uncertainty-aware models

The umbrella term for models whose outputs carry their own uncertainty honestly: posterior predictives, deep ensembles ⚑ (the pragmatic state of the art for neural nets — literacy only, at Lab scale), and conformal prediction (§22.3) as the distribution-free wrapper. The Lab-relevant hierarchy of uncertainty: _aleatoric_ (the world's noise — irreducible, §4) vs. _epistemic_ (the model's ignorance — shrinks with data). Only epistemic uncertainty justifies waiting for more data before acting; only aleatoric belongs in the settled forecast distribution; conflating them either freezes the Lab forever or licenses false confidence, and the V-gate structure is, in this vocabulary, a commitment to act only when epistemic uncertainty about _edge_ has been driven below a registered threshold.

---

## 16. Information Theory Connections

> [!info] Vocabulary owned by [[Information_Theory_for_Forecasting]]; this section maps that vocabulary onto learning theory.

### 16.1 Entropy, cross-entropy, and the training objective

Minimizing average negative log score is minimizing empirical **cross-entropy** H(p^data,q)H(\hat{p}_{\text{data}}, q) H(p^​data​,q); since H(p,q)=H(p)+DKL(p∥q)H(p, q) = H(p) + D_{\mathrm{KL}}(p \| q) H(p,q)=H(p)+DKL​(p∥q), and H(p)H(p) H(p) is fixed by the world, _log-loss training is KL-projection of the model onto the data distribution_. Maximum likelihood, ERM under log loss, and cross-entropy minimization are one procedure under three names. The floor H(p)H(p) H(p) is the information-theoretic face of irreducible error (§4): the entropy of bracket outcomes given the best available features is the hard lower bound on achievable mean log score, and the Lab's UNC estimates are its empirical shadow.

### 16.2 KL divergence as the currency of everything

One quantity, four Lab roles: training objective (§16.1); **edge itself** — DKL(q∥r)−DKL(q∥p)D_{\mathrm{KL}}(q\|r) - D_{\mathrm{KL}}(q\|p) DKL​(q∥r)−DKL​(q∥p), the Lab's central identity, simultaneously information advantage and Kelly growth rate ([[Log_Score_and_Kelly_Identity]]); **capacity** in PAC-Bayes — KL(Q∥P)\mathrm{KL}(Q\|P) KL(Q∥P) as distance-moved-from-prior (§9.5); and **model comparison** — expected log-score gaps are KL gaps. That the same functional prices learning risk, forecast quality, and betting growth is the deep structural reason the Lab's measurement-first architecture is coherent: improving the instrument and finding the edge are literally the same optimization read at different points of the ladder.

### 16.3 Minimum description length

MDL (Rissanen ⚑; Grünwald 2007 ⚑) recasts learning as compression: the best model minimizes the total code length = bits to describe the model + bits to describe the data given the model. The two-part code is SRM with an explicit, principled penalty; the connection to marginal likelihood is exact for the Bayesian mixture code ⚑. MDL's slogan — _a model that cannot compress the data has learned nothing_ — gives the Lab a crisp null: a forecaster earns its keep only insofar as it shortens the description of settled outcomes relative to climatology, which is (again) a KL statement, measured by mean log-score gap.

### 16.4 Information bottleneck and mutual-information limits

The information bottleneck ⚑ frames representation learning as compressing inputs while retaining information about targets — conceptual background for why feature engineering that discards target-irrelevant variance (e.g., collapsing full model fields to station-relevant statistics) can _improve_ generalization rather than merely economize. The data-processing inequality supplies the accompanying humility: no transformation of the Lab's inputs manufactures information absent from them — post-processing NWP output can only reorganize, never exceed, the information the guidance contains, so the ceiling on V2 skill is set upstream by the NWP/NBM chain ([[Weather_Forecast_Models]]), and detecting _where_ the market sits relative to that ceiling is exactly the V1/V2 measurement question.

---

## 17. Prediction Market Applications

> [!note] V-gate reminder §17.1–§17.4 support V1/V2 measurement; §17.5–§17.6 are V3-horizon context and authorize nothing.

### 17.1 Probability estimation

The Lab's core learning task: map issuance-time features to bracket probability vectors, trained and graded by proper scores against settled outcomes. Everything above specializes: small capacity (§7–§8), heavy shrinkage (§10), rolling-origin validation (§11.4), posterior predictive output (§15.1), log-score headline (§13.2).

### 17.2 Edge detection as a learning problem

Detecting edge is _learning about a comparison_: does the model's predictive distribution dominate the market-implied one in expected log score over the population of city-days, net of the microstructure dead zone at executable prices ([[Market_Microstructure]])? Every hazard in this document manifests: selection inflation (scanning many divergences, §3.2), multiplicity (many brackets × cities × days × specifications — the Run Log denominator), dependence-shrunk effective nn n, adaptive reuse of the sample (§11.5), and the temptation to enlarge the model until the backtest smiles (§8.4). [[Edge_Detection_v4]] owns the operational discipline; this document is its theoretical justification, and the one-line summary is: **an edge claim is a generalization claim, and it is subject to every theorem herein.**

### 17.3 Feature engineering under a known causal pipeline

Prediction-market feature research is usually a fishing expedition; the Lab's is not, because the settlement chain (NWP → forecast guidance → realized temperature → CLI product → bracket settlement) is public and physical. Learning theory converts that into strategy: a theory-constrained feature space is a small prior support, which is capacity control acquired free. Features should be derived from the pipeline outward (guidance statistics, guidance revision dynamics, historical guidance-error climatology per station/season), with market-derived features (price paths, order-book signals) held to the stricter standard of §12.3 since their signal claims are exactly the fragile, decaying kind the finance multiplicity literature ⚑ warns about.

### 17.4 Market forecasting vs. outcome forecasting

Two distinct supervised problems that must never share a table: predicting the _settlement outcome_ (the V1/V2 problem — target is physical, stationary-ish, theory-anchored) and predicting the _market price path_ (a V3-adjacent problem — target is behavioral, adversarial, and self-invalidating as edges decay post-discovery ⚑). Learning-theoretic status differs sharply: the first has a stable D\mathcal{D} D to generalize to; the second's D\mathcal{D} D shifts in response to being learned. The Lab's roadmap ordering (measure the physical problem first) is, in this light, choosing the learnable problem before the adversarial one.

### 17.5 Model comparison and signal generation (V3-horizon)

At V3, model comparison graduates from research question to trading input: which forecaster's probabilities feed sizing, when do two forecasters disagree enough to abstain, how are signals throttled under multiplicity. The theory here says only: signals are hypotheses with capacity; a signal roster grows the searched class; and the registered-forecaster discipline (recalibrated = new, scored from registration) is the correct unit of account because it makes the multiplicity ledger well-defined.

### 17.6 A worked micro-example

Concrete instantiation of §17.2's hazards. Suppose 6 months of data (~900 nominal city-days, effective nn n perhaps 300–500 after dependence ⚑ — to be measured, not assumed), 5 cities × ~6 active brackets, daily divergences computed at the executable mid. That is on the order of 10410^4 104 divergence observations that are _heavily_ cross-dependent. Scanning them for ∣Δ∣>τ|\Delta| > \tau ∣Δ∣>τ and testing the exceedances is a max-of-correlated-fluctuations exercise; the naive p-values are meaningless (§3.2). The registered alternative: pre-specify the aggregation (mean score gap per forecaster over all city-days), one test, dependence-adjusted, dated in advance by the PAC-style decidability arithmetic of §9.3. The contrast between those two procedures — scan-and-test vs. register-and-wait — is the entire methodology of the Lab, derived this time from learning theory rather than from research ethics.

---

## 18. Machine Learning Foundations

> [!info] Engineering depth owned by [[Machine_Learning]]; here each family is characterized by its theoretical signature: capacity behavior, inductive bias, and uncertainty story.

**Linear models.** Capacity ≈\approx ≈ dimension (+1); convex ERM; the entire regularization theory of §10 applies exactly; uncertainty via classical or Bayesian linear theory. Inductive bias: additivity and monotonicity in features. The theoretically best-understood family in existence, which at Lab sample sizes is itself a decisive argument.

**Tree-based methods.** Axis-aligned recursive partitioning; capacity governed by depth/leaf count and _very_ large if unconstrained; inductive bias toward interactions and thresholds, invariance to monotone feature transforms. Single trees are high-variance (unstable partitions); their theory-relevant role is as the base learner variance-reduced by ensembling.

**Bagging and random forests.** §4.3's identity operationalized: bootstrap resampling + feature subsampling decorrelates trees, driving the ensemble toward the correlation floor. Out-of-bag error gives an internal near-CV estimate ⚑ (with the same temporal-dependence caveat as all resampling here). Strong tabular baseline; weak native uncertainty story (quantile forests ⚑ partially repair it).

**Boosting.** Stagewise additive modeling by functional gradient descent (Friedman 2001 ⚑); slow learning with shrinkage is an SRM path (§10.4); margin theory (Schapire et al. 1998 ⚑) explains its resistance to overfitting in rounds — though not immunity, especially under label noise ⚑. The modern tabular champion at moderate-to-large nn n; at Lab nn n, its advantage over shrunk linear/EMOS structure is unproven and must be demonstrated through the registered gate, not assumed from leaderboards.

**Gaussian processes.** Bayesian nonparametrics with capacity controlled by the kernel and its hyperparameters; exact posterior predictive distributions in closed form for regression; marginal likelihood for principled hyperparameter selection (Rasmussen & Williams 2006 ⚑). The theoretically cleanest fit to "small data, uncertainty mandatory" of any nonlinear method — shortlisted in [[Machine_Learning]] for precisely this reason — with O(n3)O(n^3) O(n3) cost irrelevant at Lab scale.

**Neural networks.** Universal approximators ⚑ whose _classical_ capacity is astronomically large and whose observed generalization is carried by implicit regularization of the training procedure (§22.2) — i.e., the family where theory currently trails practice worst. Data-hungry, natively uncalibrated (post-hoc recalibration or ensembling required ⚑), and outside the Lab's V1/V2 admissible set on sample-size grounds alone; literacy is maintained because the _upstream_ NWP world is being transformed by them ([[Weather_Forecast_Models]], AI-NWP).

**Ensemble methods generally.** The one family whose superiority is a near-theorem (§4.3, §14.3): averaging diverse, better-than-chance predictors improves expected performance, with gains bounded by member correlation. Cheap, robust, and the first thing to try when two defensible forecasters exist.

---

## 19. Computational Considerations

**Optimization.** Convexity is the frontier between "the empirical minimum is what you found" (linear/EMOS classes — reproducible, seed-independent) and "the result is algorithm-and-seed-dependent" (trees with tie-breaking, boosting, nets). Lab preference for convex or near-convex training is a _reproducibility_ policy as much as a statistical one: P8's human-verifiable seams require that refitting yields the same model.

**Numerical stability.** The domain-specific hazards: log scores near probability 0/1 (clipping convention owned by [[Proper_Scoring_Rules_and_Calibration_-_Technical_Reference]]); ill-conditioned design matrices from collinear NWP features (ridge fixes the statistics and the numerics together, §10.2); accumulating in log-space for products of probabilities; and Kahan/compensated summation irrelevant at Lab scale but float32 vs. float64 not — score gaps of interest (~10−210^{-2} 10−2 nats) sit comfortably above float64 noise but analyses should assert it, not assume it.

**Complexity and scalability.** At n∼103n \sim 10^3 n∼103, essentially nothing is computationally binding — GPs, exhaustive small-grid searches, and full refits inside rolling-origin loops are all affordable. The binding budget is _statistical_ (capacity per §8) and _procedural_ (runs per the Log), never FLOPs. This inversion — compute cheap, data precious — should be exploited deliberately: expensive validation schemes (nested rolling-origin, many-seed stability checks) are free lunches here.

**Reproducibility.** The learning-specific additions to the Lab's standing discipline: pin seeds and library versions per run; hash the exact training-set extraction query (dual-timestamp join included) into the run record; store fitted-model artifacts append-only alongside the code commit; and require that any reported number be regenerable by a single command from the vault-recorded run ID. A model result that cannot be re-derived is E4 forever.

**Data leakage.** The catastrophic failure mode, named exhaustively because every item has a Lab-specific vector: _temporal leakage_ (future-recorded data in training — defeated by joining on ingestion time, P2); _dependence leakage_ (random folds across correlated city-days, §11.3); _selection leakage_ (feature/hyperparameter choice outside the validation loop, §12.2); _target leakage_ (features causally downstream of settlement — e.g., a "final obs" field populated retroactively); and _revision leakage_ (NWS products are revised; training on the revised value when the operational forecast saw the original — defeated only by the append-only, snapshot-everything store, P1/P4). Leakage produces the most convincing false results in the field ⚑; the Lab's storage principles are, from this document's vantage, _anti-leakage architecture_ — a design vindication worth recording.

---

## 20. Common Misconceptions

**"Lower training error means a better model."** Training error is optimistically biased by selection (§3.2) and monotonically improvable by capacity that damages generalization. The quantity is diagnostic (its _gap_ to validation error), never a criterion.

**"More features always help."** Each feature buys possible signal at certain capacity cost (§8, §12); at fixed nn n, irrelevant features strictly increase estimation error, and even _relevant_ ones can hurt when their coefficients cannot be estimated to useful precision. High-dimensional exceptions exist under strong sparsity plus regularization ⚑ — conditions to be demonstrated, not presumed.

**"Larger models are always superior."** True-ish in the large-data overparameterized regime with modern implicit regularization (§22.2); false at Lab sample sizes, where the classical trade governs and the M-competition/EMOS record (§14.2–14.3) shows small structured models _winning outright_, not merely losing gracefully.

**"Cross-validation guarantees generalization."** CV is a noisy estimator (variance!), is biased optimistic under adaptive reuse (§11.5), is invalid under temporal dependence unless designed for it (§11.3–11.4), and says nothing about distribution shift. It is the best general tool available _and_ routinely over-trusted — both facts at once.

**"Complex models always beat simple ones eventually."** Only if bias dominates (§4.2). When the irreducible floor is close — as bracket-resolution temperature plausibly is — added complexity buys variance and nothing else. "Eventually" also has a date: the PAC arithmetic (§9.3) prices the crossover nn n, and if that nn n exceeds the accrual horizon the complex model is worse _for the Lab_ even if better in the infinite-data limit.

**"The p-value from my backtest means what it says."** Only if the backtest was the single pre-registered analysis. Under search, the nominal error rate is destroyed by exactly the §3.2 mechanism, and the honest rate is governed by the size of the search — the entire reason the Run Log exists.

**"Regularization is a hack to fix overfitting after the fact."** It is the theoretically principled component (§7, §10.7) — the penalty is the generalization bound made operational; the "pure" unregularized fit is the theoretically indefensible object at finite nn n.

---

## 21. Research Lab Integration

How this document underwrites each neighbor, import/export stated both ways so contradictions are findable by search.

**[[Probability]]** — _imports_: the population-grading principle, expectation, concentration; upstream canon, nothing exported back. SLT is that principle applied to _models_: a model's quality is a population claim (RR R), gradeable only against the population, estimable from samples only with capacity accounting.

**[[Bayesian_Statistics]]** — _imports_: priors, posteriors, hierarchical pooling, predictive distributions. _Exports_: the frequentist audit frame (§15.3) and the reading of priors as capacity control (§10.6), giving the corpus one coherent story of why shrinkage works.

**[[Information_Theory_for_Forecasting]]** — _imports_: entropy/KL vocabulary and estimator caveats. _Exports_: the identification of KL as simultaneously training objective, capacity (PAC-Bayes), and edge (§16.2) — the unification that makes the vault's mathematics one subject.

**Decision Theory** — no vault note yet (backlog per the placeholder rule). The dependency is real: loss functions are decision-theoretic objects, propriety is an incentive statement, and V3 sizing is a decision problem; when the note is written, §2.2, §13, and §15.3 are its SLT interface.

**[[Machine_Learning]]** — the engineering sibling. _Exports_: the entire theoretical layer its §3 summarizes (handoff edit pending, per the ownership callout). _Imports_: the Lab-regime doctrine (small-data posture, GP shortlisting, model canon) that this document justifies but does not operationalize.

**[[Proper_Scoring_Rules_and_Calibration_-_Technical_Reference]]** — _imports_: propriety, conventions, clipping. _Exports_: the ERM reading (proper score = legitimate training loss, §6.1, §13.6) and the overfitting↔miscalibration mapping (§5.2), which makes the calibration suite double as a generalization diagnostic.

**[[Forecast_Verification]]** — _imports_: Murphy decomposition, DM-style comparison, verification inference. _Exports_: the bias–variance ↔ REL/RES/UNC correspondence (§4.1) and the framing of verification as the frequentist audit of a learned system (§15.3). A1, once ratified, owns all inference conventions both documents gesture at.

**[[Prediction_Markets]] / [[Market_Microstructure]]** — _imports_: what a price is, the executable-Δ dead zone. _Exports_: the learnability asymmetry between outcome-forecasting and price-forecasting (§17.4), a theoretical argument for the roadmap's ordering.

**[[Edge_Detection_v4]]** — the closest downstream consumer. _Imports_: thresholds, shrinkage, Run Log discipline. _Exports_: the derivation of that discipline from uniform convergence and search capacity (§3.2, §8.4, §17.2): edge detection is generalization theory applied to one comparison.

**[[Weather_Forecast_Models]]** — _imports_: what the guidance is and how it evolves. _Exports_: the data-processing ceiling argument (§16.4) — V2 skill is bounded by upstream information content — and the EMOS-vindication reading of §14.2.

**[[Kelly_Criterion]] / [[Log_Score_and_Kelly_Identity]] / [[Expected_Value]]** — _imports_: the growth mathematics and the EV typing discipline. _Exports_: the statement that a _validated_ score gap (a generalization claim survived) is the only admissible input to sizing — SLT is the gatekeeper between measurement and money.

**[[Effective_Sample_Size]]** — _imports_: the dependence-corrected nn n used in every bound and every decidability computation here. _Exports_: additional demand: capacity budgets (§8.3) and PAC arithmetic (§9.3) must run on neffn_{\text{eff}} neff​, not nominal nn n.

**A1 (Statistical Validity & Inference Framework)** — this document is deliberately _upstream_ of A1: it supplies the concepts (capacity, multiplicity-as-capacity, temporal validation, decidability arithmetic) that A1 must convert into registered conventions. Nothing here pre-empts A1's authority; where A1 ratifies a convention that narrows an option this document leaves open, A1 governs.

---

## 22. Current Research Frontiers

**22.1 Foundation models and transfer.** Massive pretraining then adaptation upends the one-task-one-sample frame; theory (transfer bounds, in-context learning as implicit Bayesian inference ⚑) trails badly. Lab relevance: indirect but real — AI-NWP foundation models ([[Weather_Forecast_Models]]) may change the _inputs_; the Lab-side learning problem stays small-nn n.

**22.2 Generalization in overparameterized models.** Benign overfitting (Bartlett et al. 2020 ⚑), double descent (Belkin et al. 2019 ⚑ ★), implicit regularization of SGD ⚑ — the program of repairing classical theory where interpolation generalizes. Watch for consensus; do not import its permissions into small-nn n practice (§5.4).

**22.3 Conformal prediction.** Distribution-free, finite-sample coverage for prediction sets under exchangeability (Vovk et al. ⚑; Angelopoulos & Bates tutorial ⚑), with adaptive variants weakening exchangeability for time series ⚑. **The standout near-term adoption candidate**: a conformal wrapper around the V2 predictive distribution yields temperature intervals with _guaranteed_ marginal coverage — a cheap, registrable honesty check orthogonal to the parametric calibration suite. Candidate for a registered V2 diagnostic; requires the temporal-adaptation variant given §6.3's dependence.

**22.4 Distribution shift and domain adaptation.** Covariate shift, label shift, importance weighting ⚑, invariant risk minimization ⚑. The Lab's concrete shifts are enumerable and _observable_: seasonality (modelable), NWS model-suite upgrades (announced — a monitored changepoint, not a surprise), station/instrumentation changes (F-series findings territory), climate trend (slow). A registered shift-monitoring convention (score-by-regime dashboards; refit triggers as ADR-gated events) is the practical import.

**22.5 Causal ML.** Prediction under observation vs. under intervention (Pearl ⚑). Lab relevance: conceptual hygiene now (the forecaster models a passively observed system); at V3, "our trading does not move the price we measure" becomes a causal assumption deserving a recorded size threshold.

**22.6 Bayesian deep learning and uncertainty-aware AI.** Approximate posteriors for nets, deep ensembles as pragmatic SOTA ⚑, calibration under shift. Literacy-only at Lab scale; the _evaluation_ methods (proper-score benchmarking of UQ ⚑) are the transferable part.

**22.7 Online and continual learning.** Regret bounds, anytime-valid inference (e-values, confidence sequences — Ramdas et al. ⚑ ★), drift-aware updating. The anytime-valid strand matters most: a continuously-accruing Lab testing score gaps _as data arrive_ without α-spending gymnastics is exactly the e-process use case, already flagged in [[Probability]] §18 as ADR-gated; A1 should adjudicate.

**Open questions the field admits** (all ⚑): why interpolation generalizes (incomplete); reliable deep UQ (ensembles as embarrassing SOTA); shift-robustness without shift examples; community-level benchmark overfitting (the field's own unledgered multiplicity crisis — the Lab's Run Log is the repair, applied at lab scale).

---

## 23. Engineering Takeaways

1. **Every skill claim is a generalization claim.** Grade models, forecasters, and edges only on data that had no influence on their construction or selection — temporally out-of-sample, selection counted.
2. **Capacity is bought with data; count all of it.** The searched class — features tried, models auditioned, analyses run — is the true hypothesis space. The Analysis Run Log is the capacity ledger; uncounted searches are unpaid debt that compounds silently.
3. **Default small, enlarge on evidence of bias.** At neffn_{\text{eff}} neff​ in the hundreds, variance dominates: shrunk linear/EMOS-class models, hierarchical pooling, simple combiners. Enlarge only on sign-consistent, out-of-sample residual structure, as a registered event.
4. **Random-fold CV is prohibited on city-day data.** Rolling-origin or embargoed temporal blocks only; the embargo width is an early registered measurement, not an assumption.
5. **Train on the score you grade.** Proper scores as training losses; no RMSE-trained, log-score-graded mismatches; no post-hoc metric shopping.
6. **Issue predictive distributions, not plug-ins.** Parameter uncertainty flows into forecast probabilities; plug-in overconfidence is directly scored as calibration failure.
7. **Compute is free; spend it on honesty.** Nested/rolling validation, many-seed stability checks, full refits — all affordable at Lab scale. The scarce resources are city-days and un-reused evaluations.
8. **Price the wait before registering the question.** PAC arithmetic on neffn_{\text{eff}} neff​ dates every decidable question; claims finer than the accrual horizon can fund are not registrable as decidable.
9. **The storage principles are anti-leakage architecture.** Append-only, dual-timestamped, snapshot-everything (P1/P2/P4) is what makes honest temporal validation _possible_; treat any convenience shortcut around them as a leakage vector by default.
10. **The referee is frequentist even when the forecaster is Bayesian.** Estimation may pool and shrink; auditing uses coverage, calibration, and dependence-adjusted tests under A1's conventions.

---

## 24. Annotated Bibliography

All entries ⚑ pending primary-source verification (Invariant 3); ★ marks the priority tier (feeds A1 or registered conventions). Ranked within tiers by recommended reading order.

### Tier 1 — Foundational works

- **Vapnik, V., _The Nature of Statistical Learning Theory_ (2nd ed., 2000)** ⚑ ★ — The accessible statement of the framework by its principal author: ERM consistency, VC theory, SRM, and the "don't solve a harder problem" philosophy. Read after ESL Ch. 2/7. Lab relevance: the theoretical constitution behind §6–§8.
- **Vapnik, V. & Chervonenkis, A., "On the Uniform Convergence of Relative Frequencies of Events to Their Probabilities," _Theory of Probability and Its Applications_ (1971)** ⚑ ★ — The founding theorem; historical reading, with modern proofs taken from Shalev-Shwartz & Ben-David.
- **Vapnik, V., _Statistical Learning Theory_ (1998)** ⚑ — The encyclopedic version; reference, not reading.
- **Valiant, L., "A Theory of the Learnable," _CACM_ (1984)** ⚑ — PAC's founding paper; short and readable.
- **Fisher, R.A., "The Use of Multiple Measurements in Taxonomic Problems," _Annals of Eugenics_ (1936)** ⚑ — Discriminant analysis; historical anchor for §1.1.
- **Breiman, L., "Statistical Modeling: The Two Cultures," _Statistical Science_ (2001)** ⚑ ★ — The field's defining polemic and this document's §1.5; essential for calibrating the Lab's between-cultures stance. Read with the published discussions (Cox, Efron ⚑).
- **Geisser, S., "The Predictive Sample Reuse Method with Applications," _JASA_ (1975)** ⚑ and **Stone, M., "Cross-Validatory Choice and Assessment of Statistical Predictions," _JRSS-B_ (1974)** ⚑ — Cross-validation's twin origins; the predictivist manifesto behind §11.

### Tier 2 — Modern core references

- **Hastie, T., Tibshirani, R. & Friedman, J., _The Elements of Statistical Learning_ (2nd ed., 2009)** ⚑ ★ — The synthesis. Chapters 2, 3, 7 (model assessment — the single most Lab-relevant chapter in any book here), 10, 15. Freely available ⚑. First acquisition.
- **Shalev-Shwartz, S. & Ben-David, S., _Understanding Machine Learning: From Theory to Algorithms_ (2014)** ⚑ ★ — The clean modern textbook treatment of everything in §3, §6–§9: fundamental theorem, Rademacher complexity, stability. Freely available ⚑. The rigor backbone of this document.
- **Bishop, C., _Pattern Recognition and Machine Learning_ (2006)** ⚑ — The Bayesian-flavored counterpart to ESL; Chapters 1–4 for the probabilistic framing of §15.
- **Murphy, K., _Probabilistic Machine Learning: An Introduction_ (2022) and _Advanced Topics_ (2023)** ⚑ — Current encyclopedic reference; consult, don't read through.
- **Mohri, M., Rostamizadeh, A. & Talwalkar, A., _Foundations of Machine Learning_ (2nd ed., 2018)** ⚑ — Alternative rigorous treatment; strongest on Rademacher and boosting theory.
- **Bousquet, O. & Elisseeff, A., "Stability and Generalization," _JMLR_ (2002)** ⚑ — The stability route (§8.5); the theoretical safety certificate for the Lab's shrunk-model posture.
- **McAllester, D., "Some PAC-Bayesian Theorems," _Machine Learning_ (1999)** ⚑ — PAC-Bayes origin (§9.5); read with a modern tutorial (Alquier ⚑).
- **Zhang, C. et al., "Understanding Deep Learning Requires Rethinking Generalization," _ICLR_ (2017)** ⚑ and **Belkin, M. et al., "Reconciling Modern Machine-Learning Practice and the Classical Bias–Variance Trade-off," _PNAS_ (2019)** ⚑ — The modern rupture (§22.2); literacy, with the §5.4 caveat attached.

### Tier 3 — Forecasting, validation, and prediction markets (closest to Lab practice)

- **Gneiting, T. & Raftery, A., "Strictly Proper Scoring Rules, Prediction, and Estimation," _JASA_ (2007)** ⚑ ★ — The propriety synthesis; co-canonical with the scoring reference. The §13 spine.
- **Gneiting, T. et al., "Calibrated Probabilistic Forecasting Using Ensemble MOS and Minimum CRPS Estimation," _MWR_ (2005)** ⚑ ★ — EMOS; the genre-defining small-model vindication of §14.2 and the V2 design anchor.
- **Bergmeir, C. & Benítez, J.M., "On the Use of Cross-Validation for Time Series Predictor Evaluation," _Information Sciences_ (2012)** ⚑ ★ — The empirical study of CV validity under temporal dependence; direct support for D-SLT-2 below. Read with Tashman (2000) ⚑ on rolling-origin design.
- **Bergmeir, C., Hyndman, R. & Koo, B., "A Note on the Validity of Cross-Validation for Evaluating Autoregressive Time Series Prediction," _CSDA_ (2018)** ⚑ — The nuance: K-fold _can_ be valid for purely autoregressive setups under conditions; useful to know the boundary of the prohibition.
- **López de Prado, M., _Advances in Financial Machine Learning_ (2018)** ⚑ — Purging/embargo formulations and the backtest-overfitting chapters; Tier-3 practitioner source, claims individually verifiable; the finance mirror of §11.4 and §19's leakage taxonomy.
- **Timmermann, A., "Forecast Combinations," _Handbook of Economic Forecasting_ (2006)** ⚑ — The combination-puzzle survey behind §14.3.
- **Harvey, C., Liu, Y. & Zhu, H., "…and the Cross-Section of Expected Returns," _RFS_ (2016)** ⚑ ★ — The multiplicity crisis, empirically; the standing prior behind §8.4 and §17.3, shared with [[Machine_Learning]]'s bibliography.
- **Wolfers, J. & Zitzewitz, E., "Prediction Markets," _JEP_ (2004)** ⚑ — Survey bridge to [[Prediction_Markets]].
- **Vovk, V., Gammerman, A. & Shafer, G., _Algorithmic Learning in a Random World_ (2005)** ⚑ and **Angelopoulos, A. & Bates, S., "A Gentle Introduction to Conformal Prediction" (2021)** ⚑ ★ — Conformal foundations and the practical tutorial; supports the §22.3 adoption candidate.

### Tier 4 — Regularization and methods primary sources

- **Tibshirani, R., "Regression Shrinkage and Selection via the Lasso," _JRSS-B_ (1996)** ⚑; **Zou, H. & Hastie, T., "Regularization and Variable Selection via the Elastic Net," _JRSS-B_ (2005)** ⚑; **Hoerl, A. & Kennard, R., "Ridge Regression," _Technometrics_ (1970)** ⚑ — The §10 primary sources.
- **Breiman, L., "Random Forests," _Machine Learning_ (2001)** ⚑; **Friedman, J., "Greedy Function Approximation: A Gradient Boosting Machine," _Annals of Statistics_ (2001)** ⚑; **Freund, Y. & Schapire, R., "A Decision-Theoretic Generalization of On-Line Learning…," _JCSS_ (1997)** ⚑ — The §18 method canon, shared with [[Machine_Learning]].
- **Rasmussen, C. & Williams, C., _Gaussian Processes for Machine Learning_ (2006)** ⚑ ★ — Given §18's shortlisting; freely available ⚑.
- **Grünwald, P., _The Minimum Description Length Principle_ (2007)** ⚑ — MDL in full (§16.3).
- **Domingos, P., "A Unified Bias-Variance Decomposition," _ICML_ (2000)** ⚑ — The general-loss decomposition behind §4.1's caveat.

**Acquisition priority if reading time is the constraint** ⚑: ESL Ch. 7 → Bergmeir & Benítez (2012) → Shalev-Shwartz & Ben-David Chs. 2–6 → Gneiting & Raftery (2007) → Breiman "Two Cultures" → Vapnik (2000) → Angelopoulos & Bates → Harvey/Liu/Zhu. That sequence covers honest evaluation, temporal validation, the theory core, the scoring spine, the cultural orientation, and the multiplicity discipline, in order of operational urgency.

---

## Proposed engineering directives (pending Architect ratification)

- **D-SLT-1 [NEW]:** All Lab capacity budgets, sample-complexity estimates, and decidability-date computations use dependence-corrected effective sample size neffn_{\text{eff}} neff​, never nominal city-day counts. (Consumes [[Effective_Sample_Size]]; interfaces with A1.)
- **D-SLT-2 [NEW]:** Random-fold cross-validation is prohibited on city-day data. Model selection and skill estimation use rolling-origin evaluation or embargoed temporal blocks; the embargo width is set by a registered measurement of dependence length, not assumed.
- **D-SLT-3 [NEW]:** Every data-driven selection event — features, hyperparameters, model families, stopping points, metric choices — is recorded in the Analysis Run Log as capacity consumed. Selection performed outside a validation loop invalidates the associated skill estimate for evidentiary use.
- **D-SLT-4 [NEW]:** Model classes are enlarged only via registered events, on documented out-of-sample evidence of bias-dominated error (sign-consistent residual structure), never on benchmark reputation or in-sample improvement.
- **D-SLT-5 [NEW]:** Training losses must be strictly proper scores (or elicit the registered target functional); the training loss and the grading score are declared together at registration.
- **D-SLT-6 [NEW]:** Fielded forecasters issue posterior-predictive (uncertainty-propagated) probabilities; plug-in point-parameter forecasts are inadmissible as registered forecasters.
- **D-SLT-7 [NEW]:** Upon ratification of this document, [[Machine_Learning]] §3 is edited to a summary deferring here (single-home convention); the maintenance ⚑ on that section is discharged by the edit, not by ratification alone.

---

_End of document. Version 1.0 — E4 testimony pending Architect verification. All ⚑ flags outstanding; no specific attribution, date, constant, or empirical claim herein is load-bearing until individually verified per Invariant 3. The D-SLT directives are proposals only._