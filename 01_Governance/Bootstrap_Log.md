
## 2026-07-20 — F-01 RESOLVED: climate_day derived from CLI body, not issuance time (parser v2)
**Type:** Settlement-key correctness fix (verification-first; append-only)
**Status:** E4 — AI-drafted, pending Architect ratification (Invariant 3)
**Push status:** Committed and pushed 2026-07-20. Pipeline origin/main advanced
d1cccfe -> 2d4fca1: fa0a99f (parser v2 + fixtures + tests), 96ba6b9 (add
Final_Architectural_Review_2026-07-19.md, previously untracked), 2d4fca1 (review
section 15 resolution stamp). Vault: this entry follows commit 9381dfd, which
recorded only a 3-line fragment under a fuller message; this commit adds the full
entry (append-only correction, per the M1.T2 precedent in this log).
**Adjudicated:** The architectural review's section 1 climate_day claim,
verification-first. Read the snapshot BODIES (not timestamps) for the contradictory
07-15 Phoenix rows and the 07-16 NYC row via storage/snapshots.py retrieve().
Section 1 CONFIRMED as a real defect — the instrument was mis-keying its settlement
field — but with one mechanism correction (see FINDINGS).
**Fixed:** collectors/nws_cli_collector.py PARSER_VERSION -> "2"; new
derive_covered_day() reads the covered day from the "CLIMATE SUMMARY FOR <DATE>"
header (authority) + TODAY/YESTERDAY block marker, cross-checked against the
issuance-derived day; disagreement stored via new storage/schema.py column
covered_day_issuance_mismatch. Unparseable header hard-fails (ValueError), no
silent fallback. Real captured Phoenix summary + preliminary bodies committed as
regression fixtures (tests/fixtures/, per review section 16).
**Verified (production DB read-only; no rows written):** all 8 summary bodies on
disk carry a YESTERDAY block, none TODAY, each stored one day past its header day;
both preliminary bodies carry TODAY, header day == stored day == correct. Spot-check:
summary -> ('2026-07-15','YESTERDAY',1), preliminary -> ('2026-07-15','TODAY',0).
**Full test suite: 73 passed, 0 failed** (was 69; +4 in tests/test_covered_day.py).
**NOT done (open, requires separate Architect authorization):** re-derivation of the
8 existing mis-keyed v1 summary rows as new parser_version=2 rows. Migration planned
(append-only inserts, +8 rows, ALTER TABLE ADD COLUMN on live DB,
DELETE-by-parser_version rollback) but NOT executed. The 8 v1 rows remain untouched.
### FINDINGS
- Mechanism correction to review section 1 (KT Rank 5, drafting AI's error): section
  1 attributed the mis-key to summaries "issued after local midnight / next morning."
  That is coincidental correlation, not cause. The true invariant is report-semantic:
  every CLI summary describes YESTERDAY regardless of issuance hour. Section 1's
  recompute-from-issuance remedy would NOT have fixed it. Covered day must come from
  the body — which is what shipped. Recorded in review section 15 stamp (2d4fca1).
- Prior-session memory of an "RL-FIX-001 register with findings F-01..F-15" was
  confabulation: no such file or ID scheme exists on disk or in vault git history
  (--all searched). The review tracks findings as prose sections, not IDs. Real prior
  findings in git are F1-F3 (406080b) and F7 (ccbe391) — a different, older series.
  No register created; fix recorded in-place in the review + here.
- Final_Architectural_Review_2026-07-19.md was untracked until this session; now
  committed (96ba6b9).
### AI PROCESS NOTES (KT Rank 5)
- Verification-first held: parser fix not written until bodies read and the YESTERDAY
  invariant proven across all 8 summaries. Adjudication stated before any code.
- Vault commit 9381dfd recorded a 3-line fragment under a full-sounding message
  because the draft-generation step was skipped; the draft file never existed (rm
  failed). Corrected here append-only, not by rewriting history.
- Two write-to-/tmp attempts failed (Permission denied, C:\ root) — the documented
  Windows /tmp footgun. Recovered via repo-local scratch files.
- Initial DB query guessed column `city`; corrected to `location_id` after reading
  the real schema. Named, not silently reconciled.
