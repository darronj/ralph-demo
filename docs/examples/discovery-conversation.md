# Example Discovery Conversation

This is an example of what the initial discovery conversation looks like when you run `./init-project.sh`.

---

## Conversation Transcript

**Claude:** I'll help you plan your project. Let's start with the essentials.

What are you building? Give me a 1-2 sentence description of your project.

**User:** A command-line todo list manager that syncs with a simple web interface

**Claude:** Great! A todo list with both CLI and web access.

Who will use this? Describe your target users and their main use cases.

**User:** Developers who live in the terminal but occasionally want to check their tasks from a browser. Main use case is quick task entry/completion via CLI, with the web UI for reviewing and organizing.

**Claude:** Perfect - focused on developer workflow.

What are the core features you need? List 3-5 key capabilities this tool must have.

**User:**
1. Add, complete, and list tasks from CLI
2. Simple web dashboard to view all tasks
3. Sync between CLI and web in real-time
4. Basic task organization (tags or projects)
5. Local-first, no cloud required

**Claude:** Excellent feature set. Local-first with real-time sync is a great choice for developers.

Any technical preferences or constraints? For example, preferred languages, frameworks, or deployment requirements.

**User:** Python for the CLI (I'm comfortable with Click), Node.js with Express for the web backend, vanilla JavaScript for the frontend to keep it simple. SQLite for local storage. No Docker/Kubernetes - should run easily on a laptop.

**Claude:** Python CLI, Node.js backend, vanilla JS frontend, SQLite storage. Clean and straightforward stack.

Finally, how will you know this is working well? What are your success criteria?

**User:**
- I can add a task via CLI and see it in the web UI within a second
- Tasks persist across restarts
- Zero setup complexity - clone and run
- Fast CLI response (under 100ms for most commands)

**Claude:** Perfect! I have everything I need. Let me generate your project plan and feature PRDs.

---

## Generated Plan

**File:** `docs/plans/2026-01-13-todo-sync-initial.md`

```markdown
# Project Plan: Todo Sync

**Date:** 2026-01-13
**Type:** Initial Discovery

## Project Overview

### Purpose
A command-line todo list manager with web interface, designed for developers who live in the terminal but occasionally need browser access. Features local-first architecture with real-time synchronization between CLI and web.

### Target Users
Developers who prefer terminal workflows but value visual task organization through a web UI. Primary use case is rapid task entry/completion via CLI with web-based review and organization.

### Success Criteria
- Tasks added via CLI appear in web UI within 1 second
- All data persists across application restarts
- Zero setup complexity (clone and run)
- CLI commands respond under 100ms

## Technical Foundation

**Stack:**
- CLI: Python with Click
- Backend: Node.js with Express
- Frontend: Vanilla JavaScript
- Database: SQLite

**Architecture:** Local-first application with WebSocket-based synchronization between CLI and web interface

**Key Constraints:**
- Must run easily on a laptop without Docker/Kubernetes
- No cloud dependencies
- Minimal setup required

## Feature Breakdown

### 1. SQLite Database Setup
**Path:** `docs/features/database-setup/`
**Dependencies:** None
**Purpose:** Create schema for tasks, tags, and sync metadata

**Key Requirements:**
- Design task table schema (id, text, completed, created_at, updated_at)
- Create tags/projects table
- Add indexes for common queries
- Migration system for schema updates

### 2. CLI Task Management
**Path:** `docs/features/cli-task-management/`
**Dependencies:** database-setup
**Purpose:** Core CLI commands for task operations

**Key Requirements:**
- `todo add "task text"` - Create new task
- `todo list` - Show all incomplete tasks
- `todo complete <id>` - Mark task as done
- `todo list --all` - Show completed tasks too
- Response time under 100ms

### 3. Web Backend API
**Path:** `docs/features/web-backend-api/`
**Dependencies:** database-setup
**Purpose:** Express server with REST API and WebSocket support

**Key Requirements:**
- REST endpoints for task CRUD operations
- WebSocket server for real-time updates
- CORS configuration for local development
- Static file serving for frontend

### 4. Web Frontend Dashboard
**Path:** `docs/features/web-frontend-dashboard/`
**Dependencies:** web-backend-api
**Purpose:** Simple vanilla JS interface for viewing and managing tasks

**Key Requirements:**
- Task list view with complete/uncomplete toggle
- Add new task form
- Filter by completion status
- WebSocket connection for live updates
- Responsive layout

### 5. Real-Time Sync Layer
**Path:** `docs/features/realtime-sync-layer/`
**Dependencies:** cli-task-management, web-backend-api
**Purpose:** Coordinate updates between CLI and web clients

**Key Requirements:**
- CLI publishes changes to sync server
- Web clients receive updates via WebSocket
- Handle concurrent updates (last-write-wins)
- Sync latency under 1 second

### 6. Task Organization
**Path:** `docs/features/task-organization/`
**Dependencies:** cli-task-management, web-frontend-dashboard
**Purpose:** Tags/projects for organizing tasks

**Key Requirements:**
- Add tags to tasks via CLI: `todo add "task" --tag work`
- Filter by tag in CLI: `todo list --tag work`
- Tag management in web UI
- Multiple tags per task

## Future Conversations

Before implementing these features, consider deeper discussions on:

- **Real-Time Sync Layer:** Conflict resolution strategy (last-write-wins vs operational transforms), handling offline CLI usage
- **Task Organization:** Tags vs projects vs both, hierarchical organization
- **Web Backend API:** Authentication for multi-user scenarios (if needed later)
- **Database Setup:** Data export/import format, backup strategy
- **CLI Task Management:** Advanced filtering (by date, priority), task editing

## Implementation Sequence

Suggested order based on dependencies:

1. **database-setup** → foundation for everything
2. **cli-task-management** and **web-backend-api** (can be parallel)
3. **web-frontend-dashboard** (after web-backend-api)
4. **realtime-sync-layer** (after both CLI and web are functional)
5. **task-organization** (enhancement, can be done last)
```

---

## Generated Feature PRDs

**File:** `docs/features/database-setup/prd.md`

```markdown
---
depends_on: []
status: ready
conversation_prompts:
  - "Discuss migration strategy and schema versioning approach"
  - "Consider indexing strategy for filtering and search queries"
---

# SQLite Database Setup

## Context

Foundational database schema for todo sync application. Supports task storage, organization via tags, and metadata for synchronization between CLI and web clients.

## Requirements

- [ ] Create tasks table (id, text, completed, created_at, updated_at)
- [ ] Create tags table (id, name)
- [ ] Create task_tags junction table
- [ ] Add indexes on task.completed and task.created_at
- [ ] Create database initialization script
- [ ] Add sample data for development/testing

## Acceptance Criteria

### Feature-Specific
- [ ] Database file created at `./data/todo.db`
- [ ] Schema matches documented structure
- [ ] Indexes improve query performance for common filters
- [ ] Sample data includes 5 tasks with various tags
- [ ] Initialization script is idempotent (safe to run multiple times)

### Standard
See [docs/standards.md](../standards.md)

## Notes

- Use SQLite3 native to Python/Node (no external dependencies)
- Place database file in `./data/` directory (create if missing)
- Use `INTEGER PRIMARY KEY AUTOINCREMENT` for IDs
- Timestamps should be ISO 8601 strings for cross-language compatibility
```

**File:** `docs/features/cli-task-management/prd.md`

```markdown
---
depends_on:
  - database-setup
status: blocked
conversation_prompts:
  - "Discuss CLI output formatting preferences (plain vs colored, table vs list)"
  - "Consider additional commands like edit, delete, search"
---

# CLI Task Management

## Context

Core command-line interface for rapid task entry and completion. Primary interaction method for developers who live in the terminal. Must be fast (< 100ms) and intuitive.

## Requirements

- [ ] Implement `todo add "<text>"` command
- [ ] Implement `todo list` command (shows incomplete tasks)
- [ ] Implement `todo complete <id>` command
- [ ] Implement `todo list --all` flag (shows all tasks)
- [ ] Add help text for each command
- [ ] Command response time under 100ms

## Acceptance Criteria

### Feature-Specific
- [ ] Adding task returns confirmation with assigned ID
- [ ] List shows tasks in reverse chronological order (newest first)
- [ ] Completed tasks marked visually (strikethrough or checkmark)
- [ ] Invalid commands show helpful error messages
- [ ] Performance measured under 100ms on typical workload
- [ ] Works from any directory (globally accessible)

### Standard
See [docs/standards.md](../standards.md)

## Notes

- Use Click framework (specified in technical preferences)
- Follow Click best practices for command structure
- Use emoji or ANSI colors sparingly (should work in basic terminals)
- Database path: `./data/todo.db` relative to project root
- Package as installable CLI tool with entry point
```

*(Additional PRD files would be generated for remaining features following the same pattern)*

---

## Generated Standards

**File:** `docs/standards.md`

```markdown
# Standard Acceptance Criteria

All features must meet these criteria before being marked complete:

- [ ] All tests pass
- [ ] No linting/type errors
- [ ] Code follows project conventions
- [ ] Documentation updated (README, inline comments where needed)
- [ ] No console errors or warnings (for web features)
- [ ] Feature works as described in requirements

## Project-Specific Standards

- [ ] Python code follows PEP 8 (enforced by flake8)
- [ ] JavaScript follows StandardJS conventions
- [ ] CLI commands respond in under 100ms
- [ ] Database queries use parameterized statements (no SQL injection)
- [ ] Error messages are user-friendly and actionable

## Customization

Feel free to add project-specific standards here. These apply to ALL features unless explicitly noted otherwise in a feature PRD.
```

---

## Next Steps (Output to User)

```
✓ Project plan created: docs/plans/2026-01-13-todo-sync-initial.md
✓ Feature PRDs generated:
  - docs/features/database-setup/prd.md (ready)
  - docs/features/cli-task-management/prd.md (blocked)
  - docs/features/web-backend-api/prd.md (blocked)
  - docs/features/web-frontend-dashboard/prd.md (blocked)
  - docs/features/realtime-sync-layer/prd.md (blocked)
  - docs/features/task-organization/prd.md (blocked)
✓ Standards defined: docs/standards.md
✓ Example conversation saved: docs/examples/discovery-conversation.md

Next steps:
1. Review the plan and PRDs in docs/
2. Have follow-up conversations to refine features (see "Future Conversations" in plan)
3. When ready:
   git add .
   git commit -m "Initial project plan"
4. Start first feature:
   git checkout -b feature/database-setup
   ./kickoff.sh

The init script has completed and removed itself.
```

---

## Tips for Your Discovery Conversation

### Be Specific About Your Stack
The more specific you are about technical preferences, the better Claude can generate appropriate PRDs. "Use Python" is okay, but "Use Python with Click for CLI" is better.

### Think About Success Criteria
These become the foundation for acceptance criteria in PRDs. Quantifiable metrics ("under 100ms", "within 1 second") are especially helpful.

### Core Features First
You'll be asked for 3-5 key capabilities. Focus on what makes the project viable. Nice-to-haves can be added later as additional features.

### Constraints Matter
Mention deployment constraints ("no Docker"), performance requirements ("must run on a laptop"), or architectural preferences ("local-first") early. These influence the entire plan.

### You Can Always Refine
The generated plan is a starting point. You can have follow-up conversations with Claude to explore the "Future Conversations" topics before implementing features.
