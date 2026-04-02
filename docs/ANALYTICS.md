# Analytics

## Purpose

The analytics layer in this repository is intentionally lightweight. It exists to show event taxonomy, instrumentation discipline, and a clean adapter seam without coupling the app to a specific backend.

## Service

- `lib/services/app_analytics.dart`

## Event Types

- `appLaunched`
- `screenViewed`
- `onboardingSkipped`
- `onboardingNextTapped`
- `onboardingCompleted`
- `gameStarted`
- `settingsSaved`

## Current Instrumentation Points

- app boot
- onboarding progression
- settings persistence
- game start
- major screen views across onboarding, home, game, settings, about, and hunt journal
- selected screen views

## Why This Design

- typed enum prevents random string drift
- logger output keeps local debugging simple
- logger-backed event output keeps the app fully backend-free while preserving an upgrade path
- parameters remain map-based for easy backend adaptation later

## Next Step If Product Expands

1. introduce backend adapter interface
2. define event naming policy and ownership
3. add privacy review and PII rules
4. centralize screen naming constants
5. add analytics assertions in tests for critical flows
