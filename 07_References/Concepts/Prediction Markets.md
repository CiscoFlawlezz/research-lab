---
type: reference
status: seed
created: 2026-07-07
---
---

## type: reference status: draft — pending human verification (Invariant 3) version: 2.0 supersedes: seed note of 2026-07-07 created: 2026-07-08 tags: [prediction-markets, reference, canonical-candidate]

# Prediction Markets

> [!warning] Epistemic status Claude-drafted research synthesis. **Every factual and quantitative claim in this document is testimony, graded E4, until independently verified** ([[Research Methodology v2]], Invariant 3). Claims transcribed from abstracts or secondary sources rather than primary tables carry an explicit ⚑ verification flag. This version supersedes the v1 seed note; the disposition of v1 material is recorded in [[#Changes from v1]].

---

## Definition

A **prediction market** (event market, information market, idea futures) is a market in contracts whose payoffs are tied to the outcome of an observable future event. The canonical instrument is the **binary (Arrow–Debreu / winner-take-all) contract**: it pays a fixed amount (normalize to $1) if event $Y = 1$ occurs and $0 otherwise. Other contract families exist — index contracts paying proportionally to a continuous outcome (whose price estimates the mean), and spread contracts (whose price estimates a quantile) (Wolfers & Zitzewitz, 2004) — but binary contracts dominate modern venues, including all Kalshi weather markets.

For a binary contract trading at price $q \in (0,1)$, the naive reading is

$$q \approx \mathbb{P}(Y = 1 \mid \mathcal{F}_t)$$

— the market's probability given public information at time $t$. This reading is a **useful approximation, not an identity**. It requires qualification on at least four grounds, each treated below:

1. **Aggregation theory.** With heterogeneous beliefs, the equilibrium price is not in general the mean trader belief (Manski, 2006); Wolfers & Zitzewitz (2006) give conditions (approximately log-utility traders, belief dispersion not too extreme) under which price ≈ mean belief holds well.
2. **Microstructure.** There is no single "price": there is a bid, an ask, a last trade (possibly stale), and a depth profile. Which functional of the book counts as "the market's forecast" is a modeling decision that must be fixed before scoring ([[Open Questions]] Q2).
3. **Fees and frictions** shift where quotes sit relative to beliefs (see [[#Practical Constraints]]).
4. **Risk preferences and probability weighting** produce systematic price–probability gaps, most prominently the favorite–longshot bias (see [[#Behavioral Biases]]).

**Terminology for this vault:** "market-implied probability" always means the output of the project's fixed extraction rule applied to the order book at a defined ingestion-time cutoff — never a casual synonym for truth.

---

## Historical Development

- **Pre-modern era.** Organized election betting is old and was once enormous: Rhode & Strumpf (2004) document large, liquid presidential betting markets on Wall Street from roughly 1868–1940, with volumes at times exceeding trading in stocks and with strong forecasting records — evidence that market-based election forecasting predates both polling and the modern literature.
- **1988 — Iowa Electronic Markets (IEM).** University of Iowa's real-money academic markets on elections and economic outcomes; the field's foundational dataset (Berg, Forsythe, Nelson & Rietz, 2008; Berg, Nelson & Rietz, 2008 on long-run forecast comparisons).
- **1990s–2000s — theory and corporate experiments.** Hanson develops "idea futures" and the Logarithmic Market Scoring Rule (LMSR) (Hanson, 2003, 2007). Corporate internal markets run at HP, Google, Ford and others (Cowgill & Zitzewitz, 2015). DARPA's Policy Analysis Market (2003) is cancelled under political pressure — an early lesson that prediction market viability is partly political, not purely technical.
- **2000s–2010s — public venues.** Intrade (until 2013), Betfair political markets, PredictIt (2014, academic no-action-letter model). Arrow et al. (2008, _Science_) — a multi-author statement urging regulatory accommodation of prediction markets.
- **2018–2024 — regulated exchange era.** Kalshi founded 2018; CFTC designation as a Designated Contract Market (DCM) approved November 2020; first contracts 2021. Polymarket launches 2020 on crypto rails; blocked from US users in 2022 after a CFTC settlement; re-enters the US via acquisition of a licensed exchange (2025). Kalshi's 2024 federal court victory over the CFTC permits US election contracts for the first time in the modern regulated era.
- **2024–2026 — scale and scrutiny.** Volumes explode: Kalshi reports tens of billions of dollars in annual event-contract volume by 2025–26, with **sports contracts constituting the overwhelming majority (~85–90%) of Kalshi volume** ⚑ — weather is a small corner of the venue. Institutional capital enters (ICE investment in Polymarket). Simultaneously: state gaming regulators litigate against event contracts, Congress debates restrictions, and the CFTC brings its first insider-trading enforcement in event contracts (2026). ⚑ All figures in this bullet are from news/CRS secondary sources, 2026 vintage; verify before quantitative use.

**Project-relevant reading of this history:** (a) the regulated-venue era is very young — most of the academic literature predates Kalshi-scale venues, so external validity of older findings is a live question; (b) **regulatory risk is a pipeline-continuity risk**: contract categories have been created and destroyed by litigation and rulemaking within single years. The append-only archive is partly insurance against the venue itself changing.

---

## Economic Foundations

Four theoretical results form the load-bearing frame. Everything empirical in this document sits on top of them.

**1. Hayek (1945) — the knowledge problem.** Relevant knowledge is dispersed, local, and tacit; the price system is a mechanism for aggregating it without central collection. Prediction markets are the deliberate engineering of this mechanism for probabilities: they exist to pay people to reveal what they privately know.

**2. Muth (1961) / rational expectations.** Agents' expectations are model-consistent: on average, equilibrium prices embed the relevant theory and information. This supplies the null hypothesis the project's instrument tests: $P_m = \mathbb{P}(Y\mid\mathcal{F}_t)$.

**3. Milgrom & Stokey (1982) — the no-trade theorem.** With common priors, common knowledge of rationality, and purely speculative motives, the arrival of private information generates _no trade_: my willingness to trade tells you I know something, and you rationally refuse. Real prediction markets trade constantly; therefore at least one assumption fails in practice — traders have heterogeneous priors, hedging motives, entertainment motives, or bounded rationality. **The existence of volume is itself evidence of the noise that makes edge possible.**

**4. Grossman & Stiglitz (1980) — the impossibility of informationally efficient markets.** If prices perfectly reflected all information, no one would pay the cost of acquiring information, so prices could not come to reflect it. Equilibrium therefore involves _residual inefficiency exactly sufficient to compensate marginal information acquisition_. This is the single most important theoretical result for the Lab's mission: "the market is efficient" and "informed participants earn returns on their information costs" are not contradictory claims — the second is what sustains the first. The project's question is thus well-posed: _is the equilibrium compensation for information in Kalshi weather markets accessible to an NWS-derived model after costs?_ Nothing in efficiency theory answers that a priori.

---

## Information Aggregation Theory

**Experimental foundations.** Plott & Sunder (1982, 1988) established in laboratory asset markets that prices can aggregate insider information and, under some conditions, aggregate _dispersed_ information no single trader holds — but aggregation fails when contract structure is poor or information is too diffuse. Aggregation is an achievement of _design_, not an automatic property of trading.

**Theoretical conditions.** Ostrovsky (2012) shows that with strategic traders, information gets fully aggregated for "separable" securities (binary Arrow–Debreu contracts qualify) but can fail otherwise. Practical conditions supported across the literature:

- **Diversity** of information sources across traders (correlated beliefs shrink effective crowd size);
- **Incentive alignment** — participants profit by moving the price toward truth;
- **Liquidity** sufficient to express information at acceptable cost;
- **Contract clarity** — unambiguous, verifiable resolution criteria.

**The price-interpretation debate.** Manski (2006) demonstrated that with risk-neutral traders holding heterogeneous beliefs, the equilibrium price identifies only a _bound_ on the belief distribution, not its mean; a price of 0.60 is consistent with mean beliefs anywhere in a wide interval. Wolfers & Zitzewitz (2006) replied that with log utility (or empirically plausible belief dispersion), price approximates mean belief closely. **Working position for this vault:** treat $P_m$ as an excellent but imperfect probability report whose error structure is an empirical object — which is precisely what the V1 instrument measures. Neither side of the debate is resolved by argument; it is resolved by calibration data, market by market.

**Markets as sequential Bayesian aggregators.** A stylized model: traders arrive with private signals; each trade moves the price toward the trader's posterior; the price path approximates a sequence of Bayesian updates on the union of revealed information. This ideal is degraded by strategic timing (informed traders conceal), bounded liquidity, and noise trading — hence _partial_ aggregation is the realistic expectation.

---

## Efficient Market Hypothesis

Fama (1970): **weak** (prices reflect price history), **semi-strong** (all public information), **strong** (all information including private) form efficiency. For a binary market, semi-strong efficiency states

$$P_m(t) = \mathbb{P}(Y = 1 \mid \mathcal{F}_t^{\text{public}})$$

Under this null, no model built on public inputs — and NWS forecasts are public — can systematically outperform the price; every model–market divergence $\Delta$ is model error.

**Why prediction markets are a favorable habitat for efficiency:** binary payoffs, terminal resolution against verifiable facts, no discounted-cash-flow ambiguity, short horizons. **Why they fall short:** thin liquidity in most contracts, retail-heavy participation, fees and position frictions, absence of cross-sectional arbitrage capital. The empirical record matches the split:

- **Good first-order aggregate calibration** across venues and decades (IEM corpus; Wolfers & Zitzewitz, 2004); on Kalshi, prices are informative and accuracy improves toward close (Bürgi, Deng & Whelan, 2025 ⚑).
- **Robust local deviations**, chiefly the favorite–longshot bias — present in Kalshi's pooled data _despite uncapped volume_ (Bürgi, Deng & Whelan, 2025 ⚑), refuting "scale fixes it."
- **Horizon-dependence**: calibration is good near resolution and degrades with time-to-expiry (Page & Clemen, 2013).

**Adaptive Markets (Lo, 2004)** reframes efficiency as an ecological, time-varying property: inefficiencies are competed away and can re-emerge as the trader population changes. A framework rather than a tested theory (falsifiability criticisms are on record), but the right _frame_ for [[Open Questions]] Q6 — any edge estimated on historical data is an estimate of a **decaying quantity**.

---

## Rational Expectations

Treated briefly since the operative content appears above: rational expectations (Muth, 1961) is the microfoundation of the semi-strong null, and rational-expectations equilibrium is the benchmark against which experimental aggregation (Plott & Sunder) was tested. Two cautions matter for practice. First, RE is an equilibrium concept — it says nothing about the _path_ by which new information (e.g., a new NWS model run) is incorporated, and underreaction along that path is a theoretically motivated inefficiency (Ottaviani & Sørensen, 2015, on prices underreacting to information when traders are budget-constrained ⚑ verify exact statement/venue). Second, RE with heterogeneous priors permits persistent disagreement and volume, consistent with the no-trade escape hatches above.

---

## Market Design

Two dominant mechanisms:

**1. Continuous limit order book (CLOB / continuous double auction).** Traders post limit orders; trades occur when orders cross. Price discovery is decentralized; liquidity is endogenous and can be absent. **Kalshi is a CLOB with a maker/taker fee structure** — not an automated market maker. Consequences: bid/ask spread is a first-order cost; quotes in dead brackets can be stale or degenerate (the project's own 1a data showed live 1¢ quotes with zero volume); and _how_ one transacts (posting vs. crossing) materially changes realized returns (see [[#Price Discovery]]).

**2. Logarithmic Market Scoring Rule (LMSR) market maker (Hanson, 2003, 2007).** An always-available automated counterparty defined by cost function

$$C(\mathbf{q}) = b \ln \sum_{i} e^{q_i / b}$$

over outstanding quantities $\mathbf{q}$, with instantaneous prices given by the softmax

$$p_i = \frac{e^{q_i/b}}{\sum_j e^{q_j/b}}$$

Properties: prices are always defined (no missing liquidity), sum to one across an exhaustive partition by construction, and the sponsor's worst-case subsidy is bounded by $b \ln n$ for $n$ outcomes. The liquidity parameter $b$ trades off price responsiveness against subsidy cost. The deep property: **LMSR implements a shared sequential log score** — each trader's profit equals the improvement in the market's log score produced by their trade, making the market literally a scoring-rule elicitation device (see [[Proper Scoring Rules and Calibration - Technical Reference (V2)]]). Empirically, Atanasov, Witkowski, Mellers & Tetlock (2024) find LMSR markets produced more accurate prices than CDA markets in tournament settings ⚑.

**Design principles with project consequences:**

- **Resolution-source precision is the whole game for contract quality.** A temperature bracket is only as well-defined as its settlement source. Whether Kalshi settles daily-high contracts against the NWS CLI Daily Climate Report or a max over hourly observations is a _standing unresolved load-bearing question_ for this project (KT document) — a market-design fact, not a modeling detail.
- **Bracket ladders (exhaustive partitions) impose coherence constraints** — implied probabilities should sum to ~1 and be monotone in the underlying variable. On a CLOB nothing enforces this; deviations are data-quality instruments first and arbitrage candidates a distant second (fees usually consume them; see [[Edge Detection v4]]).
- **CLOB liquidity is endogenous**: expect the ladder's tails to be structurally thin. This interacts with FLB, which concentrates exactly there.

---

## Incentive Structures

- **Real vs. play money.** Servan-Schreiber, Wolfers, Pennock & Galebach (2004) found real-money and play-money markets comparably accurate for NFL forecasting ⚑ — status and score-keeping can substitute for cash at the margin. Real money still matters for attracting _costly_ information acquisition (Grossman–Stiglitz logic).
- **Subsidy.** An LMSR sponsor or a fee rebate to makers is a subsidy that pays for information revelation. Kalshi's maker/taker asymmetry implicitly subsidizes quote provision.
- **Tournament vs. linear incentives.** Rank-based rewards distort reporting (chasing variance to climb rankings); linear scoring-rule payoffs elicit honest means. Tournament distortion is one proposed mechanism for extreme-price anomalies.
- **Manipulation incentives** — treated under [[#Known Market Failures]].
- **For this project:** the Lab is a _price-taker observer_ in V1; incentive design matters mainly as a lens on why counterparties are present at all in a weather market (entertainment, hedging is implausible at retail scale, cross-market speculation) — the composition of the counterparty population is the mechanism behind any measured miscalibration.

---

## Liquidity

Liquidity is the recurring conditioning variable across the empirical literature: it moderates calibration quality, information incorporation speed, and manipulation resistance.

Operational quantities:

$$\text{Spread} = P_{ask} - P_{bid}, \qquad \text{Depth}(p) = \text{resting size at or better than } p, \qquad \text{Impact} \approx \frac{\Delta P}{\text{trade size}}$$

Empirical regularities (each ⚑ pending primary verification):

- Thin markets show wider spreads, slower information incorporation, and larger deviations from coherent pricing (Tetlock, 2008, on liquidity and pricing in event markets).
- **Staleness**: in inactive brackets, "last price" is not a forecast at all; only live quotes carry information, and even they can be degenerate placeholders. Observed directly in this project's 1a data ([[Open Questions]] Q7).
- Calibration studies that fail to filter or model illiquidity conflate market error with measurement error.

**Project consequences:** (a) the market-forecast extraction rule (Q2) is inseparable from a liquidity filter; (b) any eventual cost model needs _executable-depth_ prices, not touch prices; (c) per-bracket liquidity metadata is collection-scope — if not captured at ingestion time it is unrecoverable, the same accrual-urgency logic as forecast issuance history.

---

## Price Discovery

Microstructure theory explains _how_ information enters prices and _who pays for it_:

- **Glosten & Milgrom (1985):** market makers widen spreads to cover expected losses to better-informed counterparties. The spread is an adverse-selection tax; posting limit orders means being filled disproportionately when the counterparty is right (see also Sandås, 2001).
- **Kyle (1985):** informed traders trade gradually against noise flow; price impact ("Kyle's lambda") measures the market's inference from order flow.
- **Kalshi evidence:** Bürgi, Deng & Whelan (2025) document a large gap in average realized returns between **Takers** (cross the spread) and **Makers** (post quotes), with Takers faring far worse and the favorite–longshot pattern much stronger on the Taker side. ⚑ Effect sizes transcribed from abstract/summaries, not tables; paper exists in ≥2 vintages (CESifo/UCD WP2025_19; GWU WP 2026-001) — verify against a specific version.

**Bounded implication (do not over-read):** the maker/taker gap shows execution posture is first-order _for the average participant_. It does **not** establish that passive execution dominates for an informed, model-driven trader — passive quotes bear their own adverse-selection cost precisely when the model is right and fast counterparties are too. Which posture dominates is an open empirical question for the V3 execution-cost model ([[Edge Detection v4]] carries the full argument).

---

## Calibration

A forecaster (or market) is **calibrated** if, among all events assigned probability $p$, the long-run frequency of occurrence is $p$:

$$\mathbb{E}[Y \mid P_m = p] = p \quad \text{for all } p$$

Calibration is assessed with reliability diagrams (binned $\bar{o}_k$ vs $\bar{p}_k$) and summarized (imperfectly) by expected calibration error; both carry serious finite-sample and binning caveats treated in [[Proper Scoring Rules and Calibration - Technical Reference (V2)]] — bin frequencies carry binomial noise $\sqrt{p(1-p)/n_k}$, and reliability-curve _shape_ is not signal until hundreds of forecasts accrue.

**What the literature finds for prediction markets:**

- **First-order calibration is good**, especially near resolution (IEM corpus; Wolfers & Zitzewitz, 2004).
- **Second-order deviations are systematic**: the favorite–longshot bias (longshots overpriced ⇒ **contracts priced at 5–10¢ resolve YES _less_ often than 5–10%**; favorites underpriced ⇒ high-priced contracts resolve YES _more_ often than their price). Direction matters — the v1 seed note stated it backwards in its worked example, which is exactly the kind of error a correction model would inherit.
- **Horizon effect**: Page & Clemen (2013) find calibration good at short horizons and deteriorating with time-to-resolution (longshot-overpricing worsens with horizon). Note the estimation domain: nothing in that study is as short-dated as a daily temperature bracket — extrapolation to this project's markets is a hypothesis, not a finding.
- **Calibration alone is cheap**: Foster & Vohra (1998) show asymptotic calibration is achievable by randomized forecasting with _no knowledge whatsoever_. Calibration is necessary, not sufficient; **resolution** (in the Murphy-decomposition sense) is where information lives.

**Grey literature on Kalshi weather calibration (E4, non-peer-reviewed, methodology unaudited):** several third-party analyses of settled Kalshi weather markets now exist, including one covering 8,494 settled NYC daily-high (KXHIGHNY) markets reporting raw ECE ≈ 0.016, reduced ~15× by isotonic recalibration, and various dashboard-style calibration charts on the full weather-market corpus. Treat strictly as _priors and competition intelligence_ for Experiment #1 — extraction rules, liquidity filters, and dependence handling are unverified, and several publishers sell trading tools (incentive to overstate exploitability). Their existence is itself a finding: **the naive-recalibration edge, if it exists, is already being marketed** — relevant to Q6 (efficiency improving over time).

---

## Proper Scoring Rules

Full treatment lives in [[Proper Scoring Rules and Calibration - Technical Reference (V2)]]; this section records only what a prediction-market reference needs.

A scoring rule $S(p, y)$ is **strictly proper** if honest reporting of one's true probability uniquely maximizes expected score (Gneiting & Raftery, 2007). The two workhorses:

$$\text{Brier: } BS = \frac{1}{N}\sum_{i=1}^{N}(p_i - y_i)^2 \qquad \text{Log: } LS = -\frac{1}{N}\sum_{i=1}^{N}\big[y_i \ln p_i + (1-y_i)\ln(1-p_i)\big]$$

Three market connections:

1. **Prices are forecasts.** A defined market-price functional is scoreable exactly like a model; "market calibration" is a measurable property, not an assumption.
2. **LMSR is a scoring rule** (see [[#Market Design]]) — trading profit against an LMSR equals log-score improvement.
3. **The Kelly–log-score identity** ([[Log Score and Kelly Identity — Technical Reference (V2)]]): expected log-growth of Kelly betting against market odds equals the forecaster's log-score advantage over the market. **Score-edge vs. the market rung is the precise statistical meaning of "edge"** — necessary for profit; sufficient only after fees and executable spreads.

Never validate a probability with a single outcome; probabilities validate only at population level ([[Research Methodology v2]]).

---

## Relationship to Bayesian Updating

The idealized market is a distributed Bayesian engine: the price approximates $\mathbb{P}(Y \mid I_1 \cup \dots \cup I_n)$ over traders' information sets, updated sequentially as trades reveal signals. Three precise senses in which this holds, and their limits:

- **Mechanism-level:** against an LMSR, a rational trader moves the price exactly to their posterior — a literal Bayesian update executed as a trade. On a CLOB the correspondence is looser (spread, depth, strategic timing).
- **Equilibrium-level:** under Wolfers–Zitzewitz conditions the price approximates the belief-distribution mean, which is a Bayesian pooling of trader posteriors under specific utility assumptions — not a guarantee (Manski's bound stands otherwise).
- **Dynamic-level:** the price _path_ should look like a martingale with respect to public information if updating is correct; systematic drift after identifiable information events (e.g., a new NWS model run) is underreaction and a candidate inefficiency ([[Edge Detection v4]], Q5).

For this project, the market rung of the reference ladder is best understood as "somebody else's posterior, aggregated" — the strongest available benchmark precisely because it may already contain the NWS information the model rung uses. The model–market error correlation ρ is therefore a first-class quantity (it drives the power analysis in A1).

---

## Forecast Accuracy

**The market-vs-polls question is contested, and the resolution is methodological.** Key evidence:

- **IEM corpus:** market forecasts frequently beat contemporaneous polls, especially near elections (Berg et al., 2008). Counterpoint: Erikson & Wlezien (2008) show that _properly projected_ polls (translating today's poll into an election-day forecast) beat raw market prices — the market's advantage partly reflected naive use of polls as forecasts.
- **Randomized tournament evidence:** Atanasov et al. (2017, Management Science; IARPA ACE, 2,400+ forecasters, 261 questions): market prices beat the **simple mean** of prediction polls in both seasons, but **team-based polls beat the market once statistically aggregated** (temporal decay, performance weighting, recalibration/extremizing). Follow-up (Atanasov, Witkowski, Mellers & Tetlock, 2024): small elite crowds beat large ones; markets and engineered polls statistically tied; LMSR beat CDA. Related: sophisticated polls outperform markets at **long horizons** (Dana, Atanasov, Tetlock & Mellers, 2019 ⚑).
- **Synthesis:** markets reliably beat _naive_ aggregation and lose to (or tie) _well-engineered_ aggregation. The correct comparison is always market vs. a specific well-built alternative — never market vs. strawman.

**Project translation:** the relevant contest is _Kalshi weather prices vs. an NWS-derived probabilistic model_ — i.e., market vs. an engineered aggregate of exactly the kind that has historically been competitive. The literature licenses the hypothesis; it does not license the expectation of a large edge, because the market can read the NWS too.

---

## Empirical Evidence

Domain-by-domain summary. Grades are this document's read of literature strength, all E4 pending verification:

|Domain|Headline result|Strength|Key sources|
|---|---|---|---|
|Elections|Competitive with/better than naive polls; late-stage accuracy strong; horizon effects|High|Berg et al. 2008; Rhode & Strumpf 2004; Erikson & Wlezien 2008|
|Geopolitical tournaments|Markets ≈ engineered polls; beat naive aggregates|High (randomized)|Atanasov et al. 2017, 2024|
|Sports/wagering|Well-studied; strong aggregate efficiency **with** robust FLB|High|Thaler & Ziemba 1988; Snowberg & Wolfers 2010|
|Corporate internal|Informative, with identifiable biases (optimism; slow updating)|Moderate|Cowgill & Zitzewitz 2015|
|Macro releases|Market-based forecasts competitive with surveys|Moderate ⚑|Gürkaynak & Wolfers 2006 ⚑|
|Kalshi (pooled)|Informative; accuracy improves toward close; strong FLB; maker/taker return gap|Moderate (working paper) ⚑|Bürgi, Deng & Whelan 2025|
|**Weather brackets**|**No peer-reviewed evidence located**; grey-literature calibration analyses only|**None (peer-reviewed)**|see [[#Weather Prediction Markets]]|

The last row is the point: **the project's exact domain is an empirical blank in the refereed literature.** That is simultaneously why the V1 instrument is worth building and why every prior imported from other domains must be labeled as an import.

---

## Weather Prediction Markets

**Structure (Kalshi).** Daily high/low temperature markets per city, resolved against official station observations; each event is a **bracket ladder** — an exhaustive partition of the temperature range into binary contracts (see [[Kalshi Ticker Anatomy and Market Structure]]). Project scope: daily highs for KPHX, KNYC, KMDW, KMIA, KAUS.

**What makes weather markets distinctive as a research domain:**

1. **The competition is unusually strong and public.** NWS forecasts are among the best-calibrated operational forecasts in existence, and ensemble guidance (GEFS/ECMWF) provides genuinely probabilistic public information. Every trader can read the same forecasts the model rung uses. The semi-strong null is therefore _maximally plausible_ here.
2. **Short-dated and fundamentals-driven.** Daily brackets resolve within ~24–48h of active trading; there is no narrative or partisan attachment, no cash-flow ambiguity, and the information process (successive model runs, then intraday observations) is well-structured. Elections-derived behavioral findings may simply not transfer.
3. **Outcomes are exogenous.** Nobody manipulates the temperature. Manipulation risk collapses to **settlement-source risk**: which official product settles the contract, and whether it can be revised (CLI report vs. max of hourly observations — the standing unresolved question; preliminary/final CLI revisions are a known phenomenon ⚑).
4. **High event frequency, heavy dependence.** ~150 city-days/month across five cities, but ~6 brackets per city-day resolve from _one_ temperature draw, and cities co-move under synoptic systems. Naive n vastly overstates evidence ([[Effective Sample Size]]).
5. **Intraday information dynamics.** Morning prices and final-hour prices are different forecasts on different information sets (Q5); the market's incorporation speed of new model runs is the most tractable weather-specific inefficiency hypothesis ([[Edge Detection v4]]).

**Evidence state.** Peer-reviewed: none located for exchange-traded weather bracket markets specifically (weather _derivatives_ — CME HDD/CDD swaps — are a related but distinct literature: hedging instruments priced with risk premia, not probability elicitations). Experimental: prediction markets on monthly UK rainfall/temperature with granular joint-outcome spaces have been run and reportedly aggregated expert judgment ⚑ (exact citation to be identified and verified before use). Grey literature: multiple 2025–26 Kalshi weather calibration analyses and commercial "edge-finder" tools (see [[#Calibration]]) — unaudited, but proof that the naive strategies are crowded.

**Standing project unknowns this section feeds:** Q1 (weather-bracket calibration/FLB), Q2 (extraction rule), Q4 (historical archives), Q5 (horizon/incorporation speed), Q7 (staleness).

---

## Political Markets

The founding domain and still the most-studied. Beyond the accuracy record ([[#Forecast Accuracy]]):

- **Long history:** Wall Street election markets 1868–1940 (Rhode & Strumpf, 2004) with strong forecasting records long before scientific polling.
- **Manipulation episodes:** documented attempts include the 2012 "Romney whale" on Intrade (Rothschild & Sethi, 2016 ⚑) and a 2008 Intrade episode; attempts are common, durable price distortion is rare (see [[#Known Market Failures]]).
- **Legal arc (US):** election contracts prohibited on regulated venues until KalshiEX LLC v. CFTC (2024); large-scale legal election markets are thus a post-2024 phenomenon, and legislative proposals to re-restrict them are active (2025–26). ⚑
- **Interpretive caution:** political markets attract partisan/motivated traders; belief heterogeneity is extreme, which is exactly the regime where Manski's critique bites hardest. Weather markets are the opposite pole — a reason to be careful importing election-market findings.

---

## Financial Applications

- **Macro-release markets:** short-lived "economic derivatives" (Goldman/Deutsche, 2002–06) on payrolls/ISM/claims; market-implied forecasts were competitive with or better than survey consensus (Gürkaynak & Wolfers, 2006 ⚑). Kalshi now lists CPI/Fed/GDP contracts continuously — a modern revival.
- **Central-bank probability extraction:** Fed funds futures-implied path probabilities are the institutional ancestor of event-contract probabilities; a mature methodology for turning prices into probabilities, with the same risk-premium caveats.
- **Hedging interpretation:** where participants hedge real exposures (energy vs. temperature), prices embed **risk premia** in addition to probabilities — $P_m = \mathbb{P}(Y) + \text{premium}$. At retail scale in daily temperature brackets, hedging flow is probably negligible ⚑, but the decomposition belongs in any market-implied-probability normalization spec (A4).
- **Boundary note:** weather _derivatives_ (CME) ≠ weather _prediction markets_; the former's literature (Campbell & Diebold, 2005, on temperature modeling ⚑) is useful for the model rung, not for market-behavior priors.

---

## Behavioral Biases

**Favorite–longshot bias (FLB)** — the most replicated pricing anomaly in wagering markets, documented since Griffith (1949), surveyed in Thaler & Ziemba (1988) and Ottaviani & Sørensen (2008). **Direction, stated carefully: low-probability contracts are OVERPRICED (a 5¢ contract wins less than 5% of the time; buyers lose), high-probability contracts are UNDERPRICED (a 90¢ contract wins more than 90% of the time; buyers earn small positive returns).** Competing mechanisms:

1. **Preference-based:** risk-love/skewness preference — paying for lottery-like payoffs (Golec & Tamarkin, 1998).
2. **Misperception-based:** prospect-theoretic probability weighting overweights small probabilities. Snowberg & Wolfers (2010) discriminate using exotic-bet pricing and find misperception fits better.
3. **Structural:** in bookmaker/pari-mutuel settings, margin structure and insider protection generate FLB mechanically — mechanisms that _cannot operate_ on an exchange CLOB, which is why the Kalshi finding (FLB present anyway; Bürgi, Deng & Whelan, 2025 ⚑) strengthens the misperception reading.

Kalshi effect sizes on record (⚑ from abstract/summaries — verify against a specific paper vintage before any downstream use): buyers of contracts under 10¢ lose over 60% of their money; contracts above 50¢ earn small positive returns; pattern holds across categories; FLB much stronger on the Taker side; some evidence the bias is diminishing over time (feeds Q6).

**Partition dependence** — elicited probabilities depend on how the outcome space is partitioned; documented in lab and field prediction markets (Sonnemann, Camerer, Fox & Langer, 2013 ⚑). **Directly relevant to temperature bracket ladders**, which are exactly the kind of arbitrary partition the effect concerns: bracket width and placement may themselves induce mispricing patterns. No weather-specific evidence located; a candidate hypothesis for post-Q1 work.

**Over/underreaction:** momentum and drift findings are mixed and domain-dependent; the theoretically motivated version for this project is underreaction to new NWS runs (Q5). **Herding/correlated beliefs:** shrink effective crowd size; plausible in weather markets where most participants read the same two or three forecast products.

**Discipline note:** none of these biases has been established in Kalshi weather brackets. They set directional priors and effect-size ceilings for Q1's pre-registration — not conclusions.

---

## Known Market Failures

- **Manipulation — mostly resilient, not invulnerable.** Field and lab studies overwhelmingly find manipulation attempts fail to durably distort prices: Camerer (1998, racetrack field experiment), Wolfers & Leigh (2002), Rhode & Strumpf (2004; and their own field manipulations), Hanson, Oprea & Porter (2006, lab), Hanson & Oprea (2009, theory: manipulators subsidize accuracy by adding noise trading that informed traders profit from correcting). Exceptions exist: Zitzewitz (2007) and the 2012 Intrade episode (Rothschild & Sethi, 2016 ⚑) document sustained distortion; a 2025 randomized field experiment on manipulability ⚑ (arXiv 2503.03312 — verify publication status) is better powered than prior designs. **Weather relevance: low** — outcomes are exogenous; the analogous risk is settlement-source integrity.
- **Insider/MNPI trading (2025–26):** first CFTC enforcement actions in event contracts, including a criminal case over trades placed on military action using classified information, plus exchange-level actions against candidates trading their own races. ⚑ Weather relevance: near-zero for outcomes; nonzero for _settlement_ information paths.
- **Resolution ambiguity:** contracts have failed or become disputes because the settlement criterion was ambiguous or the source revised. For this project this is not a tail risk but a design focus (snapshot the rules pages; verify station IDs — the M1b gate).
- **Liquidity failure / degenerate quotes:** thin brackets with placeholder quotes produce prices that are not forecasts; scoring them as forecasts is a measurement failure of the researcher, not the market.
- **Political shutdown risk:** PAM (2003) cancelled by outrage; election contracts banned then un-banned by litigation; state gaming suits and congressional bills active now. A venue-level failure mode with direct pipeline-continuity implications.
- **Structural fee distortion:** price-dependent fees shift where quotes can profitably sit, mechanically distorting extreme prices independent of beliefs (feeds A4's normalization).

---

## Statistical Evaluation

How market (or model) forecast quality is established — condensed here, canonical treatment in [[Proper Scoring Rules and Calibration - Technical Reference (V2)]] and [[Effective Sample Size]]:

1. **Proper scores only** (Brier, log; RPS across a bracket ladder), with **Murphy decomposition** (reliability / resolution / uncertainty) to separate calibration from information content.
2. **Skill, not raw scores.** Compare on common events via paired score differentials against the reference ladder — climatology → NWS-derived model → market — with references fixed out-of-sample. Positive, dependence-robust skill vs. the _market_ rung is the definition of edge.
3. **Honest units of evidence.** The city-day is the statistical unit (~150/month, not 900 bracket-resolutions); cluster or block-bootstrap by date; discount further for spatial correlation.
4. **Inference on differentials:** Diebold–Mariano-style tests adapted for dependence; confidence intervals, not point boasts.
5. **Pre-registration** of event sets, extraction rules, metrics, and thresholds before outcomes are inspected ([[Pre-Registered Experiment Template]]); multiplicity corrections for any scan across cities/horizons.
6. **Population-level validation only.** No single resolved market ever validates or refutes a probability.

The prediction-market literature itself frequently violates several of these (pooled calibration curves without dependence adjustment; post-hoc liquidity filters) — grade external studies accordingly when verifying them.

---

## Practical Constraints

Constraints that bind any empirical or (eventually, V3-gated) trading use of these markets:

- **Fees.** Kalshi charges price-dependent trading fees concentrated on takers (of order $0.07 \cdot P \cdot (1-P)$ per contract, maximized at P=50¢ ⚑ — verify current fee schedule against Kalshi's published formula and record the snapshot; fee changes are ADR-worthy events). Consequences: mid-range prices are costliest to trade; fee-induced quote displacement is largest there; any "edge" must be stated **net of the fee at the executable price**.
- **Spreads and depth.** The effective cost of expressing a view is the spread at executable size, not the touch. Thin tails compound with FLB.
- **Position limits and capital lockup.** Binary contracts lock capital to resolution; short-dated weather brackets mitigate this relative to elections but multiply transaction counts (and fee events).
- **API and data constraints.** Rate limits, historical data availability, and the non-backfillability of order-book states: what is not captured at ingestion time is gone. (Same class of accrual risk as NWS forecast issuance history.)
- **Regulatory continuity.** Contract categories have been created and destroyed by litigation within single years (2024–26); collection breadth is partly insurance.
- **Counterparty/venue risk.** Exchange rule changes, settlement-source changes, and market delistings are all observed phenomena; snapshot rules pages (content-addressed) so that every historical market is scored against the rules in force when it traded.

---

## Engineering Considerations for Automated Trading Systems

Stated for generality, then mapped to this Lab's architecture. The literature's engineering lessons:

1. **The market price is the strongest single feature and the correct benchmark.** Any system that ignores it is discarding information; any system that only echoes it has no reason to exist. The object of interest is the _divergence_ $\Delta = P_{model} - P_{market}$ and its out-of-sample predictive content.
2. **Two timestamps or leakage.** Every price and forecast must carry event time and ingestion time; look-ahead leakage is the default failure mode of backtests on market data. (→ dual-timestamp architecture, ADR-ratified.)
3. **Append-only raw data; snapshot everything that can change** (order books, settlement rules, station metadata). A changed document is a new snapshot. (→ content-addressed snapshot store.)
4. **Fix the market-forecast extraction rule before scoring anything** — midpoint vs. time-weighted midpoint vs. microprice; staleness and degenerate-quote handling; timestamp convention. Changing it after seeing results is p-hacking. (→ Q2, blocks Experiment #1.)
5. **Model costs at executable depth from day one of any EV computation.** Score-edge is necessary; fee-and-spread-surviving edge is the sufficient condition. (→ A4 cost band; V2 paper-Kelly ledger.)
6. **Separate the measurement instrument from the decision layer.** Calibration measurement (V1) must not share code paths or incentives with trading logic (V3); the instrument's job is to be right, including about the absence of edge. (→ version gates; scoring module contracts.)
7. **Kelly sizing under estimation error.** Full Kelly with a miscalibrated model over-bets catastrophically; fractional Kelly is the standard hedge against parameter uncertainty ([[Kelly Criterion]]; the Kelly–log-score identity makes over-betting and overconfidence literally the same error).
8. **Nonstationarity handling.** Edges decay (adaptive-markets frame; direct Kalshi evidence of diminishing bias ⚑); any deployed signal needs monitored live performance vs. registered expectations, with pre-registered kill criteria.
9. **Alerting before accrual.** Data gaps in a non-backfillable collection are permanent; alerting on collection failure is part of the instrument, not an operational luxury. (→ the flagged M9-vs-M1 sequencing risk, RL-TDD-001.)

```
Reference ladder (skill benchmarks, weakest → strongest)

  climatology  ──►  NWS-derived model  ──►  market-implied
   (base rate)      (public forecast)      (aggregated posterior)

Edge (statistical) := positive, dependence-robust proper-score skill
                      of the model rung vs. the MARKET rung
Edge (economic)    := statistical edge − fees − spread at executable depth > 0
```

---

## Common Misconceptions

1. **"Price = probability."** Only under conditions (Wolfers & Zitzewitz, 2006); with heterogeneous beliefs the price bounds, not identifies, mean belief (Manski, 2006). Always specify the extraction rule and fee adjustment.
2. **"The market was wrong — the 20% event happened."** Single-outcome validation is meaningless; probabilities validate only in aggregate.
3. **"Markets beat polls."** They beat _naive_ poll aggregates; engineered aggregation ties or wins (Atanasov et al., 2017). State the comparator.
4. **"Efficiency means no edge can exist."** Grossman–Stiglitz: equilibrium _requires_ returns to costly information. The empirical question is who collects them and whether you can.
5. **"An inefficiency implies a profit."** Not until it survives fees, spread at executable depth, and adverse selection. Most published anomalies die in the cost band.
6. **"Volume/scale eliminates behavioral bias."** Kalshi's pooled FLB persists despite uncapped volume (Bürgi, Deng & Whelan, 2025 ⚑).
7. **"Good calibration = good forecasting."** Calibration is achievable with zero knowledge (Foster & Vohra, 1998); resolution carries the information.
8. **"Longshots are underpriced lottery tickets."** Backwards: FLB says longshots are systematically **over**priced. (The v1 seed note of this document contained this reversal in a worked example — the error class this misconception list exists to prevent.)
9. **"Findings transfer across domains."** Election-market behavioral results are priors, not facts, about short-dated weather brackets. Every import must be labeled.

---

## Open Research Questions

**Field-level (literature):**

- Mechanism of FLB in exchange (non-bookmaker) settings — misperception vs. preference vs. fee structure; whether it attenuates as venues mature.
- Price interpretation under heterogeneous beliefs — empirical resolution of Manski vs. Wolfers–Zitzewitz across market types.
- Partition dependence in bracket-ladder markets — untested outside lab/field studies on other domains.
- Market incorporation dynamics of scheduled public information (model runs, data releases) — underreaction magnitude and decay.
- Whether engineered statistical aggregates systematically dominate CLOB markets at short horizons (the Atanasov results are long-horizon geopolitical).

**Project-level (this Lab; canonical register is [[Open Questions]]):**

- Q1 weather-bracket calibration/FLB · Q2 extraction rule · Q3 dependence/effective n · Q4 archive backfill · Q5 horizon/incorporation speed · Q6 efficiency nonstationarity · Q7 staleness bias — plus the settlement-source question (CLI vs. hourly max) and the A3/A4 collection-sufficiency and normalization specs.

---

## Key References

**All entries E4 until human-verified per Invariant 3.** Entries marked ⚑ above were used via abstracts or secondary sources. Alphabetical within groups.

**Foundations & theory**

- Fama, E. (1970). "Efficient Capital Markets: A Review of Theory and Empirical Work." _Journal of Finance_, 25(2).
- Grossman, S. & Stiglitz, J. (1980). "On the Impossibility of Informationally Efficient Markets." _American Economic Review_, 70(3).
- Hayek, F.A. (1945). "The Use of Knowledge in Society." _American Economic Review_, 35(4).
- Lo, A. (2004). "The Adaptive Markets Hypothesis." _Journal of Portfolio Management_, 30.
- Milgrom, P. & Stokey, N. (1982). "Information, Trade and Common Knowledge." _Journal of Economic Theory_, 26(1).
- Muth, J. (1961). "Rational Expectations and the Theory of Price Movements." _Econometrica_, 29(3).
- Ostrovsky, M. (2012). "Information Aggregation in Dynamic Markets with Strategic Traders." _Econometrica_, 80(6).
- Plott, C. & Sunder, S. (1982). "Efficiency of Experimental Security Markets with Insider Information." _Journal of Political Economy_, 90(4). — and (1988), _Econometrica_, 56(5), on dispersed information.

**Prediction markets: surveys & interpretation**

- Arrow, K. et al. (2008). "The Promise of Prediction Markets." _Science_, 320.
- Manski, C. (2006). "Interpreting the Predictions of Prediction Markets." _Economics Letters_, 91(3).
- Wolfers, J. & Zitzewitz, E. (2004). "Prediction Markets." _Journal of Economic Perspectives_, 18(2).
- Wolfers, J. & Zitzewitz, E. (2006). "Interpreting Prediction Market Prices as Probabilities." NBER WP 12200.

**Accuracy & calibration evidence**

- Atanasov, P. et al. (2017). "Distilling the Wisdom of Crowds: Prediction Markets vs. Prediction Polls." _Management Science_, 63(3).
- Atanasov, P., Witkowski, J., Mellers, B. & Tetlock, P. (2024). "Crowd Prediction Systems: Markets, Polls, and Elite Forecasters." _International Journal of Forecasting_. ⚑
- Berg, J., Forsythe, R., Nelson, F. & Rietz, T. (2008). "Results from a Dozen Years of Election Futures Markets Research." _Handbook of Experimental Economics Results_.
- Bürgi, C., Deng, W. & Whelan, K. (2025/2026). "Makers and Takers: The Economics of the Kalshi Prediction Market." Working paper; ≥2 vintages (CESifo/UCD WP2025_19; GWU WP 2026-001). **Verify against a specific version.** ⚑
- Cowgill, B. & Zitzewitz, E. (2015). "Corporate Prediction Markets: Evidence from Google, Ford, and Firm X." _Review of Economic Studies_, 82(4).
- Dana, J., Atanasov, P., Tetlock, P. & Mellers, B. (2019). "Are markets more accurate than polls? The surprising informational value of 'just asking'." _Judgment and Decision Making_, 14(2). ⚑
- Erikson, R. & Wlezien, C. (2008). "Are Political Markets Really Superior to Polls as Election Predictors?" _Public Opinion Quarterly_, 72(2).
- Gürkaynak, R. & Wolfers, J. (2006). "Macroeconomic Derivatives: An Initial Analysis of Market-Based Macro Forecasts, Uncertainty, and Risk." NBER WP 11929. ⚑
- Page, L. & Clemen, R.T. (2013). "Do Prediction Markets Produce Well-Calibrated Probability Forecasts?" _Economic Journal_, 123(568).
- Rhode, P. & Strumpf, K. (2004). "Historical Presidential Betting Markets." _Journal of Economic Perspectives_, 18(2).
- Servan-Schreiber, E., Wolfers, J., Pennock, D. & Galebach, B. (2004). "Prediction Markets: Does Money Matter?" _Electronic Markets_, 14(3). ⚑

**Behavioral & biases**

- Golec, J. & Tamarkin, M. (1998). "Bettors Love Skewness, Not Risk, at the Horse Track." _Journal of Political Economy_, 106(1).
- Griffith, R. (1949). "Odds Adjustments by American Horse-Race Bettors." _American Journal of Psychology_, 62.
- Ottaviani, M. & Sørensen, P. (2008). "The Favorite–Longshot Bias: An Overview of the Main Explanations." In _Handbook of Sports and Lottery Markets_.
- Snowberg, E. & Wolfers, J. (2010). "Explaining the Favorite–Long Shot Bias: Is It Risk-Love or Misperceptions?" _Journal of Political Economy_, 118(4).
- Sonnemann, U., Camerer, C., Fox, C. & Langer, T. (2013). "How Psychological Framing Affects Economic Market Prices in the Lab and Field." _PNAS_, 110(29). ⚑ (partition dependence)
- Thaler, R. & Ziemba, W. (1988). "Anomalies: Parimutuel Betting Markets." _Journal of Economic Perspectives_, 2(2).

**Mechanism design & microstructure**

- Glosten, L. & Milgrom, P. (1985). "Bid, Ask and Transaction Prices in a Specialist Market with Heterogeneously Informed Traders." _Journal of Financial Economics_, 14(1).
- Hanson, R. (2003). "Combinatorial Information Market Design." _Information Systems Frontiers_, 5(1). — and (2007), "Logarithmic Market Scoring Rules for Modular Combinatorial Information Aggregation," _Journal of Prediction Markets_, 1(1).
- Kyle, A. (1985). "Continuous Auctions and Insider Trading." _Econometrica_, 53(6).
- Sandås, P. (2001). "Adverse Selection and Competitive Market Making." _Review of Financial Studies_, 14(3).
- Tetlock, P.C. (2008). "Liquidity and Prediction Market Efficiency." Working paper. ⚑ (verify title/venue)

**Manipulation**

- Camerer, C. (1998). "Can Asset Markets Be Manipulated? A Field Experiment with Racetrack Betting." _Journal of Political Economy_, 106(3).
- Hanson, R. & Oprea, R. (2009). "A Manipulator Can Aid Prediction Market Accuracy." _Economica_, 76(302).
- Hanson, R., Oprea, R. & Porter, D. (2006). "Information Aggregation and Manipulation in an Experimental Market." _Journal of Economic Behavior & Organization_, 60(4).
- Rhode, P. & Strumpf, K. (2006/2008). "Manipulating Political Stock Markets: A Field Experiment and a Century of Observational Data." Working paper. ⚑
- Rothschild, D. & Sethi, R. (2016). "Trading Strategies and Market Microstructure: Evidence from a Prediction Market." _Journal of Prediction Markets_. ⚑ (verify venue)
- [Unattributed, 2025]. "How Manipulable Are Prediction Markets?" Randomized field experiment, arXiv:2503.03312. ⚑ (identify authors; verify publication status)

**Scoring & verification (canonical treatment in the scoring-rules note)**

- Brier, G. (1950). _Monthly Weather Review_, 78(1). · Foster, D. & Vohra, R. (1998). _Biometrika_, 85(2). · Gneiting, T. & Raftery, A. (2007). _JASA_, 102(477). · Gneiting, Balabdaoui & Raftery (2007). _JRSS-B_, 69(2). · Diebold, F. & Mariano, R. (1995). _JBES_, 13(3).

**Grey literature (E4; competition intelligence, not evidence)**

- Third-party Kalshi weather calibration analyses (2025–26): KXHIGHNY recalibration study (~8,494 settled markets; zerve.ai gallery); Lychee Data weather-market calibration guides; commercial edge-scanner tools. Methodology unaudited; several publishers have commercial incentives.
- CRS reports on prediction-market policy (2026); CFTC enforcement advisory on event contracts (Feb 2026); Britannica/news coverage of venue volumes. Use for regulatory context only.

---

## Changes from v1

The seed note (2026-07-07) was audited on 2026-07-08. Disposition:

- **Preserved (rewritten, now cited):** three-layer problem decomposition (estimation → mispricing → allocation); "probabilistic arbitrage against collective intelligence" framing; EV-after-costs objective; calibration-over-accuracy emphasis; liquidity-as-dominant-variable; forecast-combination robustness; markets-as-Bayesian-aggregators framing.
- **Corrected:** the calibration example table and prose that stated the favorite–longshot bias **backwards** (showed longshots underpriced); overclaims on sports-market efficiency and corporate-market evidence; broken LaTeX throughout.
- **Removed:** all uncited "Confidence: High/Moderate" assertions (replaced by E4-pending-verification discipline and named sources); triplicated FLB/calibration/combination sections; speculative ML section (a stub belongs in [[Machine Learning]] when evidence exists); "autonomous trading system" framing that presupposed the V3 gate.
- **Added:** economic foundations (Hayek, Muth, Milgrom–Stokey, Grossman–Stiglitz); Manski vs. Wolfers–Zitzewitz; LMSR mathematics; microstructure (Glosten–Milgrom, Kyle, maker/taker); Kalshi-specific evidence; the entire weather-market section; manipulation literature; regulatory history through 2026; statistical-evaluation discipline; misconceptions; full reference list.

**Verification queue for the Architect (highest value first):** (1) Bürgi–Deng–Whelan effect sizes against a specific vintage's tables; (2) Kalshi fee formula snapshot; (3) Page & Clemen horizon result; (4) Atanasov 2017/2024 headline results; (5) the ⚑-flagged citations (Sonnemann et al.; Gürkaynak & Wolfers; Servan-Schreiber et al.; Rothschild & Sethi; UK rainfall experimental markets; arXiv 2503.03312). Each verified item can then be promoted from E4 with a dated Lit-note.
