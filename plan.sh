#!/usr/bin/env bash
set -euo pipefail

# plan.sh
# Launch feature planning conversation with Claude
# Uses plan.md prompt for adding features to existing projects

show_help() {
  echo "=== Feature Planning ==="
  echo ""
  echo "Usage: ./plan.sh [--help|-h]"
  echo ""
  echo "Launches a feature planning conversation with Claude."
  echo ""
  echo "Claude will ask you about:"
  echo "  • What problem this feature solves"
  echo "  • Who benefits and how"
  echo "  • Dependencies on existing features"
  echo "  • Scope (in/out of scope)"
  echo "  • Success criteria"
  echo ""
  echo "After the conversation, Claude will generate:"
  echo "  • Feature plan document"
  echo "  • Feature PRD with dependency tracking"
  echo "  • Conversation transcript"
  echo ""
  echo "Next steps after completion:"
  echo "  1. Review the feature plan: docs/plans/*.md"
  echo "  2. Review feature PRD: docs/features/*/prd.md"
  echo "  3. Commit: git add docs/ && git commit -m \"Plan: <feature-name>\""
  echo "  4. Start implementation: git checkout -b feature/<name> && ./kickoff.sh"
  echo ""
}

# Check for help flag
if [[ "${1:-}" == "--help" ]] || [[ "${1:-}" == "-h" ]]; then
  show_help
  exit 0
fi

# Check for Claude CLI
if ! command -v claude &> /dev/null; then
  echo "❌ Claude CLI not found"
  echo ""
  echo "Install instructions: https://claude.com/code"
  echo ""
  exit 1
fi

# Check if project has been initialized
if [[ ! -d "docs/plans" ]] || [[ -z "$(ls -A docs/plans 2>/dev/null)" ]]; then
  echo "⚠️  No initial plan found in docs/plans/"
  echo ""
  echo "Run ./init-project.sh first to initialize your project."
  echo ""
  exit 1
fi

# Launch Claude with feature planning prompt
cat plan.md | claude
