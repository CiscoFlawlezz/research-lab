# Kalshi Ticker Anatomy and Market Structure

**Vault location:** `04 Data Sources`
**Cross-links:** [[Kalshi API]] · [[Weather Model]] · [[Proper Scoring Rules and Calibration - Technical Reference]]
**Status:** Empirical findings from Milestone 1a live run (2026-07-03/04)
**Created:** 2026-07-04

---

## Ticker structure (observed from live data)

Format: `SERIES-DATE-TYPE`

Examples from the 1a integration test:
- `KXHIGHTPHX-26JUL04-T111` — Phoenix daily high, July 4 2026, **T**hreshold market: "high temperature above 111°"
- `KXHIGHTPHX-26JUL04-B110.5` — same event, **B**racket market: "high temperature in a range centered near 110.5°"

Components:
| Part | Meaning | Example |
|---|---|---|
| Series | City + market family | `KXHIGHTPHX`, `KXHIGHNY`, `KXHIGHCHI`, `KXHIGHMIA`, `KXHIGHAUS` |
| Date | Settlement date, YYMMMDD | `26JUL04` |
| T### | Threshold contract (above ###) | `T111` |
| B###.# | Bracket contract (range) | `B110.5` |

All five candidate series tickers were verified to EXIST against the live API on 2026-07-03.

## Structural facts that matter for analysis

**1. Quotes exist without trades.**
Observed directly in 1a data: a settled bracket showed `price_close: None` (no trades in the window) but live `yes_bid: 0.0000 / yes_ask: 0.0100` and nonzero open interest. Consequences:
- Last-trade price is **stale or absent** in thin brackets → bid/ask midpoint is the default probability proxy for scoring the market, not last trade.
- Zero volume ≠ zero information: a 0¢/1¢ quote is the market pricing that bracket as nearly impossible.

**2. Brackets within one event are one observation.**
The ~6 contracts per city-day resolve from a single temperature draw → see [[Effective Sample Size]]. Also: ordered brackets mean distributional scoring (RPS) applies, not just per-contract Brier.

**3. Settlement mechanics.**
- Settlement source: **NWS Daily Climate Report** for one named station per city — never a consumer forecast.
- Reports use **local standard time**, so the measurement window shifts during Daylight Saving Time. Must be handled in code, never assumed away.
- Station mapping is per-market and must be verified against each market's official rules page. Candidates: KPHX (Phoenix Sky Harbor), KNYC (Central Park), KMDW (Chicago Midway), KMIA (Miami Intl), KAUS (Austin-Bergstrom). **Verification status tracked in `config.yaml` — do not trust until flipped to verified.**

**4. API field regime (post-March-2026).**
Legacy integer price fields were removed; current fields are `_dollars` strings (exact decimals) and `_fp` fixed-point quantities. Pipeline stores prices as TEXT to avoid float rounding; raw JSON always preserved so upstream schema changes never destroy information.

**5. Data tiers.**
Recent/live markets: standard endpoints. Older settled markets migrate to separate `/historical/` endpoints. Candlestick intervals available: 1 min / 1 hour / 1 day. Kalshi prices are therefore **recoverable retroactively**; NWS forecast snapshots are (working assumption) **not** — the asymmetry that drives the pipeline's polling design.
