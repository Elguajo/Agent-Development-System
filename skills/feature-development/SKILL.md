---
name: feature-development
description: Orchestrate a non-trivial feature from clarified requirements through exploration, architecture, implementation, focused verification, and review. Use for multi-file features that benefit from a structured end-to-end workflow.
---

# Feature Development

Own **workflow orchestration**, not the specialist responsibilities themselves.

## Use when
- Building a non-trivial feature across multiple files or layers.
- Requirements, architecture, implementation, and verification all matter.
- The user wants an end-to-end feature workflow rather than one focused task.

## Do not use when
- The change is a tiny, well-defined fix.
- The user only asks for design, debugging, testing, or review; use that focused skill directly.

## Workflow
1. Clarify product intent with `product-requirements` when scope or acceptance criteria are unclear.
2. Use `codebase-explorer` to understand relevant existing patterns.
3. Use `solution-architecture` for material technical decisions.
4. Implement the approved smallest coherent solution, following project instructions.
5. For UI work, preserve supplied design intent and coordinate with `frontend-design`, `design-system-enforcer`, `figma-implementation`, `responsive-design`, and `motion-design` only as relevant.
6. Verify behavior with `testing` and/or `playwright-testing`.
7. Verify visible UI with `visual-qa` when appropriate.
8. Run focused `accessibility-review`, `performance-review`, `code-review`, or `security-review` when the change affects those concerns.
9. Hand final readiness to `release-check`.

## Orchestration rules
- Do not invoke every skill mechanically; use only specialists justified by the task.
- A specialist's explicit boundary overrides this orchestrator.
- Do not reopen settled product/design decisions without evidence of a conflict or defect.
- Keep implementation proportional to the requirement; avoid speculative infrastructure.
- State what was actually verified versus what remains unchecked.

## Output contract
Return:
- Feature status
- Decisions made
- Files/surfaces changed
- Verification performed
- Findings/fixes
- Remaining risks or follow-ups
