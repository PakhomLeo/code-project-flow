#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/PakhomLeo/code-project-flow.git"
SKILL_NAME="code-project-flow"

# Console messages are English on purpose: this script also runs under
# non-UTF-8 locales where translated output would turn into mojibake.

resolve_skills_root() {
  if [ -n "${1:-}" ]; then
    printf '%s\n' "$1"
  elif [ -d "$HOME/.qoder-cn/skills" ]; then
    printf '%s\n' "$HOME/.qoder-cn/skills"
  elif [ -d "$HOME/.qoder/skills" ]; then
    printf '%s\n' "$HOME/.qoder/skills"
  else
    printf '%s\n' "$HOME/.qoder-cn/skills"
  fi
}

SKILLS_ROOT="$(resolve_skills_root "${1:-}")"
TARGET="$SKILLS_ROOT/$SKILL_NAME"

if ! command -v git >/dev/null 2>&1; then
  echo "git is required but was not found on PATH." >&2
  exit 1
fi

if [ -d "$TARGET/.git" ]; then
  echo "Already installed, updating: $TARGET"
  git -C "$TARGET" pull --ff-only
  echo "Done. Start a new agent session for it to take effect."
  exit 0
fi

if [ -e "$TARGET" ]; then
  echo "Target exists and is not a git checkout: $TARGET" >&2
  echo "Rename or remove it yourself, then run this script again." >&2
  exit 1
fi

mkdir -p "$SKILLS_ROOT"
git clone --depth 1 "$REPO_URL" "$TARGET"
echo "Installed: $TARGET"
echo "Start a new agent session for it to take effect."
