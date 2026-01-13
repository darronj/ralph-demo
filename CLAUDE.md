# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is a **template repository** for starting new projects with Claude Code. It provides:

1. **Guided discovery workflow** - Run `./init-project.sh` to have a structured conversation about your project
2. **Automated planning** - Claude generates a plan document and feature PRDs with dependency tracking
3. **Feature automation** - The Ralph Wiggum Loop executes features iteratively against PRD requirements
4. **Dependency validation** - Scripts ensure prerequisites are complete before starting work

## For Template Users

When someone clones this template:

1. They run `./init-project.sh` (which self-deletes after use)
2. You (Claude) conduct a discovery interview to understand:
   - What they're building and why
   - Who will use it
   - Core functionality (3-5 key features)
   - Technical preferences (language, framework)
   - Success criteria
3. You generate:
   - Plan document: `docs/plans/YYYY-MM-DD-<project>-initial.md`
   - Feature PRDs: `docs/features/*/prd.md` with YAML frontmatter
   - Standards document: `docs/standards.md`
   - Example conversation: `docs/examples/discovery-conversation.md`
4. They review, commit, and start building with `./kickoff.sh`

## Directory Structure

```
docs/
  plans/          # Planning documents
  features/       # Feature PRDs (generated during init)
  architecture/   # Ralph Wiggum Loop docs, PRD writing guidance
  examples/       # Discovery conversation example
  standards.md    # Standard acceptance criteria
```

## PRD Format

Each feature PRD has YAML frontmatter for dependency tracking:

```yaml
---
depends_on:
  - database-setup
  - user-schema
status: blocked  # blocked|ready|in-progress|complete
conversation_prompts:
  - "Topic to explore when ready to implement"
---

# Feature Name

## Context
Why this feature matters

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
Context for Claude during execution
```

## Key Scripts

### `init-project.sh` (template users run this)

- Conducts discovery conversation
- Generates plan and PRDs
- Self-deletes after completion

### `kickoff.sh` (runs feature automation)

- Validates PRD exists and dependencies are complete
- Updates status: ready → in-progress → complete
- Runs Ralph Wiggum Loop
- Suggests newly unblocked features on completion

## When Helping Template Users

### During Init (`init-project.sh`)

Ask discovery questions naturally, one topic at a time:

1. Project essence (what/why)
2. Target users
3. Core functionality
4. Technical foundation
5. Success criteria

Generate the plan document with:

- Hierarchical feature breakdown based on dependencies
- "Future Conversations" section with topics to explore later
- Implementation sequence suggestions

Generate feature PRDs with:

- Appropriate status (ready if no dependencies, blocked otherwise)
- Conversation prompts for deeper exploration
- Well-structured requirements and acceptance criteria

### During Feature Development (`kickoff.sh`)

- Read the PRD to understand requirements
- Follow the Ralph Wiggum Loop pattern
- Complete requirements iteratively
- Mark complete when all acceptance criteria met

## Important Notes

- **Dependency validation happens in kickoff.sh** - Don't start work if dependencies aren't complete
- **Status transitions** - Scripts handle ready→in-progress→complete automatically
- **Conversation prompts** - Each PRD includes topics for follow-up planning conversations
- **Self-documenting** - Each feature PRD should be standalone with all context needed

## Ralph Wiggum Loop

See [docs/architecture/ralph-wiggum-loop.md](docs/architecture/ralph-wiggum-loop.md) for details on how the automated iteration system works.

## This Template Repository

If you're modifying THIS template (not using it for a project), remember:

- Keep documentation clear for people who will clone this
- Example content should demonstrate the workflow
- Scripts should be production-ready and handle edge cases
- README is the entry point - make it welcoming
