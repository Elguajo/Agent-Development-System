<div align="center">

# Agent Skills

**A version-controlled, cross-agent library of focused workflows for Codex and Claude Code.**

[Quick start](#quick-start) · [Included skills](#included-skills) · [Use & adopt](#use-and-adopt-skills) · [Add a skill](#add-a-skill) · [Architecture reference](docs/agent-architecture.md) · [Safety](#safety-and-provenance)

</div>

---

## Why this repository exists

Useful agent workflows should be reusable, reviewable, and portable—not buried
inside a chat or copied by hand between computers. This repository is the single
source of truth for a small, intentionally curated collection of personal skills.

Each skill follows the [Agent Skills](https://agentskills.io/) format: a folder
with a `SKILL.md`, plus optional scripts, references, and assets. The common
format lets the same workflow work in both Codex and Claude Code.

For a broader explanation of skills, agents, tools, MCP, subagents, hooks,
permissions, memory, plugins, and automations, see the
[Agent Architecture reference](docs/agent-architecture.md).

## Quick start

Clone the repository on a new computer, then run one command from its root:

```bash
git clone https://github.com/Elguajo/agent-skills.git
cd agent-skills
./bootstrap.sh
```

`bootstrap.sh` validates that skills are present, then links each one into both
local agents:

| Agent | Local skill location |
|---|---|
| Codex Desktop | `~/.codex/skills/<skill-name>` |
| Claude Code | `~/.claude/skills/<skill-name>` |

Existing skills are never overwritten. To deliberately replace an existing local
copy, use:

```bash
./bootstrap.sh --adopt
```

The prior copy is moved to `~/.agent-skills-backups/`; nothing is deleted.
Restart Codex or Claude Code if either was already running when a new skill was
installed.

## Included skills

| Skill | Use it for | Compatibility |
|---|---|---|
| [`credit-codex-contributor`](skills/credit-codex-contributor/SKILL.md) | Add Codex to GitHub's automatic Contributors list through a safe, co-authored attribution commit. | Codex · Claude Code |
| [`frontend-design`](skills/frontend-design/SKILL.md) | Build visually distinctive, intentional web interfaces rather than generic default designs. | Codex · Claude Code |

## How it works

```text
agent-skills/skills/<skill>/SKILL.md
                 │
                 ├── ~/.codex/skills/<skill>   → Codex
                 └── ~/.claude/skills/<skill>  → Claude Code
```

The installer creates absolute symbolic links, so any update committed to this
repository immediately becomes the canonical local version for both agents.

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

### Choose the right installation mode

| Situation | Command | Result |
|---|---|---|
| New computer or no conflicting local skill | `./bootstrap.sh` | Adds missing links and leaves every existing local skill untouched. |
| An existing local skill should be managed by this repository | `./bootstrap.sh --adopt` | Moves the existing folder to a timestamped backup, then replaces it with a link to this repository. |

Use `--adopt` only when the repository version is the one you want both agents
to use. The previous local folders remain recoverable at
`~/.agent-skills-backups/`.

### Start a skill

After installation, restart an agent if it was already open. Skills can be
selected naturally by describing the task, or started explicitly:

| Agent | Natural request | Explicit invocation |
|---|---|---|
| Codex Desktop | “Добавь Codex в контрибьюторы” | Select the skill in the Skills panel, or use `$credit-codex-contributor` in Codex CLI/IDE. |
| Claude Code | “Добавь Codex в контрибьюторы” | `/credit-codex-contributor` |
| Either agent | “Сделай выразительный дизайн интерфейса для …” | `frontend-design` can be selected from the agent’s skill picker. |

Codex and Claude Code normally match the request to the skill description
automatically. Explicit invocation is useful when several skills could fit or
when you want to make the chosen workflow unambiguous. See the official
[Codex skills guide](https://learn.chatgpt.com/docs/build-skills) and
[Claude Code skills guide](https://code.claude.com/docs/en/skills) for
provider-specific UI details.

### Confirm that installation worked

```bash
ls -l ~/.codex/skills/credit-codex-contributor
ls -l ~/.claude/skills/credit-codex-contributor
```

Each result should point to this repository’s `skills/` folder. Then open a new
Codex or Claude Code conversation and use one of the natural requests above.
If the skill does not appear, run `./bootstrap.sh` again and restart the agent.

## Add a skill

Create an instruction-only skill by default. Add scripts only when they remove
repeated, error-prone work.

```text
skills/
└── my-skill/
    └── SKILL.md
```

Use `$skill-creator` to scaffold a new skill. Before committing it, verify that:

1. The `description` names clear user-facing trigger phrases.
2. The body gives direct, bounded instructions and contains no credentials.
3. The workflow works in both agents or explicitly documents why it is agent-specific.
4. Bundled scripts are executable, dependency-light, and tested.
5. Any imported skill retains its original license and provenance.

Then install it locally:

```bash
./bootstrap.sh
```

## Safety and provenance

- `bootstrap.sh` creates links only. It does not install packages, change global
  Git settings, or execute a skill's bundled scripts.
- Git does not run the installer automatically during `clone`; installation is a
  deliberate local action.
- Review third-party instructions and scripts before adding them. Keep provider
  API keys, tokens, and private context out of this repository.
- Imported skills carry their license and a `SOURCE.md` with the exact upstream
  revision. For example, `frontend-design` is preserved from
  [`anthropics/skills`](https://github.com/anthropics/skills) under Apache-2.0.

## Repository layout

```text
agent-skills/
├── bootstrap.sh             # One-command setup on a new computer
├── docs/
│   └── agent-architecture.md # Skills and agent-system architecture reference
├── scripts/
│   └── install.sh           # Safe symlink installer
└── skills/
    ├── credit-codex-contributor/
    │   └── SKILL.md
    └── frontend-design/
        ├── LICENSE.txt
        ├── SKILL.md
        └── SOURCE.md
```

## License

This repository does not impose a single license on third-party skills. Each
imported skill retains its own license and attribution. Add a repository-wide
license before making original skills available for reuse by others.
