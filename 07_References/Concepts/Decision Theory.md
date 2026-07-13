## title: "Decision Theory" aliases: ["Decision Theory", "Bayesian Decision Theory", "Statistical Decision Theory", "Decision Theory — Technical Reference"] vault_location: "07 References/Concepts" level: "Quantitative researcher reference" status: "AI-drafted v1 — E4, awaiting Architect ratification per Invariant 3; NOT canonical until ratified" created: 2026-07-12 review: 2027-01-12 tags: [decision-theory, bayesian-decision-theory, statistical-decision-theory, utility-theory, expected-utility, value-of-information, sequential-decisions, kelly, canon-candidate]

# Decision Theory — Research Synthesis

**Vault location:** `07 References/Concepts` **Level:** Quantitative researcher reference (assumes probability theory, Bayesian inference, and the scoring-rule material; overlaps deliberately with [[Expected Value]], [[Kelly Criterion]], and [[Information Theory for Forecasting]] §17) **Cross-links:** [[Probability]] · [[Bayesian Statistics]] · [[Information Theory for Forecasting]] · [[Expected Value]] · [[Kelly Criterion]] · [[Log Score and Kelly Identity]] · [[Proper Scoring Rules and Calibration - Technical Reference]] · [[Forecast Verification]] · [[Prediction Markets]] · [[Market Microstructure]] · [[Statistical Learning Theory]] · [[Machine Learning]] · [[Edge Detection]] · [[Effective Sample Size]] · [[Glossary]] · [[Open Questions]] · [[Research Methodology v2 Canonical]] **Status:** Version 1 — draft, **E4** (AI-drafted testimony), ungraded pending Architect verification and canonization (Invariant 3) **Created:** 2026-07-12 **Tags:** #decision-theory #expected-utility #bayes-risk #value-of-information #canon-candidate

> [!warning] Epistemic status (Invariant 3) This document is AI-drafted testimony, not evidence. Every bibliographic citation was produced from model knowledge without live retrieval and **must be independently verified (title, year, venue, page-level claims) before any statement here becomes load-bearing in a registration or ADR**. Lower-confidence citations carry ⚑ per house convention; ★ marks the priority verification tier (entries directly feeding A-series decisions or registered conventions). The synthesis of _ideas_ is believed faithful to the literature; bibliographic metadata is the most fragile layer. Canonizing this document as "current reference" does **not** discharge individual ⚑ flags.

> [!info] Ownership boundaries One home per convention. This document **owns** the lab's decision-theoretic vocabulary — states, actions, loss, utility, risk, Bayes action, admissibility, EVPI/EVSI, the normative/descriptive distinction — and the _general_ theory of converting probabilistic beliefs into actions. It **does not own**: the Kelly–log-score identity and its derivation (owned by [[Log Score and Kelly Identity]]); bet sizing machinery and fractional Kelly (owned by [[Kelly Criterion]], V3-gated); score orientation, units, and clipping (owned by [[Proper Scoring Rules and Calibration - Technical Reference]]); the edge estimand and its inference (owned by [[Edge Detection]] and, once ratified, **A1**); EV bookkeeping at executable prices (owned by [[Expected Value]]); fee/spread mechanics (owned by [[Market Microstructure]]); information-theoretic vocabulary (owned by [[Information Theory for Forecasting]]). Where this document and a ratified A-series document disagree, the A-series document governs.

> [!note] Scope discipline Reference document, not an ADR. Nothing here modifies the methodology, the city-day unit, the reference ladder, the V1→V2→V3 gating, or any settled decision. Decision machinery proposed here (thresholds, loss specifications, act sets) is _candidate_ design, ratified only through the normal ADR process. In particular, nothing in this document authorizes trading: the lab is in V1 (measurement), and every trading-flavored example below is stated as theory that the V3 gate would one day instantiate.

---

## 1. Purpose and scope

This is the lab's canonical reference on **how probabilistic beliefs are converted into actions** — the missing arrow at the end of every other document in the corpus. [[Probability]] defines what a belief is; [[Bayesian Statistics]] defines how beliefs update; [[Proper Scoring Rules and Calibration - Technical Reference]] and [[Forecast Verification]] define how beliefs are graded; [[Prediction Markets]] and [[Market Microstructure]] define the mechanism the lab's beliefs will eventually confront; [[Kelly Criterion]] defines one particular action rule. Decision theory is the framework in which all of these are special cases: a decision problem is a triple (states, actions, consequences), a probabilistic forecast is a belief over states, a loss function encodes what consequences cost, and the whole apparatus exists to answer one question — _given what I believe and what mistakes cost, what should I do?_

Two theses organize the document.

**Thesis 1 — separation of belief and value.** A rational decision factorizes into a _belief_ component (a probability distribution over states, produced and graded by the forecasting machinery) and a _value_ component (a utility or loss function over consequences, chosen by the decision-maker). The optimal action is then a deterministic function of both: maximize posterior expected utility. This separation is not a convenience; it is a theorem (Savage, 1954), and it is the deep reason the lab can build a _measurement instrument_ (V1) before ever specifying a trading policy (V3). Beliefs can be manufactured, stored, and verified independently of the actions they will someday drive. The forecast pipeline is the belief factory; decision theory is the specification for the consumer of its output.

**Thesis 2 — the forecast is not the decision.** The highest-probability outcome is not in general the best action; maximizing forecast accuracy is not in general maximizing realized value; and a better probability does not automatically imply a different action. The mapping from beliefs to actions passes through the loss function, and the loss function can make a 3% probability of an expensive event more action-relevant than a 60% probability of a cheap one. Every misconception catalogued in §20 is a failure to keep this mapping explicit. For this lab specifically: **disagreement Δ is a belief-level quantity; a trade is an action-level quantity; the entire microstructure dead zone lives in the gap between them.**

This is deliberately **not** a survey of descriptive decision theory. Prospect theory, framing effects, and the heuristics-and-biases program appear only where they explain _market counterparty behavior_ (the favorite–longshot bias documented in [[Prediction Markets]] and [[Edge Detection]] is, from this document's standpoint, a population of decision-makers deviating from expected utility in a directional way). The lab's own machinery is normative by construction: an autonomous system has no cognitive biases to describe, only a specification to get right or wrong.

Scope boundaries with neighboring documents are stated in the ownership callout above and revisited in §21.

---

## 2. Conventions and notation

**Primitive objects.** Θ\Theta Θ denotes the **state space** (states of nature θ∈Θ\theta \in \Theta θ∈Θ); A\mathcal{A} A the **action space** (actions a∈Aa \in \mathcal{A} a∈A); X\mathcal{X} X the **sample space** of observable data xx x. A **consequence** is determined by the pair (θ,a)(\theta, a) (θ,a). The **loss function** is L:Θ×A→RL : \Theta \times \mathcal{A} \to \mathbb{R} L:Θ×A→R, with the statistician's sign convention (loss is minimized); the **utility function** is u:Θ×A→Ru : \Theta \times \mathcal{A} \to \mathbb{R} u:Θ×A→R (utility is maximized), and where both appear, L=−uL = -u L=−u up to an affine rescaling that never changes an optimal action. Decision-theory literature splits roughly along field lines — statistics minimizes loss, economics maximizes utility — and this document uses whichever is native to the result being stated, flagging conversions.

**Beliefs.** Following the corpus-wide convention of [[Log Score and Kelly Identity]] and [[Information Theory for Forecasting]] §2: qq q is the **true / data-generating distribution** (an idealization the pipeline never observes), pp p is the **lab's forecast**, rr r is the **market-implied forecast**. Priors over Θ\Theta Θ are π(θ)\pi(\theta) π(θ); posteriors are π(θ∣x)\pi(\theta \mid x) π(θ∣x). Where a result is stated for a generic belief without corpus role, plain PP P is used.

**Decision rules.** A (non-randomized) **decision rule** is a function δ:X→A\delta : \mathcal{X} \to \mathcal{A} δ:X→A mapping data to actions. The **risk function** is R(θ,δ)=Ex∼θ[L(θ,δ(x))]R(\theta, \delta) = \mathbb{E}_{x \sim \theta}[L(\theta, \delta(x))] R(θ,δ)=Ex∼θ​[L(θ,δ(x))] — frequentist expectation over data at fixed state. The **Bayes risk** is r(π,δ)=Eθ∼π[R(θ,δ)]r(\pi, \delta) = \mathbb{E}_{\theta \sim \pi}[R(\theta, \delta)] r(π,δ)=Eθ∼π​[R(θ,δ)]. The **posterior expected loss** of action aa a given data xx x is ρ(a∣x)=Eθ∼π(⋅∣x)[L(θ,a)]\rho(a \mid x) = \mathbb{E}_{\theta \sim \pi(\cdot \mid x)}[L(\theta, a)] ρ(a∣x)=Eθ∼π(⋅∣x)​[L(θ,a)]. Keeping these three expectations distinct — over data, over states, over both — is half the discipline of reading the statistical literature; §9 lays out the ledger.

**Units.** Where log utility or information quantities appear, natural logarithms (**nats**) are the working unit, inherited from the registered convention in [[Proper Scoring Rules and Calibration - Technical Reference]] §2. Monetary quantities in examples are in contract-price units ([0,1][0,1] [0,1] per \$1 Kalshi contract) unless stated.

**Discrete first.** The lab's V1 instrument concerns Kalshi temperature brackets — finite, mutually exclusive, exhaustive outcome sets per city-day. All core results are stated for finite Θ\Theta Θ and A\mathcal{A} A; measure-theoretic generality is invoked only where a result genuinely requires it (complete class theorems, §9.5) and quarantined there.

---

## 3. Historical development

The history matters here for a practical reason: the modern synthesis — Bayesian decision theory as implemented in every serious autonomous system — is the confluence of three originally separate streams (utility, subjective probability, statistical decision rules), and knowing which stream a concept came from predicts which assumptions it silently carries.

### 3.1 Bernoulli: utility resolves the St. Petersburg paradox

Daniel Bernoulli (1738, _Specimen theoriae novae de mensura sortis_; English translation _Econometrica_ 1954) confronted the St. Petersburg game: a fair coin is flipped until the first heads at flip nn n, paying 2n2^n 2n ducats. The expected payout is ∑n2−n⋅2n=∞\sum_n 2^{-n} \cdot 2^n = \infty ∑n​2−n⋅2n=∞, yet no one will pay more than a few ducats to play. Bernoulli's resolution: people value _utility_, not money, and utility is concave in wealth — he proposed u(w)=ln⁡wu(w) = \ln w u(w)=lnw, under which the game's expected utility is finite and modest. Two ideas of permanent importance are born here: (i) **diminishing marginal utility** — the next ducat matters less the more you have; (ii) **maximize expected utility, not expected value**. The lab meets both again in §16: Bernoulli's exact utility function, ln⁡w\ln w lnw, is the Kelly criterion's objective, and the St. Petersburg lesson — unbounded EV can coexist with bounded willingness to pay — is the ancestral form of "overbetting a positive-EV opportunity destroys bankrolls" ([[Kelly Criterion]]).

### 3.2 Bayes and Laplace: probability as the calculus of belief

Thomas Bayes (1763, posthumously, "An Essay towards solving a Problem in the Doctrine of Chances") supplied inverse probability — updating a prior over an unknown parameter from observations — and Laplace (1774; 1812, _Théorie analytique des probabilités_) generalized it into a working method, including explicitly decision-flavored results: Laplace showed that under absolute-error loss the best estimate is the posterior median, and under squared error the posterior mean — statistical decision theory a century and a half before the name. The Bayesian stream contributes the _belief_ half of the modern synthesis: probability as a degree of belief that a rational agent updates by conditioning. See [[Bayesian Statistics]] for the full treatment.

### 3.3 Ramsey and de Finetti: subjective probability from betting behavior

Frank Ramsey ("Truth and Probability," 1926, published 1931) and Bruno de Finetti (1931; 1937, "La prévision: ses lois logiques, ses sources subjectives") independently derived subjective probability _from_ decision-making rather than assuming it. Ramsey showed that an agent with consistent preferences over gambles implicitly carries both a utility function and a subjective probability measure — the first representation theorem, predating von Neumann–Morgenstern. De Finetti's operational route is the one this lab should internalize: define your probability of an event as the price at which you are indifferent between buying and selling a $1 contract on it, and prove (the **Dutch book theorem**) that prices immune to guaranteed-loss arbitrage must satisfy the probability axioms. On a prediction market venue this is not a metaphor — it is a literal description of the instrument. A Kalshi price _is_ a de Finetti previsione published by a mechanism, and coherence is the minimal rationality standard for both the lab's forecasts and its reading of the market ([[Prediction Markets]], [[Probability]]). De Finetti also contributed exchangeability and the representation theorem that grounds "learning from experience" without assuming objective chances.

### 3.4 Von Neumann and Morgenstern: axiomatizing expected utility

Von Neumann & Morgenstern (_Theory of Games and Economic Behavior_, 1944; axioms in the 1947 2nd ed.) proved that an agent whose preferences over _lotteries with known probabilities_ satisfy four axioms (§7) behaves _as if_ maximizing the expectation of a utility function unique up to positive affine transformation. This converts "maximize expected utility" from Bernoulli's proposal into a theorem: EU-maximization is not one policy among many but the unique representation of consistent preference. The restriction to _known_ probabilities (risk, not uncertainty) is the seam Savage later closed.

### 3.5 Wald: statistical decision theory

Abraham Wald (_Statistical Decision Functions_, 1950; sequential analysis 1947) unified estimation, hypothesis testing, and experimental design as special cases of a single object: a decision rule δ:X→A\delta : \mathcal{X} \to \mathcal{A} δ:X→A evaluated by its risk function R(θ,δ)R(\theta, \delta) R(θ,δ). Wald contributed the **minimax** criterion (guard against the worst state), the study of **admissibility** (never use a rule dominated everywhere by another), and — decisive for the Bayesian synthesis — the **complete class theorems**: under broad conditions, every admissible rule is a Bayes rule for some prior, or a limit of Bayes rules (§9.5). Wald's frequentist machinery thus ends up _certifying_ the Bayesian recipe: if you insist only on not being dominated, you are already committed to acting like a Bayesian with _some_ prior; the remaining argument is only about which prior. His sequential probability ratio test (SPRT) is also the ancestor of every optional-stopping and sequential-monitoring result the lab's A1 framework must eventually take a position on.

### 3.6 Savage: the full subjectivist synthesis

Leonard Savage (_The Foundations of Statistics_, 1954) merged the streams: from seven postulates on preferences over _acts_ (functions from states to consequences), with **no probabilities assumed anywhere**, he derived simultaneously a unique subjective probability over states and a utility over consequences such that preferences maximize subjective expected utility. This is the deepest available justification for the lab's architecture: an agent that is coherent in Savage's sense _necessarily decomposes_ into a belief module and a value module (Thesis 1, §1). Savage's sure-thing principle (P2) is the axiom that both the Allais and Ellsberg paradoxes (§7.4, §13) target; knowing that locates precisely where the normative theory is contested.

### 3.7 Bellman: sequential decisions

Richard Bellman (_Dynamic Programming_, 1957) supplied the recursion that makes multi-stage decision problems tractable: the **principle of optimality** — an optimal policy has the property that whatever the initial decision, the remaining decisions form an optimal policy for the resulting state — and the value-function equation named for him (§12). Together with Howard's policy iteration (1960) this founded Markov decision process theory, the substrate of modern reinforcement learning.

### 3.8 Raiffa, Schlaifer, Lindley: applied Bayesian decision analysis

Raiffa & Schlaifer (_Applied Statistical Decision Theory_, 1961) and Raiffa (_Decision Analysis_, 1968) turned the Savage framework into an engineering discipline: decision trees, preposterior analysis, conjugate families chosen for decision tractability, and the **value-of-information** calculus (EVPI/EVSI, §11) that prices data before you buy it. Dennis Lindley (_Making Decisions_, 1971; the 1956 information paper already canonical in [[Information Theory for Forecasting]]) was the discipline's most effective expositor and its conscience: "inference is a decision problem with a special loss function" is essentially Lindley's framing, made exact by Bernardo (1979). The lab's A3-style reasoning about what data is worth collecting descends directly from this school.

### 3.9 Pearl: causal decision-making

Judea Pearl (_Causality_, 2000/2009) matters to decision theory because expected-utility calculations condition on the _consequences of interventions_, not on observational correlations: the correct expectation for evaluating action aa a is over P(outcome∣do(a))P(\text{outcome} \mid do(a)) P(outcome∣do(a)), not P(outcome∣a observed)P(\text{outcome} \mid a \text{ observed}) P(outcome∣a observed). For this lab the distinction is mostly latent — buying a Kalshi contract does not change the weather, so the do-operator collapses to conditioning on the weather side — but it is live on the _market_ side (a large order changes the price it executes at; [[Market Microstructure]] impact is a causal effect of the lab's own action) and it becomes central the moment any model is trained on data whose distribution the deployed policy will shift (§18, §22).

### 3.10 The modern synthesis

By roughly 1970 the pieces were assembled: **Bayesian decision theory** — represent uncertainty as a posterior, represent preferences as utility, act to maximize posterior expected utility, price information by its expected effect on that maximum, and handle sequences by Bellman recursion on beliefs. Everything since is elaboration under constraints: computation (§19), robustness to misspecified beliefs (§13, §22), and learning the components from data (§18). The lab's stack is a faithful instantiation: [[Bayesian Statistics]] produces the posterior, this document specifies the argmax, [[Kelly Criterion]] is the argmax for the specific utility ln⁡(wealth)\ln(\text{wealth}) ln(wealth), and the V-gates are a governance layer acknowledging that the _belief module must be validated before the action module is trusted_.

---

## 4. Foundations: what a decision under uncertainty is

### 4.1 The anatomy of a decision

A decision problem has four irreducible ingredients:

1. **States of nature** θ∈Θ\theta \in \Theta θ∈Θ: the facts the decision-maker does not control and does not (fully) know. For a city-day: which temperature bracket verifies.
2. **Actions** a∈Aa \in \mathcal{A} a∈A: the options actually available. Crucially, "do nothing" is an action and usually the most frequently optimal one. For the eventual V3 system: {no trade, buy YES at ask, sell YES at bid, …} per contract, or richer (limit orders at chosen prices).
3. **Consequences** c(θ,a)c(\theta, a) c(θ,a): what happens when action meets state. A bought YES contract at ask a∗a^{\ast} a∗ pays 1−a∗−fee1 - a^{\ast} - \text{fee} 1−a∗−fee if the bracket verifies and −a∗−fee-a^{\ast} - \text{fee} −a∗−fee if not ([[Expected Value]], [[Market Microstructure]] own the exact accounting).
4. **Preferences over consequences**, encoded as utility uu u or loss LL L.

Uncertainty enters as a probability distribution over Θ\Theta Θ — for this lab, the forecast pp p (or, for the market's implied decision-making, rr r). The normative claim of the entire theory is a single sentence: **choose aa a to maximize Eθ∼belief[u(θ,a)]\mathbb{E}_{\theta \sim \text{belief}}[u(\theta, a)] Eθ∼belief​[u(θ,a)].** Everything else in this document is justification, machinery, or failure analysis for that sentence.

### 4.2 Rationality and optimality

"Rational" is a technical term here, not an honorific: a preference pattern is rational iff it satisfies the coherence axioms (§7), and an action is optimal iff nothing available has higher expected utility _under the stated beliefs and utility_. Three deflationary consequences deserve emphasis because each is routinely violated in informal reasoning:

- **Optimality is relative to the belief.** A decision can be optimal and lose; a decision can be reckless and win. Grading decisions by single outcomes is exactly the epistemic error the corpus's foundational principle prohibits for probabilities ([[Probability]]: a probability is a claim about a population). Decisions inherit the same rule: **judge the rule over the population, never the act by the outcome.** In practice this is why the lab's ledger must store the belief, the action, _and_ the loss specification at decision time — otherwise later audit cannot distinguish bad luck from bad policy.
- **Optimality is relative to the action set.** Enlarging A\mathcal{A} A (limit orders, not just market orders; partial sizes; waiting) can strictly improve the achievable expected utility. Much of practical system design is action-space engineering, not belief improvement.
- **Rationality does not remove uncertainty.** It only guarantees the _use_ of uncertainty is coherent. A rational agent still assigns probability, still loses sometimes, and still faces variance; see misconception §20.5.

### 4.3 Normative vs. descriptive decision theory

**Normative** theory says how an idealized coherent agent _should_ choose (expected utility, Bayesian updating). **Descriptive** theory says how humans _do_ choose — and the answer, since Allais (1953), Ellsberg (1961), and Kahneman & Tversky's prospect theory (1979), is: systematically otherwise. Humans overweight small probabilities, are loss-averse around reference points, exhibit ambiguity aversion, and violate the independence and sure-thing axioms in reproducible ways.

The lab's stance, stated once and inherited everywhere: **the lab's own machinery is normative; descriptive theory is a model of the counterparty.** An autonomous pipeline should be built to the normative specification because the normative theory is a _design target_, not an empirical hypothesis — the machine has whatever decision procedure it is given. Descriptive regularities matter as _market structure_: the favorite–longshot bias ([[Edge Detection]] §"Why Edge Exists"; Bürgi–Deng–Whelan Kalshi evidence ⚑) is prospect-theoretic probability weighting visible in equilibrium prices, and any persistent behavioral deviation by the crowd is precisely the kind of population-level mispricing the V2 instrument exists to detect. Prospect theory therefore appears in this corpus as a *hypothesis generator about rr r*, never as a component of the lab's own action rule.

---

## 5. The formal decision problem

### 5.1 The Wald triple and its extensions

The core formal object is the triple (Θ,A,L)(\Theta, \mathcal{A}, L) (Θ,A,L) — state space, action space, loss. Two standard extensions:

- **Data.** Add a sample space X\mathcal{X} X and a likelihood family {f(x∣θ)}\{f(x \mid \theta)\} {f(x∣θ)}; decisions become **decision rules** δ:X→A\delta : \mathcal{X} \to \mathcal{A} δ:X→A. This is the statistical decision problem (§9).
- **Time.** Index states, actions, and information by stages; decisions become **policies** mapping information states to actions. This is the sequential problem (§12).

**Randomized rules** — distributions over actions — are needed for minimax theory (the minimax rule may be randomized) and game-theoretic settings; under expected-utility preferences against a fixed belief they never strictly beat the best deterministic action, which is why production systems can usually ignore them. ⚑ _Nuance:_ randomization re-enters through exploration (§18) and through adversarial/impact considerations (unpredictability has value against a strategic counterparty; [[Market Microstructure]]).

### 5.2 What "outcome space" adds

Some formulations interpose consequences c∈Cc \in \mathcal{C} c∈C with c=g(θ,a)c = g(\theta, a) c=g(θ,a) and u:C→Ru : \mathcal{C} \to \mathbb{R} u:C→R. The factorization matters in engineering because it separates **world modeling** (gg g: what happens — settlement rules, fees, fills) from **valuation** (uu u: how much it matters). Bugs live disproportionately in gg g: the lab's finding F1 (settlement source is the NWS CLI product, not raw station obs) is exactly a gg g-layer discovery — the _consequence function_ of any bracket position runs through the CLI report, and a system that modeled gg g off raw observations would compute correct expected utilities of the wrong game.

### 5.3 Formulating real systems as decision problems

A discipline checklist for casting any lab subsystem in this frame (candidate content for the Engineering Playbook):

1. **Enumerate A\mathcal{A} A honestly** — include _wait_ and _do nothing_; include partial actions if they exist. An action space missing "wait" manufactures false urgency.
2. **Define Θ\Theta Θ at the settlement grain** — the state is what the contract settles on (CLI-reported high in the WFO's bracket arithmetic), not the physical quantity it approximates (F1, F3).
3. **Write LL L (or uu u) in the unit that compounds** — for capital decisions, log wealth (§16); for pure inference decisions, a proper score ([[Proper Scoring Rules and Calibration - Technical Reference]]).
4. **State whose probability feeds the expectation** — pp p, rr r, a blend, or a posterior over models. Ambiguity here is where "disagreement" quietly gets treated as "edge."
5. **Record all four components in the ledger at decision time** (dual-timestamp discipline). A decision that cannot be audited against its own inputs is not a measurement.

### 5.4 Worked micro-example (frictionless idealization)

Binary bracket, lab belief p=0.34p = 0.34 p=0.34 that it verifies; market ask a∗=0.27a^{\ast} = 0.27 a∗=0.27. Actions {buy 1 YES, do nothing}; monetary loss (negative payoff), risk-neutral for illustration. Expected payoffs: buy =p−a∗=0.07= p - a^{\ast} = 0.07 =p−a∗=0.07; nothing =0= 0 =0. The EU rule says buy. Every subsequent section complicates exactly one ingredient of this toy: §6–7 replace money with utility (0.07 expected dollars is _not_ automatically worth the variance); §8 replaces the point belief with a posterior (how sure is p=0.34p = 0.34 p=0.34?); §13 asks what happens when pp p itself is not trusted; §15–16 add fees, spread, sizing, and repetition; and [[Edge Detection]] asks the prior question of whether a population of such Δ\Delta Δ's reflects skill at all.

---

## 6. Utility theory

### 6.1 Utility is not money

A utility function u(w)u(w) u(w) over wealth encodes how much marginal wealth matters. If uu u is strictly concave, the agent is **risk-averse**: by Jensen's inequality, u(E[W])>E[u(W)]u(\mathbb{E}[W]) > \mathbb{E}[u(W)] u(E[W])>E[u(W)] for any non-degenerate gamble WW W, so the agent strictly prefers the expected value for certain over the gamble itself. Concavity is the mathematical form of Bernoulli's diminishing marginal utility, and it is why **maximizing expected wealth is not maximizing expected utility**: expected-wealth maximization is the special case u(w)=wu(w) = w u(w)=w (risk neutrality), a defensible local approximation only when stakes are small relative to bankroll — and a catastrophic global policy, since a risk-neutral agent offered repeated favorable gambles bets everything every time and goes bankrupt with probability approaching one despite maximal expected wealth ([[Kelly Criterion]] treats this pathology in full; [[Expected Value]] owns the "EV is not a policy" discussion).

### 6.2 Certainty equivalents and risk premium

The **certainty equivalent** of gamble WW W is the sure amount CECE CE with u(CE)=E[u(W)]u(CE) = \mathbb{E}[u(W)] u(CE)=E[u(W)]; the **risk premium** is πR=E[W]−CE≥0\pi_R = \mathbb{E}[W] - CE \ge 0 πR​=E[W]−CE≥0 under concavity. For small risks, the Arrow–Pratt expansion gives

πR≈12A(w) Var(W),A(w)=−u′′(w)u′(w),\pi_R \approx \tfrac{1}{2} A(w)\, \mathrm{Var}(W), \qquad A(w) = -\frac{u''(w)}{u'(w)},πR​≈21​A(w)Var(W),A(w)=−u′(w)u′′(w)​,

where A(w)A(w) A(w) is the coefficient of **absolute risk aversion**; relative risk aversion is R(w)=wA(w)R(w) = w A(w) R(w)=wA(w). Log utility has R(w)=1R(w) = 1 R(w)=1 constant — the signature of the Kelly agent: risk attitude toward *fractions of bankroll* is invariant to bankroll size, which is what makes a fixed *fractional* sizing rule the optimal form (§16).

Certainty equivalents give the lab a clean vocabulary for a recurring question: what is a noisy opportunity _worth_? An "edge" whose distribution is wide has a certainty equivalent well below its mean, and the gap grows with size; this is the utility-theoretic root of "all unresolved uncertainty pushes size down."

### 6.3 Which utilities appear in practice

- **Linear** (u=wu = w u=w): risk-neutral; correct for negligible stakes, and implicitly assumed by any raw-EV ranking.
- **Logarithmic** (u=ln⁡wu = \ln w u=lnw): Kelly; maximizes asymptotic growth rate; CRRA with γ=1\gamma = 1 γ=1.
- **Power / CRRA** (u=w1−γ/(1−γ)u = w^{1-\gamma}/(1-\gamma) u=w1−γ/(1−γ)): the standard one-parameter risk-aversion family; γ>1\gamma > 1 γ>1 is more conservative than Kelly, and fractional Kelly can be read as CRRA with γ=1/f\gamma = 1/f γ=1/f ⚑ (exact under continuous-time lognormal dynamics, approximate otherwise — derivation owned by [[Kelly Criterion]]).
- **Exponential / CARA** (u=−e−αwu = -e^{-\alpha w} u=−e−αw): analytically convenient (with Gaussian risks, EU maximization reduces to mean–variance), but wealth-independent absolute risk aversion is a poor model for a compounding bankroll.
- **Bounded utilities**: required to evade St. Petersburg-type divergences in full generality; Savage's theorem delivers bounded uu u.

**Convention note (single home).** The lab's capital-allocation utility, once V3 is live, is logarithmic — this is already the corpus's spine via the Kelly–log-score identity. This document records _why_ log is a principled choice among utilities (§16); the sizing machinery itself stays in [[Kelly Criterion]].

---

## 7. Expected utility theory

### 7.1 The von Neumann–Morgenstern axioms

Over lotteries (probability distributions over a consequence set) with known probabilities, define a preference relation ⪰\succeq ⪰. The vNM axioms:

1. **Completeness**: any two lotteries are comparable.
2. **Transitivity**: A⪰BA \succeq B A⪰B, B⪰CB \succeq C B⪰C ⇒\Rightarrow ⇒ A⪰CA \succeq C A⪰C.
3. **Continuity** (Archimedean): if A⪰B⪰CA \succeq B \succeq C A⪰B⪰C, some mixture αA+(1−α)C∼B\alpha A + (1-\alpha) C \sim B αA+(1−α)C∼B.
4. **Independence**: A⪰BA \succeq B A⪰B iff αA+(1−α)C⪰αB+(1−α)C\alpha A + (1-\alpha) C \succeq \alpha B + (1-\alpha) C αA+(1−α)C⪰αB+(1−α)C for all CC C, α∈(0,1]\alpha \in (0,1] α∈(0,1].

**Representation theorem (vNM 1947).** Preferences satisfy 1–4 iff there exists uu u on consequences with A⪰B⇔EA[u]≥EB[u]A \succeq B \Leftrightarrow \mathbb{E}_A[u] \ge \mathbb{E}_B[u] A⪰B⇔EA​[u]≥EB​[u], unique up to positive affine transformation.

The affine-uniqueness clause has two engineering corollaries: utility has **no absolute scale** (never compare utility magnitudes across agents or across differently calibrated uu u's), and any implementation is free to rescale uu u for numerical convenience without changing a single decision.

### 7.2 Why the axioms are normatively compelling

Each axiom is backed by a money-pump or dominance argument: an agent violating transitivity can be cycled into paying to return to its starting position; an agent violating independence can be presented with a compound lottery it evaluates inconsistently under statewise-identical reframings. For a _designed_ system the case is even simpler: the axioms are consistency requirements, and inconsistency in a machine is a bug with an exploit path. A trading system whose preferences admit a money pump will eventually meet a counterparty operating it.

### 7.3 From vNM to Savage

vNM assumes the probabilities; Savage (1954) derives them. From postulates on preferences over acts f:Θ→Cf : \Theta \to \mathcal{C} f:Θ→C — centrally the **sure-thing principle** (preferences between acts that agree on some event depend only on where they differ) — Savage obtains a unique finitely additive subjective probability PP P on Θ\Theta Θ and a bounded utility uu u with acts ranked by EP[u(f(θ))]\mathbb{E}_P[u(f(\theta))] EP​[u(f(θ))]. Anscombe & Aumann (1963) reach the same endpoint with a technically lighter mixed objective/subjective construction. The theorem is the formal warrant for Thesis 1: coherent preference _implies_ the belief/value factorization the lab's architecture assumes.

### 7.4 Where the axioms are contested

- **Allais (1953)**: with known probabilities, majorities reverse preferences across independence-equivalent pairs when certainty is involved — a descriptive strike against independence.
- **Ellsberg (1961)**: with _unknown_ probabilities, subjects pay to avoid ambiguity in patterns inconsistent with any single subjective prior — a strike against the sure-thing principle, and the entry point for the ambiguity models of §13.
- **Unbounded utility / St. Petersburg variants**: force boundedness or integrability conditions in full generality.

The normative reading the lab adopts: these are reasons to be careful about _where beliefs come from and how robust decisions are to them_ (§13), not reasons to abandon the EU form. No alternative with comparable coherence guarantees exists; the productive responses (maxmin EU, robust Bayes, DRO) are _extensions parameterized around_ expected utility, and all of them reduce to it when ambiguity vanishes.

---

## 8. Bayesian decision theory

### 8.1 The recipe

Given prior π(θ)\pi(\theta) π(θ), likelihood f(x∣θ)f(x \mid \theta) f(x∣θ), observed xx x, and loss LL L:

1. Form the posterior π(θ∣x)∝f(x∣θ) π(θ)\pi(\theta \mid x) \propto f(x \mid \theta)\, \pi(\theta) π(θ∣x)∝f(x∣θ)π(θ) ([[Bayesian Statistics]]).
2. For each action, compute **posterior expected loss** ρ(a∣x)=Eθ∼π(⋅∣x)[L(θ,a)]\rho(a \mid x) = \mathbb{E}_{\theta \sim \pi(\cdot \mid x)} [L(\theta, a)] ρ(a∣x)=Eθ∼π(⋅∣x)​[L(θ,a)].
3. Take the **Bayes action** a∗(x)=arg⁡min⁡aρ(a∣x)a^{\ast}(x) = \arg\min_a \rho(a \mid x) a∗(x)=argmina​ρ(a∣x).

Two structural facts elevate this from recipe to theory. **Conditionality:** the Bayes action depends on the data only through the posterior — the posterior is a sufficient interface between inference and decision, which is precisely what licenses the lab's pipeline boundary (forecast engine emits distributions; decision layer consumes them; neither needs the other's internals). **Equivalence:** minimizing posterior expected loss pointwise in xx x minimizes the pre-experimental Bayes risk r(π,δ)r(\pi, \delta) r(π,δ) — the "normal-form vs. extensive-form" equivalence of Raiffa–Schlaifer — so the convenient computation (condition, then optimize) coincides with the principled objective (optimal rule over all data realizations).

### 8.2 Bayes risk and its decomposition

r(π,δ)=Eθ∼πEx∣θ[L(θ,δ(x))]r(\pi, \delta) = \mathbb{E}_{\theta \sim \pi} \mathbb{E}_{x \mid \theta} [L(\theta, \delta(x))] r(π,δ)=Eθ∼π​Ex∣θ​[L(θ,δ(x))] is the single-number grade of a decision _rule_ before data arrive. Its minimum over δ\delta δ, r(π)=min⁡δr(π,δ)r(\pi) = \min_\delta r(\pi,\delta) r(π)=minδ​r(π,δ), is the **value of the decision problem** under prior π\pi π; the entire value-of-information calculus (§11) is bookkeeping on how r(π)r(\pi) r(π) falls as the information structure improves. r(π)r(\pi) r(π) is concave in π\pi π ⚑ (standard result; minimum of linear functionals), which is the geometric root of both "information has nonnegative value in expectation" (§11) and the generalized-entropy view of proper scoring rules ([[Proper Scoring Rules and Calibration - Technical Reference]] §10: every proper score's expected value is a concave "uncertainty function" — i.e., a Bayes risk).

### 8.3 Point beliefs vs. posteriors over parameters

The V1 pipeline emits a forecast distribution pp p over brackets — a _point belief_ over states. Full Bayesian decision theory distinguishes a further layer: uncertainty about the forecast model itself (a posterior over pp p's parameters, or over models). For a **single** decision under a proper composite belief, only the _predictive_ distribution matters — model uncertainty integrates out, and the Bayes action against the posterior-predictive is optimal. The distinction becomes operative in three places the lab will actually meet: (i) **sizing** — growth-optimal sizing under parameter uncertainty is _not_ Kelly at the predictive mean; estimation error induces an effective shrinkage (the Bayesian root of fractional Kelly ⚑, owned by [[Kelly Criterion]]); (ii) **value of information** — only the model-uncertainty layer can be reduced by collecting data, so EVSI (§11) lives there; (iii) **edge inference** — A1's job is exactly to quantify the posterior (or sampling) uncertainty in the population-level score differential before any of it is treated as pp p-vs-rr r skill.

### 8.4 Where the prior comes from

Priors in this lab are not decorative: the climatology rung of the reference ladder _is_ a prior in the plainest sense — the belief before today's model output — and the reference ladder is a prior-to-posterior gradient (climatology → NWS-derived model → market). Priors are also governance objects: pre-registration discipline exists because a prior chosen after seeing the data is not a prior, and the Analysis Run Log is the multiplicity ledger that keeps posterior claims honest ([[Research Methodology v2 Canonical]]).

---

## 9. Statistical decision theory

### 9.1 The three expectations, kept straight

|Object|Definition|Averages over|Fixed|
|---|---|---|---|
|Posterior expected loss ρ(a∣x)\rho(a \mid x) ρ(a∣x)|Eθ∣x[L(θ,a)]\mathbb{E}_{\theta \mid x}[L(\theta, a)] Eθ∣x​[L(θ,a)]|states|data|
|(Frequentist) risk R(θ,δ)R(\theta, \delta) R(θ,δ)|Ex∣θ[L(θ,δ(x))]\mathbb{E}_{x \mid \theta}[L(\theta, \delta(x))] Ex∣θ​[L(θ,δ(x))]|data|state|
|Bayes risk r(π,δ)r(\pi, \delta) r(π,δ)|Eπ[R(θ,δ)]=E[ρ(δ(x)∣x)]\mathbb{E}_\pi[R(\theta,\delta)] = \mathbb{E}[\rho(\delta(x) \mid x)] Eπ​[R(θ,δ)]=E[ρ(δ(x)∣x)]|both|—|

Most classical-vs-Bayesian confusion is a failure to say which row a claim lives in. The lab's own instruments already span the table: a proper score realized on one city-day is a draw whose expectation over outcomes at fixed truth is a risk-like object; the population-level score differential of [[Edge Detection]] is a Bayes-risk-flavored average over the city-day population; A1's task is the sampling theory connecting them.

### 9.2 Estimation as decision

An estimator is a decision rule with A=Θ\mathcal{A} = \Theta A=Θ. Classical results become corollaries of the loss chosen: under squared error the Bayes estimator is the posterior mean; under absolute error, the posterior median; under 0–1 loss (in the limit), the posterior mode. This is the cleanest illustration in all of statistics that **the "best estimate" is not a property of the posterior alone — it is a property of the posterior _and_ the loss**. A pipeline that reports "the model's temperature estimate" without a loss convention has not finished specifying its own output. (Candidate directive D-DT-2.)

### 9.3 Admissibility

Rule δ\delta δ is **inadmissible** if some δ′\delta' δ′ has R(θ,δ′)≤R(θ,δ)R(\theta, \delta') \le R(\theta, \delta) R(θ,δ′)≤R(θ,δ) for all θ\theta θ with strict inequality somewhere; admissible otherwise. Admissibility is a weak floor — an admissible rule can still be terrible (the constant estimator ignoring all data is admissible under squared error) — but _in_admissibility is disqualifying: something is better no matter what the truth is. The classic shock is **Stein's phenomenon** (Stein 1956; James–Stein 1961): for estimating a k≥3k \ge 3 k≥3-dimensional normal mean under summed squared error, the vector of per-coordinate MLEs is inadmissible — shrinking every coordinate toward a common point dominates it. The engineering moral is directly lab-relevant: **estimating five cities separately is dominated by partial pooling** — shrinkage across related problems (hierarchical/empirical Bayes; [[Bayesian Statistics]]) is not a stylistic preference but a dominance result, and any per-city calibration or bias-correction layer should default to it.

### 9.4 Minimax

The minimax rule minimizes max⁡θR(θ,δ)\max_\theta R(\theta, \delta) maxθ​R(θ,δ): optimal against an adversarial nature, equivalently the value of a zero-sum game (Wald; the minimax theorem). Minimax is the right posture when the prior is genuinely adversarial or reputational tail-risk dominates; it is over-conservative as a default because it lets a single worst-case state dictate the entire policy. Its lasting practical residue is the bridge fact: minimax rules are Bayes rules against a **least favorable prior** — worst-case analysis is Bayesian analysis with a hostile prior, which locates minimax on the same spectrum as the robustness methods of §13 rather than in opposition to Bayes.

### 9.5 Complete class theorems

Under regularity (e.g., finite Θ\Theta Θ, or exponential-family structure with convex loss), the class of Bayes rules (plus their limits) is **complete**: every rule outside it is dominated by one inside (Wald 1950; Le Cam 1955 ⚑ for general statements). Read forward: choosing _any_ admissible procedure is choosing a prior, possibly implicitly. The lab's preference for explicit priors and pre-registered analysis is thus not a Bayesian aesthetic but an audit requirement — the prior exists either way; the only question is whether it is written down.

### 9.6 Engineering applications

Statistical decision theory supplies the lab three working tools: (i) **loss-explicit estimation** — every point number the pipeline emits carries its loss convention (§9.2); (ii) **dominance screening** — before tuning any estimator, check it is not dominated by an available shrinkage/pooled alternative (§9.3); (iii) **worst-case audits** — evaluate candidate rules under least-favorable configurations (e.g., regime change in a city's forecast bias) as a stress test, without adopting minimax as the objective (§9.4).

---

## 10. Loss functions

The loss function is where "what do mistakes cost" is written down, and the choice is never neutral: **the loss determines which functional of the belief the optimal action reveals.** The modern name for this correspondence is _elicitability_ (Gneiting 2011, "Making and Evaluating Point Forecasts" ★): a functional is elicitable iff some loss makes it the unique optimizer.

### 10.1 The standard menu

- **Zero–one loss** L=1{a≠θ}L = \mathbb{1}\{a \ne \theta\} L=1{a=θ}: Bayes action = posterior mode (MAP). Appropriate only when all errors are equally costly — which is almost never true with money attached; see misconception §20.1.
- **Squared error** L=(a−θ)2L = (a - \theta)^2 L=(a−θ)2: Bayes action = posterior mean. Smooth, penalizes large errors quadratically, the default of regression; sensitive to outliers.
- **Absolute error** L=∣a−θ∣L = |a - \theta| L=∣a−θ∣: Bayes action = posterior median. Robust to tails; the right default when the report is "central temperature" and occasional CLI oddities shouldn't drag the estimate.
- **Quantile (pinball) loss** Lτ(a,θ)=(τ−1{θ<a})(θ−a)L_\tau(a,\theta) = (\tau - \mathbb{1}\{\theta < a\})(\theta - a) Lτ​(a,θ)=(τ−1{θ<a})(θ−a): elicits the τ\tau τ-quantile; the asymmetric generalization of absolute error and the natural loss whenever over- and under-forecasting cost differently.
- **Logarithmic loss** L(p,θ)=−ln⁡p(θ)L(p, \theta) = -\ln p(\theta) L(p,θ)=−lnp(θ) for a _distributional_ action: the strictly proper score whose expectation is cross-entropy; uniquely local among smooth proper scores; the corpus spine ([[Proper Scoring Rules and Calibration - Technical Reference]] owns the conventions; [[Log Score and Kelly Identity]] owns its identity with growth).
- **Asymmetric / custom monetary losses**: linex, piecewise-linear cost structures, and — the terminal case for this lab — the realized P&L of a position at executable prices net of fees, which is not a "loss function chosen for convenience" but the actual game ([[Expected Value]], [[Market Microstructure]]).

### 10.2 Choosing a loss is choosing the question

Three lab-specific rulings follow from elicitability:

1. **Distributional actions demand proper scores.** When the action _is_ a probability distribution (the V1 product), only strictly proper scoring rules make honest reporting optimal; any improper loss pays the forecaster to hedge. Already registered doctrine; restated here because it is a theorem of this section, not a convention of that one.
2. **Point summaries must name their loss.** "The forecast high" is undefined until median/mean/mode is fixed (§9.2); the same discipline the settlement product forces (F1 fixes _whose_ number; the loss fixes _which summary of the belief_ targets it).
3. **Verification loss ≠ decision loss.** The pipeline is _graded_ on proper scores (belief quality) and will eventually be _paid_ on monetary loss (action quality). These are linked by the Kelly identity but not identical once frictions enter; conflating them is misconception §20.4.

### 10.3 A worked contrast

Belief over three brackets: p=(0.42,0.35,0.23)p = (0.42, 0.35, 0.23) p=(0.42,0.35,0.23). Under 0–1 loss the Bayes action is bracket 1. Now attach money: suppose (for illustration) the available contracts price bracket 3 at 0.10 while the lab believes 0.23. The monetary-loss Bayes action ignores the mode entirely and concerns bracket 3 — the _least likely_ outcome in the belief — because the loss (payoff) structure, not the probability ranking, determines relevance. The highest-probability state and the optimal action share no necessary relationship (misconception §20.1); everything is mediated by LL L.

---

## 11. Value of information

Information has decision value only through the actions it changes; this section is the calculus of that value. It is also the theoretical backbone of the lab's most consequential operational principle — **irreversibility beats importance** — because the accrual clock is, in this vocabulary, a statement that unpurchased sample information depreciates to zero for non-backfillable data.

### 11.1 EVPI

Let r(π)=min⁡aEπ[L(θ,a)]r(\pi) = \min_a \mathbb{E}_\pi[L(\theta,a)] r(π)=mina​Eπ​[L(θ,a)] be the prior value (expected loss of the best uninformed action). With perfect information the agent acts after seeing θ\theta θ, paying Eπ[min⁡aL(θ,a)]\mathbb{E}_\pi[\min_a L(\theta,a)] Eπ​[mina​L(θ,a)]. The **expected value of perfect information** is

EVPI=min⁡aEπ[L(θ,a)]−Eπ[min⁡aL(θ,a)] ≥0,\mathrm{EVPI} = \min_a \mathbb{E}_\pi[L(\theta,a)] - \mathbb{E}_\pi\big[\min_a L(\theta,a)\big] \ \ge 0,EVPI=amin​Eπ​[L(θ,a)]−Eπ​[amin​L(θ,a)] ≥0,

the gap between "min of expectation" and "expectation of min" — nonnegative by exchanging min and E\mathbb{E} E (Jensen on the concave value function §8.2). EVPI is the hard ceiling on what *any* data source, model upgrade, or feed subscription can be worth for a given decision; anything priced above its EVPI is not worth buying at any accuracy.

### 11.2 EVSI and preposterior analysis

For an experiment yielding xx x, the **expected value of sample information** is

EVSI=r(π)−Ex[min⁡aρ(a∣x)],\mathrm{EVSI} = r(\pi) - \mathbb{E}_x\big[\min_a \rho(a \mid x)\big],EVSI=r(π)−Ex​[amin​ρ(a∣x)],

the expected drop in achievable loss from conditioning — computed *before* running the experiment by averaging over the prior predictive (Raiffa–Schlaifer "preposterior analysis"). 0≤EVSI≤EVPI0 \le \mathrm{EVSI} \le \mathrm{EVPI} 0≤EVSI≤EVPI, and information that cannot change the optimal action has EVSI exactly zero regardless of its statistical informativeness — the sharpest formulation of "collect data that can move decisions, not data that is merely interesting." Net gain = EVSI − cost defines optimal experimental design; Lindley (1956) and Bernardo (1979) connect the log-loss case to expected information gain, making EIG a special case of EVSI ([[Information Theory for Forecasting]] §17 owns that bridge).

**Worked micro-example.** Frictionless binary contract priced at c=0.30c = 0.30 c=0.30; prior belief the bracket verifies: π=0.30\pi = 0.30 π=0.30 (agreement — no trade has value; the prior-optimal action is _nothing_, at expected loss 0). Perfect information: knowing the outcome in advance, buy when it verifies (gain 0.700.70 0.70, probability 0.300.30 0.30) and sell/short when it doesn't (gain 0.300.30 0.30, probability 0.700.70 0.70), so EVPI=0.30(0.70)+0.70(0.30)−0=0.42\mathrm{EVPI} = 0.30(0.70) + 0.70(0.30) - 0 = 0.42 EVPI=0.30(0.70)+0.70(0.30)−0=0.42 per contract — the absolute ceiling any forecast improvement could be worth on this contract at this price. Now a _partial_ signal: a model output that shifts the posterior to 0.450.45 0.45 with prior-predictive probability 0.40.4 0.4, or to 0.200.20 0.20 with probability 0.60.6 0.6 (coherent: 0.4×0.45+0.6×0.20=0.300.4 \times 0.45 + 0.6 \times 0.20 = 0.30 0.4×0.45+0.6×0.20=0.30). Post-signal optimal actions: buy in the first case (expected gain 0.45−0.30=0.150.45 - 0.30 = 0.15 0.45−0.30=0.15), sell in the second (expected gain 0.30−0.20=0.100.30 - 0.20 = 0.10 0.30−0.20=0.10). EVSI=0.4(0.15)+0.6(0.10)−0=0.12\mathrm{EVSI} = 0.4(0.15) + 0.6(0.10) - 0 = 0.12 EVSI=0.4(0.15)+0.6(0.10)−0=0.12 — the most this signal is worth per contract, before costs, and only 29%29\% 29% of the EVPI ceiling. Note what drove the value: the signal _crosses action thresholds_ in both branches. A signal of identical statistical strength that moved the posterior between 0.280.28 0.28 and 0.320.32 0.32 would have EVSI exactly zero at this price — every nat of it wasted on a decision it cannot change.

### 11.3 Blackwell ordering and "more information never hurts"

Blackwell (1953): experiment E1E_1 E1​ is _sufficient for_ (a garbling of no) E2E_2 E2​ iff E1E_1 E1​ yields weakly lower Bayes risk for **every** loss and prior. Within the theorem's scope, more information never hurts _in expectation, before you see it, for an agent who updates coherently and acts optimally_. Every qualifier is load-bearing; §20.3 catalogs the real-world failures outside them (costs, miscalibrated updating, strategic settings where public information destroys value — Hirshleifer 1971).

### 11.4 Stopping rules

Sequential information purchase — collect another observation or act now — is an optimal-stopping problem: continue while expected marginal EVSI exceeds marginal cost (delay, fees, adverse price movement). Wald's SPRT is the canonical solved case. Two lab translations: (i) **entry timing** (V3-gated) is a stopping problem in which waiting buys forecast information (later NWS cycles are more skillful) but pays in price movement as the market also learns — §15.4; (ii) **research-phase gates themselves** are stopping rules: the V2→V3 gate is "stop measuring and start acting only when the posterior on edge clears a pre-registered bar," which is exactly a sequential decision with an explicit continuation region. ⚑ _A1 dependency:_ optional-stopping effects on inference (peeking) must be governed by A1's sequential-analysis stance; this document only notes that the decision-theoretic and inferential treatments of stopping must be ratified together.

---

## 12. Sequential decision making

### 12.1 Bellman's principle and dynamic programming

For a multi-stage problem with state sts_t st​, action ata_t at​, reward R(st,at)R(s_t, a_t) R(st​,at​), transition kernel P(st+1∣st,at)P(s_{t+1} \mid s_t, a_t) P(st+1​∣st​,at​), and discount γ∈[0,1)\gamma \in [0,1) γ∈[0,1), the optimal value function satisfies the **Bellman equation**

V∗(s)=max⁡a[R(s,a)+γ∑s′P(s′∣s,a) V∗(s′)],V^{\ast}(s) = \max_{a} \Big[ R(s,a) + \gamma \sum_{s'} P(s' \mid s, a)\, V^{\ast}(s') \Big],V∗(s)=amax​[R(s,a)+γs′∑​P(s′∣s,a)V∗(s′)],

a fixed point of a γ\gamma γ-contraction, hence unique and computable by value iteration; policy iteration (Howard 1960) alternates evaluation and greedy improvement and typically converges in few iterations. The principle of optimality is what makes the recursion valid: optimal behavior from any reachable state onward is itself optimal, so global sequential optimization decomposes into local one-step optimizations against the value of the future.

The conceptual export matters more than the algorithm: **in sequential settings, the correct objective for today's action includes the value of tomorrow's options.** A myopic one-step EU maximizer is optimal only when actions do not affect future states or information — which is false whenever capital is finite (today's position size changes tomorrow's bankroll: the Kelly setting §16), whenever acting reveals or destroys information, and whenever prices respond to participation. A concrete failure: a rule that commits the full bankroll to today's best single opportunity is myopically EV-optimal and sequentially disastrous, because the state variable it ignores — remaining capital — is the multiplier on every future opportunity. Log utility is the special case in which this bookkeeping happens automatically (§16.1's myopic-optimality property), which is part of why it is the natural utility for compounding systems rather than merely a defensible one.

### 12.2 Markov decision processes

The MDP is the standard formalization; its assumptions deserve explicit statement because each is violated somewhere in the lab's domain: (i) **Markov state** — the future depends on the past only through sts_t st​: true only if the state is engineered to carry sufficient statistics (forecast cycle, current book, position, bankroll); (ii) **known dynamics** — false for markets; estimated dynamics reintroduce all of §8.3's parameter-uncertainty structure; (iii) **stationary rewards/dynamics** — seasonal weather and evolving market participation both violate it, motivating the non-stationarity vigilance already doctrinal in [[Statistical Learning Theory]] and [[Edge Detection]].

### 12.3 POMDPs: acting on beliefs

When the state is not observed, the decision-relevant object is the **belief state** bt=P(st∣history)b_t = P(s_t \mid \text{history}) bt​=P(st​∣history), updated by Bayes filtering; a POMDP is exactly an MDP on belief space (Åström 1965 ⚑; Kaelbling–Littman–Cassandra 1998). Exact solution is intractable in general (belief space is a continuous simplex; PSPACE-hardness results apply ⚑), so practice uses point-based value iteration, Monte Carlo tree search on beliefs (POMCP ⚑), or certainty-equivalent approximations with explicit error acknowledgment. The lab-relevant reading: **a forecasting-and-trading system is natively a POMDP** — the "true" atmospheric-and-market state is never observed; the pipeline's entire forecast layer is the filter that maintains btb_t bt​; and the separation between filtering (belief maintenance) and control (acting on beliefs) is the POMDP restatement of Thesis 1.

### 12.4 What the lab actually needs from this section

V1 needs the vocabulary, not the solvers. Three sequential structures are already present in the lab's world and should be _named_ as such in any future design discussion: (i) **bankroll dynamics** — repeated bets compound; the growth-optimal treatment is §16, and its sequential character is why single-bet EV intuitions mislead; (ii) **information timing** — forecast skill and market prices co-evolve toward settlement; entry/exit is optimal stopping (§11.4, §15.4); (iii) **research program control** — the staged roadmap with gates is a designed MDP over the lab itself, with the accrual clock as a non-recoverable state variable. None of these requires reinforcement learning to manage at current scale; all of them are misdesigned if their sequential structure is ignored.

---

## 13. Risk, uncertainty, and robustness

### 13.1 Knight's distinction and its modern form

Knight (1921) separated **risk** (known probabilities) from **uncertainty** (unknown probabilities). Strict subjectivists dissolve the distinction — a coherent agent always has _some_ prior — but Ellsberg (1961) showed the dissolution is behaviorally false and, more importantly for engineering, _practically_ incomplete: there is a real difference between a probability estimated from ten thousand exchangeable city-days and one conjured for a regime never observed. The modern vocabulary grades this as **ambiguity**: uncertainty about the probability model itself.

### 13.2 Formal responses

- **Maxmin expected utility** (Gilboa & Schmeidler 1989): hold a _set_ C\mathcal{C} C of priors; choose arg⁡max⁡amin⁡P∈CEP[u]\arg\max_a \min_{P \in \mathcal{C}} \mathbb{E}_P[u] argmaxa​minP∈C​EP​[u]. Axiomatically grounded; conservative in proportion to the size of C\mathcal{C} C.
- **Smooth ambiguity** (Klibanoff, Marinacci & Mukerji 2005 ⚑): a second-order distribution over models with a concave transform — ambiguity aversion as risk aversion one level up; recovers standard Bayes when the transform is linear.
- **Robust Bayes / ε\varepsilon ε-contamination** (Berger 1985): perturb the prior within a neighborhood; report the range of Bayes actions.
- **Distributionally robust optimization** (DRO): optimize worst case over a divergence- or Wasserstein-ball around a nominal distribution — the modern computational workhorse (§22).

All are parameterized retreats from a single trusted prior toward minimax (§9.4), recovering plain EU as ambiguity → 0. The design question is never "Bayes or robust?" but "how large is the credible model neighborhood, and what does worst-case-over-it cost?"

### 13.3 The lab's standing resolution

The corpus already contains the lab's answer, and this section only names its decision-theoretic form: **all unresolved uncertainty pushes size down.** The Kelly growth curve's asymmetry (overbetting catastrophic, underbetting slow) means that ambiguity about pp p maps into fractional sizing rather than into abandoning EU — fractional Kelly _is_ the lab's ambiguity policy, with the fraction as the single knob pricing everything not yet validated: parameter uncertainty (§8.3), model misspecification (this section), and the E-grade of the inputs (Invariant 3 as a robustness parameter). Deep uncertainty that cannot be represented even as a model set — genuine regime novelty, e.g., a change in NWS CLI methodology (F1's failure mode) — is handled _structurally_, not by widening C\mathcal{C} C: monitoring, kill criteria, and scope restrictions (trade only regimes with validated populations) are the decision-theoretic meaning of the lab's gates and invariants.

---

## 14. Forecasting applications: the cost–loss framework

Meteorology is decision theory's oldest continuous industrial application, and the cost–loss model is its fruit fly: small enough to solve exactly, rich enough to exhibit every theme of this document.

### 14.1 The static cost–loss problem

A user faces an adverse event EE E (freeze, storm) with forecast probability pp p. Actions: **protect**, at cost CC C; or **don't**, risking loss L>CL > C L>C if EE E occurs. Expected losses: protect =C= C =C; don't =pL= pL =pL. Protect iff

p>C/L,p > C/L,p>C/L,

the **cost–loss ratio** threshold (Thompson 1952 ⚑; Murphy 1977). Numerically: an orchardist with protection cost C=$2,000C = \$2{,}000 C=$2,000 against a freeze loss L=$50,000L = \$50{,}000 L=$50,000 protects at any p>0.04p > 0.04 p>0.04 — a "4% chance of frost" forecast, far below the modal outcome, correctly triggers action; a events-company with C=$40,000C = \$40{,}000 C=$40,000 (cancellation) against L=$50,000L = \$50{,}000 L=$50,000 (rain-out) acts only above p=0.8p = 0.8 p=0.8. Same forecast, opposite optimal actions, both rational. Everything is here in miniature: the optimal action depends on the *full probability*, not the modal category; the threshold is a property of the *user's economics*, not of the forecast; and different users facing the same forecast rationally act differently. A probabilistic forecast serves every C/LC/L C/L user simultaneously — a categorical forecast serves exactly one threshold and silently imposes its issuer's loss function on every user. This is the decision-theoretic argument for the lab's insistence on full-distribution products.

### 14.2 Forecast value

The **value score** of a forecast system for a C/LC/L C/L user is the expected-expense reduction relative to climatology, normalized by the perfect-information reduction (Richardson 2000 ★; Murphy 1985 ⚑):

V(C/L)=E[expenseclim]−E[expenseforecast]E[expenseclim]−E[expenseperfect].V(C/L) = \frac{\mathbb{E}[\text{expense}_{\text{clim}}] - \mathbb{E}[\text{expense}_{\text{forecast}}]}{\mathbb{E}[\text{expense}_{\text{clim}}] - \mathbb{E}[\text{expense}_{\text{perfect}}]}.V(C/L)=E[expenseclim​]−E[expenseperfect​]E[expenseclim​]−E[expenseforecast​]​.

Value is user-relative: the same forecast system has different VV V at different C/LC/L C/L, and the envelope of VV V over users connects to the ROC/verification machinery ([[Forecast Verification]] owns those identities; Richardson shows the Brier skill score is a particular C/LC/L C/L-weighted average of value ⚑). Two permanent lessons: (i) **skill ≠ value** — a forecast can improve proper scores while being worthless to a particular user whose threshold it never crosses, and (marginally) vice versa; (ii) **value is only realized through decisions** — an ignored forecast has zero value at any accuracy, which is EVSI = 0 through inaction (§11.2).

### 14.3 The market as a C/LC/L C/L aggregator

A prediction-market price is, among other things, the equilibrium of many participants running threshold decisions against their own economics. The cost–loss lens predicts structure in rr r: hedgers with extreme C/LC/L C/L ratios rationally hold positions at prices a pure forecaster would call mispriced — _their_ optimum is not a probability claim. This is one of the standing hypotheses for why persistent Δ\Delta Δ need not imply market irrationality, and why [[Edge Detection]] demands population-level score differentials rather than price-disagreement anecdotes.

---

## 15. Prediction market applications

This section states the decision problems the V3 gate would one day instantiate. Under V1, every claim here is theory about a future instrument; nothing authorizes action.

### 15.1 From probability estimation to decision problem

The research question of V1–V2 is epistemic: *is pp p better than rr r over a population?* The V3 question is decision-theoretic: *given pp p, the book, fees, and the bankroll, what action maximizes expected log growth?* The transformation adds, minimally: executable prices (ask/bid, not midpoint), fees, size (which turns a discrete trade/no-trade into a continuous allocation, §16), opportunity cost (capital locked until settlement cannot take tomorrow's opportunity — a shadow price on capital, sequential in the §12 sense), impact and fill risk for maker orders ([[Market Microstructure]]), and correlation across simultaneous positions (five cities are not independent; a synoptic pattern is a common factor — portfolio Kelly, owned by [[Kelly Criterion]]).

### 15.2 The dead zone as a no-trade region

The decision-theoretic form of the microstructure dead zone: the action space is {buy at a∗a^{\ast} a∗, sell at b∗b^{\ast} b∗, nothing}, and _nothing_ is optimal whenever b∗+fee-adjusted costs≤p≤a∗+fee-adjusted costsb^{\ast} + \text{fee-adjusted costs} \le p \le a^{\ast} + \text{fee-adjusted costs} b∗+fee-adjusted costs≤p≤a∗+fee-adjusted costs (suitably oriented). Because a∗−b∗>0a^{\ast} - b^{\ast} > 0 a∗−b∗>0 always, **a nonempty no-trade region exists for every contract at every moment**; disagreement must clear the executable boundary, not the midpoint, before the EU comparison even begins. Adding belief uncertainty (§8.3, §13) widens the effective region further: the certainty equivalent of a noisy Δ\Delta Δ is smaller than its mean (§6.2). "Do nothing" is thus not a failure mode of a trading system; it is the correct output of the decision rule almost all the time, and a system whose logs do not show mostly-nothing is mis-specified.

### 15.3 Expected edge and opportunity cost

Ranking opportunities by raw EV is loss-blind (§10) and sequence-blind (§12). The correct ranking object under log utility is each opportunity's contribution to expected growth _given the portfolio and bankroll_ — which automatically prices opportunity cost: capital committed at small growth rates crowds out capacity for larger ones, and simultaneous correlated positions share a risk budget. The single-number summary "edge" in lab vocabulary remains reserved for the validated population-level quantity ([[Glossary]]); per-decision expected advantage is always conditional on the epistemic status of pp p ([[Expected Value]]'s central discipline).

### 15.4 Timing as optimal stopping

For a given city-day, the lab's information (successive NWS cycles) and the market's price co-evolve toward settlement. Entering early buys worse information at better prices; entering late buys better information at prices that have already absorbed what the crowd learned. This is a stopping problem (§11.4) whose value function depends on _relative_ learning rates — formally, the lab's edge at time tt t is a DKLD_{\mathrm{KL}} DKL​ gap that itself has a time profile, and optimal entry maximizes expected growth over the entry-time distribution. ⚑ _Empirical dependency:_ the time profile is measurable from V1 data (forecast-issuance snapshots vs. market snapshots — precisely the non-backfillable series the accrual clock guards); no theoretical prior substitutes for it. This is a concrete instance of measurement-before-optimization: the stopping problem cannot be posed, let alone solved, without the very data V1 exists to collect.

---

## 16. The Kelly criterion as expected utility maximization

The Kelly criterion is not a rival framework to decision theory; it is decision theory with the utility filled in. This section states the identification; the operational machinery (fractional Kelly, portfolio Kelly, drawdown mathematics, V3 gating) is owned by [[Kelly Criterion]], and the information-theoretic identity by [[Log Score and Kelly Identity]].

### 16.1 The identification

Bankroll WW W, binary contract at price cc c believed to win with probability pp p, stake fraction ff f. One-step expected log wealth:

g(f)=pln⁡ ⁣(1+f 1−cc)+(1−p)ln⁡(1−f),g(f) = p \ln\!\big(1 + f\,\tfrac{1-c}{c}\big) + (1-p) \ln(1 - f),g(f)=pln(1+fc1−c​)+(1−p)ln(1−f),

(in the even-odds normalization, g(f)=pln⁡(1+f)+(1−p)ln⁡(1−f)g(f) = p\ln(1+f) + (1-p)\ln(1-f) g(f)=pln(1+f)+(1−p)ln(1−f)). Kelly's f∗=arg⁡max⁡fg(f)f^{\ast} = \arg\max_f g(f) f∗=argmaxf​g(f) is *exactly* the Bayes action (§8.1) for action space f∈[0,1)f \in [0,1) f∈[0,1), belief pp p, and utility u(W)=ln⁡Wu(W) = \ln W u(W)=lnW. Nothing beyond §4–8 is invoked: **Kelly = expected utility maximization with logarithmic utility.** The choice of ln⁡\ln ln is then justified on three independent grounds:

1. **Asymptotic dominance** (Breiman 1961 ★; Kelly 1956 ★): over repeated favorable bets, the log-optimal policy achieves the maximal almost-sure exponential growth rate, and outgrows any essentially different policy with probability → 1. Growth-rate optimality is a _theorem about repetition_, which is why Kelly is native to the lab's setting (~150 city-days/month is a repetition machine) and irrelevant to one-shot decisions.
2. **Myopic optimality**: log utility is the unique CRRA utility for which the sequential problem (§12) collapses to one-step optimization — the Bellman recursion for log wealth separates, so today's optimal fraction ignores the horizon ⚑ (Mossin 1968 / Hakansson 1971 lineage). This is an enormous engineering simplification: the log investor may solve a static problem each period without a value function.
3. **The information identity**: expected log growth against market prices equals the forecaster's expected log-score advantage, E[growth]=DKL(q∥r)−DKL(q∥p)\mathbb{E}[\text{growth}] = D_{\mathrm{KL}}(q\|r) - D_{\mathrm{KL}}(q\|p) E[growth]=DKL​(q∥r)−DKL​(q∥p) — edge in the lab's sense _is_ the Kelly growth rate ([[Log Score and Kelly Identity]]). The measurement instrument (proper-score differentials) and the capital objective (growth) are the same number in different clothes; this identity is the reason the lab's V1→V3 architecture is coherent rather than merely staged.

### 16.2 What decision theory adds to the Kelly discussion

- **Kelly is not risk-neutral EV maximization** — f∗f^{\ast} f∗ is interior precisely because ln⁡\ln ln is concave; the risk-neutral agent bets everything (§6.1). "Maximize EV" and "maximize growth" recommend different actions on every non-degenerate bet.
- **Kelly presupposes pp p** — the derivation treats the belief as true. Under parameter uncertainty the growth-optimal action shrinks (§8.3), and under ambiguity it shrinks further (§13.3): decision theory locates fractional Kelly as the _robust Bayes action_ of the sizing problem, not as an ad hoc haircut.
- **The asymmetry is a utility fact**: g(f)g(f) g(f) falls off steeply past f∗f^{\ast} f∗ (and g(2f∗)≈0g(2f^{\ast}) \approx 0 g(2f∗)≈0 in the classical even-odds case ⚑), while under-sizing costs only quadratically near the peak. The corpus principle "all unresolved uncertainty pushes size down" is the gradient of gg g read as a policy.
- **Bounded-utility objection**: ln⁡W→−∞\ln W \to -\infty lnW→−∞ as W→0W \to 0 W→0 encodes absolute ruin-aversion — a feature for a bankroll, and the decision-theoretic reason Kelly systems never risk the full bankroll on any finite-odds event.

---

## 17. Information theory connections

Owned vocabulary lives in [[Information Theory for Forecasting]]; this section states only the decision-theoretic ligaments.

**Entropy as Bayes risk.** For log loss, the prior value of the prediction problem is the entropy: min⁡pEq[−ln⁡p]=H(q)\min_{p} \mathbb{E}_{q}[-\ln p] = H(q) minp​Eq​[−lnp]=H(q), attained at p=qp = q p=q. Generalized: every strictly proper scoring rule's optimal expected score defines a concave generalized entropy, and every concave generalized entropy is a Bayes risk (§8.2; Grünwald & Dawid 2004 ⚑; [[Proper Scoring Rules and Calibration - Technical Reference]] §10). Entropy is therefore not merely _analogous_ to decision value — under log loss it _is_ the value of the problem, and uncertainty reduction is Bayes-risk reduction.

**Information gain as EVSI.** Under log loss, EVSI (§11.2) for the prediction decision equals the expected information gain / mutual information between observation and state (Lindley 1956 ★; Bernardo 1979 ★, who shows log is the unique smooth proper local utility making "inference as decision" consistent). This is the license for using EIG as a data-valuation heuristic — with the standing caveat that for _non-log_ downstream losses, bits are only a proxy: information that never crosses an action threshold has EVSI zero however many nats it carries (§11.2, §20.3).

**Bayesian updating as the unique coherent use of information.** The dynamic-coherence arguments for conditioning (van Fraassen ⚑; diachronic Dutch books) close the loop: the same betting-consistency logic that generates static probability (de Finetti, §3.3) forces Bayes' rule as the update, so the belief pipeline feeding the decision layer has no coherent alternative design.

**Decisions change what information is worth.** VoI is loss- and action-relative; a change in A\mathcal{A} A (new order types, new markets) re-prices every data source with no change in the data. Information valuation is therefore not a property of the pipeline in isolation — it must be recomputed when the action layer changes. (Candidate directive D-DT-5.)

---

## 18. Machine learning applications

Modern ML is decision theory industrialized; the mapping is worth stating exactly because the ML literature often hides the decision-theoretic joints.

**Statistical learning as risk minimization.** Empirical risk minimization is Wald's framework with LL L a training loss and δ\delta δ a hypothesis; regularization is a prior in disguise (MAP), and generalization theory is the sampling theory of risk estimates — [[Statistical Learning Theory]] owns this and the ES/dependence caveats that dominate the lab's effective sample size reality.

**Reinforcement learning.** RL is the MDP program (§12) with unknown dynamics learned from interaction: value-based methods estimate Q∗Q^{\ast} Q∗, policy-gradient methods ascend E[∑γtR]\mathbb{E}[\sum \gamma^t R] E[∑γtR] directly, actor–critic combines them (Sutton & Barto 2018 ★). The **exploration–exploitation dilemma** is the sequential form of the value of information: exploring is _paying_ current expected reward for EVSI about the environment. The bandit literature makes the price exact — regret lower bounds (Lai & Robbins 1985 ⚑) say some exploration cost is unavoidable; UCB acts on optimism, **Thompson sampling acts by posterior randomization** and is the cleanest production example of Bayesian decision theory (sample a model from the posterior, act optimally against the sample). Gittins indices (1979 ⚑) solve the discounted independent-armed case exactly and stand as the reminder that "explore vs. exploit" is sometimes a solved problem, not a vibe.

**Bayesian optimization and active learning.** BO optimizes expensive black-box functions by maintaining a posterior (typically a GP) and choosing evaluations via an **acquisition function** — expected improvement, UCB, entropy search — each an explicit VoI surrogate (§11); active learning selects labels by expected information gain (BALD lineage; [[Information Theory for Forecasting]] §15). Both are §11 running in a loop, and both are plausibly lab-relevant tooling (hyperparameter selection for post-processing models) long before any RL is.

**Uncertainty-aware prediction.** Calibrated predictive distributions (deep ensembles, conformal prediction ⚑, Bayesian NNs) matter _because_ the consumer is a decision rule: a miscalibrated pp p silently corrupts every downstream arg⁡max⁡\arg\max argmax, and — per the Kelly asymmetry — overconfidence is the expensive direction. The lab's insistence on calibration audits before any pp p becomes load-bearing is this point in governance form.

**A scope note.** Nothing in the current roadmap requires RL; the lab's sequential problems (§12.4) are low-dimensional and better served by explicit stopping/sizing analysis than by learned policies. The section exists because the _concepts_ (regret, exploration cost, acquisition functions) are the correct vocabulary for lab decisions about its own experimentation budget.

---

## 19. Computational considerations

**Monte Carlo decision analysis.** When ρ(a∣x)\rho(a \mid x) ρ(a∣x) has no closed form, estimate it by posterior sampling: ρ^(a)=1N∑iL(θi,a)\hat\rho(a) = \tfrac{1}{N}\sum_i L(\theta_i, a) ρ^​(a)=N1​∑i​L(θi​,a), θi∼π(⋅∣x)\theta_i \sim \pi(\cdot \mid x) θi​∼π(⋅∣x). Two disciplined practices: (i) **common random numbers** — evaluate all candidate actions on the _same_ posterior draws, so comparisons difference out shared noise; (ii) report the Monte Carlo standard error of the _difference_ in expected losses between leading actions, and refuse to declare an argmax whose margin is inside MC noise (an exact analogue of the lab's rule against reading signal inside sampling error). Optimizing a noisy surrogate also risks **optimizer's curse** (Smith & Winkler 2006 ★): the selected-best action's estimated value is biased upward _by selection_, even with unbiased estimates of every action — the decision-layer twin of the multiplicity problem the Analysis Run Log exists to police, and the reason post-selection value estimates must be shrunk or re-estimated out-of-sample.

**Stochastic optimization.** Sample average approximation (SAA) replaces expectations with empirical means and solves the deterministic surrogate; stochastic gradient methods (Robbins–Monro 1951 ⚑ lineage) optimize directly on noisy gradients. For the smooth, low-dimensional objectives the lab will actually face (e.g., g(f)g(f) g(f) over a few coordinates), SAA plus a standard solver is the right tool; SGD machinery is for high dimensions.

**Numerical stability.** All probability accounting in log space (log-sum-exp for normalization); never exponentiate early. Log utilities and log scores share a boundary pathology at p∈{0,1}p \in \{0,1\} p∈{0,1} — the clipping convention is owned by [[Proper Scoring Rules and Calibration - Technical Reference]] and applies unchanged to decision computations. Kelly objectives near f→1f \to 1 f→1 are numerically and substantively explosive; constrain the feasible set away from the boundary rather than trusting the optimizer's line search.

**Complexity boundaries worth knowing.** Finite MDPs are polynomial (linear programming); POMDPs are PSPACE-hard in general ⚑; multi-asset growth optimization is a concave program (tractable) but its _inputs_ (a joint distribution over correlated city-days) are the hard part — the statistical estimation dominates the optimization, which is the usual situation in this lab and the reason computational sophistication is rarely the binding constraint.

**Architecture rule.** Keep the belief computation and the decision computation in separate, separately testable modules with the posterior (or forecast distribution) as the only interface — the software form of Thesis 1, and the only structure under which the V1 instrument can be validated independently of any future action layer. (Candidate directive D-DT-1.)

---

## 20. Common misconceptions

**20.1 "The highest-probability outcome is the best action."** Only under 0–1 loss (§10.1). With any asymmetric loss — and money is always asymmetric — the optimal action routinely concerns low-probability states (§10.3, §14.1). The modal bracket is a statistic, not a policy.

**20.2 "Expected value equals expected utility."** Only under linear utility, i.e., stakes negligible relative to bankroll. For repeated capital decisions the relevant expectation is of log wealth, and EV-maximization is the f→f \to f→ everything policy that ruins with probability one ([[Expected Value]], [[Kelly Criterion]], §6.1, §16.2).

**20.3 "More information is always beneficial."** Blackwell's theorem (§11.3) says _weakly better, in expectation, pre-observation, free of charge, for a coherent optimizer_. Outside those qualifiers: information costs (collection, latency, attention); information that cannot change any action has zero value (§11.2); mis-processed information (overfitting, multiplicity) has _negative_ realized value — the Analysis Run Log exists because uncontrolled "more analysis" degrades inference; and in strategic settings public information can destroy value (Hirshleifer 1971).

**20.4 "Maximizing forecast accuracy maximizes profit."** Accuracy (proper score) and profit are linked by the Kelly identity _at executable prices with correct sizing_; they diverge through fees, spread, impact, capital constraints, and correlation. A skill improvement located entirely inside the dead zone (§15.2) changes no action and earns nothing; a small skill edge at a systematically mispriced boundary can dominate. Score differentials are the right _research_ target (V2) precisely because they are action-independent; converting them to P&L is a separate, friction-laden optimization (V3).

**20.5 "Rational decisions eliminate uncertainty."** Rationality guarantees coherent _use_ of uncertainty, nothing more (§4.2). The optimal policy loses on individual realizations at whatever rate the probabilities dictate; judging it requires populations. A lab that graded decisions by outcomes would re-import the exact single-outcome fallacy its foundational principle exists to prohibit.

**20.6 "Do-nothing means the system failed to find a decision."** _(Lab-specific.)_ No-trade is the Bayes action on the overwhelming majority of contract-moments (§15.2). A decision log dominated by "nothing" is evidence of a working loss specification, not a missing one.

---

## 21. Research Lab integration

Decision theory is the corpus's connective tissue: every other document supplies a component of one master computation — _maximize posterior expected log growth, subject to validation gates_ — and this section states each document's role in that computation.

- **[[Probability]]** supplies the object over which expectations are taken and the foundational rule this document extends from beliefs to actions: probabilities are graded on populations; so are decision rules (§4.2). The single-outcome fallacy has a decision-theoretic twin (outcome-grading of decisions), and both are prohibited by the same argument.
- **[[Bayesian Statistics]]** supplies the belief-maintenance machinery (§8): priors, posteriors, hierarchical pooling (which §9.3 upgrades from technique to dominance requirement), and the predictive distributions that are the decision layer's sole input.
- **[[Information Theory for Forecasting]]** supplies the currency in which both skill and growth are denominated; §17 records the identities (entropy = log-loss Bayes risk; EIG = log-loss EVSI) that make information quantities decision quantities.
- **[[Expected Value]]** owns per-decision EV accounting at executable prices and its epistemic conditioning; this document supplies the surrounding theory for why EV is an input to a utility calculation, never a policy (§6, §20.2).
- **[[Kelly Criterion]]** is the corpus's worked instance of the entire framework — the Bayes action under log utility (§16) — and owns all sizing machinery; **[[Log Score and Kelly Identity]]** owns the identity that makes V2's measurement and V3's objective the same quantity.
- **[[Proper Scoring Rules and Calibration - Technical Reference]]** owns the loss functions for distributional actions (§10.2); its generalized-entropy section is the Bayes-risk geometry of §8.2 specialized to prediction.
- **[[Forecast Verification]]** owns the population-level grading of beliefs; §14 adds the user side — value scores, cost–loss thresholds — that converts verification statistics into decision-relevance statements.
- **[[Prediction Markets]]** and **[[Market Microstructure]]** define the mechanism and frictions that shape the realizable action space (§15): executable prices, fees, the dead zone, impact. The de Finetti reading of prices (§3.3) is the bridge between market mechanics and belief semantics.
- **[[Edge Detection]]** answers the _precondition_ question — does a population of disagreements constitute skill? — that gates the entire action layer; in this document's terms, it is the hypothesis test on whether the belief module clears the bar at which its outputs may enter a utility calculation with real stakes.
- **[[Statistical Learning Theory]]** and **[[Machine Learning]]** govern the learned components of the belief module and supply the regret/exploration vocabulary (§18) for the lab's meta-decisions about its own experimentation.
- **[[Research Methodology v2 Canonical]]** and the V-gates are this document's §11.4 and §13.3 in governance form: staged research is a designed sequential decision process whose stopping rules are pre-registered, and whose robustness posture (nothing load-bearing before validation) is the structural response to deep uncertainty.

**The one-sentence integration:** the corpus builds a belief factory ([[Bayesian Statistics]] + the pipeline), a grading system for its output ([[Proper Scoring Rules and Calibration - Technical Reference]] + [[Forecast Verification]] + [[Edge Detection]]), and a theory of the venue ([[Prediction Markets]] + [[Market Microstructure]]); decision theory is the specification of the module that would consume validated beliefs and emit actions — and the proof that this module can be specified last without being designed wrong, because coherent preference _factorizes_ (Thesis 1).

---

## 22. Current research frontiers

- **Uncertainty-aware AI.** Making deep predictive systems emit decision-grade uncertainty (ensembles, Bayesian last layers, conformal methods ⚑) remains unsolved at the calibration standards a capital decision requires; the frontier question for this lab's horizon is when learned post-processing of NWS output produces distributions calibrated enough to feed a sizing rule without a wrapper.
- **Bayesian reinforcement learning.** Treating unknown dynamics as a posterior and solving the resulting belief-MDP (Bayes-adaptive MDPs ⚑) prices exploration exactly but is intractable at scale; practical middle grounds (posterior sampling for RL / PSRL ⚑) carry regret guarantees. Relevant to the lab mainly as the correct _formalism_ for "when should the system experiment with its own policy."
- **Robust and distributionally robust optimization.** Wasserstein-ball and ff f-divergence DRO (Esfahani & Kuhn 2018 ⚑; Duchi–Namkoong lineage ⚑) has matured into tractable convex programs with statistical guarantees, converging with regularization theory. The lab-shaped question: DRO-Kelly — growth optimization against a neighborhood of the estimated joint city-day distribution — as a principled derivation of the Kelly fraction rather than a heuristic one. ⚑ Literature exists on robust growth-optimal portfolios; survey before A-series sizing work.
- **Causal decision theory** in Pearl's sense (§3.9): policy evaluation under distribution shift induced by the policy itself — off-policy evaluation, invariant prediction ⚑. Latent for V1; live the moment any model trains on data collected under a prior version of the system's own behavior.
- **Ambiguity in markets.** Equilibrium models with ambiguity-averse participants predict no-trade regions and premia that resemble microstructure effects; disentangling ambiguity premia from transaction costs in observed spreads is open and directly touches the lab's dead-zone interpretation.
- **Scalable Bayesian decision analysis.** Amortized inference, variational posteriors feeding downstream decisions, and _loss-calibrated_ approximate inference ⚑ (approximate the posterior where it matters for the decision, not in aggregate KL) — the last being conceptually important for the lab: approximation error should be budgeted in units of decision regret, not posterior distance.
- **AI-agent decision architectures.** LLM-based agents currently lack coherent probabilistic beliefs; the open engineering program — relevant to this lab's own Claude-in-the-loop workflows — is grafting explicit decision-theoretic scaffolding (calibrated beliefs, explicit loss, argmax discipline) onto systems whose native outputs are testimony. Invariant 3 is, in effect, the lab's local solution: AI output enters as E4 evidence with a verification gate before it can drive decisions.

**Open problems most likely to matter here:** (i) principled fraction selection under joint parameter-and-model uncertainty (the robust-Kelly question); (ii) sequential inference that respects both optional stopping and decision deadlines (A1 territory); (iii) decision-grade calibration guarantees for post-processed NWP output.

---

## 23. Engineering takeaways and proposed directives

### 23.1 Principles

1. **Separate belief from decision** — distinct modules, forecast distribution as the only interface; validate the belief module first (the V-gate architecture is this principle as governance).
2. **Every action recommendation names its loss** — no argmax without a stated LL L/uu u; no point estimate without its loss convention.
3. **"Do nothing" and "wait" are first-class actions** — absent from A\mathcal{A} A, the system manufactures trades; present, the dead zone does its work.
4. **Expectations at executable prices only** — midpoint EV is a research convenience, never a decision input.
5. **Grade rules on populations, never acts on outcomes** — log belief, action, and loss at decision time so the population audit is possible at all.
6. **Uncertainty prices into size, not into paralysis** — ambiguity and estimation error shrink ff f; only validation failure (gate criteria) sets f=0f = 0 f=0.
7. **Value data by the actions it can change** — EVSI before collection cost; the accrual clock is the depreciation schedule of unpurchased information.
8. **Beware the optimizer's curse** — post-selection value estimates are biased up; shrink or re-measure out-of-sample; the Analysis Run Log is the belief-side twin of this rule.

### 23.2 Common engineering mistakes

Ranking by raw EV across heterogeneous variances; encoding the modal outcome as "the forecast"; letting the backtest's action set include options the venue doesn't offer; recomputing beliefs inside the decision layer (interface violation); treating "no trade today" as a bug; grading a week of outcomes as evidence about the policy; leaving the loss function implicit in code (a hard-coded threshold _is_ a loss claim — surface it).

### 23.3 Proposed directives (pending Architect ratification)

- **D-DT-1 (Module separation).** Belief computation and decision computation live in separate modules; the forecast distribution (plus its epistemic-status metadata) is the sole interface. _Absorption path: Engineering Playbook._
- **D-DT-2 (Loss-explicit outputs).** Any scalar summary of a forecast distribution emitted by the pipeline must carry its loss convention (mean/median/mode/quantile-τ\tau τ) in the schema. _Absorption path: Engineering Playbook / storage schema._
- **D-DT-3 (Decision ledger).** If and when any action layer exists (V3), each decision record stores: belief snapshot, action set considered, loss specification, chosen action, and both timestamps (dual-timestamp discipline). _Absorption path: A-series (V3 spec)._
- **D-DT-4 (No-trade default).** The action layer's null action is "nothing"; every non-null action must clear an executable-price EU test whose parameters are pre-registered. _Absorption path: A-series (V3 spec)._
- **D-DT-5 (VoI re-pricing).** Any change to the action space or loss specification triggers re-evaluation of standing data-collection priorities (EVSI is action-relative). _Absorption path: Research Methodology / A3._
- **D-DT-6 (MC decision hygiene).** Monte Carlo comparisons of candidate actions use common random numbers and report the MC standard error of pairwise differences; no argmax declared inside MC noise. _Absorption path: Engineering Playbook._

---

## 24. Annotated bibliography

> [!warning] Every entry is E4 bibliographic testimony pending verification. ★ = Tier 1 (verify before any load-bearing citation; these feed A-series decisions or registered conventions). Ranking within tiers is by long-term importance to this lab. Recommended reading order for a new researcher: 16 → 4 → 1 → 7 → 5 → 12 → 9 → 2, then by need.

### Tier 1 — Foundational, verify first

1. ★ **Bernoulli, D. (1738). "Specimen theoriae novae de mensura sortis." Trans. as "Exposition of a New Theory on the Measurement of Risk," _Econometrica_ 22 (1954): 23–36.** Utility, concavity, log utility, St. Petersburg. The origin of both expected utility and (via ln⁡w\ln w lnw) the Kelly objective. Read the translation; it is short.
2. ★ **von Neumann, J. & Morgenstern, O. (1944/1947). _Theory of Games and Economic Behavior._ Princeton UP.** The EU representation theorem (2nd ed. appendix). The normative foundation; skim the axioms and theorem statement, not the game theory.
3. ★ **Savage, L. J. (1954). _The Foundations of Statistics._ Wiley (2nd ed. Dover 1972).** Subjective probability + utility from preference axioms; the sure-thing principle. The deepest warrant for the belief/value factorization the lab's architecture assumes. Chapters 1–5.
4. ★ **Wald, A. (1950). _Statistical Decision Functions._ Wiley.** Risk functions, minimax, admissibility, complete classes. Historically decisive; in practice, read via Berger (item 7).
5. ★ **Raiffa, H. & Schlaifer, R. (1961). _Applied Statistical Decision Theory._ Harvard Business School.** Preposterior analysis, EVPI/EVSI, conjugate machinery. The engineering manual of Bayesian decision analysis; §11 descends from it. Pair with **Raiffa, H. (1968). _Decision Analysis._ Addison-Wesley** for the accessible version.
6. ★ **Bellman, R. (1957). _Dynamic Programming._ Princeton UP.** The principle of optimality and the recursion. Read Ch. 1 for the idea; modern statements via Puterman (item 20).
7. ★ **Berger, J. O. (1985). _Statistical Decision Theory and Bayesian Analysis_, 2nd ed. Springer.** The graduate reference unifying §8–9 and §13's robust Bayes; the default citation for admissibility, complete classes, and Bayes/minimax bridges. The single most useful book behind this document.
8. ★ **Kelly, J. L. Jr. (1956). "A New Interpretation of Information Rate." _BSTJ_ 35: 917–926** and ★ **Breiman, L. (1961). "Optimal Gambling Systems for Favorable Games." _Proc. 4th Berkeley Symp._ 1: 65–78.** Growth optimality proposed and proved. Co-owned with [[Kelly Criterion]] / [[Log Score and Kelly Identity]]; listed here as the utility-theoretic instance.
9. ★ **Gneiting, T. (2011). "Making and Evaluating Point Forecasts." _JASA_ 106: 746–762.** Elicitability: losses determine which functional the optimal report reveals. The theorem behind §10.2 and D-DT-2.
10. ★ **Richardson, D. S. (2000). "Skill and Relative Economic Value of the ECMWF Ensemble Prediction System." _QJRMS_ 126: 649–667.** Cost–loss value scores and the value–verification bridge (§14.2). The meteorological decision literature's central modern paper.
11. ★ **Smith, J. E. & Winkler, R. L. (2006). "The Optimizer's Curse: Skepticism and Postdecision Surprise in Decision Analysis." _Management Science_ 52: 311–322.** Selection bias in chosen-action value estimates; the decision-side multiplicity result (§19). Directly feeds lab audit practice.
12. ★ **Lindley, D. V. (1971). _Making Decisions._ Wiley (2nd ed. 1985).** The clearest short exposition of the whole Bayesian decision program; also **Lindley (1956)** (EIG; co-owned with [[Information Theory for Forecasting]]).

### Tier 2 — Core supporting

13. **Ramsey, F. P. (1926/1931). "Truth and Probability." In _The Foundations of Mathematics._** The first representation theorem; subjective probability from betting preferences.
14. **de Finetti, B. (1937). "La prévision: ses lois logiques, ses sources subjectives." _Ann. Inst. Henri Poincaré_ 7: 1–68.** Coherence, Dutch books, exchangeability; the operational semantics of a market price (§3.3).
15. **Bernardo, J. M. (1979). "Expected Information as Expected Utility." _Annals of Statistics_ 7: 686–690.** Inference as decision under log utility; the §17 EIG–EVSI bridge. Co-owned with [[Information Theory for Forecasting]].
16. **Peterson, M. (2017). _An Introduction to Decision Theory_, 2nd ed. Cambridge UP.** The best conceptual on-ramp (normative/descriptive, axioms, paradoxes) before the technical texts. First read for a newcomer.
17. **DeGroot, M. H. (1970). _Optimal Statistical Decisions._ McGraw-Hill (Wiley Classics 2004).** Rigorous Bayesian decision theory including sequential problems; the natural second textbook after Berger.
18. **Blackwell, D. (1953). "Equivalent Comparisons of Experiments." _Ann. Math. Statist._ 24: 265–272.** Information ordering; the exact scope of "more information never hurts" (§11.3). Co-owned with [[Information Theory for Forecasting]].
19. **Stein, C. (1956) / James, W. & Stein, C. (1961). "Estimation with Quadratic Loss." _Proc. 4th Berkeley Symp._ 1: 361–379.** Inadmissibility of the multivariate MLE; the dominance case for pooling across cities (§9.3).
20. **Puterman, M. L. (1994). _Markov Decision Processes._ Wiley.** The MDP reference: existence, value/policy iteration, LP formulations (§12.2).
21. **Kaelbling, L. P., Littman, M. L. & Cassandra, A. R. (1998). "Planning and Acting in Partially Observable Stochastic Domains." _Artificial Intelligence_ 101: 99–134.** The POMDP framework and belief-MDP construction (§12.3).
22. **Murphy, A. H. (1977). "The Value of Climatological, Categorical and Probabilistic Forecasts in the Cost-Loss Ratio Situation." _Monthly Weather Review_ 105: 803–816.** ⚑ (exact title/pages) The cost–loss canon; with **Katz, R. W. & Murphy, A. H., eds. (1997). _Economic Value of Weather and Climate Forecasts._ Cambridge UP** as the field survey.
23. **Gilboa, I. & Schmeidler, D. (1989). "Maxmin Expected Utility with Non-Unique Prior." _J. Math. Econ._ 18: 141–153.** The axiomatic ambiguity model (§13.2).
24. **Ellsberg, D. (1961). "Risk, Ambiguity, and the Savage Axioms." _QJE_ 75: 643–669** and **Allais, M. (1953). "Le comportement de l'homme rationnel devant le risque…" _Econometrica_ 21: 503–546.** The two canonical stress tests of the axioms (§7.4).
25. **Grossman, S. J. & Stiglitz, J. E. (1980). "On the Impossibility of Informationally Efficient Markets." _AER_ 70: 393–408.** Why information-gathering is compensated in equilibrium; co-owned with [[Edge Detection]]; here it grounds §15's participation economics.
26. **Wolfers, J. & Zitzewitz, E. (2006). "Interpreting Prediction Market Prices as Probabilities." NBER WP 12200.** ⚑ When price ≈ mean belief and when risk aversion/wealth effects distort it — the decision-theoretic reading of rr r (§14.3, §15).

### Tier 3 — Machine learning and computation

27. **Sutton, R. S. & Barto, A. G. (2018). _Reinforcement Learning: An Introduction_, 2nd ed. MIT Press.** The RL canon; read Chs. 1–6 for the decision-theoretic core (§18).
28. **Russo, D., Van Roy, B., et al. (2018). "A Tutorial on Thompson Sampling." _Foundations and Trends in ML_ 11(1).** ⚑ Posterior-sampling decisions; Bayesian decision theory in production form.
29. **Gittins, J. C. (1979). "Bandit Processes and Dynamic Allocation Indices." _JRSS B_ 41: 148–177.** ⚑ Exact solution of the discounted bandit; the benchmark for exploration pricing.
30. **Lai, T. L. & Robbins, H. (1985). "Asymptotically Efficient Adaptive Allocation Rules." _Adv. Appl. Math._ 6: 4–22.** ⚑ Regret lower bounds — the unavoidable cost of learning while acting.
31. **Shapiro, A., Dentcheva, D. & Ruszczyński, A. (2009). _Lectures on Stochastic Programming._ SIAM.** SAA theory and stochastic optimization practice (§19).
32. **Garnett, R. (2023). _Bayesian Optimization._ Cambridge UP.** ⚑ Modern BO/acquisition-function reference; §11 in loop form.
33. **Esfahani, P. M. & Kuhn, D. (2018). "Data-Driven Distributionally Robust Optimization Using the Wasserstein Metric." _Math. Programming_ 171: 115–166.** ⚑ The tractable DRO framework behind §22's robust-Kelly question.
34. **Grünwald, P. & Dawid, A. P. (2004). "Game Theory, Maximum Entropy, Minimum Discrepancy and Robust Bayesian Decision Theory." _Annals of Statistics_ 32: 1367–1433.** ⚑ Entropy as minimax Bayes risk; the deep version of §17's first paragraph.

### Tier 4 — Context, history, markets

35. **Knight, F. H. (1921). _Risk, Uncertainty and Profit._ Houghton Mifflin.** The risk/uncertainty distinction in original form (§13.1).
36. **Kahneman, D. & Tversky, A. (1979). "Prospect Theory: An Analysis of Decision under Risk." _Econometrica_ 47: 263–291.** The descriptive counterpoint; in this corpus, a model of the counterparty (§4.3).
37. **Howard, R. A. (1966). "Information Value Theory." _IEEE Trans. SSC_ 2: 22–26.** VoI as engineering; co-owned with [[Information Theory for Forecasting]].
38. **Anscombe, F. J. & Aumann, R. J. (1963). "A Definition of Subjective Probability." _Ann. Math. Statist._ 34: 199–205.** The lighter route to Savage's endpoint (§7.3).
39. **Pearl, J. (2009). _Causality_, 2nd ed. Cambridge UP.** Interventions vs. conditioning; §3.9's do-operator distinction.
40. **Hirshleifer, J. (1971). "The Private and Social Value of Information…" _AER_ 61: 561–574.** ⚑ Public information destroying value; the strategic exception in §11.3/§20.3. Co-owned with [[Information Theory for Forecasting]].
41. **MacLean, L. C., Thorp, E. O. & Ziemba, W. T., eds. (2011). _The Kelly Capital Growth Investment Criterion._ World Scientific.** The Kelly literature collected; co-owned with [[Kelly Criterion]]; here as the repository of the growth-vs-utility debates (Samuelson's objections and responses ⚑).

---

## Appendix — Canonization checklist for the Architect

1. Spot-verify Tier-1 bibliography (items 1–12) against originals; priority ⚑ resolutions: Murphy 1977 exact title/pages (item 22), Wolfers–Zitzewitz 2006 publication status (item 26), Thompson 1952 attribution for the cost–loss threshold (§14.1), the fractional-Kelly/CRRA equivalence's exact conditions (§6.3, §16.2), and the myopic-optimality lineage (Mossin/Hakansson, §16.1).
2. Confirm the notation table (§2) is consistent with [[Log Score and Kelly Identity]] and [[Information Theory for Forecasting]] §2 (qq q truth / pp p lab / rr r market), and that the loss-vs-utility sign convention introduces no conflict with the registered score-orientation convention in [[Proper Scoring Rules and Calibration - Technical Reference]] §2.
3. Ratify, amend, or defer D-DT-1…6; recommended absorption paths are stated per directive (Engineering Playbook: 1, 2, 6; A-series/V3 spec: 3, 4; Methodology/A3: 5).
4. Confirm boundary assignments in the Ownership callout with [[Kelly Criterion]], [[Expected Value]], [[Log Score and Kelly Identity]], [[Information Theory for Forecasting]], and [[Edge Detection]] to prevent dual ownership — particular care on §16 (identification only; no sizing machinery) and §17 (ligaments only; no vocabulary redefinition).
5. Note that §22 (frontiers) is fast-moving and should carry a revisit date if canonized; §15 is V3-gated theory and must not be read as authorizing any action.
6. Grade and stamp.