#!/usr/bin/env bash

set -euo pipefail

MODE="build"
ITERATIONS=0
THINKING="high"
MODEL="${MODEL:-gpt-5.4}"
CODEX_BIN="${CODEX_BIN:-codex}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRY_RUN=0
INTERACTIVE=0
MAX_IDLE=1

print_help() {
  cat <<'EOF'
Codex Ralph loop

Usage:
  ./loop.sh
  ./loop.sh [build|plan] [iterations] [thinking]
  ./loop.sh --mode build --iterations 5 --thinking high
  ./loop.sh --ask
  ./loop.sh --help

Options:
  build|plan              Mode. Default: build
  -n, --iterations N      Number of iterations. 0 = run forever. Default: 0
  -t, --thinking LEVEL    low | medium | high | xhigh. Default: high
  -m, --model MODEL       Codex model. Default: gpt-5.4
  --ask, --interactive    Run one interactive Codex session per iteration
  --max-idle N            Stop after N consecutive no-op iterations. 0 = disable. Default: 1
  --dry-run               Print the Codex command and exit
  -h, --help              Show this help

Behavior:
  - Uses PROMPT_build.md for build mode and PROMPT_plan.md for plan mode
  - Default mode runs one fresh non-interactive Codex exec session per iteration
  - Interactive mode runs one Codex chat session per iteration
  - Stops on the first non-zero Codex exit code
  - Graceful stop: add "STOP" to the top 5 lines of the active prompt file
  - Idle stop triggers when an iteration leaves HEAD unchanged and the worktree clean
EOF
}

die() {
  echo "Error: $*" >&2
  exit 1
}

validate_mode() {
  case "$1" in
    build|plan) ;;
    *) die "invalid mode: $1" ;;
  esac
}

validate_iterations() {
  [[ "$1" =~ ^[0-9]+$ ]] || die "iterations must be a non-negative integer"
}

validate_thinking() {
  case "$1" in
    low|medium|high|xhigh) ;;
    *) die "thinking must be one of: low, medium, high, xhigh" ;;
  esac
}

validate_max_idle() {
  [[ "$1" =~ ^[0-9]+$ ]] || die "max idle must be a non-negative integer"
}

POSITIONAL=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    build|plan)
      POSITIONAL+=("$1")
      shift
      ;;
    help|-h|--help)
      print_help
      exit 0
      ;;
    -n|--iterations)
      [[ $# -ge 2 ]] || die "missing value for $1"
      ITERATIONS="$2"
      shift 2
      ;;
    -t|--thinking)
      [[ $# -ge 2 ]] || die "missing value for $1"
      THINKING="$2"
      shift 2
      ;;
    -m|--model)
      [[ $# -ge 2 ]] || die "missing value for $1"
      MODEL="$2"
      shift 2
      ;;
    --interactive|--ask)
      INTERACTIVE=1
      shift
      ;;
    --max-idle)
      [[ $# -ge 2 ]] || die "missing value for $1"
      MAX_IDLE="$2"
      shift 2
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    --mode)
      [[ $# -ge 2 ]] || die "missing value for $1"
      MODE="$2"
      shift 2
      ;;
    --)
      shift
      while [[ $# -gt 0 ]]; do
        POSITIONAL+=("$1")
        shift
      done
      ;;
    -*)
      die "unknown option: $1"
      ;;
    *)
      POSITIONAL+=("$1")
      shift
      ;;
  esac
done

if [[ ${#POSITIONAL[@]} -ge 1 ]]; then
  MODE="${POSITIONAL[0]}"
fi

if [[ ${#POSITIONAL[@]} -ge 2 ]]; then
  ITERATIONS="${POSITIONAL[1]}"
fi

if [[ ${#POSITIONAL[@]} -ge 3 ]]; then
  THINKING="${POSITIONAL[2]}"
fi

if [[ ${#POSITIONAL[@]} -gt 3 ]]; then
  die "too many positional arguments"
fi

validate_mode "$MODE"
validate_iterations "$ITERATIONS"
validate_thinking "$THINKING"
validate_max_idle "$MAX_IDLE"

case "$MODE" in
  build) PROMPT_FILE="$ROOT_DIR/PROMPT_build.md" ;;
  plan) PROMPT_FILE="$ROOT_DIR/PROMPT_plan.md" ;;
esac

[[ -f "$PROMPT_FILE" ]] || die "prompt file not found: $PROMPT_FILE"
command -v "$CODEX_BIN" >/dev/null 2>&1 || die "codex binary not found: $CODEX_BIN"

should_stop() {
  head -n 5 "$PROMPT_FILE" | grep -Eq '^STOP$'
}

BRANCH="$(git -C "$ROOT_DIR" branch --show-current 2>/dev/null || true)"
if [[ -z "$BRANCH" ]]; then
  BRANCH="(detached or unknown)"
fi

echo "========================================"
echo "🤖 Codex Ralph loop"
echo "Mode:       $MODE"
echo "Session:    $([[ "$INTERACTIVE" -eq 1 ]] && echo interactive || echo non-interactive)"
echo "Prompt:     $(basename "$PROMPT_FILE")"
echo "Iterations: $ITERATIONS"
echo "Thinking:   $THINKING"
echo "Model:      $MODEL"
echo "Max idle:   $MAX_IDLE"
echo "Branch:     $BRANCH"
echo "Root:       $ROOT_DIR"
echo "========================================"

EXEC_CMD=(
  "$CODEX_BIN"
  exec
  --full-auto
  -C "$ROOT_DIR"
  -m "$MODEL"
  -c "model_reasoning_effort=\"$THINKING\""
  -
)

INTERACTIVE_CMD=(
  "$CODEX_BIN"
  --full-auto
  -C "$ROOT_DIR"
  -m "$MODEL"
  -c "model_reasoning_effort=\"$THINKING\""
)

if [[ "$DRY_RUN" -eq 1 ]]; then
  printf 'Dry run command:\n'
  if [[ "$INTERACTIVE" -eq 1 ]]; then
    printf '  %q' "${INTERACTIVE_CMD[@]}"
    printf ' %q\n' "<contents of $(basename "$PROMPT_FILE")>"
  else
    printf '  %q' "${EXEC_CMD[@]}"
    printf ' < %q\n' "$PROMPT_FILE"
  fi
  exit 0
fi

COUNT=0
IDLE_COUNT=0
while :; do
  if should_stop; then
    echo "🛑 STOP found in $(basename "$PROMPT_FILE"); exiting cleanly."
    break
  fi

  if [[ "$ITERATIONS" -gt 0 && "$COUNT" -ge "$ITERATIONS" ]]; then
    echo "🛑 Reached iteration limit: $ITERATIONS"
    break
  fi

  COUNT=$((COUNT + 1))
  echo
  echo "🚀 ----- iteration $COUNT start -----"

  HEAD_BEFORE="$(git -C "$ROOT_DIR" rev-parse HEAD 2>/dev/null || true)"

  if [[ "$INTERACTIVE" -eq 1 ]]; then
    PROMPT_TEXT="$(cat "$PROMPT_FILE")"
    "${INTERACTIVE_CMD[@]}" "$PROMPT_TEXT"
  else
    "${EXEC_CMD[@]}" < "$PROMPT_FILE"
  fi

  echo "✅ ----- iteration $COUNT complete -----"

  HEAD_AFTER="$(git -C "$ROOT_DIR" rev-parse HEAD 2>/dev/null || true)"
  STATUS_AFTER="$(git -C "$ROOT_DIR" status --porcelain 2>/dev/null || true)"

  if [[ "$HEAD_BEFORE" == "$HEAD_AFTER" && -z "$STATUS_AFTER" ]]; then
    IDLE_COUNT=$((IDLE_COUNT + 1))
    echo "Idle iteration count: $IDLE_COUNT"
    if [[ "$MAX_IDLE" -gt 0 && "$IDLE_COUNT" -ge "$MAX_IDLE" ]]; then
      echo "🛑 Reached max idle iterations: $MAX_IDLE"
      break
    fi
  else
    IDLE_COUNT=0
  fi
done
