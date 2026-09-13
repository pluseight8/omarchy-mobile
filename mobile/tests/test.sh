#!/bin/bash

set -euo pipefail

ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)
export OMARCHY_PATH="${OMARCHY_PATH:-$ROOT}"

fail() {
  printf 'not ok - %s\n' "$1" >&2
  exit 1
}

pass() {
  printf 'ok - %s\n' "$1"
}

command -v jq >/dev/null 2>&1 || fail "jq is available"

bash -n "$ROOT/bin/omarchy-mobile" "$ROOT/mobile/lib/common.sh" "$ROOT/mobile/install/install.sh" "$ROOT/mobile/release/build.sh" "$ROOT/mobile/sync-upstream.sh"
pass "mobile shell scripts parse"

jq -e '(.schemaVersion == 1) and (.referenceDevice == "google-pixel-10") and (.devices | length >= 3)' "$ROOT/mobile/devices/index.json" >/dev/null
pass "device index has the Pixel reference and generic templates"

jq -e '(.id == "google-pixel-10") and (.status == "untested") and (.realHardwareValidated == false) and (.boot.imagesAvailable == false) and (.boot.installerAvailable == false)' "$ROOT/mobile/devices/google/pixel-10.json" >/dev/null
pass "Pixel 10 stays explicitly untested and non-installable"

status=$(OMARCHY_MOBILE_DEVICE=google-pixel-10 "$ROOT/bin/omarchy-mobile" status --json)
jq -e '(.device == "google-pixel-10") and (.realHardwareValidated == false) and (.boot.imagesAvailable == false) and (.boot.installerAvailable == false)' <<<"$status" >/dev/null
pass "status JSON exposes the honest device gates"

plan=$("$ROOT/mobile/install/install.sh" --device google-pixel-10 --dry-run)
grep -Fq 'Dry run result: blocked safely' <<<"$plan" || fail "dry-run refuses the unvalidated Pixel safely"
pass "installer dry-run is non-destructive"

grep -Fq 'Текущие сборки ещё не были протестированы разработчиком на реальных устройствах' "$ROOT/README.md" || fail "root README carries the required warning"
grep -Fq 'Текущие сборки ещё не были протестированы разработчиком на реальных устройствах' "$ROOT/mobile/install/INSTALL.md" || fail "installer instructions carry the required warning"
pass "required experimental warning is present in user-facing files"

printf 'mobile contract tests passed\n'
