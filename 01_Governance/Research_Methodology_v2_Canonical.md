
## Governance
- [[Research Methodology v2_canonical]]
- [[Research_Lab_Master_Specification_v1]]
- [[Master Roadmap]]
- [[Learning Roadmap]]
- [[Pre_Implementation_Artifact_roadmap_v1]]
- [[Current Sprint]]
- [[Decision Log]]
- [[ADR_Collection_v2.0]]
- [[ADR-022 — Vault Folder Scheme (Hybrid)]]
- [[Future_Directions.md]]
- [[Bootstrap_Log]]
# Research Methodology (Canonical)
*Version 2.0 — supersedes v1.0 per ADR-002. This is the canonical research workflow for the project.*
*Review annually, or immediately after any process failure. Last reviewed: 2026-07-04.*

This document defines **how** research is conducted. Any research artifact that does not conform to it is a draft, not a finding. Amendments require an ADR; silent deviations are process failures.

Changes from v1.0, in one line: v2.0 stops trusting its own inputs and its own storage. It adds verification of AI-supplied claims, versioned storage, data snapshots, retraction propagation, a prediction ledger, and machine-queryable maintenance — and removes duplicated state and compliance theater identified in the v1.0 audit (ADR-001).

---

## 0. The Five Invariants

Everything else in this document serves these. If a shortcut violates an invariant, the shortcut is wrong.

1. **Pre-registration.** Expectations are written before results are seen, date-stamped, and append-only.
2. **No orphan findings.** A finding not integrated into the vault does not exist.
3. **Verify before grade.** No claim supplied by an AI session — citation, statistic, quote, or summary of a source — receives an evidence grade above E4 until a human has opened the primary source and confirmed it. AI output is testimony, not evidence.
4. **Snapshot what you cite.** Any data or web content a conclusion depends on is archived locally (or via web archive) with date of capture at time of use. A live URL is a courtesy, not provenance.
5. **Retract downstream.** Deprecating a note requires walking its backlinks and flagging every dependent conclusion for re-review before the deprecation is complete.

---

## 1. Infrastructure (prerequisite, not optional)

**1.1 Version control.** The vault is a Git repository with automated commits (daily minimum, plus after any Stage 6 integration) and at least one off-machine remote or backup. A knowledge base without versioned backup is a single point of failure; no research proceeds until this exists.

**1.2 Data store.** A `Data/` directory inside the repo (or alongside it if files are large) holds snapshots: raw files named `YYYY-MM-DD — source — description`, each with a capture date and, for anything load-bearing, a checksum recorded in the note that uses it. Web pages are saved via web archive or local snapshot at time of citation.

**1.3 Query plugin.** The vault uses one query plugin (Dataview or equivalent) for exactly three jobs: surfacing notes past their review date, listing open questions by status, and rendering the prediction ledger. Without machine queries, review dates and the decay system are decorative. No other plugins are adopted without an ADR.

**1.4 Environment capture.** Any computational experiment records language/package versions and random seeds in the experiment note. AI-assisted analysis records the model and date, and the full session transcript is exported into `Transcripts/` and linked from the note it produced — summaries preserve conclusions, transcripts preserve the reasoning path.

---

## 2. The Research Lifecycle

Every topic passes through these stages. Killing a topic early is a success. Each stage has an artifact; if the artifact doesn't exist, the stage didn't happen.

| Stage | Name | Artifact | Kill criterion |
|---|---|---|---|
| 0 | Intake | Line in Research Backlog | Not decision-relevant |
| 1 | Framing | Research Brief (falsifiable question, motivation, track assignment) | Cannot be stated falsifiably |
| 2 | Literature & prior art | Lit notes | Already answered — adopt, don't redo |
| 3 | Evidence gathering | Source inventory + snapshots (Invariant 4) | No credible evidence obtainable |
| 4 | Analysis / experiment | Experiment note with pre-registration (Invariant 1) | Unmeasurable or unreproducible |
| 5 | Synthesis | Research Summary with confidence + ledger entries | — |
| 6 | Integration | Vault update, links, contradiction sweep, MOC update, Git commit | — |
| 7 | Maintenance | Review date set; status `evergreen`/`decaying`/`deprecated` | — |

**Track assignment (Stage 1).** Two tracks, assigned by *stakes*, not effort:
- **Full track** — anything that could become load-bearing for a real decision, however small the question looks. All stages, all templates.
- **Exploratory track** — background learning and curiosity. May skip Stages 2–3 and produce only a short Summary. Invariants 1–5 still apply without exception. A note may not move from exploratory to load-bearing without being upgraded through the full track first; the Summary template's status field enforces this distinction.

---

## 3. Standing Workflow

### 3.1 Selecting topics
All candidates enter one Research Backlog and are scored 1–5 on **Decision relevance**, **Tractability**, and **Durability**. The scoring is a forcing function against novelty-chasing, not a precision instrument — the axes correlate and the weights are even by convention (recorded honestly as such in ADR-002). Work the highest score; park anything below 9/15. Ties and judgment calls are fine; skipping the scoring is not.

### 3.2 Reading literature
Three passes: **Pass 1** (5 min — abstract, conclusions, figures: continue?), **Pass 2** (30 min — data and method: trust?), **Pass 3** (deep — only for sources that survive and bear on a live question). Every source read past Pass 1 gets a Lit note, including rejected sources, with the rejection reason — this is what prevents re-reading the same paper in eight months.

**Source tiers**, descending default trust: (1) peer-reviewed with public data/code, (2) peer-reviewed without, (3) working papers, (4) practitioner books, (5) institutional blogs, (6) forums/social. Two caveats the tiers do not capture: in markets and forecasting, peer review is a weak replication signal, so tier 1–2 status earns Pass 2 attention, never exemption from it; and tier is about the *source*, not the *claim* — a tier-5 post reporting a checkable fact can reach E1 by checking it.

### 3.3 Evidence grades
Every inherited claim is tagged:
- **E1 — Verified:** reproduced or checked against primary data *by the human*.
- **E2 — Corroborated:** two or more *independent* credible sources. Independence means separate underlying data or observation, not two outlets citing one origin. If independence wasn't checked, the grade is E3.
- **E3 — Single-source:** one credible source, unchecked.
- **E4 — Testimony:** unverified assertion — including anything an AI session reported that the human has not confirmed (Invariant 3).

E3/E4 may seed hypotheses; they may never be load-bearing. A conclusion that collapses when its E3/E4 supports are removed is not a conclusion — it is an open question.

### 3.4 Facts vs. assumptions
Every research note carries two never-merged sections: **Facts** (each with source link, grade, and snapshot reference) and **Assumptions** (each with rationale and invalidation condition). If it can't be cited, it goes in Assumptions regardless of how obvious it feels. The largest errors live in "everyone knows."

### 3.5 Uncertainty
Two mechanisms, mandatory in every Summary (v2.0 deliberately cut from v1.0's five overlapping systems):
1. **Numeric confidence** on each key conclusion — numbers can be scored, words cannot.
2. **"What would change my mind"** — the two or three observations that would most move the estimate.
Known unknowns are handled structurally: they go straight into the Open Questions log rather than living as a third section in every note.

**Prediction ledger.** Every resolvable claim with a stated confidence gets a row in `Prediction_Ledger.md` at the moment it's made: claim, confidence, date, resolution date, outcome. The ledger is the raw material for calibration; grading yourself from memory is banned as an instrument.

**Calibration review** runs semi-annually against the ledger. Honest expectation, per the audit: at solo volumes the first several reviews are *directional*, not diagnostic — they can catch gross overconfidence, not fine miscalibration. Treat early numbers accordingly and do not tune the process against noise.

### 3.6 Experiments
Before running: hypothesis stated so it can fail; exact data with snapshot references; method; environment capture (§1.4); pre-registered expectation; and a decision rule ("if X, conclude Y; if not-X, conclude Z"). After running: results, surprises, and a **"Ways this could be wrong"** section (data quality, sample size, look-ahead, survivorship, multiple comparisons). Reproducibility standard: a stranger — or you in two years, which is the same reader — can re-run it from the note plus the snapshots. Where AI reasoning is part of the method, the transcript link *is* part of the method record; AI steps are acknowledged as replicable-in-substance, not bit-identical, and any conclusion that depends on an AI step being exactly repeatable is invalid by construction.

### 3.7 Integration (Stage 6 checklist — run in one sitting)
1. Create/update the Research Summary.
2. Link it bidirectionally to every note it draws on or bears on.
3. **Contradiction sweep:** search the vault for the Summary's key terms and check the relevant MOC — do not rely on memory. If a contradiction is found, resolve it *now*: deprecate one note or downgrade the new finding. Two live contradictory notes are never left standing.
4. If anything was deprecated, execute Invariant 5: walk backlinks, flag dependents with `#needs-rereview`.
5. Update the theme MOC.
6. Add ledger rows for any new resolvable claims.
7. Git commit with a message naming the Summary.

### 3.8 Decisions (ADRs)
Any choice that shapes future work — methodology change, tool, definition, source trust ruling — gets an ADR. Append-only; reversals get a new superseding ADR. The bar is "shapes future work": adding a tag or renaming a note does not need an ADR (v1.0's requirement to that effect trained ADR-ignoring and is removed).

### 3.9 Maintenance
Weekly, run the review-date query (§1.3). A note past its review date is treated as E3 at best until re-verified. Anything tagged `#needs-rereview` outranks new topics in the queue — propagated errors compound faster than missing knowledge.

---

## 4. Templates

State lives in **frontmatter fields only** — tags are not used for status (v1.0 duplicated state in both; duplicated state drifts).

### 4.1 Literature Review
```markdown
---
type: lit
tier: 1-6
verdict: adopt | corroborate | reject | hypothesis-only
date-read:
---
# Lit — [Source Title]
Source: [citation + link + snapshot ref]

## Core claims (each graded E1–E4; independence noted for any E2)
## Methodology assessment — data, period, method, weakest link
## What I doubt
## What this changes in the vault (links)
```

### 4.2 Decision Log (ADR)
```markdown
---
type: adr
status: proposed | accepted | superseded
supersedes:
---
# ADR-NNN — [Title]
## Context — the problem that forced a decision
## Options — including "do nothing"
## Decision
## Rationale
## Consequences — commitments made, things made harder
## Revisit trigger — the observable event that reopens this
```

### 4.3 Research Summary
```markdown
---
type: summary
track: full | exploratory
status: evergreen | decaying | deprecated
review-by:
confidence-entries-in-ledger: yes | none
---
# Summary — [Topic]
Question: [one sentence, falsifiable]

## Bottom line — one paragraph; every conclusion carries numeric confidence
## Facts (source, grade, snapshot ref)
## Assumptions (rationale, invalidation condition)
## Evidence and reasoning
## Steelman of the opposite conclusion — written as if arguing the other side
## What would change my mind
## Open questions spawned → [[Open_Questions]]
## Provenance — experiments, lit notes, transcripts (links)
## Retraction check — if deprecated: backlinks walked on [date], dependents flagged
```

### 4.4 Experiment
```markdown
---
type: experiment
status: planned | run | abandoned
date:
---
# Exp — [Title]
## Hypothesis (falsifiable)
## Data — snapshot refs + checksums
## Method — steps, code, environment (versions, seeds, model+date if AI-assisted)
## Pre-registered expectation — DATE-STAMPED, APPEND-ONLY below this line
---
## Results
## Surprises
## Ways this could be wrong
## Transcript link (if AI-assisted)
```

### 4.5 Open Questions (single vault-wide note)
```markdown
| ID | Question | Origin | Why it matters | Blocking? | Status |
```
Exit only by becoming a Research Brief or being closed with a written reason. When the table passes ~50 open rows, split by theme via ADR — not before.

### 4.6 Prediction Ledger (single vault-wide note)
```markdown
| ID | Claim | Confidence | Date made | Resolves by | Outcome | Notes |
```

### 4.7 Experiment Queue
```markdown
| ID | Hypothesis | Data needed | Effort | Score (D/T/Du) | Status |
```

All seven live in `Templates/`, wired to Obsidian's Templates plugin, so compliance costs a keystroke.

---

## 5. Anti-Fragmentation Doctrine

The practices that keep institutional research coherent over years, as implemented here:

**One system, one format, one naming convention.** Everything funnels to the vault at Stage 6 (Invariant 2). Dated artifacts: `YYYY-MM-DD — Type — Title`; evergreen concepts: plain descriptive titles.

**Written for the stranger.** Every note assumes a reader with no memory of its creation — no "as discussed," full provenance, jargon defined or linked. The stranger is you in two years or a fresh AI session; they are the same reader.

**Negative results are filed** with the same rigor as positive ones. The most expensive failure mode is silently re-running dead ends.

**Findings and decisions are separate record types.** Summaries say what is true; ADRs say what we chose. Merging them makes "we believe X" indistinguishable from "we assumed X for convenience in 2024."

**One canonical answer per question.** The Stage 6 contradiction sweep (by search, not memory) plus immediate resolution keeps the vault trustworthy — a vault with two live contradictory notes teaches you to distrust all of it.

**Decay is managed, not assumed away.** Status fields, review dates, and a weekly query make rot visible. Deprecation propagates (Invariant 5), so retracted findings cannot survive inside derived conclusions.

**MOCs over folders.** One `MOC_Home`, per-theme MOCs once a theme exceeds ~10 notes, updated at every Stage 6.

---

## 6. Known Residual Weaknesses (accepted, monitored)

An honest process names what it did not fix.

**Pre-registration remains unenforceable solo.** Date-stamping and the append-only convention are honor-system; Git history now provides a partial audit trail (edits to expectation sections are visible in diffs), which is the strongest cheap enforcement available. Residual risk accepted.

**Templates can still be filled perfunctorily.** The steelman section raises the cost of hollow compliance but cannot eliminate it. No solo process fully substitutes for adversarial review; the AI red-team step is used with the explicit understanding that it shares the framing's blind spots.

**Calibration feedback is slow and small-sample.** Acknowledged in §3.5; the mitigation is patience, not process.

**Independence checks for E2 are effort-bounded.** E2 is a statement about diligence performed, not a guarantee of independence. When in doubt, grade E3.

**The methodology can still rot.** Mitigations: annual review date, the rule that process failures trigger amending ADRs rather than workarounds, and the fact that the document is now shorter-per-obligation than v1.0. Rejected as unjustified: further process to police the process.

**Audit items rejected, for the record:** collapsing to a single uncertainty mechanism (the change-my-mind list is cheap and directly serves falsifiability); abandoning topic scoring over axis correlation (it is a forcing function, not a measurement); auto-splitting the Open Questions log preemptively (structure trails need).

---

## 7. Bootstrap Checklist (do once, in order)

1. `git init` the vault; configure automated commits and an off-machine remote.
2. Create `Data/`, `Transcripts/`, `Templates/`, `Decision_Log/`.
3. Install the query plugin; add the review-date query, `#needs-rereview` query, and ledger view to `MOC_Home`.
4. Create `Research_Backlog`, `Open_Questions`, `Prediction_Ledger`, `Experiment_Queue`, `MOC_Home`.
5. Write **ADR-000** (adopted methodology v1.0), **ADR-001** (external audit findings — paste the audit), **ADR-002** (adopted v2.0, superseding v1.0, with rationale per audit item).
6. Load the seven templates into the Templates plugin.
7. First Git commit: "Methodology v2.0 canonical."

---

*This document is the canonical research workflow. It is amended only by ADR. Silent deviations are process failures.*
