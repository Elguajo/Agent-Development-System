---
name: motion-design
description: Define and implement purposeful UI motion, transitions, scroll behavior, and micro-interactions that support an existing visual direction while respecting reduced-motion preferences and performance constraints.
---

# Motion Design

Own **motion behavior**, not the base visual identity.

## Use when
- The interface needs transitions, micro-interactions, scroll effects, or choreographed motion.
- Existing animation feels arbitrary, excessive, inconsistent, or technically expensive.

## Do not use when
- The page needs a new aesthetic direction; use `frontend-design`.
- The problem is layout across viewport sizes; use `responsive-design`.
- The task is primarily runtime performance diagnosis; hand off to `performance-review`.

## Workflow
1. Read the visual brief/design system and identify what motion should communicate.
2. Decide where motion adds clarity, continuity, feedback, hierarchy, or character.
3. Spend visual emphasis deliberately; avoid animating everything.
4. Define duration, easing, delay/stagger, trigger, interruption, and exit behavior.
5. Prefer transform/opacity and other compositor-friendly properties where suitable.
6. Respect `prefers-reduced-motion`; preserve full usability without animation.
7. Avoid scroll effects that break reading, input, focus, or native navigation.
8. Verify in-browser behavior and hand off regressions to `playwright-testing` / `visual-qa`.

## Output contract
Return:
- Motion purpose by interaction
- Timing/easing rules
- Reduced-motion behavior
- Performance/accessibility constraints
- Browser checks required
