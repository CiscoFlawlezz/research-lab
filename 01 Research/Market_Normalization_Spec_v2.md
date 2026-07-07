---
title: "Market-Implied Probability Normalization Specification (A4)"
aliases: ["Market Normalization Spec", "A4", "Implied Probability Normalization"]
artifact_id: "A4 / RL-A4-001"
vault_location: "01 Research/Prediction Markets"
level: "Quantitative researcher reference — pre-registered ADR (design)"
status: "Audited draft (v2) — ungraded; resolves Open Questions Q2; requires architect ratification per Invariant 3 before canonical"
supersedes: "Market Normalization Spec v1 (2026-07-04)"
audited: 2026-07-04
resolves: "Open Questions Q2 (on ratification); addresses Q7"
track: "Full"
guards_risk: "R7 (microstructure noise masquerading as divergence)"
created: 2026-07-04
review: 2027-01-04
tags: [prediction-markets, normalization, microstructure, kalshi, pre-registration, ADR]
---

# Market-Implied Probability Normalization Specification (A4)

**Cross-links:** [[Edge Detection]] · [[Kalshi Ticker Anatomy and Market Structure]] · [[Kalshi API]] · [[Prediction Markets]] · [[Market Microstructure]] · [[Statistical Arbitrage]] · [[Effective Sample Size]] · [[Proper Scoring Rules and Calibration - Technical Reference]] · [[Expected Value]] · [[Research Lab Master Specification]] · [[Glossary]] · [[Open Questions]]

> **Provenance note (Invariant 3).** This is an AI-drafted specification. Its structural claims about Kalshi (ticker format, quote-without-trade behavior, `_dollars`/`_fp` field regime, DCR settlement) are **inherited from [[Kalshi Ticker Anatomy and Market Structure]]**, which records them as empirical findings from the Milestone 1a live run — treat those as the grade that note carries, not as re-verified here. The fee formula, the specific staleness thresholds, and every numeric parameter below are **E4 (testimony)** proposals to be confirmed against Kalshi's published fee schedule and the collector's actual captured fields before this document is stamped canonical. This is a design ADR, not a finding.

> **Scope discipline.** A4 does one thing: it pre-registers the deterministic rules that convert raw Kalshi quotes into a market-implied probability per city-day, *before* any divergence is measured against it — so that the normalization can never be tuned after seeing which choice makes the model look good. It does not model the outcome, does not produce $P_f$, does not decide thresholds for action (that is [[Edge Detection]] §8), and does not touch settlement adjudication (that is A6). It co-determines A3 (Collection Sufficiency Audit): every field A4 requires, A3 must confirm is being captured, and every field A3 finds uncapturable-but-needed constrains A4.

> **Audit note (v2, 2026-07-04).** Supersedes the v1 draft after self-audit against the governing corpus. Material corrections: (1) **register alignment** — v1 did not state that A4 *is* the resolution of canonical [[Open Questions]] Q2 (extraction rule, which blocks Experiment #1) and addresses Q7 (staleness bias); this is now stated in §1, and the front matter records it; (2) **numbering collision fixed** — v1's internal "Open Questions 1–6" (and a stray "Q2 above" cross-reference) collided with the canonical Q1–Q7 numbering; internal items are now labeled **A4-Q#** (§12); (3) **Glossary consistency** — §3 now explicitly ties the midpoint choice to the [[Glossary]] Midpoint entry, which already names Q2 as the owner of the exact rule. No parameters were changed and no new scope was added; every numeric value remains a placeholder gated behind §13.

---

## 1. Executive Summary

**The problem A4 exists to solve.** A Kalshi bracket price is not a probability. It is a quote — often a bid/ask pair with no recent trade, sometimes stale, always fee-laden, and belonging to a ladder of brackets whose prices need not sum to $1$. Turning that raw material into a single number $P_m$ that can be scored against a model, honestly, requires a *fixed, pre-committed* set of rules. Without them, the analyst has a free parameter — "which price did I use?" — that can be unconsciously tuned until divergence appears. That free parameter is **R7**, named in the Master Spec as the most seductive false positive this Lab will face: *thin markets produce wide spreads and stale quotes; a naive midpoint "implied probability" will diverge from any model, looking profitable on paper and being untradeable in fact.* A4 removes the free parameter by pre-registration.

**The five decisions A4 pre-registers.**
1. **Point-estimate rule** — mid vs. microprice vs. last-trade, and the fallback cascade when the preferred input is absent.
2. **Fee incorporation** — whether and how the price-dependent Kalshi fee enters the implied probability and the recorded cost band.
3. **Staleness handling** — the thresholds and timestamps that decide when a quote is too old to trust, and what happens when it is.
4. **Bracket-ladder coherence** — treatment of incomplete coverage and sum-to-one violations across an event's brackets.
5. **Liquidity metadata** — the microstructure metrics recorded *alongside every* $P_m$, so that any later divergence can be interrogated for whether it is real or an artifact of thinness.

**The governing principle.** $P_m$ is never stored as a bare number. It is stored as a **normalized probability plus a quality record** — the inputs it was derived from, the rule branch that produced it, its staleness, its spread, and its liquidity context. A divergence observation is only admissible for analysis if its $P_m$ quality record clears pre-registered gates. This converts R7 from a silent contaminant into an explicit, filterable, auditable field.

**Relation to the canonical Open Questions register.** A4 *is* the resolution of **[[Open Questions]] Q2** ("What is the correct market-forecast extraction rule?" — midpoint vs microprice vs last-trade, timestamp convention, wide/crossed/absent quotes), which the register records as **blocking Experiment #1 pre-registration**. A4's §5 also directly addresses **Q7** ("Does quote staleness in thin brackets bias market scores, and in which direction?"). Ratifying A4 (per §13) is therefore the action that moves Q2 to *Answered* and unblocks the first calibration study. A4 does not create a new question register; where it surfaces genuinely new items, §12 marks them as candidates for architect entry into [[Open Questions]].

**What A4 is not.** It is not an attempt to produce the "true" market probability — there may be no single such number in a thin market. It is an attempt to produce a *defined, reproducible, honestly-caveated* one, and to record enough context that the honesty can be checked later.

---

## 2. Inherited Structural Facts (the terrain A4 must handle)

From [[Kalshi Ticker Anatomy and Market Structure]] (Milestone 1a empirical findings) and [[Kalshi API]]. A4 does not re-derive these; it inherits them and designs around them.

- **Ticker format** `SERIES-DATE-TYPE`, e.g. `KXHIGHTPHX-26JUL04-B110.5` (bracket) and `-T111` (threshold). Five series: `KXHIGHTPHX`, `KXHIGHNY`, `KXHIGHCHI`, `KXHIGHMIA`, `KXHIGHAUS`.
- **Quotes exist without trades.** A settled bracket showed `price_close: None` but live `yes_bid: 0.0000 / yes_ask: 0.0100` with nonzero open interest. **Consequence for A4: last-trade is not the default input** — bid/ask midpoint is, because last-trade is stale or absent in exactly the thin brackets that matter most.
- **Brackets are one observation.** ~6 contracts per city-day resolve from a single temperature draw ([[Effective Sample Size]]). A4 therefore normalizes at the *ladder* level, not the contract level — the object produced is a discrete distribution over brackets, not six independent probabilities.
- **Price fields are `_dollars` (exact decimal strings) and `_fp` (fixed-point).** Legacy integer fields removed post-March-2026. Pipeline stores prices as TEXT; raw JSON always preserved. **A4 arithmetic operates on exact decimals, never floats**, to avoid rounding artifacts that could themselves masquerade as divergence.
- **Settlement source is the NWS Daily Climate Report (DCR)** for one named station per city, in **local standard time** (window shifts under DST). Station mapping is per-market, verified in `config.yaml`, untrusted until flipped. *(This resolves the settlement-source open question that the [[Edge Detection]] doc left flagged — DCR, not max-hourly, per this note. A4 assumes DCR; A6 owns adjudication.)*
- **Recoverability asymmetry.** Kalshi prices are retroactively recoverable via `/historical/` candlesticks (1min/1hr/1day); NWS forecasts are not. This matters to A4 only insofar as it means the *price* side of a historical divergence can be reconstructed — but candlestick OHLC may *not* preserve the bid/ask depth A4 needs, which is precisely the A3 gap flagged in the KT document (candlesticks alone cannot support A4).

---

## 3. Decision 1 — Point-Estimate Rule (mid vs. microprice vs. last-trade)

*This section resolves [[Open Questions]] Q2. The [[Glossary]] already records the **Midpoint** as the default probability proxy "because last trade is stale in thin brackets," with the exact extraction rule explicitly deferred to Q2 — this section supplies that rule, consistent with the Glossary default.*

**The candidates.**
- **Last-trade price** — the price of the most recent execution. *Rejected as default:* stale or absent in thin brackets (inherited fact); using it silently imports arbitrary-age information.
- **Midpoint** $\text{mid} = \tfrac{1}{2}(\text{bid} + \text{ask})$ — simple, always defined when both quotes exist, symmetric. *Weakness:* ignores which side has size; in an imbalanced book the "fair" price is not the midpoint.
- **Microprice** $\text{micro} = \dfrac{\text{ask}\cdot V_{\text{bid}} + \text{bid}\cdot V_{\text{ask}}}{V_{\text{bid}} + V_{\text{ask}}}$ — depth-weighted, leans toward the side with more size, closer to the next-trade expectation in microstructure theory. *Weakness:* requires depth; degenerates to mid when sizes are equal or unknown; can be unstable when one side is nearly empty.

**Pre-registered rule (proposed).** Record **all three** wherever the data exists; designate the **midpoint as the canonical** $P_m$ for scoring, with the microprice recorded as a companion field for sensitivity analysis. Rationale: the midpoint is the most robust and least assumption-laden estimator in a market where depth is often one contract deep or absent; the microprice is retained so a later study can test whether depth-weighting changes any divergence conclusion (a pre-registered robustness check, not a post-hoc switch). Last-trade is recorded for reference only, never scored.

**Fallback cascade** (deterministic, ordered — the first that succeeds wins, and the branch taken is recorded):
1. Both bid and ask present → **midpoint**. (Canonical.)
2. One-sided quote only (e.g. `bid=0.00, ask=0.01`, the observed tail case) → use the **midpoint of the available one-sided quote against the natural bound** ($0$ or $1$), i.e. a `0.00/0.01` book → $P_m = 0.005$, flagged `one_sided=true`. This is the market pricing a tail bracket as near-impossible; it is information, not absence.
3. No live quote, last-trade present and within staleness window (§5) → **last-trade**, flagged `source=last_trade`.
4. Nothing within window → **no admissible $P_m$**; the city-day bracket is recorded as `unpriced`, not imputed. An unpriced bracket propagates to ladder handling (§6).

**Recorded fields per bracket:** `p_mid`, `p_micro` (nullable), `p_last` (nullable), `p_canonical`, `source_branch`, `one_sided` flag.

---

## 4. Decision 2 — Fee Incorporation

**The fact.** Kalshi charges a trading fee that is a **function of price and contract count**, not a flat rate. A fee schedule of the general shape $\text{fee} \propto c\,(1-c)$ per contract (maximized near $c=0.5$, near-zero in the tails) is the widely-reported form. **This exact formula and its coefficients are E4 and must be confirmed against Kalshi's current published schedule before ratification** — the fee regime has changed before (the March-2026 field change) and could again.

**The design question A4 answers:** does the fee enter $P_m$ itself, or is it recorded separately?

**Pre-registered rule (proposed).** Keep $P_m$ **fee-free** — it is a *probability estimate*, and a probability should not be contaminated with a cost that depends on trade direction and size. Instead, record the fee as a **separate cost band** alongside $P_m$: `fee_yes`, `fee_no` (the fee to acquire a YES vs a NO at the current price), computed from the confirmed formula at the canonical price. Rationale: divergence is measured on probabilities ($P_f$ vs $P_m$), and cost is applied *later*, at the [[Edge Detection]] §2.4 net-edge stage and the V2 paper-ledger stage, where it belongs. Folding fees into $P_m$ would make the market's "probability" direction-dependent and would double-count cost when the net-edge calculation applies it again.

**What this guards.** It keeps the two questions separate — *"do the probabilities disagree?"* (A4's $P_m$) and *"does the disagreement survive costs?"* ([[Edge Detection]] net edge) — which the Master Spec §11 edge-validation ladder requires to be answered in order, not conflated.

---

## 5. Decision 3 — Staleness Handling

**Why it is load-bearing.** A quote's age is measured against **event time**, not ingestion time (the dual-timestamp architecture exists for this). A midpoint from a quote last updated hours ago, in a market where the forecast has since changed, is not a current probability — it is a fossil, and scoring it as $P_m$ manufactures divergence from a model that *has* updated. This is a primary R7 mechanism.

**The timestamps in play.**
- `quote_event_time` — when the quote was current on the exchange.
- `ingestion_time` — when the collector recorded it.
- `cutoff_time` — the pre-registered analysis cutoff for the city-day (the "as-of" moment a forecast and price are compared).
- `last_trade_time` — event time of the most recent execution.

**Pre-registered rule (proposed).**
- Define **quote staleness** $= \text{cutoff\_time} - \text{quote\_event\_time}$.
- Two thresholds, both recorded, both pre-registered (candidate values, to be set from observed update frequencies in the first weeks of collection — **the values below are placeholders pending that empirical calibration**):
  - **Soft threshold** (e.g. 15 min): quote is used but flagged `stale_soft=true`; admissible for analysis but separable in any study.
  - **Hard threshold** (e.g. 60 min): quote is treated as **no live quote** → cascade falls through to last-trade (itself staleness-checked) or `unpriced`.
- **Last-trade staleness** uses its own hard threshold; a last-trade older than it is never used.
- Every $P_m$ carries `quote_staleness_seconds` and the two flags. **No staleness filtering is applied at normalization time beyond the hard-cutoff fallthrough** — soft-stale quotes are *kept and flagged*, and the decision to include/exclude them is made in the pre-registered study, not silently here. A4's job is to *measure and record* staleness, not to unilaterally discard.

**Rationale for "record, don't discard."** Discarding at normalization time bakes a judgment into the data that cannot be revisited. Recording the staleness as a field lets Study 1 pre-register its own staleness inclusion rule and lets a robustness check vary it — the honest, reproducible pattern.

---

## 6. Decision 4 — Bracket-Ladder Coherence (incomplete coverage & sum-to-one)

**The structural constraint.** The brackets of one city-day partition the temperature axis. If they are mutually exclusive and exhaustive, the "YES" prices of the ladder should sum to approximately $1$ (the excess over $1$ is the market's aggregate overround / fee-and-spread cushion, analogous to a bookmaker's vig). Two things go wrong in thin markets: **incomplete coverage** (some brackets have no admissible $P_m$ — the `unpriced` case) and **sum-to-one violation** (the priced brackets sum to something materially off $1$).

**Pre-registered rules (proposed).**

*Coverage classification*, recorded per city-day:
- `complete` — every bracket in the ladder has an admissible $P_m$.
- `partial` — some brackets `unpriced` but the priced ones span the model's plausible mass.
- `insufficient` — unpriced brackets fall where the model places non-trivial mass → the ladder cannot support an honest distributional comparison.

*Sum-to-one handling.* Record the **raw ladder sum** $\Sigma = \sum_i P_{m,i}$ (canonical prices, priced brackets only) as a field on every city-day. Then produce **two** distributions:
- **Raw** — the unnormalized canonical prices, preserved exactly.
- **Renormalized** — $\tilde P_{m,i} = P_{m,i} / \Sigma$, the proper distribution used for distributional scoring (RPS).

Both are stored; scoring uses the renormalized distribution, but the raw sum $\Sigma$ is retained because **$\Sigma$'s deviation from $1$ is itself a diagnostic** — a large deviation flags either a real overround (information about market friction) or a collection/coverage bug (information about data quality). Per the [[Edge Detection]] Category-4 note, *a ladder that doesn't sum to ~1 signals a normalization or collection bug at least as often as a real edge* — so $\Sigma$ is a first-class data-quality sentinel, not a nuisance to be normalized away silently.

*Admissibility gate.* A city-day classified `insufficient`, or with $|\Sigma - 1|$ beyond a pre-registered band (candidate: outside $[0.95, 1.15]$ — placeholder pending observed overrounds), is **recorded but marked inadmissible for divergence scoring**, with the reason. It is not deleted; the KT reproducibility principle requires the raw record to survive.

**What A4 deliberately does not do.** It does not *repair* an incoherent ladder by imputing missing brackets from the model — that would leak the model into the market rung and destroy the independence the whole comparison depends on. Missing is recorded as missing.

---

## 7. Decision 5 — Liquidity Metadata (recorded alongside every $P_m$)

The R7 mitigation named in the Master Spec is explicit: *liquidity metrics are collected alongside prices.* A4 pins the list. Every $P_m$ record carries, where the API exposes it:

| Field | Definition | Purpose |
|---|---|---|
| `spread` | `ask − bid` (canonical price units) | Primary uncertainty/cost proxy; wide spread → low-trust $P_m$ |
| `bid_depth`, `ask_depth` | Size at top of book each side | Microprice input; execution feasibility |
| `depth_total` | Sum of visible size | Thinness gate |
| `order_imbalance` | $(V_{\text{bid}} - V_{\text{ask}})/(V_{\text{bid}} + V_{\text{ask}})$ | Directional pressure; microprice lean |
| `open_interest` | Outstanding contracts | Market seriousness even without trades |
| `volume_window` | Contracts traded in the analysis window | Trade-based liquidity |
| `quote_staleness_seconds` | From §5 | Fossil-quote guard |
| `one_sided`, `stale_soft` | Boolean flags | Fast filtering |
| `ladder_sum` $\Sigma$ | From §6 | Coherence sentinel |
| `coverage_class` | From §6 | Distributional admissibility |

**The single most important consequence:** because these travel with every $P_m$, any divergence observation the Lab later produces can be re-examined and asked *"is this real, or is it thin-market noise?"* — after the fact, on the recorded evidence, without re-collecting anything. That capability is the entire point of A4. A divergence that survives filtering on spread, staleness, coverage, and $\Sigma$ is a candidate phenomenon; one that does not is R7 caught before it wastes a study.

---

## 8. The Normalization Pipeline (deterministic order of operations)

Pre-registered sequence, per city-day, per cutoff. Determinism is the requirement — same inputs must always yield the same $P_m$ record.

1. **Gather** all bracket quotes for the city-day event as of `cutoff_time`, with all four timestamps and full book where available.
2. **Per bracket:** compute `p_mid`, `p_micro`, `p_last`; apply the §3 fallback cascade to set `p_canonical` and `source_branch`; set `one_sided`.
3. **Staleness (§5):** compute `quote_staleness_seconds`; apply soft/hard thresholds; re-run cascade if hard-stale; set flags.
4. **Fees (§4):** compute `fee_yes`, `fee_no` at `p_canonical` from the confirmed schedule; store separately — do **not** alter `p_canonical`.
5. **Liquidity (§7):** compute and attach all liquidity metadata.
6. **Ladder (§6):** compute $\Sigma$; classify coverage; build **raw** and **renormalized** distributions; set admissibility.
7. **Emit** the city-day normalization record (append-only, dual-timestamped, raw JSON retained per [[Kalshi API]] discipline). Nothing is imputed; nothing incoherent is silently repaired; every branch taken is recorded.

The output is one **market-rung record** per city-day-cutoff: a renormalized bracket distribution for scoring, plus the raw distribution, plus the full quality/liquidity envelope, plus admissibility.

---

## 9. Interaction with the Rest of the Lab

- **A3 (Collection Sufficiency Audit)** — A4 is A3's requirements document for the market side. Every field in §7 that A3 finds *not currently captured* (candidly, at least bid/ask depth if OHLC-only) is a **non-backfillable gap** to fix immediately, because normalization of historical data is only as rich as what was stored. A4 and A3 share a session precisely because each defines the other.
- **[[Edge Detection]]** — A4 produces $P_m$; Edge Detection consumes it. The fee band A4 records is applied at Edge Detection §2.4; the coherence check there (Category 4) *is* A4's $\Sigma$ sentinel.
- **A1 (Statistical Validity)** — the admissibility flags A4 emits feed A1's effective-sample-size and inclusion machinery; a city-day marked inadmissible here is excluded there, by rule, before scoring.
- **A10 (Study 1 Pre-Registration)** — imports A4 by reference and pins the *study-level* inclusion rules (which staleness flag to admit, which $\Sigma$ band), which A4 deliberately leaves to the study rather than hard-coding.
- **Prediction Ledger** — market-rung records enter the ledger alongside model-rung forecasts, both dual-timestamped, both scored post-resolution against the DCR outcome.

---

## 10. Pre-Registered Parameters (the values that must be fixed before data is scored)

These are the free parameters A4 removes by fixing them in advance. **All values below are candidates to be set from the first collection weeks' observed distributions and confirmed against Kalshi's published fee schedule; they are placeholders, not commitments, until the ADR is ratified.** Recording them here as an explicit table is the point — after ratification, changing any of them requires a new ADR and retraction sweep, not a silent edit.

| Parameter | Candidate value | Set from |
|---|---|---|
| Canonical point estimate | Midpoint | §3 rationale |
| Soft staleness threshold | 15 min | Observed quote update frequency |
| Hard staleness threshold | 60 min | Observed quote update frequency |
| Last-trade staleness limit | 60 min | Observed trade frequency |
| Fee formula | Kalshi published schedule | **Must confirm — E4** |
| Sum-to-one admissibility band | $[0.95, 1.15]$ | Observed overrounds |
| Coverage `insufficient` rule | Unpriced bracket holds model mass > ε | A2 model mass placement |
| Renormalization | Divide by $\Sigma$ | §6 |

---

## 11. Failure Modes A4 Is Designed to Prevent

1. **The tunable-price artifact (R7 core).** Choosing mid/micro/last after seeing results → removed by pre-committing the cascade.
2. **Fossil quotes.** Scoring hours-old quotes against updated models → caught by staleness fields and hard-cutoff fallthrough.
3. **Fee double-counting or contamination.** Baking fees into $P_m$ then applying them again at net-edge → prevented by keeping $P_m$ fee-free and recording the band separately.
4. **Silent ladder repair.** Imputing missing brackets from the model → forbidden; independence preserved; missing recorded as missing.
5. **Overround mistaken for edge.** A ladder summing to 1.12 read as free money → $\Sigma$ recorded, renormalization explicit, band gate applied.
6. **Float rounding masquerading as divergence.** Exact-decimal arithmetic mandated on `_dollars` strings.
7. **Data-quality bug read as inefficiency.** $\Sigma$ deviation and coverage class flag collection failures as such, not as phenomena.

---

## 12. Open Questions Raised by A4

Candidates for the canonical [[Open Questions]] register, labeled **A4-Q#** here to avoid collision with the register's own Q1–Q7 numbering. (A4 itself *resolves* canonical Q2 and addresses Q7 — see §1; the items below are additional.)

- **A4-Q1.** What are the true observed quote-update and trade frequencies per city? — sets the staleness thresholds; unanswerable until collection runs. (Related to canonical Q5, time-to-settlement.)
- **A4-Q2.** Does the Kalshi API expose full book depth, or only top-of-book / OHLC? — determines whether microprice and depth metrics are even computable for accrued history (the A3 gap). *Highest urgency — non-backfillable.*
- **A4-Q3.** What is the current, exact Kalshi fee schedule? — E4; blocks §4 ratification.
- **A4-Q4.** What is the empirical distribution of $\Sigma$ (overround) across city-days? — sets the admissibility band; also a genuine finding about weather-market friction.
- **A4-Q5.** Do the five cities differ enough in liquidity that per-city thresholds are warranted rather than one global set? — a normalization-uniformity question.
- **A4-Q6.** How often are ladders `insufficient`, and does insufficiency correlate with the tail brackets where the model is weakest (the KT "sharp center, fabricated tails" concern)? — if so, divergence and inadmissibility concentrate together, with consequences for A1.

---

## 13. Ratification Checklist (Definition of Done)

Before this leaves draft and is stamped canonical (per Invariant 3, architect action):

- [ ] Fee formula confirmed against Kalshi's published schedule and cited with snapshot (Invariant 4).
- [ ] A3 audit confirms every §7 field is captured, or the collector is amended and the gap dated.
- [ ] Staleness thresholds set from ≥2 weeks of observed update frequencies, not placeholders.
- [ ] Sum-to-one band set from observed overround distribution.
- [ ] Depth availability (A4-Q2 above) resolved — microprice fields either populated or explicitly marked unavailable for the accrued era.
- [ ] Ratified as an ADR with a decision record, superseding no prior normalization assumption silently.
- [ ] Cross-checked against A1's inclusion machinery for consistent admissibility semantics.

*Until every box is checked, $P_m$ records produced under this spec are provisional and any divergence computed from them is exploratory, never load-bearing.*

---

## 14. References

**All E4 until human-verified per Invariant 3.** Structural facts inherited from the cited vault notes carry those notes' grades.

- [[Kalshi Ticker Anatomy and Market Structure]] — Milestone 1a empirical findings (ticker format, quote-without-trade, field regime, DCR settlement).
- [[Kalshi API]] — endpoint and field documentation; `_dollars`/`_fp` regime; historical/candlestick tiers.
- [[Research Lab Master Specification]] §5 Step 4, §10 R7 — normalization requirement and the risk it guards.
- [[Institutional Knowledge Transfer v1]] §candidate-losses — the A3/A4 collection-gap dependency (bid/ask depth non-backfillable).
- Pre_Implementation_Artifact_Roadmap_v1 §A4 — scope definition (mid vs. microprice vs. last-trade; fees; staleness; coverage; sum-to-one; liquidity).
- Microprice / order-imbalance microstructure lineage — Kyle (1985), Stoll (1989), and the depth-weighted fair-price literature (confirm specific citations at Lit-note stage).
- Overround / vig in betting markets — standard bookmaking references; connect to favorite–longshot literature already in [[Proper Scoring Rules and Calibration - Technical Reference]] (Thaler & Ziemba 1988; Snowberg & Wolfers 2010).

---

## Next topic (queued)

**[[Statistical Validity and Inference Framework]]** (artifact A1) — the highest-scored Tier-1 artifact: effective-sample-size estimation under cross-city and temporal correlation, paired-differential machinery with date-block resampling, the multiplicity policy, minimum-n/decidability rules, and pre-committed reliability-diagram binnings. It is the inference layer that [[Edge Detection]] §7 and A4's admissibility flags both feed into, and per the roadmap it is the one artifact that *could not be approximated by a weaker model* — if only one frontier session remained, it goes here. Type **continue** to draft it.

*Alternative queued topic:* **[[Forecast to Probability Conversion]]** (A2 + A8) — the model rung: turning an NWS point forecast into an honest bracket distribution, confronting the "sharp center, fabricated tails" residual-depth problem before Study 1 does.
