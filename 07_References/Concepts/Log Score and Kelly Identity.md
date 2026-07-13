# Log Score and Kelly Identity

**Vault location:** `01 Research`
**Cross-links:** [[Kelly Criterion]] · [[Expected Value]] · [[Edge Detection]] · [[Proper Scoring Rules and Calibration - Technical Reference (V2)]]
**Status:** Foundational result — cite from any edge or sizing discussion
**Created:** 2026-07-04

---

## The claim

For a binary prediction market contract, the expected log-growth rate of a Kelly (log-utility) bettor trading against the market equals the expected **log-score difference** between the bettor's forecast and the market's price-implied forecast.

**"I have positive expected log growth (before costs)" and "my forecasts log-score better than the market's prices" are the same mathematical statement.**

## Setup

- YES contract pays \$1 if event occurs; market price $r$ (so NO costs $1-r$).
- Your probability belief: $p$. True probability: $q$.
- Market is two-sided and frictionless (fees handled separately below).

## Derivation

A log-utility bettor allocates so that terminal wealth is proportional to belief: fraction $p$ of wealth into YES at price $r$, fraction $1-p$ into NO at price $1-r$.

Wealth growth factor:
- If event occurs ($Y=1$): the YES stake pays $1/r$ per dollar → growth $= p/r$
- If it doesn't ($Y=0$): the NO stake pays $1/(1-r)$ per dollar → growth $= (1-p)/(1-r)$

Expected log growth under the true probability $q$:

$$\mathbb{E}_q[\ln \text{growth}] = q\ln\frac{p}{r} + (1-q)\ln\frac{1-p}{1-r}$$

Regroup:

$$= \underbrace{\big[q\ln p + (1-q)\ln(1-p)\big]}_{\text{your expected log score}} - \underbrace{\big[q\ln r + (1-q)\ln(1-r)\big]}_{\text{market's expected log score}}$$

Equivalently, in information-theoretic form:

$$\mathbb{E}_q[\ln \text{growth}] = D_{\mathrm{KL}}(q\,\|\,r) - D_{\mathrm{KL}}(q\,\|\,p)$$

## Consequences

1. **Edge is score difference.** Positive expected log growth ⟺ your expected log score beats the market's on those events. Edge detection *is* score comparison — not analogously, identically.
2. **Unbeatable market condition.** If $r = q$ (prices equal true probabilities), the first KL term is zero and no belief $p$ achieves positive expected growth. Market efficiency has a precise scoring meaning.
3. **Being less wrong is enough.** You profit when $D_{KL}(q\|p) < D_{KL}(q\|r)$ — your forecast need not be *right*, only closer to the truth than the price.
4. **Costs are a threshold, not a modifier.** Fees and effective spread subtract a roughly constant drag from the growth rate. The tradeable condition is score-edge **exceeding** a cost threshold, not merely positive. (Quantifying that threshold for Kalshi fee schedules → [[Expected Value]], future milestone.)
5. **Why log score has co-equal status with Brier in this project:** it is the only score denominated in the same units as compounding wealth.

## Cautions

- The identity is an *expectation* statement; realized growth is noisy and Kelly sizing at full fraction is aggressive. Sizing discipline is [[Kelly Criterion]] territory, gated until an edge is validated.
- Assumes you can trade both sides at $r$; real markets have bid/ask, so the relevant "market forecast" for scoring must match the executable price — see Open Question 2 in [[Open Questions]].
