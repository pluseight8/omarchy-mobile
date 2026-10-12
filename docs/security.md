# Security model

## Current code

This repository contains an Omarchy third-party QML menu plugin and static Node checks. The plugin is loaded into the Omarchy shell process. Upstream explicitly describes third-party plugins as unsandboxed code with the same user-level process and file access. The app-library facade narrows the APIs handed to a menu; it does not isolate plugin code.

The current launcher does not execute shell commands, modify settings, install packages, access firmware, or write device partitions. It delegates app lookup and launch to Omarchy's existing facade.

## Supply chain

- Review upstream and Quickshell API changes before updating compatibility.json.
- Pin GitHub Actions by immutable commit SHA.
- Keep firmware and binary blobs out of the repository until source, checksum, redistribution rights, and device binding are reviewed.
- Do not treat an Android factory image or an arbitrary online image as an Omarchy Mobile component.
- Do not publish an image as installable until exact inputs and device tests are recorded.

## Device operations

No bootloader unlock, flashing, slot selection, AVB, relocking, or partition writing is implemented here. Google's Pixel 10 factory-image page reports data-erasing flash behavior and a May 2026 anti-rollback change for the Pixel 10 family. Any future device operation requires a reviewed, exact-build recovery plan and an explicit separate confirmation from the device owner.

## Reporting

Report suspected security issues privately to the repository maintainers rather than publishing exploit details in an issue. No security contact is configured yet; until one is added, use GitHub's private vulnerability reporting for this repository if available.
