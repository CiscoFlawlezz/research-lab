# Bootstrap Log

2026-07-04 — Pre-move snapshot created from fully hydrated OneDrive copy and verified by opening a note inside the zip. Stored at: [My Passport D:].

2026-07-04 — Vault relocated from C:\Users\rjkir\OneDrive\Documents\Obsidian\Research Lab to C:\Users\rjkir\Obsidian\Research Lab. Vault opens with all content intact. Old OneDrive copy removed. No OneDrive sync icons on new location.

2026-07-06 — Git for Windows 2.55.0.windows.2 installed. Editor: Notepad. Default branch: main. Line endings: checkout as-is, commit as-is. Credential helper: Git Credential Manager. Identity configured (user.name, user.email). Repository initialized at vault root. .gitignore created (excludes workspace.json, workspace-mobile.json, .trash/, Windows debris).

2026-07-06 — Private GitHub remote created (github.com/CiscoFlawlezz/research-lab). Local main tracks origin/main. First push verified in browser: 2 commits, correct exclusions, Private badge confirmed. Auth via Git Credential Manager (browser flow); credential stored in Windows Credential Manager. 2FA enabled on account.

2026-07-06 — Reconciliation: expected 3 commits, found 2. Root cause: environment-log entry was written before the initial commit and was included in it; the intended separate commit found nothing to commit. Verified local main == origin/main (hashes 0162068, 14ae139). No content loss. Lesson: read git commit output — "nothing to commit" means no commit was created.

Automation test line.