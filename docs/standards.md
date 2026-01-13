# Standard Acceptance Criteria

All features must meet these criteria before being marked complete:

- [ ] All tests pass
- [ ] No linting/type errors
- [ ] Code follows project conventions
- [ ] Documentation updated (README, inline comments where needed)
- [ ] No console errors or warnings
- [ ] Feature works as described in requirements

## Customization

This file will be customized during `init-project.sh` based on your project's tech stack and requirements.

You can edit this file at any time to add project-specific standards. These standards apply to ALL features unless explicitly noted otherwise in a feature PRD.

## Example Project-Specific Standards

When you run `./init-project.sh`, Claude will help generate standards appropriate for your project. Here are examples:

**For a Python project:**
- [ ] Code follows PEP 8 style guide
- [ ] Type hints used for function signatures
- [ ] Docstrings present for public functions

**For a JavaScript/TypeScript project:**
- [ ] ESLint passes with no errors
- [ ] TypeScript compiles without errors (if applicable)
- [ ] No unused variables or imports

**For a web application:**
- [ ] No console errors in browser
- [ ] Works in latest Chrome, Firefox, Safari
- [ ] Responsive design works on mobile

**For an API:**
- [ ] All endpoints have integration tests
- [ ] Error responses include helpful messages
- [ ] API documentation updated (OpenAPI/Swagger)

**For performance-critical features:**
- [ ] Load time under X seconds
- [ ] Response time under X milliseconds
- [ ] Memory usage within acceptable bounds

## Why Standard Criteria?

Standard acceptance criteria ensure consistent quality across all features without cluttering individual PRDs. They represent your project's definition of "done."

Feature-specific acceptance criteria (in each PRD) validate that the feature works correctly. Standard criteria (this file) validate that it's production-ready.
