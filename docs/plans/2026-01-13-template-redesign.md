# Design: Project Template with Discovery Workflow

**Date:** 2026-01-13
**Type:** Redesign - Ralph Demo to Project Template

## Overview

Transform the ralph-demo repository from a documentation-focused example into a batteries-included template for starting new projects. Users clone it, run an init script, have a guided conversation with Claude about their project, and receive a structured plan with feature PRDs ready to execute.

## Design Goals

1. **Guided discovery** - Structured conversation that uncovers project requirements
2. **Dependency tracking** - Features know what they need before they can start
3. **Automated validation** - Scripts check readiness before allowing work to begin
4. **Future-facing** - Plans include conversation prompts for deeper exploration later
5. **Self-documenting** - Each feature PRD is standalone with all context needed

## Workflow

### Phase 1: Initial Setup

1. User clones template repository
2. Runs `./init-project.sh`
3. Claude conducts discovery interview covering:
   - **Project essence:** What are you building? (1-2 sentences)
   - **Target users:** Who will use this?
   - **Core functionality:** What are the main features? (3-5 key capabilities)
   - **Technical foundation:** Language/framework preferences or constraints
   - **Success criteria:** How will you know this is working well?
4. Claude generates:
   - Plan document: `docs/plans/YYYY-MM-DD-<project-name>-initial.md`
   - Feature PRDs: `docs/features/*/prd.md` with dependency metadata
   - Standards document: `docs/standards.md` with default acceptance criteria
5. Script prints next steps and deletes itself (one-time use)
6. User reviews artifacts, potentially has follow-up planning conversations
7. User commits plan: `git add . && git commit -m 'Initial project plan'`

### Phase 2: Feature Development

1. User creates branch: `git checkout -b feature/<feature-name>`
2. Runs `./kickoff.sh`
3. Script validates:
   - PRD exists
   - Status is `ready` (not `blocked`)
   - All dependencies have status `complete`
4. If validation passes:
   - Updates status to `in-progress`
   - Runs Ralph Wiggum Loop (automated iteration)
   - On completion, updates status to `complete`
   - Checks if any blocked features are now ready
5. User reviews, merges, or spins off sub-features

## File Structure

```
docs/
  plans/
    2026-01-13-my-app-initial.md          # Initial discovery & plan
  features/
    database-setup/
      prd.md                               # Feature PRD with metadata
    auth-system/
      prd.md                               # Depends on database-setup
      oauth-provider/                      # Sub-feature
        prd.md                             # Depends on parent
  architecture/
    ralph-wiggum-loop.md                   # How automation works
    writing-prds.md                        # PRD writing guidance
  examples/
    discovery-conversation.md              # Example conversation
  standards.md                             # Standard acceptance criteria
init-project.sh                            # Bootstrap script (self-deletes)
kickoff.sh                                 # Feature automation runner
.gitignore                                 # Excludes .active, progress.md
```

## PRD Format

### Metadata (YAML Frontmatter)

```yaml
---
depends_on:
  - database-setup
  - user-schema
status: blocked  # blocked|ready|in-progress|complete
conversation_prompts:
  - "Discuss authentication strategy (OAuth vs JWT vs sessions)"
  - "Define user permission levels and access control"
---
```

**Status values:**
- `blocked` - Dependencies not complete
- `ready` - Dependencies complete, can start work
- `in-progress` - Currently being worked on
- `complete` - Done, validated against acceptance criteria

**Conversation prompts:**
1-3 suggested topics for deeper exploration when ready to implement

### Content Structure

```markdown
# Feature Name

## Context
Brief description of what this feature does and why it matters.

## Requirements
- [ ] Specific, testable requirement
- [ ] Another requirement
- [ ] Final requirement

## Acceptance Criteria

### Feature-Specific
- [ ] Concrete validation that requirement is met
- [ ] Observable behavior or output
- [ ] Edge case handling

### Standard
See [docs/standards.md](../standards.md)

## Notes
Additional context Claude needs during execution:
- Existing patterns to follow
- Files to reference
- Constraints or gotchas
```

## Plan Document Format

**`docs/plans/YYYY-MM-DD-<project-name>-initial.md`:**

```markdown
# Project Plan: <Project Name>

**Date:** YYYY-MM-DD
**Type:** Initial Discovery

## Project Overview

### Purpose
[1-2 sentence description from discovery]

### Target Users
[Who will use this and why]

### Success Criteria
[Measurable outcomes that indicate success]

## Technical Foundation

**Stack:** [Language/framework choices]
**Architecture:** [High-level approach - CLI, web app, API, etc.]
**Key Constraints:** [Any technical limitations or requirements]

## Feature Breakdown

### 1. Feature Name
**Path:** `docs/features/feature-name/`
**Dependencies:** None (or list of feature names)
**Purpose:** [Brief description]
**Key Requirements:**
- Requirement 1
- Requirement 2
- Requirement 3

[... repeat for each feature ...]

## Future Conversations

Before implementing these features, consider deeper discussions on:

- **Feature Name:** Topic to explore (e.g., "Schema design patterns, migration strategy")
- **Feature Name:** Topic to explore

## Implementation Sequence

Suggested order based on dependencies:
1. feature-a → feature-b → feature-c
2. feature-d (can start after feature-a)
3. feature-e (can start after feature-d completes)
```

## Standard Acceptance Criteria

**`docs/standards.md`:**

```markdown
# Standard Acceptance Criteria

All features must meet these criteria before being marked complete:

- [ ] All tests pass
- [ ] No linting/type errors
- [ ] Code follows project conventions
- [ ] Documentation updated (README, inline comments where needed)
- [ ] No console errors or warnings
- [ ] (If applicable) Code reviewed by team member

## Customization

Projects may add additional standard criteria by editing this file.
Feature-specific criteria belong in individual PRDs.
```

## Script Behavior

### `init-project.sh`

**Purpose:** Bootstrap new project with discovery conversation

**Logic:**
1. Check if `docs/plans/` contains any files
   - If yes: Exit with "Project already initialized. Remove docs/plans/ to re-init."
2. Create required directories: `docs/{plans,features,architecture,examples}`
3. Launch Claude with discovery system prompt
4. Claude conversation generates:
   - Plan document at `docs/plans/YYYY-MM-DD-<project>-initial.md`
   - Feature directories and PRDs with frontmatter
   - `docs/standards.md` with default criteria
   - `docs/examples/discovery-conversation.md` (transcript)
5. Print next steps:
   ```
   ✓ Project plan created: docs/plans/...
   ✓ Feature PRDs generated: docs/features/...
   ✓ Standards defined: docs/standards.md

   Next steps:
   1. Review the plan and PRDs
   2. Have follow-up conversations to refine features
   3. Commit: git add . && git commit -m "Initial project plan"
   4. Start work: git checkout -b feature/<name> && ./kickoff.sh
   ```
6. Delete itself: `rm -- "$0"`

**Note:** Self-deletion prevents confusion about re-running

### `kickoff.sh` (Enhanced)

**New validation logic:**

```bash
# After determining FEATURE_DIR and PRD path...

# 1. Parse frontmatter
STATUS=$(yq eval '.status' "$PRD" 2>/dev/null || echo "ready")
DEPENDENCIES=($(yq eval '.depends_on[]' "$PRD" 2>/dev/null))

# 2. Check status
if [[ "$STATUS" == "complete" ]]; then
  echo "Feature already complete. Reset status in PRD to re-run."
  exit 0
fi

# 3. Check dependencies
if [[ "$STATUS" == "blocked" ]] || [[ ${#DEPENDENCIES[@]} -gt 0 ]]; then
  for dep in "${DEPENDENCIES[@]}"; do
    DEP_PRD="$FEATURES_DIR/$dep/prd.md"
    if [[ ! -f "$DEP_PRD" ]]; then
      echo "Dependency not found: $dep"
      echo "Expected: $DEP_PRD"
      exit 1
    fi

    DEP_STATUS=$(yq eval '.status' "$DEP_PRD" 2>/dev/null || echo "ready")
    if [[ "$DEP_STATUS" != "complete" ]]; then
      echo "Feature '$FEATURE_PATH' depends on '$dep' (status: $DEP_STATUS)"
      echo "Complete dependencies first:"
      echo "  git checkout -b feature/$dep && ./kickoff.sh"
      exit 1
    fi
  done
fi

# 4. Update status to in-progress
yq eval -i '.status = "in-progress"' "$PRD"
git add "$PRD"
git commit -m "feat($ROOT_FEATURE): starting $FEATURE_PATH"

# ... existing loop logic ...

# 5. On completion, update status
yq eval -i '.status = "complete"' "$PRD"
git add "$PRD"
git commit -m "feat($ROOT_FEATURE): completed $FEATURE_PATH"

# 6. Check for newly unblocked features
echo ""
echo "=== Checking for newly unblocked features ==="
for prd in "$FEATURES_DIR"/*/prd.md; do
  NEXT_STATUS=$(yq eval '.status' "$prd" 2>/dev/null)
  if [[ "$NEXT_STATUS" == "blocked" ]]; then
    # Check if all dependencies are now complete
    # If yes, suggest next feature to work on
  fi
done
```

**Dependencies:**
- Requires `yq` for YAML parsing (https://github.com/mikefarah/yq)
- Script should check for `yq` and provide install instructions if missing

## Edge Cases & Error Handling

### Re-running init
- Check for existing `docs/plans/` content
- Exit with clear message about removal if already initialized

### Circular dependencies
- Plan generation should detect cycles
- Warn user and refuse to generate PRDs with circular deps
- Suggest breaking the cycle

### Missing dependencies
- Kickoff validates dependency paths exist
- Clear error message with expected location

### Manual status changes
- User can edit PRD frontmatter to change status
- `blocked` → `ready` (to force work on a feature)
- `complete` → `ready` (to rework a feature)
- `in-progress` → `ready` (to restart after interruption)

### Dependency completion cascading
- When feature completes, check all features with status `blocked`
- If all dependencies complete, auto-update to `ready`
- Print suggestions for next features to tackle

## README Structure

See implementation section for complete README content. Key sections:

1. **Quick Start** - Clone, init, review, commit, build
2. **How It Works** - Discovery phase, development phase, dependency management
3. **Project Structure** - Directory layout with explanations
4. **Learn More** - Links to architecture docs

## Additional Documentation

### `docs/architecture/writing-prds.md`

Guidance on:
- Writing atomic, testable requirements
- Good vs bad acceptance criteria examples
- When to use feature-specific vs standard criteria
- How to structure notes for Claude context

### `docs/examples/discovery-conversation.md`

Full transcript showing:
- How Claude asks discovery questions
- Example answers
- Generated plan document
- Generated PRD examples

This helps users understand what to expect from `init-project.sh`

## Migration from Current State

To transform current ralph-demo into template:

1. Move `docs/ralph-wiggum-loop.md` → `docs/architecture/`
2. Write new `README.md` with template instructions
3. Update `CLAUDE.md` to explain template purpose
4. Create `docs/architecture/writing-prds.md`
5. Create `docs/examples/discovery-conversation.md`
6. Create `docs/standards.md` template
7. Create `init-project.sh` script
8. Update `kickoff.sh` with dependency validation
9. Create `.gitignore` with `.active` and `progress.md`
10. Delete `prompt.md` (no longer relevant)
11. Commit all changes

## Future Enhancements

Ideas for later iteration (not in initial template):

- `./visualize-deps.sh` - Generate graph of feature dependencies
- `./check-ready.sh` - List all features with status `ready`
- Template variations (CLI, web app, API) with pre-seeded discovery prompts
- Integration with CI/CD for automated acceptance criteria validation

## Success Criteria

This redesign is complete when:

- [ ] User can clone repo and run `./init-project.sh` successfully
- [ ] Discovery conversation feels natural and comprehensive
- [ ] Generated plan document includes all designed sections
- [ ] Generated PRDs have correct frontmatter and structure
- [ ] `kickoff.sh` validates dependencies before running loop
- [ ] `kickoff.sh` updates status transitions correctly
- [ ] `kickoff.sh` suggests newly unblocked features on completion
- [ ] README clearly explains template usage
- [ ] Architecture docs explain the Ralph Wiggum Loop
- [ ] Example conversation demonstrates discovery flow
- [ ] All generated scripts are executable and functional
