---
name: debugging
description: Diagnose and fix reproducible software defects using evidence, isolation, hypotheses, and regression verification. Use when behavior is wrong, unstable, failing, or unexplained and the root cause is not yet known.
---

# Debugging

Own **root-cause diagnosis and targeted correction**.

## Use when
- A bug can be reproduced or observed through logs/tests/runtime behavior.
- The cause is unclear.
- Previous ad-hoc edits have not reliably solved the problem.

## Do not use when
- The task is planned feature development; use `feature-development`.
- The user only wants code cleanup with unchanged behavior; use `refactor`.
- The issue is purely visual comparison; use `visual-qa`.

## Workflow
1. Reproduce the failure or gather the strongest available evidence.
2. Define expected versus actual behavior precisely.
3. Narrow the failing layer before editing code.
4. Form explicit hypotheses ranked by likelihood/evidence.
5. Test the cheapest discriminating hypothesis first.
6. Fix the smallest root cause rather than masking symptoms.
7. Add or update a regression test when practical.
8. Re-run the original reproduction and relevant nearby checks.
9. Record unresolved uncertainty instead of claiming certainty.

## Rules
- Do not randomly modify multiple unrelated areas until the bug disappears.
- Do not suppress errors without understanding them.
- Prefer instrumentation, logs, traces, tests, and minimal experiments over guesswork.
- Preserve unrelated behavior and project conventions.

## Output contract
Return:
- Reproduction/evidence
- Root cause (or strongest remaining hypothesis)
- Fix applied
- Regression verification
- Remaining uncertainty or follow-up
