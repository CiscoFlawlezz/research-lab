# Brier Decomposition - Worked Example

**Vault location:** `01 Research`
**Cross-links:** [[Proper Scoring Rules and Calibration - Technical Reference (V2)]] · [[Effective Sample Size]] · [[Experiment Log]]
**Status:** ⚠️ STUB — intentionally incomplete. Fill with real pipeline data after Milestone 1b's 14-day collection completes.
**Created:** 2026-07-04

---

## Purpose of this stub

Formulas without a worked example on our own data don't stick. This note exists now to record the intent and give the first real dataset an immediate consumer. **Do not fill with synthetic or invented numbers** — the project rules forbid fabricated statistics, and a fake worked example would train intuition on fiction.

## The formula to be worked

With forecasts binned into $K$ groups (sizes $n_k$, mean forecast $\bar p_k$, observed frequency $\bar o_k$, base rate $\bar o$):

$$\text{BS} = \underbrace{\tfrac{1}{N}\sum_k n_k(\bar p_k - \bar o_k)^2}_{\text{Reliability (↓)}} - \underbrace{\tfrac{1}{N}\sum_k n_k(\bar o_k - \bar o)^2}_{\text{Resolution (↑)}} + \underbrace{\bar o(1-\bar o)}_{\text{Uncertainty (fixed)}}$$

## To be completed when data exists

- [ ] Choose event set (per pre-registration discipline — see Templates)
- [ ] Extract market midpoint forecasts at a defined timestamp
- [ ] Bin (report at least two binnings — ECE is binning-sensitive)
- [ ] Compute BS and all three decomposition terms
- [ ] Table: per-city and pooled
- [ ] Reliability diagram with date-clustered bootstrap bands
- [ ] Interpretation: is the market's Brier driven by miscalibration or by resolution? What does that imply about where model effort should go?

## Reminders for the future author (us)

- Unit of evidence = city-day ([[Effective Sample Size]]); decomposition estimators are biased in small bins — report bin counts alongside.
- If reliability term ≈ 0 for the market: recalibration offers no edge; only superior resolution (information) can win.
