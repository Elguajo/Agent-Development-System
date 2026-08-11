# Agent Skills & Agent Architecture

Справочник по **skills** в OpenAI Codex и Claude Code и по соседним сущностям, из которых строятся современные agentic-системы.

> Актуализировано: 11 августа 2026.

## Что такое Skill

**Skill — это переиспользуемый пакет инструкций, процедур и ресурсов, который агент подключает, когда задача соответствует этому skill.**

Skill — это не отдельная модель и не обязательно отдельный агент.

Типичная структура:

```text
frontend-review/
├── SKILL.md
├── references/
│   └── design-rules.md
├── scripts/
│   └── check-ui.js
└── assets/
    └── report-template.md
```

Пример `SKILL.md`:

```md
---
name: frontend-review
description: Review frontend UI for responsive behavior, accessibility, spacing, typography, and design-system consistency. Use when asked to review or audit a frontend interface.
---

# Frontend review workflow

1. Inspect the existing design system.
2. Check responsive behavior.
3. Check accessibility.
4. Review spacing and typography.
5. Run relevant automated checks.
6. Produce a prioritized report.
```

Открытый формат **Agent Skills** предусматривает обязательный `SKILL.md` и опциональные `scripts/`, `references/`, `assets/` и другие ресурсы.

## Progressive disclosure

Одна из главных идей skills — **progressive disclosure**.

Агенту не нужно сразу загружать в контекст содержимое всех skills:

```text
1. Discovery
   ↓
   name + description

2. Activation
   ↓
   полный SKILL.md

3. Execution
   ↓
   scripts / references / assets по необходимости
```

Это позволяет держать много специализированных workflows, не перегружая контекст модели.

---

# Основные сущности agent architecture

Важно: не все сущности ниже являются частью стандарта Agent Skills и не все реализованы одинаково в Codex и Claude Code. Это архитектурная карта понятий.

| Сущность | За что отвечает | Пример |
|---|---|---|
| **Model** | Базовый интеллект | GPT, Claude |
| **Agent** | Модель, работающая в цикле с контекстом и инструментами | Codex, Claude Code |
| **Instructions** | Постоянные правила проекта | `AGENTS.md`, `CLAUDE.md` |
| **Skill** | Переиспользуемый workflow / procedural knowledge | `frontend-review` |
| **Tool** | Конкретное действие, которое может выполнить агент | terminal, file read/write, browser |
| **MCP** | Стандарт подключения внешних tools/resources | GitHub, Figma, DB, Notion |
| **Subagent** | Отдельный специализированный агент/контекст | reviewer, researcher |
| **Hook** | Автоматическая реакция на lifecycle/event | после изменения файла запустить lint |
| **Permissions / Rules** | Ограничения на действия агента | allow / ask / deny |
| **Memory** | Сохраняемый рабочий контекст | решения и особенности проекта |
| **Plugin / Extension package** | Упаковка нескольких возможностей | skills + hooks + integrations |
| **Automation** | Запуск agent workflow по времени/условию | ежедневная проверка CI |

## 1. Model

Model — это сам языковой/рассуждающий интеллект.

```text
GPT / Claude
```

Сам по себе model ещё не является полноценной agent-системой. Чтобы выполнять задачи в реальной среде, вокруг модели добавляются instructions, tools, context, permissions и agent loop.

## 2. Agent

Упрощённо:

```text
Agent = Model + Instructions + Context + Tools + Agent Loop
```

Агент может:

- изучать состояние проекта;
- принимать промежуточные решения;
- читать и изменять файлы;
- запускать инструменты;
- проверять результат;
- продолжать выполнение задачи в несколько шагов.

## 3. Instructions: `AGENTS.md` / `CLAUDE.md`

Это долговременные инструкции проекта.

Пример:

```md
# Project rules

- Use TypeScript.
- Use pnpm instead of npm.
- Never modify database migrations manually.
- Run tests before completing a task.
- Components must use the existing design system.
```

Упрощённое различие:

```text
Project instructions
→ правила, которые нужно учитывать постоянно

Skill
→ специализированная процедура, подключаемая для подходящей задачи
```

Например:

```text
AGENTS.md:
Always use TypeScript.

Skill:
When creating a landing page, perform this specific design QA workflow.
```

## 4. Skill

Skill отвечает прежде всего на вопрос:

> **Как выполнять определённый тип работы?**

Например `create-landing-page` может задавать процесс:

```text
1. Analyze requirements
2. Inspect design system
3. Plan component architecture
4. Implement responsive layout
5. Check accessibility
6. Test desktop/mobile
7. Capture evidence
8. Review against requirements
```

Skill может содержать не только prompt/instructions, но и дополнительные ресурсы:

```text
SKILL.md
scripts/
references/
assets/
```

Короткая формула:

```text
Skill = reusable procedural knowledge
```

## 5. Tool

Tool — это возможность **фактически совершить действие**.

Например:

```text
read_file
write_file
terminal
browser
git
search
```

Skill может сказать:

```text
Проверь GitHub Issues и сгруппируй проблемы.
```

Но для реального доступа к GitHub агенту нужен соответствующий tool/integration.

Различие:

```text
Skill
→ объясняет ЧТО и КАК делать

Tool
→ позволяет это ВЫПОЛНИТЬ
```

## 6. MCP

**Model Context Protocol (MCP)** — стандарт подключения моделей и агентов к внешним инструментам и ресурсам.

Архитектурно это может выглядеть так:

```text
Agent
│
├── GitHub MCP
├── Figma MCP
├── Notion MCP
├── Database MCP
└── Browser / internal tools
```

После подключения агент может получить конкретные capabilities, например чтение репозитория, запросы к БД или работу с Figma.

Ключевое различие:

```text
Skill = knowledge + workflow
MCP   = external capabilities + resources
```

Например:

```text
Figma Audit Skill
        ↓
    Figma MCP
        ↓
  реальный Figma-файл
```

## 7. Subagent

Subagent — отдельный специализированный агент или изолированный рабочий контекст, которому основной агент делегирует часть задачи.

Пример:

```text
Main Agent
│
├── UX Research Agent
├── Frontend Agent
├── Backend Agent
├── Security Reviewer
└── QA Agent
```

Главное различие:

```text
Skill ≠ Subagent
```

Skill:

```text
документирует, как проводить security review
```

Subagent:

```text
сам выполняет роль Security Reviewer
```

Subagent при этом может иметь собственные:

```text
instructions
skills
tools
permissions
context
```

## 8. Hooks

Hook отвечает на вопрос:

> **Что автоматически должно произойти при определённом событии?**

Например:

```text
File edited
↓
run formatter

File edited
↓
run ESLint

Before dangerous command
↓
permission/security check

Task completed
↓
run tests
```

Различие:

```text
Skill
→ workflow, выбранный для задачи

Hook
→ реакция на конкретное событие/lifecycle point
```

## 9. Permissions / Rules

Permissions или rules определяют, какие действия агент может выполнять автоматически, какие требуют подтверждения, а какие запрещены.

Пример концептуально:

```text
git status
→ allow

npm test
→ allow

production deploy
→ ask

destructive command
→ deny
```

То есть:

```text
Skill
→ как выполнять работу

Permissions
→ что агенту разрешено выполнять
```

## 10. Memory

Memory — информация, сохраняемая между этапами или сессиями работы, если конкретный agent/client это поддерживает.

Например:

```text
Project uses pnpm.
Project uses Supabase.
Auth architecture decision: ...
Previous implementation failed because ...
```

Различие с project instructions:

```text
Instructions
→ намеренно прописанные правила

Memory
→ накопленный контекст и знания о работе
```

## 11. Plugin / Extension package

Plugin можно рассматривать как способ **упаковать несколько agentic-возможностей в один устанавливаемый пакет**.

Концептуально:

```text
my-development-plugin/
│
├── skills/
│   ├── frontend-review/
│   └── security-review/
│
├── agents/
│   └── reviewer
│
├── hooks/
└── integrations / MCP config
```

Упрощённо:

```text
Skill  = workflow
Plugin = package / distribution layer
```

Конкретный состав plugin зависит от клиента и его реализации.

## 12. Automation

Automation отвечает прежде всего на вопрос:

> **Когда запускать agent workflow?**

Например:

```text
Every weekday 09:00
↓
Agent
↓
Skill: project-health-check
↓
GitHub tools
↓
Check CI + open issues
↓
Generate report
```

Удобная формула:

```text
Skill      = HOW
Automation = WHEN
```

---

# Общая архитектурная модель

```text
                         MODEL
                           │
                         AGENT
                           │
            ┌──────────────┴──────────────┐
            │                             │
       Instructions                    Memory
   AGENTS.md / CLAUDE.md                  │
            │                             │
            └──────────────┬──────────────┘
                           ↓
                         Skills
                 ┌─────────┼─────────┐
                 │         │         │
             research    code     review
                 │         │         │
                 └─────────┼─────────┘
                           ↓
                         Tools
                  ┌────────┴────────┐
                  │                 │
              Local tools          MCP
                  │                 │
            Files / Shell      GitHub / Figma
            Git / Browser      DB / Notion / etc.
                  │                 │
                  └────────┬────────┘
                           ↓
                       Subagents
                 ┌─────────┼─────────┐
                 │         │         │
             Research    Coding    Reviewer
                 │         │         │
                 └─────────┼─────────┘
                           ↓
                         Hooks
                           ↓
                 Permissions / QA
                           ↓
                     Automations
```

Это **концептуальная схема**, а не утверждение, что каждый клиент реализует ровно такую иерархию.

# Аналогия с компанией

Если представить agent-систему как компанию:

- **Model** — интеллект сотрудника.
- **Agent** — сам сотрудник, который умеет действовать.
- **AGENTS.md / CLAUDE.md** — правила и рабочая инструкция компании.
- **Skill** — SOP / методичка по конкретному типу работы.
- **Tool** — инструмент в руках сотрудника.
- **MCP** — стандартизированный доступ к внешним системам компании.
- **Subagent** — другой специализированный сотрудник.
- **Memory** — накопленный рабочий контекст.
- **Permissions / Rules** — что сотруднику разрешено делать.
- **Hook** — автоматическое правило «если произошло X → выполни Y».
- **Plugin** — устанавливаемый набор возможностей.
- **Automation** — расписание или условие запуска работы.

# Практическая связка

Для реального AI development workflow особенно полезно мыслить связкой:

```text
Project Instructions
        ↓
      Skills
        ↓
   Tools / MCP
        ↓
    Subagents
        ↓
      Hooks
        ↓
 Permissions / QA
        ↓
   Automations
```

Например для разработки веб-приложения:

```text
AGENTS.md
│
├── Skill: research-feature
├── Skill: implement-feature
├── Skill: frontend-review
├── Skill: run-tests
└── Skill: final-review
        │
        ↓
GitHub / Browser / Figma / Terminal tools
        │
        ↓
Optional specialized subagents
        │
        ↓
Hooks + tests + permissions
```

# Что относится именно к Agent Skills standard

Открытый Agent Skills standard определяет прежде всего формат skills:

```text
skill-name/
├── SKILL.md          # required
├── scripts/          # optional
├── references/       # optional
├── assets/           # optional
└── ...
```

В `SKILL.md` обязательны как минимум:

```yaml
---
name: skill-name
description: What the skill does and when to use it.
---
```

Другие сущности — MCP, subagents, hooks, permissions, plugins, automations и memory — являются соседними частями agent ecosystem и могут отличаться между продуктами.

# Источники

## Agent Skills

- Agent Skills overview: https://agentskills.io/home
- Agent Skills specification: https://agentskills.io/specification
- Agent Skills quickstart: https://agentskills.io/skill-creation/quickstart

## OpenAI Codex

- Codex documentation: https://developers.openai.com/codex/
- Codex use cases: https://developers.openai.com/codex/use-cases

## Claude Code

- Claude Code documentation: https://docs.anthropic.com/en/docs/claude-code/
- Claude Code getting started: https://docs.anthropic.com/en/docs/claude-code/getting-started
- Claude Code MCP: https://docs.anthropic.com/en/docs/claude-code/mcp

# Коротко

```text
Model        = интеллект
Agent        = исполнитель
Instructions = постоянные правила
Skill        = как выполнять повторяемую работу
Tool         = действие
MCP          = подключение внешних capabilities/resources
Subagent     = специализированный исполнитель
Hook         = реакция на событие
Permissions  = ограничения
Memory       = накопленный контекст
Plugin       = пакет возможностей
Automation   = когда запускать workflow
```
