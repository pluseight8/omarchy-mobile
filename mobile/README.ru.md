# Архитектура Omarchy Mobile

[English version](README.md)

Omarchy Mobile — fork, основанный на upstream, а не вторая desktop-среда. Оригинальное дерево Omarchy остаётся реализацией shell, CLI, тем, приложений, конфигурации, обновлений, плагинов и agentic workflow. Дерево `mobile/` добавляет device contracts, определение устройства, защищённую установку, recovery-документацию и release tooling поверх этой основы.

## Правила разработки

1. Расширяйте upstream Omarchy в минимально необходимой точке. Если поведение уже принадлежит upstream, используйте или расширяйте его, а не копируйте в отдельную мобильную реализацию.
2. Держите вопросы мобильного оборудования за явными device manifests и небольшими adapters. Device-specific код не должен проникать в темы, основной CLI router или core shell, если только upstream не требуется действительно переносимая возможность.
3. Используйте AOSP, GrapheneOS, LineageOS, postmarketOS и mainline Linux только как источники знаний об оборудовании и загрузке. Omarchy Mobile не является Android ROM и не использует Android в качестве desktop UX.
4. Никогда не объявляйте устройство или функцию поддержанными на основании статического кода, успешного CI или эмулятора. Физическая проверка требует воспроизводимого отчёта и подтверждения recovery.
5. Границы bootloader, kernel, firmware, userspace, compositor, input, power, camera, modem и recovery должны оставаться явными. Смартфону сначала нужен реальный Linux boot path, и только затем на нём может работать сам Omarchy.

## Слои

| Слой | Владелец | Текущая роль |
| --- | --- | --- |
| Omarchy base | Upstream `omacom/omarchy` | Реальная desktop-среда, приложения, темы, CLI, shell, пакеты и agentic workflow. |
| Mobile contracts | `mobile/devices/` | Точные manifests устройств, статусы возможностей и требования к валидации. |
| Mobile runtime boundary | `mobile/lib/` и `bin/omarchy-mobile` | Определение устройства и read-only status без замены поведения upstream. |
| Installation and recovery | `mobile/install/` | Checksums, risk gates, recovery-инструкции и преднамеренный отказ при отсутствии артефактов. |
| Release and sync | `mobile/release/`, `mobile/sync-upstream.sh`, `.github/workflows/` | Воспроизводимые bundles, отслеживание upstream и автоматизация CI/release. |

## Модель статусов устройств

Каждый manifest содержит `status`, `supportLevel`, `realHardwareValidated`, boot artifact gates и статусы capabilities. `untested` — настоящее состояние, а не эвфемизм для «поддерживается». Reference manifest Pixel 10 намеренно остаётся `untested` и не имеет загрузочного образа.

Проверка:

    OMARCHY_PATH="$PWD" ./bin/omarchy mobile status google-pixel-10
    OMARCHY_PATH="$PWD" ./bin/omarchy mobile status --json google-pixel-10

## Синхронизация с upstream

Fork записывает upstream-репозиторий, ветку и последний синхронизированный commit в `mobile/upstream.env`.

    mobile/sync-upstream.sh --check
    mobile/sync-upstream.sh --apply

Команда `--apply` работает только в чистом worktree и выполняет обычный merge. Если изменения upstream и mobile конфликтуют, разрешайте конкретные файлы вручную. Конфликт лучше, чем незаметная потеря изменений любой из сторон.

## Установка и recovery

Текущий installer намеренно является безопасным planner. Он проверяет optional bundle и печатает точные blockers, но не прошивает устройство: не опубликованы device-specific image, recovery path, installer backend и подтверждение тестирования на реальном устройстве. См. [install/INSTALL.md](install/INSTALL.md) и [install/recovery.md](install/recovery.md), а также [русские версии](install/INSTALL.ru.md) и [recovery](install/recovery.ru.md).

## Releases

`mobile/release/build.sh` создаёт полный source archive, installer/recovery bundle, release manifest, release notes и `SHA256SUMS`. Tag release workflow запускается только после того, как exact tagged commit прошёл main CI. Release asset не является заявлением о поддержке железа.

## Отчёты о валидации

При тестировании устройства зафиксируйте точную модель и регион, процедуру boot и recovery, commits kernel/userspace, checksums образов, логи, поведение питания и температуры, результаты проверки сохранности данных и каждую работающую или неработающую capability. Только после этого `realHardwareValidated` может стать `true`, причём изменение должно быть проверено вместе с отчётом.
