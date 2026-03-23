Read `specs/*.md` first in lexical order. That directory is the source of truth.
Then read `IMPLEMENTATION_PLAN.md` and `AGENTS.md`.
If present, also read setup files such as `README.md`, `SETUP.md`, `.env.example`, compose files, and deployment config.
Inspect the repo before assuming what exists.

Plan only. Do not implement product code in this pass.
Treat this as one bounded planning pass. Persist the next clean truth to disk, then stop.

Your job:

1. Audit the planning artifacts against `specs/*.md`.
- Separate:
  - source requirements
  - explicit repo decisions
  - open decisions
- If lower-level docs drift from the source brief, fix them before planning from them.

2. Update `IMPLEMENTATION_PLAN.md` into an execution-ready plan.
- Keep it short, prioritized, and source-faithful.
- Plan the thinnest coherent slice first, then optional deeper work.
- Each major item should capture:
  - reviewer-visible outcome
  - verification/backpressure
  - blocker or dependency

3. Do not silently choose major architecture that is still open.
- If a baseline is already documented in the repo, use it.
- If a required choice is unresolved and cannot be safely deferred, ask one concise question.
- Otherwise leave one clean blocker instead of churning.

4. Audit setup and deployment assumptions.
- Keep setup docs aligned with the current plan.
- Do not let the plan outrun the available proof loops.
- If validation is too weak for the planned slice, add the missing proof expectation to `IMPLEMENTATION_PLAN.md`.
- Do not keep refining once the next implementation run is unblocked. Prefer a fresh pass over a bloated session.

5. Leave durable memory accurate for the next run.
- `IMPLEMENTATION_PLAN.md` should reflect current repo state, current decisions, and current blockers.
- `AGENTS.md` stays operational only. Update it only for durable build/run/validation learnings.
- Do not rely on long chat history or compaction. Write the minimum durable state the next run needs.

6. End the planning run cleanly.
- If files changed, run `git add -A`, commit with a planning-focused message, and `git push`.
- If no files changed, do not create an empty commit.
- Finish with a short human-readable summary:
  - what changed
  - open blockers or decisions
  - what the next loop should do

Keep the prompt efficient: prefer precise edits over broad rewrites.
