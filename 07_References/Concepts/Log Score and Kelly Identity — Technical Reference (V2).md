### Type

reference

### Status

AI-drafted V2 — E4 testimony, ungraded pending Architect verification per Invariant 3; NOT canonical until ratified

### Created

2026-07-04

### Revised

2026-07-15

### Review

2027-01-15

### Tags

log-score,kelly-criterion,kl-divergence,proper-scoring-rules,prediction-markets,information-theory,edge-detection,growth-optimal,e-values

### Aliases

Log Score and Kelly Identity,Kelly–log-score identity,Growth–score identity

# Log Score and Kelly Identity — Technical Reference (V2)

**Vault location:** `07_References/Concepts` **Level:** Quantitative researcher reference (assumes [[Probability]], [[Information Theory for Forecasting]], basic convex optimization) **Cross-links:** [[Kelly Criterion]] · [[Proper Scoring Rules and Calibration - Technical Reference (V2)]] · [[Forecast Verification]] · [[Information Theory for Forecasting]] · [[Decision Theory]] · [[Expected Value]] · [[Edge Detection]] · [[Prediction Markets]] · [[Market Microstructure]] · [[Bayesian Statistics]] · [[Glossary]] · [[Open Questions]] **Status:** Version 2 — draft, ungraded pending Architect verification (Invariant 3) **Created:** 2026-07-04 (V1) · **Revised:** 2026-07-15 (V2, full rewrite)

> [!warning] Epistemic status (Invariant 3) This document is AI-drafted testimony, not evidence. It was produced from model knowledge without live retrieval. Every bibliographic citation **must be independently verified (title, year, venue, page-level claims) before any statement here is cited as load-bearing in a registration or ADR**. ★ marks the priority verification tier; ⚑ marks lower-confidence metadata per house convention. The mathematics in §3–§7 is textbook-stable and the lowest-risk layer; §8 (testing by betting) draws on more recent literature and its framing should be verified before governance use. Where this note and any ratified A-series document disagree, the A-series document governs.

> [!info] Supersession note This V2 supersedes the V1 of the same filename (created 2026-07-04, 3,228 characters) in full. The filename is preserved so that all existing `[[Log Score and Kelly Identity]]` backlinks resolve unchanged. V1's metadata error (vault location listed as `01 Research`) is corrected. Under the single-home convention this document is the canonical owner of the identity; parallel treatments elsewhere in the corpus (notably [[Proper Scoring Rules and Calibration - Technical Reference (V2)]] §11.3) should eventually be reduced to cross-references — an Architect decision, out of scope here.

> [!note] Known cross-document inconsistency (flagged, not fixed here) > [[Forecast Verification]] §18.3 states this identity with pp and qq **swapped** relative to the A-series notation standard (there: qq = beliefs, pp = truth). This document follows the registered standard: qq = true distribution, pp = lab forecast, rr = market-implied, information quantities in nats, forward KL written truth-side first. The Forecast Verification passage should be corrected at its next revision.

---

## 1. The claim

For a binary prediction-market contract, three quantities are the same number:

Eq[ln⁡growth]⏟Kelly growth rate  =  Eq[Slog⁡(p;Y)]−Eq[Slog⁡(r;Y)]⏟expected log-score edge over the market  =  DKL(q ∥ r)−DKL(q ∥ p)⏟KL information advantageKelly growth rateEq​[lngrowth]​​=expected log-score edge over the marketEq​[Slog​(p;Y)]−Eq​[Slog​(r;Y)]​​=KL information advantageDKL​(q∥r)−DKL​(q∥p)​​

where qq is the true probability, pp the lab's forecast, rr the market's price-implied forecast, and Slog⁡(p;y)=yln⁡p+(1−y)ln⁡(1−p)Slog​(p;y)=ylnp+(1−y)ln(1−p) the logarithmic score (nats).

**"I have positive expected log growth (before costs)" and "my forecasts log-score better than the market's prices" are the same mathematical statement** — not analogous, identical. This identity is why the lab's V1 measurement instrument (proper-score differentials) and its V3 capital objective (bankroll growth) are one quantity read three ways, and why the V1→V3 architecture is coherent rather than merely staged.

The identity is stronger than an expectation statement. For the full-deployment Kelly bettor it holds **path by path** (§4): the realized log-wealth trajectory _is_ the running sum of realized log-score differentials. The score ledger and the paper-trading ledger, gross of costs, are the same object.

---

## 2. Setup and assumptions

One settlement event Y∈{0,1}Y∈{0,1}. A YES contract pays \$1 if Y=1Y=1; a NO contract pays \$1 if Y=0Y=0.

The identity in its exact form requires all of the following. Each assumption is numbered so that later documents can cite scope conditions individually; §9 catalogs what happens when each fails.

- **A1 (Complete two-sided book).** Both YES and NO are tradeable, at prices rr and 1−r1−r respectively, with r∈(0,1)r∈(0,1) strictly. The implied probabilities sum to exactly 1 — no overround.
- **A2 (Frictionless).** No fees, no bid–ask spread; rr is a single executable price for both sides.
- **A3 (Price-taking, infinite depth).** The bettor's own order does not move rr, and any size executes at rr.
- **A4 (Full deployment, divisibility).** The bettor allocates their entire bankroll across the two contracts in arbitrary real-valued fractions. (Holding cash is not a restriction under A1 — see the replication remark in §3.)
- **A5 (One event at a time).** A single market resolves before the next allocation. No simultaneous correlated exposures.
- **A6 (Known belief).** The bettor's forecast pp is a fixed number, acted on as stated. Estimation error in pp is deferred to §9.2.
- **A7 (Truth exists as a population claim).** qq denotes the true conditional probability of the event given the information available at trade time. Per lab doctrine, a probability is a claim about a population and can only be graded against a population ([[Forecast Verification]]); qq appears here as an analytical device, and every expectation under qq becomes measurable only as an average over a registered population of events.

---

## 3. The allocation lemma

**Lemma (proportional betting).** Under A1–A4, the bettor who maximizes their _subjectively_ expected log wealth — expectation taken under their own belief pp — allocates stake fractions equal to belief: fraction pp of wealth into YES at price rr, fraction 1−p1−p into NO at price 1−r1−r.

_Proof._ Let b∈[0,1]b∈[0,1] be the fraction placed on YES, 1−b1−b on NO. Terminal wealth per unit bankroll is b/rb/r if Y=1Y=1 and (1−b)/(1−r)(1−b)/(1−r) if Y=0Y=0. Subjective expected log growth:

g(b)=pln⁡br+(1−p)ln⁡1−b1−r=[pln⁡b+(1−p)ln⁡(1−b)]+const(r).g(b)=plnrb​+(1−p)ln1−r1−b​=[plnb+(1−p)ln(1−b)]+const(r).

The bracket is the negative cross-entropy −H(p,b)−H(p,b), maximized uniquely at b=pb=p by Gibbs' inequality. Notably, the optimal allocation does not depend on the price rr — prices enter the growth rate but not the optimal stake proportions. This is Cover & Thomas's horse-race result specialized to two outcomes (★ Cover & Thomas 2006, ch. 6). ∎

**Remark (cash is replicated, so A4 is not restrictive).** Under A1, "hold one dollar in cash" is exactly replicated by spending rr on YES and 1−r1−r on NO: the portfolio pays \$1 in every state. Cash is the portfolio b=rb=r. Therefore allowing a cash position adds nothing to the feasible set when the book sums to 1, and — importantly — the Kelly bettor with p=rp=r _is_ in cash: **no divergence, no position.** The identity's dead-zone behavior is built in. When the book does _not_ sum to 1 (overround), cash ceases to be spanned and the lemma fails; see §7.2.

**Remark (subjective vs. objective edge).** The bettor's own expected growth evaluated under their belief is

g(p)=pln⁡pr+(1−p)ln⁡1−p1−r=DKL(p ∥ r)  ≥  0,g(p)=plnrp​+(1−p)ln1−r1−p​=DKL​(p∥r)≥0,

with equality iff p=rp=r. **A coherent Kelly bettor always believes they have non-negative edge.** Belief in edge is free; the identity in §4 prices what reality actually pays, and the difference between believed edge D(p∥r)D(p∥r) and delivered edge D(q∥r)−D(q∥p)D(q∥r)−D(q∥p) is the bettor's own divergence from truth. This is the decision-theoretic reason calibration is non-negotiable before sizing ([[Forecast Verification]] §18.3, [[Kelly Criterion]]).

---

## 4. The identity

### 4.1 Pathwise form (the strong statement)

With the allocation b=pb=p, realized wealth growth on a single event is the likelihood ratio

WafterWbefore=p(y)r(y)wherep(1)=p,  p(0)=1−p,  etc.Wbefore​Wafter​​=r(y)p(y)​wherep(1)=p,p(0)=1−p,etc.

Taking logs,

ln⁡WafterWbefore=ln⁡p(y)−ln⁡r(y)=Slog⁡(p;y)−Slog⁡(r;y).lnWbefore​Wafter​​=lnp(y)−lnr(y)=Slog​(p;y)−Slog​(r;y).

**Realized log growth on each event equals the realized log-score differential on that event.** Over a sequence of events t=1,…,nt=1,…,n with forecasts ptpt​, prices rtrt​, outcomes ytyt​:

  ln⁡WnW0=∑t=1n[Slog⁡(pt;yt)−Slog⁡(rt;yt)]  lnW0​Wn​​=t=1∑n​[Slog​(pt​;yt​)−Slog​(rt​;yt​)]​

No expectation, no asymptotics, no distributional assumption: an accounting identity of the full-deployment proportional bettor. Its consequences for the lab:

1. The paper-trading ledger (gross of costs) and the log-score-differential ledger are **the same time series**. Score tracking is P&L tracking.
2. "Noise in realized growth" and "noise in realized score differentials" are the same noise; there is no additional layer of trading randomness for this bettor beyond outcome randomness.
3. M8.T5's monthly reconciliation — realized paper growth against identity-predicted growth — is a decomposition of this equation plus cost terms, not an approximate comparison of two different objects.

### 4.2 Expectation form

Taking EqEq​ of the single-event equation:

Eq[ln⁡growth]=qln⁡pr+(1−q)ln⁡1−p1−rEq​[lngrowth]=qlnrp​+(1−q)ln1−r1−p​

Regrouping:

=[qln⁡p+(1−q)ln⁡(1−p)]⏟lab’s expected log score−[qln⁡r+(1−q)ln⁡(1−r)]⏟market’s expected log score=H(q,r)−H(q,p)=lab’s expected log score[qlnp+(1−q)ln(1−p)]​​−market’s expected log score[qlnr+(1−q)ln(1−r)]​​=H(q,r)−H(q,p)

a difference of cross-entropies. Adding and subtracting the entropy H(q)H(q):

  Eq[ln⁡growth]=DKL(q ∥ r)−DKL(q ∥ p)  Eq​[lngrowth]=DKL​(q∥r)−DKL​(q∥p)​

The entropy of the event itself — the irreducible unpredictability of weather — cancels. **Only relative distance to truth is paid.** You are not rewarded for the world being predictable; you are rewarded for being less wrong than the price.

### 4.3 Units

Natural log throughout: growth rates and score differentials in **nats per event** (lab standard). Divide by ln⁡2≈0.6931ln2≈0.6931 for bits; a growth rate of gg nats/event compounds wealth by the factor egeg per event.

---

## 5. Corollaries

1. **Edge detection is score comparison.** Positive expected log growth   ⟺  D(q∥p)<D(q∥r)  ⟺  ⟺D(q∥p)<D(q∥r)⟺ the lab's expected log score beats the market's on the registered population. This is the license for the entire V1→V2 measurement program: an edge claim is a score-differential claim, testable by [[Forecast Verification]] machinery before a dollar moves.
2. **Efficiency has a scoring definition.** If r=qr=q, then D(q∥r)=0D(q∥r)=0 and expected growth =−D(q∥p)≤0=−D(q∥p)≤0 for every belief pp, with equality only at p=qp=q (which earns exactly zero). **A market is unbeatable in expectation iff its prices equal the true probabilities.** Within this model, price-equals-truth _is_ the definition of efficiency, and "the market is efficient against me" and "my log score cannot beat the price's" are the same hypothesis (§8 makes this testable).
3. **Being less wrong is enough.** Profit requires D(q∥p)<D(q∥r)D(q∥p)<D(q∥r), not p=qp=q. The forecast need not be right — only closer to truth than the price, in KL.
4. **Growth is capped by the market's own error.** Eq[ln⁡growth]≤D(q∥r)Eq​[lngrowth]≤D(q∥r), attained iff p=qp=q. You cannot extract more than the market is wrong, and you extract it all only by being exactly right. Market error is the resource; forecast error is the leakage.
5. **Perfect-knowledge special case.** If p=qp=q: growth =D(q∥r)=D(q∥r) exactly. This is Kelly's original reading — the growth rate of a true-belief bettor equals the informational deficit of the odds (★ Kelly 1956).
6. **Side information is mutual information.** If the bettor observes side information XX and bets the true conditionals p(⋅∣x)=q(⋅∣x)p(⋅∣x)=q(⋅∣x) against a market pricing the marginal (r=q(⋅)r=q(⋅), i.e., fair odds relative to the unconditional truth), the expected growth is EX[D(q(⋅∣X) ∥ q(⋅))]=I(X;Y)EX​[D(q(⋅∣X)∥q(⋅))]=I(X;Y) — the growth increment from side information equals the mutual information between the information and the outcome (★ Kelly 1956; ★ Cover & Thomas 2006, Thm 6.2.1 ⚑ _theorem number unverified_). For the lab: the value of a data feed, in nats of growth against a marginally-calibrated market, is literally the mutual information it carries about settlement. This is the deepest form of "edge = information," and the reason non-backfillable feeds sit at the top of the accrual-clock priority.

---

## 6. Why log — and only log

The identity is not one instance of a family. It is unique to the logarithm, from both directions.

### 6.1 From the utility side

- **Kelly = expected-utility maximization with u(W)=ln⁡Wu(W)=lnW.** Nothing exotic: the Bayes action for log utility ([[Decision Theory]] §16). The multiplicative dynamics of a bankroll make ln⁡ln the coordinate in which compounding becomes additive, so time-averages of log growth obey the law of large numbers directly.
- **Asymptotic dominance.** Over i.i.d. repetitions, the log-optimal policy achieves the maximal almost-sure exponential growth rate and outgrows any essentially different policy with probability → 1 (★ Breiman 1961; ★ Kelly 1956). Growth-rate optimality is a theorem about _repetition_ — native to the lab's ~150 city-days/month cadence, irrelevant to one-shot bets.
- **Myopic optimality.** Log is the unique CRRA utility for which the dynamic problem separates: today's optimal fraction ignores the horizon (⚑ Mossin 1968 / Hakansson 1971 lineage; owned by [[Decision Theory]] §16). The Kelly bettor legitimately solves a static problem each settlement day.
- **The Samuelson caution (honest limitation).** Growth-optimality does **not** imply optimality for agents with non-log utility, at any horizon, no matter how long (★ Samuelson 1971; ⚑ Samuelson 1979). "Kelly maximizes long-run wealth almost surely" is true and still does not force a power-utility agent to prefer it; the a.s. statement and the expected-utility ranking are different orderings. The lab adopts log growth as a _chosen_ objective — justified by the repetition structure, the ruin-aversion built into ln⁡W→−∞lnW→−∞, and the identity itself — not as a utility-free law of nature.

### 6.2 From the scoring side

- **Strict properness.** Eq[Slog⁡(p;Y)]Eq​[Slog​(p;Y)] is uniquely maximized at p=qp=q; the expected regret of reporting pp is exactly D(q∥p)D(q∥p) ([[Proper Scoring Rules and Calibration - Technical Reference (V2)]]; ★ Good 1952; ★ Gneiting & Raftery 2007). The identity inherits its incentive properties: the market pays honest accuracy.
- **Locality — stated precisely.** On outcome spaces with **three or more** categories, the log score is the unique smooth strictly proper _local_ scoring rule (up to affine transformation): the score depends only on the probability assigned to the realized outcome (★ Bernardo 1979; ⚑ Shuford, Albert & Massengill 1966). **For binary outcomes this uniqueness argument is vacuous** — with two outcomes, pp determines both entries, so every score is trivially local. For the lab's binary brackets, the uniqueness of log rests instead on §6.3.
- **Boundary behavior.** Slog⁡→−∞Slog​→−∞ as confident forecasts meet contrary outcomes. This is a feature (absolute penalty for certainty about falsehoods, mirroring absolute ruin-aversion of ln⁡WlnW at W=0W=0) and an operational hazard near r∈{0,1}r∈{0,1}; the registered boundary rule in [[Forecast Verification]] §9.5 governs. Per that document, the log score is the lab's **registered primary** score subject to the boundary rule — V1 of this document said "co-equal with Brier," which is superseded by the registered convention.

### 6.3 The uniqueness that matters here

Wealth under proportional betting multiplies by the likelihood ratio p(y)/r(y)p(y)/r(y) (§4.1). The logarithm is the unique (up to scale) function turning multiplicative wealth dynamics into an additive quantity, and the log of a likelihood ratio is a difference of log scores. **No other utility makes trading P&L a proper-score differential, and no other proper score is denominated in the units of compounding wealth.** Under any other utility, "expected utility of trading" and "score differential" are different functionals; under any other score, the differential has no wealth reading. The identity is the intersection point of the two uniqueness results, and it is a single point.

---

## 7. Extensions

### 7.1 Multi-outcome markets (bracket books)

The lab's actual instruments are bracket partitions of a settlement variable, not lone binaries. Let outcomes i=1,…,mi=1,…,m partition the settlement space, with market prices riri​, forecast p=(p1,…,pm)p=(p1​,…,pm​), truth qq. If the book is complete and ∑iri=1∑i​ri​=1 (A1 generalized), the lemma and both forms of the identity carry over verbatim:

ln⁡WafterWbefore=ln⁡pYrY,Eq[ln⁡growth]=∑iqiln⁡piri=DKL(q ∥ r)−DKL(q ∥ p).lnWbefore​Wafter​​=lnrY​pY​​,Eq​[lngrowth]=i∑​qi​lnri​pi​​=DKL​(q∥r)−DKL​(q∥p).

This is a property the log score does not share with Brier or RPS: only the categorical log score differential has this exact wealth reading across the whole bracket book. Caveats specific to the lab's markets:

- **Bracket implied probabilities generally do not sum to 1** once extracted from executable prices (spreads, fees, tick discreteness). Extraction and normalization rules are [[Market_Normalization_Spec_v2]] / Open Question 2 territory; the identity applies to the _normalized_ book plus a vig correction (§7.2).
- **Completeness can fail operationally**: not every bracket is tradeable in both directions at meaningful depth at all times.

### 7.2 Overround: where the vig goes

Suppose the (executable) implied probabilities sum to ∑iri=1+θ∑i​ri​=1+θ with overround θ>0θ>0, and define the normalized prices r~i=ri/(1+θ)r~i​=ri​/(1+θ). A bettor who still deploys the full bankroll proportionally (b=pb=p) has

Eq[ln⁡growth]=∑iqiln⁡piri=[DKL(q ∥ r~)−DKL(q ∥ p)]−ln⁡(1+θ).Eq​[lngrowth]=i∑​qi​lnri​pi​​=[DKL​(q∥r~)−DKL​(q∥p)]−ln(1+θ).

**The vig enters as a clean additive drag of ln⁡(1+θ)ln(1+θ) nats per event** on top of the score-differential structure against the _normalized_ book. Two warnings:

1. Under a subfair book (θ>0θ>0), cash is no longer replicated (buying the whole book costs 1+θ1+θ and pays 1), so **proportional betting is no longer optimal**; the growth-optimal allocation may leave outcomes unbet and hold cash, and the display above is a _lower bound_ on optimal growth, not the optimum. Optimal Kelly under unfair odds is [[Kelly Criterion]] machinery.
2. Kalshi's cost structure is not a uniform proportional overround — the fee varies with price level (largest mid-scale) and the effective spread with bracket depth — so θθ is state-dependent and bracket-conditional. V1's claim that costs are "a roughly constant drag" is retired. The correct general statement survives: **costs convert the identity into a threshold condition** — tradeable edge requires the score differential to _exceed_ the state-dependent cost wedge at the executable price, not merely to be positive. Quantification: [[Kelly Criterion]] §11 (fee formula ⚑ there, unratified), [[Expected Value]], [[Forecast Verification]] §18.4.

### 7.3 Fractional Kelly preserves the identity — with a shrunk forecast

Fractional Kelly at fraction λ∈[0,1]λ∈[0,1] (fraction λλ in the Kelly position, 1−λ1−λ in cash) is, by the cash-replication remark under A1, identical to full-deployment proportional betting on the **shrunk forecast**

pλ=λp+(1−λ)r,pλ​=λp+(1−λ)r,

a linear pool of the lab's forecast with the market's. Therefore the identity holds _exactly_ under fractional Kelly, with pλpλ​ in place of pp:

Eq[ln⁡growthλ]=DKL(q ∥ r)−DKL(q ∥ pλ),Eq​[lngrowthλ​]=DKL​(q∥r)−DKL​(q∥pλ​),

and the pathwise form holds with Slog⁡(pλ;yt)Slog​(pλ​;yt​). Reading: **fractional Kelly is not a departure from the identity but a change of forecast — you trade as if you partially believed the market.** Since D(q∥pλ)D(q∥pλ​) interpolates between D(q∥r)D(q∥r) (at λ=0λ=0: zero growth, zero risk relative to cash) and D(q∥p)D(q∥p) (at λ=1λ=1), shrinkage buys variance reduction at a known price in expected growth. Why one _should_ shrink — estimation error, ambiguity, the overbetting asymmetry — is owned by [[Kelly Criterion]] (fractional Kelly as robust Bayes action, per [[Decision Theory]] §16.2). ⚑ _The linear-pool equivalence is standard in the growth-optimal literature but should be verified against a citable source (e.g., MacLean–Thorp–Ziemba 2011 or prediction-market treatments) before load-bearing use._

### 7.4 Sequential and conditional forecasts

Nothing in §4.1 requires the events to be i.i.d. or the forecasts to be static: ptpt​ and rtrt​ may condition on anything known before settlement tt. The pathwise identity is unconditional; the expectation form holds conditionally each period with qtqt​ the true conditional probability. The _almost-sure growth-rate_ interpretation (wealth compounds at the expected rate) additionally requires enough independence/stationarity for a law of large numbers across the registered population — one reason the V1 gate is denominated in gap-audited city-days rather than calendar time.

---

## 8. Wealth as evidence: testing by betting

The pathwise identity gives the paper ledger a second, inferential life.

After nn events, the full-Kelly bettor's wealth relative to start is a **likelihood ratio**:

WnW0=∏t=1npt(yt)rt(yt),W0​Wn​​=t=1∏n​rt​(yt​)pt​(yt​)​,

the likelihood of the observed outcomes under the lab's forecasts divided by their likelihood under the market's prices. Under the efficiency null H0H0​: _the market's prices are the true conditional probabilities_ (rt=qtrt​=qt​ for all tt), each factor has conditional expectation ∑yqt(y) pt(y)/qt(y)=1∑y​qt​(y)pt​(y)/qt​(y)=1, so (Wn/W0)(Wn​/W0​) is a **nonnegative martingale with initial value 1** — an e-process. Ville's inequality (⚑ Ville 1939) then gives, for any α∈(0,1)α∈(0,1):

Pr⁡H0(sup⁡n  Wn/W0 ≥ 1/α)  ≤  α.H0​Pr​(nsup​Wn​/W0​≥1/α)≤α.

**Consequences.**

1. **The paper-trading bankroll is an anytime-valid test statistic of market efficiency.** Multiplying starting paper wealth by 20 against the (frictionless, executable-price) market is evidence against efficiency at level α=0.05α=0.05 — valid under optional stopping, at every nn simultaneously, with no fixed-horizon requirement. This is the "testing by betting" program (★ Shafer 2021; ⚑ Grünwald–de Heide–Koolen e-value literature), and it lands directly on the lab's V2 exit question: _is the measured edge real?_
2. **Optional stopping is licensed, p-hacking is not smuggled in**: e-process validity is exactly what pre-registration-friendly sequential monitoring needs, and it composes with the lab's registration discipline rather than fighting it.
3. **Symmetric humility**: under the null, wealth is an exact martingale in levels (E[Wn]=W0E[Wn​]=W0​) but log-wealth has strictly negative drift whenever pt≠rtpt​=rt​ (Corollary 5.2 with r=qr=q: expected log growth =−D(q∥pt)<0=−D(q∥pt​)<0), so the typical trajectory of a bettor who is wrong about the market being wrong decays exponentially. The privilege of disagreeing with a correct market is paid for in the same units it would have earned.
4. **Scope**: the test statistic is only as meaningful as the prices used. Frictionless paper wealth at _executable_ prices (never mids) is the honest instrument; costs, discretization, and depth caveats from §7.2 and §9 apply before any efficiency claim graduates from this machinery. ⚑ _Framing of this section should be verified against the e-value literature before use in a registration._

---

## 9. Scope conditions and failure modes

The identity is powerful because it is narrow. The register below names each assumption's failure mode and its owning document.

1. **Simultaneous correlated markets (A5 fails).** The lab's real book — multiple city-day brackets resolving together — cannot deploy the full bankroll in each market at once. Per-market identities still hold marginally, but expected growth does **not** decompose as their sum, and per-market Kelly is not jointly optimal. Joint sizing is a portfolio problem: [[Kelly Criterion]].
2. **Estimated beliefs (A6 fails).** With p^≠pp^​=p, the identity holds for the p^p^​ actually bet — reality grades the forecast used, not the forecast intended. The dangers are (i) in-sample score differentials overstate out-of-sample ones (why pre-registration and out-of-sample grading are non-negotiable), and (ii) the growth penalty is asymmetric: overconfident p^p^​ induces overbetting, and overbetting is catastrophic while underbetting is merely slow — in the classical even-odds case, betting double Kelly drives long-run growth to approximately zero (second-order exact for small edges; ⚑ classical, see MacLean–Thorp–Ziemba 2011). **Every unresolved uncertainty pushes size down**; the mechanism is fractional shrinkage (§7.3) with λλ set by [[Kelly Criterion]] doctrine.
3. **Executable price vs. observed price (A2–A3 fail).** The rr in the identity must be the price at which the position actually executes, at size, on the relevant side — not the mid, not the last trade. Divergence Δ=p−rmidΔ=p−rmid​ is not edge; only divergence surviving at the executable price, net of the cost wedge, engages the statistical machinery ([[Market Microstructure]]; Open Question 2). The microstructure dead zone is where the identity's inputs are unmeasurable, not where it is false.
4. **Boundary prices (A1 fails at the edge).** As r→0r→0 or 11, log quantities blow up, tick discreteness dominates, and the fee/depth structure is at its most hostile — precisely where the log score concentrates attention (the FLB region, [[Forecast Verification]] §18.3). Tail-bracket claims face the corpus's highest evidentiary bar; the registered boundary rule ([[Forecast Verification]] §9.5) governs scoring there.
5. **Market impact and depth (A3 fails).** At size, the act of trading moves rr toward pp, consuming the measured divergence. The identity prices the marginal dollar at the pre-trade executable price; average realized growth at size is strictly worse. Depth-aware sizing: [[Kelly Criterion]], [[Market Microstructure]].
6. **Discreteness (A4 fails).** Contracts trade in integer lots at 1¢ ticks; small bankrolls cannot realize real-valued b=pb=p. A rounding drag, second-order for the lab's scale but part of M8.T5's reconciliation residual.
7. **qq is a population claim (A7, always).** No single settlement grades a probability. Every expectation in this document becomes an estimator only over a registered population with gap-audited coverage — the reason the V1 exit gate is denominated in city-days ([[Forecast Verification]]; pre-registration discipline).
8. **Non-log objectives.** Under any other utility the wealth–score identity dissolves (§6.3). An agent maximizing mean wealth (risk-neutral) bets the entire bankroll on any positive edge and ruins almost surely under repetition; agents with other CRRA utilities size differently and their P&L is not a proper-score differential. The identity is a property of the log-utility bettor, adopted deliberately (§6.1).

---

## 10. Worked example

Even-money bracket: true probability q=0.60q=0.60, market price r=0.50r=0.50, lab forecast p=0.58p=0.58 (right direction, imperfect).

**Market's divergence from truth:**

D(q∥r)=0.6ln⁡0.60.5+0.4ln⁡0.40.5=0.6(0.18232)+0.4(−0.22314)≈0.02014 nats.D(q∥r)=0.6ln0.50.6​+0.4ln0.50.4​=0.6(0.18232)+0.4(−0.22314)≈0.02014 nats.

**Lab's divergence from truth:**

D(q∥p)=0.6ln⁡0.600.58+0.4ln⁡0.400.42≈0.6(0.03390)+0.4(−0.04879)≈0.00082 nats.D(q∥p)=0.6ln0.580.60​+0.4ln0.420.40​≈0.6(0.03390)+0.4(−0.04879)≈0.00082 nats.

**Expected growth:** 0.02014−0.00082≈0.019310.02014−0.00082≈0.01931 nats/event — a wealth factor of e0.01931≈1.0195e0.01931≈1.0195, about **1.9% expected bankroll growth per event, gross of costs**, even though the forecast is 2 points off truth. Being less wrong is enough (Corollary 5.3); the cap was D(q∥r)≈2.0%D(q∥r)≈2.0% (Corollary 5.4), and the 2-point forecast error leaked only ≈ 0.08 points of it — KL is quadratically forgiving near truth.

**Sanity check that doubles as a market lesson.** At ~150 city-days/month, a persistent edge of this size would compound e150×0.01931≈e2.90≈18×e150×0.01931≈e2.90≈18× **per month** before costs. Nothing tradeable at size compounds at 18×/month; therefore persistent 10-point mispricings at even odds do not exist at executable prices and depth. Realistic surviving edges are far smaller, which is why (i) the cost wedge in §7.2 is decisive, (ii) the dead zone eats most raw ΔΔ, and (iii) V1's job is building an instrument sensitive enough to measure edges that are small, before V3 is allowed to bet them.

---

## 11. What this document licenses in the lab

- **Edge detection is score comparison** — the V1/V2 measurement program (log-score differentials vs. executable prices over registered populations) _is_ the measurement of the V3 objective, in the same units (nats). No translation layer exists because none is needed.
- **The registered primary score is the log score** (subject to the boundary rule), because it is the unique score denominated in compounding wealth (§6.3); Brier/RPS remain diagnostic instruments ([[Forecast Verification]]).
- **Δ≠Δ= edge.** The identity engages only at executable prices, past the dead zone, net of the state-dependent cost threshold (§7.2, §9.3).
- **All unresolved uncertainty pushes size down**, implemented as shrinkage toward the market (§7.3), governed by [[Kelly Criterion]].
- **The paper ledger is a test statistic.** V2's edge-validation question has an anytime-valid formulation via §8, compatible with pre-registration and optional stopping.
- **Trading remains V3-gated.** Nothing here shortens the gate; the identity is the reason the gate's measurement criterion is the right one.

### Ownership map (single-home convention)

|Concept|Canonical home|
|---|---|
|The identity (pathwise + expectation), fractional-shrinkage corollary, side-information corollary, wealth-as-evidence|**this document**|
|Kelly sizing, fractional Kelly policy, portfolio/joint Kelly, drawdowns, fee formula, V3 gating|[[Kelly Criterion]]|
|Properness theory, LMSR/market scoring rules, calibration theory|[[Proper Scoring Rules and Calibration - Technical Reference (V2)]]|
|Scoring practice, registered score, boundary rule, Murphy diagrams, cost-adjusted verification|[[Forecast Verification]]|
|Entropy/KL/mutual information definitions and vocabulary|[[Information Theory for Forecasting]]|
|Utility framing, Bayes actions, myopic optimality|[[Decision Theory]]|
|Price extraction, executable price, dead zone|[[Market Microstructure]] · [[Prediction Markets]] · Open Question 2|

## 12. References

> All entries are E4 (unverified AI testimony). ★ = priority verification tier (load-bearing); ⚑ = lower-confidence metadata.

- ★ Kelly, J. L. Jr. (1956). "A New Interpretation of Information Rate." _Bell System Technical Journal_, 35(4), 917–926.
- ★ Breiman, L. (1961). "Optimal Gambling Systems for Favorable Games." _Proc. Fourth Berkeley Symposium on Mathematical Statistics and Probability_, Vol. 1, 65–78.
- ★ Cover, T. M., & Thomas, J. A. (2006). _Elements of Information Theory_, 2nd ed. Wiley. Ch. 6 (Gambling and Data Compression), Ch. 16 (Information Theory and Portfolio Theory).
- ★ Good, I. J. (1952). "Rational Decisions." _Journal of the Royal Statistical Society B_, 14(1), 107–114.
- ★ Bernardo, J. M. (1979). "Expected Information as Expected Utility." _Annals of Statistics_, 7(3), 686–690.
- ★ Gneiting, T., & Raftery, A. E. (2007). "Strictly Proper Scoring Rules, Prediction, and Estimation." _JASA_, 102(477), 359–378.
- ★ Samuelson, P. A. (1971). "The 'Fallacy' of Maximizing the Geometric Mean in Long Sequences of Investing or Gambling." _PNAS_, 68(10), 2493–2496.
- ★ Shafer, G. (2021). "Testing by Betting: A Strategy for Statistical and Scientific Communication." _JRSS-A_, 184(2), 407–431.
- ⚑ Samuelson, P. A. (1979). "Why we should not make mean log of wealth big though years to act are long." _Journal of Banking & Finance_, 3(4), 305–307.
- ⚑ Ville, J. (1939). _Étude critique de la notion de collectif_. Gauthier-Villars. (Ville's inequality.)
- ⚑ MacLean, L. C., Thorp, E. O., & Ziemba, W. T., eds. (2011). _The Kelly Capital Growth Investment Criterion: Theory and Practice_. World Scientific.
- ⚑ Hanson, R. (2007). "Logarithmic Market Scoring Rules for Modular Combinatorial Information Aggregation." _Journal of Prediction Markets_, 1(1), 3–15.
- ⚑ Shuford, E. H., Albert, A., & Massengill, H. E. (1966). "Admissible Probability Measurement Procedures." _Psychometrika_, 31(2), 125–145. (Locality.)
- ⚑ Grünwald, P., & Dawid, A. P. (2004). "Game Theory, Maximum Entropy, Minimum Discrepancy and Robust Bayesian Decision Theory." _Annals of Statistics_, 32(4), 1367–1433.
- ⚑ Kullback, S., & Leibler, R. A. (1951). "On Information and Sufficiency." _Annals of Mathematical Statistics_, 22(1), 79–86.
- ⚑ Latané, H. A. (1959). "Criteria for Choice Among Risky Ventures." _Journal of Political Economy_, 67(2), 144–155.
- ⚑ Mossin, J. (1968) / Hakansson, N. (1971) — myopic optimality lineage; exact citations owned by [[Decision Theory]] §16, verify there.
- ⚑ Grünwald, P., de Heide, R., & Koolen, W. (c. 2020–2024). E-value / safe-testing literature; exact primary citation to be established before governance use.