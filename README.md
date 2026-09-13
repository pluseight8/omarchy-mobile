# Omarchy Mobile

Omarchy Mobile is an unofficial mobile fork of [Omarchy](https://github.com/omacom/omarchy). It keeps the original Omarchy tree, shell, themes, applications, CLI, plugins, configuration, updates, and agentic workflows as its foundation, then adds a mobile/device layer for Linux-capable smartphones.

The goal is not to make an Android-style launcher or an unrelated mobile distribution. The goal is for the same Omarchy desktop to run on a phone and gain touch, rotation, on-screen keyboard, mobile hardware, and adaptive-display support where the underlying Linux kernel and device support make that possible.

Upstream repository: [omacom/omarchy](https://github.com/omacom/omarchy)

Omarchy Mobile repository: [pluseight8/omarchy-mobile](https://github.com/pluseight8/omarchy-mobile)

## Current status

This repository is currently an experimental upstream-based development fork. The reference device is Google Pixel 10, but no device in this repository has been validated by the developer on real hardware. Device manifests are contracts and test matrices, not claims that a device boots or that a feature works.

The current release layer does not ship a bootable phone image or a working flashing backend. The generated installer bundle verifies what is available and deliberately refuses to flash a device while the corresponding image, recovery path, and validation evidence are absent.

⚠️ Omarchy Mobile находится на ранней экспериментальной стадии. Текущие сборки ещё не были протестированы разработчиком на реальных устройствах. Установка выполняется полностью на ваш страх и риск. Я не несу ответственности за потерю данных, невозможность загрузки, повреждение программного обеспечения или любые другие проблемы с вашим устройством. Перед установкой обязательно сделайте резервную копию данных и убедитесь, что знаете процедуру восстановления заводской прошивки.

Если вы протестировали Omarchy Mobile на реальном устройстве, я буду очень признателен за отзывы, отчёты об ошибках, информацию о работающих и неработающих функциях и характеристики вашего устройства.

## Relationship with upstream

The root of this repository is the upstream Omarchy source tree. Mobile-specific work lives in [mobile/](mobile/) and is intentionally designed as an overlay that can later be proposed upstream. The tracked upstream source, branch, and last synchronized commit are recorded in [mobile/upstream.env](mobile/upstream.env).

Use [mobile/sync-upstream.sh](mobile/sync-upstream.sh) to check or apply a merge from the current upstream quattro branch. Review every conflict in upstream-owned files; do not hide upstream changes with a blanket merge strategy.

## Repository layout

- shell/, bin/, install/, default/, config/, themes/, agents/, and manual/ are the original Omarchy implementation and documentation.
- mobile/devices/ contains explicit device manifests and capability statuses.
- mobile/lib/ contains the small shared mobile detection and manifest layer.
- mobile/install/ contains the guarded installer entrypoint and recovery guidance.
- mobile/release/ builds source and installer bundles with SHA-256 checksums.
- mobile/tests/ validates contracts without pretending to validate physical hardware.

The original Omarchy manual remains authoritative for the desktop environment and is available in [manual/](manual/). The mobile architecture and testing rules are documented in [mobile/README.md](mobile/README.md).

## Development

Run the mobile contract suite from an Omarchy checkout:

    OMARCHY_PATH="$PWD" bash mobile/tests/test.sh

The normal Omarchy suites remain available through test/all. A green software test suite does not mean that a phone is supported; physical validation must be recorded in the relevant device manifest first.

## License

Omarchy Mobile retains the upstream [MIT License](LICENSE).
