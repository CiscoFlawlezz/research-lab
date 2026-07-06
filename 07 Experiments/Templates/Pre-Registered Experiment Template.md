# Pre-Registered Experiment Template

**Vault location:** `07 Experiments/Templates`
**Usage:** COPY this note (never edit the template itself), rename the copy `Experiment N - Short Name`, place it in `07 Experiments`, and fill every section above the Results line BEFORE looking at any outcome data. Date the registration. Nothing above the Results line is edited after registration — corrections go in an addendum.
**Why this exists:** Selection effects and multiple testing are the quiet killers of retail quant research. Pre-registration is the strongest cheap defense. If a section feels annoying to fill in advance, that is usually the exact place self-deception was going to enter.

---

# Experiment N — [Short Name]

**Registered:** [date, before any outcome data was inspected]
**Author:** [name]
**Status:** Registered / Running / Complete / Abandoned (reason)

## 1. Hypothesis

[One falsifiable sentence. "Kalshi weather bracket midpoints at final-hour timestamps are miscalibrated, with longshot brackets overpriced" — not "explore market calibration."]

## 2. Event set (fixed ex ante)

- Cities: [ ]
- Date range: [ ]
- Contract types: [threshold / bracket / both]
- Inclusion & exclusion rules: [e.g., minimum quote presence; markets voided/settled abnormally]
- **Anti-cherry-picking clause:** every market meeting the above is scored. No post-hoc exclusions without a dated addendum explaining why.

## 3. Data extraction rules

- Market forecast definition: [e.g., bid/ask midpoint at timestamp T; cite resolution of Open Question 2]
- Timestamp convention: [UTC; which snapshot]
- Missing/degenerate quote handling: [rule]
- Outcome source: [kalshi_settlements table]

## 4. Metrics

[Proper scores only. e.g., Brier + log per contract; RPS per event; Murphy decomposition with ≥2 binnings; reliability diagram.]

## 5. Inference plan

- Unit of evidence: city-day ([[Effective Sample Size]])
- Clustering / resampling: [e.g., block bootstrap by date, B = ...]
- Test: [e.g., paired score differentials, DM-style]
- Threshold: [e.g., 95% CI excluding zero]

## 6. Success / failure criteria (decided now)

- Result A means: [ ]
- Result B means: [ ]
- Minimum sample before any conclusion is claimed: [n city-days, justified]

## 7. What would change my mind

[Per Thinking Framework step 6: which specific evidence would overturn the expected conclusion?]

---
*=========== REGISTRATION LINE — nothing above edited after this date ===========*

## 8. Results

[Filled after execution. Tables, figures, exact numbers with uncertainty.]

## 9. Post-mortem

- What the result means for the project:
- What we learned about *method* (not just outcome):
- Errors in the registration itself, honestly recorded:
- New Open Questions generated → [[Open Questions]]
- Decision Log entries required → [[Decision Log]]
