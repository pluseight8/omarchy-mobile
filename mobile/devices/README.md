# Device manifests

Every device is described by a JSON manifest. A manifest records what has been implemented, what is only planned, and what has actually been tested. It is deliberately separate from the Omarchy shell so that adding a device does not create a second desktop implementation.

The supported status vocabulary is intentionally conservative:

- planned means there is an intended integration point, but no implementation or evidence should be assumed.
- untested means code or a device contract may exist, but the developer has not validated it on real hardware.
- experimental means a real-device experiment may be possible, but the result is not a support promise.
- validated is reserved for a reproducible report covering the required hardware, boot, recovery, power, and data-safety checks.

realHardwareValidated must stay false until the validation report exists. A green CI run only checks repository contracts; it cannot upgrade a device manifest.

The Pixel 10 manifest is the reference starting point. It intentionally has no boot image and no installer backend. Copy the generic template for another exact model rather than marking a family as supported.
