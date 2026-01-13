# Context Usage Report

Generated: 2026-01-13

## Overview

**Model:** claude-sonnet-4-5-20250929
**Tokens:** 48.9k / 200.0k (24%)

## Context Categories

| Category | Tokens | Percentage |
|----------|--------|------------|
| System prompt | 3.2k | 1.6% |
| System tools | 19.2k | 9.6% |
| MCP tools | 19.8k | 9.9% |
| Custom agents | 1.3k | 0.7% |
| Memory files | 1.7k | 0.9% |
| Skills | 1.4k | 0.7% |
| Messages | 2.2k | 1.1% |
| Free space | 106.1k | 53.1% |
| Autocompact buffer | 45.0k | 22.5% |

## MCP Servers

### Atlassian Server

Tools for Jira and Confluence integration:

#### Confluence Tools

| Tool | Tokens | Description |
|------|--------|-------------|
| getConfluenceSpaces | 628 | List Confluence spaces |
| getConfluencePage | 378 | Get page content by ID |
| getPagesInConfluenceSpace | 475 | List pages in a space |
| getConfluencePageFooterComments | 373 | Get footer comments |
| getConfluencePageInlineComments | 405 | Get inline comments |
| getConfluencePageDescendants | 299 | Get child pages |
| createConfluencePage | 449 | Create new page |
| updateConfluencePage | 465 | Update existing page |
| createConfluenceFooterComment | 334 | Add footer comment |
| createConfluenceInlineComment | 500 | Add inline comment |
| searchConfluenceUsingCql | 449 | CQL search |

#### Jira Tools

| Tool | Tokens | Description |
|------|--------|-------------|
| getJiraIssue | 366 | Get issue details |
| editJiraIssue | 303 | Update issue |
| createJiraIssue | 679 | Create new issue |
| getTransitionsForJiraIssue | 357 | Get available transitions |
| getJiraIssueRemoteIssueLinks | 419 | Get remote links |
| getVisibleJiraProjects | 443 | List projects |
| getJiraProjectIssueTypesMetadata | 294 | Get issue types |
| getJiraIssueTypeMetaWithFields | 330 | Get field metadata |
| addCommentToJiraIssue | 413 | Add comment |
| transitionJiraIssue | 760 | Transition issue status |
| searchJiraIssuesUsingJql | 393 | JQL search |
| lookupJiraAccountId | 220 | Find user by name/email |
| addWorklogToJiraIssue | 413 | Log work time |

#### General Atlassian Tools

| Tool | Tokens | Description |
|------|--------|-------------|
| atlassianUserInfo | 83 | Get current user info |
| getAccessibleAtlassianResources | 92 | Get cloud IDs |
| search | 140 | Unified Rovo search |
| fetch | 185 | Get resource by ARI |

**Total Atlassian Tools:** 28
**Total Tokens:** ~11.4k

### Sequential Thinking Server

| Tool | Tokens | Description |
|------|--------|-------------|
| sequentialthinking | 1.1k | Multi-step reasoning with branching |

### Chrome DevTools Server

Browser automation and inspection tools:

| Tool | Tokens | Description |
|------|--------|-------------|
| click | 136 | Click element |
| close_page | 124 | Close page |
| drag | 138 | Drag and drop |
| emulate | 355 | Emulate device/network |
| evaluate_script | 280 | Execute JavaScript |
| fill | 144 | Fill form field |
| fill_form | 176 | Fill multiple fields |
| get_console_message | 131 | Get console message |
| get_network_request | 135 | Get network request |
| handle_dialog | 145 | Handle dialog |
| hover | 109 | Hover over element |
| list_console_messages | 323 | List console messages |
| list_network_requests | 329 | List network requests |
| list_pages | 75 | List open pages |
| navigate_page | 204 | Navigate to URL |
| new_page | 137 | Open new page |
| performance_analyze_insight | 197 | Analyze performance |
| performance_start_trace | 189 | Start trace |
| performance_stop_trace | 79 | Stop trace |
| press_key | 173 | Press keyboard key |
| resize_page | 129 | Resize window |
| select_page | 150 | Select page |
| take_screenshot | 303 | Screenshot page/element |
| take_snapshot | 213 | Take a11y snapshot |
| upload_file | 151 | Upload file |
| wait_for | 143 | Wait for text |

**Total Chrome DevTools Tools:** 26
**Total Tokens:** ~4.3k

### Playwright Server

Browser automation with Playwright:

| Tool | Tokens | Description |
|------|--------|-------------|
| browser_close | 73 | Close browser |
| browser_resize | 122 | Resize window |
| browser_console_messages | 134 | Get console messages |
| browser_handle_dialog | 126 | Handle dialog |
| browser_evaluate | 171 | Execute JavaScript |
| browser_file_upload | 126 | Upload files |
| browser_fill_form | 276 | Fill form fields |
| browser_install | 91 | Install browser |
| browser_press_key | 120 | Press key |
| browser_type | 228 | Type text |
| browser_navigate | 98 | Navigate to URL |
| browser_navigate_back | 78 | Go back |
| browser_network_requests | 120 | List network requests |
| browser_run_code | 164 | Run Playwright code |
| browser_take_screenshot | 326 | Take screenshot |
| browser_snapshot | 109 | Take snapshot |
| browser_click | 253 | Click element |
| browser_drag | 209 | Drag and drop |
| browser_hover | 136 | Hover element |
| browser_select_option | 184 | Select dropdown option |
| browser_tabs | 152 | Manage tabs |
| browser_wait_for | 150 | Wait for condition |

**Total Playwright Tools:** 22
**Total Tokens:** ~3.4k

## Custom Agents

| Agent Type | Source | Tokens | Purpose |
|------------|--------|--------|---------|
| code-reviewer | Plugin | 247 | Review code against plan |
| prompt-engineer | User | 239 | Create/refine AI prompts |
| accessibility-reviewer | User | 412 | WCAG compliance review |
| dev-hours-estimator | User | 414 | Estimate development time |

**Total Custom Agents:** 4
**Total Tokens:** 1.3k

## Memory Files

| Type | Path | Tokens |
|------|------|--------|
| User Global | ~/.claude/CLAUDE.md | 76 |
| Project | ./CLAUDE.md | 1.7k |

**Total Memory:** 1.7k

## Skills (Superpowers)

### Planning & Execution

| Skill | Tokens |
|-------|--------|
| execute-plan | 18 |
| write-plan | 20 |
| brainstorm | 19 |
| brainstorming | 71 |
| writing-plans | 75 |
| executing-plans | 59 |
| subagent-driven-development | 61 |

### Development Practices

| Skill | Tokens |
|-------|--------|
| test-driven-development | 62 |
| testing-anti-patterns | 66 |
| testing-skills-with-subagents | 78 |
| verification-before-completion | 67 |
| condition-based-waiting | 65 |

### Debugging & Problem Solving

| Skill | Tokens |
|-------|--------|
| systematic-debugging | 71 |
| root-cause-tracing | 69 |
| defense-in-depth | 54 |
| dispatching-parallel-agents | 59 |

### Workflow & Integration

| Skill | Tokens |
|-------|--------|
| using-superpowers | 66 |
| using-git-worktrees | 59 |
| finishing-a-development-branch | 61 |
| sharing-skills | 61 |
| writing-skills | 64 |

### Code Review

| Skill | Tokens |
|-------|--------|
| requesting-code-review | 66 |
| receiving-code-review | 67 |

### Ralph Loop

| Skill | Tokens |
|-------|--------|
| ralph-loop:help | 16 |
| ralph-loop:cancel-ralph | 12 |
| ralph-loop:ralph-loop | 14 |

**Total Skills:** 29
**Total Tokens:** 1.4k

## Summary

- **Total MCP Tools:** 76 tools across 4 servers
- **Most Token-Heavy Server:** Atlassian (11.4k tokens)
- **Most Tools:** Atlassian (28 tools)
- **Context Usage:** 24% of available capacity
- **Free Space:** 106.1k tokens (53.1%)
- **Autocompact Buffer:** 45.0k tokens (22.5%)
