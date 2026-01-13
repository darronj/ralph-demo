# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is a documentation repository for the **Ralph Wiggum Loop** - a human-in-the-loop feature development automation system for Claude Code. The system uses git branches and a docs folder structure to track automated work against feature requirements.

## Directory Structure

```
docs/
  features/          # Feature work tracked here (PRDs, progress)
  architecture/      # Architecture documentation
  plans/             # Implementation plans
  user/              # User-facing documentation
```

## How the Loop Works

1. Human creates a PRD (Product Requirements Document) in `docs/features/<feature-name>/prd.md`
2. Human creates branch `feature/<feature-name>` and runs `./kickoff.sh`
3. Loop iterates: reads PRD, reads progress, completes next requirement
4. Loop outputs to `progress.md` until COMPLETE or STUCK
5. Human decides when to merge or spin off sub-features

## Branch Naming Convention

Branches map directly to folder structure:
- `feature/auth-refactor` → `docs/features/auth-refactor/`
- `feature/auth-refactor/oauth-provider` → `docs/features/auth-refactor/oauth-provider/`

## Key Files Per Feature

| File | Purpose | Created By |
|------|---------|------------|
| `prd.md` | Requirements checklist | Human |
| `progress.md` | Iteration log and status | Script |
| `.active` | Branch lineage history (in root feature dir) | Script |

## Running the Loop

```bash
# Start new feature
mkdir -p docs/features/my-feature
# Write prd.md with requirements as checkboxes
git checkout -b feature/my-feature
./kickoff.sh

# Spin off sub-feature
git checkout -b feature/my-feature/enhancement
./kickoff.sh
```

## PRD Format

```markdown
# Feature Name

## Context
Brief description of what this feature does.

## Requirements
- [ ] First requirement
- [ ] Second requirement

## Notes
Additional context.
```
