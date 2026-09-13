# Omarchy Mobile architecture

Omarchy Mobile is an upstream-based fork, not a second desktop environment. The original Omarchy source remains the implementation of the shell, CLI, themes, applications, configuration, updates, plugins, and agentic workflows. The mobile/ tree supplies device contracts, detection, guarded installation, recovery documentation, and release tooling around that base.

## Design rules

1. Extend upstream Omarchy at the smallest possible seam. If upstream already owns a behavior, use or extend it instead of copying it into a mobile implementation.
2. Keep mobile hardware concerns behind explicit device manifests and small adapters. Device-specific support must not leak into themes, the main CLI router, or the core shell unless upstream needs a genuinely portable capability.
3. Treat Android projects such as AOSP, GrapheneOS, LineageOS, postmarketOS, and mainline Linux as sources of hardware and boot knowledge only. Omarchy Mobile is not an Android ROM and does not use Android as its desktop UX.
4. Never promote a device or feature based on static code, a successful CI run, or an emulator. Physical validation needs a reproducible report and recovery evidence.
5. Keep the bootloader, kernel, firmware, userspace, compositor, input, power, camera, modem, and recovery boundaries visible. A phone needs a real Linux boot path before Omarchy itself can run.

## Layers

| Layer | Owner | Current role |
| --- | --- | --- |
| Omarchy base | Upstream omacom/omarchy | The actual desktop, apps, themes, CLI, shell, packages, and agentic workflow. |
| Mobile contracts | mobile/devices/ | Exact device manifests, capability statuses, and validation requirements. |
| Mobile runtime boundary | mobile/lib/ and bin/omarchy-mobile | Detection and read-only status without replacing upstream behavior. |
| Installation and recovery | mobile/install/ | Checksums, risk gates, recovery guidance, and a deliberate refusal when artifacts are missing. |
| Release and sync | mobile/release/, mobile/sync-upstream.sh, .github/workflows/ | Reproducible bundles, upstream tracking, and CI/release automation. |

## Device status model

Every manifest contains status, supportLevel, realHardwareValidated, boot artifact gates, and capability statuses. Untested is a real state, not a euphemism for supported. The Pixel 10 reference manifest is intentionally untested and has no bootable image.

To inspect it:

    OMARCHY_PATH="$PWD" ./bin/omarchy mobile status google-pixel-10
    OMARCHY_PATH="$PWD" ./bin/omarchy mobile status --json google-pixel-10

## Upstream synchronization

The fork records its upstream repository, branch, and last synchronized commit in mobile/upstream.env.

    mobile/sync-upstream.sh --check
    mobile/sync-upstream.sh --apply

The apply command only runs in a clean worktree and performs a normal merge. If upstream and mobile changes conflict, resolve the exact files deliberately. A conflict is preferable to silently dropping changes from either project.

## Installation and recovery

The current installer is intentionally a safe planner. It verifies an optional bundle and prints the exact blockers, but it will not flash a device because no device-specific image, recovery path, installer backend, or real-device validation has been published. See install/INSTALL.md and install/recovery.md.

## Releases

mobile/release/build.sh creates a complete source archive, an installer/recovery bundle, a release manifest, release notes, and SHA256SUMS. The tag release workflow runs only after the exact tagged commit has passed the main CI workflow. A release asset is not a claim of hardware support.

## Validation reports

When somebody tests a device, record the exact model and region, boot and recovery procedure, kernel/userspace commits, image checksums, logs, power and thermal behavior, data-safety results, and every working or non-working capability. Only then may realHardwareValidated change to true, and that change must be reviewed with the report.
