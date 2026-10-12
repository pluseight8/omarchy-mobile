# Architecture and current implementation

Audit date: 2026-10-12. This document describes the first prototype in this repository, not a completed mobile operating system.

## System boundary

Omarchy remains the owner of its user session: shell host, Quickshell, Hyprland configuration, CLI, themes, plugin registry, IPC, updates, migrations, and settings. This project contributes one optional third-party menu plugin. It consumes the app-library facade that Omarchy already injects into menu plugins and the public Omarchy UI components for themed overlay surfaces.

The launcher does not fork the upstream app catalogue, install applications, manage windows, own the home-screen gesture, or provide a new update path. It closes after an app launch and lets the host's existing library perform the launch.

## Layers

| Layer | Responsibility | State in this repository |
| --- | --- | --- |
| A. Omarchy upstream | Runtime, Quickshell host, plugins, themes, CLI, services, IPC, package and update lifecycle | Reused through the third-party menu plugin interface; no upstream files copied |
| B. Mobile UI | Touch-sized app grid, search, tap-to-launch, long-press details, responsive column count | Prototype source in mobile/launcher/Launcher.qml; not runtime-tested |
| C. Platform integration | ARM64 packaging, mobile input, power, orientation, notifications and session integration | Research only; no platform service or package yet |
| D. frankel device support | Kernel, DT, boot path, firmware, recovery and validation | External experimental sources only; no device code or image here |

## Plugin contract

The manifest uses schema version 1, kind menu, and a QML Item entry point. Omarchy's plugin host injects shell, manifest, and lifecycle methods. A menu plugin receives a scoped application-library facade through shell.appLibrary. The launcher calls the upstream methods sortedEntries, entryName, entrySubtext, iconSource, refreshIcons, and launch.

The UI uses Quickshell's PanelWindow/WlrLayershell surface together with qs.Ui.BorderSurface, qs.Commons.Style, qs.Commons.Border, and qs.Commons.Color. This keeps the plugin compatible with the current v4.0.4 release, where the built-in menu uses PanelWindow and the newer qs.Ui.OverlayWindow wrapper is not present. It also keeps theme values in upstream ownership. The launcher itself is unsandboxed QML running inside the user's shell process, as documented for all third-party Omarchy plugins.

The plugin interface is documented upstream at the reviewed commit: https://github.com/omacom/omarchy/blob/4c1b4cb3a94447aff39af98e2fcc0490a9fb32e7/docs/omarchy-shell.md. Exact source locations and revisions are listed in the research report.

## Touch behavior in this prototype

- App entries are laid out in a grid whose column count follows the available logical width.
- GridView provides Flickable-based scrolling.
- Tap launches the selected app through upstream's app library.
- Long press opens a details area with a launch action.
- Search filters through the same app library.
- Close and Escape dismiss the menu.
- Interactive controls use a minimum target derived from Style.space(48).

Not implemented: device-wide home or recents gestures, workspace swipe, edge back gesture, touch gesture arbitration, safe-area insets, sensor-driven orientation, on-screen keyboard invocation, mobile notifications, lock screen, status panel, and multi-window workspace adaptation. A text input's input-method hints do not prove compositor or keyboard support.

## ARM64 and update relationship

The reviewed Omarchy source and omarchy-pkgs contain ARM64 support, including an aarch64 Quickshell package recipe. That establishes a packaging path to investigate, not a successful Omarchy Mobile ARM build. This repository currently has no package, root filesystem, kernel, initramfs, or reproducible release image.

compatibility.json pins the reviewed source commit and records explicitly which checks were not performed. The scheduled workflow checks watched upstream plugin-contract files and opens one review issue when they change. Static contract tests are not a compatibility certification. A mobile release must retain an explicit upstream commit pin and pass runtime, package, and migration checks before the record is promoted.

Omarchy's existing update command, pacman/ALPM, user settings, post-update hooks, and migrations remain upstream responsibilities. The mobile layer must add preflight and health checks through a small adapter only after a supported package lifecycle is identified. It must not perform kernel, firmware, bootloader, or partition updates as part of an ordinary Omarchy package update.

## Acceptance gates

| Gate | Minimum evidence |
| --- | --- |
| Research | Dated primary-source audit; unknown hardware remains unknown |
| ARM64 foundation | Reproducible pinned rootfs and package build, checked on an ARM64 runner |
| Quickshell prototype | Plugin loads in the pinned Omarchy shell; QML errors captured; portrait and landscape UI interaction recorded |
| Touch adaptation | Input, scroll, long press, keyboard, focus, and gesture conflict tests on a compatible compositor |
| frankel bring-up | Documented serial boot, kernel/DT revision, recovery plan, and per-device-component tests on a Pixel 10 |
| Daily-use milestone | Real hardware tests of telephony, emergency calling, charging, suspend/resume, security, updates, and recovery |

No gate after research is complete.
