# Project Planning Prompt

You are helping plan a project using the Ralph Loop template repository.

This prompt can be used for:

- Initial project discovery and planning
- Adding new features to an existing project
- Refining or expanding existing plans

## Your Task: Discovery Interview

Conduct a discovery interview by asking these questions **ONE AT A TIME**:

1. **Project essence:** What are you building? (1-2 sentence description)
2. **Target users:** Who will use this and why?
3. **Core functionality:** What are the main features? (3-5 key capabilities)
4. **Technical foundation:** Any language/framework preferences or constraints?
5. **Success criteria:** How will you know this is working well?

Ask each question, wait for the answer, then ask the next. Be conversational and natural.

## After Gathering All Information

Generate the following files:

### 1. Plan Document: `docs/plans/YYYY-MM-DD-<project-name>-initial.md`

Structure:
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
- **Feature Name:** Another topic

## Implementation Sequence

Suggested order based on dependencies:
1. feature-a → feature-b → feature-c
2. feature-d (can start after feature-a)
```

### 2. Feature PRDs: `docs/features/<feature-name>/prd.md`

For each feature, create a directory and PRD with this structure:

```markdown
---
depends_on:
  - dependency-feature-name
status: ready  # or blocked if has dependencies
conversation_prompts:
  - "Topic to explore when ready to implement"
  - "Another topic"
---

# Feature Name

## Context
Brief description of what this feature does and why it matters.

## Requirements
- [ ] Specific, testable requirement
- [ ] Another requirement
- [ ] Final requirement

## Acceptance Criteria

### Feature-Specific
- [ ] Observable validation that requirement is met
- [ ] Edge case handling
- [ ] Integration point verification

### Standard
See [docs/standards.md](../standards.md)

## Notes
Additional context for Claude during execution:
- Existing patterns to follow
- Files to reference
- Constraints or gotchas
```

**Important:**
- Set `status: ready` if `depends_on: []` (no dependencies)
- Set `status: blocked` if the feature has dependencies
- Add 1-3 conversation_prompts for topics to explore later

### 3. Update `docs/standards.md`

Based on the tech stack, add project-specific standards. For example:

- **Python project:** Add PEP 8, type hints, docstrings
- **JavaScript/TypeScript:** Add ESLint, TypeScript compilation
- **Web app:** Add browser compatibility, responsive design
- **API:** Add integration tests, API documentation

### 4. Conversation Transcript: `docs/examples/discovery-conversation.md`

Save a transcript of this discovery conversation showing:
- Questions you asked
- User's answers
- Brief explanation of what was generated

## After Generating All Files

Output a summary showing:
```
✓ Project plan created: docs/plans/...
✓ Feature PRDs generated:
  - docs/features/feature-1/prd.md (ready)
  - docs/features/feature-2/prd.md (blocked)
  ...
✓ Standards defined: docs/standards.md
✓ Example conversation saved: docs/examples/discovery-conversation.md

Next steps:
1. Review the plan and PRDs in docs/
2. Have follow-up conversations to refine features
3. When ready:
   git add .
   git commit -m "Initial project plan"
4. Start first feature:
   git checkout -b feature/<name>
   ./kickoff.sh
```

## Before Exiting

**IMPORTANT:** Ask the user if they want to remove the init-project.sh script.

Use the AskUserQuestion tool with:

- Question: "The init-project.sh script is designed for one-time use. Would you like to remove it now?"
- Options:
  - "Yes - Remove the script (recommended)"
  - "No - Keep it for now"

If the user chooses "Yes", tell them to run:

```bash
rm init-project.sh
```

If the user chooses "No", explain they can remove it later with the same command.

## Critical Requirements

- **DO NOT execute code** - This is planning only, not implementation
- **Create directories** - Use appropriate directory structure
- **Use today's date** - For plan document filename
- **Hierarchical dependencies** - Features that depend on others list them in `depends_on`
- **Conversation prompts** - Each PRD should have topics for deeper exploration
- **Complete PRDs** - Include all sections (Context, Requirements, Acceptance Criteria, Notes)

## Tips

- Break features into logical units based on dependencies
- Consider parallel work opportunities (features with same dependencies)
- Write clear, specific requirements (not implementation details)
- Include both feature-specific and reference to standard acceptance criteria
- Add helpful notes about patterns, files, or constraints Claude should know
