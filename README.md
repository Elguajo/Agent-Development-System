# Agent Skills

Личный, version-controlled каталог skills для Codex и Claude Code.

## Структура

Каждый skill живёт в `skills/<name>/SKILL.md`. Общие skills используют только
portable Agent Skills frontmatter (`name` и `description`).

```text
skills/
└── credit-codex-contributor/
    └── SKILL.md
```

## Новый компьютер

После клонирования репозитория выполни одну команду из его корня:

```bash
./bootstrap.sh
```

Она проверит структуру skills и подключит их к Codex и Claude Code. Git намеренно
не запускает такие скрипты автоматически при `clone`: это защита от выполнения
непроверенного кода. Если на компьютере уже есть локальные skills с такими же
именами, используй `./bootstrap.sh --adopt`.

## Установка вручную

```bash
./scripts/install.sh
```

Скрипт создаёт симлинки для каждого skill в `~/.codex/skills` и
`~/.claude/skills`, не перезаписывая существующие skills. Если нужно заменить
существующую локальную копию симлинком, запусти:

```bash
./scripts/install.sh --adopt
```

Старая копия будет перемещена в `~/.agent-skills-backups/`, а не удалена.

## Добавление skills

1. Создай `skills/<name>/SKILL.md` через `$skill-creator`.
2. Оставь основной workflow portable: без provider-specific YAML-полей,
   plugin manifests и credentials.
3. Проверь skill и выполни `./scripts/install.sh`.
4. Зафиксируй изменение в этом репозитории.

Для заимствованных skills сохрани исходную лицензию и ссылку на автора в
самой папке skill или в commit message.

## Источники

- `anthropics/skills` — основной каталог примеров Agent Skills.
- `openai/plugins` — актуальные примеры Codex plugins и skills.
- `agentskills/agentskills` — спецификация portable Agent Skills.

Не используй deprecated `openai/skills` как базовый upstream.
