# Decisions

This file captures the most important engineering choices in the repository and why they were made.

## ADR-001: Keep `provider` Instead of Migrating to `riverpod`

### Decision

Use `provider` for the current codebase.

### Why

- existing state surface is small and understandable
- migration churn would not create proportional product value
- public portfolio signal is stronger when the current architecture is coherent than when a trendy migration is half-finished

### Revisit When

- multiple async feature domains appear
- state becomes distributed across many screens and services
- feature-package isolation becomes a goal

## ADR-002: Use an Offline-First Core

### Decision

Local persistence remains the source of truth for settings, onboarding state, and activity history.

### Why

- the game should remain useful without network access
- simpler demo setup for reviewers and recruiters
- faster cold-start and fewer failure modes

## ADR-003: Make Crash Reporting Opt-In by Configuration

### Decision

Sentry is wired structurally but enabled only when `SENTRY_DSN` is provided.

### Why

- the repo is safe to clone and run without third-party credentials
- production posture is demonstrated without forcing secrets into the codebase
- local development remains frictionless

## ADR-004: Add Analytics as a Thin Service Layer

### Decision

Analytics is modeled as a small internal service with typed events and optional Sentry breadcrumbs.

### Why

- shows event taxonomy thinking without overbuilding a backend client
- keeps instrumentation testable and readable
- preserves a seam for later adapters such as Firebase Analytics, PostHog, or Segment

## ADR-005: Add Golden + Integration Coverage

### Decision

Use widget, golden, and integration layers together instead of relying only on unit tests.

### Why

- UI-heavy apps need regression safety above the model layer
- visual changes are common in portfolio projects
- navigation smoke coverage reduces the risk of broken top-level flows

## ADR-006: Separate Product Shell from Flame Runtime

### Decision

Keep the surrounding app shell in standard Flutter screens and isolate the interactive game loop to the Flame screen.

### Why

- product UI and game runtime have different lifecycles
- simpler testability for non-game features
- easier to evolve app-level concerns like onboarding, settings, and diagnostics
