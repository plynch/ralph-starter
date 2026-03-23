Read `specs/*.md` first in lexical order. That directory is the source of truth.
Then read `IMPLEMENTATION_PLAN.md` and `AGENTS.md`.
If present, also read setup files such as `README.md`, `SETUP.md`, `.env.example`, compose files, and deployment config.
Inspect the repo before assuming missing functionality.

Build only. Work the highest-priority unfinished item from `IMPLEMENTATION_PLAN.md`.
Treat this as one bounded build pass. Finish one slice, persist the new truth, and stop before the session sprawls.

Rules:

1. Implement one bounded slice only.
- Do not jump ahead.
- If the planned feature work is complete, choose at most one bounded polish slice that improves reviewer clarity, deployment confidence, or demoability without expanding scope.
- If finishing the slice exposes follow-up work, record it in `IMPLEMENTATION_PLAN.md` and leave it for the next fresh run.

2. Search first, then change code.
- Confirm whether the behavior already exists before adding it.
- Keep docs, examples, specs, and implementation aligned in the same pass.

3. Use strong backpressure.
- Run the strongest available validation for the changed unit of work.
- Prefer machine feedback over human review.
- If no useful check exists, add the smallest focused proof loop.
- If the slice changes public behavior, add or update targeted proof that exercises it.

4. Do not ship a broken build.
- If validation fails, either fix the failure or document the blocker accurately in `IMPLEMENTATION_PLAN.md`.
- Do not commit or push code that you know does not build or fails the relevant validation.
- Never claim behavior is working unless you verified it.

5. Keep durable memory accurate for the next run.
- Update `IMPLEMENTATION_PLAN.md` with completed work, newly discovered work, and blockers.
- Update `AGENTS.md` only for durable operational learnings.
- Do not rely on long chat history or compaction to carry state. Persist only what the next run needs.

6. End the build run cleanly.
- If files changed and the slice's relevant validation passes, run `git add -A`, commit with a slice-focused message, and `git push`.
- If files changed but validation still fails, do not commit broken work.
- If no files changed, do not create an empty commit.
- Finish with a short human-readable summary:
  - what changed
  - what validation ran
  - what blocker or next slice remains

Keep the prompt efficient: prefer precise edits over broad rewrites.
