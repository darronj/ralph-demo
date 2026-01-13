# Project Template

A template repository for starting new projects with Claude Code. Includes guided discovery conversation and automated feature development workflow.

## Quick Start

1. **Clone this template:**

   ```bash
   git clone https://github.com/your-org/ralph-demo my-new-project
   cd my-new-project
   rm -rf .git && git init
   git add . && git commit -m "Initial commit from template"
   ```

2. **Initialize your project:**

   ```bash
   ./init-project.sh
   ```

   This launches a conversation with Claude to understand your project goals and generate an initial plan.

3. **Review the generated plan:**
   - Plan document: `docs/plans/YYYY-MM-DD-<project>-initial.md`
   - Feature PRDs: `docs/features/*/prd.md`
   - Standards: `docs/standards.md`
   - Example conversation: `docs/examples/discovery-conversation.md`

4. **Refine (optional):**

   Have follow-up conversations with Claude to explore topics suggested in the plan's "Future Conversations" section.

5. **Commit your plan:**

   ```bash
   git add .
   git commit -m "Initial project plan"
   ```

6. **Start building:**

   ```bash
   git checkout -b feature/<feature-name>
   ./kickoff.sh
   ```

## How It Works

### Discovery Phase

The init script guides you through questions about:

- **What you're building** - Project purpose and description
- **Who will use it** - Target users and use cases
- **Core functionality** - Main features (3-5 key capabilities)
- **Technical preferences** - Language, framework, constraints
- **Success criteria** - Measurable outcomes

Claude generates a structured plan with feature PRDs that have:

- Dependency tracking (knows what must complete first)
- Status tracking (blocked, ready, in-progress, complete)
- Future conversation prompts (topics to explore when ready)
- Acceptance criteria (both feature-specific and standard)

### Development Phase

Features follow the **Ralph Wiggum Loop** (see [docs/architecture/ralph-wiggum-loop.md](docs/architecture/ralph-wiggum-loop.md)):

1. Create feature branch: `git checkout -b feature/<feature-name>`
2. Run `./kickoff.sh`
3. Script validates dependencies are complete
4. Loop runs automated iterations against PRD requirements
5. Feature completes and commits automatically
6. Review, merge, or spin off sub-features

### Dependency Management

Each PRD tracks dependencies via YAML frontmatter:

```yaml
---
depends_on:
  - database-setup
  - user-schema
status: blocked  # blocked|ready|in-progress|complete
---
```

The kickoff script:

- ✓ Validates dependencies are complete before starting
- ✓ Updates status through workflow (ready → in-progress → complete)
- ✓ Suggests newly unblocked features when work completes

## Project Structure

```text
docs/
  plans/              # Planning documents from discovery
  features/           # Feature PRDs and progress tracking
    <feature-name>/
      prd.md          # Requirements, dependencies, acceptance criteria
      progress.md     # Auto-generated iteration log
  architecture/       # System design documentation
  examples/           # Example conversations and templates
  standards.md        # Standard acceptance criteria for all features

init-project.sh       # Start here for new projects (self-deletes after use)
kickoff.sh            # Run feature automation with dependency validation
.gitignore            # Excludes generated files (.active, progress.md)
```

## Writing Effective PRDs

See [docs/architecture/writing-prds.md](docs/architecture/writing-prds.md) for guidance on:

- Writing atomic, testable requirements
- Crafting good acceptance criteria
- Structuring notes for Claude context
- When to break features into sub-features

## Example Workflow

```bash
# 1. Initialize project
./init-project.sh
# ... have discovery conversation ...
# ✓ Plan generated in docs/plans/
# ✓ Features generated in docs/features/

# 2. Review and commit
git add .
git commit -m "Initial project plan"

# 3. Start first feature (no dependencies)
git checkout -b feature/database-setup
./kickoff.sh
# ✓ Validates PRD exists
# ✓ Checks status is 'ready'
# ✓ Runs automated loop
# ✓ Commits on completion

# 4. Start dependent feature
git checkout master
git checkout -b feature/auth-system
./kickoff.sh
# ✓ Validates dependency 'database-setup' is complete
# ✓ Runs automated loop

# 5. Spin off sub-feature
git checkout -b feature/auth-system/oauth-provider
./kickoff.sh
# ✓ Creates sub-feature PRD if needed
# ✓ Validates parent feature complete
```

## Dependencies

The kickoff script requires `yq` for YAML parsing:

```bash
# macOS
brew install yq

# Linux
wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/local/bin/yq
chmod +x /usr/local/bin/yq
```

## Learn More

- [Ralph Wiggum Loop explanation](docs/architecture/ralph-wiggum-loop.md) - How the automation works
- [Writing effective PRDs](docs/architecture/writing-prds.md) - PRD best practices
- [Example discovery conversation](docs/examples/discovery-conversation.md) - What to expect from init

## Why "Ralph Wiggum Loop"?

The loop keeps trying, one step at a time, with cheerful persistence. Sometimes it gets stuck. Sometimes it succeeds in unexpected ways. But it keeps going until it's done or needs help.

Just like Ralph, it's doing its best.
