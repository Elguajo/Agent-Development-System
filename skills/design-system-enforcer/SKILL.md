---
name: design-system-enforcer
description: Enforce an existing product design system during UI implementation by reusing tokens, primitives, components, patterns, and documented rules instead of inventing duplicates or arbitrary values. Use when a repository already has a design system or DESIGN.md.
---

# Design System Enforcer

Own **consistency with an existing design system**. Do not invent the project's aesthetic direction.

## Use when
- Implementing or modifying UI in a project with existing tokens/components/design rules.
- The task risks creating duplicate primitives or arbitrary style values.
- `DESIGN.md`, theme tokens, component libraries, or established UI patterns exist.

## Do not use when
- The user wants a new visual identity; `frontend-design` owns art direction.
- There is no existing system to enforce; follow the task brief and project instructions instead.
- The task is a visual regression audit; use `visual-qa`.

## Workflow
1. Read project instructions and `DESIGN.md` if present.
2. Inspect theme/tokens and component directories before coding.
3. Search for existing components matching the requested behavior.
4. Reuse existing variants and composition patterns whenever possible.
5. Use semantic tokens instead of arbitrary colors, spacing, radii, shadows, typography, or z-index values.
6. Create a new primitive only if no suitable existing one exists; explain the gap in code/comments only when useful.
7. Keep component APIs consistent with neighboring components.
8. Verify responsive, hover, focus, disabled, loading, error, and empty states where applicable.

## Conflict rules
- Task-specific design instructions override generic system defaults when explicitly requested.
- Do not undo intentional visual decisions made by `frontend-design` if they are compatible with project constraints.
- If Figma conflicts with the coded design system, do not guess: preserve semantic behavior and flag the mismatch for resolution.

## Completion criteria
A change is consistent when it reuses established tokens/components, avoids unnecessary duplicates and one-off styling, and still satisfies the requested UI behavior.
