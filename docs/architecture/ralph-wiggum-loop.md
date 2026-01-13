# Ralph Wiggum Loop: Feature Development Automation

## Overview

A simple, human-in-the-loop system for running automated Claude Code loops against feature requirements. The system uses git branches and a docs folder structure to track work, with no external dependencies or orchestration.

## Core Concepts

### The Loop

Each iteration of the loop:

1. Reads the PRD (Product Requirements Document)
2. Reads current progress
3. Asks Claude to complete the next requirement
4. Records the result
5. Repeats until COMPLETE or STUCK

### Human-in-the-Loop Dispatch

There is no automatic orchestrator. You are the scheduler:

- You decide which feature to work on
- You create the branch
- You run the kickoff script
- You decide when to merge or spin off sub-features

This is intentional. Automation handles the tedious iteration; you handle the judgment calls.

## Folder Structure

```
docs/features/
  auth-refactor/                    # Root feature
    prd.md                          # Requirements (you write this)
    progress.md                     # Loop output (auto-generated)
    .active                         # Branch history (auto-generated)
    
    oauth-provider/                 # Sub-feature (optional)
      prd.md
      progress.md
      
    session-cleanup/                # Another sub-feature
      prd.md
      progress.md

  payment-flow/                     # Another root feature
    prd.md
    progress.md
    .active
```

### File Purposes

| File | Purpose | Created By |
|------|---------|------------|
| `prd.md` | Requirements checklist | You |
| `progress.md` | Iteration log and status | Script |
| `.active` | Branch lineage history | Script |

## Branch Naming Convention

Branches map directly to folder structure:

```
feature/auth-refactor                     -> docs/features/auth-refactor/
feature/auth-refactor/oauth-provider      -> docs/features/auth-refactor/oauth-provider/
feature/auth-refactor/oauth-provider/refresh -> docs/features/auth-refactor/oauth-provider/refresh/
```

The first segment after `feature/` is always the root feature. Sub-features nest beneath.

## The .active File

The `.active` file lives in the root feature directory and tracks all branches that have worked on this feature:

```
feature/auth-refactor
feature/auth-refactor/oauth-provider
feature/auth-refactor/session-cleanup
```

This provides:

- A history of how the feature evolved
- A way to see what work happened before merging
- A breadcrumb trail for debugging

## Workflow

### Starting a New Feature

```bash
# 1. Create the feature directory and PRD
mkdir -p docs/features/my-feature
cat > docs/features/my-feature/prd.md << 'EOF'
# My Feature

## Requirements

- [ ] First requirement
- [ ] Second requirement
- [ ] Third requirement
EOF

# 2. Create the branch
git checkout -b feature/my-feature

# 3. Run the loop
./kickoff.sh
```

### Spinning Off Sub-Features

When the main feature completes but you want to add more before merging:

```bash
# From the completed feature branch
git checkout -b feature/my-feature/enhancement

# Create sub-feature PRD
cat > docs/features/my-feature/enhancement/prd.md << 'EOF'
# Enhancement

## Requirements

- [ ] Additional requirement
EOF

# Run the loop
./kickoff.sh
```

### Completing and Merging

```bash
# After the loop completes
git push -u origin feature/my-feature

# Create PR, get review, merge

# Clean up (optional - you may want to keep for history)
rm docs/features/my-feature/.active
```

## The Kickoff Script

```bash
#!/usr/bin/env bash
set -euo pipefail

FEATURES_DIR="docs/features"
BRANCH=$(git branch --show-current)

# --- Parse branch into feature/subfeature ---

if [[ "$BRANCH" == feature/* ]]; then
  FEATURE_PATH="${BRANCH#feature/}"
else
  FEATURE_PATH="$BRANCH"
fi

ROOT_FEATURE=$(echo "$FEATURE_PATH" | cut -d'/' -f1)
ROOT_DIR="$FEATURES_DIR/$ROOT_FEATURE"

FEATURE_DIR="$FEATURES_DIR/$FEATURE_PATH"
PRD="$FEATURE_DIR/prd.md"
PROGRESS="$FEATURE_DIR/progress.md"
ACTIVE="$ROOT_DIR/.active"

# --- Validation ---

if [[ ! -d "$ROOT_DIR" ]]; then
  echo "No feature dir found for '$ROOT_FEATURE'"
  echo "Expected: $ROOT_DIR"
  echo ""
  echo "Available features:"
  ls -1 "$FEATURES_DIR"
  exit 1
fi

if [[ ! -d "$FEATURE_DIR" ]]; then
  echo "Creating sub-feature dir: $FEATURE_DIR"
  mkdir -p "$FEATURE_DIR"
  
  if [[ ! -f "$PRD" ]]; then
    echo "# $FEATURE_PATH" > "$PRD"
    echo "" >> "$PRD"
    echo "## Requirements" >> "$PRD"
    echo "" >> "$PRD"
    echo "- [ ] TODO: Define requirements" >> "$PRD"
    echo ""
    echo "Created empty PRD at $PRD"
    echo "Fill it out and re-run."
    exit 0
  fi
fi

if [[ ! -f "$PRD" ]]; then
  echo "No prd.md found in $FEATURE_DIR"
  exit 1
fi

# --- Record branch in .active ---

LAST_ENTRY=$(tail -1 "$ACTIVE" 2>/dev/null || echo "")
if [[ "$LAST_ENTRY" != "$BRANCH" ]]; then
  echo "$BRANCH" >> "$ACTIVE"
  echo "Recorded branch in $ACTIVE"
fi

echo ""
echo "=== Starting loop ==="
echo "Branch: $BRANCH"
echo "Feature: $FEATURE_PATH"
echo "PRD: $PRD"
echo "Progress: $PROGRESS"
echo ""
echo "Branch history:"
cat "$ACTIVE" | sed 's/^/  /'
echo ""

# --- Initialize progress ---

if [[ ! -f "$PROGRESS" ]]; then
  echo "# Progress: $FEATURE_PATH" > "$PROGRESS"
  echo "" >> "$PROGRESS"
  echo "Started: $(date -Iseconds)" >> "$PROGRESS"
  echo "Branch: $BRANCH" >> "$PROGRESS"
  echo "" >> "$PROGRESS"
fi

# --- The Loop ---

MAX_ITERATIONS=20
ITERATION=0
RESULT=""

while [[ $ITERATION -lt $MAX_ITERATIONS ]]; do
  ITERATION=$((ITERATION + 1))
  echo "=== Iteration $ITERATION ==="

  RESULT=$(claude  --dangerously-skip-permissions -p "
You are working on a feature.

PRD: $(cat "$PRD")

Current progress: $(cat "$PROGRESS")

Either:
1. Complete the next incomplete requirement and respond with CONTINUE
2. If all requirements done, respond with COMPLETE
3. If stuck, respond with STUCK: <reason>
" 2>&1) || true

  echo "" >> "$PROGRESS"
  echo "--- Iteration $ITERATION: $(date -Iseconds) ---" >> "$PROGRESS"
  echo "$RESULT" | tail -5 >> "$PROGRESS"

  if echo "$RESULT" | grep -q "COMPLETE"; then
    echo "=== Feature complete! ==="
    break
  fi

  if echo "$RESULT" | grep -q "STUCK"; then
    echo "=== Stuck ==="
    echo "$RESULT"
    break
  fi

  sleep 2
done

# --- Wrap up ---

echo "" >> "$PROGRESS"
echo "Finished: $(date -Iseconds)" >> "$PROGRESS"

if echo "$RESULT" | grep -q "COMPLETE"; then
  git add -A
  git commit -m "feat($ROOT_FEATURE): $FEATURE_PATH (automated)"
  
  echo ""
  echo "=== Complete ==="
  echo ""
  echo "Push this branch:"
  echo "  git push -u origin $BRANCH"
  echo ""
  echo "Or start a sub-feature:"
  echo "  git checkout -b $BRANCH/<sub-feature-name>"
  echo "  ./kickoff.sh"
  echo ""
  echo "Branch history so far:"
  cat "$ACTIVE" | sed 's/^/  /'
fi
```

## PRD Format

Keep it simple. Checkboxes work well:

```markdown
# Feature Name

## Context

Brief description of what this feature does and why.

## Requirements

- [ ] First requirement
- [ ] Second requirement  
- [ ] Third requirement

## Notes

Any additional context Claude might need.
```

## Tips

### Writing Good PRDs

- Be specific and atomic in requirements
- Include acceptance criteria where helpful
- Reference existing code patterns if relevant
- Keep requirements small enough to complete in one iteration

### Managing Sub-Features

- Use sub-features for related work that should stay on the same branch lineage
- Each sub-feature gets its own PRD, so scope can be different
- The `.active` file shows the full history when you're ready to merge

### When Things Get Stuck

- Check `progress.md` for what happened
- The loop outputs STUCK with a reason
- You can manually fix the issue and re-run
- Or adjust the PRD to be more specific

### Keeping History Clean

- The loop commits on completion with a conventional commit message
- Sub-features commit separately
- You can squash when merging if preferred

## Why "Ralph Wiggum Loop"?

The loop keeps trying, one step at a time, with cheerful persistence. Sometimes it gets stuck. Sometimes it succeeds in unexpected ways. But it keeps going until it's done or needs help.

Just like Ralph, it's doing its best.
