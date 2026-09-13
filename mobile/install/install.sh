#!/bin/bash

set -euo pipefail

MOBILE_ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
export MOBILE_ROOT

# shellcheck disable=SC1091
source "$MOBILE_ROOT/lib/common.sh"

show_help() {
  cat <<'EOF'
Usage:
  install.sh --device <id> [--dry-run] [--bundle <path>] [--acknowledge-risk]

The current release contains a guarded verification/planning path only. It
does not contain a boot image or a device flashing backend. A live install is
refused until the selected manifest explicitly provides both and a validation
report exists.

Options:
  --device <id>          Device manifest to inspect; defaults to detection.
  --bundle <path>        Release bundle to verify before planning.
  --dry-run              Print the plan and blockers without changing a device.
  --acknowledge-risk     Acknowledge the experimental warning for a future live install.
  --help                 Show this help.
EOF
}

device=""
bundle=""
dry_run="false"
acknowledged="false"

while (( $# > 0 )); do
  case "$1" in
    --device)
      (( $# >= 2 )) || mobile_die "--device requires a value"
      device="$2"
      shift 2
      ;;
    --bundle)
      (( $# >= 2 )) || mobile_die "--bundle requires a path"
      bundle="$2"
      shift 2
      ;;
    --dry-run)
      dry_run="true"
      shift
      ;;
    --acknowledge-risk)
      acknowledged="true"
      shift
      ;;
    --help|-h)
      show_help
      exit 0
      ;;
    *)
      mobile_die "unknown installer option: $1"
      show_help >&2
      exit 2
      ;;
  esac
done

mobile_require_command jq
resolved=$(mobile_resolve_manifest "$device")
IFS=$'\t' read -r device_id manifest_path <<<"$resolved"

printf '%s\n\n' "Omarchy Mobile installer plan"
mobile_print_warning
printf '\nSelected device: %s\nManifest: %s\n' "$device_id" "$manifest_path"

if [[ -n $bundle ]]; then
  [[ -e $bundle ]] || mobile_die "bundle does not exist: $bundle"
  printf 'Bundle: %s\n' "$bundle"
  if [[ -d $bundle && -f $bundle/SHA256SUMS ]]; then
    (cd "$bundle" && sha256sum --check SHA256SUMS)
    printf 'Bundle checksums: verified\n'
  elif [[ -f $bundle ]]; then
    printf 'Bundle checksum file: not adjacent; archive contents were not inspected\n'
  fi
fi

images_available=$(jq -r '.boot.imagesAvailable // false' "$manifest_path")
installer_available=$(jq -r '.boot.installerAvailable // false' "$manifest_path")
real_hardware_validated=$(jq -r '.realHardwareValidated // false' "$manifest_path")

printf 'Boot images available: %s\n' "$images_available"
printf 'Installer backend available: %s\n' "$installer_available"
printf 'Real hardware validated: %s\n' "$real_hardware_validated"

if [[ $dry_run == "true" ]]; then
  if [[ $images_available != "true" || $installer_available != "true" || $real_hardware_validated != "true" ]]; then
    printf '\nDry run result: blocked safely because the manifest is not installable. No device was touched.\n'
  else
    printf '\nDry run result: the manifest passes the availability gates; a live backend must still perform its own checks.\n'
  fi
  exit 0
fi

if [[ $acknowledged != "true" ]]; then
  mobile_die "refusing a live operation without --acknowledge-risk"
fi

if [[ $images_available != "true" || $installer_available != "true" || $real_hardware_validated != "true" ]]; then
  mobile_die "refusing to flash: this device has no validated image and installer backend"
fi

mobile_die "no live flashing backend is shipped in this release"
