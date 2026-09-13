#!/bin/bash

set -euo pipefail

ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
UPSTREAM_ENV="$ROOT/mobile/upstream.env"

# shellcheck disable=SC1091
source "$UPSTREAM_ENV"

usage() {
  cat <<'EOF'
Usage:
  mobile/sync-upstream.sh --check
  mobile/sync-upstream.sh --apply

Fetch the recorded Omarchy upstream branch and either report divergence or
merge it into the current checkout. The apply path refuses a dirty worktree.
Resolve conflicts deliberately; never use a blanket ours/theirs strategy.
EOF
}

mode=""
case "${1:-}" in
  --check|--apply) mode="$1" ;;
  --help|-h) usage; exit 0 ;;
  *) usage >&2; exit 2 ;;
esac

cd "$ROOT"
if ! git remote get-url upstream >/dev/null 2>&1; then
  git remote add upstream "$OMARCHY_UPSTREAM_REPOSITORY"
fi

git fetch upstream "$OMARCHY_UPSTREAM_BRANCH"
upstream_ref="upstream/$OMARCHY_UPSTREAM_BRANCH"
upstream_commit=$(git rev-parse "$upstream_ref")
current_commit=$(git rev-parse HEAD)

printf 'Upstream: %s\nBranch: %s\nCommit: %s\n' "$OMARCHY_UPSTREAM_REPOSITORY" "$OMARCHY_UPSTREAM_BRANCH" "$upstream_commit"

if git merge-base --is-ancestor "$upstream_commit" "$current_commit"; then
  printf 'Current checkout already contains upstream commit %s.\n' "$upstream_commit"
  exit 0
fi

if [[ $mode == "--check" ]]; then
  printf 'Current checkout does not contain the recorded upstream tip. Run --apply from a clean worktree.\n' >&2
  exit 10
fi

if [[ -n $(git status --short) ]]; then
  printf 'Refusing to merge upstream into a dirty worktree. Commit or stash local changes first.\n' >&2
  exit 11
fi

git merge --no-edit --no-ff "$upstream_ref"
sed -i -E "s/^OMARCHY_UPSTREAM_COMMIT=.*/OMARCHY_UPSTREAM_COMMIT=\"$upstream_commit\"/" "$UPSTREAM_ENV"
printf 'Merged upstream and recorded %s in mobile/upstream.env.\n' "$upstream_commit"
