# Writing Effective PRDs

This guide helps you write Product Requirements Documents (PRDs) that enable clear, automated feature development with the Ralph Wiggum Loop.

## PRD Structure

Each PRD consists of:

1. **YAML frontmatter** - Machine-readable metadata for dependency tracking
2. **Context** - Why this feature matters
3. **Requirements** - Specific, testable items to complete
4. **Acceptance Criteria** - How to verify the feature works
5. **Notes** - Additional context for Claude during execution

## YAML Frontmatter

```yaml
---
depends_on:
  - database-setup
  - user-schema
status: blocked
conversation_prompts:
  - "Discuss authentication strategy (OAuth vs JWT vs sessions)"
  - "Define user permission levels and access control"
---
```

### Fields

**`depends_on`** (array of strings)
- List of feature folder names that must complete first
- Use relative paths: `database-setup` not `docs/features/database-setup`
- Empty array `[]` means no dependencies (feature is immediately ready)

**`status`** (string)
- `ready` - No dependencies or all dependencies complete, can start work
- `blocked` - Dependencies not yet complete
- `in-progress` - Currently being worked on (kickoff.sh sets this)
- `complete` - All requirements and acceptance criteria met

**`conversation_prompts`** (array of strings)
- 1-3 topics for deeper exploration before implementation
- Phrased as conversation starters
- Help users know what to discuss with Claude when ready

## Writing Good Requirements

### Be Specific and Testable

❌ **Bad:** Add user authentication
✅ **Good:**
- [ ] User can log in with email and password
- [ ] Invalid credentials show error message
- [ ] Successful login redirects to dashboard

### Make Requirements Atomic

Each requirement should be completable in one iteration of the loop.

❌ **Bad:**
- [ ] Build complete authentication system with OAuth, sessions, and password reset

✅ **Good:**
- [ ] Implement email/password login
- [ ] Add session management with 24-hour expiry
- [ ] Create password reset flow with email verification

### Use Action-Oriented Language

Start with verbs that describe observable behavior:

- [ ] Create user registration form
- [ ] Validate email format on client and server
- [ ] Store hashed passwords in database
- [ ] Send welcome email after registration

### Avoid Implementation Details (Usually)

Focus on **what** needs to happen, not **how** (unless the how is important):

❌ **Bad:** Use bcrypt with cost factor 12 to hash passwords
✅ **Good:** Store passwords securely using industry-standard hashing

**Exception:** If the implementation approach is a specific requirement (e.g., "must use OAuth 2.0"), include it.

## Acceptance Criteria

### Feature-Specific Criteria

These validate that requirements are met correctly:

```markdown
## Acceptance Criteria

### Feature-Specific
- [ ] User can log in with valid credentials
- [ ] Invalid login attempts show clear error messages
- [ ] Session persists across page refreshes
- [ ] User can log out and session is destroyed
- [ ] Concurrent sessions from same user are handled correctly
```

### Standard Criteria

Reference the project-wide standards:

```markdown
### Standard
See [docs/standards.md](../standards.md)
```

This typically includes:
- All tests pass
- No linting/type errors
- Documentation updated
- No console errors

### Writing Good Acceptance Criteria

✅ **Observable behavior:**
- [ ] User sees confirmation message after successful registration
- [ ] Error message displays within 2 seconds of invalid input

✅ **Edge cases:**
- [ ] System handles duplicate email registration gracefully
- [ ] Password reset works even if email contains special characters

✅ **Integration points:**
- [ ] Login state is shared with other components
- [ ] Authentication works with existing API endpoints

❌ **Vague:**
- [ ] System works correctly
- [ ] No bugs

## Context Section

Provide enough background for Claude to understand **why** this feature exists:

```markdown
## Context

Users need to authenticate before accessing protected resources. This feature provides basic email/password authentication as the foundation for our auth system. Future features will add OAuth providers and 2FA.

This builds on the database schema created in `database-setup` feature.
```

**Include:**
- Purpose and user value
- How it fits into the larger system
- What it builds upon or enables

**Keep it brief:** 2-4 sentences usually sufficient

## Notes Section

Add implementation guidance and constraints:

```markdown
## Notes

- Use bcrypt for password hashing (see `utils/crypto.js` for existing helpers)
- Follow the authentication pattern established in `auth-service/`
- Sessions stored in Redis (connection already configured)
- Error messages should NOT reveal whether email exists (security)
```

**Include:**
- Existing code patterns to follow
- Files/modules to reference
- Security considerations
- Constraints or gotchas
- Library/framework preferences

## Dependencies

### Choosing Dependencies

A feature depends on another if it **requires** that feature's output:

✅ **Clear dependency:**
```yaml
depends_on:
  - database-setup  # We need tables to exist
  - user-schema     # We need user model defined
```

❌ **Not a dependency:**
```yaml
depends_on:
  - frontend-styling  # Auth can work without pretty buttons
```

### Ordering Features

The kickoff script uses dependencies to determine what's ready to work on. Structure dependencies to enable parallel work when possible:

**Sequential (slower):**
```
database-setup → user-schema → auth-system → api-endpoints → frontend
```

**Parallel (faster):**
```
database-setup → user-schema → auth-system
              ↓
              api-layer → frontend
```

Both `auth-system` and `api-layer` depend on `user-schema`, but are independent of each other and can be worked on in parallel.

## Example PRD

Here's a complete example:

```markdown
---
depends_on:
  - database-setup
  - user-model
status: blocked
conversation_prompts:
  - "Discuss password reset flow and email template design"
  - "Consider rate limiting strategy for login attempts"
---

# User Authentication

## Context

Users need to securely authenticate before accessing their data. This feature implements basic email/password authentication as the foundation of our auth system. Future features will add OAuth providers and two-factor authentication.

## Requirements

- [ ] User can register with email and password
- [ ] Email validation (format and uniqueness)
- [ ] Password strength requirements enforced
- [ ] User can log in with credentials
- [ ] Invalid login shows appropriate error
- [ ] Session created on successful login
- [ ] User can log out
- [ ] Sessions expire after 24 hours

## Acceptance Criteria

### Feature-Specific
- [ ] Registration form validates email format client-side
- [ ] Server rejects duplicate emails with clear message
- [ ] Passwords must be 8+ characters with mixed case and numbers
- [ ] Login with valid credentials redirects to dashboard
- [ ] Login with invalid credentials shows "Invalid email or password"
- [ ] Session persists across page refreshes
- [ ] Logout clears session and redirects to login
- [ ] Expired sessions redirect to login with message

### Standard
See [docs/standards.md](../standards.md)

## Notes

- Use bcrypt for password hashing (cost factor 12)
- Sessions stored in Redis with 24-hour TTL
- Follow authentication patterns in `services/auth-service.js`
- Error messages must NOT reveal whether email exists (security)
- Use existing validation helpers in `utils/validators.js`
```

## Common Mistakes

### Too Broad
❌ Build a user management system

Fix: Break into smaller features (registration, authentication, profile management, etc.)

### Implementation, Not Requirements
❌ Create POST /auth/login endpoint that accepts JSON with email/password

Fix: Focus on user-facing behavior, let Claude decide implementation details

### Missing Dependencies
❌ Feature needs user model but doesn't list it in `depends_on`

Fix: Explicitly declare all dependencies in frontmatter

### Vague Acceptance Criteria
❌ System handles errors correctly

Fix: Specify what "correctly" means with observable behavior

## Tips

1. **Start with context** - Write the Context section first to clarify your thinking
2. **Think user-first** - Requirements should describe user-facing value
3. **Be atomic** - Each requirement completable in one loop iteration
4. **Test your criteria** - Could someone else verify these without asking questions?
5. **Link related features** - Reference other PRDs in Notes for context
6. **Update as you learn** - It's okay to refine PRDs based on implementation discoveries

## When to Split Features

Consider breaking a feature into sub-features when:

- Requirements list exceeds 10 items
- Feature has distinct phases (basic → advanced)
- Parts can be tested independently
- Different skill sets needed (backend vs frontend)
- You want to merge partial progress

Create sub-features by:
```bash
git checkout -b feature/parent-feature/sub-feature
mkdir -p docs/features/parent-feature/sub-feature
# Write sub-feature PRD
./kickoff.sh
```
