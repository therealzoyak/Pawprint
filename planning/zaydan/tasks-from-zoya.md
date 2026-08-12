# Tasks for Zaydan

Requested by Zoya · August 9, 2026

## 1. Make the badge book more delightful

- Improve the Badges button on the home screen with a more aesthetic badge emblem and a stronger sense of personality.
- Redesign the badge library so it feels like a real badge book rather than a standard progress list.
- Use small rounded badge cells, playful artwork, and plenty of color.
- Give badges clear visual states:
  - **Achieved:** vibrant, celebratory, and fully colored.
  - **In progress:** colorful and active, with progress shown clearly.
  - **Locked:** visually distinct and subdued; grey or muted colors are appropriate only here.
- Add a fun introductory header or celebratory hero at the top instead of jumping directly into the badge grid.
- Keep the collection easy to scan without filling it with explanatory text.

## 2. Expand and improve the play library

- Show the important specifications on every activity: estimated time, required materials, and activity type.
- Prioritize activities recommended specifically for Cookie while still allowing the owner to browse any or all safe activities.
- Add a clear way to switch between recommended activities and the full library.
- Support filtering by multiple activity types at once rather than forcing a single selection.
- Make the active filters obvious and easy to clear.
- Preserve all existing pet-safety, materials, and profile-based eligibility rules.

## 3. Add a proper activity end screen

- When an activity finishes, show a dedicated completion screen instead of dropping the user back into the Play flow.
- Celebrate the completed time with the pet and provide a clear sense of closure.
- Keep reaction, early-stop reason, notes, and memory/photo capture available without making the screen feel like a survey.
- After the owner finishes the completion flow, return them directly to the home screen.
- Ensure the saved play time and feedback are reflected immediately in home progress and future recommendations.

## 4. Add a daily play-minute goal

- Let owners choose how many minutes they want to play with each pet per day.
- Include this in setup and make it editable later from the pet profile or progress area.
- Show today's completed minutes against the daily goal on the home screen.
- Keep the goal encouraging rather than streak-based or guilt-inducing.
- Handle days with multiple activities and multiple pets independently and accurately.

## 5. Polish copy and strengthen the color palette

- Audit every visible screen for awkward grammar, spelling mistakes, inconsistent capitalization, and unnatural phrasing.
- Make labels and instructions concise, warm, and easy to understand.
- Increase color saturation across the existing palette so the app feels livelier and less dominated by cream and white.
- Preserve the established design system, layouts, hierarchy, and interaction patterns; this is a color and copy polish pass, not a redesign.
- Check contrast and legibility after adjusting colors, including locked, disabled, and secondary states.

## 6. Resolve mood selection, time matching, and multi-activity recommendations

### Discuss with Zaydan before implementing

- Decide whether the Play mood choices are single-select or multi-select. The current UI looks single-select, but recommendations behave as though multiple contexts may be influencing the result.
- Decide what a multi-activity session means:
  - A planned sequence that fills the owner’s available time.
  - A sequence that adapts as the pet’s energy changes.
  - An optional alternative to one longer activity.
- Decide whether multi-activity combinations deserve their own tab. Do not add the tab until the intended behavior is agreed upon.

### Implement after the decision

- Make the UI clearly reflect the chosen single-select or multi-select behavior.
- Ensure Playful, Hungry, Sleepy, Checking in, and other moods produce meaningfully different ranked results.
- Properly respect available time. A 20-minute opportunity should not repeatedly return only the same 3–5 minute ideas unless the UI explains that they are components of a longer combination.
- If combinations are approved, show the total duration, activity order, transition logic, and whether the next activity changes based on the pet’s engagement or energy.
- Add regression tests for mood differentiation, exact time matching, and combination duration.

## 7. Celebrate daily goal completion

- When a pet reaches their daily play target, show a fun, polished celebration inspired by activity-ring completion.
- Mark the daily target clearly as complete on Home without introducing guilt, streak pressure, or excessive interruption.
- Make the celebration happen once per pet per day and remain accurate across multiple sessions.

## 8. Add future notification and account/profile placeholders

### Discuss the information architecture with Zaydan first

- Decide whether the owner account contains pet profiles, or whether the interface is primarily pet-first with owner settings beneath it.
- Define where shared household settings, notifications, subscription/account information, and individual pet profiles belong.

### Implement placeholders after the decision

- Add a clear Notifications placeholder for future reminders and scheduling controls.
- Add an Owner Profile placeholder and preserve the existing Pet Profile & Plan entry point.
- Clearly label unavailable functionality as coming later; do not create controls that look operational when they are not.

## 9. Make setup more delightful and validate required answers

- Give the five-step setup a warmer, more playful feel inspired by polished pet apps while preserving Pawprint’s own visual identity.
- Use centered, in-place motion only; avoid lateral floating or sliding entrances.
- Add a concise inline validation flag when someone tries to continue without answering a mandatory question.
- Keep each required setup screen within the viewport on supported phone sizes.
- Keep advanced questions in progressive personalization after entering the app.

## 10. Give each main area a distinct but consistent tint

- Establish Home/Play as aqua, Fetch as purple, and Care as pale yellow/gold within the existing palette.
- Apply these tints consistently to headers, selected states, primary actions, and subtle backgrounds without making screens loud or tacky.
- Standardize margins, card spacing, corner radii, button heights, typography hierarchy, and icon treatment across all three areas.
- Perform a final visual QA pass on compact and large iPhone sizes so the app feels professional, neat, and consistently playful.
