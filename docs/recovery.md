# Recovery status

This project has no validated Pixel 10 image, partition map, boot/recovery layout, or recovery script. Do not use a generic Android factory image or an experimental third-party flash helper based only on this research report.

The only safe guidance at this stage is to preserve the original device state and use Google's official Pixel 10 factory-image and recovery documentation for the exact build: https://developers.google.com/android/images. Factory flashing erases data. Bootloader and anti-rollback state can affect which builds can boot.

A project recovery guide must not be written until a separate device campaign records the exact model and build, the official recovery artifact and checksum, an end-to-end restore test, and the outcome of interruption and failed-boot tests. No recovery command has been tested by Omarchy Mobile.
