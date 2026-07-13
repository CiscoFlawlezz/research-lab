---
type: reference
status: seed
created: 2026-07-07
---
---

---

## title: "Kelly Criterion" aliases: ["Kelly Criterion", "Kelly", "Growth-Optimal Betting", "Optimal Capital Allocation — Technical Reference", "Log-Optimal Portfolio"] vault_location: "07_References/Concepts" level: "Quantitative researcher reference (assumes probability theory, basic convex optimization, familiarity with [[Probability]] and [[Log Score and Kelly Identity]])" status: "AI-drafted V1 — E4 testimony, ungraded pending Architect verification per Invariant 3; NOT canonical until ratified" supersedes: "Kelly_Criterion.md empty placeholder stub (0 bytes)" created: 2026-07-10 review: 2027-01-10 tags: [kelly-criterion, capital-allocation, position-sizing, information-theory, log-utility, bayesian, robust-optimization, prediction-markets, kalshi, risk-management, numerical-stability]

# Kelly Criterion — Research Synthesis

**Vault location:** `07_References/Concepts` **Level:** Quantitative researcher reference. The sizing layer of the project's stack: it consumes calibrated probabilities and produces capital allocations. **Cross-links:** [[Log Score and Kelly Identity]] · [[Probability]] · [[Bayesian Statistics]] · [[Expected Value]] · [[Proper Scoring Rules and Calibration - Technical Reference (V2)]] · [[Forecast Verification]] · [[Edge Detection]] · [[Prediction Markets]] · [[Kalshi Ticker Anatomy and Market Structure]] · [[Effective Sample Size]] · [[Machine Learning]] · [[Brier Decomposition - Worked Example]] · [[Glossary]] · [[Open Questions]] **Status:** Version 1 — draft, ungraded pending Architect verification (Invariant 3) **Created:** 2026-07-10

> [!warning] Epistemic status (Invariant 3) This document is AI-drafted testimony, not evidence. It was produced from model knowledge without live retrieval, following the convention of [[Forecast Verification]] V2 and [[Probability]]. Every bibliographic citation **must be independently verified (title, year, venue, page-level claims) before any statement here is cited as load-bearing in a registration or ADR**. Lower-confidence citations carry ⚑ per house convention; ★ marks the priority verification tier. The mathematics in §2–§10 is textbook-stable and the lowest-risk layer; bibliographic metadata, empirical effect sizes (§16), and the Kalshi fee formula (§11.4 ⚑) are the most fragile. Where this note and any ratified A-series document disagree, the A-series document governs.

> [!info] Supersession note This document replaces the prior `Kelly_Criterion.md`, which was an **empty placeholder stub** — precisely the structural bug the methodology prohibits. Existing `[[Kelly Criterion]]` backlinks throughout the vault (from [[Log Score and Kelly Identity]], [[Edge Detection]], [[Forecast Verification]], [[Probability]], and others) now resolve here. Per the single-source rule, the stub is superseded in full.

> [!note] Scope discipline Reference document, not an ADR. Nothing here modifies the methodology, the city-day unit, the reference ladder, the V-gate roadmap, or any settled decision. **Live Kelly sizing remains gated behind V3; the only Kelly machinery authorized before then is the V2 paper ledger.** The engineering directives in §23 are _proposals_ pending Architect ratification, flagged [NEW] where they are not already standing policy elsewhere.

---

## 0. Orientation: what this document is for

The Research Lab's pipeline separates three questions that casual treatments of trading conflate: _Is the market wrong?_ ([[Edge Detection]]), _By how much, in growth units?_ ([[Log Score and Kelly Identity]]), and _Given a validated answer to the first two, how much capital goes on each contract?_ This document answers only the third. It is deliberately downstream: Kelly sizing consumes a calibrated probability $P_f$, a market price, and a cost model, and emits a stake. If the probability is not calibrated — if the forecaster has not survived the verification machinery of [[Forecast Verification]] and the population-level inference of [[Edge Detection]] — then everything below is a precise answer to a question that has not yet been earned. The single most important sentence in this reference is therefore its first engineering directive: **Kelly is the last stage of the pipeline, never the first.**

---

## 1. Historical Development

### 1.1 Bell Labs, 1956

The Kelly criterion did not come from gambling or from finance. It came from a physicist at Bell Telephone Laboratories thinking about Claude Shannon's channel capacity. John L. Kelly Jr., a Texan acoustics and signal-processing researcher, published "A New Interpretation of Information Rate" in the _Bell System Technical Journal_ in 1956 (★ Kelly 1956). Shannon's 1948 theory (★ Shannon 1948) had defined the capacity of a noisy channel as the maximum mutual information between input and output, and had shown that reliable communication is possible at any rate below capacity. Capacity was defined operationally in terms of coding; Kelly asked whether the same quantity had an _economic_ interpretation that did not require any coding at all.

His construction: a gambler receives advance information about the outcomes of baseball games (in the paper's framing, over a noisy private wire — the mid-century "wire service" that transmitted race and game results). The gambler cannot re-transmit or decode anything; all he can do is bet. Kelly showed that if the gambler bets to maximize the expected logarithm of wealth, the exponential growth rate of his capital equals the mutual information rate of the channel carrying his tips. Channel capacity, a purely communication-theoretic quantity, is _literally_ the maximum rate at which side information can be converted into compound wealth growth. Anecdotally, AT&T management was uneasy about a Bell System publication framed around bookmaking, and the published title is the sanitized one ⚑ (the gambling framing survives in the body; the anecdote is via Poundstone 2005 and should not be treated as verified corporate history).

This origin explains a fact that surprises newcomers: the Kelly criterion is not an axiom about human preferences and not a piece of financial folklore. It is a theorem in information theory, and its natural units — bits, entropy, KL divergence — are the same units in which this project scores forecasts. The vault's [[Log Score and Kelly Identity]] is the local expression of Kelly's original insight.

### 1.2 Independent economics lineage

Henry Latané independently proposed the geometric-mean criterion for portfolio selection in economics (⚑ Latané 1959, _Journal of Political Economy_), apparently unaware of Kelly. Leo Breiman then supplied the rigorous asymptotics (★ Breiman 1961): among all betting strategies, the log-optimal one asymptotically dominates in growth rate and asymptotically minimizes the expected time to reach a distant wealth target. Breiman's paper converted Kelly's calculation into the two optimality properties that still anchor the theory (§2.4).

### 1.3 Thorp and practice

Edward O. Thorp made the criterion operational. His card-counting system for blackjack (_Beat the Dealer_, 1962 ★) used Kelly sizing to survive the variance of a small, fluctuating edge; his warrant-hedging work with Sheen Kassouf (_Beat the Market_, 1967) and his hedge fund Princeton Newport Partners carried the same logic into securities. Thorp's later synthesis papers (★ Thorp 1971; ★ Thorp 2006) remain the best practitioner-grade treatments: they contain the fractional-Kelly drawdown formulas (§7, §13) and the sober warnings about estimation error (§8) that popularizations omit. Thorp and Shannon also built what is usually described as the first wearable computer, for predicting roulette — an anecdote relevant here only as evidence that the founders treated Kelly as an engineering discipline attached to a _measured_ edge, never as a substitute for one.

### 1.4 The Samuelson controversy

Paul Samuelson attacked the criterion's normative pretensions in a famous series of papers (★ Samuelson 1971; Samuelson 1979 — the latter written almost entirely in one-syllable words to make the point unmissable). His argument, which is _correct_ and is accepted as such by the modern Kelly literature (MacLean–Thorp–Ziemba 2011): maximizing expected log wealth is optimal _if and only if_ your utility is logarithmic. No limit theorem forces log utility on you. An investor with stronger risk aversion rationally bets less than Kelly forever, no matter how long the horizon, and "in the long run Kelly wins almost surely" does not imply "Kelly maximizes your expected utility." The mature position — the one this project adopts — is that Kelly is a _growth-rate-optimal reference point with known properties_, from which deliberate, registered deviations (fractional Kelly, caps) are made for risk, robustness, and estimation-error reasons. §6 and §18.5 develop this.

### 1.5 Modern era

William Poundstone's _Fortune's Formula_ (2005) is the standard popular history (useful for narrative, never citable for numbers). The MacLean–Thorp–Ziemba anthology (★ 2011, _The Kelly Capital Growth Investment Criterion_) collects the primary literature and is this document's default "see the anthology" reference. In current quantitative finance, Kelly survives as: the log-utility special case of Merton's continuous-time portfolio problem (§10.2); the theoretical backbone of growth-optimal and universal portfolio theory (Cover 1991); a live research area in robust and Bayesian optimization (§14, §9); and the standard sizing framework in sports-betting and prediction-market quantitative work — the literature nearest this project's use case.

---

## 2. Mathematical Foundations

### 2.1 The multiplicative setting

Kelly applies when capital compounds: wealth after $n$ bets is a _product_, $W_n = W_0 \prod_{t=1}^{n} G_t$, where $G_t > 0$ is the growth factor of period $t$. Prediction market trading is multiplicative in exactly this sense — stakes scale with the bankroll, and losses shrink the base from which future gains compound. This is the structural fact from which everything follows. In an additive setting (fixed stake regardless of wealth, external income dominating), Kelly's logic does not bind.

### 2.2 Why the logarithm appears

Take logs: $\ln W_n = \ln W_0 + \sum_t \ln G_t$. The log converts a product of random factors into a sum of random terms, and sums are what the law of large numbers governs. If the $\ln G_t$ are i.i.d. (or stationary ergodic — Algoet–Cover 1988 ★) with mean $g = \mathbb{E}[\ln G]$, then almost surely

$$\frac{1}{n}\ln \frac{W_n}{W_0} ;\longrightarrow; g.$$

The long-run _realized_ exponential growth rate of every strategy is its expected log growth. Not its expected growth factor, not its expected profit — its expected log. This is not a preference statement; it is the strong law of large numbers applied to compounding. Maximizing $g$ therefore maximizes the almost-sure asymptotic growth rate of capital. The quantity $g$ is called the **growth rate** (Cover–Thomas call $2^{g}$-style versions the _doubling rate_ when logs are base 2).

### 2.3 The optimization problem

Let the bettor allocate fraction vector $\mathbf{f}$ of current wealth across available contracts with random per-dollar net return vector $\mathbf{R}$. The Kelly problem is

$$\max_{\mathbf{f} \in \mathcal{F}} ; g(\mathbf{f}) = \mathbb{E}\big[\ln(1 + \mathbf{f}^\top \mathbf{R})\big],$$

with $\mathcal{F}$ the feasible set (typically $f_i \ge 0$, $\sum_i f_i \le 1$ for a no-leverage cash account). Two properties make this an unusually well-behaved problem: $g$ is **concave** in $\mathbf{f}$ (log of an affine function), so every local optimum is global and convex-optimization machinery applies (§19.6); and $g \to -\infty$ as any outcome's growth factor approaches zero, so the optimizer _automatically_ avoids any allocation with positive probability of total ruin. Kelly never bets everything on an uncertain outcome — the log utility's infinite penalty at zero is the built-in survival constraint.

### 2.4 Asymptotic optimality (Breiman's properties)

Breiman (1961 ★), extended by Finkelstein–Whitley (1981 ⚑) and Algoet–Cover (1988 ★), established, for the log-optimal strategy $\Lambda^*$ against any competing strategy $\Lambda$:

1. **Growth dominance.** $\lim_n \frac{1}{n}\ln\big(W_n^{\Lambda^_}/W_n^{\Lambda}\big) \ge 0$ almost surely; if $\Lambda$ differs materially from $\Lambda^_$, the ratio $W_n^{\Lambda^*}/W_n^{\Lambda} \to \infty$ a.s.
2. **Minimal time to a goal.** $\Lambda^*$ asymptotically minimizes the expected time to reach any sufficiently distant wealth target.
3. **Competitive optimality** (Bell–Cover 1980 ⚑). In a one-shot game, log-optimal wealth cannot be beaten in probability by more than a fair-coin margin: $\Pr(W^{\Lambda} \ge W^{\Lambda^*}) \le \tfrac{1}{2}$ under a fair randomization, so log-optimality is not only an asymptotic property.
4. **Median/quantile optimality** (⚑ Ethier 2004). Full Kelly maximizes the median of long-run fortune — a useful framing because the _mean_ of terminal wealth is maximized by insane all-in strategies whose expectation is carried by vanishing-probability paths (§5.3).

Equally important is what these theorems do **not** say: nothing about finite-horizon expected utility for non-log utilities (Samuelson, §1.4), nothing about the _speed_ of the asymptotics (convergence is slow — §13.2), and nothing when the probabilities fed in are wrong (§8).

---

## 3. The Information Theory Connection

### 3.1 Growth rate as an information quantity

For a "horse race" — one of $m$ mutually exclusive outcomes occurs, outcome $i$ with probability $p_i$, paying gross odds $o_i$-for-1 — a bettor who wagers proportions $b_i$ of wealth (with $\sum b_i = 1$, full investment) has growth rate

$$g(\mathbf{b}) = \sum_i p_i \ln (b_i, o_i).$$

Maximizing over $\mathbf{b}$ gives $b_i^* = p_i$: **proportional betting** ("betting your beliefs"), independent of the odds. The optimal growth rate decomposes as

$$g^* = \sum_i p_i \ln o_i ; - ; H(p),$$

where $H(p) = -\sum p_i \ln p_i$ is the Shannon entropy of the outcome. Growth is what the odds pay minus the intrinsic unpredictability of the event. Low-entropy events (near-certain outcomes) support fast growth _if the odds have not already priced that certainty_; high-entropy events cap achievable growth no matter how good the forecaster. This is the sizing-layer shadow of the **uncertainty (UNC)** term in the Murphy decomposition ([[Brier Decomposition - Worked Example]]): the same climatological entropy that bounds resolution bounds growth.

### 3.2 Side information is worth exactly its mutual information

Kelly's central theorem: if the bettor observes side information $Y$ about outcome $X$ before betting, the increase in the maximum growth rate is

$$\Delta g^* ;=; I(X;Y),$$

the mutual information between the outcome and the signal (Kelly 1956 ★; Cover–Thomas 2006 ch. 6 ★). A forecasting system is, in Kelly's sense, a _channel_, and its economic value to a log-optimal bettor is its information rate — capacity when the channel is used optimally. This is the deepest justification for this project's scoring conventions: the log score measures, in nats, exactly the quantity that compounds.

### 3.3 The KL identity (local canonical form)

Against a market quoting price $r$ for a binary event with true probability $q$, a log-utility bettor holding belief $p$ achieves (see the derivation in [[Log Score and Kelly Identity]], which this document treats as the canonical vault statement)

$$\mathbb{E}_q[\ln \text{growth}] ;=; D_{\mathrm{KL}}(q,|,r) ;-; D_{\mathrm{KL}}(q,|,p).$$

Growth is the difference of two divergences: how wrong the market is, minus how wrong you are. Every consequence the project has already ratified follows — edge is a score difference, an efficient market ($r=q$) is unbeatable, being _less wrong_ than the price suffices, and costs enter as a threshold on the score gap. Nothing in the present document modifies that note; §4 and §11 extend it to sizing, multiple outcomes, and costs.

### 3.4 Coding-theory intuition

The mapping to source coding is exact. An idealized codebook assigns an outcome of probability $p_i$ a codeword of length $-\ln p_i$ nats; redundancy — coding with lengths matched to a wrong distribution $r$ while the source is $q$ — costs exactly $D_{\mathrm{KL}}(q|r)$ extra nats per symbol. A market price is a code for the future; a mispriced market is a redundant code; and the Kelly bettor is an arbitrageur of coding inefficiency, extracting the redundancy as growth. "Information efficiency" of a market has, through this lens, a quantitative meaning: the expected number of nats per contract that a correctly-calibrated observer could extract. [[Edge Detection]]'s program is the measurement of that quantity with honest error bars.

---

## 4. Derivations of the Kelly Criterion

Every derivation below makes the same four assumptions, stated once: **(A1)** wealth is infinitely divisible (no minimum ticket); **(A2)** the bet is available repeatedly under i.i.d. or stationary-ergodic conditions; **(A3)** the probabilities used are the _true_ probabilities (relaxed in §8–§9); **(A4)** there are no frictions (relaxed in §11–§12). Each relaxation moves the optimum, always downward in aggressiveness.

### 4.1 Binary bet, even money

Win probability $p$, lose probability $q = 1-p$, stake $f$ returned double on a win, lost on a loss:

$$g(f) = p\ln(1+f) + q\ln(1-f), \qquad g'(f) = \frac{p}{1+f} - \frac{q}{1-f}.$$

Setting $g'=0$: $;f^* = p - q = 2p - 1$ — the _edge_. Optimal growth $g^* = \ln 2 + p\ln p + q\ln q = \ln 2 - H(p)$: the growth rate is the information deficit of a fair coin, recovering §3.1.

### 4.2 Binary bet, general odds

Net odds $b$-to-1 (win $b$ per unit staked, lose the unit):

$$g(f) = p\ln(1+bf) + q\ln(1-f) \quad\Longrightarrow\quad f^* = \frac{bp - q}{b} = p - \frac{q}{b}.$$

The numerator $bp - q$ is the expected net return per unit staked — the **edge**; the denominator is the odds. The classical slogan "edge over odds" is this formula. $f^* > 0$ iff $bp > q$ iff expected value is positive: Kelly bets nothing on negative-EV propositions and the empty bet is always feasible, which is why $g^* \ge 0$ always.

### 4.3 Prediction-market form (the project's working formula)

A YES contract pays $1 and costs price $r \in (0,1)$. Per dollar staked the net odds are $b = (1-r)/r$. Substituting into §4.2:

$$\boxed{,f^__{\text{YES}} = \frac{p - r}{1 - r},} \qquad (p > r), \qquad\qquad \boxed{,f^__{\text{NO}} = \frac{r - p}{r},} \qquad (p < r),$$

where the NO side is the purchase of the complementary contract at price $1-r$. Interpretation: the stake is the disagreement $\Delta = p - r$ ([[Edge Detection]]'s raw material) _scaled by the price of the side you are buying's complement_. Cheap longshots (small $r$) get small fractions even for a fixed $\Delta$; expensive favorites tolerate larger fractions. Note carefully what this formula is **not**: it is not licensed by observing $\Delta \ne 0$. Disagreement is not edge; this formula is applied, in this project, only to forecasters that have cleared [[Edge Detection]]'s population-level gate, and until V3 only on paper.

A useful identity: at the optimum, expected log growth equals the KL gap of §3.3 evaluated at $q = p$ (the bettor's own belief), i.e. the _subjective_ growth rate is $D_{\mathrm{KL}}(p|r)$. The _realized_ long-run growth substitutes the true $q$ — the gap between the two is precisely the forecaster's own miscalibration penalty $D_{\mathrm{KL}}(q|p)$. Calibration failures are paid for in growth units, linearly, always.

### 4.4 Both-sides formulation

The [[Log Score and Kelly Identity]] derivation uses the "bet your beliefs on both sides" construction — fraction $p$ of wealth on YES and $1-p$ on NO — which is the horse-race proportional bet of §3.1 specialized to $m=2$. With a two-sided frictionless market the two formulations produce identical wealth paths; with real spreads they differ, and the executable-price question is Open Question 2 in [[Open Questions]], owned by A4. This document defers to A4's eventual registered rule for which price enters the formulas.

### 4.5 Multiple mutually exclusive outcomes (bracket markets)

Kalshi daily-high markets are **bracket markets**: outcomes $i = 1,\dots,m$ partition the temperature line; exactly one bracket settles YES ([[Kalshi Ticker Anatomy and Market Structure]]). This is a horse race with prices $r_i$ (gross odds $o_i = 1/r_i$) and model pmf $p_i$ from the NWS-derived rung of the reference ladder.

Two regimes, distinguished by the **overround** $S = \sum_i r_i$:

- **Fair-in-aggregate ($S = 1$, no take).** Full-investment proportional betting $b_i = p_i$ is optimal, with growth $g^* = D_{\mathrm{KL}}(p ,|, r)$ — the multi-outcome generalization of §3.3, and the cleanest statement in the entire theory: _growth equals the KL divergence from your pmf to the market's pmf._
- **Overround ($S > 1$, the realistic case — fees and spreads make effective prices sum past one).** Full investment is no longer optimal; holding cash is a strictly useful option. The solution is a **water-filling** program: bet only on outcomes whose $p_i / r_i$ ratio exceeds a threshold determined by the budget constraint, with stakes $f_i = p_i - \lambda r_i$ for active outcomes ($\lambda$ solving the complementary-slackness condition), zero elsewhere. Closed-form threshold procedures exist (⚑ Smoczynski–Tomkins 2010; the structure is standard KKT analysis of the concave program). Engineering consequence: in an overround bracket market Kelly typically concentrates on the one or two brackets with the largest probability ratios and ignores the rest — it does _not_ spread across all disagreements.

### 4.6 General case

For arbitrary payoff distributions (continuous returns, correlated simultaneous contracts) no closed form exists; the problem remains the concave program of §2.3, solved numerically (§10.4, §19.6). Every closed form above is a special case and should be unit-tested against the numerical solver, not the other way around.

---

## 5. Expected Log Growth: Arithmetic vs. Geometric

### 5.1 Volatility drag

For a return $R$ with mean $\mu$ and variance $\sigma^2$, small-return expansion gives $\mathbb{E}[\ln(1+R)] \approx \mu - \tfrac{1}{2}\sigma^2$. Geometric (compound) growth is arithmetic expectation _minus half the variance_. Two strategies with equal expected value but different variance have different long-run growth; variance is not merely a "risk" attribute to be traded off against return — in a multiplicative world it is a direct subtraction from realized growth. This term, the **volatility drag**, is why over-betting destroys wealth even at positive expected value.

### 5.2 The over-betting cliff

In the continuous approximation with a single opportunity of drift edge $\mu$ and variance $\sigma^2$, the growth rate of fraction $f$ is $g(f) = f\mu - \tfrac{1}{2}f^2\sigma^2$: a downward parabola with maximum at the **Merton/Kelly fraction** $f^* = \mu/\sigma^2$ and peak growth $g^* = \mu^2/2\sigma^2$. Three facts every implementer must internalize:

1. $g(2f^*) = 0$. Betting **double** Kelly annihilates growth entirely while retaining all the variance.
2. $g(f) < 0$ for $f > 2f^*$: beyond twice Kelly, a _positive-EV_ strategy loses money almost surely in the long run.
3. The curve is flat near the top but the _risk_ is not: moving from $f^_$ to $\tfrac{1}{2}f^_$ sacrifices only 25% of growth (§7.1) while halving volatility. Growth is forgiving to under-betting and merciless to over-betting — the asymmetry that drives everything in §7–§8.

### 5.3 Why maximizing expected wealth is the wrong objective

Expected terminal wealth $\mathbb{E}[W_n]$ is maximized by staking everything on the highest-EV outcome every period. For a $p = 0.6$ even-money coin, all-in for $n$ rounds gives $\mathbb{E}[W_n] = W_0 (1.2)^n \to \infty$ while $\Pr(\text{ruin}) = 1 - 0.6^n \to 1$. The expectation is carried entirely by a single exponentially-unlikely path. This is the ensemble-average/time-average distinction: $\mathbb{E}[W_n]$ averages over parallel universes; a research lab lives on one sample path, and what its one path earns is governed by $\mathbb{E}[\ln G]$ (§2.2). (The "ergodicity economics" program of Peters ⚑ makes this observation its centerpiece; the observation itself is classical — it is in Kelly 1956 — and none of this project's machinery depends on the newer program's contested claims.) See [[Expected Value]] for the EV layer; EV determines _whether_ to bet, log growth determines _how much_.

---

## 6. Utility Theory: What Kelly Assumes and What It Doesn't

### 6.1 Log utility and CRRA

The constant-relative-risk-aversion (CRRA) family is $u(w) = \frac{w^{1-\gamma}-1}{1-\gamma}$, with $\gamma \to 1$ giving $u(w) = \ln w$. Kelly is exactly expected-utility maximization for $\gamma = 1$. Higher $\gamma$ (more risk-averse) implies smaller optimal fractions; in the continuous-time lognormal setting the CRRA-optimal fraction is $f^*_\gamma = \mu/(\gamma\sigma^2)$ — i.e., **fractional Kelly with fraction $c = 1/\gamma$** (★ Merton 1969; the identification of fractional Kelly with CRRA is standard, e.g., MacLean–Thorp–Ziemba 2010/2011, and is _exact_ only under lognormality — a caveat that matters for skewed bracket payoffs ⚑).

### 6.2 The correct resolution of the Samuelson debate

Both sides are right about different claims. Kelly's defenders are right that log-optimality has objective, preference-free consequences (Breiman's properties, §2.4). Samuelson is right that those consequences do not compel anyone to adopt the objective: a $\gamma = 3$ investor who understands everything above still rationally bets a third of Kelly, forever. The project's stance: **the Kelly fraction is an instrument reading, not a command.** It is the uniquely well-defined "100% mark" on the sizing dial — the point beyond which more aggression is unambiguously irrational for _every_ CRRA investor (since $g$ declines and variance rises). Where to sit below that mark is a registered risk-policy decision (§20), not a theorem.

### 6.3 Non-CRRA considerations

Log utility is unbounded below, which is why Kelly refuses ruin (§2.3) — a feature. It is also unbounded above and myopic under i.i.d. returns (the multi-period log problem decomposes into independent single-period problems — Hakansson 1970 ⚑ — which is what makes online Kelly simple, §15.1). Drawdown-based preferences, loss aversion, and bounded utilities all generate different sizing rules; none has the information-theoretic anchoring of §3, which is why this project treats them as _constraints layered on top of_ Kelly (§13, §20) rather than replacement objectives.

---

## 7. Fractional Kelly

### 7.1 Definitions and the growth–risk exchange rate

Fractional Kelly with fraction $c \in (0,1]$ stakes $c f^*$. In the continuous approximation (§5.2):

$$g(c f^_) = c(2-c),g^_.$$

Half Kelly ($c = \tfrac12$) earns $75%$ of maximal growth with half the position volatility; quarter Kelly earns $43.75%$ with a quarter of the volatility. The exchange rate is excellent near $c=1$ and the risk reduction is dramatic: under the geometric-Brownian approximation the probability that wealth _ever_ falls to fraction $x$ of its starting value under fractional Kelly $c$ is

$$\Pr\big(\inf_t W_t \le x W_0\big) = x^{,2/c - 1}$$

(★ Thorp 2006 presents this family of formulas). Full Kelly: $\Pr = x$ — a **10% chance of ever losing 90% of the bankroll**. Half Kelly: $x^3$ — the same 90% drawdown has probability $0.1%$. This single pair of numbers is the practitioner case for fractional Kelly.

### 7.2 Why professionals bet fractionally

Three independent reasons, usually all operative:

1. **Estimation error (dominant — §8).** The input $p$ is estimated; over-estimates of edge cause over-betting, and over-betting is catastrophic (§5.2) while under-betting is cheap. Fractional Kelly is a crude but robust hedge against one's own miscalibration.
2. **Model misspecification.** Real payoff distributions have fatter tails, correlations, and regime shifts absent from the model; the true $f^*$ under the true distribution is smaller than the computed one more often than not.
3. **Risk preference and survival of the institution** (§6.2, §13.4). Even with perfect probabilities, full-Kelly drawdowns exceed what most humans and all investors-with-clients tolerate.

The growth–security tradeoff was formalized by MacLean–Ziemba–Blazenko (★ 1992, _Management Science_), who show fractional Kelly traces an efficient frontier between growth rate and security measures (probability of reaching a goal before a drawdown barrier). MacLean–Thorp–Ziemba (★ 2010, "good and bad properties") is the canonical summary: full Kelly's good properties are asymptotic, its bad properties (violent drawdowns, sensitivity to error) are immediate.

### 7.3 Adaptive and dynamic fractions

Nothing requires $c$ to be constant. Proposals in the literature: raise $c$ as the estimation sample grows (uncertainty-scaled Kelly, §8.4); lower $c$ after drawdowns (although this is _not_ implied by Kelly theory — Kelly stakes are already proportional to current wealth, which is automatic drawdown response; further reduction is a separate risk-policy overlay); regime-dependent $c$. For this project, any $c$-schedule is part of the **registered sizing rule**: changing $c$ mid-sample is the sizing-layer analog of post-hoc recalibration, and per standing methodology a re-registration event (a "new registered forecaster" in the sense already ratified for calibration — the same principle applies to the sizing rule).

### 7.4 Empirical comparisons

Simulation and historical studies (collected in the MacLean–Thorp–Ziemba anthology; see §16) consistently find: full Kelly maximizes median/terminal growth over long horizons but with drawdown distributions unacceptable in practice; half Kelly is the most common professional default; fixed-fraction non-Kelly sizing (stake a constant fraction regardless of edge) underperforms because it ignores edge magnitude; risk-parity-style volatility targeting is a different objective (equalize risk contributions) that coincides with Kelly only under special homogeneity conditions ⚑ — comparisons are in §16.

---

## 8. Parameter Uncertainty: The Dominant Practical Problem

### 8.1 The asymmetry theorem of practice

Everything in §4 assumed the true $p$ is known (A3). It never is. The consequences are governed by the shape of $g(f)$ (§5.2): if the estimate $\hat{p}$ overstates the edge, the computed $\hat{f}^_$ exceeds the true optimum, and the penalty grows quadratically then catastrophically (past $2f^__{\text{true}}$, growth goes negative). Understating the edge merely leaves growth on the table. **Errors in $p$ are not symmetric in consequence, so unbiased estimation is not the right target — conservative estimation is.** In realistic settings the loss from estimation error dwarfs the loss from choosing, say, half Kelly instead of a cleverly optimized fraction; probability estimation quality dominates sizing sophistication. This is why the project's effort allocation — months of [[Forecast Verification]] machinery before a single sized position — is not caution for its own sake but the correct engineering priority.

### 8.2 Where the errors come from

For this project specifically: sampling error in calibration estimates bounded by city-day counts (~150/month; [[Effective Sample Size]] governs the honest $n$ under cross-city same-day correlation); nonstationarity (seasonal regime shifts in forecast skill); selection effects if edge is measured on the same sample that triggered attention ([[Edge Detection]]'s multiple-testing machinery exists precisely to prevent this from contaminating the $p$ that reaches the sizing layer); and market-side error — $r$ itself must be extracted by A4's registered rule, and mid-vs-microprice or staleness errors propagate into $\Delta$ and hence into $f^*$ linearly (§4.3).

### 8.3 Shrinkage and conservative sizing

The generic prescriptions, in increasing sophistication: (i) fractional Kelly as blanket insurance (§7.2); (ii) shrink $\hat{p}$ toward the market price $r$ (equivalently toward "no edge") before computing $f^*$ — a one-parameter empirical-Bayes move whose shrinkage weight can be set from the calibration sample size; (iii) size on a lower confidence bound of the edge rather than the point estimate (⚑ Baker–McHale 2013 develop shrinkage-Kelly under estimation error and find aggressive shrinkage optimal at realistic sample sizes); (iv) full robust formulations (§14). Options (ii) and (iii) have a clean property worth noting: they automatically produce **zero stake** when the edge estimate is statistically indistinguishable from zero, unifying the edge-detection gate and the sizing rule into one formula. Whether the project adopts that unification or keeps the gate and the sizer as separate registered components is an A1-adjacent design decision — logged to [[Open Questions]].

### 8.4 Scaling with evidence

A useful heuristic family: $c(n) = c_{\max} \cdot \frac{n}{n + n_0}$, where $n$ is the effective sample size behind the forecaster's validation and $n_0$ a registered constant — sizing confidence grows with the accrual clock. This ties the sizing layer to the project's central constraint (wall-clock accrual of city-days) and gives the V2 paper ledger a realistic shape from day one. [NEW] — proposal only, not policy.

---

## 9. Bayesian Kelly

### 9.1 The setup

Let the forecaster's uncertainty about the event probability be a posterior $\pi(q)$ (from [[Bayesian Statistics]]: Beta-Binomial calibration models, hierarchical city-level partial pooling, etc.). The Bayesian log-utility action maximizes posterior-expected growth:

$$\bar{g}(f) = \int \Big[ q \ln(1 + b f) + (1-q)\ln(1 - f) \Big], \pi(q), dq.$$

### 9.2 A precise and frequently-botched result

Because the single-bet log growth is **linear in $q$**, the integral collapses:

$$\bar{g}(f) = \bar{q},\ln(1+bf) + (1-\bar{q})\ln(1-f), \qquad \bar{q} = \mathbb{E}_\pi[q].$$

**For a single binary bet, exact Bayesian Kelly equals plug-in Kelly at the posterior mean.** Posterior _uncertainty_ (the spread of $\pi$) has zero effect on the optimal stake; only the posterior mean enters. Much folklore asserting "Bayesian uncertainty shrinks the Kelly bet" is, for this canonical case, simply false, and the vault should not repeat it. Genuine shrinkage-from-uncertainty arises only from ingredients _outside_ this setup:

1. **Nonlinear-in-$q$ payoff structure** — multi-outcome brackets, continuous payoffs, or simultaneous correlated bets, where growth is not affine in the unknown parameters.
2. **Non-Bayesian decision criteria** — worst-case/ambiguity-averse objectives (§14), or frequentist evaluation of the plug-in rule.
3. **Parameter–outcome dependence over time** — sequential settings where today's outcome updates tomorrow's posterior, so the _policy_ problem is not myopic (§9.3).
4. **The gap between the posterior mean and the estimate people actually plug in** — MLEs and raw frequencies overshoot; a proper posterior mean under a sensible prior already _is_ shrunk toward the prior (toward "no edge" if the prior is centered on the market). The practical bite of "Bayesian Kelly" is mostly this: it forces the shrinkage of §8.3(ii) to happen with a principled weight.

This distinction is exactly the kind that Invariant-3 verification exists to protect: the linearity argument is three lines of algebra (checkable in-house, no citation needed); claims that uncertainty _per se_ should reduce the single-bet stake require one of the four ingredients above and should be challenged if presented without one.

### 9.3 Sequential Bayesian Kelly

With repeated bets on the _same_ unknown $q$, outcomes carry information, and the dynamic-programming solution differs from myopic posterior-mean Kelly: there is an exploration motive (bets reveal information that improves future sizing). Browne–Whitt (★ 1996, _Advances in Applied Probability_) solve the continuous-time Bayesian Kelly problem and characterize how the optimal policy tracks the filtered estimate. For this project the exploration motive is essentially absent — outcomes arrive from the weather regardless of whether we bet (the information is free; betting is not the instrument of learning) — so **myopic posterior-mean Kelly is the correct Bayesian policy for the paper ledger**, a genuinely convenient structural fact worth recording.

### 9.4 Integration with the vault's Bayesian machinery

The pipeline shape: [[Bayesian Statistics]] produces $\pi(q \mid \text{data})$ per contract via the registered calibration model → the sizing layer consumes $\bar{q}$ (per §9.2) and, for multi-bracket or multi-city portfolios, the full joint posterior (per §9.2 ingredient 1 and §10) → fractional multiplier $c$ applied per the registered risk policy. Posterior predictive, not posterior over parameters, is the object priced: the distinction (parameter uncertainty integrated out into the predictive pmf over brackets) is the [[Bayesian Statistics]] document's territory.

---

## 10. Portfolio Kelly: Simultaneous and Correlated Bets

### 10.1 Why independent sizing fails

The project's natural trading day offers up to five city markets (each with multiple brackets) _simultaneously_. Sizing each with §4.3 independently and summing is wrong for two reasons. First, budget: fractions can sum past 1. Second, and more damaging, **correlation**: daily temperature outcomes across cities share synoptic-scale drivers (a continental heat ridge lifts several cities' highs together), so five "independent" bets can be closer to one large bet in disguise. The joint problem is

$$\max_{\mathbf{f} \ge 0,; \mathbf{1}^\top \mathbf{f} \le 1} ; \mathbb{E}\big[\ln\big(1 + \textstyle\sum_i f_i R_i\big)\big],$$

with the expectation over the **joint** outcome distribution. Log of a sum does not decompose; there is no per-market formula.

### 10.2 The quadratic/continuous approximation

For small returns, $g(\mathbf{f}) \approx \mathbf{f}^\top \boldsymbol{\mu} - \tfrac12 \mathbf{f}^\top \Sigma, \mathbf{f}$, maximized (unconstrained) at

$$\mathbf{f}^* = \Sigma^{-1} \boldsymbol{\mu},$$

the multi-asset Merton solution. Positive correlation inflates the effective variance of the aggregate position and shrinks every component; the aggregate exposure to a shared factor (the synoptic regime) is what gets budgeted, not the per-city stakes. Warnings: $\Sigma^{-1}$ is notoriously estimation-fragile (small eigenvalue errors produce wild weights); with ~150 city-days/month the sample covariance of five cities is estimable but crude, and shrinkage estimators (Ledoit–Wolf-type ⚑) or a registered one-factor structure ("common synoptic factor + idiosyncratic") are the realistic choices. The quadratic approximation also degrades for the large per-contract returns typical of low-priced brackets — treat it as an initializer for the exact solver, not the answer.

### 10.3 Discrete exact formulation for bracket portfolios

For $K$ cities each with a settled bracket, the joint outcome space is the product of the cities' bracket sets; the exact objective is a finite sum $\sum_{\omega} \Pr(\omega) \ln(1 + \mathbf{f}^\top \mathbf{R}(\omega))$ over joint scenarios $\omega$. The joint pmf comes from the Bayesian model's joint posterior predictive (§9.4) — which requires the model to _have_ a cross-city dependence structure, another item the covariance discussion above feeds. With five cities and ~6 brackets each the scenario space (~$6^5 \approx 7{,}800$) is trivially enumerable; no approximation is needed (§19.6). Whitrow (⚑ 2007, _JRSS-C_) treats algorithms for many simultaneous bets.

### 10.4 Where the fraction applies

Registered design question [NEW]: fractional Kelly for a portfolio should scale the **solution vector** ($c \cdot \mathbf{f}^*$), not the per-position formulas independently — scaling the joint optimum preserves its correlation-aware proportions. Proposal, pending ratification with the rest of the sizing rule.

---

## 11. Prediction Market Applications (Kalshi-Style)

### 11.1 Binary YES/NO markets

§4.3 is the base formula, with three market-microstructure substitutions: $r$ is the **executable** price of the side being bought (ask for entry), not the midpoint used for scoring — buying YES at ask $r_a$: $f^* = (p - r_a)/(1 - r_a)$; the effective edge is thus pre-shrunk by half the spread relative to mid-based disagreement; and the position is capped by displayed depth (§11.5). The dual-price discipline — mid (or A4's registered extraction) for _measurement_, executable side for _sizing_ — must be kept explicit in code and column names, or the two will silently contaminate each other.

### 11.2 Bracket markets

§4.5 is the machinery. Practical notes for Kalshi daily-high brackets: brackets trade as separate binary order books, so "the pmf the market quotes" must be assembled from per-bracket quotes and need not sum to one — the normalization rule is A4's (sum-to-one treatment, incomplete-coverage rule), and the sizing layer must consume A4's normalized $\mathbf{r}$, not raw quotes; the overround regime of §4.5 is the operative one (fees guarantee $S_{\text{eff}} > 1$); and correlated adjacent brackets mean an error in the model's location parameter (forecast bias of 1°F) moves probability _between neighbors_, making "long bracket $i$, short neighbor $i\pm1$" positions exquisitely sensitive to calibration of the distribution's location — a sizing-layer reason why [[Forecast Verification]]'s reliability diagnostics are decomposed by bracket distance.

### 11.3 Weather-market specifics

Settlement is the CLI Daily Climate Report value (F1 finding — the settlement source is the WFO CLI product, not raw METAR), so the model pmf must be a pmf over _CLI-settled integer values_ mapped into bracket cutlines, including the half-degree rounding behavior at boundaries (standing ⚑ flag — verify against the ticker series rules before this becomes load-bearing). Time structure matters for growth accounting: capital committed to a contract settling tomorrow at 11 AM ET (Miami/Austin delay, F3) is locked and unavailable for other same-day opportunities; growth is per unit _time_, so the opportunity cost of lockup belongs in the cost model (§12.5).

### 11.4 Fees

Kalshi charges trading fees per contract, historically of the form fee $= \lceil 0.07 \cdot C \cdot P \cdot (1-P) \rceil$ in cents for $C$ contracts at price $P$ ⚑ — **this formula, its constant, its rounding rule, and its per-series exceptions must be verified against the current Kalshi fee schedule before entering the cost model**; fee schedules change and some series have carried different constants. Structurally, a $P(1-P)$-shaped fee is heaviest near $P = 0.5$ — exactly where bracket markets concentrate — and enters the growth calculation as a deterministic reduction of the payoff on each side, shifting the breakeven edge (§12.1). The [[Expected Value]] document owns the quantified cost threshold; this document owns its effect on $f^*$.

### 11.5 Order books, depth, and partial fills

The formulas assume a fixed price for arbitrary size. Real books offer size-dependent prices: walking the book raises the average entry price with quantity, so the _marginal_ edge declines with size and the Kelly problem becomes $\max_f ; \mathbb{E}[\ln(1 + f R(f))]$ with $R$ depending on $f$ through the price-impact function. Consequences: the optimum is smaller than the fixed-price $f^_$; beyond thin top-of-book depth the effective $f^_$ is often the _depth limit itself_ (the bankroll-relative size at which marginal edge net of costs hits zero); and partial fills leave the realized position a random variable — the sizing layer should treat the displayed-depth fill as the plan and log realized fills against it. For a small bankroll in a thin weather market, **the binding constraint is usually liquidity, not Kelly** — a deflating but clarifying fact: the sizing layer's early job is mostly to _verify_ that depth-limited positions are below fractional Kelly, and to alarm when bankroll growth makes Kelly the binding constraint.

### 11.6 Contract integrality

Contracts are integer-quantity; the divisibility assumption (A1) fails at small bankrolls. Rule: round **down** (over-betting asymmetry, §8.1). At bankrolls where rounding down frequently yields zero contracts, that is information: the edge is too small relative to granularity to be worth transacting, and the correct stake is zero.

---

## 12. Trading Costs

Each friction reduces the optimal fraction; their composition is multiplicative in effect on growth and should be modeled jointly, not summed casually.

### 12.1 Commissions and fees

A deterministic cost $\kappa$ per unit staked transforms the binary problem into $g(f) = p\ln(1 + bf - \kappa f) + q\ln(1 - f - \kappa f)$ (fee paid on entry regardless of outcome; Kalshi's settlement-fee variants adjust which branch carries $\kappa$ ⚑ — encode from the verified schedule). First-order effect: the edge threshold. There is a strictly positive minimum edge below which $f^* = 0$; costs convert "any positive edge is tradeable" into "edge must exceed a threshold" — consequence 4 of [[Log Score and Kelly Identity]], now with the sizing-layer mechanism explicit.

### 12.2 Spread

Crossing the spread is a round-trip cost of (roughly) the full spread on positions held to settlement entered at market: buy at ask, settle at truth. For measurement the mid may be the registered probability extraction (A4's decision); for sizing the ask _is_ the price. In thin brackets spreads of several cents are typical ⚑ (verify against collected book data once A3's depth collection is live) — against model edges of a few points, the spread alone can consume the majority of gross disagreement. Expect the cost model to reject most nominal disagreements; that is the design working.

### 12.3 Slippage and impact

§11.5. For resting-order (maker) entries, replace impact cost with **non-execution risk**: the order fills preferentially when the market moves through it, i.e., conditional on fill the world has drifted against the model — a selection effect on fills.

### 12.4 Adverse selection

The counterparty taking the other side of a resting order may be reacting to information the model lacks (a new NWS forecast issuance, a METAR observation trend). Fills are then a _biased sample_ of intended trades: the trades that execute are disproportionately the mistaken ones. This is the microstructure phenomenon behind the maker/taker choice and it interacts with latency (§12.5). It is measurable in-house once live: compare model edge on filled vs. unfilled intended trades. [NEW] proposed diagnostic for the V2 paper ledger — paper-trade both at touch and at mid, and record the divergence.

### 12.5 Latency and staleness

Between probability computation and order arrival, the book moves. Staleness risk rises around scheduled information events — NWS forecast issuance times are public and clustered, and the market's repricing around them is presumably fast. Cost model entry: an execution-window haircut estimated from collected intraday data (A3's candlestick/book history). Additionally, capital lockup (§11.3) is an opportunity cost priced in growth-per-day units.

### 12.6 Composite effect

Let effective post-cost win/lose payoffs replace the frictionless ones in §4; recompute $f^*$ from the modified $g$. Do not apply the frictionless formula and subtract costs afterward — the optimum moves, not just the value. In code this means the sizing function's signature takes a **cost-adjusted payoff structure**, never raw prices plus a separate cost knob applied downstream.

---

## 13. Risk Management Under Kelly

### 13.1 What Kelly optimizes and what it ignores

Kelly maximizes the long-run growth rate. It does not minimize volatility, does not bound drawdowns, and does not care about the path — only the exponent. Full Kelly is, by most institutional definitions, an _aggressive_ strategy that happens to be the least aggressive strategy that is still growth-maximal. Risk management under Kelly is therefore not a modification of the criterion but a set of constraints imposed on top of it, with the growth cost of each constraint computable (that computability is a genuine advantage over ad-hoc sizing).

### 13.2 Drawdowns and the slowness of the asymptotics

The formula of §7.1 quantifies drawdown probabilities; the companion fact is _time_: expected time to double at growth rate $g^_$ is $\ln 2 / g^_$. For realistic prediction-market edges net of costs, $g^*$ per bet is small and per-year is modest, so the "long run" in which Breiman's dominance manifests is measured in years — over spans shorter than that, luck dominates and full-Kelly paths are violently dispersed. Illustrative full-Kelly facts from the standard coin-toss analyses (⚑ Ziemba's simulation studies in the anthology): even with a genuine edge, minority-but-substantial fractions of full-Kelly paths spend long stretches below the starting bankroll. Any dashboard for the V2 ledger should display growth with its dispersion cone, not a point trajectory, or it will train false confidence.

### 13.3 Ruin, technically and actually

Under the idealized assumptions, Kelly's ruin probability is zero (§2.3: log utility never stakes 100% on an uncertain outcome). Actual ruin re-enters through the assumptions' failure: integer contracts at small bankrolls (§11.6), correlated positions mis-modeled as independent (§10.1), fat-tailed model error (the model's $p$ can simply be wrong in a correlated way across many city-days — a bad forecast regime), and operational failures. The honest statement: **Kelly removes ruin from the mathematics and returns it to the model-risk budget**, which is where this project's governance (registration, verification, gap audits) already lives.

### 13.4 Psychological and institutional risk

A solo operator is the institution. The relevant literature observation (Thorp 2006 ★; MacLean–Thorp–Ziemba 2010 ★) is that even sophisticated professionals under-tolerate full-Kelly variance and abandon strategies at drawdown troughs — converting temporary paper losses into permanent realized ones. A registered fractional policy with pre-committed drawdown responses (e.g., "at 30% drawdown, halt and audit; do not resize discretionarily") converts a psychological failure mode into a governed procedure. This is the sizing-layer analog of pre-registration: the decision is made when calm, executed when not.

### 13.5 Tail risk

The Gaussian/quadratic approximations understate tail exposure when payoffs are skewed (longshot brackets) or when the true outcome distribution has structure the model misses. The exact discrete formulation (§10.3) prices in-model tails correctly by construction; _out-of-model_ tails (regime error) are handled by exposure caps — a maximum fraction of bankroll at risk per day across all cities, registered as a constant, binding regardless of what Kelly computes. Caps are crude precisely so that they are robust: they must not depend on the model whose failure they insure against.

---

## 14. Robust Kelly

### 14.1 The framework

Robust Kelly replaces the known distribution with an **ambiguity set** $\mathcal{P}$ of plausible distributions and maximizes worst-case growth:

$$\max_{\mathbf{f}} ; \min_{P \in \mathcal{P}} ; \mathbb{E}_P[\ln(1 + \mathbf{f}^\top \mathbf{R})].$$

This is the decision-theoretic expression of ambiguity aversion (Knightian uncertainty): distinct from risk (known probabilities), and _not_ obtainable from any Bayesian average (§9.2's linearity result shows Bayesian averaging over $q$ cannot shrink a single binary stake — maximin can, which is exactly why the robust family matters here).

### 14.2 Instantiations

- **Interval ambiguity**: $q \in [\underline{q}, \bar{q}]$. Worst case for a YES stake is $\underline{q}$; robust Kelly = plug-in Kelly at the lower confidence bound — recovering §8.3(iii) as exact maximin, the cleanest bridge between the frequentist confidence machinery of [[Edge Detection]] and a sizing rule.
- **Divergence balls**: $\mathcal{P} = {P : D_{\mathrm{KL}}(P | \hat{P}) \le \rho}$ or Wasserstein balls around the empirical/posterior estimate — distributionally robust optimization (DRO). Sun–Boyd (⚑ 2018, "Distributional robust Kelly gambling") give a convex formulation solvable at scale; Rujeerapaiboon–Kuhn–Wiesemann (⚑ 2016, _Management Science_, robust growth-optimal portfolios) develop the portfolio case with performance guarantees.
- **Moment ambiguity**: fix mean/covariance bands, leave the shape free — natural where $\Sigma$ is the fragile estimate (§10.2).

### 14.3 Relations and tradeoffs

A recurring finding: robust solutions behave like fractional Kelly with a data-dependent fraction — ambiguity radius plays the role of $1 - c$. The engineering choice is therefore between a _transparent_ one-knob rule (registered $c$, trivially auditable) and a _principled_ rule whose conservatism scales automatically with evidence (DRO with radius tied to sample size) at the cost of machinery and audit surface. Given this project's governance costs and the Architect's single-operator bandwidth, the staged recommendation [NEW]: registered fractional + lower-confidence-bound edge for V2; revisit DRO only if V3 is reached and position sizes make the machinery worth its audit burden.

---

## 15. Dynamic Kelly

### 15.1 Myopia under i.i.d.

With i.i.d. opportunities and log utility, the multi-period problem decomposes: bet each period as if it were the only one (Hakansson 1970 ⚑; Algoet–Cover 1988 ★ for the general stationary-ergodic statement, where the conditional distribution given the past replaces the marginal). Sequential Kelly is therefore _structurally simple_: re-estimate, re-solve, re-stake. All genuine dynamics live in the estimation layer, not the sizing layer.

### 15.2 Online learning and universal portfolios

Cover's universal portfolio (★ Cover 1991) achieves, without any statistical assumptions, the same asymptotic growth rate as the best constant-rebalanced portfolio chosen _in hindsight_, with regret $O(\log n)$ — the online-learning guarantee of the Kelly world. Conceptually important (growth-optimality is achievable adversarially, not just stochastically); practically peripheral for this project, whose opportunity set is a stream of short-horizon settling contracts rather than a rebalanced asset menu.

### 15.3 Nonstationarity

Weather-market edges are seasonal and regime-dependent (forecast skill varies by synoptic regime; market participation varies by attention). Dynamic response happens through the registered estimation model (rolling windows, hierarchical seasonal terms — [[Bayesian Statistics]]), never through discretionary resizing. Per §7.3, a _changed sizing rule is a new registered sizing rule_, scored from its registration date — the project's recalibration principle applied to capital.

### 15.4 Reinforcement learning framing

Kelly is the special case of RL where: state = bankroll (+ information set), action = stake vector, reward = $\ln(\text{growth factor})$, and the i.i.d. structure makes the greedy policy optimal (§15.1). RL earns its complexity only when actions affect future opportunities (market impact, information revelation, inventory) — mostly absent here (§9.3). The correct import from RL is not policy learning but its _evaluation_ discipline: off-policy evaluation of a sizing rule on logged paper data before promotion, which the V2 ledger enables. See [[Machine Learning]].

---

## 16. Simulation and Empirical Studies

Findings recur across the simulation literature (anthology chapters, esp. MacLean–Thorp–Zhao–Ziemba's simulation study ⚑; Ziemba's coin-toss experiments ⚑):

1. **Kelly vs. fixed stake**: proportional (Kelly-family) staking dominates fixed absolute stakes in growth and in ruin behavior; fixed stakes either become trivially small (bankroll grows) or dangerously large (bankroll shrinks).
2. **Full vs. half Kelly**: full Kelly wins median terminal wealth over long horizons; half Kelly wins on essentially every path-risk measure with modest growth sacrifice (§7.1). The literature's practitioner consensus is fractional.
3. **Martingale** (double on loss): transfers probability mass from many small wins to rare catastrophic losses; under any bankroll bound, ruin is guaranteed with positive probability per cycle and certainty asymptotically. Its persistent folk appeal is a base-rate illusion (most sessions win). Anti-martingale (press on wins) is directionally Kelly-like but uncalibrated to edge.
4. **Volatility targeting**: equalizes risk, not growth; coincides with Kelly only when edge is proportional to variance across opportunities. In edge-heterogeneous settings (this project's, where per-contract edge varies daily) it misallocates toward low-edge positions.
5. **Human behavior**: Haghani–Dewey's biased-coin experiment (⚑ 2016: subjects bet a $p=0.6$ coin with real money; a large minority went bust and most wagered erratically, despite the optimal strategy being static 20% Kelly) — evidence that even quantitatively literate humans do not improvise Kelly-like behavior, and hence that sizing must be _encoded, registered, and automated_, not left to session judgment. The specific percentages require verification before citation ⚑.

Interpret all simulation evidence with this project's standing discipline: simulations verify _internal consistency_ of the mathematics (E-grade limited), not external validity of any edge.

---

## 17. Machine Learning Applications

The ML literature meets Kelly at four points. **(1) Calibration over accuracy**: a classifier feeding a Kelly layer must be _probabilistically calibrated_; accuracy-optimized scores mis-size positions even when they rank correctly — the ML-side restatement of why [[Proper Scoring Rules and Calibration - Technical Reference (V2)]] governs model selection here. **(2) Contextual bandits**: choosing among markets each day with covariates (forecast spread, book depth) is structurally a contextual bandit with a log-wealth objective; but per §9.3 the exploration term is nearly zero because outcomes are observed regardless of betting — the project can run _pure exploitation with free full-information feedback_, a much easier regime than the bandit literature's. **(3) Online learning**: §15.2's regret guarantees; the log loss that online learning minimizes is the same log score the vault already treats as co-equal with Brier. **(4) Distributional prediction**: the sizing layer consumes full pmfs over brackets (§10.3), so the upstream model must be a distributional forecaster, not a point forecaster — aligning with the ensemble/distributional rungs planned for V2. Deep-RL position sizing exists as a research area (§22) but imports model risk this project's governance would have to pay for; there is no current justification.

---

## 18. Common Misconceptions

1. **"Kelly maximizes expected profit."** False. Expected profit is maximized by all-in staking (§5.3). Kelly maximizes the expected _logarithm_ — equivalently the almost-sure long-run growth rate, equivalently (⚑ Ethier 2004) the median of long-run wealth. On expectation, Kelly is _deliberately_ suboptimal.
2. **"Kelly eliminates risk."** False. Full Kelly has a 10% probability of a 90% drawdown (§7.1). It eliminates in-model _ruin_, which is different from risk, and only in-model (§13.3).
3. **"Kelly assumes you know the probabilities — so it's useless in practice."** Half true, wrongly concluded. The classical formula assumes known $p$ (A3); the modern literature (§8–§9, §14) is one long relaxation of that assumption, and the practical variants (posterior-mean Kelly, LCB-Kelly, fractional) are precisely tools for _not_ knowing $p$. The correct conclusion is not "useless" but "only as good as the calibration pipeline that feeds it."
4. **"Kelly is a gambling technique."** Historically inverted. It originated in information theory (§1.1) and its deepest formulation is about channels and codes (§3); gambling was the illustrative application. Its modern home is portfolio theory and sequential decision-making.
5. **"Kelly always recommends aggressive sizing."** False in both directions. At small validated edges net of realistic costs — this project's realistic regime — Kelly recommends _tiny_ fractions, and frequently zero (§12.1's threshold). When Kelly output feels aggressive, the input edge is usually overstated; the formula is a mirror, and objections to its output are usually objections to one's own probability estimate.
6. **(Bonus, from §9.2.) "Bayesian uncertainty about $p$ shrinks the Kelly stake."** For a single binary bet, false — only the posterior mean enters. Shrinkage requires nonlinearity, ambiguity aversion, or a frequentist criterion; be precise about which is being invoked.

---

## 19. Computational Engineering

### 19.1 Closed forms first, solver second

Implement §4.1–§4.5 closed forms as pure functions with exhaustive unit tests; implement the general concave solver (§19.6) separately; test each against the other on their overlap. Disagreement is a bug, and this cross-check is the cheapest strong test the sizing layer has.

### 19.2 Numerical domains

- **Probabilities**: validate $p, r \in (0,1)$ strictly; clip inputs to $[\varepsilon, 1-\varepsilon]$ (registered $\varepsilon$, e.g. $10^{-6}$) _with a logged warning_ — silent clipping hides upstream calibration bugs. This mirrors the log-score boundary discipline in [[Forecast Verification]] §9.5; the sizing layer should reuse the same registered $\varepsilon$, one constant, one place.
- **Logs**: use `log1p` for $\ln(1+x)$ near zero; compute growth comparisons in log domain throughout; never exponentiate intermediate quantities that will be logged again.
- **Money**: ledger arithmetic in `Decimal` (or integer cents), per the pipeline's existing conventions; optimization in floats; convert at the boundary with explicit rounding rules (contracts: round down, §11.6). Never mix domains within a function.
- **Floating point**: growth-rate differences of $10^{-4}$/bet are decision-relevant; accumulate log sums with care (Kahan/`math.fsum`) in long simulations.

### 19.3 Validation and guards

Every sizing call validates: pmf sums to $1 \pm$ tolerance post-A4-normalization; payoffs cost-adjusted (§12.6 signature discipline); output $f$ within $[0, c_{\max}]$ and under all registered caps; **hard assertion** that no output can exceed the exposure cap regardless of inputs — the cap check must be structurally last and unconditional.

### 19.4 Determinism and provenance

Sizing outputs enter the paper ledger with dual timestamps (event time = quotes' timestamp; ingestion time = computation time), the forecaster ID and sizing-rule version that produced them, and the exact inputs — the sizing layer inherits the pipeline's append-only, replayable discipline. A sizing decision that cannot be recomputed byte-identically from stored inputs is a provenance failure.

### 19.5 Probability-input contract

The sizing function consumes the **posterior-predictive pmf from the registered forecaster** and A4's normalized market pmf. It must be impossible to call it with raw quotes or unregistered probabilities by construction (types/wrappers, not comments).

### 19.6 Optimization

The exact discrete problem (§10.3) is a finite-scenario concave maximization: CVXPY with an exponential-cone-capable solver, or projected gradient on the simplex — both trivial at this scale (thousands of scenarios, tens of variables). Verify solver output with KKT residuals and against closed forms on degenerate cases. Avoid general-purpose unconstrained optimizers on the raw objective (domain violations at $1 + \mathbf{f}^\top\mathbf{R} \le 0$ produce NaN gradients); either encode the domain in the solver or barrier it explicitly.

---

## 20. Practical Engineering Guidelines

The sizing pipeline, in registered order [NEW — proposed architecture, pending ratification]:

1. **Gate.** Only forecasters holding a current pass from [[Edge Detection]]'s population-level machinery reach the sizing layer. No gate pass → stake ≡ 0. (V-gate: before V3, "stake" means paper-ledger stake only.)
2. **Probability.** Posterior-predictive pmf from the registered forecaster (§19.5); posterior mean where scalar $q$ suffices (§9.2).
3. **Market.** A4-normalized market pmf for measurement; executable side prices, cost-adjusted (§12.6), for sizing.
4. **Edge threshold.** Compute cost-adjusted edge; below threshold → zero (§12.1). Optionally LCB shrinkage per the registered rule (§8.3, §14.2).
5. **Joint solve.** Exact discrete portfolio Kelly across all live city/bracket opportunities (§10.3).
6. **Fraction.** Scale the solution vector by registered $c$ (§10.4); half Kelly is the literature's default prior for $c$, but the registered value is the Architect's decision.
7. **Caps.** Apply registered per-contract, per-city, per-day exposure caps; caps bind unconditionally (§13.5, §19.3).
8. **Granularity.** Convert to integer contracts, round down; log the rounding residual (§11.6).
9. **Ledger.** Write the full decision record append-only with dual timestamps (§19.4).

Standing rules proposed alongside: the sizing rule (fraction, thresholds, caps, shrinkage) is **registered before first use and versioned like a forecaster** — changes create a new rule scored from its own registration date (§7.3, §15.3); drawdown responses are pre-committed (§13.4); a kill switch halts sizing on gap-audit failures or reconciliation errors upstream (a sizing decision computed from a pipeline in a failed-audit state is invalid by construction); and the paper ledger runs both at-touch and at-mid variants to measure execution costs empirically (§12.4) before any V3 conversation.

---

## 21. Connections to Other Research Lab Documents

- **[[Log Score and Kelly Identity]]** — the canonical vault statement of the growth ⟷ log-score identity; this document extends it to sizing, portfolios, and costs and defers to it on the identity itself.
- **[[Probability]]** — supplies the measure-theoretic and distributional foundations; §3's entropy/KL machinery is defined there.
- **[[Bayesian Statistics]]** — produces the posterior (predictive) pmfs the sizing layer consumes (§9.4); the posterior-mean result (§9.2) and the joint cross-city predictive (§10.3) are its direct interfaces.
- **[[Expected Value]]** — owns the cost-threshold quantification (Kalshi fees, spreads) that §12 consumes; EV answers _whether_, Kelly answers _how much_.
- **[[Proper Scoring Rules and Calibration - Technical Reference (V2)]]** — calibration is the input-quality contract of the sizing layer; miscalibration is paid linearly in growth (§4.3).
- **[[Forecast Verification]]** — the machinery that earns a forecaster its gate pass; shares the boundary-$\varepsilon$ convention (§19.2).
- **[[Edge Detection]]** — the gate itself (§20 step 1); disagreement Δ becomes a Kelly input only after its population-level validation, and the sizing layer must be structurally unable to bypass this.
- **[[Prediction Markets]]** — institutional and efficiency context, favorite-longshot bias (whose direction — longshots overpriced, favorites underpriced — implies the _favorite side_ is where residual edge is more plausible, and interacts with the fee shape of §11.4).
- **[[Kalshi Ticker Anatomy and Market Structure]]** — bracket structure, settlement mechanics (F1/F3), and ticker conventions underlying §11.
- **[[Effective Sample Size]]** — the honest $n$ behind every calibration estimate feeding §8's uncertainty and §8.4's evidence-scaled fraction.
- **[[Machine Learning]]** — calibration-first modeling, online learning, bandit framing (§17).
- **[[Open Questions]]** — receives: the gate/sizer unification question (§8.3); executable-price question (existing OQ2); half-degree rounding ⚑ (§11.3); fee-schedule verification (§11.4).

---

## 22. Current Research Frontiers

- **Distributionally robust Kelly.** Convex DRO formulations (Wasserstein/f-divergence balls) with finite-sample growth guarantees; the open engineering question is principled radius selection tied to sample size and to the multiple-testing structure of the edge search (a connection to A1's FDR machinery that appears unexplored in the literature — a genuine, if small, research opportunity for this lab).
- **Drawdown-constrained growth.** Risk-constrained Kelly (⚑ Busseti–Ryu–Boyd 2016) maximizes growth subject to explicit drawdown-probability constraints via convex reformulation — the most direct formalization of §13's "caps on top of Kelly," and the first candidate if the project ever replaces crude caps with optimized ones.
- **Bayesian-sequential and filtering approaches.** Continuous-time filtering extensions of Browne–Whitt; interaction of learning and betting when information is _not_ free — inapplicable here (§9.3) but the boundary is worth knowing.
- **Deep RL for allocation.** Active but, for auditable single-operator systems, currently a model-risk importer without offsetting benefit; watch, don't adopt.
- **Growth-optimal market making.** Kelly-style inventory and quoting for the _maker_ side; relevant only if the project ever quotes rather than takes — far beyond V3.
- **Evolutionary/relative-wealth dynamics.** Log-optimal strategies as evolutionarily dominant in market-selection models (⚑ Lo–Orr–Zhang 2018 and the market-selection literature) — a theoretical explanation for why prices might tend toward calibration, connecting to [[Prediction Markets]]' efficiency discussion.
- **Unresolved in general**: sizing under _misspecified_ (not merely uncertain) models — the gap between §8's in-model uncertainty and reality's out-of-model error remains where practice leans on the blunt instrument of fractional Kelly.

## 23. Engineering Takeaways (proposed directives)

- **D-KC-1.** Kelly is the last pipeline stage. No stake computation for any forecaster without a current [[Edge Detection]] gate pass; structural enforcement, not procedural. [NEW]
- **D-KC-2.** Never full Kelly. The registered fraction $c$ and all caps are set by ADR before first paper use; half Kelly is the literature default, the choice is the Architect's. [NEW]
- **D-KC-3.** Over-betting is the catastrophic direction (double Kelly = zero growth). All rounding, clipping, and tie-breaking resolves downward. [NEW]
- **D-KC-4.** Cost-adjust payoffs _before_ optimizing (§12.6); never size on frictionless formulas with costs subtracted afterward. [NEW]
- **D-KC-5.** Size jointly across simultaneous correlated city-days (§10); independent per-market sizing is prohibited once more than one market is live per day. [NEW]
- **D-KC-6.** For single binary stakes, the Bayesian input is the posterior mean; claims that posterior _spread_ should shrink a binary stake must name their mechanism (§9.2). [NEW]
- **D-KC-7.** The sizing rule is a registered, versioned artifact; any change is a new rule scored from its registration date. [NEW]
- **D-KC-8.** Exposure caps bind last and unconditionally, independent of every model (§13.5, §19.3). [NEW]
- **D-KC-9.** Paper ledger before real ledger (V-gate); at-touch and at-mid parallel paper books to measure execution drag empirically (§12.4). [NEW]
- **D-KC-10.** Sizing decisions are replayable: stored inputs + stored rule version ⟹ byte-identical output (§19.4). [NEW]
- **Failure modes to expect**: overstated edge from calibration-sample reuse (the gate exists for this); spread and fees consuming nominal disagreement (§12.2 — most Δ should die at step 4); covariance fragility (§10.2); silent probability clipping masking upstream bugs (§19.2); liquidity, not Kelly, binding at small bankrolls (§11.5) — verify which constraint binds and log it.

## 24. Annotated Bibliography

Ranked within tiers. ★ = priority verification tier (feeds A-series or directive-level claims). ⚑ = lower-confidence metadata or effect sizes; verify before any load-bearing use. Per Invariant 3, **every** entry is E4 until the Architect confirms it against the primary source.

### Tier 1 — Essential reading (foundations)

1. ★ Kelly, J. L., Jr. (1956). "A New Interpretation of Information Rate." _Bell System Technical Journal_ 35(4), 917–926. The origin: growth rate = information rate; side information worth its mutual information. Short, readable, still the best single source.
2. ★ Breiman, L. (1961). "Optimal Gambling Systems for Favorable Games." _Proc. Fourth Berkeley Symposium on Mathematical Statistics and Probability_, Vol. 1. The asymptotic optimality theorems (§2.4). The mathematical spine.
3. ★ Cover, T. M., and J. A. Thomas (2006). _Elements of Information Theory_, 2nd ed. Wiley. Ch. 6 (gambling and side information) and Ch. 16 (log-optimal portfolios, universal portfolios). The standard rigorous textbook treatment; already cited by [[Forecast Verification]].
4. ★ Thorp, E. O. (2006). "The Kelly Criterion in Blackjack, Sports Betting, and the Stock Market." In _Handbook of Asset and Liability Management_, Vol. 1 (Zenios & Ziemba, eds.). North-Holland. The definitive practitioner synthesis: fractional Kelly, drawdown formulas (§7.1), estimation-error warnings. If one reference guides implementation, this one.
5. ★ MacLean, L. C., E. O. Thorp, and W. T. Ziemba, eds. (2011). _The Kelly Capital Growth Investment Criterion: Theory and Practice_. World Scientific. The anthology; contains or reprints most of this bibliography.

### Tier 2 — The debate and the growth–security tradeoff

6. ★ Samuelson, P. A. (1971). "The 'Fallacy' of Maximizing the Geometric Mean in Long Sequences of Investing or Gambling." _PNAS_ 68(10). The correct critique of normative overreach (§1.4, §6.2).
7. Samuelson, P. A. (1979). "Why We Should Not Make Mean Log of Wealth Big Though Years to Act Are Long." _Journal of Banking & Finance_ 3. The one-syllable reprise.
8. ★ MacLean, L. C., W. T. Ziemba, and G. Blazenko (1992). "Growth Versus Security in Dynamic Investment Analysis." _Management Science_ 38(11). The fractional-Kelly efficient frontier (§7.2).
9. ★ MacLean, L. C., E. O. Thorp, and W. T. Ziemba (2010). "Long-Term Capital Growth: The Good and Bad Properties of the Kelly and Fractional Kelly Capital Growth Criteria." _Quantitative Finance_ 10(7) ⚑ (venue/volume to confirm). The balanced modern summary.
10. ⚑ Latané, H. A. (1959). "Criteria for Choice Among Risky Ventures." _Journal of Political Economy_ 67. The independent economics lineage.
11. ⚑ Hakansson, N. H. (1970). "Optimal Investment and Consumption Strategies Under Risk for a Class of Utility Functions." _Econometrica_ 38. Myopia results (§15.1).

### Tier 3 — Theory extensions

12. ★ Algoet, P. H., and T. M. Cover (1988). "Asymptotic Optimality and Asymptotic Equipartition Properties of Log-Optimum Investment." _Annals of Probability_ 16(2). Stationary-ergodic generalization.
13. ⚑ Bell, R. M., and T. M. Cover (1980). "Competitive Optimality of Logarithmic Investment." _Mathematics of Operations Research_ 5(2). One-shot game optimality (§2.4.3).
14. ★ Cover, T. M. (1991). "Universal Portfolios." _Mathematical Finance_ 1(1). Adversarial growth-optimality (§15.2).
15. ⚑ Finkelstein, M., and R. Whitley (1981). "Optimal Strategies for Repeated Games." _Advances in Applied Probability_ 13. Breiman extensions.
16. ⚑ Ethier, S. N. (2004). "The Kelly System Maximizes Median Fortune." _Journal of Applied Probability_ 41. Median-optimality (§18.1).
17. ★ Merton, R. C. (1969). "Lifetime Portfolio Selection Under Uncertainty: The Continuous-Time Case." _Review of Economics and Statistics_ 51. The $\mu/(\gamma\sigma^2)$ fraction; Kelly as $\gamma = 1$ (§6.1).

### Tier 4 — Uncertainty, Bayesian, robust

18. ★ Browne, S., and W. Whitt (1996). "Portfolio Choice and the Bayesian Kelly Criterion." _Advances in Applied Probability_ 28(4). The sequential Bayesian solution (§9.3).
19. ⚑ Baker, R. D., and I. G. McHale (2013). "Optimal Betting Under Parameter Uncertainty: Improving the Kelly Criterion." _Decision Analysis_ 10(3). Shrinkage under estimation error (§8.3).
20. ⚑ Sun, Q., and S. Boyd (2018). "Distributional Robust Kelly Gambling." arXiv:1812.10371. Convex DRO-Kelly (§14.2).
21. ⚑ Rujeerapaiboon, N., D. Kuhn, and W. Wiesemann (2016). "Robust Growth-Optimal Portfolios." _Management Science_ 62(7). Portfolio DRO with guarantees.
22. ⚑ Busseti, E., E. K. Ryu, and S. Boyd (2016). "Risk-Constrained Kelly Gambling." _Journal of Investing_ 25(3). Drawdown-constrained convex formulation (§22).

### Tier 5 — Applications, markets, behavior

23. ⚑ Whitrow, C. (2007). "Algorithms for Optimal Allocation of Bets on Many Simultaneous Events." _JRSS Series C_ 56(5). Simultaneous-bet computation (§10.3).
24. ⚑ Smoczynski, P., and D. Tomkins (2010). "An Explicit Solution to the Problem of Optimizing the Allocations of a Bettor's Wealth When Wagering on Horse Races." _Mathematical Scientist_ 35. Water-filling closed form (§4.5).
25. ⚑ Haghani, V., and R. Dewey (2016). "Rational Decision-Making Under Uncertainty: Observed Betting Patterns on a Biased Coin." SSRN/_Journal of Portfolio Management_ ⚑. The behavioral case for automation (§16.5); all percentages need primary-source confirmation.
26. Thorp, E. O. (1962). _Beat the Dealer_. Random House. Historical; Kelly in first sustained practice.
27. ⚑ Thorp, E. O. (1971). "Portfolio Choice and the Kelly Criterion." _Business and Economics Statistics Section, Proc. American Statistical Association_. Early securities application.
28. ⚑ Rotando, L. M., and E. O. Thorp (1992). "The Kelly Criterion and the Stock Market." _American Mathematical Monthly_ 99(10). Pedagogical equities treatment.
29. Poundstone, W. (2005). _Fortune's Formula_. Hill and Wang. History and narrative only; never a citation source for numbers.
30. ⚑ Thaler, R. H., and W. T. Ziemba (1988). "Anomalies: Parimutuel Betting Markets: Racetracks and Lotteries." _Journal of Economic Perspectives_ 2(2). Favorite-longshot bias (direction: longshots overpriced), feeding [[Prediction Markets]].
31. ⚑ Lo, A. W., H. A. Orr, and R. Zhang (2018). "The Growth of Relative Wealth and the Kelly Criterion." _Journal of Bioeconomics_ 20. Evolutionary framing (§22).

**Essential-reading shortlist** (if the Architect verifies only five): Kelly 1956; Breiman 1961; Cover–Thomas ch. 6; Thorp 2006; MacLean–Ziemba–Blazenko 1992.

---

## Maintenance

**Update triggers.** (i) Verification of any ⚑ entry — replace flag with E-grade and date. (ii) **Kalshi fee schedule verification** (§11.4) — highest-priority ⚑ in this document; the cost model cannot be built without it; coordinate with [[Expected Value]]. (iii) Ratification of A4 — reconcile §11.1–§11.2's price-extraction and normalization references with A4's registered rules. (iv) Ratification of A1 — reconcile §8.3's gate/sizer unification question and any LCB-based rule with A1's inference framework. (v) Ratification of any sizing-rule ADR — §20's pipeline and §23's D-KC directives convert from proposal to policy (or are amended). (vi) A3 depth-collection going live — replace §12.2's spread expectations with measured values. (vii) V2 paper-ledger first run — add a worked example appendix from real (paper) decisions.

**Deprecation rules.** Where this synthesis and any ratified A-series document or ADR disagree, the ratified document governs; this is literature context, never a registration source. The empty stub this document replaces should be deleted, not archived (single-source rule). The [NEW]-flagged items (§8.4, §10.4, §12.4 diagnostic, §14.3 staging, §20 pipeline, all D-KC directives) are proposals pending Architect ratification, not standing policy.

**Verification queue.** ★ tier first (n = 13); then the two decision-fragile ⚑ clusters — the Kalshi fee formula (§11.4) and the Haghani–Dewey percentages (§16.5) if ever cited; then remaining ⚑ entries lazily on first use. The half-degree rounding flag (§11.3) is owned by the existing vault-wide ⚑, not duplicated here.

**Internal-check ledger (no citation needed — verifiable in-house).** The §9.2 linearity result (three lines of algebra); the §5.2 parabola facts ($g(2f^_) = 0$); the §7.1 growth identity $g(cf^_) = c(2-c)g^*$; the §4.3 boxed formulas; the §3.3 KL identity (already derived in [[Log Score and Kelly Identity]]). These can be graded on mathematical verification alone, independent of the bibliography.