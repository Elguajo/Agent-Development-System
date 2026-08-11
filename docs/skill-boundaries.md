# Skill Boundaries and Handoffs

This document prevents skills from competing for the same responsibility.

## Precedence

1. Explicit user request
2. Repository/project instructions (`AGENTS.md`, `CLAUDE.md`, project docs)
3. Task-specific source of truth (for example Figma, approved screenshots, API contract)
4. Existing project conventions/design system
5. Generic guidance inside these skills

A skill must not override a higher-precedence source.

## Responsibility map

| Skill | Primary responsibility | Handoff / boundary |
|---|---|---|
| `product-requirements` | Define what/why, scope, states, acceptance criteria | Technical design → `solution-architecture` |
| `solution-architecture` | Decide how a non-trivial change fits the existing system | Visual direction → `frontend-design`; verification → review skills |
| `frontend-design` | Visual concept/art direction | Existing-system consistency → `design-system-enforcer`; reference implementation → `figma-implementation` |
| `design-system-enforcer` | Reuse existing tokens/components/patterns | Does not invent art direction |
| `figma-implementation` | Translate supplied Figma/reference intent to production code | Post-implementation fidelity → `visual-qa` |
| `visual-qa` | Compare implemented UI to approved visual intent | Functional browser behavior → `playwright-testing` |
| `playwright-testing` | Browser-level functional/E2E verification | Visual fidelity → `visual-qa`; a11y → `accessibility-review` |
| `accessibility-review` | Accessibility-specific audit/remediation | Does not broadly redesign UI |
| `performance-review` | Evidence-based performance diagnosis | Does not perform speculative architecture rewrites |
| `code-review` | Correctness/regression/maintainability review of a change | Deep security → `security-review` |
| `security-review` | Security/trust-boundary review | General quality → `code-review` |
| `release-check` | Final evidence-based ship/no-ship gate | Material defect → hand back to owning skill |
| `credit-codex-contributor` | Repository attribution workflow | Unrelated to engineering workflow skills |

## Collision rules

### `frontend-design` vs `design-system-enforcer`
`frontend-design` may propose an aesthetic direction when the brief leaves room for one. `design-system-enforcer` ensures implementation reuses the existing system. If an explicit new design direction intentionally changes the system, the task/user decision wins; do not silently force old tokens back in.

### `frontend-design` vs `figma-implementation`
When Figma or an approved reference is supplied as the source of truth, `figma-implementation` should reproduce it instead of allowing `frontend-design` to reinterpret it. Use `frontend-design` only for unresolved visual choices.

### `visual-qa` vs `playwright-testing`
`visual-qa` answers “does it look right?” `playwright-testing` answers “does it work in a browser?” A single browser session may gather evidence for both, but findings remain classified by owner.

### `code-review` vs `security-review`
`code-review` can flag an obvious security problem, but security-sensitive surfaces should be handed to `security-review` for threat-focused analysis. `security-review` should not fill its report with general formatting or maintainability opinions.

### `release-check` vs every other skill
`release-check` does not redo all prior work. It verifies evidence and delegates material failures back to the relevant owner. It should never claim that an unavailable check passed.

## External skills/plugins

This repository intentionally avoids duplicating provider-specific capabilities when an official external skill/plugin already owns them well. In particular, the existing vendored `frontend-design` remains the sole generic art-direction skill. Provider tools such as Figma MCP/plugins can be used by `figma-implementation` rather than copied into this repository.
