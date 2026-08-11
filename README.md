<div align="center">

# Agent Development System

**An AI Development Workflow System for building software with Codex and Claude Code.**

[Русская версия](README.ru.md)

</div>


<div align="left">
  
## Contents

<p>
  <a href="#quick-start">Quick start</a><br>
  <a href="#keep-skills-up-to-date">Update skills</a><br>
  <a href="docs/ai-development-workflow-system.md">Concept</a><br>
  <a href="#workflow-map">Workflow map</a><br>
  <a href="#included-skills">Included skills</a><br>
  <a href="#repository-layout">Repository layout</a><br>
  <a href="docs/agent-architecture.md">Architecture reference</a><br>
  <a href="#safety-and-provenance">Safety & provenance</a>
</p>

</div>

---

## What this project is

Its architectural direction is an **AI Development Workflow System**: we are not primarily building the agents themselves; we are building the system through which AI agents develop software.

That means coordinating:

```text
project intent
    ↓
skill discovery / routing
    ↓
specialist workflows
    ↓
tools and integrations
    ↓
implementation
    ↓
verification and review
    ↓
release evidence
    ↓
SHIP
```

Skills are therefore one layer of the system, not the whole system.

The goal is to make AI-assisted software development more deliberate, reusable, inspectable, conflict-aware, and production-ready without forcing unnecessary process onto simple tasks.

Read the full concept and development roadmap in [`docs/ai-development-workflow-system.md`](docs/ai-development-workflow-system.md).

## Why this repository exists

Useful AI development workflows should be reusable, reviewable, portable, and clearly bounded—not buried inside a chat or copied by hand between computers.

This repository is the single source of truth for the current workflow system: skills, routing metadata, responsibility boundaries, provenance, installation logic, and documentation.

Each skill follows the [Agent Skills](https://agentskills.io/) format: a folder with a `SKILL.md`, plus optional scripts, references, and assets. This repository currently ships installation support for Codex Desktop and Claude Code; another agent can reuse the format only when it supports compatible skill discovery.

The system is deliberately **conflict-aware**. Each specialist owns one primary concern and hands work off instead of competing with neighboring skills. See [`docs/skill-boundaries.md`](docs/skill-boundaries.md).

For a broader explanation of skills, agents, tools, MCP, subagents, hooks, permissions, memory, plugins, and automations, see [`docs/agent-architecture.md`](docs/agent-architecture.md).

## Quick start

Prerequisites: Git and a Bash-compatible shell. Clone the repository on a new computer, then run one command from its root:

```bash
git clone https://github.com/Elguajo/Agent-Development-System.git
cd Agent-Development-System
./bootstrap.sh
```

Keep this clone in a permanent location after installation. The installer creates absolute symbolic links to it, so moving or deleting the repository will break the installed skills.

On Windows, run the commands from Git Bash. Creating symbolic links may also require enabling Developer Mode or using an elevated shell.

`bootstrap.sh` validates that skills are present, then links each one into both local agents:

| Agent | Local skill location |
|---|---|
| Codex Desktop | `~/.codex/skills/<skill-name>` |
| Claude Code | `~/.claude/skills/<skill-name>` |

Existing skills are never overwritten. To deliberately replace an existing local copy, use:

```bash
./bootstrap.sh --adopt
```

The prior copy is moved to `~/.agent-skills-backups/`; nothing is deleted. The installer also removes only broken symlinks that were previously managed by this repository, so repository-managed skill renames do not touch unrelated local skills.

Restart Codex or Claude Code if either was already running when new skills were installed.

### Start using skills

After restarting the agent, describe the task normally or name a skill explicitly when you want a particular workflow. For example:

```text
Use product-spec to turn this feature idea into acceptance criteria.
Use feature-development to implement this feature through the relevant specialists.
```

Use [`SKILLS.md`](SKILLS.md) to choose an explicit skill, or let an agent with skill routing select one from the task. Each installed `SKILL.md` contains the authoritative execution instructions.

### Verify or reverse an installation

The installer creates links for **both** Codex Desktop and Claude Code, even if only one is currently installed. Confirm an individual link and its target with:

```bash
readlink "$HOME/.codex/skills/product-spec"
readlink "$HOME/.claude/skills/product-spec"
```

To stop managing one skill, remove only its symlink with `unlink "$HOME/.codex/skills/<skill-name>"` or `unlink "$HOME/.claude/skills/<skill-name>"`. If it was replaced with `--adopt`, restore the original folder from the timestamped path under `~/.agent-skills-backups/` after first removing that skill's symlink. The installer never deletes the adopted folder.

### Keep skills up to date

Refresh local links after changing the repository locally:

```bash
./bootstrap.sh
```

Pull and install the latest library version:

```bash
git pull --ff-only
./bootstrap.sh
```

After a repository-managed skill is renamed, the same command removes its stale broken managed link and creates the new one.

## Workflow map

This is the current software-development workflow model. **It is not a requirement to run every skill for every task.** `feature-development` acts as an orchestrator and should select only the specialists justified by the change.

```text
                                  PRODUCT
                                     │
                                     ▼
                             ┌──────────────┐
                             │ product-spec │
                             └──────┬───────┘
                                    │
                                    ▼
                           codebase-explorer
                                    │
                                    ▼
                         solution-architecture
                                    │
                                    ▼
                         feature-development
                           (orchestration)
                                    │
                    ┌───────────────┴───────────────┐
                    │                               │
                    ▼                               ▼
                FRONTEND                         BACKEND
                    │                               │
         ┌──────────┼──────────┐                    │
         │          │          │                    │
         ▼          ▼          ▼                    │
  frontend-design   │      figma-to-code            │
                    │                               │
             design-system                          │
                    │                               │
            responsive-design                       │
                    │                               │
              motion-design                         │
                    │                               │
                    └───────────────┬───────────────┘
                                    │
                                    ▼
                             IMPLEMENTATION
                                    │
                         debugging / refactor
                                    │
                                    ▼
                                  TEST
                         ┌──────────┴──────────┐
                         │                     │
                         ▼                     ▼
                      testing        playwright-testing
                                               │
                                               ▼
                                           visual-qa
                                    │
                    ┌───────────────┼────────────────┐
                    │               │                │
                    ▼               ▼                ▼
          accessibility-review  performance-review  code-review
                                                     │
                                                     ▼
                                               security-review
                                                     │
                                                     ▼
                                                release-check
                                                     │
                                                     ▼
                                                    SHIP
```

A more accurate way to read the map is:

- **Definition:** what should exist?
- **Understanding:** how does the current system work?
- **Architecture:** how should the change fit?
- **Implementation specialists:** which discipline-specific workflows apply?
- **Verification:** does it work and look right?
- **Review:** is it maintainable, secure, accessible, and performant where relevant?
- **Release gate:** is there enough evidence to ship?

The long-term direction adds intelligent routing, tool-aware execution, evidence-aware completion, and reusable project bootstrapping. See the [AI Development Workflow System roadmap](docs/ai-development-workflow-system.md#development-direction).

## Included skills

The skill library covers product definition, codebase exploration, architecture, feature orchestration, frontend implementation, debugging, testing, QA, reviews, release checks, and one GitHub attribution utility.

Use [`SKILLS.md`](SKILLS.md) to choose a skill: it is the complete human-readable catalog, including ownership, trigger conditions, provenance, and handoffs. Use [`skills/registry.yaml`](skills/registry.yaml) for the machine-readable routing metadata. Each `skills/<skill>/SKILL.md` is authoritative for execution instructions.

All listed skills are intended for Codex and Claude Code unless a skill explicitly documents an agent-specific dependency.

## How the skills avoid conflicts

The key rule is **one primary owner per concern**.

- `codebase-explorer` explains **how the repository works now**; `solution-architecture` decides **how it should change**.
- `product-spec` owns product intent and acceptance criteria; `solution-architecture` owns technical structure.
- `frontend-design` owns art direction; `design-system` owns consistency with the existing system.
- A supplied Figma/reference overrides aesthetic reinterpretation; `figma-to-code` follows the source of truth.
- `responsive-design` defines responsive behavior; `visual-qa` checks the rendered result.
- `testing` owns unit/integration regression coverage; `playwright-testing` owns browser E2E behavior.
- `debugging` changes behavior to correct a defect; `refactor` preserves behavior.
- `code-review` owns general change quality; `security-review` owns threat-focused analysis.
- `release-check` verifies evidence; it does not redo architecture, design, or implementation.

Full precedence and collision rules: [`docs/skill-boundaries.md`](docs/skill-boundaries.md).

## How it works

```text
Agent-Development-System/skills/<skill>/SKILL.md
                 │
                 ├── ~/.codex/skills/<skill>   → Codex
                 └── ~/.claude/skills/<skill>  → Claude Code
```

The installer creates absolute symbolic links, so an update committed to this repository becomes the canonical local version for both agents after the repository is updated locally.

Do not move or delete the clone while you want to use its installed skills. If you need to relocate it, remove the existing skill symlinks first, then run `./bootstrap.sh` from the new location.

## Use and adopt skills

| Situation | Command | Result |
|---|---|---|
| New computer or no conflicting local skill | `./bootstrap.sh` | Adds missing links and leaves every existing unrelated local skill untouched. |
| An existing local skill should be managed by this repository | `./bootstrap.sh --adopt` | Moves the existing folder to a timestamped backup, then replaces it with a link to this repository. |

Use `--adopt` only when the repository version is the one you want both agents to use. Previous local folders remain recoverable at `~/.agent-skills-backups/`.

Skills can be selected naturally from the request or invoked explicitly when several skills could fit. Project instructions and explicit user requirements always outrank generic skill guidance.

The installer prints an exact summary of newly linked, already linked, skipped, backed-up, and stale links removed skills. A skipped skill is left untouched; use `--adopt` only when you intend to replace it.

## Add a skill

Create an instruction-only skill by default. Add scripts only when they remove repeated, error-prone work.

```text
skills/
└── my-skill/
    └── SKILL.md
```

Before committing a new skill, verify that:

1. The `description` names clear user-facing trigger conditions.
2. Its responsibility does not duplicate an existing skill.
3. `Use when` / `Do not use when` / handoff rules are explicit when overlap is possible.
4. The workflow works in both agents or explicitly documents why it is agent-specific.
5. Bundled scripts are dependency-light, reviewable, and tested.
6. Imported skills retain their original license and provenance.
7. The new skill is added to both [`SKILLS.md`](SKILLS.md) and [`skills/registry.yaml`](skills/registry.yaml).

Then install it locally:

```bash
./bootstrap.sh
```

## Safety and provenance

- `bootstrap.sh` creates links and removes only stale broken symlinks previously managed by this repository. It does not install packages, change global Git settings, or execute a skill's bundled scripts.
- Git does not run the installer automatically during `clone`; installation is a deliberate local action.
- Review third-party instructions and scripts before adding them. Keep provider API keys, tokens, and private context out of this repository.
- Imported skills carry their license and a `SOURCE.md` with the exact upstream revision. `frontend-design` retains its upstream provenance and license files.

## Repository layout

Treat this section as the **navigation map for both humans and agents**. The file tree shows where information lives; the table below explains which source to use for which question.

```text
Agent-Development-System/
├── README.md                         # Entry point: identity, setup, workflow, repository map
├── SKILLS.md                         # Human catalog + field notes for every skill
├── bootstrap.sh                      # One-command installer entry point
│
├── docs/
│   ├── ai-development-workflow-system.md # Concept, principles and development roadmap
│   ├── agent-architecture.md         # How skills, agents, tools, MCP, hooks, etc. relate
│   └── skill-boundaries.md           # Precedence, collisions and handoff rules
│
├── scripts/
│   └── install.sh                    # Safe Codex/Claude symlink installation logic
│
└── skills/
    ├── registry.yaml                 # Machine-readable catalog for AI/tools/routing
    │
    └── <skill>/
        └── SKILL.md                # Authoritative execution instructions
```

### Knowledge map

| Question | Canonical source | What it contains |
|---|---|---|
| **What is the project and where is it going?** | [`docs/ai-development-workflow-system.md`](docs/ai-development-workflow-system.md) | The AI Development Workflow System concept, principles, system layers, and roadmap. |
| **How do I install and use it?** | [`README.md`](README.md) | Setup, installation lifecycle, current workflow map, operating model, and navigation. |
| **Which skill should I use and what can I reuse from it?** | [`SKILLS.md`](SKILLS.md) | Human-readable catalog, field notes, origin, useful parts, tooling, pairings, and boundaries. |
| **How should an AI discover or route to skills?** | [`skills/registry.yaml`](skills/registry.yaml) | Structured metadata: ownership, triggers, outputs, non-goals, tooling, relations, and handoffs. |
| **How exactly should a skill perform its job?** | `skills/<skill>/SKILL.md` | Authoritative execution instructions for that skill. |
| **Where did a vendored skill come from?** | `skills/<skill>/SOURCE.md` | Upstream repository, path, revision, retrieval date, and local modifications when applicable. |
| **What wins if two skills or sources disagree?** | [`docs/skill-boundaries.md`](docs/skill-boundaries.md) | Precedence, collision rules, and responsibility handoffs. |
| **How do skills relate to agents, tools, MCP, hooks, and plugins?** | [`docs/agent-architecture.md`](docs/agent-architecture.md) | Conceptual architecture of the wider agent ecosystem. |

The intended reading path is:

```text
README.md / Repository layout
            │
            ├── Understand the system ───────────→ ai-development-workflow-system.md
            │
            ├── Human choosing a skill ──────────→ SKILLS.md
            │                                      │
            │                                      ▼
            │                                 SKILL.md
            │
            ├── AI choosing a skill ─────────────→ registry.yaml
            │                                      │
            │                                      ▼
            │                                 SKILL.md
            │
            └── Conflict / provenance ────────────→ skill-boundaries.md / SOURCE.md
```

`SKILL.md` is authoritative for **execution**. `SKILLS.md` and `registry.yaml` are authoritative for **discovery, provenance, relationships, and navigation**. The concept document is authoritative for the **direction of the system**. Project instructions and the explicit user request still outrank generic skill guidance.

## License

Original material in this repository is licensed under the [MIT License](LICENSE). Imported skills retain their own licenses and attribution; in particular, [`frontend-design`](skills/frontend-design/) is licensed under Apache-2.0. Where terms differ, the imported skill's license governs that skill.
