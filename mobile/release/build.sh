#!/bin/bash

set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
ROOT=$(cd -- "$SCRIPT_DIR/../.." && pwd)

version="${1:-}"
output_dir="${2:-$ROOT/dist}"

if [[ -z $version ]]; then
  printf 'Usage: %s <version> [output-directory]\n' "${BASH_SOURCE[0]}" >&2
  exit 2
fi

command -v jq >/dev/null 2>&1 || { printf 'jq is required\n' >&2; exit 1; }
command -v sha256sum >/dev/null 2>&1 || { printf 'sha256sum is required\n' >&2; exit 1; }
git -C "$ROOT" rev-parse HEAD >/dev/null

# shellcheck disable=SC1091
source "$ROOT/mobile/upstream.env"

mkdir -p "$output_dir"
staging=$(mktemp -d)
trap 'rm -rf "$staging"' EXIT

source_name="omarchy-mobile-$version-source"
bundle_name="omarchy-mobile-$version-install-bundle"
source_archive="$output_dir/$source_name.tar.gz"
bundle_archive="$output_dir/$bundle_name.tar.gz"

rm -f "$source_archive" "$bundle_archive" "$output_dir/SHA256SUMS" "$output_dir/release-notes.md"

git -C "$ROOT" archive --format=tar.gz --prefix="$source_name/" -o "$source_archive" HEAD

bundle_root="$staging/$bundle_name"
mkdir -p "$bundle_root/mobile"
cp -R "$ROOT/mobile/." "$bundle_root/mobile/"
cp "$ROOT/README.md" "$bundle_root/README.md"
cp "$ROOT/LICENSE" "$bundle_root/LICENSE"
cp "$ROOT/version" "$bundle_root/omarchy-upstream-version"

upstream_head=$(git -C "$ROOT" rev-parse HEAD)
jq -n \
  --arg version "$version" \
  --arg sourceCommit "$upstream_head" \
  --arg upstreamRepository "$OMARCHY_UPSTREAM_REPOSITORY" \
  --arg upstreamBranch "$OMARCHY_UPSTREAM_BRANCH" \
  --arg upstreamCommit "$OMARCHY_UPSTREAM_COMMIT" \
  --arg referenceDevice "$OMARCHY_MOBILE_REFERENCE_DEVICE" \
  '{schemaVersion: 1, version: $version, sourceCommit: $sourceCommit, upstream: {repository: $upstreamRepository, branch: $upstreamBranch, recordedCommit: $upstreamCommit}, referenceDevice: $referenceDevice, realHardwareValidated: false, bootableImagesIncluded: false, installerBackendIncluded: false, status: "experimental"}' \
  >"$bundle_root/RELEASE-MANIFEST.json"

cat >"$bundle_root/INSTALL.md" <<EOF
# Omarchy Mobile $version install bundle

This bundle was generated from commit $upstream_head. The upstream base recorded by the fork is $OMARCHY_UPSTREAM_REPOSITORY@$OMARCHY_UPSTREAM_COMMIT on branch $OMARCHY_UPSTREAM_BRANCH.

No bootable mobile image or live flashing backend is included. Verify the bundle, read mobile/install/recovery.md, and run mobile/install/install.sh --device google-pixel-10 --dry-run before doing anything else.

The installer is expected to refuse a live Pixel 10 install because the device manifest remains untested.
EOF

tar -C "$staging" -czf "$bundle_archive" "$bundle_name"

(cd "$output_dir" && sha256sum "$(basename "$source_archive")" "$(basename "$bundle_archive")" > SHA256SUMS)

{
  printf '# Omarchy Mobile %s\n\n' "$version"
  printf 'Upstream base: %s (%s @ %s).\n\n' "$OMARCHY_UPSTREAM_REPOSITORY" "$OMARCHY_UPSTREAM_BRANCH" "$OMARCHY_UPSTREAM_COMMIT"
  printf 'Source commit: %s.\n\n' "$upstream_head"
  printf 'Reference device: %s; real hardware validated: false. No bootable image or live flashing backend is included in this release.\n\n' "$OMARCHY_MOBILE_REFERENCE_DEVICE"
  cat "$ROOT/mobile/EXPERIMENTAL_WARNING.md"
  printf '\n## Assets\n\n- %s — complete upstream-based source archive.\n- %s — guarded installer, manifests, recovery checklist, and release metadata.\n- SHA256SUMS — SHA-256 checksums for both archives.\n' "$(basename "$source_archive")" "$(basename "$bundle_archive")"
} >"$output_dir/release-notes.md"

printf 'Created:\n  %s\n  %s\n  %s\n  %s\n' "$source_archive" "$bundle_archive" "$output_dir/SHA256SUMS" "$output_dir/release-notes.md"
