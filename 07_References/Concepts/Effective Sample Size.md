# Effective Sample Size

**Vault location:** `01 Research`
**Cross-links:** [[Proper Scoring Rules and Calibration - Technical Reference (V2)]] · [[Edge Detection]] · [[Experiment Log]]
**Status:** Standing rule — every statistical analysis in this project must comply
**Created:** 2026-07-04

---

## The rule

**The unit of statistical evidence in this project is the city-day.** All standard errors, confidence intervals, and hypothesis tests must respect the dependence structure: cluster by date, or block-bootstrap by date.

## Why the naive count is wrong

Naive count: 5 cities × ~6 brackets × 30 days = **900** forecasts per month. This overstates evidence by roughly a factor of six or more, for two reasons:

**1. Brackets within a city-day are one observation.**
All ~6 temperature brackets for Phoenix on July 4 resolve from a single realized temperature. Their outcomes are deterministic functions of one random draw — perfectly dependent. Scoring them as six independent data points is counting the same coin flip six times.

**2. City-days are not independent either.**
Regional weather systems (a heat dome over the Southwest, a cold front across the Midwest) move multiple cities' temperatures together on the same day, and weather persists across adjacent days. The correlation magnitude is an open empirical question ([[Open Questions]] #3), but it is not zero.

**Honest accounting: ≤ ~150 city-days/month, discounted further for spatial and temporal correlation.**

## Why this matters concretely

Binomial noise at small n is brutal. The standard error of an observed frequency is $\sqrt{p(1-p)/n}$:

| n in calibration bin | SE at p = 0.7 |
|---|---|
| 10 | ±14.5 pp |
| 50 | ±6.5 pp |
| 200 | ±3.2 pp |

A "70% bin" showing 50% or 90% observed frequency at n = 10 is *unremarkable noise*. Calibration curves need hundreds of forecasts per bin region before their shape is signal. Early curves are entertainment, not evidence.

## Standing consequences

1. Any analysis quoting n in the high hundreds after one month of collection is double-counting → **rejected on sight**.
2. Reliability diagrams must carry bootstrap/consistency bands, resampled **by date**, never by contract.
3. Model-vs-market comparisons use paired score differentials on identical events with date-clustered inference (Diebold–Mariano style or block bootstrap).
4. Collection duration requirements for any experiment are derived from *city-day* counts. This is the quantitative reason patience is load-bearing in the charter, not decorative.

## What would change this note

Empirical measurement of cross-city and lag-1 temporal correlation in outcomes and in score differentials (Open Question 3). Evidence of near-independence would *loosen* the discount, never tighten it — the rule as stated is the conservative floor.
