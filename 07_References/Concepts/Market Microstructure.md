---

## title: "Market Microstructure — Research Synthesis" version: 1 status: "E4 — AI-drafted, pending Architect verification and canonization" created: 2026-07-11 vault_location: "07 References/Concepts" tags: [microstructure, prediction-markets, liquidity, price-discovery, canon-candidate]

# Market Microstructure — Research Synthesis

**Vault location:** `07 References/Concepts` **Level:** Quantitative researcher reference (assumes probability theory, statistical inference, basic stochastic processes; familiarity with [[Probability]] and [[Prediction_Markets]]) **Cross-links:** [[Prediction_Markets]] · [[Edge_Detection]] · [[Probability]] · [[Bayesian_Statistics]] · [[Expected_Value]] · [[Kelly_Criterion]] · [[Forecast_Verification]] · [[Proper_Scoring_Rules_and_Calibration]] · [[Machine_Learning]] · [[Log_Score_and_Kelly_Identity]] · [[Kalshi_API]] · [[Kalshi_Ticker_Anatomy_and_Market_Structure]] · [[National_Weather_Service]] · [[Effective_Sample_Size]] · [[Glossary]] **Status:** Version 1 — draft, ungraded pending Architect verification (Invariant 3) **Created:** 2026-07-11

> [!warning] Epistemic status (Invariant 3) This document is AI-drafted testimony, not evidence. Every bibliographic citation was produced from model knowledge without live retrieval and **must be independently verified (title, year, venue, page-level claims) before any statement here is cited as load-bearing in a registration or ADR**. Lower-confidence citations and empirical magnitudes carry ⚑ per house convention; ★ marks the priority verification tier (entries directly feeding A-series decisions or V2/V3 gates). Claims about Kalshi's current mechanics (fees, tick size, matching rules, maker programs) are **doubly flagged**: they are both AI testimony and descriptions of a system that changes by rulebook amendment; they must be verified against the live rulebook and API documentation, snapshot-archived, before use. The synthesis of _ideas_ is believed faithful to the literature; bibliographic metadata and platform-specific parameters are the most fragile layers.

> [!info] Boundaries with neighboring documents This document owns the _mechanics of trading_: how order books work, why spreads exist, how information becomes price, and where market structure creates or destroys edge. [[Prediction_Markets]] owns the _economics of prediction markets_ as institutions (why they aggregate information, their history, their accuracy record). [[Edge_Detection]] owns the _statistical validation_ of any edge this document helps locate — nothing here licenses a trade. [[Kelly_Criterion]] owns sizing; [[Expected_Value]] owns the EV epistemology; A1 (Statistical Validity & Inference Framework) will own inference on any microstructure statistic once ratified. Where this document states a convention, it is authoritative for that convention only; where it touches settlement, [[National_Weather_Service]] and the F1 finding (settlement = CLI product, not raw observations) govern.

---

## 1. Historical Development

### 1.1 From Bachelier to the electronic limit order book

Market microstructure is young as a named field but old as a set of questions. **Louis Bachelier's** _Théorie de la spéculation_ (1900) ⚑ modeled price changes as a random walk five years before Einstein's Brownian motion paper, and in doing so posed the question the field still circles: if prices are unforecastable, what exactly is the trading process _doing_? Bachelier treated the price as a diffusion; he had no theory of _why_ it diffused. The gap between "prices follow a stochastic process" and "prices are produced by a mechanism populated by strategic agents" is precisely the space microstructure occupies.

**Friedrich Hayek's** "The Use of Knowledge in Society" (1945, _American Economic Review_) ⚑ supplied the second pillar: prices are a communication system that aggregates dispersed, tacit, and contradictory private information that no central planner could collect. Hayek's insight is the philosophical charter for prediction markets specifically — the claim that a market price over an event can encode more than any individual forecaster knows — and it is the claim the Lab's entire V1→V2 program is designed to _test locally_ rather than assume: does the Kalshi price for a Phoenix temperature bracket actually aggregate information beyond the NWS forecast, or does it merely echo it with noise and fees? Hayek asserts aggregation; microstructure explains the mechanism and its failure modes.

The field acquired its name with **Mark Garman (1976)** ⚑, whose "Market microstructure" (_Journal of Financial Economics_) modeled a dealer facing stochastic buy and sell order arrivals and asked how quotes must be set to avoid ruin — the first inventory model. **Harold Demsetz (1968)** ⚑, "The Cost of Transacting" (_QJE_), predates the name but founded the substance: the bid-ask spread is the price of _immediacy_, paid by those who demand to trade now to those who stand ready to wait. Demsetz made the spread an equilibrium object rather than a friction to be assumed away.

The 1980s produced the field's two theoretical monuments, both in 1985:

- **Kyle (1985)** ★, "Continuous Auctions and Insider Trading" (_Econometrica_): a single informed trader strategically feeds orders into a market where a market maker sets prices as a function of aggregate order flow. Prices become linear in net order flow; the coefficient — **Kyle's λ** — is the first rigorous measure of market depth and the ancestor of every price-impact model in use today (§17.1).
- **Glosten & Milgrom (1985)** ★, "Bid, Ask and Transaction Prices in a Specialist Market with Heterogeneously Informed Traders" (_JFE_): a sequential-trade model in which the spread exists _purely_ because some counterparties know more than the market maker. Each trade is a Bayesian signal; quotes are conditional expectations. This model is the single most important piece of theory in this document for the Lab's purposes, because a binary prediction market is very nearly a _literal instantiation_ of it (§17.2).

**Maureen O'Hara's** _Market Microstructure Theory_ (1995) ⚑ consolidated the theory; **Ananth Madhavan (2000)** ⚑, "Market Microstructure: A Survey" (_Journal of Financial Markets_), organized the empirics; **Larry Harris's** _Trading and Exchanges_ (2003) ⚑ codified the practitioner taxonomy (trader types, order types, market structures) that this document borrows throughout. **Joel Hasbrouck's** _Empirical Market Microstructure_ (2007) ⚑ supplied the econometric toolkit: information shares, VAR models of quotes and trades, the decomposition of prices into a random-walk efficient price plus stationary microstructure noise (§3.2). **David Easley and Maureen O'Hara** developed the probability-of-informed-trading (PIN) research program (Easley et al. 1996, _Journal of Finance_ ⚑), and with **Marcos López de Prado** extended it to volume time as **VPIN** (Easley, López de Prado, O'Hara 2012, _Review of Financial Studies_ ⚑ — including the contested claim that VPIN spiked before the 2010 Flash Crash; see §16.5 for the Andersen–Bondarenko rebuttal ⚑). López de Prado's _Advances in Financial Machine Learning_ (2018) ⚑ is the bridge text between microstructure and the ML practices governed by [[Machine_Learning]].

### 1.2 The evolution of electronic markets

The institutional history matters because Kalshi inherited its structure from it. U.S. equities moved from floor-based specialist trading (NYSE, one designated intermediary per stock with affirmative obligations) and dealer networks (NASDAQ, competing dealers quoting by phone) to **electronic communication networks** (ECNs, 1990s) after the 1994 Christie–Schultz odd-eighths collusion findings ⚑ and the SEC's 1997 order handling rules forced displayed limit orders into the public quote. Decimalization (2001) collapsed tick sizes from sixteenths to pennies; Regulation NMS (2005) ⚑ knitted competing venues into a national market system; and by the 2010s the modal U.S. equity market was a fully electronic **central limit order book (CLOB)** with price-time priority, populated significantly by algorithmic and high-frequency traders. The specialist with obligations gave way to voluntary electronic liquidity provision — market making as a strategy anyone may enter and exit, with the resiliency consequences §5.4 discusses.

Kalshi (CFTC-designated contract market, launched 2021 ⚑) adopted the end state of this evolution directly: an anonymous electronic CLOB, price-time priority, one-cent ticks on binary contracts priced 1¢–99¢ ⚑★. There is no designated specialist with affirmative obligations; liquidity provision is voluntary and, in thin weather markets, intermittent. Every structural property the Lab observes in its order book snapshots — wide spreads at 3 a.m., depth that appears after a forecast release, quotes that go stale between NWS issuances — is a predictable consequence of this institutional design choice, not an anomaly.

---

## 2. What Is Market Microstructure?

### 2.1 Definition

O'Hara's canonical definition ⚑: market microstructure is **the study of the process and outcomes of exchanging assets under explicit trading rules**. Three clauses, each load-bearing:

- **Process**: not just equilibrium prices but the sequence of quotes, orders, cancellations, and trades that produces them. The process is observable at far higher resolution than the "fundamentals," which is why microstructure is an _empirical_ discipline before it is a theoretical one.
- **Explicit trading rules**: the matching algorithm, tick size, order types, fee schedule, and settlement procedure are not background details; they are parameters of the game whose equilibria we observe. Change the rules, change the prices. This is why §14's platform specifics are not an appendix but a core section.
- **Exchanging assets**: microstructure is about _trading_, and trading is where the Lab's V3 gate lives. V1 and V2 can be executed with microstructure knowledge used purely for _measurement design_ — knowing what a quoted price does and does not mean is prerequisite to comparing it against an NWS-derived probability at all.

### 2.2 The four questions

The field decomposes into four questions, and this document is organized around them:

1. **Price formation** — how do transaction prices come to exist, and what do they estimate? (§3, §9)
2. **Information aggregation** — how does dispersed private information become public price? (§8, §9, §13)
3. **Liquidity** — what does it cost to trade, in whose favor, and when? (§5, §6, §11)
4. **Mechanism design** — how do the trading rules shape all of the above? (§12, §14)

### 2.3 Why markets cannot be understood through price alone

A time series of last-traded prices is a **lossy, biased, irregularly-sampled projection** of the market's state. Four independent reasons:

- **Bid-ask bounce**: consecutive trades alternate between bid and ask even when no information arrives, inducing spurious negative autocorrelation in "returns" (Roll 1984 ⚑; §17.3). A naive volatility estimate from trade prices in a wide-spread Kalshi market is dominated by bounce, not belief revision.
- **Selection**: trades occur only when someone chooses to cross the spread. In thin markets, hours pass without trades while quotes — the live object — move repeatedly. The last trade in a weather bracket may be six hours stale; the _quote_ is the current market. This single fact drives the Lab's collection design: **snapshot the book, not just the tape** (§18.1).
- **Censoring at the spread**: the "true" price lives somewhere inside the bid-ask interval and is never directly printed. Every comparison of a Lab probability estimate against "the market price" must first answer _which_ price: bid, ask, mid, microprice, or last trade — each answers a different question (§3.1). This is exactly the class of decision A4 (Market Normalization Specification) exists to pre-commit.
- **Strategic supply**: displayed quantities are choices, not inventories. Depth can be pulled in milliseconds; the book you see is what liquidity providers _want_ you to see (§5.2).

The Lab's foundational epistemological principle — a probability is a claim about a population and can only be graded against a population — has a microstructure corollary: **a market price is a claim by a mechanism, and can only be interpreted through the mechanism that produced it.** A 30¢ ask sitting alone on an empty book and a 30¢ midpoint of a 29/31 market with 5,000 contracts each side are different epistemic objects that a price column collapses into the same number.

---

## 3. Price Formation

### 3.1 The taxonomy of prices

For a binary contract with best bid $b$ and best ask $a$ (in cents, payout 100¢ if YES):

- **Quoted prices**: $b$ and $a$. Commitments, not consensus — each is the reservation price of _one_ marginal liquidity provider, standing until canceled or filled.
- **Midpoint**: $m = (a+b)/2$. The conventional proxy for consensus value; unbiased only if liquidity provision is symmetric, which in prediction markets near 0 or 100 it systematically is not (§13.6).
- **Microprice** (Stoikov 2018 ⚑): with depth $Q_b$ at the bid and $Q_a$ at the ask, $$ p_{micro} = \frac{Q_a , b + Q_b , a}{Q_a + Q_b}, $$ the depth-weighted mid, tilting toward the side with _less_ resting size on the theory that the thin side is about to give way. Empirically a better short-horizon predictor of the next mid than the mid itself in equities ⚑; untested in Kalshi weather markets — a natural V2-era research question, and computable only if depth is collected (A3 relevance).
- **Transaction price**: where an aggressive order met a resting order. It is the mid plus roughly half the effective spread, signed by trade direction — a _cost-inclusive_ price.
- **Efficient price**: the unobservable martingale component $m^__t$ — the conditional expectation of settlement value given all available information — which observed prices track with stationary error: $p_t = m^__t + \varepsilon_t$ (Hasbrouck's decomposition ⚑). All of empirical microstructure is techniques for estimating properties of $m^*_t$ from the contaminated $p_t$.

**Lab convention (proposed, for A4 ratification):** every stored market probability must carry a tag identifying which of these objects it is, plus book context (spread, depth at touch) sufficient to reconstruct the alternatives. A bare "price" column is a normalization decision made silently, and silent decisions violate pre-registration discipline.

### 3.2 Price discovery vs. price formation

**Price formation** is the mechanical production of transaction prices by the matching engine. **Price discovery** is the incorporation of information into the efficient price. They are distinct: a market can form prices all day (noise traders crossing spreads) while discovering nothing, and can discover much while trading little (quotes updating on a forecast release with no trades printing). In Kalshi weather markets the second pattern is common and important: the informative event is often a _quote revision following an NWS issuance_, not a trade. A pipeline that logs only trades will systematically miss the discovery process it exists to measure — the microstructure restatement of the A3 collection-sufficiency concern.

### 3.3 Why prices move

Prices move for exactly four reasons, and separating them is most of the empirical work:

1. **Public information** — a scheduled or unscheduled news arrival shifts everyone's valuation; quotes jump without trades needing to occur. In weather markets this is the dominant mode: NWS forecast issuances, model runs (GFS/ECMWF cycles), and afternoon observations are _scheduled, public, and dated_ — an unusually clean natural experiment in public-information price discovery. ★ (This structure directly feeds edge hypotheses in §19.)
2. **Private-information inference from order flow** — trades themselves are signals; the market maker's Bayesian update moves quotes (Glosten–Milgrom, §17.2).
3. **Inventory pressure** — liquidity providers shade quotes to shed unwanted positions; the effect is transitory and reverts (§7.2).
4. **Noise and mechanics** — bounce, tick discreteness, fat fingers, liquidations. Transitory by construction.

Modes 1–2 move the efficient price (permanent impact); modes 3–4 do not (temporary impact). The permanent/temporary decomposition (§11) is the operational version of this taxonomy.

---

## 4. Order Books

### 4.1 Anatomy of the limit order book

A **central limit order book (CLOB)** is a pair of priority queues. The **bid side** holds resting buy orders sorted descending by price; the **ask side** holds resting sell orders sorted ascending. Within a price level, orders queue by arrival time: **price-time priority**. The best bid and best ask are the _touch_; their difference is the quoted spread; everything behind the touch is _depth_.

```
        ASKS (sell YES)              BIDS (buy YES)
  price   size                  price   size
   38¢     420                   35¢     600  ← best bid
   37¢     250                   34¢   1,100
   36¢     180  ← best ask       33¢     300

  quoted spread = 36¢ − 35¢ = 1¢ ;  mid = 35.5¢
```

A schematic for a thin weather bracket, where gaps dominate:

```
  ask  41¢ ██ 150
  ask  39¢ █ 60          ← best ask
  ---- spread: 6¢ ----
  bid  33¢ ██ 200        ← best bid
  bid  30¢ ████ 500
  bid  25¢ ██████ 900
```

Everything the Lab stores about "the market" is a function of this object at a timestamp. The book is the state; trades are transitions.

### 4.2 Order types

- **Limit order**: buy (sell) up to quantity $q$ at price no worse than $p$. If not immediately matchable, it _rests_, supplying liquidity and displayed information. The limit order is simultaneously an option granted to the market (anyone may hit it) and a signal (its price and size are public) — the twin costs that adverse selection theory (§8) and information leakage (§8.4) formalize.
- **Market order**: trade immediately at the best available price(s), walking the book if size exceeds touch depth. Demands liquidity; pays the spread; in a thin book, pays far more than the spread (§11.4).
- **Marketable limit order**: a limit priced through the touch — executes like a market order but with a worst-price bound. **In thin prediction markets this should be the Lab's only aggressive order type (V3-era)**: a true market order in a book with a 60¢ gap to the next level is an unbounded-loss instruction. ★
- **Stop orders**: dormant until a trigger price prints, then become market (stop) or limit (stop-limit) orders. They are _liquidity-demanding at the worst times_ — they fire into moves — and are the accelerant in cascade events. Whether Kalshi supports native stop orders is a platform fact to verify ⚑; the Lab has no V1/V2 use for them.
- **Hidden and iceberg orders**: fully hidden orders rest without display (typically losing time priority to displayed orders at the same price); icebergs display a _peak_ quantity and automatically refresh from a hidden reserve as the peak fills. Their existence means **displayed depth is a floor, not a measurement, of available liquidity** (§5.2). Whether Kalshi's engine supports hidden/iceberg functionality is a rulebook fact requiring verification before any depth-based feature is trusted ⚑★.

### 4.3 Matching and priority

The matching engine executes an incoming aggressive order against resting orders in strict priority: best price first; within price, earliest first (some derivatives markets use pro-rata allocation instead ⚑ — verify which discipline Kalshi's engine applies before modeling queue position ⚑★). Two implementation-relevant consequences:

- **Queue position is an asset.** A resting order at the front of a level captures spread with lower adverse-selection exposure than one at the back, because back-of-queue orders fill disproportionately when the level is about to be swept (the fill itself is bad news — "you got filled _because_ you were wrong"). Passive execution strategies live and die on queue dynamics.
- **The book is self-describing about cost.** Walking the book gives the _exact, deterministic_ cost of immediacy for any size right now. Expected cost of a resting order, by contrast, involves fill probability and adverse selection — a genuinely hard estimation problem. Aggressive costs are known; passive costs are forecast.

### 4.4 YES/NO duality on binary exchanges

On Kalshi, every contract has a YES and NO side with prices summing to 100¢ at settlement. A bid for NO at price $p$ is economically identical to an ask for YES at $100 - p$, and the exchange's book consolidates both sides ⚑ (verify the exact display and matching convention against current documentation ⚑★). Implication for collection: the Lab must confirm whether the API's order book endpoint presents a unified YES-equivalent book or separate YES/NO books, and normalize to a single convention in A4 — a duplicate of the F2-style precision-about-referents discipline (series ticker ≠ rulebook code; YES book ≠ NO book ≠ consolidated book).

---

## 5. Liquidity

### 5.1 Definition and dimensions

Liquidity is the ability to trade **quickly, in size, without moving the price**. Kyle (1985) ★ gave the canonical three dimensions:

- **Tightness** — the spread: cost of a round trip in small size.
- **Depth** — the size tradable at or near the touch: Kyle's $1/\lambda$.
- **Resiliency** — the speed at which the book replenishes after depletion.

Harris ⚑ adds **immediacy** (how fast can you trade at all) and breadth. The dimensions are not redundant: a Kalshi weather market an hour after a forecast release may be tight but shallow (1¢ spread, 50 contracts at touch); the same market overnight may be deep but wide (500 contracts resting, 8¢ spread). A single "liquidity" scalar is as lossy as a single verification score — the Murphy dimensionality lesson from [[Forecast_Verification]] transposed to market state.

### 5.2 Displayed vs. latent liquidity

**Displayed liquidity** is the visible book. **Latent liquidity** is everything that would trade if asked: hidden orders, iceberg reserves, and — dominant in small markets — _traders monitoring who would respond to a quote or a price move but rest nothing_. Empirical regularity from equities and futures ⚑: executed volume routinely exceeds what displayed depth "should" allow, because latent supply materializes against incoming flow. In prediction markets latent liquidity includes market-making programs that quote on demand and manual traders alerted by price moves. Consequences:

- Displayed depth **understates** what a patient trader can do and **overstates** nothing — it is a lower bound with unknown slack.
- Cost estimates from walking the displayed book are therefore _worst-case_ for marketable size, which is the conservative direction for V3 sizing — a rare case where the measurement bias is on the safe side. ★

### 5.3 Providers and consumers

Liquidity **providers** post resting orders, earn the spread, and bear adverse-selection and inventory risk. Liquidity **consumers** cross the spread, paying for immediacy. The roles are per-order, not per-trader: the same participant provides in one market and consumes in another. The Lab's eventual V3 posture is a _strategic choice on this axis_, not a detail: an edge derived from slow-moving public information (NWS issuance vs. stale quotes) can often be captured _passively_ — resting inside a wide spread at a price the Lab's probability justifies — converting the spread from a cost into a subsidy. The same edge captured aggressively pays the spread and may not survive it. [[Expected_Value]] arithmetic must be run per execution style, not per signal.

### 5.4 Why liquidity varies over time

Liquidity is the equilibrium of a voluntary game and inherits the dynamics of its players' incentives:

- **Information risk cycles**: quoting into a scheduled information event (a forecast issuance, an afternoon of realized temperatures) is writing options to better-informed counterparties; rational makers widen or withdraw before events and re-enter after. Expect Kalshi weather books to be _predictably_ thin immediately before NWS issuance windows and thick after — a hypothesis the Lab's own snapshots can test cheaply in V1. ★
- **Attention cycles**: retail-heavy platforms show diurnal and day-of-week liquidity seasonality ⚑; weather markets add an event-lifecycle pattern (contract listed → dormant → active as horizon shrinks → frantic near expiration → settled).
- **Volatility feedback**: higher volatility → wider spreads and thinner depth (inventory risk scales with variance) → larger price impact per order → measured volatility rises further. Liquidity spirals are this loop unhinged (Brunnermeier & Pedersen 2009 ⚑, funding vs. market liquidity).
- **No obligations**: with no designated market maker, zero liquidity is an admissible state. Empty or one-sided books are _data_ about maker risk assessments, not gaps to be interpolated over. The Lab's storage schema must represent "no bid" as a first-class value, never as 0¢. ★

---

## 6. The Bid-Ask Spread

### 6.1 The three spreads

For direction indicator $d_t \in {+1, -1}$ (buyer/seller-initiated), trade price $p_t$, prevailing mid $m_t$, and a later mid $m_{t+\Delta}$:

- **Quoted spread**: $S^{quoted}_t = a_t - b_t$. The advertised cost of a round trip at the touch.
- **Effective spread**: $S^{eff}_t = 2, d_t (p_t - m_t)$. What aggressors actually pay — less than quoted if there is price improvement or hidden liquidity inside the touch, more if the order walks the book. The honest cost measure for backtests. ★
- **Realized spread**: $S^{real}_t = 2, d_t (p_t - m_{t+\Delta})$. What the _liquidity provider_ actually keeps after the market has moved, evaluated at horizon $\Delta$ (5 minutes is a common equity convention ⚑; the right $\Delta$ for daily weather contracts is an open normalization question for A4).

The identity $S^{eff}_t = S^{real}_t + 2, d_t(m_{t+\Delta} - m_t)$ decomposes the aggressor's cost into the maker's revenue plus **price impact** (the adverse-selection component). When realized spreads are near zero while effective spreads are wide, makers are earning nothing: the entire spread is compensation for trading against informed flow. That regime — plausible in weather markets during information-rich hours — means _wide spreads are not automatically maker profits waiting to be harvested_; they may be actuarially fair premiums against people who have seen the 18z model run.

### 6.2 Why spreads exist: the three-component decomposition

The classical decomposition (Stoll 1989 ⚑; Glosten & Harris 1988 ⚑; Huang & Stoll 1997 ⚑) attributes the spread to:

1. **Order-processing costs** — exchange fees, infrastructure, the fixed cost of being present. Roughly size- and information-invariant.
2. **Inventory risk** — compensation for holding an unwanted, unhedgeable position while waiting for offsetting flow (Garman 1976 ⚑; Ho & Stoll 1981 ⚑). Scales with volatility and holding time.
3. **Adverse selection** — compensation for losses to better-informed counterparties (Glosten–Milgrom ★). Scales with the probability and quality of informed trading.

Empirical estimates in equities assign the majority of the spread to order processing and adverse selection, with proportions varying by market ⚑. For Kalshi weather markets the decomposition is testable and consequential (§14.2): the inventory component should be _unusually large_ (positions cannot be hedged and must be held to settlement or unwound in the same thin book) and the adverse-selection component should _spike on a schedule_ (around NWS issuances). If the Lab can decompose observed spreads even crudely, it learns _when_ the market fears informed flow — which is a map of when the market thinks information arrives, itself an input to edge hypotheses.

### 6.3 Tick size as a floor

Kalshi's 1¢ tick on a 0–100¢ instrument is enormous in relative terms: at a 5¢ price, one tick is 20% of the price, and the minimum quotable spread is a 1¢ absolute band. Two consequences with direct Lab relevance:

- **Probability resolution is capped.** The market _cannot express_ a probability distinction finer than ~1 percentage point, and near the boundaries the constraint binds hard: prices of 1¢–3¢ quantize a whole region of the probability axis. Calibration analysis of market prices ([[Proper_Scoring_Rules_and_Calibration]]) must treat tick quantization as measurement error in the market's forecast, or bins near 0/1 will show spurious miscalibration. ★
- **Queues, not price improvement.** When the tick floor binds (spread pinned at 1¢), competition among makers moves from price to queue position and size — the classic large-tick regime ⚑. Depth at the touch becomes the competitive margin, which strengthens the case for collecting depth, not just top-of-book prices (A3).

---

## 7. Market Makers

### 7.1 The market maker's problem

A market maker quotes both sides continuously, earning the spread on round trips while managing two risks that pull the quote in different directions:

- **Inventory risk** (Garman 1976 ⚑; Amihud & Mendelson 1980 ⚑; Ho & Stoll 1981 ⚑): accumulated positions expose the maker to price moves. Optimal response: _shade quotes against your inventory_ — long makers lower both bid and ask to encourage sells to them to stop and buys from them to resume. Inventory effects are mean-reverting in the maker's position and transitory in price.
- **Adverse selection** (Glosten & Milgrom ★): some counterparties trade _because they know something_. Optimal response: set bid and ask as conditional expectations — ask = E[value | next trade is a buy], bid = E[value | next trade is a sell] — so that each fill is, in expectation, break-even against the information it reveals. Adverse-selection effects are permanent in price.

The modern synthesis is **Avellaneda & Stoikov (2008)** ⚑: a stochastic-control formulation yielding optimal quotes as a reservation price (mid adjusted for inventory) plus a half-spread determined by risk aversion, volatility, and order-arrival intensity. It is the reference architecture for most algorithmic market-making systems and the natural starting point should the Lab ever consider passive two-sided quoting (far beyond V3; noted for completeness only).

### 7.2 Quoting behavior as observable data

The Lab does not need to _be_ a market maker to benefit from market-making theory; it needs to _read_ makers' behavior, which is public in the book:

- **Skew** (mid displaced toward one side relative to depth-weighted fair value) reveals maker inventory or directional fear.
- **Withdrawal** before scheduled information events reveals the market's own map of when information arrives (§5.4).
- **Asymmetric depth** persisting across snapshots suggests one-sided latent flow the makers are leaning against.

Each is a candidate V2-era feature, computable only from book snapshots with depth — the recurring A3 refrain.

### 7.3 Profitability and its fragility

Maker P&L per unit time ≈ (realized spread × fill rate) − inventory costs − fees. The realized spread (§6.1), not the quoted spread, is the revenue line; in toxic flow regimes it compresses toward zero or negative while quoted spreads look generous. Empirical literature on voluntary electronic makers ⚑ shows profitability concentrated in benign flow and sharp losses around information events — the reason resiliency fails exactly when consumers most want liquidity.

### 7.4 How prediction market makers differ from equity market makers

The differences are structural, not stylistic, and they matter for every inference the Lab draws from Kalshi quotes:

1. **No hedge instrument.** An equity maker lays off inventory in correlated instruments (futures, ETFs, options). A maker in the Phoenix ≥110° bracket has, at best, adjacent brackets in the same event — which hedge _event_ risk only partially and share the same thin liquidity. Inventory risk must be either warehoused to settlement or unwound against the same book it was acquired in. Expect inventory components of spreads to be structurally larger than equity intuitions suggest (§6.2).
2. **Terminal, dated settlement.** Every position resolves to 0 or 100 at a known time. Inventory risk _grows_ as expiration approaches (less time for offsetting flow, more concentrated information arrival) — opposite the equity maker's indefinite-horizon setting. Predicts widening spreads and maker withdrawal into settlement, modulated by how much uncertainty remains (§13.4).
3. **The asset is a probability.** Value is bounded [0,100], volatility is state-dependent (maximal near 50¢, collapsing near the boundaries as the outcome becomes certain — the martingale variance of a bounded process), and "fundamental value" arrives on a public schedule (NWS products). Maker models tuned to lognormal diffusions do not transfer; the relevant state variable is _remaining uncertainty_, not price level.
4. **Informed traders are identifiable as a class.** In equities, informed flow means insiders and superior analysts. In weather markets, "informed" means _faster or better processing of public meteorological data_ — the information is public, edges are latency and synthesis. This softens the classic adverse-selection problem (no one has private access to tomorrow's temperature) but sharpens the _processing race_ (§8.3, §19.3).
5. **Regulatory and program structure.** Kalshi operates maker incentive programs whose terms (rebates, obligations, symbols covered) shape observed liquidity ⚑ — a platform fact requiring rulebook verification and snapshot before any liquidity analysis treats quoting behavior as purely voluntary ⚑★.

---

## 8. Information Asymmetry

### 8.1 Informed and uninformed traders

The canonical typology (Harris ⚑): **informed traders** (trade on value-relevant information), **uninformed/liquidity traders** (trade for exogenous reasons — hedging, cash needs, entertainment), and **noise traders** (trade on pseudo-signals they believe are information; Black 1986 ⚑). The market maker cannot distinguish them ex ante — that impossibility _is_ the adverse-selection problem — but their aggregate mix determines equilibrium spreads (Glosten–Milgrom, §17.2) and depth (Kyle, §17.1).

The uncomfortable equilibrium fact (Glosten & Milgrom ⚑; Milgrom & Stokey's no-trade theorem 1982 ⚑): **informed trading is only possible because uninformed trading exists.** With only rational informed traders, no one takes the other side and the market unravels. Prediction markets live on this knife's edge more visibly than equities: their uninformed flow is recreation and opinion expression, not hedging demand, and it fluctuates with attention (§13.2). A weather bracket with no recreational flow is a market where the only counterparty is someone who has also read the forecast — and the Lab should ask, before every V3-era trade, _why is this liquidity available to me?_ The answer "because an uninformed participant wanted the other side" is comforting; the answer "because a better-calibrated forecaster posted it" is the adverse-selection trap. [[Expected_Value]]'s conditional-EV epistemology applies: EV is conditional on the counterparty-composition model, not just the probability model.

### 8.2 Adverse selection formalized

Each arriving order carries information with some probability. The maker's zero-profit quotes embed a **regret-proofing** margin: the ask is set high enough that _even conditional on the buyer being informed_, the maker breaks even on average. The spread is therefore a **posterior-predictive object** — it prices the maker's beliefs about the _distribution of counterparty knowledge_. Reading spreads as pure transaction friction misses that they are the market's self-reported estimate of its own informational vulnerability, time-stamped and free to collect.

### 8.3 Information leakage and informed order flow

Informed traders face a self-defeating dynamic: trading reveals the information being traded on. Kyle's insider optimally _spreads orders over time_, hiding in noise-trader volume, moving price only gradually (§17.1) — the theoretical basis for two empirical regularities:

- **Order flow autocorrelation**: informed flow arrives in same-direction sequences (order splitting), so imbalance predicts imbalance ⚑.
- **Gradual price adjustment**: prices drift toward the informed valuation over the informed trader's accumulation window rather than jumping (§9.3).

In Lab terms: if some Kalshi participants systematically process NWS updates faster than quotes adjust, their footprint is _directional flow bursts and quote revisions clustered in the minutes after issuance_. That footprint is measurable from the Lab's timestamped collection — one of the cleanest V2-era analyses available, since issuance times are exogenous and public. ★

### 8.4 The Lab as a (future) informed trader

Symmetrically: any V3-era Lab execution leaks. Posting a large resting order at 34¢ in a book quoted 30/38 _is_ a public forecast statement, and other participants' models will read it. Execution design (order sizing, splitting, display) is information management, not just cost management. Pre-registering execution rules in A4-successor documents is the microstructure analogue of pre-registering analysis choices: it prevents the leak profile from being improvised under P&L pressure.

---

## 9. Price Discovery

### 9.1 Information incorporation as the market's output

Price discovery is the process by which the efficient price $m^*_t$ absorbs information. Its two conduits (§3.3): **public announcements** (quotes revise without trades) and **order flow** (trades reveal private assessments; quotes revise in response). Empirical microstructure attributes a large share of equity price discovery to order flow ⚑ (Hasbrouck's information-share methodology ⚑); for weather derivatives on public data, the prior should tilt heavily toward the announcement channel — but _how heavily_ is measurable, and the answer is close to the Lab's core question. If essentially all discovery in Kalshi weather brackets happens via quote revision after NWS products, the market is a _repricing service on public forecasts_ and edge must come from beating that repricing (speed or synthesis). If material discovery happens via flow _between_ issuances, someone is adding information beyond the NWS — and the Lab must locate what they know before claiming edge against the price. This dichotomy should be an explicit V2 hypothesis. ★

### 9.2 News shocks and adjustment speed

Event-study logic transfers directly: measure the quote path around exogenous, timestamped NWS issuances. Instantaneous full adjustment = efficient repricing, no latency edge. Measurable drift over minutes–hours toward the post-issuance equilibrium = information latency (§19.2). The weather setting is unusually favorable for this measurement because the "news" is scheduled, machine-readable, and archived — provided the Lab collects _forecast issuance history_, which is unrecoverable retroactively (the A3 finding; this section is its microstructure justification).

### 9.3 Permanent vs. temporary impact

Every price move decomposes into a permanent component (efficient-price revision: information) and a temporary component (liquidity/inventory effects: reverts). Operationally, the permanent component of a trade's impact is estimated by the mid change surviving to horizon $\Delta$ (§6.1's realized-spread machinery, reused). The decomposition matters twice for the Lab:

- **Measurement**: a "market probability" sampled mid-reversion (immediately after a large trade in a thin book) is contaminated by temporary impact. A4 should specify sampling offsets relative to trades, or prefer quote-based over trade-based probabilities. ★
- **Attribution**: if Lab trades ever move prices, only the _temporary_ part is recoverable cost; the _permanent_ part is the market learning from the Lab — edge decay in real time (§19.5).

---

## 10. Order Flow

### 10.1 Signed volume and imbalance

**Signed (net) order flow** over a window is $\sum_t d_t , v_t$: buyer-initiated volume minus seller-initiated volume. **Cumulative order imbalance** is its running sum. Where trade initiator flags are not provided by the venue, direction is inferred: the **tick rule** (trade above prior trade = buy) or **Lee–Ready** (1991) ⚑ (compare trade price to prevailing mid; tick rule for mid-price trades). Classification accuracy in equities is imperfect (~85% for Lee–Ready in classic studies ⚑) and unknown for Kalshi's trade feed — the Lab must verify whether the API reports taker side explicitly, which would eliminate this entire error source ⚑★. If it does, weather markets offer _cleaner_ flow data than most equity research corpora.

### 10.2 Why order flow predicts prices

Three mechanisms, with different persistence signatures:

1. **Private-information revelation** (Kyle; Glosten–Milgrom): flow is correlated with the informed signal, so it forecasts the _permanent_ component. Impact does not revert.
2. **Inventory pressure**: flow pushes makers into positions they shade quotes to escape; predicts _transitory_ continuation then reversal.
3. **Autocorrelated demand**: order splitting and herding make flow predict flow, hence prices mechanically through impact ⚑.

Evans & Lyons (2002) ⚑ made order flow famous in FX: daily flow explains a large fraction of exchange-rate variation that macro variables cannot. The general lesson — **flow is the conduit through which dispersed information becomes price** — is Hayek operationalized. For the Lab, flow-based features are V2-era candidates _only after_ A1 fixes the inference framework: flow "signals" are the canonical overfitting playground, and every candidate must enter the Analysis Run Log denominator.

### 10.3 Order flow toxicity

**Toxicity** is flow's informativeness against the liquidity provider — flow is toxic when fills systematically precede adverse mid moves. VPIN (§16.5) is its best-known proxy. The concept matters to the Lab defensively: _Lab flow will itself be toxic_ if V3 strategies work, and platforms/makers adapt to toxic flow with wider quotes, smaller size, or (on some venues) exclusion from incentive programs ⚑. Edge persistence (§19.5) is partly a function of how visible the Lab's toxicity becomes.

---

## 11. Market Impact

### 11.1 Definitions

For an order of size $Q$: **temporary impact** is the execution-price concession that reverts after the order completes; **permanent impact** is the lasting revision of the mid. **Slippage** is realized execution price minus a benchmark (usually arrival mid). **Implementation shortfall** (Perold 1988 ⚑) is the full gap between paper-portfolio and actual P&L: spread + impact + delay cost + opportunity cost of unfilled quantity. It is the correct total-cost accounting identity and the object V3 backtests must debit — [[Edge_Detection]]'s statistical validation is necessary but not sufficient; an edge must survive shortfall, not just significance. ★

### 11.2 Empirical regularities

The equity/futures literature's headline finding is the **square-root law** ⚑: impact grows approximately as $\sigma \sqrt{Q/V}$ (volatility times root of size over daily volume), remarkably stable across markets and eras (Torre–Ferrari/BARRA ⚑; Almgren et al. 2005 ⚑; Tóth et al. 2011 ⚑). Whether it holds in thin discrete prediction markets is unknown — with 1¢ ticks and gap-ridden books, impact is likely _staircase-shaped in the small_ (zero until touch depth is exhausted, then jumping a gap) even if root-like in the large. For V1/V2 the practical tool is exact, not statistical: **walk the collected book** to compute deterministic worst-case cost for any hypothetical size (§5.2). Statistical impact models become relevant only if V3 sizes ever exceed touch depth routinely.

### 11.3 Execution scheduling

Almgren & Chriss (2000) ⚑ formalized the trade-off: execute fast (pay temporary impact) vs. slow (bear volatility risk on the unexecuted remainder), yielding optimal trajectories along an efficient frontier. The weather-market version has a twist: the "volatility risk" of waiting includes _scheduled information arrival_ — waiting across an NWS issuance is not diffusion risk but event risk. Any V3 execution policy should be indexed to the issuance calendar, not clock time.

### 11.4 Thin-book pathologies

In a book quoted 30/38 with 60 contracts at the ask and the next ask at 55¢, a 100-contract market buy pays a _17-cent_ concession on the tail of the order — a catastrophic, fully avoidable cost. Rules that follow: marketable limits only (§4.2); size ≤ a pre-registered fraction of visible depth; never leave unhedged market orders working across issuance times. These belong in the V3-gate execution spec; recorded here as the microstructure rationale.

---

## 12. Auction Theory and Exchange Design

### 12.1 The design space

An exchange chooses: **matching discipline** (continuous vs. periodic), **auction format** (double vs. one-sided), **priority rules** (price-time vs. pro-rata), **tick size**, **order-type menu**, **transparency regime** (pre/post-trade), and **intermediation** (designated makers vs. voluntary). Each choice reallocates surplus among fast traders, patient traders, and informed traders.

- **Continuous double auction (CDA)**: both sides post standing offers; trades execute the instant of a cross. Maximizes immediacy; rewards speed; exposes resting orders to sniping around news.
- **Call (batch) auctions**: orders accumulate; periodic uniform-price clearing. Concentrates liquidity, dampens the speed race (Budish, Cramton & Shim 2015 ⚑ argue frequent batch auctions eliminate latency arbitrage by design), improves price discovery per trade — at the cost of immediacy. Used at equity opens/closes, where the day's largest volumes now cluster ⚑.
- **Automated market makers (AMMs)**: algorithmic standing quotes from a pricing function — Hanson's LMSR (2003) ⚑★ for prediction markets (subsidized, always-quoting, loss-bounded by $b \ln n$), constant-product functions in decentralized finance ⚑. AMMs guarantee liquidity existence at the cost of parameterized, information-insensitive pricing (§22.3).

### 12.2 Why Kalshi's structure is what it is

Kalshi runs a continuous double auction with price-time priority and 1¢ ticks under CFTC designated-contract-market regulation ⚑★ (verify each clause against the current rulebook before citing as load-bearing). The design is intelligible as a set of forced and free choices: CFTC DCM rules push toward exchange-style CLOBs with open access and surveillance; continuous trading suits event contracts whose information arrives irregularly (a batch auction every hour would strand traders during a fast-moving afternoon of temperature observations); the coarse tick subsidizes makers (guaranteed minimum spread revenue per round trip) in exactly the thin markets that need quoting encouraged (§6.3). The costs of these choices — quantized probabilities, queue competition at the tick floor, no guaranteed liquidity — are the water the Lab swims in. The design point to internalize: **Kalshi's microstructure was chosen for regulatory fit and liquidity bootstrapping, not for probability-measurement fidelity.** The Lab's normalization layer (A4) exists to undo, where possible, the measurement distortions the trading design necessarily introduces.

---

## 13. Prediction Market Microstructure

### 13.1 The binary contract as an asset class

A binary contract paying 100¢ on event $E$ has price $p$ commonly read as "the market's probability of $E$." The reading requires care stacked three layers deep:

1. **Risk preferences and budget constraints**: prices equal risk-neutral, wealth-weighted aggregated beliefs; Manski (2006) ⚑ showed price can diverge substantially from mean belief under heterogeneity, while Wolfers & Zitzewitz (2006) ⚑ showed conditions under which price ≈ mean belief. The divergence is bounded but not zero.
2. **Microstructure wedge**: fees, spread, and tick quantization insert a dead zone around the efficient price within which no arbitrage force operates. A contract "worth" 71.4¢ can trade 70/72 indefinitely. The Lab's divergence metric Δ must exceed this dead zone before it is even _mechanically_ meaningful — prior to any statistical validation ([[Edge_Detection]]'s Δ ≠ edge, with a microstructure floor beneath the statistical one). ★
3. **Which price** (§3.1): bid, ask, mid, micro, last — each is a different functional of the book.

### 13.2 Liquidity dynamics over the contract lifecycle

Weather brackets follow a characteristic arc: **listing** (empty or maker-seeded book, wide) → **dormancy** (days out; low attention; stale quotes drifting on scheduled forecast updates) → **activation** (final ~24–48h; forecast uncertainty collapsing; volume arriving) → **endgame** (observation day; intraday temperatures partially reveal the outcome; brackets die sequentially as the running max forecloses them) → **settlement** (CLI publication; F1 governs what "the outcome" even is). Liquidity, spread, depth, and informed-flow intensity are all _functions of lifecycle phase_, and pooling snapshots across phases without conditioning is a category error — the microstructure version of pooling forecasts across lead times in [[Forecast_Verification]].

### 13.3 Volatility is uncertainty resolution, not diffusion

A binary price is a martingale probability: its instantaneous variance is maximal near 50¢ and vanishes toward 0/100, and its _total_ remaining variance is exactly the remaining uncertainty about the event. Late-lifecycle brackets on days with a clear forecast are near-degenerate (1¢/99¢) with almost nothing to discover; the same bracket on a knife-edge day is violently volatile into the afternoon max. Any volatility-derived feature must be conditioned on price level and time-to-settlement or it measures the calendar, not the market.

### 13.4 Expiration and settlement effects

As settlement approaches: makers' inventory horizon shrinks (§7.4.2) → spreads widen or books empty precisely as retail attention peaks; partial revelation through realized intraday temperatures makes "informed" trading nearly mechanical (whoever watches observations fastest); and the settlement referent — the **CLI product, not raw METAR** (F1) — introduces its own microstructure: a bracket can be _observationally decided_ but not _officially settled_, and the residual (CLI correction risk, rounding conventions ⚑ at bracket boundaries — the flagged NWS rounding question) supports small but real prices where naive analysis expects 0/100. Late-day prices of 2¢ for "impossible" brackets may be rational pricing of settlement-procedure risk, not free money. ★

### 13.5 Forecast convergence

The empirical signature of a healthy prediction market is prices converging toward extremes as evidence accumulates, tracking the objective posterior. The Lab's V2 comparison — NWS-derived probability path vs. market price path over the same horizon — is a _relative convergence study_: who moves first, who overshoots, who mean-reverts. Microstructure contributes the null model: quote-revision latency, dead zones, and lifecycle liquidity determine how much path divergence is _mechanically expected under zero informational difference_. Divergence must beat that null before Bayesian/statistical machinery even engages.

### 13.6 Structural differences from equities — consolidated

|Dimension|Equities|Prediction markets (Kalshi weather)|
|---|---|---|
|Terminal value|none (going concern)|0/100 at known date|
|Hedging venue|rich (futures, options, ETFs)|none / adjacent brackets only|
|Information|private + public, unscheduled|public, scheduled (NWS cycle)|
|Informed trader|insider, superior analyst|faster/better processor of public data|
|Uninformed flow|hedging, indexing, liquidity needs|recreation, opinion|
|Price meaning|discounted cash flows|(approximately) a probability|
|Volatility|~diffusive|uncertainty-resolution, state-dependent|
|Tick/price|~1bp–10bp relative|1–50%+ relative near boundaries|
|Maker of last resort|designated programs common|voluntary; empty books admissible|

Every row is a reason equity-calibrated intuitions and models must be re-derived, not imported, for this asset class.

---

## 14. Kalshi Applications

> [!warning] Platform-fact discipline Everything in this section describing Kalshi's current mechanics is E4 **and** perishable. Fee formulas ⚑★, tick and price bounds ⚑, matching/priority rules ⚑, maker programs ⚑, API field semantics ⚑ must each be verified against the live rulebook/API docs and snapshot-archived (per the standing Kalshi fee-formula flag) before entering any registration, ADR, or EV computation.

### 14.1 Bid/ask dynamics in weather brackets

Working hypotheses for V1 data to confirm or kill, stated pre-collection: (a) spreads widen in the minutes before scheduled NWS issuance windows and compress after (maker information risk, §5.4); (b) overnight books are wide/stale with quote revisions clustered at forecast update times; (c) touch depth is thin absolutely (tens–hundreds of contracts) with large gaps behind the touch; (d) YES/NO book consolidation makes one side's apparent depth partially a mirror of the other's (§4.4). Each is checkable from snapshots alone — cheap, pre-registerable V1-era descriptive analyses that double as data-quality audits.

### 14.2 Liquidity cycles

Compound seasonality expected: intraday (U.S. waking hours; issuance times; afternoon observation window for daily-high contracts), weekly (weekend retail attention), and lifecycle (§13.2). For the Lab's _measurement_ mission the cycle dictates sampling design: comparing an NWS-derived probability against a 4 a.m. stale quote and against a post-issuance active quote are different experiments. A4 should either fix comparison timestamps relative to the issuance calendar or record liquidity covariates (spread, depth, staleness age) with every comparison so conditioning is possible ex post. ★

### 14.3 Settlement mechanics and the F1 chain

The full chain: station observations → WFO processing → **CLI Daily Climate Report** → Kalshi settlement determination per rulebook. Microstructure consequences: (i) settlement risk premium in late prices (§13.4); (ii) the market's effective information set includes _anticipation of the CLI value_, not the METAR feed the Lab might naively collect — so market/Lab divergence near settlement can reflect referent mismatch, not belief mismatch (F1's validity risk restated as a divergence-measurement risk); (iii) any historical settlement-price analysis must align to CLI publication timestamps, not observation-day end.

### 14.4 Market maker behavior and weather peculiarities

Weather markets are a strange habitat for makers: information arrival is _scheduled and public_ (less classic adverse selection) but _fast and decisive_ when it arrives (observation afternoons resolve brackets in hours). Rational maker behavior is therefore _punctuated_: tight and deep in quiet regimes, absent around information. If Kalshi maker-program participants have quoting obligations ⚑, their fingerprints (constant-width quotes, symmetric size, instant re-centering after trades) should be visually identifiable in the book data and worth tagging: program quotes and organic quotes carry different information (§7.2).

### 14.5 Fees as microstructure

Kalshi's fee schedule ⚑★ (the standing verification flag; a commonly cited form is a per-contract fee scaling with $p(1-p)$ ⚑ — _verify, do not assume_) directly determines the no-arbitrage dead zone (§13.1.2) and hence the minimum exploitable divergence. The Lab's EV arithmetic must debit fees at the _marginal_ rate for the executed side and size; the dead-zone width $\approx$ spread + 2×fees + tick effects should be computed and stored per comparison so V2 divergence analyses can distinguish "inside the dead zone" (unactionable by construction) from "outside it" (candidate edge). This quantity deserves a registered name and formula in A4. ★

---

## 15. Behavioral Effects

### 15.1 The behavioral inventory

- **Herding**: trading with observed flow rather than private signals; rational when others plausibly know more (information cascades, Bikhchandani, Hirshleifer & Welch 1992 ⚑), pathological when the cascade rests on nothing. In prediction markets, herding on the _price itself_ — treating price as evidence and updating toward it — is self-reinforcing and can detach price from the forecast data.
- **Overreaction / underreaction**: prices moving too far on salient news then reverting, or too little on unglamorous news then drifting (De Bondt & Thaler 1985 ⚑; post-announcement drift literature ⚑). Weather translation: dramatic model-run swings may be overweighted; quiet monotone forecast revisions underweighted — testable against the NWS record.
- **Anchoring**: insufficient adjustment from a salient reference. Candidate anchors in weather brackets: yesterday's price, round-number prices, the previous forecast, climatological normals.
- **Favorite–longshot bias** ★: the best-documented prediction-market miscalibration — longshots overpriced, favorites underpriced (racetrack: Griffith 1949 ⚑, Thaler & Ziemba 1988 ⚑; prediction markets: Snowberg & Wolfers 2010 ⚑, who dissect risk-love vs. probability-misperception explanations). For Kalshi weather brackets this predicts systematic overpricing of tail brackets (extreme temperatures) — but §6.3's tick quantization and §13.4's settlement-risk premia produce _observationally similar_ patterns near the boundaries. Disentangling behavioral longshot bias from mechanical price floors is a genuinely publishable-grade V2 question and a warning against reading raw boundary miscalibration as free edge. ★
- **Noise trading and liquidity shocks**: Black (1986) ⚑ — noise traders make markets liquid _and_ prices noisy; De Long et al. (1990) ⚑ — noise-trader risk deters arbitrage, letting mispricings persist. Attention-driven flow surges (a heat wave making national news) are liquidity shocks that both create mispricing and supply the liquidity to trade against it.

### 15.2 When behavioral effects create edge

Three conditions must hold jointly: (1) a _persistent, mechanism-backed_ bias (not a fitted artifact — the [[Machine_Learning]] trust principle: trust the finding in proportion to the verifiability of its mechanism); (2) **limits to arbitrage** protecting it (fees, dead zones, position limits ⚑, unhedgeability — prediction markets are rich in these, which is precisely why documented biases persist there); (3) the Lab on the _right side of the limit_ — a bias protected by costs the Lab also pays is a museum piece, not an edge. Every behavioral edge hypothesis entering V2 must state which limit-to-arbitrage protects it and why that limit binds others but not the Lab.

---

## 16. Quantitative Measures

Implementation-oriented catalog. All are book/tape functionals; all inherit the collection requirements of §18.1; none is an edge — they are _state descriptors_ and _candidate conditioning variables_ whose inferential use is governed by A1 and logged in the Analysis Run Log.

### 16.1 Spread measures

Quoted, effective, realized (§6.1). Report in cents _and_ as a fraction of $\min(p, 100-p)$ — relative cost near boundaries is the binding version. Effective spread requires trade-side attribution (§10.1).

### 16.2 Depth and imbalance

Depth at touch; cumulative depth within $k$ cents; **order book imbalance** $I = (Q_b - Q_a)/(Q_b + Q_a)$ — in equities a robust short-horizon direction predictor ⚑; unknown here; cheap to compute from snapshots.

### 16.3 Kyle's λ

Regression slope of price change on signed volume over a window: $\Delta p_t = \lambda , q_t + \epsilon_t$. Estimates depth's inverse; requires enough trades per window, which thin markets may not supply — expect λ estimable only in active lifecycle phases, and treat window-selection as a pre-registered choice (multiplicity discipline).

### 16.4 Amihud illiquidity and the Roll measure

**Amihud (2002)** ⚑: $ILLIQ = \text{mean}(|r_t| / \text{volume}_t)$ — price move per dollar traded; a coarse, robust λ proxy usable from daily aggregates. **Roll (1984)** ⚑: effective spread $\approx 2\sqrt{-\text{Cov}(\Delta p_t, \Delta p_{t-1})}$ from trade prices alone — historically vital when quotes were unrecorded; for the Lab, mainly a _cross-check_ on directly observed spreads and a reminder that bounce-induced negative autocorrelation is spread, not signal (§3.3). Fails (positive autocovariance) exactly when information dominates — informative failure.

- **Realized volatility**: sum of squared mid returns over fixed intervals; use _quote mids_, never trade prices, to avoid bounce contamination; condition per §13.3.

### 16.5 VPIN

Easley, López de Prado & O'Hara (2012) ⚑: bucket volume into equal-size bins, estimate per-bucket signed imbalance (bulk classification), VPIN = mean absolute imbalance over a rolling window — a real-time toxicity proxy. Contested: Andersen & Bondarenko (2014) ⚑ argue VPIN is largely a repackaging of volume/volatility and did not predict the Flash Crash out-of-sample. Lab stance: interesting _descriptive_ covariate for maker-behavior studies (§7.2); nowhere near load-bearing; the controversy itself is the lesson — microstructure metrics ship with contested empirics, and E-grading applies to metrics, not just citations.

### 16.6 Implementation notes

(1) Every metric stored with: formula version, window, price-object used (§3.1), and book snapshot ID — metrics without provenance are unfalsifiable. (2) Compute in **event time** (per snapshot, per trade, per issuance epoch) as well as clock time; weather-market activity is too lumpy for clock-time stationarity. (3) The metric layer belongs _downstream_ of raw storage: store books and trades raw and append-only; derive metrics reproducibly; never store only derived values (Engineering Playbook: raw is sacred).

---

## 17. Statistical Models

### 17.1 The Kyle model (1985) ★

One risk-neutral informed trader knows terminal value $v \sim N(p_0, \Sigma_0)$; noise traders submit $u \sim N(0, \sigma_u^2)$; a competitive market maker observes only total flow $y = x + u$ and prices $p = E[v \mid y]$. Linear equilibrium: informed demand $x = \beta (v - p_0)$, pricing rule $p = p_0 + \lambda y$, with $\lambda = \frac{1}{2}\sqrt{\Sigma_0}/\sigma_u$. Readings: depth is _earned by noise flow_ ($\lambda \propto 1/\sigma_u$ — more uninformed volume, deeper markets); the insider trades _gradually_, embedding information into flow over time; half the insider's information reaches price per auction round (in the continuous version, information is fully incorporated only at the horizon). Limitations: single insider, exogenous noise, no spread (price is single), risk neutrality. Lab relevance: λ as a depth statistic (§16.3); the gradualism prediction underlying §8.3's issuance-window flow analysis; and the sobering identity that _the Lab's own V3 flow, if informed, pays λ on itself_.

### 17.2 Glosten–Milgrom (1985) ★

Sequential traders arrive one at a time; a fraction $\mu$ are informed (know $v \in {0, 100}$), the rest trade randomly; a zero-profit maker posts bid/ask as conditional expectations: $a = E[v \mid \text{buy}]$, $b = E[v \mid \text{sell}]$. The spread is pure adverse selection; each trade triggers a Bayesian update; quotes form a martingale converging to $v$. **This is nearly a literal model of a Kalshi bracket**: binary $v$, sequential anonymous flow, quotes as posteriors. Three transferable results: (i) spread widens in $\mu$ and in the maker's uncertainty about $v$ — predicting spread peaks when uncertainty is high _and_ informed share is high (pre-issuance, observation afternoons); (ii) prices converge to truth as trades accumulate — the market _learns_, and the speed is governed by informed share; (iii) if $\mu$ is too high, the market **breaks** — no spread yields zero profit and quoting stops: the empty weather book at 3 a.m. is Glosten–Milgrom's no-trade corner, realized. Limitations: no inventory, unit trade size, exogenous informed share, myopic maker.

### 17.3 The Roll model (1984)

Efficient price random-walks; trades hit bid or ask with equal probability; observed $\Delta p$ inherits negative first-order autocovariance $-s^2/4$ from bounce, giving the spread estimator of §16.4. Value is diagnostic, not structural.

### 17.4 Zero-intelligence models

Gode & Sunder (1993) ⚑: budget-constrained _random_ traders in a CDA achieve near-full allocative efficiency — market _structure_, not trader rationality, produces much of what looks like intelligent pricing. Farmer, Patelli & Zovko (2005) ⚑ extend to LOB statistics. Lab use: zero-intelligence simulation of a Kalshi-like book (1¢ ticks, thin Poisson flow, binary settlement) is the correct **null model generator** for microstructure statistics — before claiming a book pattern is informative, show it doesn't arise from structured randomness. This is the microstructure sibling of climatology baselines in [[Forecast_Verification]]. ★

### 17.5 Order arrival models: Poisson to Hawkes

Baseline: independent Poisson arrivals per order type (the Garman tradition). Reality: order flow is self-exciting — arrivals raise near-future arrival intensity. **Hawkes processes** ⚑ model intensity $\lambda(t) = \mu + \sum_{t_i < t} \phi(t - t_i)$ with kernel $\phi$; widely fit to trades/quotes ⚑ (Bacry, Mastromatteo & Muzy 2015 review ⚑). Weather-market twist: apparent self-excitation may be _common causation by scheduled issuances_ — a Hawkes fit ignoring the NWS calendar will hallucinate contagion. Any arrival modeling must include exogenous issuance covariates (a marked/nonhomogeneous specification) or it misattributes the clock to the crowd.

### 17.6 Model-selection posture

All these models are _lenses_, not truth: Kyle isolates strategic informed trading; Glosten–Milgrom isolates learning and spreads; Roll isolates bounce; zero-intelligence isolates structure; Hawkes isolates clustering. The Lab's standing rule applies: adopt the simplest model that generates the observed statistic; register the choice; let A1 govern any inference built on it.

---

## 18. Engineering Applications

### 18.1 Data collection

Microstructure dictates the collection contract:

1. **Books, not just trades** (§3.3): snapshot bid/ask/depth at registered cadence; trades alone miss most discovery in thin markets.
2. **Depth, not just touch**: microprice, imbalance, walk-the-book costs, and maker-behavior features all require levels (A3's sufficiency question answered in the affirmative from theory).
3. **Event-aligned sampling**: cadence should densify around the NWS issuance calendar and the afternoon observation window; uniform clock sampling undersamples exactly the informative epochs (§14.2).
4. **Dual timestamps** (exchange time, ingest time) — already a Lab storage invariant; microstructure adds the reason: latency _is_ a variable of study (§19.2), so the collection system must measure its own delay.
5. **Explicit null states**: no-bid, no-ask, empty book, halted — first-class enum values, never zeros or NaNs (§5.4).
6. **Taker-side flags**: verify and store if the API provides them (§10.1) ⚑★.

### 18.2 Storage

Raw, append-only, immutably timestamped (existing SQLite WAL design conforms); books stored as full snapshots (thin books make deltas a false economy and snapshots trivially auditable — gap audits per the V1 exit gate operate on snapshot sequences); derived metrics in separate, versioned, regenerable tables keyed to snapshot IDs (§16.6).

### 18.3 Feature engineering

Microstructure features (spread, depth, imbalance, staleness age, issuance-epoch phase, lifecycle phase) serve V2 twice: as _conditioning variables_ for divergence measurement (is Δ concentrated in stale/illiquid states, i.e., unactionable?) and as _candidate signals_ (each entering the multiplicity denominator). The trust principle governs throughout: prefer features whose mechanism is stated ex ante (this document is the mechanism library) over features discovered by search.

### 18.4 Edge detection interface

This document supplies [[Edge_Detection]] with its microstructure floor: Δ must exceed dead-zone width (§14.5) at the _executable_ price (relevant side of the touch, at available depth, net of fees) before statistical machinery engages. A divergence measured against mids in stale books is a measurement artifact until proven otherwise. ★

### 18.5 Backtesting

Non-negotiables inherited from this document: fill logic must respect the book (no fills at mid; passive fills require price crossed _through_, plus a queue model or a registered conservative assumption); costs debited as implementation shortfall (§11.1); no lookahead across issuance timestamps; results reported per liquidity regime, not pooled (§13.2). A backtest violating any of these is not evidence — it does not even reach E4.

### 18.6 Execution (V3-gated)

Marketable limits only; size capped at registered fraction of visible depth; execution windows indexed to the issuance calendar; leak-aware order placement (§8.4); every fill logged with the full book context that motivated it, so realized slippage is auditable against the pre-trade estimate. These are candidate contents for a future execution spec, not current authority.

---

## 19. Prediction Market Edge

Where microstructure says edge is _structurally most likely_ in Kalshi weather markets — hypotheses for V2, not conclusions.

### 19.1 Stale prices

Quotes persist until revised; in low-attention regimes, information (a new forecast issuance) can be public while quotes still reflect the old state. Staleness edge is the cleanest structurally: the information is public and verifiable, the mispricing is time-boxed, and the mechanism is undeniable. Its enemies: dead-zone costs (a stale quote must be stale by _more_ than spread+fees), latent liquidity (the stale quote may be a trap tended by a fast maker), and competition (staleness edges decay first, §19.5). Measurement: quote-revision latency distributions after issuances — V1 data suffices. ★

### 19.2 Information latency

The generalization of staleness: the market as a whole reprices public information with a lag distribution. The Lab's advantage candidate is _pipeline speed and synthesis quality on NWS products_ — an informed-trader position acquired entirely from public data (§7.4.4). The latency edge exists iff the Lab's probability update completes inside the market's repricing lag _and_ the residual divergence clears the dead zone. Both clauses are measurable before any trade: this is the flagship V2 experiment design this document exists to support.

### 19.3 Thin liquidity — both faces

Thin books create mispricings (small flow moves price; no arbitrageur corrects a 6¢-wide market) _and_ cap extraction (position size bounded by the same thinness; entering moves the price against you). Formally: edge per contract may be large where total extractable EV is small. [[Kelly_Criterion]] sizing must use _impact-adjusted_ edge (walk-the-book prices, not touch), and the V3 gate should require minimum-depth conditions, not just minimum-divergence conditions. The Kelly asymmetry principle lands here with force: thin-book impact uncertainty is an unresolved uncertainty, and every unresolved uncertainty pushes size down.

### 19.4 Structural inefficiency niches

Beyond latency: (i) boundary phenomena — favorite–longshot bias vs. tick floors vs. settlement premia (§15.1, §13.4) — exploitable only after the three are disentangled; (ii) cross-bracket coherence — bracket sets must satisfy probability axioms (sum-to-one, monotone CDFs); incoherent bracket pricing is an internal arbitrage requiring no forecast at all, just simultaneous execution in thin books (execution risk is the entire risk); (iii) referent mismatches — participants trading raw observations against a CLI-settled contract (F1) are systematically wrong in a way a correctly-referenced forecaster can price.

### 19.5 Edge persistence

Edges decay through: crowding (others find it), adaptation (makers reprice against toxic flow, §10.3), and structural change (platform rule amendments — another reason rulebook facts are snapshot-archived with dates). Persistence is strongest where limits to arbitrage are structural (unhedgeability, position limits, fee floors) and weakest where the edge is pure speed. The Lab's monitoring obligation: edges are populations too — an edge validated on months 1–3 is a claim about a regime, graded only against continued out-of-sample performance, never assumed stationary. The pre-registration machinery (recalibrated forecaster = new forecaster) applies to strategies verbatim.

---

## 20. Common Misconceptions

1. **"Tight spreads imply efficiency."** Tightness is one liquidity dimension (§5.1) and can coexist with trivial depth and stale information. A 1¢-wide market with 20 contracts a side, unrevised since the last issuance, is tight and wrong. Efficiency claims require price _accuracy_ evidence (calibration against outcomes — [[Forecast_Verification]] machinery), not spread statistics.
2. **"Volume equals liquidity."** Volume is realized trading; liquidity is the _capacity_ to trade without impact. Settlement-day panic prints huge volume into terrible liquidity. The book, not the tape, measures liquidity.
3. **"Prices always reflect truth."** Prices reflect the marginal expressed, fee-burdened, tick-quantized, budget-constrained opinion within a dead zone (§13.1). Hayek is a tendency claim with mechanism-dependent failure modes, not a theorem. The Lab's entire premise is that the reflection is imperfect _measurably often_; the null hypothesis discipline is that it is imperfect _less often than it looks_.
4. **"Market makers predict outcomes."** Makers predict _flow_ and price _risk_; their quotes are regret-proofed conditional expectations (§8.2), not forecasts they would defend. A maker quoting 30/38 is not asserting p ∈ [0.30, 0.38]; they are asserting that quoting there is profitable against expected counterparties.
5. **"Order flow equals information."** Flow mixes information, inventory rebalancing, noise, and mechanical rebalances (§10.2); its informational content is regime-dependent and partly an artifact of classification error (§10.1). Flow is _evidence about_ information, requiring a model to extract — never a synonym.
6. **"Wide spreads are free money for liquidity providers."** Realized vs. effective spread (§6.1): wide quotes may be actuarially fair against the informed flow they anticipate. If quoting inside the spread were free money, someone faster would already be doing it — the absence of that someone is information.
7. **"The mid is the market's probability."** The mid is one functional of one snapshot (§3.1), unbiased only under symmetric liquidity provision, quantized by ticks, and undefined in one-sided books. "The market's probability" is a _modeling choice_ the Lab must register (A4), not a field the API returns.

---

## 21. Research Lab Integration

- **[[Probability]]** — supplies the objects markets price. Microstructure adds: the market's probability is _implicit, interval-valued (bid/ask), and mechanism-mediated_; extracting a point probability from a book is an estimation problem with registered conventions, not a lookup.
- **[[Bayesian_Statistics]]** — Glosten–Milgrom quotes are literal Bayesian posteriors; the market is a sequential updating engine whose priors and likelihoods are hidden. The Lab's comparison of its own posterior path against the market's quote path is a comparison of two Bayesian learners with different data and different loss functions.
- **[[Prediction_Markets]]** — that document explains _why_ prediction markets aggregate information; this one explains _how_, and where the how breaks (dead zones, thin books, no-trade corners). Institutional claims live there; mechanical claims live here.
- **[[Expected_Value]]** — every EV computed against a market price is conditional on the price object chosen (§3.1), the executable side and depth (§18.4), and fees (§14.5). Microstructure is where EV's "epistemology is the entire project" principle meets the tape: the arithmetic inputs are themselves modeled quantities.
- **[[Kelly_Criterion]]** — Kelly needs edge and odds; microstructure corrupts both (impact-adjusted edge, §19.3; executable rather than quoted odds). The Kelly asymmetry converts every microstructure uncertainty into a sizing haircut. The [[Log_Score_and_Kelly_Identity]] spine (log-score edge = KL advantage = growth rate) is stated against _frictionless_ odds; the friction wedge is this document's contribution to that identity's honest application.
- **[[Edge_Detection]]** — Δ ≠ edge acquires a second, prior clause: Δ ≠ executable Δ. The microstructure floor (dead zone at executable prices) precedes the statistical floor (A1 inference). Both must be cleared, in that order.
- **[[Forecast_Verification]]** — market prices, once normalized (A4), are forecasts and enter the verification machinery like any other forecaster; tick quantization and staleness are that forecaster's measurement-error model (§6.3). Scoring the market without modeling its microstructure error is scoring a corrupted transcription.
- **[[Machine_Learning]]** — microstructure features are high-multiplicity, regime-dependent, and mechanism-rich: the ideal habitat for both genuine signals and overfitting. The trust principle plus the Analysis Run Log denominator are the containment vessel; this document is the mechanism library that lets features be proposed ex ante rather than mined.
- **Market Normalization (A4)** — this document is effectively A4's requirements dossier: price-object tagging (§3.1), dead-zone formula (§14.5), sampling relative to issuances (§14.2), null-state semantics (§5.4), YES/NO convention (§4.4), realized-spread horizon (§6.1), quantization treatment (§6.3). Each is listed in §23 as a candidate pre-commitment.

---

## 22. Current Research Frontiers

- **AI/RL market making**: reinforcement-learning agents over Avellaneda–Stoikov-style state spaces ⚑; open problems include non-stationarity, adversarial flow, and sim-to-real transfer (zero-intelligence and Hawkes simulators as gyms, §17.4–17.5). Lab relevance: distant, but RL-quoted markets would change the _meaning_ of observed quotes.
- **Prediction market efficiency at scale**: the 2024+ surge of event-market volume (election cycles) ⚑ is generating new empirical literature on calibration, longshot bias, and manipulation in real-money markets — directly reusable methods for the Lab's V2 designs; monitor and verify before import.
- **AMMs and hybrid mechanisms**: LMSR (Hanson 2003 ⚑★) and its liquidity-sensitive successors ⚑; constant-function DeFi makers and loss-versus-rebalancing analyses ⚑; hybrid CLOB+AMM designs. Open question with Lab bite: what mechanism _optimally elicits_ probabilities in thin markets — the measurement-fidelity question Kalshi's CDA answers only incidentally (§12.2).
- **Information aggregation theory**: when do markets beat the best individual forecaster, and when does the crowd merely average its errors ⚑ — the theoretical frame for the Lab's central empirical question (market vs. NWS-derived probability).
- **High-frequency event markets**: as event exchanges add faster products, equity-style latency arms races arrive with them; frequent-batch-auction arguments (Budish et al. ⚑) apply with extra force to markets whose information is scheduled.
- **Microstructure + ML**: deep order-book models ⚑, generative book simulators, flow-toxicity learning — all upstream of the Lab's needs but supplying the null-model and feature literature V2 will cite.

Open questions the Lab is unusually well-positioned to answer in miniature: How fast do thin scheduled-information markets reprice public forecasts? Is boundary miscalibration behavioral, mechanical, or settlement-rational? Does depth-weighted microprice beat mid as a probability extractor in tick-constrained books? Each is registrable, small-N honest, and valuable independent of trading.

---

## 23. Engineering Takeaways

Candidate takeaways for absorption into A-series documents (per governance freeze: stated here as candidates, not directives; ratification authority remains with the Architect and the A-series process).

**Measurement (V1-relevant):**

1. Snapshot books with depth, event-aligned cadence, dual timestamps, explicit null states (§18.1). The tape alone is insufficient by construction.
2. Tag every stored market probability with its price object and book context (§3.1); "price" is not a column, it is a decision.
3. Represent no-bid/no-ask/empty/halted as first-class states (§5.4).
4. Verify and snapshot platform facts before use: fee formula ★, tick/bounds, matching discipline, taker-side flags ★, hidden-order support, maker programs, YES/NO book convention (§14 header).

**Analysis (V2-relevant):** 5. Compute and store dead-zone width per comparison; classify divergences as inside/outside before statistics engage (§14.5, §18.4). 6. Condition every market-side analysis on lifecycle phase and liquidity regime; never pool (§13.2). 7. Treat tick quantization as measurement error in market calibration studies, especially near boundaries (§6.3). 8. Use zero-intelligence simulation as the null generator for book-pattern claims (§17.4). 9. Include the NWS issuance calendar as an exogenous covariate in any flow/arrival model (§17.5). 10. Log every microstructure feature evaluated into the Analysis Run Log denominator; the mechanism library (this document) licenses proposing features ex ante, not exempting them from multiplicity accounting.

**Execution (V3-gated):** 11. Marketable limits only; size ≤ registered fraction of visible depth; windows indexed to the issuance calendar (§11.4, §18.6). 12. Backtests: book-respecting fills, implementation-shortfall costs, no lookahead across issuances, per-regime reporting (§18.5). 13. Impact-adjusted edge into Kelly; unresolved microstructure uncertainty is a sizing haircut, always downward (§19.3).

**Common mistakes to not make:** volatility from trade prices (bounce); probabilities from mids in one-sided or stale books; spread as maker profit; flow as information; pooling across lifecycle; backtest fills at mid; treating platform parameters as stable facts rather than dated snapshots.

---

## 24. Annotated Bibliography

All entries E4; ⚑ implicit on every bibliographic detail; ★ marks the priority verification tier (directly feeds A-series decisions or V2/V3 designs). Ranked by expected long-term importance **to this Lab**, not to the field.

### Tier 1 — Load-bearing for Lab design ★

1. **Glosten, L. & Milgrom, P. (1985), "Bid, Ask and Transaction Prices in a Specialist Market with Heterogeneously Informed Traders," _Journal of Financial Economics_.** ★ The sequential-trade adverse-selection model; near-literal model of a binary contract book (§17.2). The single most transferable theory object in this document.
2. **Kyle, A. (1985), "Continuous Auctions and Insider Trading," _Econometrica_.** ★ Strategic informed trading, λ, depth, gradual information incorporation (§17.1). Foundation of impact measurement and the Lab's self-impact reasoning.
3. **Wolfers, J. & Zitzewitz, E. (2004), "Prediction Markets," _Journal of Economic Perspectives_; and (2006), "Interpreting Prediction Market Prices as Probabilities," NBER WP.** ★ The price↔probability wedge (§13.1); prerequisite reading for A4's normalization decisions.
4. **Hanson, R. (2003), "Combinatorial Information Market Design," _Information Systems Frontiers_ (LMSR).** ★ The canonical prediction-market AMM; the comparison point for understanding what Kalshi's CDA does and does not elicit (§12, §22).
5. **Snowberg, E. & Wolfers, J. (2010), "Explaining the Favorite–Longshot Bias," _Journal of Political Economy_.** ★ The boundary-bias decomposition the Lab must replicate-or-refute before touching tail brackets (§15.1, §19.4).
6. **Harris, L. (2003), _Trading and Exchanges: Market Microstructure for Practitioners_, Oxford UP.** The taxonomy source (trader types, order types, structures); the correct first full read for the Architect; §4–§7 of this document compress its relevant half.

### Tier 2 — Core theory and empirics

7. **O'Hara, M. (1995), _Market Microstructure Theory_, Blackwell.** The theoretical consolidation; Kyle and Glosten–Milgrom in context with their descendants.
8. **Hasbrouck, J. (2007), _Empirical Market Microstructure_, Oxford UP.** The econometric toolkit: efficient-price decompositions, information shares, VAR of quotes and trades; governs how §16's metrics become inference.
9. **Madhavan, A. (2000), "Market Microstructure: A Survey," _Journal of Financial Markets_.** The field map; efficient orientation layer over Tiers 1–2.
10. **Roll, R. (1984), "A Simple Implicit Measure of the Effective Bid-Ask Spread," _Journal of Finance_.** Bounce, spread estimation, and the reason trade-price volatility lies (§16.4, §17.3).
11. **Amihud, Y. (2002), "Illiquidity and Stock Returns," _Journal of Financial Economics_.** The robust coarse illiquidity proxy (§16.4).
12. **Huang, R. & Stoll, H. (1997), "The Components of the Bid-Ask Spread," _Review of Financial Studies_.** Spread decomposition methodology (§6.2) — the template for the Lab's own decomposition study.
13. **Avellaneda, M. & Stoikov, S. (2008), "High-Frequency Trading in a Limit Order Book," _Quantitative Finance_.** The reference market-making architecture; needed to _read_ maker behavior even if never to enact it (§7).
14. **Almgren, R. & Chriss, N. (2000), "Optimal Execution of Portfolio Transactions," _Journal of Risk_; Perold, A. (1988), "The Implementation Shortfall," _Journal of Portfolio Management_.** Execution cost accounting and scheduling (§11); shortfall is the backtest debit line.

### Tier 3 — Prediction markets and information aggregation

15. **Manski, C. (2006), "Interpreting the Predictions of Prediction Markets," _Economics Letters_.** The belief-heterogeneity bound; the caution against reading price as mean belief (§13.1).
16. **Arrow, K. et al. (2008), "The Promise of Prediction Markets," _Science_.** The institutional charter statement; context for [[Prediction_Markets]].
17. **Forsythe, R., Nelson, F., Neumann, G. & Wright, J. (1992), "Anatomy of an Experimental Political Stock Market," _American Economic Review_ (Iowa Electronic Markets).** ⚑ The founding empirical accuracy studies; methods ancestor of the Lab's V2 comparisons.
18. **Berg, J., Forsythe, R., Nelson, F. & Rietz, T. (2008), "Results from a Dozen Years of Election Futures Markets Research," _Handbook of Experimental Economics Results_.** ⚑ Long-run market-vs-poll evidence; the market-vs-expert-forecast comparison template.
19. **Thaler, R. & Ziemba, W. (1988), "Anomalies: Parimutuel Betting Markets," _Journal of Economic Perspectives_.** Longshot-bias canon; historical depth for §15.
20. **Milgrom, P. & Stokey, N. (1982), "Information, Trade and Common Knowledge," _Journal of Economic Theory_.** The no-trade theorem: why every trade needs a non-informational reason to exist (§8.1) — the question to ask before every V3 fill.

### Tier 4 — Modern quantitative and flow literature

21. **Easley, D., Kiefer, N., O'Hara, M. & Paperman, J. (1996), "Liquidity, Information, and Infrequently Traded Stocks," _Journal of Finance_ (PIN); Easley, D., López de Prado, M. & O'Hara, M. (2012), "Flow Toxicity and Liquidity in a High-Frequency World," _RFS_ (VPIN); Andersen, T. & Bondarenko, O. (2014), "VPIN and the Flash Crash," _Journal of Financial Markets_ (rebuttal).** Read as a trilogy: metric, extension, contestation — an object lesson in metric epistemics (§16.5).
22. **Evans, M. & Lyons, R. (2002), "Order Flow and Exchange Rate Dynamics," _Journal of Political Economy_.** Flow as the information conduit, empirically at its strongest (§10.2).
23. **Lee, C. & Ready, M. (1991), "Inferring Trade Direction from Intraday Data," _Journal of Finance_.** Trade signing; needed only if Kalshi's feed lacks taker flags (§10.1) ⚑★ — verify the feed first.
24. **Gode, D. & Sunder, S. (1993), "Allocative Efficiency of Markets with Zero-Intelligence Traders," _Journal of Political Economy_.** The null-model charter (§17.4) ★.
25. **Budish, E., Cramton, P. & Shim, J. (2015), "The High-Frequency Trading Arms Race," _Quarterly Journal of Economics_.** Mechanism-design critique of continuous trading; frames §12's design trade-offs.
26. **Brunnermeier, M. & Pedersen, L. (2009), "Market Liquidity and Funding Liquidity," _Review of Financial Studies_.** Liquidity spirals (§5.4); background, not load-bearing.
27. **Bacry, E., Mastromatteo, I. & Muzy, J.-F. (2015), "Hawkes Processes in Finance," _Market Microstructure and Liquidity_.** Arrival-model survey; consult only if V2 reaches flow modeling (§17.5).
28. **López de Prado, M. (2018), _Advances in Financial Machine Learning_, Wiley.** The microstructure↔ML bridge; read alongside [[Machine_Learning]]'s multiplicity discipline, which supersedes it where they conflict.
29. **Bouchaud, J.-P., Bonart, J., Donier, J. & Gould, M. (2018), _Trades, Quotes and Prices_, Cambridge UP.** ⚑ The modern empirical LOB synthesis (square-root law, book dynamics); the deepest single follow-up text for §11 and §16.
30. **Foucault, T., Pagano, M. & Röell, A. (2013), _Market Liquidity: Theory, Evidence, and Policy_, Oxford UP.** ⚑ Graduate-level integration of §5–§8; reference depth.

### Historical foundations (context tier)

31. **Bachelier, L. (1900), _Théorie de la spéculation_.** ⚑ The random-walk origin (§1.1).
32. **Hayek, F. (1945), "The Use of Knowledge in Society," _American Economic Review_.** The aggregation charter — and the claim the Lab exists to test locally rather than assume (§1.1).
33. **Demsetz, H. (1968), "The Cost of Transacting," _Quarterly Journal of Economics_.** The spread as the price of immediacy (§1.1).
34. **Garman, M. (1976), "Market Microstructure," _Journal of Financial Economics_.** The field's name and first inventory model.
35. **Black, F. (1986), "Noise," _Journal of Finance_.** Noise traders as the market's paradoxical foundation (§8.1, §15.1).

---

_End of document. Version 1. E4 pending Architect verification per Invariant 3. Wikilinks use underscore filename convention. Proposed conventions and takeaways (§3.1, §14.5, §23) are candidates for A4/A-series absorption, not directives._