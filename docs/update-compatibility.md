# Upstream update compatibility

Upstream Omarchy can change. Compatibility is a measured property of a specific Omarchy commit, package set, and mobile adaptation revision, not a promise about future versions.

## Recorded pin

compatibility.json records the Omarchy source commit reviewed, package repository commit, package recipe source pin, mobile version, and the test categories that were actually run. Today the record says STATIC_SOURCE_REVIEW_ONLY. It is not a tested runtime pairing.

## Monitoring workflow

The scheduled GitHub Actions workflow checks out current upstream quattro and omarchy-pkgs master with full history, resolves the latest official Omarchy release, and runs the source-contract suite against both the branch and release. It compares watched plugin API, host, theme, menu, overlay, and package-recipe paths with the reviewed pins and writes a compatibility summary. Changes to watched files open one deduplicated GitHub issue for review. It does not build packages yet.

This is a change detector. It does not decide that a change is breaking, update the pin, build an ARM64 package, run Quickshell, test migrations, create a release, or apply an update to a phone. A person must inspect the diff and run the missing gates.

## Release gate

Before a candidate is marked compatible, record:

- Omarchy tag and exact source commit.
- omarchy-pkgs commit and exact package source revisions.
- Mobile adaptation commit.
- ARM64 build results and package checksums.
- Plugin manifest, IPC, theme, component, and CLI contract test results.
- Quickshell runtime result and visual interaction evidence.
- Migration and update-health-check results.
- Known regressions and device validation status.

If any gate has not run, preserve the release pin and describe the candidate as unverified. Security updates must still be reviewed promptly; pinning does not mean ignoring security changes.

## Update and recovery boundary

Ordinary updates should continue to use Omarchy's own command, pacman/ALPM, hooks, and migrations. A mobile adapter may add a compatibility preflight and post-update health check after its package lifecycle is defined. User configuration should be backed up before migrations. Rollback is only promised once package cache, state restoration, and the boot path have been tested together.

Kernel, firmware, bootloader, verified-boot, and partition changes are a separate device maintenance operation. No such operation is bundled with the mobile plugin or implemented by this repository.
