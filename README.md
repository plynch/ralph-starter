# Ralph Starter

Minimal starter repo for a Codex-driven Ralph loop.

The intended shape is simple: each pass deterministically loads a small set of durable files from disk, completes one bounded slice, writes back the new truth, and exits before the session gets bloated enough to need compaction.

## Operating Model

- Keep durable context small and explicit: `specs/*.md` in lexical order, `IMPLEMENTATION_PLAN.md`, `AGENTS.md`, the active prompt file, and any setup files that actually exist.
- One pass should do one reviewer-visible thing only. If more work appears, record it on disk and let the next fresh pass pick it up.
- Prefer strong backpressure with terse success output and detailed failure output.
- Use non-interactive runs when the agent should keep moving on its own. Use interactive runs when it should stop and wait for a human answer.
- If a session starts sprawling across too many files, decisions, or failures, stop and hand off to the next fresh context window.

## Files

- `specs/*.md`: source of truth for product intent and scope
- `IMPLEMENTATION_PLAN.md`: durable execution memory
- `AGENTS.md`: durable build, run, and validation rules
- `PROMPT_plan.md`: planning loop instructions
- `PROMPT_build.md`: implementation loop instructions
- `loop.sh`: runner for repeated Codex plan/build passes

## Quick Start

There is no quick start. Read all the background reading. But if you insist:

1. Fill in `specs/00-project.md`.
2. Replace the placeholder commands in `AGENTS.md`.
3. Adjust `IMPLEMENTATION_PLAN.md` for the first real slice.
4. Make the loop runner executable:

```bash
chmod +x ./loop.sh
```

5. Run one planning pass (--ask flag helpful here):

```bash
./loop.sh plan 1 --ask
```

6. Run one build pass:

```bash
./loop.sh build 1
```

7. Only after the proof loops are trustworthy, allow repeated unattended build passes:

```bash
./loop.sh build 0 high
```

8. Edit either prompt while the loop is running. Ralph will pick it up next run.

(This is the part of the workflow I'm adjusting to. "Human on the loop" instead of "Human in the loop")

## Codex Usage

- Default mode uses `codex exec` for a fresh non-interactive run per iteration.
- `--ask` uses the interactive `codex` CLI when a run should stop and wait. `--interactive` remains an alias.
- If your local workflow splits these into separate wrappers such as `codex-exec` and `codex`, consider teaching `loop.sh` separate binaries before cloning this starter into a real project.

## Notes

- Add `STOP` to the top of `PROMPT_plan.md` or `PROMPT_build.md` for a graceful stop.
- The loop stops after an idle iteration by default if the repo remains unchanged.

## More Reading

- [Geoff Huntley: everything is a ralph loop](https://ghuntley.com/loop/)
- [Geoff Huntley: don’t waste your back pressure](https://ghuntley.com/pressure/)
- [Clayton Farr: The Ralph Playbook](https://github.com/ClaytonFarr/ralph-playbook)
- [HumanLayer: Context-Efficient Backpressure for Coding Agents](https://www.hlyr.dev/blog/context-efficient-backpressure)
- [HumanLayer: A Brief History of Ralph](https://www.hlyr.dev/blog/brief-history-of-ralph)
- [HumanLayer: Skill Issue: Harness Engineering for Coding Agents](https://www.hlyr.dev/blog/skill-issue-harness-engineering-for-coding-agents)
