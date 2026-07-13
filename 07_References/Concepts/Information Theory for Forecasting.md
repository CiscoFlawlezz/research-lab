# Information Theory for Forecasting — Research Synthesis

**Vault location:** `07 References/Concepts` **Level:** Quantitative researcher reference (assumes probability theory, statistical inference, basic measure-theoretic literacy; overlaps deliberately with [[Proper Scoring Rules and Calibration - Technical Reference]] §10 and [[Bayesian Statistics]]) **Cross-links:** [[Probability]] · [[Bayesian Statistics]] · [[Proper Scoring Rules and Calibration - Technical Reference]] · [[Forecast Verification]] · [[Prediction Markets]] · [[Kelly Criterion]] · [[Expected Value]] · [[Edge Detection]] · [[Machine Learning]] · [[Market Microstructure]] · [[Log Score and Kelly Identity]] · [[Effective Sample Size]] · [[Glossary]] **Status:** Version 1 — draft, **E4** (AI-drafted testimony), ungraded pending Architect verification and canonization (Invariant 3) **Created:** 2026-07-11 **Tags:** #information-theory #entropy #KL-divergence #scoring-rules #canon-candidate

> [!warning] Epistemic status (Invariant 3) This document is AI-drafted testimony, not evidence. Every bibliographic citation was produced from model knowledge without live retrieval and **must be independently verified (title, year, venue, page-level claims) before any statement here becomes load-bearing in a registration or ADR**. Lower-confidence citations carry ⚑ per house convention; ★ marks the priority verification tier (entries directly feeding A-series decisions or registered conventions). The synthesis of _ideas_ is believed faithful to the literature; bibliographic metadata is the most fragile layer. Canonizing this document as "current reference" does **not** discharge individual ⚑ flags.

> [!info] Ownership boundaries One home per convention. This document **owns** the lab's information-theoretic vocabulary (entropy, surprisal, cross-entropy, KL divergence, mutual information) and their forecasting interpretations. It **does not own**: score orientation/units and the clipping convention (owned by [[Proper Scoring Rules and Calibration - Technical Reference]] §2, §13); the Kelly–log-score derivation (owned by [[Log Score and Kelly Identity]], summarized here in §11.4); statistical inference on information estimates (owned by **A1** once ratified); market normalization of prices to probabilities (owned by **A4** once ratified); bet sizing (owned by [[Kelly Criterion]], V3-gated). Where this document and a ratified A-series document disagree, the A-series document governs.

---

## 1. Purpose and scope

This is the lab's canonical reference on **why information is valuable, how it is quantified, and how it is measured** inside a probabilistic forecasting and trading system. The lab's entire architecture — scoring forecasts, diagnosing calibration, detecting edge against market prices, and (eventually, behind the V3 gate) sizing positions — rests on a single family of information-theoretic quantities. The log score is a negative surprisal. Its expectation is a cross-entropy. The gap between two forecasters' expected log scores is a difference of KL divergences. The Kelly growth rate of a bettor against a market _is_ that gap. These are not analogies; they are the same objects viewed from measurement, inference, and capital perspectives, and this document is the place where the objects themselves are defined, derived, and given engineering form.

This is deliberately **not** a general introduction to information theory. Channel capacity, source coding, error-correcting codes, and rate–distortion theory appear only where they illuminate forecasting (notably: the source-coding interpretation of the log score, §6.3, and Kelly's original channel framing, §3.4). The organizing question throughout is: _what does this quantity mean for a system that issues probabilities about the future and is graded against realized outcomes?_

Scope boundaries with neighboring documents are stated in the ownership callout above and revisited in §21.

---

## 2. Conventions and notation

**Units.** Natural logarithms — **nats** — are the lab's working unit, inherited from the registered convention in [[Proper Scoring Rules and Calibration - Technical Reference]] §2. The reason is not aesthetic: the Kelly–log-score identity is denominated in nats (expected log-growth of wealth per event), and a silent $\ln$/$\log_2$ mismatch corrupts the growth interpretation by a factor of $\ln 2 \approx 0.693$. **Bits** ($\log_2$) appear when citing the meteorological ignorance-score literature or when a "number of binary questions" intuition is genuinely clarifying; every such appearance is labeled. Conversion: $1 \text{ nat} = 1/\ln 2 \approx 1.4427$ bits; convert only at the reporting layer, never in storage.

**Notation.** Uppercase $X, Y$ denote random variables; lowercase $x, y$ realized values; calligraphic $\mathcal{X}$ alphabets (finite unless stated). $p, q, r$ denote probability mass functions or, where flagged, densities: throughout this document, $q$ is the **true / data-generating distribution** (an idealization the pipeline never observes), $p$ is the **lab's forecast**, and $r$ is the **market-implied forecast** — matching [[Log Score and Kelly Identity]] and [[Proper Scoring Rules and Calibration - Technical Reference]]. $H(\cdot)$ is entropy, $H(P, Q)$ cross-entropy (first argument is the _truth-side_ distribution taking the expectation, second the _forecast-side_ distribution being evaluated — see the orientation warning in §7.1), $D_{\mathrm{KL}}(\cdot | \cdot)$ Kullback–Leibler divergence, $I(X;Y)$ mutual information. The convention $0 \ln 0 = 0$ is adopted throughout, justified by continuity ($x \ln x \to 0$ as $x \downarrow 0$); the convention $p \ln(p/0) = +\infty$ for $p > 0$ is likewise standard and is the mathematical root of the log score's boundary problem (§19.2).

**Discrete first.** The lab's V1 instrument concerns Kalshi temperature **brackets** — finite, mutually exclusive, exhaustive outcome sets per city-day. All core results are therefore stated for finite alphabets. Differential-entropy caveats (it can be negative, it is not invariant under coordinate change, it is _not_ the limit of discrete entropy) are quarantined in §5.6 so they cannot contaminate discrete reasoning.

---

## 3. Historical development

### 3.1 Hartley: information as logarithmic capacity

Ralph Hartley (1928, "Transmission of Information," _Bell System Technical Journal_) ⚑ proposed the first quantitative measure: a message selected from $N$ equally likely alternatives carries $\log N$ units of information. The logarithm is forced by additivity — two independent selections from $N$ and $M$ alternatives should carry the information of one selection from $NM$ — and this additivity requirement recurs in every subsequent axiomatization. Hartley's measure is Shannon entropy restricted to the uniform case; what it lacks is any role for _unequal probabilities_, which is precisely what forecasting is about.

### 3.2 Shannon and Wiener: probability enters

Claude Shannon (1948, "A Mathematical Theory of Communication," _BSTJ_) ★ generalized Hartley by weighting surprisal by probability: $H = -\sum_i p_i \ln p_i$. Shannon's framing was communication engineering — how many bits are needed to encode a source, how fast can a channel transmit — but the mathematical objects are statements about _probability distributions_, not about wires. Norbert Wiener (1948, _Cybernetics_) ⚑ arrived at essentially the same quantity independently and contemporaneously from the theory of prediction and filtering of time series — a lineage worth noting because Wiener's route to entropy ran _through forecasting_ (anti-aircraft fire-control prediction) rather than through coding. Shannon acknowledged the parallel development. The historical lesson the lab should retain: information theory was co-invented by a forecaster, and its application to prediction is original, not derivative.

### 3.3 Kullback and Leibler: information for statistical inference

Solomon Kullback and Richard Leibler (1951, "On Information and Sufficiency," _Annals of Mathematical Statistics_) ★ redirected the theory toward statistics: their divergence $D_{\mathrm{KL}}(P|Q)$ measures "the mean information for discrimination" between two hypotheses per observation. Kullback's book (_Information Theory and Statistics_, 1959) ⚑ systematized the program: sufficiency is exactly the property of losing no discrimination information; hypothesis-testing error exponents are KL divergences (the Chernoff–Stein lemma, §8.5). This is the branch of the theory the lab actually lives in — the lab's core question, "does our forecast discriminate reality from the market's implied forecast?", is a Kullback-style discrimination question, not a Shannon-style coding question.

### 3.4 Kelly: information as growth rate

J. L. Kelly Jr. (1956, "A New Interpretation of Information Rate," _BSTJ_) ★ closed the loop between Shannon's channel capacity and gambling: a bettor with access to a noisy signal about race outcomes, betting log-optimally, achieves a wealth growth rate equal to the mutual information between signal and outcome (for fair odds). Kelly's paper is the origin of everything behind the lab's V3 gate, and its message is stated precisely in §11.4 and [[Log Score and Kelly Identity]]: information advantage, log-score edge, and capital growth rate are one quantity. Cover and Thomas (2006, ch. 6) ⚑ give the modern textbook treatment ("gambling and data compression are dual"); Cover's universal portfolio work (1991, _Mathematical Finance_) ⚑ extends the growth-rate viewpoint to sequential investment without distributional assumptions.

### 3.5 Jaynes: information as inference

Edwin Jaynes (1957, "Information Theory and Statistical Mechanics," _Physical Review_) ★ inverted the direction of application: rather than measuring the information in a known distribution, use entropy to _choose_ a distribution when knowledge is incomplete — the **maximum entropy principle** (§5.4). Jaynes's posthumous _Probability Theory: The Logic of Science_ (2003) ⚑ is the fullest statement of probability as extended logic, the epistemological stance closest to the lab's own (a probability is a claim conditional on an information state; see [[Probability]]). MaxEnt gives the lab its formal notion of an _honest ignorance prior_ and explains why climatology is the canonical reference forecast (§13.3).

### 3.6 Lindley, Bernardo, Blackwell: information for decisions and experiments

Dennis Lindley (1956, "On a Measure of the Information Provided by an Experiment," _Annals of Mathematical Statistics_) ★ defined the expected information from an experiment as the expected KL divergence from prior to posterior — the foundation of Bayesian experimental design and of the lab's "value of collecting this data stream" reasoning (§10.3). José Bernardo (1979, _Annals of Statistics_) ⚑ showed that treating expected information as the utility of an inference yields the log score as the unique (smooth, proper, local) utility and generates reference priors. David Blackwell (1953, "Equivalent Comparisons of Experiments") ⚑ proved the ordering result behind "more information never hurts a rational decision-maker" — with scope conditions that matter and are frequently violated in markets (§17.4).

### 3.7 MacKay, Cover & Thomas: the modern synthesis

Thomas Cover and Joy Thomas (_Elements of Information Theory_, 1991; 2nd ed. 2006) ★ is the standard graduate reference and the lab's default citation for theorems (chain rules, data-processing inequality, Fano, AEP, gambling chapter). David MacKay (_Information Theory, Inference, and Learning Algorithms_, 2003) ★ unified coding, Bayesian inference, and machine learning in one framework and is the single best bridge text for this lab's purposes: MacKay treats inference _as_ communication and model comparison _as_ description-length accounting. Between them, the modern consensus is settled: information theory is not a theory of data transmission that happens to apply to statistics; it is the calculus of uncertainty reduction, of which coding is one application and forecasting another.

### 3.8 The forecasting-verification lineage

In parallel, meteorology developed the verification side: Brier (1950) ⚑ on quadratic scoring; I. J. Good (1952, "Rational Decisions," _JRSS B_) ★ proposing the logarithmic score explicitly as a fee/reward with Bayesian justification; Murphy and Winkler (1987) ⚑ founding distributions-oriented verification; Roulston and Smith (2002, _Monthly Weather Review_) ★ importing the log score into meteorology as the **ignorance score** with an explicit information-theoretic reading; Weijs, van Nooijen and van de Giesen (2010, _Monthly Weather Review_) ⚑ decomposing the log score into reliability–resolution–uncertainty terms that are all KL divergences; Gneiting and Raftery (2007, _JASA_) ★ consolidating proper scoring rules, of which the log score is the information-theoretic member. This lineage is treated at full depth in [[Forecast Verification]] and [[Proper Scoring Rules and Calibration - Technical Reference]]; here it anchors the claim that the verification stack the lab has already ratified is information theory in operational clothing.

---

## 4. What is information?

### 4.1 Information is uncertainty resolved, not data stored

The primitive concept is not the message but the **probability distribution over what the message might be**. Before a Kalshi bracket settles, the lab's state of knowledge about the Phoenix daily high is a distribution over brackets; after the NWS CLI product publishes, that distribution collapses to a point. **Information is the name for the difference between those two epistemic states.** Shannon's formalization makes this quantitative: the information delivered by an observation is the reduction in uncertainty it causes, and uncertainty is entropy (§5). Data — bytes on disk — is the _carrier_ of information, and the two quantities can diverge arbitrarily: a terabyte of METAR observations that the lab's forecast already implies carries no information about the settlement; a single bit ("the CLI high rounded up, not down") can carry decisive information about a boundary bracket. Misconception §20.1 develops the failure modes of conflating them.

Three consequences of this definition structure everything downstream:

1. **Information is relative to a prior.** The same observation carries different information to different receivers. A market price of 0.62 is highly informative to a forecaster whose prior was diffuse and nearly uninformative to one whose model already said 0.61. There is no observer-independent "amount of information in" an event — only surprisal relative to a distribution (§6). This is why the lab's edge question is inherently _comparative_: information advantage is a two-forecaster property.
2. **Information is additive over independent resolutions.** Learning two independent facts yields the sum of their individual informations. Logarithms are the unique continuous way to convert multiplicative probability structure into additive information structure — the same additivity that makes log scores sum across city-days into a portfolio-level ledger and makes Kelly growth compound.
3. **Predictability is the complement of entropy.** A process is predictable exactly to the extent that its conditional entropy given the forecaster's information is below its marginal entropy (§9.4). "Randomness" in the forecasting-relevant sense is _residual_ entropy — what remains after conditioning on everything the forecaster knows — not an intrinsic property of the phenomenon. Daily high temperature in Phoenix in July is highly predictable (low conditional entropy given date); the same variable in a transition season carries more residual entropy. Both are "random"; they differ in how much of their entropy the forecaster's information set removes.

### 4.2 Surprise as the atomic unit

The atomic quantity is the **surprisal** of an outcome under a distribution: $-\ln p(y)$. Everything else in this document is an expectation, difference, or decomposition of surprisals: entropy is expected surprisal under the same distribution that assigns the probabilities; cross-entropy is expected surprisal when reality's distribution and the forecaster's distribution differ; KL divergence is the expected _excess_ surprisal from using the wrong distribution; mutual information is the expected surprisal reduction from conditioning. This single-object economy is worth internalizing: when the pipeline logs $-\ln p_i(y_i)$ per settled event, it is recording the atomic measurements from which every information-theoretic diagnostic in this document is estimable.

### 4.3 Why "reducing uncertainty" and not "acquiring truth"

A subtle point with governance consequences: information theory measures _movement between distributions_, not correctness. An observation can be genuinely informative (large surprisal reduction) while moving beliefs _away_ from truth — e.g., an erroneous METAR reading, or a manipulated market price. Expected information gain is non-negative (§10.2), but _realized_ belief movement has no such guarantee, and a system that maximizes information intake without provenance controls maximizes exposure to confident error. This is the information-theoretic restatement of the lab's F1 lesson: the CLI product and raw observations are different information sources about the settlement variable, and conflating them injects a systematic divergence between the distribution the pipeline conditions on and the distribution settlement is drawn from.

---

## 5. Entropy

### 5.1 Definition and interpretation

For a discrete random variable $X$ with pmf $p$ on alphabet $\mathcal{X}$:

$$H(X) = -\sum_{x \in \mathcal{X}} p(x) \ln p(x) = \mathbb{E}_p[-\ln p(X)] \quad \text{(nats)}$$

Entropy is **expected surprisal**: the average information delivered when $X$ is revealed, equivalently the uncertainty held before revelation. Interpretations, all provably equivalent or tightly linked:

- **Coding:** the minimum expected code length for i.i.d. draws of $X$ is $H(X)$ nats per symbol (Shannon's source coding theorem; achievable within one symbol by Huffman/arithmetic coding). ⚑ (theorem attribution standard; Cover & Thomas ch. 5)
- **Counting:** by the asymptotic equipartition property, $n$ i.i.d. draws concentrate on $\approx e^{nH}$ "typical" sequences; entropy is the log of the effective size of the outcome space.
- **Questions (bits):** $H_2(X) = H(X)/\ln 2$ is the minimum expected number of yes/no questions to identify $X$ — the interpretation most useful when explaining bracket forecasting to a non-specialist.
- **Betting:** in Kelly's framework, $H(X)$ is the growth-rate shortfall of a bettor with no information beyond $p$ against fair odds; every nat of entropy removed by side information becomes a nat of achievable log growth (§11.4).

### 5.2 Derivation: why this functional form

Shannon (1948) proved $H$ is the unique (up to base) function satisfying: (i) continuity in the probabilities; (ii) monotone increase in $N$ for uniform distributions; (iii) the grouping/recursivity axiom — uncertainty decomposes consistently when a choice is made in stages. Later axiomatizations (Khinchin 1957 ⚑; Faddeev ⚑) tightened the assumptions. The lab does not need the axiomatics operationally, but should register what they rule out: any "uncertainty index" that is not entropy-like violates either additivity over independent systems or consistency under coarsening — and coarsening consistency matters concretely, because Kalshi brackets _are_ a coarsening of the underlying temperature distribution, and the lab needs uncertainty accounting that behaves coherently when °F-resolution distributions are aggregated into bracket distributions.

Rényi entropies $H_\alpha = \frac{1}{1-\alpha}\ln\sum_i p_i^\alpha$ ⚑ generalize Shannon's ($\alpha \to 1$ recovers it) by relaxing the grouping axiom; they appear in the scoring-rule literature as the entropy functions of non-local proper scores (the Brier score's entropy is the quadratic/Gini entropy $\sum p_i(1-p_i)$, a transform of $H_2^{\text{Rényi}}$). This is the structural reason Brier and log scores rank forecasters differently: they are built on different entropy functionals. See [[Proper Scoring Rules and Calibration - Technical Reference]] §4.

### 5.3 Properties

For finite $\mathcal{X}$ with $|\mathcal{X}| = m$:

1. $0 \le H(X) \le \ln m$; zero iff $X$ is deterministic; maximum iff uniform.
2. **Concavity** in $p$: mixing distributions cannot decrease entropy. Consequence for markets: the entropy of an aggregated (consensus) distribution is at least the average entropy of the aggregated individuals' distributions — pooling forecasts by linear averaging _manufactures apparent uncertainty_ (Ranjan & Gneiting 2010 ⚑ show linear pools are systematically underconfident/miscalibrated even when components are calibrated). Relevant to how the lab reads market prices as pooled beliefs (§14.3).
3. **Conditioning reduces entropy in expectation:** $H(X \mid Y) \le H(X)$, with equality iff independence. _Realized_ conditional entropy $H(X \mid Y = y)$ can exceed $H(X)$ — an observation can legitimately make you less certain (e.g., a discrepant obs that widens the forecast distribution). Only the average over $Y$ is guaranteed to shrink.
4. **Chain rule:** $H(X, Y) = H(X) + H(Y \mid X)$. Joint uncertainty decomposes sequentially; with equality $H(X,Y) = H(X) + H(Y)$ iff independent, and $H(X,Y) \le H(X) + H(Y)$ always (subadditivity).
5. **Invariance:** $H$ depends only on the multiset of probabilities, not on labels — relabeling brackets changes nothing. (Contrast CRPS/RPS, which are distance-sensitive and _do_ use bracket ordering; entropy and log score are label-blind. This is the locality tradeoff, owned by [[Proper Scoring Rules and Calibration - Technical Reference]] §4.2.)

### 5.4 Maximum entropy

Jaynes's principle: among all distributions consistent with known constraints, adopt the one with maximum entropy — the unique choice that is honest about everything not known. Canonical solutions: no constraints on a finite set → uniform; fixed mean on non-negative support → exponential; fixed mean and variance on $\mathbb{R}$ → Gaussian. Formally, the MaxEnt distribution under linear constraints is the exponential-family member with those sufficient statistics.

Three lab-relevant uses:

- **Reference forecasts.** Climatology is (approximately) the MaxEnt forecast given only the historical distribution of the target — which is why it is the canonical skill baseline in [[Forecast Verification]]: skill is information beyond the honest-ignorance benchmark.
- **Prior construction.** When the lab must place a prior with only moment-level knowledge, MaxEnt is the defensible default, and any departure from it is an implicit information claim that should be documented.
- **Interpretation discipline.** MaxEnt is a principle of _inference under stated constraints_, not a claim that nature maximizes entropy. Misapplied, it smuggles in the assumption that the constraint list is complete.

### 5.5 Conditional and joint entropy in the forecasting loop

Write $\Omega_t$ for the lab's information set at forecast issuance and $Y$ for the settlement bracket. The quantity the forecasting system is trying to minimize is $H(Y \mid \Omega_t)$ — residual uncertainty given everything collected. The decomposition $H(Y) = I(Y; \Omega_t) + H(Y \mid \Omega_t)$ splits climatological uncertainty into the part the information set explains (mutual information — the _resolution_ of the system in information units, §13.3) and the irreducible remainder. Every pipeline investment decision (new data stream, longer collection window, better model) is a wager that it increases $I(Y; \Omega_t)$ by more than its cost — a wager that §10.3 and §17 make precise.

### 5.6 Differential entropy: quarantined caveats

For a density $f$, $h(X) = -\int f \ln f$. Unlike discrete entropy it can be negative (a uniform on $[0, 0.1]$ has $h = \ln 0.1 < 0$), is not invariant under change of variables ($h(aX) = h(X) + \ln|a|$), and is _not_ the limit of discrete entropies under refinement (discrete entropy of an $n$-bin quantization diverges like $\log n$). **Differences** of differential entropies, and KL divergences between densities, remain well-behaved and reparameterization-invariant — one more reason the lab's working quantities are divergences and score _differences_, not raw entropies. Since Kalshi brackets discretize temperature for the lab, differential entropy should essentially never appear in pipeline code; if a continuous model (e.g., an EMOS-style predictive density) is ever scored, score it through the bracket probabilities it implies, keeping everything discrete. Proposed as directive D-IT-6 (§23).

---

## 6. Surprisal

### 6.1 Self-information

The **surprisal** (self-information) of outcome $y$ under distribution $p$ is

$$s(y) = -\ln p(y).$$

Properties: $s(y) \ge 0$ (for pmfs); $s(y) = 0$ iff the outcome was certain; $s \to \infty$ as $p(y) \to 0$; additive over independent events ($p_1 p_2 \mapsto s_1 + s_2$). Surprisal is the unique continuous, decreasing, additive function of probability (Cover & Thomas ch. 2 ⚑), which is the honest answer to "why logarithms?": nothing else converts independence into addition.

### 6.2 The logarithmic scale and rare events

The logarithm imposes a specific — and correct — exchange rate on rare events. Moving a forecast probability from 0.50 to 0.25 costs the realized-event surprisal $\ln 2 \approx 0.693$ nats; moving from 0.02 to 0.01 costs the same $\ln 2$. Surprisal prices _relative_ error in probability, not absolute error. The Brier score, by contrast, prices absolute error: the 0.50→0.25 move costs far more Brier than the 0.02→0.01 move. For a trading-oriented lab this is not a matter of taste: returns on a prediction market contract are also relative to price (buying at 0.01 and settling at 1 is a 100× return; at 0.50, 2×), so the log/surprisal scale is the one commensurate with capital. This is the deep reason the log score, not Brier, carries the Kelly identity — and simultaneously the reason the log score is fragile in the tails (§19.2): it takes the tail seriously because the market does.

### 6.3 Coding interpretation, briefly

An outcome with probability $p$ deserves a code word of length $-\log_2 p$ bits in an optimal code; assigning probabilities _is_ designing a code for reality. A forecaster whose distribution is wrong pays, per event, exactly the excess code length $-\ln p(y) + \ln q(y)$ on average $= D_{\mathrm{KL}}(q | p)$ (§8). The lab does not compress anything, but the interpretation earns its keep as intuition: **a forecast is a compression scheme for the future, and verification measures the wasted bits.**

### 6.4 Why forecasting systems naturally reward reducing surprise

Grading a forecaster by mean realized surprisal (the negatively oriented log score / ignorance score) creates the incentive structure the lab wants: (i) it is **strictly proper** — expected surprisal is uniquely minimized by reporting one's true belief (§11.2); (ii) it is **local** — only the probability placed on the realized outcome matters, so the forecaster cannot harvest score from the shape of the distribution over non-events; (iii) it is **unbounded below** — categorical confidence in a wrong outcome is infinitely penalized, which enforces the epistemic humility the lab wants hard-coded (never report 0 or 1 on an uncertain event; the clipping convention that operationalizes this is owned by [[Proper Scoring Rules and Calibration - Technical Reference]] §13.2). A system trained, scored, and paid in surprisal units is a system whose gradient points toward genuine uncertainty reduction rather than toward gaming a bounded metric.

---

## 7. Cross-entropy

### 7.1 Definition and orientation warning

For truth-side distribution $Q$ and forecast $P$ on the same alphabet:

$$H(Q, P) = -\sum_y q(y) \ln p(y) = \mathbb{E}_{Y \sim Q}[-\ln p(Y)].$$

Cross-entropy is **expected surprisal when reality draws from $Q$ but the forecaster prices with $P$**. Orientation warning, registered here once: the literature is inconsistent about argument order, and ML sources often write $H(p, q)$ with $p$ = data, $q$ = model — the _reverse_ of this lab's $q$-truth/$p$-forecast letter convention. In lab documents and code, cross-entropy is always written and named with the truth-side distribution first: `cross_entropy(truth_weights, forecast_probs)`. An argument-order bug here silently swaps forward and reverse KL (§8.3) and is undetectable on symmetric test cases. Proposed as directive D-IT-2 (§23).

### 7.2 The fundamental decomposition

$$H(Q, P) = H(Q) + D_{\mathrm{KL}}(Q | P).$$

Expected surprisal splits into an **irreducible** part — the entropy of reality itself, which no forecaster can beat — and an **excess** part, the KL divergence, which is entirely the forecaster's miscalibration/misinformation and is zero iff $P = Q$. Consequences:

1. **Cross-entropy is minimized, over $P$, uniquely at $P = Q$** (Gibbs' inequality, §8.2). This _is_ the strict propriety of the log score, derived in one line.
2. **The floor is not zero.** A perfect forecaster of a genuinely uncertain event still pays $H(Q)$ per event. Verification targets the gap above the floor, never the floor itself — which is why raw mean log scores across cities with different climatological entropies (Phoenix summer vs. Chicago spring) are not comparable, while _skill relative to climatology_ is. This restates [[Forecast Verification]]'s uncertainty term in information units.
3. **Empirical estimability.** $H(Q)$ and $D_{\mathrm{KL}}(Q|P)$ are separately unobservable (both require $q$), but their sum is estimable without ever knowing $q$: the sample mean of realized surprisals $\frac1N \sum_i -\ln p_i(y_i)$ is an unbiased estimate of expected cross-entropy. This is the quietly remarkable fact the whole verification enterprise stands on — **the lab can estimate its expected excess surprisal relative to another forecaster without access to true probabilities**, because the unobservable $H(Q)$ floor cancels in the difference: $$\mathbb{E}\left[\tfrac1N\textstyle\sum_i \left(\ln p_i(y_i) - \ln r_i(y_i)\right)\right] = D_{\mathrm{KL}}(Q|R) - D_{\mathrm{KL}}(Q|P).$$ Every claim of edge the lab will ever make is an estimate of this displayed quantity (with inference machinery owned by A1).

### 7.3 Why minimizing cross-entropy improves forecasts

Because of §7.2(1): the unique minimizer of expected cross-entropy is the truth. Any procedure that reduces out-of-sample cross-entropy is, by definition, moving the forecast distribution toward the data-generating distribution in the KL sense. This is simultaneously: the justification for maximum likelihood (minimizing empirical cross-entropy _is_ maximizing average log-likelihood — the two phrases denote one computation); the justification for cross-entropy loss in ML classifiers (§15.1); and the justification for the lab's log-score-first verification. One caveat with teeth: minimization is toward truth _in KL geometry_, which weights errors by their surprisal cost, not by their dollar cost under an arbitrary position; the alignment of KL geometry with capital is exactly the Kelly identity, and it holds for log-utility growth, not for every P&L functional (§11.4, [[Kelly Criterion]]).

---

## 8. Kullback–Leibler divergence

### 8.1 Definition and intuition

$$D_{\mathrm{KL}}(Q | P) = \sum_y q(y) \ln \frac{q(y)}{p(y)} = H(Q,P) - H(Q) \ \ge 0.$$

Readings, all exact:

- **Excess surprisal:** average extra nats paid per event for believing $P$ when reality is $Q$.
- **Coding overhead:** expected wasted code length from compressing $Q$-data with a $P$-code.
- **Discrimination information (Kullback–Leibler's own reading):** the expected per-observation weight of evidence, in the sense of the log-likelihood ratio, favoring $Q$ over $P$ when $Q$ is true. Large $D_{\mathrm{KL}}(Q|P)$ = data quickly reveal that $P$ is wrong.
- **Growth rate (Kelly reading):** nats of expected log wealth growth per event available to a $Q$-knowing bettor against $P$-implied prices ([[Log Score and Kelly Identity]]).

### 8.2 Non-negativity (Gibbs' inequality)

$D_{\mathrm{KL}}(Q|P) \ge 0$ with equality iff $Q = P$, by Jensen's inequality applied to the concave $\ln$: $\sum q \ln(p/q) \le \ln \sum q \cdot (p/q) = \ln \sum p \le 0$. Two engineering corollaries: (i) expected information gain is non-negative (§10.2); (ii) no forecaster can have positive expected log-score edge over the truth — and hence no bettor can have positive expected log growth against truth-equal prices, the information-theoretic statement of an unbeatable market (§14.2).

### 8.3 Asymmetry, and which direction the lab uses

$D_{\mathrm{KL}}(Q|P) \ne D_{\mathrm{KL}}(P|Q)$ in general; KL is not a metric (no symmetry, no triangle inequality). The asymmetry is informative, not a defect:

- **Forward KL** $D_{\mathrm{KL}}(Q|P)$ (truth first) is _mean-seeking / zero-avoiding_: it explodes where $q > 0$ but $p \approx 0$, i.e., it savagely punishes assigning near-zero probability to things that happen. This is the direction verification uses — it is the excess-surprisal direction, the direction the log score estimates, and the direction whose penalty structure enforces "never be certain and wrong."
- **Reverse KL** $D_{\mathrm{KL}}(P|Q)$ is _mode-seeking / zero-forcing_: it tolerates $p \approx 0$ where $q > 0$ but punishes putting mass where truth has none. Variational inference minimizes this direction (for tractability), which is the root cause of variational posteriors being overconfident — an ML-side fact the lab should remember when evaluating uncertainty-aware models (§15.4, §20.7).

Symmetrized alternatives — Jeffreys divergence $D(Q|P) + D(P|Q)$ ⚑, Jensen–Shannon divergence (bounded, $\sqrt{\text{JSD}}$ a metric) ⚑ — exist and occasionally appear in model-comparison literature, but they sever the exact links to scoring, likelihood, and growth. The lab's convention: **forward KL, truth-side first, everywhere**; other divergences only with explicit written justification. Proposed as directive D-IT-3.

### 8.4 KL and Bayesian updating

Bayes' theorem is, in information terms, the statement that observing data $D$ moves the belief distribution by exactly the information in $D$: posterior $\pi(\theta \mid D) \propto \pi(\theta) L(D \mid \theta)$, and the realized information gained is $D_{\mathrm{KL}}(\pi(\cdot\mid D) ,|, \pi(\cdot))$. Three structural facts (developed in §10 and §12): the expected gain is Lindley's measure of the experiment; the log marginal likelihood that scores the model _is_ a sequence of realized log scores (§12.2); and minimizing forward KL to the truth is asymptotically what Bayesian posterior concentration does (the posterior concentrates on the KL-closest model in the support of the prior — Berk 1966 ⚑ for the misspecified case). Bayesian inference is uncertainty accounting in KL currency; [[Bayesian Statistics]] owns the full treatment.

### 8.5 Hypothesis testing rates: how fast wrongness is revealed

Chernoff–Stein lemma (Cover & Thomas ch. 11 ⚑): testing $P$ vs. $Q$ with fixed type-I error, the type-II error decays as $e^{-n D_{\mathrm{KL}}(P|Q)}$. Sanov's theorem ⚑ generalizes: the probability that an empirical distribution from $Q$ looks like it came from a set $E$ decays as $e^{-n \min_{P \in E} D_{\mathrm{KL}}(P|Q)}$. Lab translation: **KL divergence is the exchange rate between divergence size and sample size.** A candidate edge of $\delta$ nats/event needs on the order of $1/\delta$ events (times a factor set by desired error rates and per-event score variance — formal power arithmetic owned by A1) to distinguish from zero. This is why the accrual clock is the binding constraint: at ~150 city-days/month, the smallest edge worth hypothesizing is bounded below by what three months of city-days can resolve. Small divergences are real quantities that are simply _expensive to see_ — the information-theoretic version of the lab's effective-sample-size discipline ([[Effective Sample Size]]).

### 8.6 Pinsker's inequality: from nats to probability distance

$$|Q - P|_{TV} \le \sqrt{\tfrac12 D_{\mathrm{KL}}(Q|P)}.$$

Total variation distance — the maximum difference in probability the two distributions assign to any event, and hence a bound on the maximum per-contract mispricing — is controlled by KL. Useful direction for the lab: a measured log-score edge of $\delta$ nats/event implies the market's implied distribution differs from (the lab's estimate of) truth by at most $\sqrt{\delta/2}$ in TV; conversely, tiny KL means every bracket price is nearly right, bounding the exploitable per-contract discrepancy. The inequality is loose but the direction of control is the operationally relevant one.

---

## 9. Mutual information

### 9.1 Definition and equivalent forms

$$I(X;Y) = D_{\mathrm{KL}}\big(P_{XY} ,|, P_X \otimes P_Y\big) = H(X) - H(X\mid Y) = H(Y) - H(Y\mid X) = H(X) + H(Y) - H(X,Y).$$

Mutual information is the KL divergence between the joint distribution and the independence hypothesis: the information one variable carries about another, symmetric, non-negative, zero iff independent. Because it is a KL divergence, everything in §8 applies; because of the conditional-entropy form, it is exactly **expected uncertainty reduction**: how many nats of entropy about $Y$ (settlement bracket) are removed, on average, by observing $X$ (a feature, a forecast, a price).

### 9.2 Dependence beyond correlation

$I(X;Y) = 0$ iff $X \perp Y$ — full stop, any dependence, any shape. Correlation detects only linear dependence; MI detects all of it (at the price of harder estimation, §9.5). For jointly Gaussian variables the two coincide: $I = -\frac12 \ln(1-\rho^2)$, a useful calibration point (e.g., $\rho = 0.5 \Rightarrow I \approx 0.144$ nats). The **data-processing inequality** — for a Markov chain $X \to Y \to Z$, $I(X;Z) \le I(X;Y)$ — is the theorem with the most governance content per symbol: _no deterministic or stochastic processing of a data stream can increase the information it carries about the target._ Feature engineering can only reformat, concentrate, or destroy information; it cannot create it. Any pipeline stage that claims to have "added signal" has actually added either (a) an external information source or (b) noise dressed as signal.

### 9.3 Feature relevance and its limits

MI between a candidate feature and the target is the canonical filter-style relevance measure (used across the feature-selection literature ⚑). Two structural cautions before the lab ever uses it:

1. **Relevance is not additive.** Features can be individually useless and jointly informative (XOR-type interactions: $I(X_1;Y) = I(X_2;Y) = 0$ yet $I(X_1,X_2;Y) > 0$) and individually informative but jointly redundant ($I(X_1,X_2;Y) < I(X_1;Y) + I(X_2;Y)$). Univariate MI screening is a heuristic, not a guarantee; the object that matters is the joint $I(\text{feature set}; Y)$, which is exactly what is hard to estimate.
2. **Estimated MI is not usable MI.** MI upper-bounds what any model could extract; it says nothing about whether the lab's model class extracts it, at what sample cost, or whether it survives the market's fee threshold. High-MI features license _model-building effort_, not edge claims.

### 9.4 Predictability as mutual information

The information-theoretic predictability literature (Kleeman 2002, _J. Atmos. Sci._ ⚑; DelSole 2004 ⚑; DelSole & Tippett 2007, _Rev. Geophys._ ⚑; antecedents in Leung & North 1990 ⚑) defines predictability of $Y$ from information set $\Omega$ as $I(Y;\Omega) = H(Y) - H(Y\mid\Omega)$, or the expected KL divergence of forecast distribution from climatology. This makes "how predictable is the Phoenix daily high at issuance time $t$?" a well-posed measurable quantity with a ceiling: the lab's realizable skill is bounded by $I(Y;\Omega_t)$ for the $\Omega_t$ it actually collects — and A3's collection-sufficiency question is precisely whether the lab's $\Omega_t$ preserves the $I$ available in the NWS issuance stream it samples (data-processing inequality again: a collector that drops forecast issuances strictly loses information that is unrecoverable later).

### 9.5 Estimation is the hard part

MI must be estimated from samples, and naive plug-in estimators are biased upward (finite samples manufacture spurious dependence; the Miller–Madow correction ⚑ removes the leading $\frac{(|\mathcal{X}|-1)(|\mathcal{Y}|-1)}{2N}$ bias term for discrete variables). For continuous variables, binning choices dominate results; k-NN estimators (Kraskov–Stögbauer–Grassberger 2004 ⚑) and neural estimators (MINE, Belghazi et al. 2018 ⚑) exist, with the latter known to be high-variance. Lab policy proposal (D-IT-5): any reported MI estimate must carry (i) the estimator name, (ii) sample size, and (iii) a permutation-null baseline — the MI the same estimator reports when the target is shuffled — before it may inform any design decision. An MI number without a null is testimony, not measurement.

---

## 10. Information gain and Bayesian updating

### 10.1 Realized information gain

When data $D$ updates prior $\pi_0(\theta)$ to posterior $\pi_1(\theta) = \pi_0(\theta)L(D\mid\theta)/p(D)$, the **realized information gain** is $D_{\mathrm{KL}}(\pi_1 | \pi_0)$ — how far, in nats, the evidence moved the belief. It is always $\ge 0$ as a divergence, but note carefully what is _not_ guaranteed: the posterior can be _more_ entropic than the prior (surprising data legitimately widen beliefs), and the movement can be toward a wrong region if the data are corrupted (§4.3). Information gain measures belief displacement, not belief improvement.

### 10.2 Expected information gain (Lindley 1956)

Before observing, the expected gain from an experiment/observation channel is

$$\mathrm{EIG} = \mathbb{E}_D\big[D_{\mathrm{KL}}(\pi(\cdot\mid D),|,\pi(\cdot))\big] = I(\Theta; D),$$

the mutual information between parameter and data. It is non-negative, zero iff the data are uninformative about $\theta$, and bounded by both $H(\Theta)$ and $H(D)$ — you cannot learn more about a quantity than the uncertainty it has, nor more than the data channel carries. Equivalent form: EIG = prior predictive entropy minus expected likelihood entropy, $H(D) - \mathbb{E}_\theta[H(D\mid\theta)]$, often the computable one.

### 10.3 Value of evidence, in the lab's terms

EIG is the correct currency for the lab's recurring resource questions:

- **Which data streams to collect (A3):** the value of a stream is $I(Y_{\text{settlement}}; \text{stream} \mid \text{streams already collected})$ — _conditional_ MI, because a stream redundant with existing collection has near-zero marginal EIG regardless of its standalone MI. The unrecoverability of NWS forecast issuance history is an EIG statement: a stream not collected at issuance time has its information permanently destroyed, and no later processing recovers it (data-processing inequality, applied to time).
- **When to stop refining a model:** when the marginal EIG of further model complexity, estimated out-of-sample, is inside the noise floor of the score-difference estimator (A1's territory).
- **Sequential design / active learning (§20.4):** choose the next observation to maximize EIG — greedy information maximization, near-optimal under submodularity conditions ⚑.

The caution from §17.4 applies: EIG prices information for a _learner_; the _trader's_ value of information is routed through decisions and can be zero even when EIG is large.

---

## 11. Proper scoring rules from information theory

_(Full treatment: [[Proper Scoring Rules and Calibration - Technical Reference]]. This section states only the information-theoretic core, from the IT side of the bridge.)_

### 11.1 The logarithmic score

$S_{\log}(p, y) = \ln p(y)$ (positively oriented, nats; the ignorance score is the same object in bits, negated). It is the surprisal with sign flipped: scoring by log score **is** paying forecasters in negative surprisal.

### 11.2 Strict propriety, one line

$\mathbb{E}_{Y\sim Q}[S_{\log}(P, Y)] = -H(Q, P) = -H(Q) - D_{\mathrm{KL}}(Q|P)$, uniquely maximized over $P$ at $P = Q$ by Gibbs' inequality. Honesty is the unique optimum; the strict propriety of the log score is Gibbs' inequality wearing verification clothing. Moreover the _value_ at the optimum is $-H(Q)$: **the entropy of the target is the expected score of the perfect forecaster** — the general Gneiting–Raftery structure (every proper score corresponds to a concave entropy function; the score's divergence is the entropy's Bregman divergence ⚑) instantiated at Shannon entropy. The log score's special status among proper scores: it is the unique smooth, strictly proper, **local** score for alphabets with ≥3 outcomes (locality theorem — precise statement and scope conditions owned by [[Proper Scoring Rules and Calibration - Technical Reference]] §4.2), the unique one whose expected value is Shannon cross-entropy, and the unique one denominated in the currency of likelihood, evidence, and capital growth.

### 11.3 Expected log score differences are KL differences

Restating the load-bearing display from §7.2(3): for two forecasters $P$ (lab) and $R$ (market),

$$\mathbb{E}_Q[\text{log-score edge}] = D_{\mathrm{KL}}(Q|R) - D_{\mathrm{KL}}(Q|P).$$

Edge is _relative divergence from truth_. Three readings: the lab profits by being **less wrong** than the market, not by being right; an efficient market ($R = Q$) makes the first term zero and every $P$'s edge non-positive; and the estimator of the left side needs no access to $Q$ (realized score differences suffice), which is what makes edge detection empirically possible at all. [[Edge Detection]] operationalizes this; A1 owns the inference.

### 11.4 The Kelly identity (summary; owned by [[Log Score and Kelly Identity]])

For a binary contract at price $r$, a log-utility bettor with belief $p$ achieves expected log growth $\mathbb{E}_q[\ln \text{growth}] = D_{\mathrm{KL}}(q|r) - D_{\mathrm{KL}}(q|p)$ — identical to §11.3. Kelly (1956) and Cover & Thomas ch. 6 generalize: with side information $X$, the achievable growth-rate increment is $I(Y; X)$ — **mutual information is the growth rate of money**, the single most direct monetization of an information-theoretic quantity in all of applied mathematics. The identity chain the lab's architecture hangs on:

$$\text{expected log-score edge} ;=; \text{KL information advantage} ;=; \text{Kelly growth rate (pre-cost)}.$$

V1 measures the first, V2 validates it statistically, V3 (gated) deploys the third. Costs enter as a threshold on the shared quantity, not a modification of the identity.

---

## 12. Bayesian connections

### 12.1 Posterior entropy and the direction of inference

Bayesian updating does not monotonically shrink entropy per observation (§10.1), but in expectation it does — $\mathbb{E}_D[H(\Theta \mid D)] \le H(\Theta)$ — and under regularity, posterior entropy decreases asymptotically like $\frac{k}{2}\ln\frac{1}{n}$-type rates ⚑ as data accumulate. Inference is expected-uncertainty reduction, purchased at the rate the likelihood's information about $\theta$ allows (the Fisher information appears here as the local curvature of KL: $D_{\mathrm{KL}}(p_\theta | p_{\theta+d\theta}) \approx \frac12 d\theta^\top \mathcal{I}(\theta), d\theta$ — Fisher information is infinitesimal KL, the bridge between information theory and classical asymptotics ⚑).

### 12.2 Evidence is accumulated log score

The log marginal likelihood of a model $M$ on a data sequence factorizes by the chain rule:

$$\ln p(D_{1:N} \mid M) = \sum_{i=1}^{N} \ln p(D_i \mid D_{1:i-1}, M).$$

Each term is the **log score of the model's one-step-ahead predictive distribution** on the datum that then arrived. Bayesian model evidence _is_ the model's cumulative prequential log score (Dawid's prequential principle, 1984 ⚑): model comparison by Bayes factors and forecaster comparison by log-score differences are one procedure. Consequences: (i) evidence automatically penalizes complexity — a model spreading predictive mass over many possibilities scores worse per event (MacKay's Occam factor reading ⚑); (ii) the lab's forecast-verification ledger, kept in per-event log scores, is simultaneously a Bayesian model-comparison ledger, with no additional machinery.

### 12.3 Belief updating as divergence minimization

The posterior is the solution to a variational problem: $\pi_1 = \arg\min_{\rho} { D_{\mathrm{KL}}(\rho | \pi_0) - \mathbb{E}_\rho[\ln L(D\mid\theta)] }$ ⚑ (the "Bayes as optimization" / Gibbs-posterior form, e.g. Zellner 1988 ⚑, Bissiri et al. 2016 ⚑). Bayes' rule moves beliefs the minimum KL distance consistent with fully absorbing the likelihood evidence — a conservation principle: no information invented, none discarded. Under misspecification, the posterior concentrates on the KL-projection of truth onto the model class (Berk 1966 ⚑) — the Bayesian machine converges to the _least-wrong_ model in exactly the divergence that scoring measures, which is why a misspecified-but-KL-close model can still carry tradeable edge (§11.3: being less wrong is enough).

---

## 13. Forecast verification through the information lens

_(Full framework: [[Forecast Verification]]. Here: the information-theoretic reading of its core attributes.)_

### 13.1 The joint distribution is the information channel

Murphy–Winkler's verification object — the joint distribution $p(f, y)$ of forecasts and observations — is, information-theoretically, a **channel** from reality to forecast. Verification quantities are functionals of this channel; $I(F;Y)$ is its capacity actually used.

### 13.2 Calibration and reliability

A forecaster is calibrated if $\Pr(Y = 1 \mid F = f) = f$. In the log-score decomposition of Weijs et al. (2010) ⚑ ★, the **reliability** term is $\mathbb{E}_F\big[D_{\mathrm{KL}}\big(\bar{o}(F) ,|, F\big)\big]$ — the average divergence of conditional outcome frequencies from the forecasts that were issued. Calibration is _zero average divergence between what you said and what happened conditional on what you said_: not a vibe, a KL quantity, estimable by the binning/CORP machinery owned by [[Proper Scoring Rules and Calibration - Technical Reference]] §7.

### 13.3 Resolution, discrimination, sharpness

The **resolution** term of the same decomposition is $\mathbb{E}_F\big[D_{\mathrm{KL}}\big(\bar{o}(F) ,|, \bar{o}\big)\big]$ — how far conditional outcome rates move from climatology when sorted by forecast — and its idealized ceiling is $I(F;Y)$: resolution is the mutual information the forecast system captures about the outcome ⚑. The full decomposition reads, in nats:

$$\underbrace{\mathbb{E}[-\ln p(y)]}_{\text{mean surprisal}} = \underbrace{H(\bar o)}_{\text{uncertainty (climatological entropy)}} - \underbrace{\text{RES}}_{\text{information captured}} + \underbrace{\text{REL}}_{\text{information misstated}}.$$

**Better forecasts contain more usable information** is now a theorem-shaped sentence: minimize mean surprisal by maximizing captured information (RES → $I(F;Y)$) while keeping stated probabilities faithful (REL → 0). Sharpness — concentration of the forecast distributions, low $H(F(\cdot))$ per issued forecast — is desirable _only subject to calibration_ (Gneiting, Balabdaoui & Raftery 2007 ⚑: "maximize sharpness subject to calibration"): unconditional sharpness is just low entropy, and low entropy while wrong is the maximal-surprisal catastrophe (§20.3). Discrimination (ROC-style separation of outcome classes by forecasts) is the same channel viewed from the $p(f \mid y)$ factorization.

### 13.4 Skill scores in information units

The log-skill score relative to climatology, $1 - H(Q,P)/H(\bar o)$-style or as a raw nat difference, measures the _fraction/amount of climatological uncertainty the system removes_. The lab's convention (inherited from [[Proper Scoring Rules and Calibration - Technical Reference]] §2): report raw nats/event for anything feeding growth or edge arithmetic, dimensionless skill only for cross-city or cross-season comparability.

---

## 14. Prediction markets

### 14.1 Markets as information-aggregation devices

The theoretical claim descending from Hayek (1945, "The Use of Knowledge in Society" ⚑) is that prices aggregate dispersed private information no single agent holds. For prediction markets specifically, the empirical literature (Wolfers & Zitzewitz 2004, _J. Econ. Perspectives_ ⚑; Berg et al. on the Iowa Electronic Markets ⚑) finds prices that are competitive with — frequently better-calibrated than — polls and expert panels, with known systematic deviations (§14.4). The lab's stance is instrumental: whether markets aggregate optimally is an open question (§14.5); _that the price defines an implied forecast which can be scored like any other forecaster_ is not. The market is forecaster $R$ in the §11.3 display, no more privileged than that — but no less: it aggregates information the lab does not collect, and beating it requires an information source or processing advantage the aggregation has not already absorbed.

### 14.2 Efficiency is an information statement

An efficient market in the lab's operational sense is $R = Q$ on the σ-algebra of available information: prices equal true conditional probabilities given public information (Fama 1970's semi-strong form ⚑, restated distributionally). Then $D_{\mathrm{KL}}(Q|R) = 0$ and §11.3 forces every forecaster's edge $\le 0$: **market efficiency and market unbeatability are the same KL statement.** The Grossman–Stiglitz paradox (1980, _AER_ ⚑ ★) supplies the equilibrium reason markets cannot be _perfectly_ efficient: if prices were fully revealing, information acquisition would be uncompensated, no one would acquire it, and prices would carry none — so equilibrium requires mispricing sufficient to pay the marginal information gatherer. The paradox is the lab's macro-level license to look for edge, and simultaneously its warning: equilibrium mispricing is sized to _costs_ (data, infrastructure, fees), so persistent edge net of costs is only available to entrants with below-equilibrium costs or off-equilibrium information sources. Weather brackets are a candidate precisely because the marginal information gatherer there may be under-resourced — a hypothesis to be measured, not assumed.

### 14.3 Price discovery and belief aggregation mechanics

How individual beliefs become one price matters for interpreting $R$:

- **Order-book markets (Kalshi):** the "market forecast" is not a single object — bid, ask, mid, and last trade are different functionals of the book, and the _executable_ price differs by side. Which functional defines $R$ for scoring is exactly A4's normalization decision (pre-committed before divergence measurement); the information-theoretic point is that scoring the wrong functional measures divergence from a forecaster nobody can trade against. [[Market Microstructure]] owns the mechanics.
- **Market-scoring-rule markets (Hanson 2003, 2007 ⚑ ★):** Hanson's LMSR makes the connection literal — the automated market maker _is_ a shared log scoring rule; each trader moves the market distribution and is paid the log-score improvement of the new distribution over the old, realized at settlement. Trading is sequential collaborative forecasting, paid in surprisal units; the subsidy bounds the market-maker's loss by the entropy of the initial distribution. Even though Kalshi is order-book, LMSR is the clean theoretical model of "prices as collective forecast" and the source of intuition for why thin markets under-aggregate.
- **Pooling caveats:** if the price behaves like a linear pool of participant beliefs, §5.3(2) applies — linear pools are systematically underconfident even from calibrated individuals (Ranjan & Gneiting 2010 ⚑), predicting a specific, testable market miscalibration signature (extreme-probability contracts priced toward the middle), which overlaps observationally with the favorite–longshot bias.

### 14.4 Known deviations

The favorite–longshot bias (longshots overpriced, favorites underpriced; documented from racetracks — Thaler & Ziemba 1988 ⚑ — through modern event markets ⚑) is the canonical persistent miscalibration. Candidate mechanisms — risk-love, probability weighting (Kahneman–Tversky ⚑), liquidity/fee structure at extreme prices, pooling artifacts (§14.3) — matter to the lab only through their _stability_: a stable miscalibration of $R$ is a standing nonzero $D_{\mathrm{KL}}(Q|R)$ concentrated in tail brackets, i.e., structurally located edge. Whether Kalshi temperature tails exhibit it is an empirical question for V2, pre-registered, not assumed from the racetrack literature.

### 14.5 Do prediction markets maximize information?

The honest synthesis: **no theorem says so, and the mechanisms cut both ways.** For: incentive-compatible aggregation (traders profit exactly by moving price toward their information — Hanson's framing), continuous updating, self-selection of informed participants. Against: Grossman–Stiglitz equilibrium mispricing; thin-market noise (weather brackets are small); manipulation and herding dynamics ⚑; information _withholding_ (a strongly informed trader's optimal execution reveals slowly — Kyle 1985 ⚑, owned by [[Market Microstructure]]); and the microstructure wedge between belief and executable price (fees, spread, tick size). The lab's operational resolution: treat "the market maximizes information" as neither premise nor straw man — measure $R$'s calibration and resolution with the same instrument used on the lab's own forecasts, and let the verification ledger say how much information the price actually contains.

---

## 15. Machine learning

### 15.1 Cross-entropy loss is the log score

Training a probabilistic classifier by cross-entropy loss minimizes $\frac1N \sum_i -\ln p_\theta(y_i \mid x_i)$ — the empirical mean surprisal, i.e., the negatively oriented log score, i.e., the negative average log-likelihood. Three names, one computation. Everything from §11 transfers: cross-entropy training is strictly proper (its population optimum is the true conditional distribution $q(y\mid x)$), so a sufficiently flexible model trained to convergence on enough data _should_ output calibrated conditional probabilities — and the interesting ML fact is that modern deep networks often don't (§15.2). The identity also licenses the lab to treat any ML model that emits bracket probabilities as just another forecaster in the ledger, scored, decomposed, and compared with zero special treatment ([[Machine Learning]]'s trust principle: trust in proportion to output verifiability, not method sophistication).

### 15.2 Calibration of learned probabilities

Guo et al. (2017, ICML, "On Calibration of Modern Neural Networks" ⚑ ★) documented that high-capacity networks are systematically overconfident despite being trained on a proper loss — the optimization/regularization path, not the loss's population optimum, governs finite-sample behavior. Standard remedies (temperature scaling, Platt scaling, isotonic regression) are post-hoc recalibration maps; the governance law the lab has already ratified applies with full force: **a recalibrated model is a new registered forecaster, scored from its registration date only** — recalibrating on the evaluation sample and reporting the improved score is in-sample laundering. Expected Calibration Error, the ML literature's default metric, is a binned estimate with known instabilities; the lab's calibration instrument remains the CORP/decomposition machinery of [[Proper Scoring Rules and Calibration - Technical Reference]].

### 15.3 Information bottleneck and representation learning

The information-bottleneck program (Tishby, Pereira & Bialek 1999 ⚑; deep variational IB, Alemi et al. 2017 ⚑) formalizes representation learning as compressing input $X$ into representation $Z$ that preserves information about target $Y$: maximize $I(Z;Y) - \beta I(Z;X)$. The claim that SGD training implicitly performs IB compression (Shwartz-Ziv & Tishby 2017 ⚑) is **contested** — replications found the reported compression phase depends on activation choices and estimator artifacts (Saxe et al. 2018 ⚑) — a live dispute the lab should cite as unresolved if cited at all. The uncontested content: the data-processing inequality bounds what any representation can retain, and the compression/prediction tradeoff is a real design axis.

### 15.4 Uncertainty estimation

The decomposition the ML literature converged on (Kendall & Gal 2017 ⚑): **aleatoric** uncertainty (irreducible outcome entropy, $H(Y\mid X)$ under the true channel — the §7.2 floor) versus **epistemic** uncertainty (the model's ignorance of the channel, in principle reducible with data — posterior uncertainty over $\theta$). Estimation approaches: Bayesian neural nets and variational approximations (with the reverse-KL overconfidence caveat, §8.3), MC dropout (Gal & Ghahramani 2016 ⚑), and **deep ensembles** (Lakshminarayanan et al. 2017 ⚑), which are the pragmatic consensus performer for predictive uncertainty ⚑. Information-theoretic diagnostic worth knowing: the mutual information between predictions and model posterior, $I(Y; \theta \mid x)$ — expected disagreement among ensemble members — isolates the epistemic component (the BALD quantity, §20.4). For the lab: epistemic uncertainty is precisely the component that should shrink as the accrual clock runs, and a model whose stated uncertainty fails to shrink with data is leaking information somewhere.

### 15.5 Feature selection, restated

§9.3's cautions govern. The additional ML-specific trap: MI-based selection performed on the full dataset before cross-validation leaks target information into the evaluation — selection is part of the model and must live inside the resampling loop. This is the information-theoretic form of the multiplicity discipline the Analysis Run Log exists to enforce.

---

## 16. Weather forecasting applications

### 16.1 Ensembles are entropy made operational

Modern NWP quantifies uncertainty by integrating an ensemble of perturbed initial conditions and model physics (Leutbecher & Palmer 2008, _J. Comp. Phys._ ⚑ ★; ECMWF ENS, NOAA GEFS). The ensemble is a Monte Carlo sample from the forecast distribution; its dispersion estimates the conditional entropy $H(Y \mid \Omega_t)$ as a function of lead time. Flow-dependent predictability — some synoptic situations are intrinsically more predictable than others — is the meteorological name for $H(Y\mid \Omega_t)$ varying by regime, and it is the physical basis for the lab's expectation that edge, if it exists, is regime-dependent rather than uniform (transition seasons, boundary-bracket days, and low-spread ridge days are different information environments).

### 16.2 From ensemble to probabilities

Raw ensembles are biased and underdispersive; converting members to calibrated probabilities is the statistical postprocessing problem: Bayesian model averaging (Raftery et al. 2005, _MWR_ ⚑) and nonhomogeneous Gaussian regression / EMOS (Gneiting et al. 2005, _MWR_ ⚑) are the canonical methods, both typically _fit by optimizing a proper score_ (CRPS or log score) — the verification instrument doubling as the training objective, the same collapse of learning into scoring as §15.1. If the lab ever postprocesses public ensemble output into bracket probabilities, this literature is the starting point, and the bracket discretization (integrate the postprocessed density over bracket bounds, mind the settlement rounding convention — standing ⚑ on the NWS rounding rule at boundaries) is where lab-specific care concentrates.

### 16.3 Information gain from observations: data assimilation

Data assimilation — merging observations into model state — is Bayesian updating at scale, and its information accounting is explicitly KL/entropy-based: degrees of freedom for signal and Shannon information content quantify how many effective independent quantities an observing system contributes (Rodgers 2000, _Inverse Methods for Atmospheric Sounding_ ⚑; Fisher 2003, ECMWF tech memo ⚑). Lab-scale translation of the same idea: each collected stream (CLI reports, forecast issuances, market snapshots) has a measurable marginal information contribution to settlement prediction (§10.3), and A3's sufficiency audit is a miniature observing-system experiment.

### 16.4 The ignorance score's meteorological career

Roulston & Smith (2002) ⚑ ★ introduced IGN to meteorology with the explicitly information-theoretic argument that it measures the additional bits a user needs to determine the outcome given the forecast, and connected it to gambling returns — the meteorological literature independently rediscovering the Kelly bridge. Subsequent debate (Benedetti 2010 ⚑ arguing log-score primacy; the locality-vs-sensitivity debate owned by [[Proper Scoring Rules and Calibration - Technical Reference]]) settled into the current pluralism: log score for information/growth accounting, CRPS/RPS for distance-sensitive diagnosis. The lab inherits exactly that division of labor.

---

## 17. Decision theory and the value of information

### 17.1 Information is instrumentally valued through decisions

Decision theory prices information by its effect on achievable expected utility. Given decision problem $(A, U)$ and belief $\pi$, the **value of information** from observing $X$ is

$$\mathrm{VoI}(X) = \mathbb{E}_X\Big[\max_{a \in A} \mathbb{E}[U(a, \theta) \mid X]\Big] - \max_{a \in A} \mathbb{E}_\pi[U(a, \theta)]$$

(Raiffa & Schlaifer 1961 ⚑; Howard 1966, "Information Value Theory" ⚑ ★). VoI is non-negative for a rational agent observing _free_ information (Blackwell 1953 ⚑: a more informative experiment is more valuable for every decision problem) — and, crucially, it is **zero whenever the optimal action is unchanged by every possible realization of $X$**. Information that cannot alter a decision is worthless to that decision, however many nats it carries.

### 17.2 EIG ≠ VoI

Expected information gain (§10.2) is decision-free; VoI is decision-relative. They coincide only when utility is the log score itself (Bernardo 1979: pure inference as a decision problem with log-score utility). For the lab this is the formal reason measurement (V1) and trading (V3) are different objects: V1 maximizes an EIG-like quantity (learn the joint distribution of forecasts, prices, outcomes); V3's VoI is routed through position, fees, and bankroll, and an information advantage below the cost threshold has _negative_ trading VoI while retaining positive learning value.

### 17.3 The Kelly special case

Under log utility with a complete market, VoI of side information equals its mutual information with the outcome (§11.4) — the unique utility for which decision value and information quantity coincide exactly. This coincidence is the entire justification for using information-theoretic quantities as the lab's spine: for the growth-optimal criterion, information _is_ value, with no exchange-rate ambiguity. Fractional Kelly and drawdown constraints ([[Kelly Criterion]], V3-gated) deliberately break the exact coincidence in exchange for variance control.

### 17.4 When additional information is not valuable

Cataloged failure modes, each of which the lab will meet:

1. **Decision-irrelevance:** VoI = 0 when no realization changes the action (§17.1). Collecting streams that cannot move a bracket probability past a trade threshold has zero V3-value (but may retain V1 learning value — state which value is claimed).
2. **Cost dominance:** net VoI = gross VoI − acquisition cost; Grossman–Stiglitz equilibrium (§14.2) implies market-relevant information tends to be priced near its cost.
3. **Redundancy:** conditional MI given existing streams can be near zero despite high marginal MI (§10.3).
4. **Processing limits:** the data-processing inequality caps what the lab's models extract; unmodelable information has no realizable value.
5. **Strategic settings:** Blackwell's theorem assumes a single decision-maker. In games/markets, more _public_ information can reduce welfare or destroy insurance opportunities (Hirshleifer 1971 ⚑), and revealing one's own information through trading is costly (Kyle 1985 ⚑). "More information is always better" is a single-agent theorem about free information — every qualifier matters.

---

## 18. Market applications

### 18.1 Edge detection is divergence estimation

Restated once more because it is the document's center of gravity: the lab's edge object is $D_{\mathrm{KL}}(Q|R) - D_{\mathrm{KL}}(Q|P)$, estimated by realized log-score differences against the executable, fee-relevant market forecast (A4 defines $R$; A1 defines the inference; [[Edge Detection]] defines the workflow; disagreement Δ between $p$ and $r$ is _not_ edge until the statistical validation gate passes). The information-theoretic contribution to that workflow is structural: it says what the estimand _is_, why it is estimable without $q$, what sample sizes it demands (§8.5), and what its units mean for capital (§11.4).

### 18.2 Information asymmetry and microstructure

The microstructure canon models prices as the output of an inference performed by market makers against potentially informed order flow: Kyle (1985 ⚑) — informed traders optimally spread their information over time, and price impact λ measures the information content per unit of net order flow; Glosten–Milgrom (1985 ⚑) — the bid–ask spread is compensation for adverse selection, i.e., **the spread is the price of trading against possible information**. Two lab consequences: (i) the spread component of costs is not friction noise, it is an information-asymmetry charge, and a lab that actually has information is exactly the counterparty the spread is priced against; (ii) order flow and price dynamics are themselves an information stream about other participants' beliefs — one the lab's collectors capture as book snapshots. Full treatment: [[Market Microstructure]].

### 18.3 Arbitrage and internal coherence

Pure arbitrage is the zero-information edge: prices violating probability axioms (bracket sets summing above/below 1 beyond fees, or violating monotonicity across strikes) are exploitable regardless of any forecast. Dutch-book coherence is probability theory's foundation ([[Probability]]); its market form is a _coherence scan_ over related contracts — cheap to run on collected snapshots, informative about market quality even when unexploitable after fees, and a useful canary: markets incoherent internally are unlikely to be well-calibrated externally.

### 18.4 Liquidity as information capacity

Thin books aggregate less: with few participants, idiosyncratic beliefs and inventory effects dominate price formation, and single orders move price by more than their information content justifies (§14.5). Practical reading for weather brackets: liquidity metrics (depth, spread, trade frequency — collected per snapshot) index how much weight $R$ deserves as a forecast, and market-quality stratification belongs in the pre-registered analysis plan rather than post-hoc excuse-making when divergences concentrate in illiquid series.

---

## 19. Computational considerations

### 19.1 Work in log space, always

Probabilities underflow; log-probabilities don't. Multiply never, add always. Normalization and mixtures use **log-sum-exp** with max-subtraction: $\ln \sum_i e^{a_i} = m + \ln \sum_i e^{a_i - m}$, $m = \max_i a_i$ (`scipy.special.logsumexp`). Products of hundreds of per-event likelihoods, posterior updates, and mixture forecasts are all sums in log space. Float64 throughout the scoring path; float32 halves the safe dynamic range and its ~$10^{-7}$ relative error is material after $10^4$-term accumulations (pairwise/Kahan summation if ledgers grow long ⚑).

### 19.2 The boundary problem

$-\ln p \to \infty$ as $p \to 0$: one zero-probability realized outcome destroys a cumulative log-score ledger. The mathematical fact is not a bug (§6.4 — the unbounded penalty is the incentive), but the _numerical and governance_ handling must be fixed in advance: the lab's clipping convention (ε floor, applied at scoring time, logged when triggered) is registered in [[Proper Scoring Rules and Calibration - Technical Reference]] §13.2 and is not restated here (single home). The information-theoretic footnote: clipping at ε caps per-event surprisal at $-\ln \varepsilon$, which caps estimated KL divergences — every divergence estimate downstream inherits the cap, so clip-trigger counts must be reported alongside any KL/edge estimate (proposed D-IT-4).

### 19.3 Zeros, sparsity, and the support problem

$D_{\mathrm{KL}}(Q|P) = \infty$ whenever $Q$ puts mass where $P$ puts none. In estimation this bites through _empirical_ distributions: a bracket never observed in a finite sample has empirical probability zero, making KL estimates in either direction fragile. Standard handling: additive (Laplace/Krichevsky–Trofimov ⚑) smoothing for empirical pmfs, with the smoothing constant recorded as an analysis choice (pre-registration discipline applies — smoothing is a prior); Miller–Madow or jackknife bias correction for plug-in entropy/MI (§9.5); and a hard rule that support mismatches are _surfaced_, not silently absorbed: if a forecast assigns zero to a bracket the market prices at nonzero, that is a modeling event worth logging, not a NaN to be smoothed away.

### 19.4 Implementation recommendations

- Compute $p \ln p$ terms via `scipy.special.xlogy(p, p)` (returns 0 at $p=0$, matching the $0\ln 0 = 0$ convention) and $q\ln(q/p)$ via `scipy.special.rel_entr(q, p)` (elementwise KL kernel; `sum` it; returns `inf` on support violations rather than hiding them). `scipy.stats.entropy(q, p)` computes KL directly but silently renormalizes its inputs — prefer the explicit kernel plus an assertion that inputs already sum to 1 within tolerance.
- Store per-event surprisals (nats, float64, with forecast id, market snapshot id, clip flag) as the atomic ledger record; every aggregate in this document is a fold over that table. Never store only aggregates.
- Property-test the identities: `H(q,p) - H(q) == KL(q,p)`, `KL(q,q) == 0`, `I(X;Y) >= 0`, chain rules — cheap invariant checks that catch orientation and normalization bugs (extend the reconciliation-suite pattern of [[Proper Scoring Rules and Calibration - Technical Reference]] §13.4).
- Unit-tag every stored information quantity (`nats`); convert to bits only in rendering.

---

## 20. Common misconceptions

**20.1 "Information = data."** Data is carrier; information is uncertainty reduction relative to a receiver's prior (§4.1). Terabytes can carry zero; one bit can be decisive. Corollary the lab must resist: collection volume is not an information metric — marginal conditional MI is (§10.3).

**20.2 "Entropy = disorder."** A physics-adjacent metaphor that misleads in inference. Entropy is a property of a _distribution_ (an epistemic state), not of an arrangement of stuff. The same physical system has different entropies to differently informed observers (Jaynes's resolution of the Gibbs-paradox family ⚑). In this lab, "high entropy" means "we are uncertain," never "the weather is messy."

**20.3 "Low entropy is always good."** Low _forecast_ entropy (sharpness) is good only subject to calibration (§13.3). A confidently wrong forecast is the worst object the log score knows. Rank objectives: calibration first, then sharpness — never sharpness alone.

**20.4 "Information always has value."** True only for free information, a single decision-maker, and decisions it could change (§17.4). In markets, information can be worthless (below cost threshold), self-defeating to reveal (Kyle), or welfare-destroying when public (Hirshleifer).

**20.5 "Randomness = information."** A maximum-entropy source has maximal information _rate_ in the coding sense and zero _predictable_ structure. Forecasting value lives in mutual information — the dependence between observables and target — not in marginal entropy. High-entropy targets are hard, not rich.

**20.6 "KL divergence is a distance."** Asymmetric, no triangle inequality; direction is a modeling choice with opposite failure modes (§8.3). Any lab artifact using KL must state direction explicitly in the truth-side-first convention.

**20.7 "A tighter posterior means better inference."** Reverse-KL variational approximations and overfit models produce confidently narrow posteriors that are wrong (§8.3, §15.2, §15.4). Posterior narrowness is claimed information; only verification (out-of-sample scores) converts the claim into evidence. This is Invariant 3 in mathematical form: stated confidence is testimony until graded.

**20.8 "The market price is the market's probability."** The price is a microstructure artifact — a functional of a book with spread, fees, tick size, and inventory effects. Extracting an implied _forecast_ from it is a normalization with decisions attached (A4). Scoring "the market" before fixing that normalization measures divergence from an ill-defined forecaster.

---

## 21. Research Lab integration

How this document underpins each neighbor, with the ownership arrow stated:

- **[[Probability]]** — supplies the primitive (probability as claim conditional on an information state; population-grading principle). This document adds the calculus that _quantifies_ information states and their changes. Direction: Probability is upstream; nothing here overrides it.
- **[[Bayesian Statistics]]** — Bayesian updating is KL-accounted belief revision (§8.4, §12); evidence is cumulative log score (§12.2); the core identity (log-score edge = KL advantage = Kelly growth) is already stated there and is _restated, not re-derived_, here. Shared custody of §12 content; Bayesian mechanics owned there.
- **[[Proper Scoring Rules and Calibration - Technical Reference]]** — owns scoring conventions, the locality theorem, decompositions, CORP, clipping ε. This document supplies the entropy/divergence substrate those objects live on (§11) and defers to it on every convention.
- **[[Forecast Verification]]** — owns the verification framework and D-FV directives. §13 here is the information-units reading of its reliability/resolution/uncertainty structure; where numerical conventions differ, FV + PSR govern.
- **[[Prediction Markets]]** — owns market institutional detail. §14 supplies the aggregation-theoretic reading (efficiency as $R=Q$; LMSR as shared log score; Grossman–Stiglitz as the license to search).
- **[[Kelly Criterion]]** (V3-gated) — owns sizing. This document supplies the identity that makes sizing meaningful (§11.4) and the asymmetry warning's information reading: overbetting is betting on information you do not have.
- **[[Expected Value]]** — EV epistemology ("the arithmetic is trivial, the epistemology is the entire project") is §7.2(3) in prose: every EV is conditional on a $p$ whose divergence from $q$ is the real object.
- **[[Edge Detection]]** — owns the workflow Δ → validation → edge. This document defines the estimand (§18.1) and its sample-size economics (§8.5).
- **[[Machine Learning]]** — cross-entropy loss, calibration, uncertainty decomposition (§15); the trust principle restated information-theoretically: verifiability of output = the score ledger; sophistication of method = testimony.
- **[[Market Microstructure]]** — owns Kyle/Glosten–Milgrom mechanics; §18.2 imports only the information-asymmetry reading of spread and impact.
- **A1 (Statistical Validity & Inference Framework)** — every estimator this document motivates (score differences, MI estimates, calibration terms) hands its _inference_ to A1. This document deliberately states no confidence-interval procedures.
- **A3 / A4** — §10.3 gives A3 its EIG framing (collection sufficiency = preserved mutual information); §14.3 and §20.8 give A4 its motivation (the market forecast $R$ must be defined before divergence from it is meaningful).

---

## 22. Current research frontiers

- **Uncertainty-aware deep learning.** Deep ensembles vs. Bayesian NNs vs. conformal methods for calibrated predictive distributions; the aleatoric/epistemic decomposition's identifiability limits (Kendall & Gal 2017 ⚑; subsequent critiques ⚑). Open: reliable epistemic uncertainty under distribution shift — precisely the regime a seasonal weather forecaster inhabits.
- **Bayesian deep learning & probabilistic programming.** Scalable posterior approximation (variational methods, SGMCMC ⚑) with the reverse-KL overconfidence problem unresolved at scale; probabilistic programming (Stan, PyMC, NumPyro) making the §12 accounting executable — the lab's likely tooling when hierarchical station/city models arrive.
- **Information bottleneck.** Whether deep learning's generalization is IB-compressible remains contested (§15.3); the variational IB objective is meanwhile a usable regularizer independent of the theory dispute.
- **Active learning / optimal experimental design.** BALD (Houlsby et al. 2011 ⚑) and scalable EIG estimation (Foster et al. 2019+ ⚑) operationalize Lindley at modern scale. Lab-shaped open question: sequential design for _data collection under budget_ — which market snapshots and which issuance times carry the most conditional information per storage/API dollar.
- **Adaptive/online forecasting.** Prequential evaluation (Dawid ⚑), online learning with log loss, universal prediction (Merhav & Feder 1998 ⚑), and regret bounds measured in nats — the theory of forecasters that must update as the accrual clock runs, with guarantees that hold without stationarity assumptions the weather does not satisfy.
- **Machine-learned weather models.** Post-2022 ML NWP (GraphCast, Pangu-Weather, FourCastNet ⚑; probabilistic successors such as GenCast ⚑) reorganized the cost structure of ensemble generation; their probabilistic calibration versus operational ENS is an active verification literature directly relevant to any future lab use of public ML forecasts. ⚑ (fast-moving area; verify current state before load-bearing use)
- **Information in market design.** Automated market makers descending from LMSR (constant-function market makers, liquidity-sensitive variants ⚑); manipulation-resistance and information-elicitation guarantees; peer-prediction mechanisms for unverifiable events ⚑. Open: how order-book prediction markets' aggregation quality varies with subsidy/liquidity — the question §18.4 needs answered empirically.
- **Autonomous decision systems.** The alignment-adjacent question of decision-making under quantified uncertainty with audit trails — the lab's own architecture (pre-registration, evidence grading, gated deployment) is a small instance of a pattern this literature is still formalizing.

Open questions the lab itself carries forward: the executable-price normalization (A4); the boundary/clipping cap's effect on KL edge estimates (§19.2); whether weather-bracket tails exhibit favorite–longshot structure (V2 pre-registration candidate); minimum detectable edge given the accrual rate (A1 power arithmetic).

---

## 23. Engineering takeaways and proposed directives

**Principles (prose form).** Work in nats, in log space, in float64, truth-side first. Store surprisals, not summaries. Every information estimate is an estimate: it carries an estimator name, a sample size, and (for MI/entropy) a bias story and a null. Information is comparative (edge is two-forecaster), conditional (value is marginal given what's already collected), and decision-relative (EIG is not VoI). The data-processing inequality is a budget constraint: collection creates option value that processing can only spend. Calibration before sharpness; verification before trust; and the only exchange rate between information and money the lab may use without further argument is the Kelly identity, whose scope conditions live in [[Kelly Criterion]].

**Proposed directives** (E4, pending A-series absorption and Architect ratification; numbering continues house convention):

- **D-IT-1 (Units).** All stored information quantities are in nats, float64, unit-tagged. Bit conversions occur only at the reporting layer. (Extends the PSR §2 convention beyond scores to all information quantities.)
- **D-IT-2 (Orientation).** Cross-entropy and KL are always written and coded truth-side-first: `cross_entropy(truth, forecast)`, `kl(truth, forecast)` = forward KL. Reverse KL or symmetrized divergences require written justification in the analysis plan.
- **D-IT-3 (Divergence direction).** Edge estimands are forward-KL differences per §11.3/§18.1; no other divergence may be substituted in an edge claim.
- **D-IT-4 (Clip transparency).** Any reported KL/edge/log-score aggregate must report the count and identity of clip-triggered events (ε convention owned by PSR §13.2), since clipping caps the estimand.
- **D-IT-5 (MI hygiene).** No MI or entropy estimate informs a design decision without: estimator name, N, bias correction stated, and a permutation-null baseline.
- **D-IT-6 (Discrete pipeline).** Differential entropy does not appear in pipeline code; continuous predictive densities are scored through the bracket probabilities they imply.
- **D-IT-7 (Atomic ledger).** Per-event surprisal records (nats, forecast id, market snapshot id, clip flag, timestamp pair) are the atomic verification objects; aggregates are derived, never primary.
- **D-IT-8 (Identity property tests).** The reconciliation suite includes information-identity checks: $H(Q,P) = H(Q) + D(Q|P)$ on synthetic cases, $D(Q|Q)=0$, $I \ge 0$, chain rules, and an asymmetric-KL orientation canary case.

**Common mistakes, ranked by expected damage:** (1) orientation swaps (silent, symmetric-case-invisible — D-IT-2/8); (2) treating disagreement Δ as edge (governance, owned by [[Edge Detection]]); (3) unclipped or silently clipped boundary events corrupting ledgers (D-IT-4); (4) MI estimates without nulls driving feature decisions (D-IT-5); (5) $\ln$/$\log_2$ mixing corrupting growth arithmetic by 0.693× (D-IT-1); (6) in-sample recalibration laundering (§15.2, governance already ratified); (7) comparing raw mean log scores across different-entropy targets (§7.2(2)).

---

## 24. Annotated bibliography

> [!warning] Every entry is E4 bibliographic testimony pending verification. ★ = Tier 1 (verify before any load-bearing citation; these feed A-series decisions or registered conventions). Ranking within tiers is by long-term importance to this lab.

### Tier 1 — Foundational, verify first

1. ★ **Shannon, C. E. (1948). "A Mathematical Theory of Communication." _Bell System Technical Journal_ 27: 379–423, 623–656.** The source: entropy, mutual information, source/channel coding, the axiomatization. Read Part I; the forecasting content is all there.
2. ★ **Kelly, J. L. Jr. (1956). "A New Interpretation of Information Rate." _BSTJ_ 35: 917–926.** Information rate = growth rate. The origin of the lab's V3 spine; short, readable, and the single most lab-relevant paper on this list.
3. ★ **Kullback, S. & Leibler, R. A. (1951). "On Information and Sufficiency." _Annals of Mathematical Statistics_ 22: 79–86.** The divergence, framed as discrimination information — the lab's edge estimand descends directly from it.
4. ★ **Cover, T. M. & Thomas, J. A. (2006). _Elements of Information Theory_, 2nd ed. Wiley.** Default theorem reference. Chapters 2 (entropy/MI), 6 (gambling — mandatory), 11 (Sanov/Stein), 12 (MaxEnt).
5. ★ **Gneiting, T. & Raftery, A. E. (2007). "Strictly Proper Scoring Rules, Prediction, and Estimation." _JASA_ 102: 359–378.** The scoring consolidation; the entropy–score–divergence correspondence in general form. Co-owned citation with PSR.
6. ★ **MacKay, D. J. C. (2003). _Information Theory, Inference, and Learning Algorithms_. Cambridge UP.** The bridge text: inference as communication, Occam factors, model comparison. Free PDF from the author's site (verify link).
7. ★ **Grossman, S. J. & Stiglitz, J. E. (1980). "On the Impossibility of Informationally Efficient Markets." _American Economic Review_ 70: 393–408.** The equilibrium logic of why edge can exist and why it is sized to costs. Governs the lab's macro-thesis.
8. ★ **Roulston, M. S. & Smith, L. A. (2002). "Evaluating Probabilistic Forecasts Using Information Theory." _Monthly Weather Review_ 130: 1653–1660.** IGN score; the meteorological Kelly bridge; the closest published ancestor of the lab's verification stance.
9. ★ **Hanson, R. (2007). "Logarithmic Market Scoring Rules for Modular Combinatorial Information Aggregation." _Journal of Prediction Markets_ 1: 3–15.** (2003 working version ⚑.) Markets as shared log scoring rules — the theoretical model of price-as-forecast.
10. ★ **Lindley, D. V. (1956). "On a Measure of the Information Provided by an Experiment." _Annals of Mathematical Statistics_ 27: 986–1005.** EIG; the foundation of A3's value-of-collection reasoning.

### Tier 2 — Core supporting

11. **Jaynes, E. T. (1957). "Information Theory and Statistical Mechanics." _Physical Review_ 106: 620–630.** MaxEnt. Pair with **Jaynes (2003), _Probability Theory: The Logic of Science_** for the full epistemology.
12. **Good, I. J. (1952). "Rational Decisions." _JRSS B_ 14: 107–114.** The log score proposed, with Bayesian and betting justifications — pre-dates most of the verification literature.
13. **Weijs, S. V., van Nooijen, R. & van de Giesen, N. (2010). "Kullback–Leibler Divergence as a Forecast Skill Score with Classic Reliability–Resolution–Uncertainty Decomposition." _Monthly Weather Review_ 138: 3387–3399.** §13's decomposition; every term a KL.
14. **Murphy, A. H. & Winkler, R. L. (1987). "A General Framework for Forecast Verification." _Monthly Weather Review_ 115: 1330–1338.** The joint-distribution framing (§13.1). Co-owned with FV.
15. **Bernardo, J. M. (1979). "Expected Information as Expected Utility." _Annals of Statistics_ 7: 686–690.** Log score as the unique inference utility; the EIG–VoI bridge.
16. **Blackwell, D. (1953). "Equivalent Comparisons of Experiments." _Annals of Mathematical Statistics_ 24: 265–272.** The "more information never hurts" theorem and its exact scope.
17. **Howard, R. A. (1966). "Information Value Theory." _IEEE Trans. Systems Science and Cybernetics_ 2: 22–26.** VoI as an engineering discipline.
18. **Cover, T. M. (1991). "Universal Portfolios." _Mathematical Finance_ 1: 1–29.** Growth-rate optimality without distributional assumptions; the robust end of the Kelly program.
19. **Kyle, A. S. (1985). "Continuous Auctions and Insider Trading." _Econometrica_ 53: 1315–1335.** and **Glosten, L. & Milgrom, P. (1985). "Bid, Ask and Transaction Prices…" _J. Financial Economics_ 14: 71–100.** Information asymmetry priced into spread and impact. Co-owned with [[Market Microstructure]].
20. **Wolfers, J. & Zitzewitz, E. (2004). "Prediction Markets." _Journal of Economic Perspectives_ 18(2): 107–126.** The standard empirical survey; calibration evidence and caveats.
21. **Leutbecher, M. & Palmer, T. N. (2008). "Ensemble Forecasting." _Journal of Computational Physics_ 227: 3515–3539.** Why and how NWP quantifies uncertainty.
22. **DelSole, T. & Tippett, M. K. (2007). "Predictability: Recent Insights from Information Theory." _Reviews of Geophysics_ 45.** ⚑ Predictability as MI; the ceiling on realizable skill.
23. **Hayek, F. A. (1945). "The Use of Knowledge in Society." _American Economic Review_ 35: 519–530.** The aggregation thesis in original form.

### Tier 3 — Machine learning and estimation

24. **Guo, C., Pleiss, G., Sun, Y. & Weinberger, K. Q. (2017). "On Calibration of Modern Neural Networks." _ICML_.** Overconfidence of deep nets; temperature scaling. Governs how the lab reads any NN probability.
25. **Lakshminarayanan, B., Pritzel, A. & Blundell, C. (2017). "Simple and Scalable Predictive Uncertainty Estimation using Deep Ensembles." _NeurIPS_.** The pragmatic uncertainty baseline.
26. **Kendall, A. & Gal, Y. (2017). "What Uncertainties Do We Need in Bayesian Deep Learning for Computer Vision?" _NeurIPS_.** Aleatoric/epistemic decomposition.
27. **Gal, Y. & Ghahramani, Z. (2016). "Dropout as a Bayesian Approximation." _ICML_.** MC dropout.
28. **Tishby, N., Pereira, F. & Bialek, W. (1999). "The Information Bottleneck Method." _Allerton_.** With **Alemi et al. (2017), "Deep Variational Information Bottleneck," _ICLR_** and the **Shwartz-Ziv & Tishby (2017) ⚑ / Saxe et al. (2018) ⚑** dispute pair — cite the dispute, not one side.
29. **Kraskov, A., Stögbauer, H. & Grassberger, P. (2004). "Estimating Mutual Information." _Physical Review E_ 69: 066138.** ⚑ The k-NN MI estimator; with **Paninski (2003), "Estimation of Entropy and Mutual Information," _Neural Computation_** ⚑ on why plug-in estimation is biased.
30. **Houlsby, N., Huszár, F., Ghahramani, Z. & Lengyel, M. (2011). "Bayesian Active Learning by Disagreement." arXiv:1112.5745.** ⚑ BALD; EIG operationalized for models.
31. **Raftery, A. E. et al. (2005) "Using Bayesian Model Averaging to Calibrate Forecast Ensembles," _MWR_ 133** and **Gneiting, T. et al. (2005) "Calibrated Probabilistic Forecasting Using Ensemble Model Output Statistics…," _MWR_ 133.** Postprocessing canon, if the lab ever ingests ensembles.

### Tier 4 — Context and history

32. **Hartley, R. V. L. (1928). "Transmission of Information." _BSTJ_ 7: 535–563.** The logarithmic measure.
33. **Wiener, N. (1948). _Cybernetics_. MIT Press.** The forecasting route to entropy.
34. **Kullback, S. (1959). _Information Theory and Statistics_. Wiley.** The statistical program in full.
35. **Dawid, A. P. (1984). "Present Position and Potential Developments: Some Personal Views. Statistical Theory: The Prequential Approach." _JRSS A_ 147: 278–292.** ⚑ Prequential evaluation — the lab's ledger philosophy avant la lettre.
36. **Thaler, R. & Ziemba, W. (1988). "Anomalies: Parimutuel Betting Markets." _J. Econ. Perspectives_ 2(2): 161–174.** ⚑ Favorite–longshot survey.
37. **Hirshleifer, J. (1971). "The Private and Social Value of Information and the Reward to Inventive Activity." _AER_ 61: 561–574.** ⚑ When public information destroys value.
38. **Merhav, N. & Feder, M. (1998). "Universal Prediction." _IEEE Trans. Information Theory_ 44: 2124–2147.** ⚑ Prediction without stationarity; log-loss regret.

---

## Appendix — Canonization checklist for the Architect

1. Spot-verify Tier-1 bibliography (items 1–10) against originals; resolve ⚑ on the Hanson 2003/2007 versioning, DelSole–Tippett venue, and the Weijs et al. page range.
2. Confirm the §2 conventions (nats; truth-side-first orientation; $0\ln 0 = 0$) do not conflict with any registered PSR/FV convention — they are intended as extensions, not amendments.
3. Ratify, amend, or defer the proposed D-IT-1…8 directives; recommended absorption path is A1 (D-IT-4, 5, 8) and the Engineering Playbook (D-IT-1, 2, 3, 6, 7).
4. Confirm boundary assignments in the Ownership callout with [[Proper Scoring Rules and Calibration - Technical Reference]], [[Forecast Verification]], and [[Log Score and Kelly Identity]] to prevent dual ownership.
5. Note that §22's ML-weather-model entries are fast-moving and should carry a revisit date if canonized.
6. Grade and stamp.