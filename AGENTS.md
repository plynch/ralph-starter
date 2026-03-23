# AGENTS.md

## Build & Run

- Source-of-truth order:
  1. `specs/*.md` in lexical order
  2. `IMPLEMENTATION_PLAN.md`
  3. `AGENTS.md`
  4. setup files if present such as `README.md`, `SETUP.md`, `.env.example`, and compose or deployment config
- Keep the first slice narrow.
- Do not silently choose unresolved architecture.
- Update docs, examples, and validation in the same pass as behavior changes.

## Validation

Run these after implementing:

- Tests: `[replace with project test command]`
- Typecheck: `[replace with project typecheck command]`
- Lint: `[replace with project lint command]`
- Local run: `[replace with project local run command]`

## Operational Notes

- Install dependencies with `[replace with project install command]`
- Main env vars: `[replace with the real env contract once known]`
- Use `./loop.sh plan` for planning passes.
- Use `./loop.sh build` for implementation passes.
- Use `./loop.sh --ask` when you want each iteration to wait for user answers. `--interactive` remains an alias.
- Add `STOP` to the top of the active prompt file for a graceful stop.

## Codebase Patterns

- Prefer machine feedback over human correction.
- Do not claim behavior that is not proven.
- A slice is not done until the relevant docs and verification exist.
- Prefer fresh iterations over long sessions. If scope expands, persist the next step to disk and let the next run reload it.
- Keep backpressure terse on success and verbose on failure.
