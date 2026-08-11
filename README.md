<div align="center">

# Agent Skills

**A version-controlled, cross-agent library of focused workflows for Codex and Claude Code.**

[Quick start](#quick-start) · [Workflow map](#workflow-map) · [Included skills](#included-skills) · [Skill boundaries](docs/skill-boundaries.md) · [Architecture reference](docs/agent-architecture.md) · [Safety](#safety-and-provenance)

</div>

---

## Why this repository exists

Useful agent workflows should be reusable, reviewable, portable, and clearly bounded—not buried inside a chat or copied by hand between computers. This repository is the single source of truth for an intentionally curated personal skill system.

Each skill follows the [Agent Skills](https://agentskills.io/) format: a folder with a `SKILL.md`, plus optional scripts, references, and assets. The common format lets the same workflow work in both Codex and Claude Code.

The library is deliberately **conflict-aware**. Each specialist owns one primary responsibility and hands off to another skill instead of competing with it. See [Skill Boundaries and Handoffs](docs/skill-boundaries.md).

For a broader explanation of skills, agents, tools, MCP, subagents, hooks, permissions, memory, plugins, and automations, see the [Agent Architecture reference](docs/agent-architecture.md).

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

The prior copy is moved to `~/.agent-skills-backups/`; nothing is deleted. Restart Codex or Claude Code if either was already running when a new skill was installed.

## Workflow map

This is the conceptual system. **It is not a requirement to run every skill for every task.** `feature-development` acts as an orchestrator and should select only the specialists justified by the change.

```text
                                  PRODUCT
                                     │
                                     ▼
                         ┌──────────────────────┐
                         │ product-requirements │
                         └──────────┬───────────┘
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
  frontend-design   │   figma-implementation        │
                    │                               │
         design-system-enforcer                     │
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
- **Implementation specialists:** what discipline-specific rules apply?
- **Verification:** does it work and look right?
- **Review:** is it maintainable, secure, accessible, and performant?
- **Release gate:** is there enough evidence to ship?

## Included skills

### Product, exploration, and architecture

| Skill | Use it for |
|---|---|
| [`product-requirements`](skills/product-requirements/SKILL.md) | Turn an idea into scope, states, constraints, and acceptance criteria without prematurely designing the implementation. |
| [`codebase-explorer`](skills/codebase-explorer/SKILL.md) | Map relevant entry points, data flow, dependencies, conventions, and similar existing implementations. |
| [`solution-architecture`](skills/solution-architecture/SKILL.md) | Choose how a non-trivial change should fit the current system and compare technical trade-offs. |
| [`feature-development`](skills/feature-development/SKILL.md) | Orchestrate a multi-step feature across the appropriate specialist skills. |

### Frontend and design implementation

| Skill | Use it for |
|---|---|
| [`frontend-design`](skills/frontend-design/SKILL.md) | Build visually distinctive, intentional interfaces rather than generic default designs. |
| [`design-system-enforcer`](skills/design-system-enforcer/SKILL.md) | Reuse existing tokens, components, variants, and patterns instead of creating parallel UI systems. |
| [`figma-implementation`](skills/figma-implementation/SKILL.md) | Translate supplied Figma/reference intent into production code without reinterpreting approved design. |
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

The key rule is **one primary owner per concern**. Examples:

- `codebase-explorer` explains **how the repository works now**; `solution-architecture` decides **how it should change**.
- `frontend-design` owns art direction; `design-system-enforcer` owns consistency with the existing system.
- A supplied Figma/reference overrides aesthetic reinterpretation; `figma-implementation` follows the source of truth.
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

The installer creates absolute symbolic links, so any update committed to this repository immediately becomes the canonical local version for both agents.

## Everyday workflow

### Install or refresh local links

```bash
./bootstrap.sh
```

### Update the library

```bash
git pull --ff-only
./bootstrap.sh
```

## Use and adopt skills

| Situation | Command | Result |
|---|---|---|
| New computer or no conflicting local skill | `./bootstrap.sh` | Adds missing links and leaves every existing local skill untouched. |
| An existing local skill should be managed by this repository | `./bootstrap.sh --adopt` | Moves the existing folder to a timestamped backup, then replaces it with a link to this repository. |

Use `--adopt` only when the repository version is the one you want both agents to use. The previous local folders remain recoverable at `~/.agent-skills-backups/`.

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

Then install it locally:

```bash
./bootstrap.sh
```

## Safety and provenance

- `bootstrap.sh` creates links only. It does not install packages, change global Git settings, or execute a skill's bundled scripts.
- Git does not run the installer automatically during `clone`; installation is a deliberate local action.
- Review third-party instructions and scripts before adding them. Keep provider API keys, tokens, and private context out of this repository.
- Imported skills carry their license and a `SOURCE.md` with the exact upstream revision. `frontend-design` retains its upstream provenance and license files.

## Repository layout

```text
agent-skills/
├── bootstrap.sh
├── docs/
│   ├── agent-architecture.md
│   └── skill-boundaries.md
├── scripts/
│   └── install.sh
└── skills/
    ├── product-requirements/
    ├── codebase-explorer/
    ├── solution-architecture/
    ├── feature-development/
    ├── frontend-design/
    ├── design-system-enforcer/
    ├── figma-implementation/
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

## License

This repository does not impose a single license on third-party skills. Each imported skill retains its own license and attribution. Add a repository-wide license before making original skills available for reuse by others.
