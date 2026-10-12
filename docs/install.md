# Installation status

There is no Omarchy Mobile installer or Pixel 10 image. Do not install the generic Omarchy desktop ISO on a Pixel. This repository has not produced a bootable image and provides no bootloader, partition, fastboot, or flashing commands.

Pixel 10 is a research target only. The available Frankel work is an experimental minimal boot path that relies on a serial console; it is not a phone installation. No data-preserving installation path has been demonstrated.

Before an installer can be published, the project needs an exact device/build identification flow, verified image inputs and checksums, a tested backup and restore procedure, signed artifacts, explicit data-loss warnings, and hardware tests for both install and recovery. Any destructive operation must require a separate explicit confirmation from the device owner.

For stock Pixel recovery, follow Google's current official documentation for the exact Pixel 10 build: https://developers.google.com/android/images. Google warns that factory flashing erases data. The May 2026 Pixel 10 family anti-rollback change is an additional reason to verify the exact slot and build state before any future experiment.
