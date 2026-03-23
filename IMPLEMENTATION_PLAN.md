# Implementation Plan

## Current State

- Repo baseline: new starter repo with loop scaffolding only
- Proven working: `./loop.sh --help`
- Missing: product code, setup details, and project-specific validation commands

## Baseline Decisions

- Use `specs/*.md` in lexical order as the source of truth.
- Keep the first slice narrow and reviewer-visible.
- Do not silently harden unresolved architecture into the plan.

## Next Slices

1. Define the first thin product slice
- Reviewer-visible outcome: `[what a reviewer can concretely observe]`
- Verification: `[exact command, test, or smoke proof]`
- Blocker: `[none or blocker]`

2. Add the smallest useful proof loop
- Reviewer-visible outcome: `[what becomes provably true]`
- Verification: `[exact command]`
- Blocker: `[none or blocker]`

3. Add setup and runtime documentation
- Reviewer-visible outcome: `[how a reviewer can run or inspect the project]`
- Verification: `[README or setup walkthrough checked against reality]`
- Blocker: `[none or blocker]`

## Open Blockers

- Fill in project-specific commands and runtime assumptions in `AGENTS.md`.

## Stop Condition

Stop when the current planned slice is implemented, validated, documented, and the durable memory files reflect reality.
