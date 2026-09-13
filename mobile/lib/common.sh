#!/bin/bash

mobile_die() {
  printf 'omarchy-mobile: %s\n' "$*" >&2
  return 1
}

mobile_warn() {
  printf 'omarchy-mobile: warning: %s\n' "$*" >&2
}

mobile_require_command() {
  local command="$1"

  command -v "$command" >/dev/null 2>&1 || mobile_die "required command is not available: $command"
}

mobile_require_root() {
  [[ -n ${MOBILE_ROOT:-} && -d $MOBILE_ROOT ]] || mobile_die "mobile data directory is unavailable: ${MOBILE_ROOT:-unset}"
}

mobile_warning_file() {
  printf '%s/EXPERIMENTAL_WARNING.md' "$MOBILE_ROOT"
}

mobile_print_warning() {
  local warning_file
  warning_file=$(mobile_warning_file)
  [[ -f $warning_file ]] || mobile_die "experimental warning file is missing: $warning_file"
  cat "$warning_file"
}

mobile_index_file() {
  printf '%s/devices/index.json' "$MOBILE_ROOT"
}

mobile_manifest_path() {
  local device_id="$1"
  local relative_path

  mobile_require_command jq || return
  mobile_require_root || return
  relative_path=$(jq -r --arg id "$device_id" '.devices[] | select(.id == $id) | .path' "$(mobile_index_file)")

  if [[ -z $relative_path || $relative_path == "null" ]]; then
    return 1
  fi

  printf '%s/devices/%s' "$MOBILE_ROOT" "$relative_path"
}

mobile_detect_device_id() {
  local model=""
  local normalized=""

  if [[ -n ${OMARCHY_MOBILE_DEVICE:-} ]]; then
    printf '%s' "$OMARCHY_MOBILE_DEVICE"
    return 0
  fi

  if command -v getprop >/dev/null 2>&1; then
    model=$(getprop ro.product.model 2>/dev/null || true)
    [[ -n $model ]] || model=$(getprop ro.product.device 2>/dev/null || true)
  fi

  if [[ -z $model && -r /sys/firmware/devicetree/base/model ]]; then
    model=$(tr -d '\0' </sys/firmware/devicetree/base/model)
  fi

  normalized=${model,,}
  case "$normalized" in
    *pixel*10*) printf 'google-pixel-10' ;;
    *pixel*) printf 'google-pixel-template' ;;
    *) printf 'android-generic' ;;
  esac
}

mobile_resolve_manifest() {
  local requested_id="${1:-}"
  local device_id="$requested_id"
  local path=""

  if [[ -z $device_id ]]; then
    device_id=$(mobile_detect_device_id)
  fi

  path=$(mobile_manifest_path "$device_id" || true)
  if [[ -z $path ]]; then
    device_id="android-generic"
    path=$(mobile_manifest_path "$device_id" || true)
  fi

  [[ -n $path && -f $path ]] || mobile_die "no manifest found for device: $device_id"
  printf '%s\t%s' "$device_id" "$path"
}

mobile_print_status() {
  local device_id="${1:-}"
  local json="${2:-false}"
  local resolved=""
  local manifest_id=""
  local manifest_path=""
  local upstream_commit="unknown"
  local upstream_branch="unknown"
  local support="unknown"

  mobile_require_command jq || return
  mobile_require_root || return
  resolved=$(mobile_resolve_manifest "$device_id") || return
  IFS=$'\t' read -r manifest_id manifest_path <<<"$resolved"

  if [[ -f $MOBILE_ROOT/upstream.env ]]; then
    # shellcheck disable=SC1091
    source "$MOBILE_ROOT/upstream.env"
    upstream_commit="${OMARCHY_UPSTREAM_COMMIT:-unknown}"
    upstream_branch="${OMARCHY_UPSTREAM_BRANCH:-unknown}"
  fi

  support=$(jq -r '.supportLevel // "unknown"' "$manifest_path")
  if [[ $json == "true" ]]; then
    jq -n \
      --arg device "$manifest_id" \
      --arg manifest "$manifest_path" \
      --arg support "$support" \
      --arg status "$(jq -r '.status // "unknown"' "$manifest_path")" \
      --arg upstreamBranch "$upstream_branch" \
      --arg upstreamCommit "$upstream_commit" \
      --argjson realHardwareValidated "$(jq -c '.realHardwareValidated // false' "$manifest_path")" \
      --argjson imagesAvailable "$(jq -c '.boot.imagesAvailable // false' "$manifest_path")" \
      --argjson installerAvailable "$(jq -c '.boot.installerAvailable // false' "$manifest_path")" \
      '{device: $device, manifest: $manifest, supportLevel: $support, status: $status, realHardwareValidated: $realHardwareValidated, boot: {imagesAvailable: $imagesAvailable, installerAvailable: $installerAvailable}, upstream: {branch: $upstreamBranch, commit: $upstreamCommit}}'
    return 0
  fi

  printf 'Omarchy Mobile status\n'
  printf '  Device: %s\n' "$manifest_id"
  printf '  Manifest: %s\n' "$manifest_path"
  printf '  Status: %s\n' "$(jq -r '.status // "unknown"' "$manifest_path")"
  printf '  Support level: %s\n' "$support"
  printf '  Real hardware validated: %s\n' "$(jq -r '.realHardwareValidated // false' "$manifest_path")"
  printf '  Boot images available: %s\n' "$(jq -r '.boot.imagesAvailable // false' "$manifest_path")"
  printf '  Installer available: %s\n' "$(jq -r '.boot.installerAvailable // false' "$manifest_path")"
  printf '  Upstream: %s @ %s\n' "$upstream_branch" "$upstream_commit"
}
