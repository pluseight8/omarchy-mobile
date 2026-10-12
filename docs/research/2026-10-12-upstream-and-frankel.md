# Omarchy upstream and Pixel 10 research

Audit date: 2026-10-12. Scope: the public upstream repositories, the plugin and ARM64 source paths used by the first prototype, and primary-source Pixel 10 / kernel bring-up material. This is a scoped audit, not a claim that every manual page, package, issue, pull request, or hardware subsystem has been reviewed.

## Revisions reviewed

| Source | Revision or release | Finding |
| --- | --- | --- |
| omacom/omarchy | branch quattro, commit 4c1b4cb3a94447aff39af98e2fcc0490a9fb32e7 | Current source snapshot reviewed for shell APIs and architecture |
| omacom/omarchy | release v4.0.4, commit c668141e9c42b13c80c9ca4ea108e11708c5e8a5, published 2026-09-15 | Latest release found during this audit; its plugin contracts are checked separately |
| omacom/omarchy-pkgs | branch master, commit be468d003ea717e87de04d1c9aeba838c8652394 | Package recipes and architecture metadata reviewed |
| omarchy package recipe | source commit c668141e9c42b13c80c9ca4ea108e11708c5e8a5 | Source revision pinned by the reviewed omarchy package recipe |
| Linaro GoogleLT Pixel scripts | branch clo/main; exact commit SHA not resolved through the available source connector | Observation only; no source code or flashing command is used by this project |

## Omarchy findings

The upstream agent and packaging files describe x86_64 and aarch64 support. The platform model includes architecture-wide packages and explicit architecture-specific additions. The current aarch64-only package list includes zram-generator; the current x86_64-only list includes gliff and superwhisper-bin. These lists are a useful compatibility signal, not proof that every install path or optional feature runs on ARM.

The omarchy-pkgs repository has architecture-specific recipes and CI coverage for x86_64 and aarch64. Its Quickshell recipe declares both architectures and pins Quickshell 0.3.2. This establishes that the core shell package has an ARM64 packaging route. This audit did not build the recipe or run the package.

The shell documentation defines third-party plugins as Git repositories with a schemaVersion 1 manifest. Menu entry points are QML Items and receive lifecycle hooks plus capability-scoped host data. Menu plugins receive a scoped application-library facade. The facade in PluginAppLibraryApi.qml exposes entryName, entrySubtext, sortedEntries, iconSource, refreshIcons, launch, and remove. The upstream menu itself consumes that same API for application rows. This is why the mobile prototype is an optional menu plugin and does not copy app discovery, filtering, icon fallback, or process launch code.

The reviewed quattro branch has OverlayWindow, BorderSurface, Commons.Style, Commons.Color, and Border helpers. The v4.0.4 release has BorderSurface and the same theme tokens, but no OverlayWindow.qml; its own menu creates a Quickshell PanelWindow with WlrLayershell. The prototype therefore uses the lower-level PanelWindow/WlrLayershell APIs already used by the released built-in menu, plus upstream BorderSurface and theme tokens. Plugin code still runs unsandboxed with the user's process and file access; the scoped facade is a capability boundary, not a security sandbox.

### Omarchy feature compatibility inventory

This is a source-based assessment for the first mobile prototype. “Not run” is distinct from “incompatible.”

| Capability | Assessment | Mobile work or limitation |
| --- | --- | --- |
| Themes and theme tokens | Reuse source APIs; runtime not tested | The prototype reads upstream menu colors, spacing, fonts, border, and radius tokens |
| CLI and shell scripts | ARM64/package review required | Inspect each executable and dependency; do not assume x86 binaries run on AArch64 |
| Quickshell plugins | Reuse documented menu plugin interface | Prototype exists; Quickshell load and lifecycle are not tested |
| Shell IPC | Upstream owns it | No custom IPC or replacement command was added |
| Applications and desktop entries | Reuse scoped app-library facade | Search, icon lookup, and launch delegate to upstream |
| Services and notifications | Upstream source remains authoritative | Mobile panel layout and device integration are not implemented |
| User configuration | Preserve upstream paths and schema | No settings migration or device profile has been added |
| Updates and migrations | Preserve Omarchy/pacman lifecycle | Compatibility preflight, backup, health check, and rollback are not implemented |
| Agentic and AI features | Requires per-package ARM64 and service review | No feature is claimed to work on phone hardware |
| x86_64-only optional software | Must be gated with upstream architecture metadata | Current examples include gliff and superwhisper-bin; do not fake a successful install |
| Games, virtualization, desktop peripherals | Not assessed in this first slice | Keep upstream desktop behavior conditional rather than removing it |

## First mobile integration decision

At both the reviewed v4.0.4 release and quattro commit, a third-party menu is a documented extension point and receives the shared application catalogue needed for an app launcher. A new optional plugin therefore has less divergence than patching the built-in menu, copying its model, replacing Quickshell, or creating a separate mobile shell. The QML currently has static source-contract tests only. It has not been loaded by Quickshell and is not yet a verified usable interface.

## Pixel 10: confirmed device facts and kernel scope

Google's Pixel 10 specification lists the Tensor G5, 12 GB RAM, 6.3-inch OLED, 1080 by 2424 resolution, and 60–120 Hz refresh rate. These are device specifications, not evidence of Linux driver support.

The Linux kernel mailing-list series for Laguna / Tensor G5 and Frankel, Blazer, and Mustang boards was applied to a maintainer's development tree as separate binding, DTS-directory, Frankel DTS, and configuration commits. The initial Frankel DTS is commit 54edd8698bb1fb40c339d0cb2f15baad6993dd48. This is early source-level bring-up evidence. The series does not establish that it is merged into the current Linus tree or that the phone boots a usable Linux system. At audit time the checked Torvalds Linux mirror's Google DTS directory did not contain a Frankel DTS.

The scoped AOSP kernel-devices Google index reviewed here listed repositories only through Tegu and did not expose a Frankel / Laguna repository in that index. This is an observation about that index, not proof that no Google source exists elsewhere.

Linaro's GoogleLT Pixelscripts names frankel as a target and describes booting a minimal BusyBox initramfs. The project notes limited support and reliance on a USB serial console; normal reboot support was not established. Its flash helper changes boot-related partitions and erases DTBO. That helper is evidence of an experimental lab path, not an installation procedure. No command from it was run and no image was flashed.

No confirmed postmarketOS Frankel device port or mainline-ready phone integration was found in the scoped searches. Absence from these searches is not proof of impossibility.

### Pixel 10 (frankel) compatibility matrix

Status meanings: SUPPORTED requires a successful test on this exact device; PARTIAL means a tested subset; EXPERIMENTAL means early source or lab work without complete device validation; BLOCKED requires a verified blocker; NOT TESTED means evidence is not sufficient to claim a result. No function is marked SUPPORTED.

| Component | Status | Evidence and limitation |
| --- | --- | --- |
| Bootloader, kernel and initramfs | EXPERIMENTAL | Linaro scripts describe a minimal BusyBox boot with USB serial debugging. Not a graphical system; normal reboot support is not established |
| Device Tree, memory and UFS | EXPERIMENTAL | Initial Frankel DTS exists in a kernel maintainer tree; complete memory and storage operation has not been validated |
| Display, DRM/KMS and display pipeline | NOT TESTED | No Linux display test found |
| Touch panel and multitouch | NOT TESTED | No Linux input test found |
| GPU acceleration | NOT TESTED | No Frankel Linux graphics test found |
| Power and volume buttons | NOT TESTED | No input-event test found |
| USB-C and USB devices | NOT TESTED | Serial-console tooling does not establish general USB host/device support |
| Wi-Fi | NOT TESTED | No Linux firmware/driver test found |
| Bluetooth | NOT TESTED | No Linux test found |
| Cellular modem, SIM/eSIM and data | NOT TESTED | No validated modem interface or data session found |
| Voice calls, SMS and emergency calls | NOT TESTED | No end-to-end telephony test found |
| Microphones, speakers and audio routing | NOT TESTED | No Linux audio route test found |
| Cameras | NOT TESTED | No camera capture test found |
| Rotation and other sensors | NOT TESTED | No sensor/input test found |
| Haptics | NOT TESTED | No vibration test found |
| Biometrics | NOT TESTED | No Linux integration test found |
| NFC | NOT TESTED | No Linux test found |
| Charging, battery reporting and thermals | NOT TESTED | No Linux power-supply or thermal test found |
| Suspend/resume and screen-off power | NOT TESTED | No measured suspend/resume test found |
| GPS/GNSS | NOT TESTED | No Linux position fix test found |

No compatible Pixel image, device tree bundle, firmware set, or recovery procedure is produced by this repository.

The Linaro repository was inspected through its branch README, but its immutable commit SHA could not be resolved with the available source connector during this audit. That source is recorded as an unpinned observation only and must be pinned before using it as an engineering dependency.

## Bootloader, recovery, and anti-rollback constraints

Google's factory-image documentation states that flashing a factory image erases user data and warns about bootloader unlock/security state. Its Pixel 10 family notice for the May 2026 update describes an anti-rollback version increase and an inactive-slot bootloader consequence. The exact device build, slot state, and recovery path must be checked before any future device operation. This repository provides no unlock, flash, slot-switch, or relock command.

## Primary source index

### Omarchy

- Upstream source at reviewed commit: https://github.com/omacom/omarchy/tree/4c1b4cb3a94447aff39af98e2fcc0490a9fb32e7
- Agent and platform guidance: https://github.com/omacom/omarchy/blob/4c1b4cb3a94447aff39af98e2fcc0490a9fb32e7/AGENTS.md
- Shell/plugin contract: https://github.com/omacom/omarchy/blob/4c1b4cb3a94447aff39af98e2fcc0490a9fb32e7/docs/omarchy-shell.md
- Built-in menu and shared app library use: https://github.com/omacom/omarchy/blob/4c1b4cb3a94447aff39af98e2fcc0490a9fb32e7/shell/plugins/menu/Menu.qml
- Scoped menu app API: https://github.com/omacom/omarchy/blob/4c1b4cb3a94447aff39af98e2fcc0490a9fb32e7/shell/services/PluginAppLibraryApi.qml
- Overlay surface: https://github.com/omacom/omarchy/blob/4c1b4cb3a94447aff39af98e2fcc0490a9fb32e7/shell/Ui/OverlayWindow.qml
- Package recipes: https://github.com/omacom/omarchy-pkgs/tree/be468d003ea717e87de04d1c9aeba838c8652394
- Quickshell ARM64 recipe: https://github.com/omacom/omarchy-pkgs/blob/be468d003ea717e87de04d1c9aeba838c8652394/pkgbuilds/quickshell/PKGBUILD

### Pixel 10 and Linux

- Google Pixel 10 specifications: https://store.google.com/product/pixel_10_specs
- Google factory images and current device warnings: https://developers.google.com/android/images
- AOSP bootloader overview: https://source.android.com/docs/core/architecture/bootloader
- AOSP Google kernel-device index: https://android.googlesource.com/kernel/devices/google/
- Linux Frankel DTS maintainer commit: https://git.kernel.org/pub/scm/linux/kernel/git/krzk/linux.git/commit/?id=54edd8698bb1fb40c339d0cb2f15baad6993dd48
- Linux bindings commit: https://git.kernel.org/pub/scm/linux/kernel/git/krzk/linux.git/commit/?id=ecf6405fa6c503c34eb4e7e905957d70d4018e93
- Linux Google DTS directory commit: https://git.kernel.org/pub/scm/linux/kernel/git/krzk/linux.git/commit/?id=cf3df78629f24b40cd0cb2da74e3ea4a944bed82
- Linaro GoogleLT experimental Pixel scripts: https://gitlab.com/LinaroLtd/googlelt/pixelscripts/-/blob/clo/main/README.md?ref_type=heads
- Generic Arch Linux ARM AArch64 installation notes: https://archlinuxarm.org/platforms/armv8/generic
- postmarketOS device wiki index: https://wiki.postmarketos.org/wiki/Devices

## Open engineering questions

1. Does the upstream plugin loader accept a third-party menu with this exact QML import set and injected facade at runtime?
2. Can the mobile menu be shown reliably on an ARM64 Omarchy session with the current Quickshell and Hyprland packages?
3. Which Arch Linux ARM rootfs snapshot and digest can be pinned for a reproducible builder?
4. Which frankel kernel commits have reached Linus's tree, and which components require proprietary firmware?
5. What boot, recovery, and A/B behavior does the exact Pixel 10 bootloader expose after the May 2026 anti-rollback change?
6. Which modem, audio, display, touchscreen, camera, sensor, and power interfaces can be used without relying on Android services?

## Next acceptance work

First load the plugin in an upstream Omarchy development session and capture portrait/landscape interaction. Then produce a pinned ARM64 builder and package smoke tests. Device bring-up remains a separately gated effort with a serial boot log, exact kernel and DT revisions, and a verified restore plan before any invasive operation.
