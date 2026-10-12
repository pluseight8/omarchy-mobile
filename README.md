# Omarchy Mobile

Omarchy Mobile is an early mobile adaptation of the real Omarchy Quickshell, built through Omarchy's third-party plugin interface. It is not an Android ROM, a Pixel image, or a daily-use phone system.

The repository starts with a touch-oriented application launcher plugin. It reuses Omarchy's menu plugin contract, theme tokens, overlay surface, and scoped application library. It does not replace Omarchy's shell or duplicate its application catalogue.

## Status

- Stage: research and shell prototype.
- Upstream code reviewed: omacom/omarchy branch quattro, commit 4c1b4cb3a94447aff39af98e2fcc0490a9fb32e7.
- Latest upstream release found in this audit: v4.0.4.
- Static QML syntax lint and source-contract CI: passed on an ARM64 Ubuntu 24.04 runner with Qt 6.4.2; all 7 Node tests passed.
- Quickshell runtime and visual tests, ARM package build, and physical Pixel 10 tests: not run.
- Pixel 10 hardware: experimental boot work exists in an external development tree; this repository contains no bootable image or flashing procedure.
- Not for installation or daily use.

See the [research report](docs/research/2026-10-12-upstream-and-frankel.md), [architecture](docs/architecture.md), [touch UX specification](docs/touch-ux.md), [update compatibility policy](docs/update-compatibility.md), [security model](docs/security.md), [installation status](docs/install.md), [recovery status](docs/recovery.md), [supported devices](docs/supported-devices.md), [roadmap](docs/roadmap.md), [development notes](docs/building.md), [contribution guide](CONTRIBUTING.md), and [third-party notices](THIRD_PARTY_NOTICES.md). Russian translations are linked from [README.ru.md](README.ru.md).

## What is implemented here

The root manifest declares a third-party Omarchy menu plugin. Its Quickshell entry point opens an Omarchy-themed, responsive app grid using the shell-provided app library. The app cards support tap-to-launch, long-press details, and touch scrolling. Node contract tests check the manifest, plugin lifecycle, upstream API assumptions, and touch-oriented sizing.

The plugin has to be installed in an Omarchy session that already runs the upstream Quickshell shell. It is summoned with the upstream plugin IPC after installation and enabling. The repository does not yet package or install itself as an Omarchy plugin.

The launcher is a real upstream plugin integration in source, but it has not yet been run under Quickshell. GitHub Actions run 4 passed QML syntax lint, all 7 Node contract tests, and the pinned source comparison. This is source-only lint: Quickshell/Omarchy type metadata is not built in CI, so it does not prove QML runtime behavior or semantic compatibility. It does not validate QML runtime behavior, screenshots, virtual keyboard integration, gestures outside this menu, or hardware.

## Development checks

Requirements: Node.js 22 or newer. From the repository root:

    npm test

To compare this reviewed snapshot with a local checkout of upstream Omarchy:

    OMARCHY_UPSTREAM=/path/to/omarchy npm run check:upstream

The comparison identifies changed plugin contracts that need review. A changed contract does not by itself prove a break; the runtime compatibility record must be updated only after the corresponding tests are actually run.

## Project boundaries

Omarchy remains the source of truth for its shell, CLI, plugins, themes, settings, migrations, and update process. Mobile-specific UI is kept in this repository and uses documented plugin interfaces. Pixel 10 board support belongs under a separate device layer and must not leak into the generic launcher.

No bootloader, partition, or firmware operation is provided by this repository. Google's current factory-image notice describes a Pixel 10 family bootloader anti-rollback change in the May 2026 update; consult the official recovery documentation before any future device work.

## Sources and license

See the dated source audit for repository revisions, primary-source links, compatibility findings, and limitations. The plugin code is licensed under the MIT License. Omarchy, Quickshell, Qt, and Google materials retain their respective licenses and ownership.
