# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

Template repository for project initialization and automated feature development with Claude Code. Provides two-phase workflow: planning (generate PRDs) and execution (implement requirements).

## System Architecture

### Two-Phase Workflow

**Phase 1: Planning** (`init-project.sh` + `plan.md`)

- Conduct discovery interview with user
- Generate hierarchical plan with feature dependencies
- Create feature PRDs with YAML frontmatter metadata
- **DO NOT execute code** - planning only

**Phase 2: Execution** (`kickoff.sh` + `prompt.md`)

- Implement ONE requirement per iteration
- Update PRD by checking off completed requirements
- Append summary to root-level `progress.txt`
- **DO execute code** - production-ready implementation

### Critical Distinction

- `plan.md`: Planning mode - creates/edits PRDs, no code execution
- `prompt.md`: Execution mode - implements requirements, updates PRDs

## Prompt Files (Editable System Prompts)

Both prompts are version-controlled and tunable:

**`plan.md`** - Used by `init-project.sh`

- Discovery interview questions (one at a time)
- Plan document structure with "Future Conversations" section
- PRD generation with dependency metadata
- Sets `status: ready` (no deps) or `status: blocked` (has deps)

**`prompt.md`** - Used by `kickoff.sh`

- Choose ONE incomplete requirement (any order)
- Fully implement with code, tests, docs
- Update PRD: `- [ ]` → `- [x]`
- Append to `./progress.txt`: `[timestamp] Feature: path - Completed: summary`
- Respond: `CONTINUE` | `COMPLETE` | `STUCK: reason`

## PRD Structure with Dependency Tracking

```yaml
---
depends_on:
  - feature-name      # Array of feature folder names
status: blocked       # blocked|ready|in-progress|complete
conversation_prompts:
  - "Topic for deeper exploration"
---

# Feature Name

## Context
Why this feature matters (2-4 sentences)

## Requirements
- [ ] Specific, testable requirement
- [ ] Another requirement

## Acceptance Criteria

### Feature-Specific
- [ ] Observable validation
- [ ] Edge case coverage

### Standard
See [docs/standards.md](../standards.md)

## Notes
Implementation guidance for Claude:
- Patterns to follow
- Files to reference
- Constraints/gotchas
```

## Dependency Management

**Status Transitions:**

- `ready` → `in-progress` (kickoff starts)
- `in-progress` → `complete` (all requirements met)
- `blocked` → `ready` (when dependencies complete)

**Validation in kickoff.sh:**

1. Parse `depends_on` array from PRD frontmatter
2. Check each dependency's status = `complete`
3. Exit with helpful message if blocked
4. Auto-update blocked → ready when dependencies complete

**Auto-stop conditions:**

1. All requirements completed (`COMPLETE` response)
2. Same error occurs twice consecutively (prevents infinite retry loops)
3. Claude reports `STUCK: <reason>` (non-error blocking issue)

**Hierarchical Structure:**

```
feature/database-setup           (no deps, status: ready)
feature/auth-system              (depends: [database-setup])
feature/auth-system/oauth        (depends: [../])
```

## Key Commands

**Initialize new project:**

```bash
./init-project.sh
# Runs discovery conversation via plan.md
# Generates plan document and feature PRDs
# Self-deletes after completion
```

**Execute feature:**

```bash
git checkout -b feature/<name>
./kickoff.sh
# Validates dependencies via yq YAML parsing
# Pipes prompt.md + context to claude
# Iterates until COMPLETE or STUCK
```

**Dependencies:**

- `yq` for YAML parsing: `brew install yq` (macOS) or download binary (Linux)
- `claude` CLI installed and authenticated

## Script Behavior

**`kickoff.sh` validates:**

- PRD exists at `docs/features/<feature-path>/prd.md`
- Status is not `complete` (allow rework by editing PRD)
- All `depends_on` features have `status: complete`
- Branch format: `feature/<name>` or `feature/<parent>/<child>`

**Loop context injection:**

```bash
# kickoff.sh builds context and pipes to claude
LOOP_CONTEXT=$(cat << EOF
## Context for This Iteration
**Feature Path:** $FEATURE_PATH
**PRD File:** $PRD
**Iteration:** $ITERATION
---
## PRD Contents
$(cat "$PRD")
---
## Previous Iterations
$(cat "$PROGRESS")
EOF
)

cat prompt.md <(echo "$LOOP_CONTEXT") | claude
```

## File Purposes

**Generated during planning:**

- `docs/plans/YYYY-MM-DD-<project>-initial.md` - Plan with future conversation topics
- `docs/features/*/prd.md` - Feature PRDs with dependency metadata
- `docs/standards.md` - Standard acceptance criteria (project-specific)

**Generated during execution:**

- `docs/features/*/progress.md` - Per-feature iteration log (gitignored)
- `docs/features/*/.active` - Branch lineage history (gitignored)
- `./progress.txt` - Root-level progress log with timestamped entries for each completed requirement or error across all features (gitignored)

## Branch Naming Conventions

Branches map to feature directories:

- `feature/auth-refactor` → `docs/features/auth-refactor/`
- `feature/auth-refactor/oauth` → `docs/features/auth-refactor/oauth/`

Root feature = first segment after `feature/`
`.active` file lives in root feature directory, tracks all branches

## When Helping Users

**During init (plan.md context):**

- Ask discovery questions one at a time
- Generate plan with hierarchical dependencies
- Create feature directories with PRDs
- Set appropriate status based on dependencies
- Include "Future Conversations" in plan

**During kickoff (prompt.md context):**

- Read PRD carefully (requirements + acceptance criteria)
- Choose ONE requirement strategically (not necessarily first)
- Implement fully (code + tests + docs)
- Update PRD file (check off requirement)
- Write to `./progress.txt` with timestamp and status:
  - Success: `[timestamp] Feature: path - Completed: summary`
  - Error: `[timestamp] Feature: path - ERROR: description`
- Respond with CONTINUE/COMPLETE/STUCK

**If modifying this template repository:**

- Keep prompts editable and version-controlled
- Scripts must be production-ready
- Documentation clear for cloners
- README is entry point

## Documentation References

- [docs/architecture/ralph-wiggum-loop.md](docs/architecture/ralph-wiggum-loop.md) - Original loop design
- [docs/architecture/writing-prds.md](docs/architecture/writing-prds.md) - PRD best practices
- [docs/examples/discovery-conversation.md](docs/examples/discovery-conversation.md) - Example workflow

## Plan Mode

- Make the plan extremely concise. Sacrifice grammar for the sake of concision.
- At the end of each plan, give me a list of unresolved questions to answer, if any.
