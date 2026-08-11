<div align="center">

# Agent Development System

**An AI Development Workflow System for building software with Codex, Claude Code, and other coding agents.**

[Quick start](#quick-start) · [Concept](docs/ai-development-workflow-system.md) · [Workflow map](#workflow-map) · [Included skills](#included-skills) · [Repository layout](#repository-layout) · [Architecture reference](docs/agent-architecture.md) · [Safety](#safety-and-provenance)

</div>

---

## What this project is

**Agent Development System** is the project name.

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

Each skill follows the [Agent Skills](https://agentskills.io/) format: a folder with a `SKILL.md`, plus optional scripts, references, and assets. The common format lets core workflows work in both Codex and Claude Code.

The system is deliberately **conflict-aware**. Each specialist owns one primary concern and hands work off instead of competing with neighboring skills. See [`docs/skill-boundaries.md`](docs/skill-boundaries.md).

For a broader explanation of skills, agents, tools, MCP, subagents, hooks, permissions, memory, plugins, and automations, see [`docs/agent-architecture.md`](docs/agent-architecture.md).

## Quick start

Clone the repository on a new computer, then run one command from its root:

```bash
git clone https://github.com/Elguajo/agent-skills.git
cd agent-skills
./bootstrap.sh
```

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

### Product, exploration, and architecture

| Skill | Use it for |
|---|---|
| [`product-spec`](skills/product-spec/SKILL.md) | Turn an idea into scope, states, constraints, and acceptance criteria without prematurely designing the implementation. |
| [`codebase-explorer`](skills/codebase-explorer/SKILL.md) | Map relevant entry points, data flow, dependencies, conventions, and similar existing implementations. |
| [`solution-architecture`](skills/solution-architecture/SKILL.md) | Choose how a non-trivial change should fit the current system and compare technical trade-offs. |
| [`feature-development`](skills/feature-development/SKILL.md) | Orchestrate a multi-step feature across the appropriate specialist skills. |

### Frontend and design implementation

| Skill | Use it for |
|---|---|
| [`frontend-design`](skills/frontend-design/SKILL.md) | Build visually distinctive, intentional interfaces rather than generic default designs. |
| [`design-system`](skills/design-system/SKILL.md) | Reuse existing tokens, components, variants, and patterns instead of creating parallel UI systems. |
| [`figma-to-code`](skills/figma-to-code/SKILL.md) | Translate supplied Figma/reference intent into production code without reinterpreting approved design. |
| [`responsive-design`](skills/responsive-design/SKILL.md) | Define deliberate layout, content, typography, navigation, and interaction behavior across viewport sizes. |
| [`motion-design`](skills/motion-design/SKILL.md) | Add purposeful transitions, micro-interactions, and scroll behavior with reduced-motion and performance constraints. |

### Implementation quality

| Skill | Use it for |
|---|---|
| [`debugging`](skills/debugging/SKILL.md) | Reproduce, isolate, diagnose, and fix root causes using evidence rather than random edits. |
| [`refactor`](skills/refactor/SKILL.md) | Improve internal code structure while preserving externally observable behavior. |

### Testing and QA

| Skill | Use it for |
|---|---|
| [`testing`](skills/testing/SKILL.md) | Add focused unit/integration/regression coverage for meaningful behavior. |
| [`playwright-testing`](skills/playwright-testing/SKILL.md) | Verify browser-level functional and end-to-end flows. |
| [`visual-qa`](skills/visual-qa/SKILL.md) | Compare rendered UI against approved visual intent and identify visible regressions. |
| [`accessibility-review`](skills/accessibility-review/SKILL.md) | Audit and remediate accessibility-specific issues. |
| [`performance-review`](skills/performance-review/SKILL.md) | Diagnose measurable performance problems and recommend evidence-based improvements. |

### Review and release

| Skill | Use it for |
|---|---|
| [`code-review`](skills/code-review/SKILL.md) | Review a change for correctness, regressions, maintainability, error handling, and meaningful quality issues. |
| [`security-review`](skills/security-review/SKILL.md) | Review trust boundaries, auth, authorization, secrets, validation, common exploit classes, and security-sensitive behavior. |
| [`release-check`](skills/release-check/SKILL.md) | Perform the final evidence-based ship/no-ship gate after implementation and focused reviews are complete. |

### Utility

| Skill | Use it for |
|---|---|
| [`credit-codex-contributor`](skills/credit-codex-contributor/SKILL.md) | Add Codex to GitHub's automatic Contributors list through a safe, co-authored attribution commit. |

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
agent-skills/skills/<skill>/SKILL.md
                 │
                 ├── ~/.codex/skills/<skill>   → Codex
                 └── ~/.claude/skills/<skill>  → Claude Code
```

The installer creates absolute symbolic links, so an update committed to this repository becomes the canonical local version for both agents after the repository is updated locally.

## Everyday workflow

Install or refresh local links:

```bash
./bootstrap.sh
```

Update the library:

```bash
git pull --ff-only
./bootstrap.sh
```

After a repository-managed skill is renamed, the same command removes its stale broken managed link and creates the new one.

## Use and adopt skills

| Situation | Command | Result |
|---|---|---|
| New computer or no conflicting local skill | `./bootstrap.sh` | Adds missing links and leaves every existing unrelated local skill untouched. |
| An existing local skill should be managed by this repository | `./bootstrap.sh --adopt` | Moves the existing folder to a timestamped backup, then replaces it with a link to this repository. |

Use `--adopt` only when the repository version is the one you want both agents to use. Previous local folders remain recoverable at `~/.agent-skills-backups/`.

Skills can be selected naturally from the request or invoked explicitly when several skills could fit. Project instructions and explicit user requirements always outrank generic skill guidance.

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
agent-skills/
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
    ├── product-spec/
    ├── codebase-explorer/
    ├── solution-architecture/
    ├── feature-development/
    ├── frontend-design/
    ├── design-system/
    ├── figma-to-code/
    ├── responsive-design/
    ├── motion-design/
    ├── debugging/
    ├── refactor/
    ├── testing/
    ├── playwright-testing/
    ├── visual-qa/
    ├── accessibility-review/
    ├── performance-review/
    ├── code-review/
    ├── security-review/
    ├── release-check/
    └── credit-codex-contributor/
```

### Knowledge map

| Question | Canonical source | What it contains |
|---|---|---|
| **What is the project and where is it going?** | [`docs/ai-development-workflow-system.md`](docs/ai-development-workflow-system.md) | The AI Development Workflow System concept, principles, system layers, and roadmap. |
| **How do I install and use it?** | [`README.md`](README.md) | Setup, current workflow map, operating model, and navigation. |
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

This repository does not impose a single license on third-party skills. Each imported skill retains its own license and attribution. Add a repository-wide license before making original skills available for reuse by others.
