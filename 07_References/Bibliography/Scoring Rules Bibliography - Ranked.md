# Scoring Rules & Calibration — Ranked Core Bibliography

**Vault location:** `09 Resources/Research Papers` (cross-link from `01 Research/Probability/Proper Scoring Rules & Calibration`)
**Created:** 2026-07-04
**Ranking criterion:** influence on the field itself (foundational status + how much subsequent work stands on it), with project relevance assessed separately per entry. Project relevance and field influence are *not* the same axis — the list makes both explicit.
**Honesty note (project rules):** "influence" judgments reflect the standard view of the forecast-verification and decision-theory literature as of my knowledge; bibliographic details are canonical and stable but should be spot-checked against the originals when filed. Difficulty is rated ▲ (accessible) to ▲▲▲▲▲ (specialist).

---

## 1. Gneiting & Raftery (2007) — "Strictly Proper Scoring Rules, Prediction, and Estimation," *JASA*

**Why influential:** The modern synthesis. Unified fifty years of scattered results — Brier, Good, Savage, Matheson–Winkler — into one framework (the convex-entropy/Savage representation as the organizing principle), formalized CRPS and energy scores for distributions, and became the default citation for "proper scoring rule" across statistics, machine learning, and meteorology. Nearly every subsequent paper on forecast evaluation cites it.
**Difficulty:** ▲▲▲▲ — dense JASA-style measure-theoretic statistics; readable in parts without full rigor.
**Prerequisites:** Probability theory, convexity, comfort with expectation notation; measure theory helps but sections are skimmable without it.
**Project relevance:** Maximum. It is the formal backbone of our Technical Reference note — the tangent-line characterization, CRPS, and propriety theory all live here.
**Required reading?** **Yes — but strategically:** Sections 1–3 (definitions, characterizations, binary/categorical cases) required; the continuous/spatial machinery is reference material until we score full temperature distributions.

## 2. Gneiting, Balabdaoui & Raftery (2007) — "Probabilistic Forecasts, Calibration and Sharpness," *JRSS-B*

**Why influential:** Crystallized the **"maximize sharpness subject to calibration"** paradigm that now defines what a good probabilistic forecast *is*. Introduced the modern taxonomy of calibration (probabilistic, marginal, exceedance) and the PIT-histogram diagnostic toolkit. The conceptual companion to #1: one paper says how to score, this one says what to aim for.
**Difficulty:** ▲▲▲ — more conceptual than #1; the ideas carry even where proofs are skipped.
**Prerequisites:** Basic probability; familiarity with CDFs and quantiles.
**Project relevance:** Maximum. The calibration-diagnosis half of our methodology (reliability diagrams, sharpness assessment) is this paper operationalized.
**Required reading?** **Yes, in full.** The single best pages-to-insight ratio on this list.

## 3. Brier (1950) — "Verification of Forecasts Expressed in Terms of Probability," *Monthly Weather Review*

**Why influential:** The origin. A two-page note by a U.S. Weather Bureau scientist that gave forecasting its first workable proper score and started the entire verification tradition — in *weather*, which is why meteorology remains decades ahead of most fields at probability evaluation. Influence measured in descendants: everything else on this list exists downstream of it.
**Difficulty:** ▲ — genuinely easy; 1950s applied-meteorology prose.
**Prerequisites:** None beyond arithmetic.
**Project relevance:** High historically, modest technically — the modern treatments supersede its content, but reading the original takes fifteen minutes and grounds the vocabulary.
**Required reading?** **Yes** — on effort-to-value grounds alone.

## 4. Murphy (1973) — "A New Vector Partition of the Probability Score," *Journal of Applied Meteorology*

**Why influential:** The reliability–resolution–uncertainty decomposition. Turned the Brier score from a grade into a *diagnosis*, separating "are you honest?" from "are you informative?" — the analytical move that makes score-driven model improvement possible. Allan Murphy's broader verification corpus (including "What Is a Good Forecast?", 1993) shaped the field's entire conceptual vocabulary.
**Difficulty:** ▲▲ — algebra, patiently done.
**Prerequisites:** The Brier score; binned-data thinking.
**Project relevance:** Very high. The decomposition is our primary model-diagnosis tool and the basis for Experiment #1's analysis plan.
**Required reading?** The decomposition, yes — **via a modern textbook treatment (#6) rather than the original**, which is of historical rather than pedagogical value. Optional as a primary source.

## 5. Savage (1971) — "Elicitation of Personal Probabilities and Expectations," *JASA*

**Why influential:** Put propriety on rigorous decision-theoretic footing — the convex-function representation, the equivalence between scoring rules and honest elicitation of subjective belief. Connected forecasting to the subjective-probability program (de Finetti, Savage's own foundations), making scoring rules a pillar of Bayesian decision theory rather than a meteorologists' trick. Schervish (1989) and much of modern elicitation theory build directly on it.
**Difficulty:** ▲▲▲▲ — classic Savage: careful, dense, philosophical and mathematical at once.
**Prerequisites:** Decision theory basics, expected utility, convexity.
**Project relevance:** Moderate-direct, high-foundational. We use its *results* daily; we rarely need its proofs.
**Required reading?** **No** — reference. Read if the "why is honesty optimal?" question ever needs first-principles resolution.

## 6. Jolliffe & Stephenson (eds.) — *Forecast Verification: A Practitioner's Guide in Atmospheric Science* (2nd ed., 2012)

**Why influential:** *The* applied handbook of the field that invented forecast verification. Standard desk reference in every national weather service; the place where scores, decompositions, skill scores, confidence intervals for scores, and diagrams are presented as usable procedures with worked examples rather than theorems.
**Difficulty:** ▲▲ — practitioner-level; designed to be used, not admired.
**Prerequisites:** Intro statistics.
**Project relevance:** Maximum among books — it is applied verification *for weather*, which is literally our first market category. The chapter on verification of probability forecasts is nearly a manual for Experiment #1.
**Required reading?** **Yes** — probability-forecast and skill-score chapters required; rest as reference.

## 7. Cover & Thomas — *Elements of Information Theory* (2nd ed., 2006), gambling & portfolio chapters

**Why influential:** The standard graduate information-theory text; its Chapter 6 ("Gambling and Data Compression") and portfolio-theory chapter give the rigorous treatment of Kelly betting, log-optimal growth, and the identity between log-wealth growth and KL divergence — the mathematics behind our Kelly–log-score bridge. Made the information-theory ↔ gambling connection (Kelly 1956) canonical for generations of quants.
**Difficulty:** ▲▲▲▲ — real graduate textbook; proofs expected to be followed.
**Prerequisites:** Probability at a mathematical level; entropy/KL basics (the book itself teaches them in Ch. 2).
**Project relevance:** Very high for one specific load-bearing result: *why* log-score edge = growth edge. That identity justifies half our evaluation design.
**Required reading?** **Chapters 2 and 6 required** before any trading milestone; the rest optional. (Reading Kelly's 1956 original alongside is a pleasant bonus, not a requirement.)

## 8. Tetlock & Gardner — *Superforecasting: The Art and Science of Prediction* (2015)

**Why influential:** Brought Brier scores, calibration training, and forecast aggregation to a mass audience via the Good Judgment Project's IARPA-tournament results — the strongest public evidence that calibration is a *trainable skill* and that disciplined amateurs can beat credentialed experts. Shaped how the entire forecasting/prediction-market community talks and thinks; Tetlock's earlier *Expert Political Judgment* (2005) is the scholarly foundation beneath it.
**Difficulty:** ▲ — trade nonfiction.
**Prerequisites:** None.
**Project relevance:** High for the *human* side: it is calibration practice, error culture, and update discipline — the behavioral complement to our mathematical framework. Low for technique.
**Required reading?** **Yes** — precisely because it is the only entry that trains the researcher rather than the model.

## 9. Hanson (2007) — "Logarithmic Market Scoring Rules for Modular Combinatorial Information Aggregation," *Journal of Prediction Markets*

**Why influential:** Founded automated market making for prediction markets. The LMSR — a market maker that *is* a shared sequential log scoring rule, where each trader's profit equals the log-score improvement their trade contributes — became the default mechanism for a generation of prediction platforms and the theoretical lens for "markets as forecast aggregators." The deepest formal link between this note's two worlds.
**Difficulty:** ▲▲▲ — clear writing, moderate math (convexity, softmax pricing).
**Prerequisites:** Proper scoring rules (this topic), basic mechanism-design intuition helps.
**Project relevance:** Moderate-high conceptually (why "beat the market" = "out-score the market" is structural, not metaphorical), low operationally — Kalshi runs an order book, not an LMSR.
**Required reading?** **No** — strongly recommended after the required set; read for the identity, skim the combinatorial machinery.

## 10. Diebold & Mariano (1995) — "Comparing Predictive Accuracy," *Journal of Business & Economic Statistics*

**Why influential:** Gave econometrics its standard hypothesis test for "is forecaster A better than forecaster B?" — inference on loss differentials with autocorrelation-robust variance. Thousands of citations; the DM test is the lingua franca of forecast comparison in economics and finance, later refined by West, Giacomini–White, and others.
**Difficulty:** ▲▲▲ — standard econometrics paper; time-series inference background assumed.
**Prerequisites:** Hypothesis testing, HAC/Newey-West ideas, basic time series.
**Project relevance:** Very high at the *decision gate*: every "model beats market" claim we ever make gets tested in this framework (or its block-bootstrap cousin) with date-clustering.
**Required reading?** The *method*, yes; the paper itself **optional** — a modern econometrics-textbook exposition suffices until we're designing the actual test.

---

## Honorable mentions (cut from the ten, kept on record)

Good (1952) — log score's origin; subsumed by #1. · Schervish (1989) — the decision-theoretic mixture representation; deep, specialist. · Dawid (1982) & Foster–Vohra (1998) — calibration's philosophical limits ("calibration is cheap"); read the two-paragraph summaries in our Technical Reference, go to the sources only if challenged. · Matheson & Winkler (1976) — CRPS origin; content absorbed into #1. · Wolfers & Zitzewitz (2004) and Snowberg & Wolfers (2010) — prediction-market economics and favorite–longshot bias; they head the reading list of the *next* research topic (market efficiency), not this one.

## The distilled required-reading list (in reading order)

1. Brier (1950) — 15 minutes, the origin
2. Tetlock & Gardner — the mindset
3. Gneiting, Balabdaoui & Raftery (2007) — the paradigm
4. Jolliffe & Stephenson, probability-verification + skill-score chapters — the toolbox
5. Gneiting & Raftery (2007), §1–3 — the theory
6. Cover & Thomas, Ch. 2 + 6 — the bridge to money *(gate: before any trading milestone)*

Everything else is reference until a specific decision demands it. Total required load: roughly one book, two papers-in-part, two chapters — a realistic month alongside pipeline operation, not a curriculum fantasy.
