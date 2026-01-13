#!/usr/bin/env bash
set -euo pipefail

# kickoff.sh
# Runs the Ralph Wiggum Loop for a feature with dependency validation

FEATURES_DIR="docs/features"
BRANCH=$(git branch --show-current)

# Check for yq (required for YAML parsing)
if ! command -v yq &> /dev/null; then
  echo "❌ yq not found (required for YAML parsing)"
  echo ""
  echo "Install instructions:"
  echo "  macOS:  brew install yq"
  echo "  Linux:  wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/local/bin/yq && chmod +x /usr/local/bin/yq"
  echo ""
  exit 1
fi

# Check for Claude CLI
if ! command -v claude &> /dev/null; then
  echo "❌ Claude CLI not found"
  echo ""
  echo "Install instructions: https://claude.com/code"
  echo ""
  exit 1
fi

# --- Parse branch into feature/subfeature ---

if [[ "$BRANCH" == feature/* ]]; then
  FEATURE_PATH="${BRANCH#feature/}"
else
  echo "❌ Must be on a feature/* branch"
  echo "Current branch: $BRANCH"
  echo ""
  echo "Create a feature branch:"
  echo "  git checkout -b feature/<feature-name>"
  echo ""
  exit 1
fi

ROOT_FEATURE=$(echo "$FEATURE_PATH" | cut -d'/' -f1)
ROOT_DIR="$FEATURES_DIR/$ROOT_FEATURE"

FEATURE_DIR="$FEATURES_DIR/$FEATURE_PATH"
PRD="$FEATURE_DIR/prd.md"
PROGRESS="$FEATURE_DIR/progress.md"
ACTIVE="$ROOT_DIR/.active"

# --- Validation ---

if [[ ! -d "$ROOT_DIR" ]]; then
  echo "❌ No feature directory found for '$ROOT_FEATURE'"
  echo "Expected: $ROOT_DIR"
  echo ""
  echo "Available features:"
  ls -1 "$FEATURES_DIR" 2>/dev/null || echo "  (none)"
  echo ""
  echo "Run ./init-project.sh to create features, or manually create:"
  echo "  mkdir -p $ROOT_DIR"
  echo ""
  exit 1
fi

if [[ ! -d "$FEATURE_DIR" ]]; then
  echo "Creating sub-feature directory: $FEATURE_DIR"
  mkdir -p "$FEATURE_DIR"

  if [[ ! -f "$PRD" ]]; then
    cat > "$PRD" << EOF
---
depends_on: []
status: ready
conversation_prompts: []
---

# $FEATURE_PATH

## Context

TODO: Describe what this feature does and why.

## Requirements

- [ ] TODO: Define requirements

## Acceptance Criteria

### Feature-Specific
- [ ] TODO: Define acceptance criteria

### Standard
See [docs/standards.md](../standards.md)

## Notes

TODO: Add context for Claude during execution.
EOF
    echo ""
    echo "Created empty PRD at $PRD"
    echo "Fill it out and re-run."
    exit 0
  fi
fi

if [[ ! -f "$PRD" ]]; then
  echo "❌ No prd.md found in $FEATURE_DIR"
  exit 1
fi

# --- Parse PRD frontmatter ---

STATUS=$(yq eval '.status' "$PRD" 2>/dev/null || echo "ready")
DEPENDENCIES=($(yq eval '.depends_on[]' "$PRD" 2>/dev/null || echo ""))

echo "=== Feature: $FEATURE_PATH ==="
echo "Status: $STATUS"
echo "Dependencies: ${DEPENDENCIES[@]:-none}"
echo ""

# --- Check if already complete ---

if [[ "$STATUS" == "complete" ]]; then
  echo "✓ Feature already complete"
  echo ""
  echo "To rework this feature, edit the PRD and change status to 'ready'"
  exit 0
fi

# --- Validate dependencies ---

if [[ ${#DEPENDENCIES[@]} -gt 0 ]] && [[ "${DEPENDENCIES[0]}" != "" ]]; then
  echo "Checking dependencies..."
  for dep in "${DEPENDENCIES[@]}"; do
    DEP_PRD="$FEATURES_DIR/$dep/prd.md"

    if [[ ! -f "$DEP_PRD" ]]; then
      echo "❌ Dependency not found: $dep"
      echo "Expected: $DEP_PRD"
      echo ""
      exit 1
    fi

    DEP_STATUS=$(yq eval '.status' "$DEP_PRD" 2>/dev/null || echo "unknown")

    if [[ "$DEP_STATUS" != "complete" ]]; then
      echo "❌ Feature '$FEATURE_PATH' depends on '$dep'"
      echo "   Dependency status: $DEP_STATUS (needs: complete)"
      echo ""
      echo "Complete dependencies first:"
      echo "  git checkout -b feature/$dep"
      echo "  ./kickoff.sh"
      echo ""
      exit 1
    fi

    echo "  ✓ $dep (complete)"
  done
  echo ""
fi

# --- Record branch in .active ---

if [[ ! -f "$ACTIVE" ]]; then
  touch "$ACTIVE"
fi

LAST_ENTRY=$(tail -1 "$ACTIVE" 2>/dev/null || echo "")
if [[ "$LAST_ENTRY" != "$BRANCH" ]]; then
  echo "$BRANCH" >> "$ACTIVE"
  echo "Recorded branch in $ACTIVE"
  echo ""
fi

# --- Update status to in-progress ---

if [[ "$STATUS" == "ready" ]] || [[ "$STATUS" == "blocked" ]]; then
  yq eval -i '.status = "in-progress"' "$PRD"
  git add "$PRD"
  git commit -m "feat($ROOT_FEATURE): starting $FEATURE_PATH" --no-verify || true
  echo "Status updated: $STATUS → in-progress"
  echo ""
fi

echo "=== Starting Loop ==="
echo "Branch: $BRANCH"
echo "Feature: $FEATURE_PATH"
echo "PRD: $PRD"
echo "Progress: $PROGRESS"
echo ""

# --- Initialize progress ---

if [[ ! -f "$PROGRESS" ]]; then
  cat > "$PROGRESS" << EOF
# Progress: $FEATURE_PATH

Started: $(date -Iseconds)
Branch: $BRANCH

EOF
fi

# --- The Loop ---

MAX_ITERATIONS=20
ITERATION=0
RESULT=""

while [[ $ITERATION -lt $MAX_ITERATIONS ]]; do
  ITERATION=$((ITERATION + 1))
  echo "=== Iteration $ITERATION ==="

  RESULT=$(claude -p "
You are working on a feature using the Ralph Wiggum Loop.

PRD:
$(cat "$PRD")

Current progress:
$(cat "$PROGRESS")

Instructions:
1. Read the PRD requirements and acceptance criteria
2. Complete the next incomplete requirement
3. Update progress

Then respond with one of:
- CONTINUE (if more work remains)
- COMPLETE (if all requirements and acceptance criteria are met)
- STUCK: <reason> (if you cannot proceed)

Do not respond with just 'CONTINUE' - actually do the work first.
" 2>&1) || true

  # Record iteration in progress
  {
    echo ""
    echo "--- Iteration $ITERATION: $(date -Iseconds) ---"
    echo "$RESULT" | tail -10
  } >> "$PROGRESS"

  if echo "$RESULT" | grep -q "COMPLETE"; then
    echo ""
    echo "=== Feature complete! ==="
    break
  fi

  if echo "$RESULT" | grep -q "STUCK"; then
    echo ""
    echo "=== Stuck ==="
    echo "$RESULT"
    break
  fi

  sleep 2
done

# --- Wrap up ---

{
  echo ""
  echo "Finished: $(date -Iseconds)"
} >> "$PROGRESS"

if echo "$RESULT" | grep -q "COMPLETE"; then
  # Update status to complete
  yq eval -i '.status = "complete"' "$PRD"

  git add -A
  git commit -m "feat($ROOT_FEATURE): completed $FEATURE_PATH

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>" --no-verify || true

  echo ""
  echo "=== Complete ==="
  echo ""
  echo "✓ Feature completed: $FEATURE_PATH"
  echo "✓ Status updated: in-progress → complete"
  echo ""

  # Check for newly unblocked features
  echo "Checking for newly unblocked features..."
  READY_FEATURES=()

  for prd_file in "$FEATURES_DIR"/*/prd.md "$FEATURES_DIR"/*/*/prd.md; do
    [[ -f "$prd_file" ]] || continue

    FEATURE_STATUS=$(yq eval '.status' "$prd_file" 2>/dev/null || echo "unknown")

    if [[ "$FEATURE_STATUS" == "blocked" ]]; then
      # Check if all dependencies are now complete
      FEATURE_DEPS=($(yq eval '.depends_on[]' "$prd_file" 2>/dev/null || echo ""))
      ALL_DEPS_COMPLETE=true

      for dep in "${FEATURE_DEPS[@]}"; do
        [[ -z "$dep" ]] && continue
        DEP_PRD="$FEATURES_DIR/$dep/prd.md"
        DEP_STATUS=$(yq eval '.status' "$DEP_PRD" 2>/dev/null || echo "unknown")

        if [[ "$DEP_STATUS" != "complete" ]]; then
          ALL_DEPS_COMPLETE=false
          break
        fi
      done

      if $ALL_DEPS_COMPLETE; then
        # Update status to ready
        yq eval -i '.status = "ready"' "$prd_file"
        FEATURE_NAME=$(dirname "$prd_file" | sed "s|$FEATURES_DIR/||")
        READY_FEATURES+=("$FEATURE_NAME")
      fi
    fi
  done

  if [[ ${#READY_FEATURES[@]} -gt 0 ]]; then
    echo ""
    echo "✓ Newly ready features:"
    for ready_feature in "${READY_FEATURES[@]}"; do
      echo "  - $ready_feature"
    done
    echo ""
    echo "Work on a ready feature:"
    echo "  git checkout master"
    echo "  git checkout -b feature/${READY_FEATURES[0]}"
    echo "  ./kickoff.sh"
  fi

  echo ""
  echo "Push this branch:"
  echo "  git push -u origin $BRANCH"
  echo ""
  echo "Or start a sub-feature:"
  echo "  git checkout -b $BRANCH/<sub-feature-name>"
  echo "  ./kickoff.sh"
  echo ""
  echo "Branch history:"
  cat "$ACTIVE" | sed 's/^/  /'
fi
