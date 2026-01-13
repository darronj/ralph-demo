#!/usr/bin/env bash
set -euo pipefail

# init-project.sh
# Bootstraps a new project with guided discovery conversation
# Self-deletes after completion

SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"

echo "=== Project Initialization ==="
echo ""

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

# Check for files that might be overwritten
POTENTIAL_CONFLICTS=()

# Check for existing plan files with today's date
TODAY=$(date +%Y-%m-%d)
if compgen -G "docs/plans/${TODAY}-*-initial.md" > /dev/null 2>&1; then
  POTENTIAL_CONFLICTS+=("docs/plans/${TODAY}-*-initial.md")
fi

# Check if standards.md exists
if [[ -f "docs/standards.md" ]]; then
  POTENTIAL_CONFLICTS+=("docs/standards.md")
fi

# Check if discovery conversation example exists
if [[ -f "docs/examples/discovery-conversation.md" ]]; then
  POTENTIAL_CONFLICTS+=("docs/examples/discovery-conversation.md")
fi

# Warn if any conflicts found
if [[ ${#POTENTIAL_CONFLICTS[@]} -gt 0 ]]; then
  echo "⚠️  WARNING: The following files may be overwritten:"
  echo ""
  for file in "${POTENTIAL_CONFLICTS[@]}"; do
    echo "  • $file"
  done
  echo ""
  read -p "Continue anyway? (y/N) " -n 1 -r
  echo ""
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Initialization cancelled."
    exit 0
  fi
  echo ""
fi

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
cat initial-plan.md | claude

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
