# Omarchy Mobile installation bundle

[Русская версия инструкции](INSTALL.ru.md)

This bundle is a verification and recovery-safe planning artifact. It is not a bootable phone image. The installer refuses to change a device unless a future device manifest provides an exact image, a recovery path, a flashing backend, and a real-device validation record.

## Verify the downloaded bundle

Run the checksum command from the directory containing the release checksum file:

    sha256sum --check SHA256SUMS

Extract the bundle and run a no-write plan:

    tar -xzf omarchy-mobile-<version>-install-bundle.tar.gz
    cd omarchy-mobile-<version>-install-bundle
    ./mobile/install/install.sh --device google-pixel-10 --dry-run

The expected current result is a safe block because there is no published Pixel 10 boot image or installer backend.

## Recovery requirement

Do not unlock or flash a device unless you have already downloaded the exact factory firmware, confirmed the recovery procedure for the exact model and region, and backed up data that can be lost. Read recovery.md before any future experiment.

## Mandatory warning

⚠️ Omarchy Mobile находится на ранней экспериментальной стадии. Текущие сборки ещё не были протестированы разработчиком на реальных устройствах. Установка выполняется полностью на ваш страх и риск. Я не несу ответственности за потерю данных, невозможность загрузки, повреждение программного обеспечения или любые другие проблемы с вашим устройством. Перед установкой обязательно сделайте резервную копию данных и убедитесь, что знаете процедуру восстановления заводской прошивки.

Если вы протестировали Omarchy Mobile на реальном устройстве, я буду очень признателен за отзывы, отчёты об ошибках, информацию о работающих и неработающих функциях и характеристики вашего устройства.
