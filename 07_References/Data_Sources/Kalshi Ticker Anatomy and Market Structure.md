### Title

Kalshi Ticker Anatomy and Market Structure

### Aliases

Kalshi Market Structure,Kalshi Reference

### Type

data-source-reference

### Vault_home

07_References/Data_Sources

### Status

E4 — AI-drafted v2 (full rewrite), pending Architect ratification

### Supersedes

v1 (2026-07-04, Milestone 1a field notes)

### Created

2026-07-15

### Verified_against_live_api

false

### Cross_links

[[Kalshi API]],[[Market Microstructure]],[[Prediction Markets]],[[Forecast Verification]],[[Edge Detection]],[[Effective Sample Size]],[[Kelly Criterion]],[[Proper Scoring Rules and Calibration - Technical Reference (V2)]],[[National Weather Service]]

> [!warning] Epistemic status — read before citing This document is **E4 testimony** (Invariant 3) until ratified. Every load-bearing claim is graded in the [[#Verification Ledger]] as one of: **[P]** — primary Kalshi documentation (docs.kalshi.com, help.kalshi.com, contract-terms PDFs, live market pages), cited by URL. **[O]** — observed directly by this lab against the live API (Milestone 1a run, 2026-07-03/04; CLI collector sessions). **[S]⚑** — secondary source (academic papers, third-party guides). Flagged; do not cite as exchange fact without primary confirmation. **[I]** — inference from documented behavior; stated as inference in the text. Ratifying this document as canon does **not** discharge individual ⚑ flags. Kalshi changes its API and fee schedule; the ledger records the as-of date of each claim.

# Kalshi Ticker Anatomy and Market Structure

**Scope.** This is the lab's single canonical description of how Kalshi works as an exchange and how its daily-maximum-temperature markets are identified, quoted, traded, and settled. It holds Kalshi-specific _facts_ and their immediate lab-facing consequences. General theory lives elsewhere and is only cross-referenced: order-book theory in [[Market Microstructure]], price-as-probability epistemology in [[Prediction Markets]], scoring in the calibration corpus, sizing in [[Kelly Criterion]]. Documents on edge detection, normalization, collection, execution, and automation should cite this document instead of re-explaining Kalshi.

---

## 1. Exchange overview

### 1.1 What Kalshi is

Kalshi (KalshiEX LLC) is a U.S. exchange for **event contracts** — binary contracts that pay $1.00 if a specified real-world condition is true at determination and $0.00 otherwise. It is regulated by the CFTC as a **Designated Contract Market (DCM)**, and clearing is handled by its affiliated **Derivatives Clearing Organization** (Kalshi Klear). **[P/S]⚑** (DCM status is well documented, including in the academic literature; the current clearing-entity name should be confirmed against CFTC registration before being cited in any legal-adjacent context.)

Three consequences of the regulatory form matter for research:

1. **The exchange is never the counterparty.** Members trade against each other; Kalshi matches and clears. Prices are therefore a claim by an aggregation _mechanism_, not by a bookmaker with an inventory position — the epistemological frame in [[Prediction Markets]] applies directly.
2. **Contracts are fully collateralized.** A matched YES at price pp and NO at 1−p1−p jointly post the full $1.00 payout at trade time. There is no margin call channel and no counterparty-default term in the payoff model. **[P]**
3. **Contract terms are legal documents.** Every series has a rules PDF (`contract_terms_url` on the series object) that is the binding settlement specification. For settlement questions, the rules PDF outranks the website copy, which outranks any help article. **[P]** This is the primary-source hierarchy the F2 gate must use.

### 1.2 Participants

Retail traders (web/app), API traders, and designated market makers, plus brokered flow (e.g., Robinhood routes event contracts to Kalshi). **[P/S]⚑** Market makers receive maker-fee advantages and incentive programs (the API exposes an incentives endpoint). **[P]** For the lab, the operative fact is that weather-market books are a mix of professional quoting in liquid brackets and thin retail interest in tails — heterogeneous liquidity is the norm, not an anomaly (§5.4).

### 1.3 Trading hours and pauses

The exchange trades continuously except a **scheduled maintenance window every Thursday 03:00–05:00 ET**, during which a _trading pause_ is in effect: no placing or amending orders; cancels still accepted; resting orders remain on the book unless the order was flagged `cancel_order_on_pause`. Rarely, a full _exchange pause_ (no cancels either) occurs for intensive maintenance or outages. **[P]**

> [!important] Collector consequence A book snapshot taken inside Thursday 03:00–05:00 ET observes a frozen market. Sweeps must record exchange status (the API exposes `GET /exchange/status` and `GET /exchange/schedule`) or at minimum tag snapshots falling in this window, so that stale-quote analysis does not misread a pause as a liquidity event. **[P → design rule]**

Individual daily-temperature markets additionally stop trading at their own `close_time` — observed as 11:59 PM local time on the event date for weather series ("regardless of any data releases or events occurring"). **[P]** Per-market `close_time` from the API is authoritative; never hardcode.

### 1.4 Market lifecycle (state machine)

From primary documentation: **[P]**

|API status|Meaning|
|---|---|
|`initialized`|Created, not yet open. Becomes `active` when `open_time` passes (no WebSocket event for this transition).|
|`active`|Open for trading.|
|`inactive`|Temporarily deactivated by the exchange; trading paused, not closed. On reactivation **all resting orders are cancelled**.|
|`closed`|Past `close_time`. All order operations, including cancels, rejected (`MARKET_INACTIVE`); resting orders cancelled shortly after close. Awaiting determination.|
|`determined`|Result known (`result` = `yes` / `no` / `scalar`). Settlement timer (`settlement_timer_seconds`) running; result may be disputed in this window.|
|`disputed`|Result challenged; may be re-determined.|
|`amended`|Re-determined after dispute; settlement timer restarts.|
|`finalized`|Positions paid out. Terminal. `settlement_ts` populated.|

open_timeexchange deactivates

Two traps: **[P]**

- The REST filter `status=settled` matches `finalized`, and `status=closed` matches _anything past close_time that is not yet finalized_ (including `determined` and `disputed`). Filter values and status values are different vocabularies.
- Weather market pages advertise projected payout "30 minutes" to "1 hour" after close/resolution; these are projections, not guarantees. `settlement_ts` is the settlement-time fact of record.

---

## 2. Weather market architecture

### 2.1 The product

For each covered city and calendar day, Kalshi lists an **event**: "Highest temperature in {city} on {date}?" The event contains a set of **markets** — binary contracts on brackets and thresholds of the daily maximum. The event is flagged **mutually exclusive**: exactly one bracket outcome is true. **[P]** (Threshold `T` markets are cumulative claims over the same draw and are not mutually exclusive with each other; the mutually-exclusive flag applies to the event's bracket partition. **[I]** — confirm per event via the `mutually_exclusive` field.)

The lab's five target series (all **[O]**, verified to exist against the live API 2026-07-03):

|City|Series ticker|Candidate settlement station (⚑ unverified, tracked in `config.yaml`)|
|---|---|---|
|Phoenix|`KXHIGHTPHX`|KPHX — Sky Harbor|
|New York|`KXHIGHNY`|KNYC — Central Park|
|Chicago|`KXHIGHCHI`|KMDW — Midway|
|Miami|`KXHIGHMIA`|KMIA — Miami Intl|
|Austin|`KXHIGHAUS`|KAUS — Austin-Bergstrom|

> [!danger] Station identity is settlement identity Each series settles on **one named station**. Nearby stations (O'Hare vs Midway; a city's two airports) routinely differ by 1–3 °F — an entire bracket. The station mapping is per-series, must be confirmed from each series' rules page / contract-terms PDF (F2 gate), and remains **unverified** until flipped in `config.yaml`. **[O + P]**

### 2.2 Settlement methodology

- **Source of record:** the **final NWS Climatological Report (Daily)** — the CLI product — for the named station. Never a forecast, never a consumer weather app, never raw METAR. **[P]**
- **Preliminary vs final:** NWS data is explicitly "preliminary and subject to revision." Kalshi settles on the final report; preliminary CLI issuances (the lab's `report_kind = preliminary`) are guidance, not settlement. Kalshi's own market pages warn that preliminary reporting carries "rounding and conversion nuances" (METAR reports in whole °C; the CLI's °F value derives from conversion). **[P]**
- **Documented delay conditions:** determination may be delayed when (a) the reported high is inconsistent with 6-hr or 24-hr METAR highs, or (b) the final CLI high is _lower_ than a previously issued preliminary value. **[P]** These are exactly the cases where a naive "read the first CLI and settle" model diverges from the exchange.
- **Revision cutoff:** per the contract-terms structure, data revised after the contract's expiration time is not used; revisions arriving between last trading time and expiration may be. **[P]** (Series-specific wording must be confirmed from the current KXHIGHT* rules PDFs — the available primary example is the legacy NHIGH terms. ⚑)

### 2.3 The climate day (measurement window)

CLI reports use **local standard time**, year-round. During daylight saving time the measurement window is therefore 01:00 → 00:59 next day on the civil clock — not midnight-to-midnight. **[P, and independently encoded in the lab's `core/climate_day.py` with fixed per-city standard-time offsets, never DST-adjusted; DST-transition suite passing [O]]** This document is not the home of the climate-day implementation; [[Kalshi API]] and the pipeline's M2.T1 module own it. The canonical statement here: **the settlement window is an LST window, and any analysis that joins market data to weather data must join on the climate day, not the civil day.**

### 2.4 Bracket and threshold structure

Observed structure per city-day event (**[O]**, 1a run):

- **Bracket markets** (`B` suffix): 2 °F-wide bins, ticker value at the bin center — `B110.5` ⇒ the 110–111 °F bin. Interior bins partition the plausible range; roughly ~6 contracts per city-day in the observed events.
- **Threshold markets** (`T` suffix): cumulative tail claims — `T111` ⇒ high above 111 °F. Tails of the bracket set are themselves one-sided ("X or below" / "Y or above").

> [!warning] Strike semantics are API fields, not ticker arithmetic Whether a boundary temperature belongs to a bracket, and whether a threshold is > or ≥, must be read from the market object's `strike_type`, `floor_strike`, `cap_strike` (and the rules PDF), never inferred from the ticker or the display title. An off-by-one at the strike is a settlement-grade error. **[P → design rule]** The set of strikes listed per day is chosen by Kalshi around the forecast range and varies by season and city; collectors must enumerate markets from the event, not from a template. **[O/I]**

### 2.5 Edge cases to expect

Missing or late CLI issuance (rules PDFs specify fallback sources and procedures — confirm per series ⚑); amended/disputed determinations (§1.4); mid-season changes to strike granularity; new cities appearing under a _different series-prefix family_ (§3.3); and station instrument outages (the METAR-consistency delay condition exists precisely for this). Each of these is an event the pipeline should record, not code around silently.

---

## 3. Ticker anatomy

### 3.1 The three-level hierarchy

Kalshi identifiers form **Series → Event → Market**: **[P]**

```
KXHIGHNY                    series   (city + market family; recurring template,
                                      owns rules, settlement sources, fee multiplier)
KXHIGHNY-26JUL04            event    (one settlement-day instance; owns mutual
                                      exclusivity, strike_date, the market set)
KXHIGHNY-26JUL04-B62.5      market   (one binary contract; owns strikes, book,
                                      prices, status, result)
```

Observed component grammar for the weather families (**[O]**, consistent with docs examples):

|Component|Pattern|Example|Notes|
|---|---|---|---|
|Series|`KXHIGH{loc}` or `KXHIGHT{loc}`|`KXHIGHNY`, `KXHIGHTPHX`|Prefix family is **not uniform** — see §3.3|
|Event date|`-YYMMMDD`|`-26JUL04`|Settlement (climate) day; MMM is uppercase English month|
|Bracket market|`-B{center}`|`-B110.5`|Bin center; width from strike fields|
|Threshold market|`-T{value}`|`-T111`|Direction/inclusivity from strike fields|

### 3.2 The do-not-parse rule

Kalshi's own glossary states that while tickers "often follow Series → Event → Market," **"there are occasional exceptions, so do not parse ticker strings to infer relationships"** — the supported method is the series/event/market/search endpoints and the `series_ticker` / `event_ticker` fields on returned objects. **[P]**

Lab rule derived from this: **tickers are opaque keys.** They are stored verbatim, used for API addressing and human display, and joined on — never decomposed for meaning in pipeline logic. Every semantic fact a parser would extract (city, date, strike, direction) has an authoritative API field or config mapping. Ticker parsing is permitted only in throwaway exploratory analysis, never in the collection or settlement path.

### 3.3 The series-prefix inconsistency (worked warning)

The lab's own five series prove the naming is irregular: New York, Chicago, Miami, Austin use `KXHIGH{loc}`, while Phoenix uses `KXHIGHT{loc}` — and newer listings (e.g., Washington DC, `KXHIGHTDC`) follow the `KXHIGHT` family. **[O + P]** A parser that strips a fixed `KXHIGH` prefix reads Phoenix's location as `TPHX`. Discovery of new cities must go through series-list/search endpoints filtered by category/tags, followed by human confirmation of the settlement station (F2 discipline), not by prefix pattern-matching.

### 3.4 Worked example, end to end

`KXHIGHTPHX-26JUL04-B110.5` (**[O]**, 1a run):

1. Series `KXHIGHTPHX` — Phoenix daily high family. Series object supplies `contract_terms_url` (rules PDF), `settlement_sources`, `fee_multiplier`.
2. Event `KXHIGHTPHX-26JUL04` — the Phoenix climate day 2026-07-04 (LST window). Event object supplies `mutually_exclusive`, `strike_date`, and the full market list — the correct way to enumerate that day's brackets.
3. Market `...-B110.5` — pays $1.00 if the final CLI daily maximum at the named Phoenix station falls in the 110–111 °F bin (exact boundary inclusion per strike fields). The 1a run captured this market with `price_close: None` but a live 0¢/1¢ book — the canonical quotes-without-trades example (§5.3).
4. Settlement: Phoenix CLI final report (the lab's collector observed `high=108` for an adjacent day) ⇒ this bracket resolves NO; `result=no`, timer runs, `finalized`.

---

## 4. Market structure: the book

Theory home: [[Market Microstructure]]. This section records only what is Kalshi-specific.

### 4.1 A bids-only book

The order book endpoint returns **only bids**, on both sides: an array of YES bids and an array of NO bids (`orderbook_fp.yes_dollars`, `orderbook_fp.no_dollars`), each entry a `[price_dollars, count_fp]` string pair, sorted ascending — **best bid is the last element**. **[P]**

There are no stored asks because binary complementarity makes them redundant: **a YES bid at xx is exactly a NO ask at 1−x1−x, and a NO bid at yy is a YES ask at 1−y1−y.** **[P]** Derived quotes:

best YES ask=1−max⁡(NO bids),YES spread=best YES ask−best YES bidbest YES ask=1−max(NO bids),YES spread=best YES ask−best YES bid

> [!important] Storage rule Snapshots should store the raw two-array book. Derived quantities (best bid/ask, spread, midpoint, depth-at-k) are computed at analysis time from the stored arrays. Storing only derived quotes destroys depth information that cannot be recovered (§7.2).

### 4.2 Matching and priority

Orders match under **price-time priority** (Kalshi exposes queue position "determined using a price-time priority"). **[P]** A trade prints when a YES bid and a NO bid cross, i.e., their prices sum to ≥ $1.00; matched pairs are fully collateralized at creation. **[P/I]** Takers (orders that cross a resting quote) pay the trading fee; makers (resting quotes) pay reduced or zero fees depending on the current schedule and program (§6.3 ⚑).

### 4.3 Prices as fixed-point strings

All prices are fixed-point dollar strings (`_dollars`, up to 4 decimals); all quantities are fixed-point strings (`_fp`, 2 decimals; fractional contracts to 0.01 exist and appear in fills even for integer traders). **[P]** The pipeline's decision to store prices as TEXT and preserve raw JSON is exactly right and is retained as a design rule. Legacy integer-cent order endpoints were slated for deprecation no earlier than 2026-05-06 in favor of V2 fixed-point endpoints; current field availability per endpoint should be verified live rather than assumed. ⚑ **[P]**

### 4.4 Liquidity regimes in weather books

Empirically (**[O]**, to be quantified in V1): weather bracket books are **heterogeneous by construction**. Center-of-distribution brackets carry quoted size at competitive spreads; tail brackets carry token books (e.g., 0¢ bid / 1¢ ask) with nonzero open interest and no recent trades. Expected phenomena, all normal: thin books, wide spreads mid-distribution on low-attention days, stale last-trade prices, liquidity that arrives and departs with forecast releases (§6 of [[Edge Detection]] treats the consequences). None of these is an error condition for the collector; all of them are _data_.

---

## 5. Pricing

### 5.1 Price as probability — with bounds

A YES price rr is conventionally read as the market-implied probability of the event ([[Prediction Markets]] owns the epistemology; fees and risk terms mean rr is not exactly anyone's belief ⚑ academic literature documents systematic deviations, §6.4). What the book actually pins down is an **interval**, not a point:

- Best YES bid = the highest probability at which the market will _pay you_ to assert NO.
- Best YES ask = the lowest probability at which the market will _sell you_ YES.
- Between them, the market asserts nothing executable.

**Two-regime rule (supersedes v1's "midpoint is the default proxy"):**

1. **Scoring regime.** For grading the _market_ as a forecaster ([[Forecast Verification]]), a point value is needed; midpoint is the lab's convention, acceptable when the spread is narrow relative to the quantity measured, and the spread must be stored alongside so that wide-spread observations can be down-weighted or excluded under pre-registered rules.
2. **Decision regime.** For anything touching edge, EV, or sizing, only **executable prices** exist: you buy at the ask, sell at the bid, minus fees. Divergence Δ computed against midpoints is not edge; it must clear the ask (or bid) _and_ fees _and_ the microstructure dead zone (Market Normalization spec). A 0/1¢ tail book has midpoint 0.5¢ — a usable scoring proxy for "nearly impossible," and simultaneously a statement that you cannot sell that improbability for more than 0¢. Both facts are true; conflating them is the pitfall.

### 5.2 Tick structure is not uniformly 1¢

Markets carry a `price_level_structure`: **[P]**

|Structure|Ranges|Tick|
|---|---|---|
|`linear_cent`|$0.00–$1.00|$0.01|
|`tapered_deci_cent`|$0.00–$0.10 and $0.90–$1.00|$0.001|
||$0.10–$0.90|$0.01|
|`deci_cent`|$0.00–$1.00|$0.001|

Which structure applies to each weather market must be read from the market object (`price_level_structure`, `price_ranges`) — **unverified for the five series** ⚑. This matters disproportionately for the lab: daily-high bracket sets concentrate probability mass near 0 and 1, exactly where decicent ticks (if active) change price discreteness, minimum spread, and the resolution of tail probabilities. A "1¢" tail quote under `linear_cent` and a "0.4¢" tail quote under `tapered_deci_cent` are different measurement instruments.

### 5.3 Quotes without trades (retained from v1, [O])

A settled bracket in the 1a data showed `price_close: None` with a live 0¢/1¢ book and nonzero open interest. Consequences, unchanged: last-trade price is stale or absent in thin brackets — quote data, not trade data, is the primary observable; and zero volume ≠ zero information — a 0/1¢ book _is_ the market pricing the bracket as nearly impossible.

### 5.4 Normalization across an event

Bracket midpoints (or asks, or bids) across one event need not sum to 1: spreads, discreteness, fee-adjusted quoting, and incomplete coverage (listed strikes may not exhaust the physically possible range) all break additivity. Converting a bracket set into a proper distribution r(⋅)r(⋅) over temperature is a _modeling step_ with registered choices — owned by the Market Normalization spec. This document's contribution is the constraint list: mutually exclusive partition **[P]**, per-bracket bid/ask intervals not points (§5.1), tick discreteness (§5.2), possible decicent tails ⚑, and tail brackets that are one-sided cumulative claims.

---

## 6. Costs

### 6.1 Trading fees

Kalshi charges a **taker fee per trade** with the published general form ⚑ **[S/P — verify against the live fee schedule PDF before any EV computation is registered]**:

fee=round_up⁡$0.01(m⋅C⋅P⋅(1−P))fee=round_up$0.01​(m⋅C⋅P⋅(1−P))

where CC = contracts, PP = price in dollars, and mm = the fee multiplier, 0.070.07 for general markets. Properties that survive any multiplier update:

- **Parabolic in price:** maximal at P=0.50P=0.50 (1.75¢/contract at m=0.07m=0.07), vanishing toward 00 and 11. Fee drag is largest exactly where uncertainty — and apparent edge — is largest.
- **Round-up on the order total:** single-contract trades pay a rounding penalty (1 contract at 50¢ ⇒ 1¢ fee = 2% of notional). ⚑
- **Per-series multipliers exist:** the series object exposes `fee_multiplier` **[P]** — the programmatic source of truth. Collect it per series rather than hardcoding 0.07.
- **Maker fees** are lower (historically zero on most markets; schedules have included reduced maker formulas). ⚑ Verify current schedule; the maker/taker asymmetry is a standing argument for resting orders in any future execution design.
- **Settlement itself carries no fee** per current secondary descriptions. ⚑

### 6.2 Total cost of a round trip

The decision-relevant cost of expressing a view is: (half-)spread paid at entry + taker fee at entry + either settlement (free ⚑) or spread + fee again at exit. For a mid-priced weather bracket with a 2¢ spread, a taker round trip costs ≈ 2¢ + ~3.5¢ in fees — several percentage points of probability. This is the floor that any claimed edge Δ must clear _before_ statistical significance is even asked about ([[Edge Detection]], Market Normalization dead zone).

---

## 7. Information flow and data tiers

### 7.1 What moves weather prices

Causal inventory (mechanism level; hypotheses about exploitable structure belong to [[Edge Detection]]):

- **NWP model cycles** — global and mesoscale guidance updates on fixed schedules (e.g., 00/06/12/18Z synoptic cycles, more frequent rapid-refresh products); prices reprice around releases. **[I/S]⚑**
- **NWS forecast issuance** — official forecast updates for the settlement city; issuance history is non-backfillable and is the accrual-clock-critical collectable. **[O — lab priority]**
- **Intraday observations** — as the day progresses, METAR observations at the settlement station progressively truncate the possible maximum; tail brackets collapse toward 0/1 and the event distribution narrows mechanically with time-to-expiry.
- **Preliminary CLI issuance** — the first authoritative-looking number; §2.2's rounding and final-vs-preliminary traps apply.
- **Settlement announcement** — determination and payout (§1.4 timing fields).

Academic findings on Kalshi generally ⚑ **[S]**: prices are informative and accuracy improves approaching resolution (Bürgi et al., 2026); a favorite–longshot bias is documented, weakening over time (Hegarty & Whelan, UCD WP 2025); calibration quality is domain- and horizon-dependent. These are priors for V1 hypotheses, not established facts about _these five series_.

### 7.2 Live vs historical API tiers, and what is recoverable

Kalshi partitions exchange data into **live** and **historical** tiers with published **cutoff timestamps** (`GET /historical/cutoff`); the live window targets ~3 months. Partitioned: markets, market candlesticks, trades, orders. **Events and series remain on live endpoints indefinitely.** Candlestick intervals: 1 min / 1 hour / 1 day. **[P]**

**The recoverability boundary (narrows v1's claim):**

|Data|Retroactively recoverable?|
|---|---|
|Trades, candlesticks, settled-market metadata|Yes — live or historical endpoints **[P]**|
|Best bid/ask at candle granularity|Partially — exact candle field content **unverified** ⚑|
|**Full order-book depth at an arbitrary past instant**|**No** — no book-replay endpoint exists **[I]**|
|NWS forecast issuance snapshots|**No** (working assumption, unchanged from v1) **[O/I]**|

Polling design follows: book snapshots and forecast snapshots are collected in real time because they cannot be reconstructed; trades and candles can be backfilled and are therefore lower urgency. Irreversibility beats importance.

---

## 8. Data collection specification (what and why)

Per market, per sweep — with the **dual-timestamp rule** applied to every row: `collected_at` (lab wall clock, UTC) and the event/exchange timestamp the datum describes. Confusing the two is unrecoverable after the fact.

|Datum|Why|
|---|---|
|Raw order book (both bid arrays, full depth)|The primary observable; source of bid, ask, spread, mid, depth; not retro-recoverable|
|Best bid / ask / spread (derived, stored for query convenience)|Executable-price bounds; spread gates scoring-regime use of midpoints|
|Last trade price + trade tape|Staleness measurement; realized-transaction record; recoverable but cheap to keep aligned|
|Volume, open interest|Liquidity and participation covariates; OI distinguishes "empty" from "dormant" books|
|Market status + lifecycle events|Pause/close/determined/finalized semantics; excludes frozen-book snapshots from liquidity stats|
|`close_time`, `expected_expiration_time`, `settlement_ts`, `result`|Time-to-expiry features; settlement facts of record|
|`strike_type`, `floor_strike`, `cap_strike`, `price_level_structure`, `fee_multiplier`|Contract semantics: strikes, tick regime, fee regime — never inferred from tickers|
|Series/event metadata (`mutually_exclusive`, `settlement_sources`, `contract_terms_url`)|Settlement-source audit trail; F2 evidence|
|NWS forecast issuances + CLI reports (preliminary/final/summary, `report_kind`, `parser_version`)|The lab's side of the verification ledger; non-backfillable|
|Exchange announcements / schedule status|Pause windows; maintenance tagging|

Everything above lands in content-addressed snapshots with raw JSON preserved (M1.T6), so upstream schema changes never destroy information. **[O — implemented]**

---

## 9. Research applications (mapping, not methodology)

- **[[Forecast Verification]] / calibration** — market bid/ask/mid per bracket is a gradeable forecaster once normalization rules are fixed; grading is population-level only, per lab doctrine.
- **[[Edge Detection]]** — Δ = divergence between lab distribution pp and market-implied rr; this document supplies the executable-price, fee, tick, and dead-zone facts Δ must clear.
- **Market Normalization spec** — consumes §5 wholesale (interval prices, discreteness, non-additivity, mutual exclusivity, tail one-sidedness).
- **[[Effective Sample Size]]** — one city-day = one draw; ~6 correlated contracts. Distributional scores (RPS) over the ordered bracket set; V1's ≥300 gap-audited city-day gate is denominated in draws, not contracts.
- **[[Kelly Criterion]] / [[Expected Value]]** — sizing uses executable prices net of fees; every unresolved uncertainty in this document (⚑ items) pushes size down, per the asymmetry doctrine.
- **Backtesting / paper trading** — feasible only over quantities that were collected live (books) or are recoverable (trades, candles); §7.2's table is the feasibility boundary. Fills must be simulated against stored depth, not midpoints.
- **Automation / collectors** — do-not-parse rule (§3.2), enumerate-from-event rule (§2.4), pause tagging (§1.3), status-filter semantics (§1.4), historical-cutoff routing (§7.2).

---

## 10. Pitfalls register

1. Using midpoints where executable prices are required (the Δ ≠ executable-Δ error).
2. Ignoring spread when scoring — a 0.5¢ mid from a 0/1¢ book and a 50¢ mid from a 45/55¢ book are not equally informative observations.
3. Ignoring depth — a 1-contract best quote is not a price at which research-relevant size exists.
4. Treating all brackets as equally informative — tails are often token quotes; weight or filter under pre-registered rules.
5. Assuming market prices are calibrated — documented favorite–longshot bias ⚑; calibration is a measured output, never an input assumption.
6. Trusting last-trade / candle closes in thin markets — stale by construction (§5.3); candles with no trades are undefined or carry-forward, per field semantics to be verified ⚑.
7. Confusing settlement time with collection time — dual-timestamp rule (§8).
8. Confusing civil day with climate day — LST window (§2.3).
9. Using forecast data issued after a decision cutoff in backtests — look-ahead via NWS revisions; issuance timestamps are part of the datum.
10. Parsing tickers for semantics — §3.2/§3.3.
11. Misreading REST status filters — `settled` = `finalized`; `closed` includes `determined` and `disputed` (§1.4).
12. Treating preliminary CLI values as settlement — final report governs; documented delay/override conditions (§2.2).
13. Scheduling sweeps blind to the Thursday 03:00–05:00 ET pause (§1.3).

---

## Verification Ledger

|#|Claim|Grade|Source (as of 2026-07-15)|
|---|---|---|---|
|1|Series→Event→Market hierarchy; do-not-parse warning|[P]|docs.kalshi.com/getting_started/terms|
|2|Lifecycle statuses, filter mapping, settlement timer, orders-after-close|[P]|docs.kalshi.com/getting_started/market_lifecycle|
|3|Bids-only book, YES/NO reciprocity, spread computation, ascending sort|[P]|docs.kalshi.com/getting_started/orderbook_responses|
|4|Fixed-point `_dollars`/`_fp`; `price_level_structure` tiers incl. decicent|[P]|docs.kalshi.com/getting_started/fixed_point_migration (updated 2026-04-17)|
|5|V2 order endpoints; legacy deprecation "no earlier than 2026-05-06"|[P] ⚑ verify live|docs.kalshi.com/api-reference/orders/create-order-v2|
|6|Thursday 03:00–05:00 ET trading pause; pause semantics; `cancel_order_on_pause`|[P]|docs.kalshi.com/getting_started/maintenance_and_pauses|
|7|Live/historical cutoff, ~3-month window, partitioned entities, candle intervals 1/60/1440|[P]|docs.kalshi.com/getting_started/historical_data; .../get-market-candlesticks|
|8|Price-time priority|[P]|docs.kalshi.com/api-reference/orders/get-order-queue-position|
|9|Settlement on final NWS Daily Climate Report; LST window; delay conditions|[P]|help.kalshi.com weather-markets article; live KXHIGHT market pages|
|10|Weather close at 11:59 PM local on event date; payout projections 30–60 min|[P] ⚑ per-market fields authoritative|live kalshi.com market pages (KXHIGHTDC, KXHIGHNY)|
|11|Contract-terms revision-cutoff language|[P] ⚑ legacy NHIGH PDF; confirm current KXHIGHT* PDFs|kalshi-public-docs.s3.amazonaws.com/contract_terms/NHIGH.pdf|
|12|Taker fee = round-up(0.07·C·P·(1−P)); maker reduced/zero; settlement free|[S] ⚑ verify vs live fee schedule + series `fee_multiplier`|multiple secondary; series object field [P]|
|13|Five series exist; ticker grammar; B/T semantics; quotes-without-trades; 0/1¢ tail books|[O]|Milestone 1a live run 2026-07-03/04|
|14|Station mapping candidates|[O] ⚑ F2 open|config.yaml verification flags|
|15|KXHIGH* vs KXHIGHT* prefix inconsistency|[O+P]|lab series list; KXHIGHTDC live page|
|16|No book-replay endpoint ⇒ depth not retro-recoverable|[I]|absence in full API index (llms.txt)|
|17|Favorite–longshot bias; informativeness improving near resolution|[S] ⚑|Hegarty & Whelan (UCD WP 2025/19); Bürgi et al. 2026 (via arXiv 2606.07811)|
|18|DCM regulatory status; full collateralization|[P/S] ⚑ entity names|CFTC registrations; academic literature|

**Ratification checklist for the Architect:** (a) walk ledger rows 5, 10, 11, 12 against live sources; (b) pull `price_level_structure`, `fee_multiplier`, `strike_type/floor_strike/cap_strike`, `mutually_exclusive` for one live market in each of the five series and attach the JSON as evidence; (c) confirm current KXHIGHT*/KXHIGH* rules PDFs and station names (closes F2); (d) stamp or reject §5.1's two-regime rule as lab convention.
