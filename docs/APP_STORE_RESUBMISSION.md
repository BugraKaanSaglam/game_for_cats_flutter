# App Store Resubmission

## Goal

This document packages the current App Store resubmission strategy for `Mice and Paws: Cat Game` after a Guideline 4.3 spam-style rejection on an update.

The current build now leans much more clearly into a distinct, self-contained game experience:

- game-first home screen
- simplified non-game utility surfaces
- more distinctive in-round HUD
- streak-based round summary
- clearer product story and metadata alignment
- no backend requirement during review

## Reviewer Positioning

Use the following points consistently in App Review notes and any follow-up reply:

- this is an update to a previously approved original app
- the app is not a template, repackaged binary, or clone
- the current build focuses on the core cat-game experience
- the app works locally without requiring backend access for review
- metadata and screenshots were refreshed to match the updated binary

## Recommended Review Notes

```text
This submission is an update to a previously approved original app. The app is my own work and is not a template, repackaged binary, or related to any terminated developer account.

In this build I focused on making the game experience more distinctive and better aligned with the App Store listing: I redesigned the home screen around the core hunt flow, improved the in-game HUD and end-of-round summary, refreshed the visual identity and copy, removed non-essential utility surfaces, and kept the app fully local without requiring backend services for review.
```

## Recommended What's New

```text
Refined the app with a more distinctive game-first home screen, improved the in-game HUD and round summary, added streak and cat mood feedback, refreshed onboarding and help copy, and streamlined non-essential utility surfaces to better match the core play experience.
```

## Subtitle Candidates

- `Mice, Bugs, and Paw Taps`
- `A Playful Hunt for Cats`
- `Indoor Hunting Fun for Cats`

## Screenshot Plan

Capture portrait screenshots only and keep them focused on gameplay value.

1. Home screen
   Show the game-first hero and the hunt setup summary.
2. Live gameplay
   Show moving critters, timer, and the HUD together.
3. Round summary
   Show accuracy, best streak, and cat mood.
4. Settings
   Show timer, difficulty, sound, and custom play mat controls.
5. Hunt Journal
   Show local session history and accuracy tracking.

Avoid using:

- About/build info as a featured screenshot
- utility-only views
- splash-only images
- images that hide the actual gameplay

## Final Pre-Submission Checklist

1. Build a fresh iOS binary from the current commit.
2. Verify the version/build number in `pubspec.yaml`.
3. Upload refreshed screenshots that match the current UI.
4. Update `What's New`.
5. Update subtitle if needed.
6. Paste the current review notes.
7. Confirm the app can be reviewed without login or backend services.
