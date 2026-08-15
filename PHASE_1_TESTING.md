# Pawprint Phase 1 Testing

Use the `Pawprint` scheme on an iPhone simulator running iOS 17 or newer.

## Clean test sessions

Add `--phase-one-testing` under **Product → Scheme → Edit Scheme → Run → Arguments** when a tester needs a fresh, temporary profile on every launch. Remove the argument when testing persistence across launches.

## Core test pass

1. Complete onboarding for both a dog and a cat. Confirm Back preserves answers and the final button opens Play without hanging.
2. Confirm Today shows the selected pet, daily progress, and a tappable Play card.
3. Open Play, change the time and mood, and verify all suggestions fit the pet, time, materials, and limitations.
4. Start, pause, resume, finish, and save an activity. Relaunch without the testing argument and confirm the session remains in progress and memories.
5. Ask Fetch for a five-minute activity, a calming activity, a profile summary, and new pet names. Confirm naming/profile questions do not return activities.
6. Switch pets and verify history, favorites, care, and recommendations do not leak between profiles.
7. Add, complete, and delete a care item.
8. Test Dynamic Type, VoiceOver labels, Reduce Motion, and an empty photo permission state.

## Regression checks

- No blank screen after onboarding or tab changes.
- No activity requires unavailable materials when that filter is active.
- Food activities respect allergy, guarding, food-enrichment, and snack settings.
- Activity artwork matches the species and activity category.
- Save failures are visible; no primary action silently disappears.

When reporting a failure, include the screen, exact action, expected result, actual result, simulator/device, iOS version, and the complete Xcode console error.
