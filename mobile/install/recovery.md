# Recovery before testing Omarchy Mobile

The only safe assumption at this stage is that a phone can become unbootable or lose all user data. Keep the exact factory image, vendor flashing tools, bootloader information, region/build identifiers, and a second device available before testing. The recovery steps are device-specific; this document is a checklist, not a Pixel 10 recovery procedure.

1. Record the exact model, region, storage size, current build, bootloader state, and serial number.
2. Back up photos, messages, authentication keys, SSH keys, recovery codes, and anything else that cannot be recreated.
3. Confirm that the vendor factory image and its documented recovery process are available before unlocking anything.
4. Assume bootloader unlocking erases data. Do not continue if the backup has not been verified.
5. Use only an image and command sequence that matches the exact device variant. Never substitute a similarly named Pixel or an Android ROM image.
6. If the device does not boot, stop experimenting and restore the known-good factory image before collecting logs or trying another build.
7. Record the result in the device manifest and include the kernel, userspace, image checksum, logs, and every working/non-working capability in the report.

⚠️ Omarchy Mobile находится на ранней экспериментальной стадии. Текущие сборки ещё не были протестированы разработчиком на реальных устройствах. Установка выполняется полностью на ваш страх и риск. Я не несу ответственности за потерю данных, невозможность загрузки, повреждение программного обеспечения или любые другие проблемы с вашим устройством. Перед установкой обязательно сделайте резервную копию данных и убедитесь, что знаете процедуру восстановления заводской прошивки.

Если вы протестировали Omarchy Mobile на реальном устройстве, я буду очень признателен за отзывы, отчёты об ошибках, информацию о работающих и неработающих функциях и характеристики вашего устройства.
