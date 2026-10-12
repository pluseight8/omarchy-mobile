# Building and development environment

Status date: 2026-10-12.

## Available now

The current prototype has no compiled package. Its deterministic local checks use Node's built-in test runner and no third-party npm dependencies:

    npm test

For a live source comparison, provide a full-history checkout of omacom/omarchy:

    OMARCHY_UPSTREAM=/path/to/omarchy node tools/check-upstream.mjs

The GitHub workflow ran successfully on the public ARM64 GitHub-hosted runner label ubuntu-24.04-arm (run 4, 2026-10-12): QML syntax lint, all 7 Node contract tests, and the pinned upstream source comparison passed. The lint uses Ubuntu Qt 6.4.2 and `qml6-module-qtquick`; `.qmllint.ini` treats unresolved external Quickshell/Omarchy imports and dependent type warnings as informational because CI does not build those projects or generated type metadata. Syntax errors remain fatal, but this is not semantic QML validation or a runtime test. The workflow pins checkout and Node setup actions by commit SHA. The runner image, Qt/Node package revisions, and upstream branches continue to move, so this is not a bit-for-bit reproducible system build.

## Not available yet

There is no pinned Arch Linux ARM rootfs, build container, package repository, image builder, initramfs, frankel kernel, or downloadable system image. The generic Arch Linux ARM AArch64 installation is a starting point for later work, not a Pixel 10 installation method. A development rootfs must be pinned by immutable source revision and verified digest before it can be called reproducible.

The next build-system task is to define a pinned AArch64 userspace builder that can run makepkg for the actual upstream package set. It must use upstream PKGBUILDs and preserve their architecture conditions. CI should first build a minimal package subset, record package checksums and source revisions, and avoid bundling any device firmware whose license or provenance is unclear.

## Quickshell runtime test requirements

Before claiming the launcher works, run it inside an Omarchy session built from the recorded upstream commit. Validate manifest discovery, summon and hide lifecycle, app-library capabilities, QML import resolution, icon loading, touch scrolling, long press, search, and launch. Record the compositor, Qt, Quickshell, device scale, orientation, and screenshots. Current CI does none of these checks.

## Image and device safety

No image is produced here. Do not use generic Omarchy ISO output as a phone image. Any future Pixel artifact must be explicitly marked experimental and untested until real hardware validation. Do not lock the bootloader, alter verified-boot metadata, or publish a flash recipe until a reviewed recovery procedure, exact build inputs, and a device test record exist.
