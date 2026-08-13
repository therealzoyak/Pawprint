# Remaining tasks from Zoya

Updated after implementation audit · August 12, 2026

Completed items have been removed. Zoya is the product decision-maker for the choices below.

## 1. Resolve mood selection, time matching, and multi-activity recommendations

### Current product direction from Zoya

- Keep the Play mood choices single-select.
- Treat multi-activity sessions as optional follow-ons rather than adding a separate tab for now.

### Remaining implementation

- Make Playful, Hungry, Sleepy, Checking in, and other moods produce meaningfully different ranked results.
- Properly respect available time. A 20-minute opportunity should not repeatedly return only the same 3–5 minute ideas unless the UI explains that they are components of a longer combination.
- For optional combinations, show the total duration, activity order, transition logic, and whether the next activity changes based on the pet’s engagement or energy.
- Add regression tests for mood differentiation, exact time matching, and combination duration.
