# Glossary

**Vault location:** `00 Dashboard`
**Purpose:** Precise shared vocabulary. Drift in what terms mean is drift in the research itself. One-to-two-line definitions; each links to the full treatment. Alphabetical. Add terms the day they enter the project.
**Created:** 2026-07-04

---

**Base rate** — The unconditional historical frequency of an event (e.g., how often Phoenix July highs exceed 108°). The floor reference every forecast must beat. → topic K2 (climatology).

**Bracket market (Kalshi `B###.#`)** — Contract paying if the outcome falls in a range. Ordered brackets of one event form a discrete distribution. → [[Kalshi Ticker Anatomy and Market Structure]]

**Brier score (BS)** — Mean squared error of probability forecasts, $\frac{1}{N}\sum(p_i-y_i)^2$. Strictly proper; 0 perfect, 0.25 = always saying 50%. → [[Proper Scoring Rules and Calibration - Technical Reference]]

**Brier Skill Score (BSS)** — $1 - \text{BS}/\text{BS}_{\text{ref}}$. Positive = better than reference. Report it, never optimize it directly (skill scores are themselves improper).

**Calibration (reliability)** — Property that events forecast at X% occur ~X% of the time. Necessary for a good forecaster; nearly free to achieve alone (Foster–Vohra), hence not sufficient.

**City-day** — This project's unit of statistical evidence: one city's one settlement day. All ~6 brackets of a city-day are a single observation. → [[Effective Sample Size]]

**Climatology** — Forecasting from historical base rates alone. Reference level 1 in the skill ladder.

**CRPS** — Continuous Ranked Probability Score; proper score for full predictive distributions, $\int(F(x)-\mathbf{1}\{x\ge y\})^2dx$. Discrete version: RPS.

**Diebold–Mariano test** — Standard hypothesis test for comparing two forecasters via paired score differentials with dependence-robust variance.

**ECE (Expected Calibration Error)** — Binned average |forecast − observed frequency|. Useful, but binning-sensitive; report multiple binnings.

**Edge** — In this project, precisely: statistically significant positive skill vs the market-price reference, with date-clustered inference. Not vibes, not backtested P&L alone. → [[Edge Detection]]

**Favorite–longshot bias** — Documented pattern in many betting markets: longshots overpriced relative to true probability. Presence in Kalshi weather markets = Open Question 1.

**Kelly criterion** — Bet sizing maximizing expected log wealth. Gated until an edge is validated. → [[Kelly Criterion]]

**Kelly–log-score identity** — Expected log growth of a Kelly bettor vs market price = expected log-score difference vs the market: $D_{KL}(q\|r)-D_{KL}(q\|p)$. The bridge between scoring and money. → [[Log Score and Kelly Identity]]

**KL divergence** — $D_{KL}(q\|p)$, information-theoretic distance from truth q to forecast p. Expected log-score shortfall of p relative to truth.

**LMSR** — Hanson's Logarithmic Market Scoring Rule market maker; trading profit = improvement of the market's log score. Kalshi uses an order book, but the profit≡score identity carries via Kelly.

**Log score** — $y\ln p + (1-y)\ln(1-p)$. Strictly proper, local, unbounded penalty for confident wrongness; denominated in the units of compounding wealth.

**Midpoint** — (bid+ask)/2; default proxy for the market's probability forecast, because last trade is stale in thin brackets. Exact extraction rule = Open Question 2.

**Murphy decomposition** — BS = Reliability − Resolution + Uncertainty. Turns a grade into a diagnosis. → [[Brier Decomposition - Worked Example]]

**Pre-registration** — Fixing hypothesis, event set, extraction rules, metrics, and success criteria *before* seeing outcomes. Primary defense against selection effects. → Templates.

**Proper scoring rule** — Scoring rule under which honest reporting maximizes expected score. *Strictly* proper: honesty is uniquely optimal. Improper metrics (accuracy, MAE, hit rate) pay you to exaggerate.

**Reference ladder** — Climatology → NWS forecast → market price. The sequence of baselines a model must beat; only the last defines edge.

**Reliability diagram** — Plot of observed frequency vs forecast bin. Diagonal = calibrated. Requires bootstrap bands; early curves are noise.

**Resolution** — The decomposition's sharpness-that-pays term: how much outcome frequencies differ across forecast bins. Where information lives.

**RPS (Ranked Probability Score)** — Proper score over ordered categories via cumulative distributions; rewards being close in temperature space, unlike per-bracket Brier.

**Sharpness** — Concentration of forecasts away from the base rate. Governing paradigm: maximize sharpness *subject to* calibration.

**Threshold market (Kalshi `T###`)** — Contract paying if outcome exceeds a level.

**Uncertainty (decomposition term)** — $\bar o(1-\bar o)$; base-rate variance outside any forecaster's control.
