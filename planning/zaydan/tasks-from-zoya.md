# Tasks for Zaydan

Requested by Zoya · August 6, 2026

## 1. Make sessions adapt to actual engagement

- Track actual active time from the session timer, not the activity's preset duration.
- If someone ends early, ask one lightweight follow-up such as whether the pet lost interest, became uncomfortable, or the owner simply needed to stop.
- Use that answer and the elapsed time to adjust future duration recommendations for that pet. Do not assume every early stop means boredom.
- When extra time remains, offer an optional `Add another activity` action that creates a short, compatible activity mix without interrupting the current flow.
- Keep preset duration, actual duration, early-stop reason, and combined-session activities as separate data so later recommendations can learn from them.

### Done when

- A five-minute activity stopped after three minutes records three minutes of play.
- The completion screen captures an early-stop reason in one tap and does not feel like a survey.
- Future suggestions can become shorter or change style based on repeated outcomes.
- Owners can extend a session with a compatible second activity when their available time permits.

## 2. Separate enrichment play from routine care

- Establish two clear content types: `Play & enrichment` and `Routine care`.
- Keep the primary Play flow focused on enrichment suggestions.
- Give the dashboard a compact daily-care area for brushing, coat checks, nail/paw care, dental care, medication, and other pet-specific reminders.
- Present care items inline on the dashboard or as a dedicated full-screen destination; avoid stacking modal cards.
- Let owners set a useful cadence without turning care into streak pressure. Completion should feel reassuring and contribute to a weekly care summary.
- Include consent-based tips and gentler alternatives when a pet dislikes grooming, with appropriate vet or professional-groomer guidance for pain, severe matting, or sudden sensitivity.

### Done when

- Owners can immediately tell whether an item is play or care.
- Care reminders do not compete with the main activity recommendation.
- Completing care is tracked separately from active play minutes.
- The dashboard stays simple even when a pet has several recurring needs.

## 3. Keep recommendations current without questionnaire fatigue

- Add a quick way to update temperament, energy, sensitivities, health context, and current situation from the pet profile.
- Prefer passive learning from completed sessions, elapsed time, reactions, skipped activities, and care outcomes.
- Ask at most one contextual question when it materially changes today's recommendation; reuse recent answers instead of asking on every app open.
- Surface an occasional lightweight profile check-in only when the recommendation confidence is stale or behavior has noticeably changed.
- Preserve the warm visual language and add purposeful motion: smooth full-screen transitions, responsive button states, brief loading animation, and optional flip interactions for activity details.
- Audit navigation so every button has one clear job, back/continue behavior is predictable, and primary flows do not depend on popup-card stacks.

### Done when

- Owners can correct an outdated pet profile in a few taps.
- Recommendations adapt without repeated long forms or excessive copy.
- Animations clarify progress and hierarchy without slowing down the task.
- Play, care, completion, and profile-editing flows work consistently from start to finish.

