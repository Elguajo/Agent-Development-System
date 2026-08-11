# Agents DevKits

devkit/ is the workstation layer of Agents DevKits. It is intentionally
separate from the portable skill library at the repository root:

- root skills/ serves Codex and Claude Code through symbolic links;
- devkit/ prepares a macOS development machine and manages a local Codex
  configuration;
- machine-specific files never enter Git.

## Commands

Run every command from the repository root:

~~~bash
./devkit.sh doctor
./devkit.sh test
./devkit.sh bootstrap --profile base --profile web --profile ai
~~~

bootstrap is for a new macOS workstation. It installs the selected Homebrew
profiles, applies the related local settings, safely installs Codex/Serena
configuration, requests GitHub CLI authentication, and runs diagnostics.

## Existing machines

Do not replace a current Codex configuration with the portable baseline. Adopt
it first:

~~~bash
./devkit.sh backup
./devkit.sh install
~~~

backup sanitizes the active ~/.codex/config.toml, validates it for known secret
patterns, and writes it to the ignored path
devkit/machines/<hostname>/codex/config.toml. install uses that host-local
override when it exists. A direct install refuses to overwrite an existing
Codex config without this adoption step; install --adopt performs both.

## Opt-in MCP profiles

No MCP server is enabled by the portable baseline. List and enable only the
ones this machine needs:

~~~bash
./devkit.sh mcp list
./devkit.sh mcp enable playwright context7
./devkit.sh mcp doctor
~~~

The available portable profiles are context7, memory, playwright, and
sequential-thinking. They are pinned in config/mcp/; their configuration is
appended only to the ignored host override. Put the Context7 key in
secrets.local.env or the shell, never in Git:

~~~bash
cp devkit/secrets.example.env devkit/secrets.local.env
~~~

npx downloads a selected MCP package on first use by Codex.

## Portable exports

~~~bash
./devkit.sh export
~~~

Exports contain the portable baseline, profiles, scripts, Serena config, and
this guide. They deliberately exclude host overrides, snapshots, secrets,
authentication state, caches, sessions, and previously generated exports.
