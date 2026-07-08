# ADR-022 — Vault Folder Scheme (Hybrid)
   Date: 2026-07-07 | Status: Accepted | Supersedes: Master Spec §7.2 folder listing (structure only)

   ## Decision
   The vault adopts a hybrid scheme: the function-based workflow folders of
   Master Spec §7.2 (00_MOC, 01_Governance, 02_Glossary, 03_Open_Questions,
   04_Experiments, 05_Research_Summaries, 06_Prediction_Ledger, 07_References,
   08_Archive) plus 09_Journal and a Templates/ folder, with topic-based
   reference material housed as subfolders of 07_References (Concepts,
   Data_Sources, AI_and_Tooling, Bibliography; further subfolders created
   only when content exists).

   ## Context
   Knowledge Architecture Audit v1 (2026-07-07) found the as-built vault
   contradicted §7.2. Pure §7.2 discards useful topic homes; pure topic
   scheme lacks the folders the Methodology's workflow writes into.

   ## Consequences
   - 05 models and 06 code are NOT recreated in the vault; code and models
     live in weather-pipeline per the dual-repository decision.
   - Deviations from §7.2 as written: 09_Journal, References subfolder layout.
   - Deferred with consent: Glossary split to one-note-per-term; ADR
     collection split to one-note-per-ADR (all NEW ADRs, including this one,
     are born as individual notes).