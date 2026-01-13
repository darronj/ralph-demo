#!/usr/bin/env bash
set -euo pipefail

# init-project.sh
# Bootstraps a new project with guided discovery conversation
# Self-deletes after completion

SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"

echo "=== Project Initialization ==="
echo ""

# Check if already initialized
if [[ -d "docs/plans" ]] && [[ -n "$(ls -A docs/plans 2>/dev/null)" ]]; then
  echo "❌ Project already initialized (docs/plans/ contains files)"
  echo ""
  echo "To re-initialize:"
  echo "  rm -rf docs/plans docs/features"
  echo "  git checkout docs/standards.md docs/examples/"
  echo ""
  exit 1
fi

# Check for Claude CLI
if ! command -v claude &> /dev/null; then
  echo "❌ Claude CLI not found"
  echo ""
  echo "Install instructions: https://claude.com/code"
  echo ""
  exit 1
fi

# Create required directories
mkdir -p docs/{plans,features,architecture,examples}

echo "Starting discovery conversation with Claude..."
echo ""
echo "Claude will ask you about:"
echo "  • What you're building and why"
echo "  • Who will use it"
echo "  • Core functionality (3-5 key features)"
echo "  • Technical preferences"
echo "  • Success criteria"
echo ""
echo "After the conversation, Claude will generate:"
echo "  • Project plan document"
echo "  • Feature PRDs with dependency tracking"
echo "  • Standards document"
echo ""
read -p "Press Enter to begin..."
echo ""

# Launch Claude with planning prompt from file
cat plan.md | claude

CLAUDE_EXIT=$?

if [[ $CLAUDE_EXIT -ne 0 ]]; then
  echo ""
  echo "❌ Discovery conversation failed"
  echo ""
  echo "You can run this script again to retry."
  exit 1
fi

echo ""
echo "=== Initialization Complete ==="
echo ""
echo "✓ Project plan and features generated in docs/"
echo ""
echo "Next steps:"
echo "  1. Review the plan: docs/plans/*.md"
echo "  2. Review feature PRDs: docs/features/*/prd.md"
echo "  3. Review standards: docs/standards.md"
echo "  4. Have follow-up conversations to refine (see 'Future Conversations' in plan)"
echo "  5. When ready:"
echo "       git add ."
echo "       git commit -m \"Initial project plan\""
echo "  6. Start first feature:"
echo "       git checkout -b feature/<feature-name>"
echo "       ./kickoff.sh"
echo ""
echo "Removing init script (one-time use)..."
rm -- "$SCRIPT_PATH"
echo "Done!"
