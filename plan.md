# Feature Planning Prompt

You are helping plan new features for an existing project using the Ralph Loop workflow.

This prompt is for adding features to a project that already has:
- Initial plan in `docs/plans/`
- Existing features in `docs/features/`
- Standards defined in `docs/standards.md`

## Your Task: Feature Discovery

Ask these questions **ONE AT A TIME**:

1. **Feature purpose:** What problem does this solve? (1-2 sentences)
2. **User impact:** Who benefits and how?
3. **Dependencies:** Does this build on existing features?
4. **Scope:** What's included vs future work?
5. **Success:** How will you validate this works?

Be conversational. After each answer, acknowledge and ask the next question.

## After Gathering Information

Generate the following:

### 1. Feature Plan: `docs/plans/YYYY-MM-DD-<feature-name>.md`

```markdown
# Feature Plan: <Feature Name>

**Date:** YYYY-MM-DD
**Type:** Feature Addition

## Purpose
[1-2 sentence problem statement]

## User Impact
[Who benefits, how it changes their workflow]

## Dependencies
**Builds on:** [List of existing features, or "None - standalone"]
**Blocks:** [Features waiting on this, or "None identified"]

## Scope

### In Scope
- Capability 1
- Capability 2
- Capability 3

### Out of Scope (Future Work)
- Future enhancement 1
- Future enhancement 2

## Success Criteria
- [ ] Measurable outcome 1
- [ ] Measurable outcome 2
- [ ] Measurable outcome 3

## Implementation Notes
[Constraints, patterns to follow, integration points]

## Conversation Prompts
Before implementing, explore:
- **Topic 1:** Questions to answer
- **Topic 2:** Decisions to make
```

### 2. Feature PRD: `docs/features/<feature-name>/prd.md`

```yaml
---
depends_on:
  - existing-feature  # or []
status: ready         # or blocked
conversation_prompts:
  - "Deep dive topic"
  - "Design decision"
---

# Feature Name

## Context
Why this matters (2-4 sentences with reference to existing system)

## Requirements
- [ ] Specific, testable requirement
- [ ] Another requirement
- [ ] Integration requirement

## Acceptance Criteria

### Feature-Specific
- [ ] Observable validation
- [ ] Edge case handling
- [ ] Integration verification

### Standard
See [docs/standards.md](../standards.md)

## Notes
Implementation guidance:
- Existing patterns to follow: [file references]
- Integration points: [feature references]
- Constraints: [gotchas]
```

**Key differences from initial planning:**
- Reference existing features in Context
- Link to patterns/files in Notes
- Dependencies likely non-empty
- Narrower scope (feature, not project)

### 3. Conversation Transcript: `docs/examples/<feature-name>-planning.md`

Save this planning conversation showing questions, answers, and what was generated.

## After Generating Files

Output summary:
```
✓ Feature plan: docs/plans/YYYY-MM-DD-<feature>.md
✓ PRD created: docs/features/<feature>/prd.md (ready|blocked)
✓ Example saved: docs/examples/<feature>-planning.md

Next steps:
1. Review plan and PRD
2. Have follow-up conversations if needed
3. Commit:
   git add docs/
   git commit -m "Plan: <feature-name>"
4. Start implementation:
   git checkout -b feature/<feature-name>
   ./kickoff.sh
```

## Critical Requirements

- **DO NOT execute code** - Planning only
- **Reference existing work** - Link to features/files/patterns
- **Check dependencies** - Parse existing PRDs to understand what's available
- **Use today's date** - For plan filename
- **Validate integration** - Ensure new feature fits existing architecture
- **Focused scope** - One feature, not entire system

## Integration Validation

Before generating PRD:
1. List existing features from `docs/features/*/prd.md`
2. Check their status (complete? in-progress?)
3. Identify dependencies (what does this build on?)
4. Note integration points (what files/patterns to follow?)

## Tips

- Smaller features = faster feedback
- Dependencies should be complete or ready
- Clear boundary between this and related features
- Specific requirements (avoid "good" or "appropriate")
- Notes should reference actual files/patterns

## About .active Files

The kickoff.sh script automatically creates and maintains a `.active` file in the root feature directory. This file:

- Tracks all branches that have worked on this feature and its sub-features
- Shows the branch lineage (e.g., `feature/auth`, `feature/auth/oauth`, `feature/auth/session`)
- Provides debugging context when reviewing work before merge
- Is automatically updated - you don't need to create or modify it
