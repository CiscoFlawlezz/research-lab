# Open Questions

**Vault location:** `01 Research`
**Purpose:** Standing register of what we do not know. Reviewed each sprint. This is the Thinking Framework's step 6 ("what new information would most change the estimate") given a permanent home. Questions get a status, an owner action, and — when answered — a link to the evidence and a strikethrough, never deletion.
**Created:** 2026-07-04

---

## Active

**Q1. Are Kalshi weather markets calibrated? Is a favorite–longshot bias present?**
Status: Open — the project's first empirical target.
Resolves via: Experiment #1 (market calibration study), gated on Q2 + sufficient city-days.
Why it matters: determines whether/where edge is plausible before any model exists.

**Q2. What is the correct market-forecast extraction rule?**
Midpoint vs time-weighted midpoint vs microprice; timestamp convention; handling of wide, crossed, or absent quotes near settlement.
Status: Open — **blocks Experiment #1 pre-registration.** Answerable by reasoning + small data audit; good candidate for a knowledge session.
Why it matters: "the market's forecast" must be defined before the market can be scored; changing the rule after seeing results is p-hacking.

**Q3. What is the empirical cross-city / cross-day correlation of outcomes and score differentials?**
Status: Open — needs pipeline data.
Why it matters: determines effective sample size, statistical power, and required collection duration. → [[Effective Sample Size]]

**Q4. Are NCEI/IEM historical forecast archives usable for backfill?**
Status: Open — carryover from Milestone 1; unverified working assumption is that missed NWS forecasts are unrecoverable.
Why it matters: **highest-leverage open item** — a yes multiplies sample size immediately and unlocks Milestone 1d.

**Q5. How does market calibration vary with time-to-settlement?**
Morning prices and final-hour prices are different forecasts with different information sets.
Status: Open — needs pipeline data; shapes which timestamp Experiment #1 scores.

**Q6. Is market efficiency in these markets improving over time?**
Status: Open — nonstationarity would silently invalidate pooled historical scoring and any edge estimated on old data.

**Q7. Does quote staleness in thin brackets bias market scores, and in which direction?**
Status: Open — related to Q2; observed in 1a data that dead brackets carry 0¢/1¢ quotes with zero volume.

## Answered

*(none yet — move questions here with evidence links, struck through, never deleted)*
