# Contributing

Omarchy is the upstream source of truth. Before implementing a feature, inspect the current upstream implementation and its documented plugin or configuration interface. Prefer a small mobile plugin over copying or patching upstream files.

For each change:

1. Record the upstream commit and relevant source paths.
2. Keep generic mobile behavior separate from device-specific support.
3. Add or update a meaningful contract test.
4. Run npm test and the live upstream comparison when an upstream checkout is available.
5. State clearly whether a check was static, built, emulated, or run on real hardware.
6. Update both English and Russian user-facing documentation.

Do not add unverified firmware, destructive flashing commands, fabricated screenshots, or success-shaped stubs. Never mark a device function supported without corresponding physical-device evidence.
