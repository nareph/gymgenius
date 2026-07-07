# GymGenius v3

# Contributing Guide

Version 3.0

---

# Overview

Thank you for contributing to GymGenius.

GymGenius is an AI-first, Local-First Health Intelligence System.

Maintaining code quality, architecture consistency and scientific accuracy is more important than adding new features quickly.

Every contribution should move the project toward one goal:

> Help users make better health decisions through reliable software.

---

# Development Philosophy

Every contribution should respect these principles.

- Simplicity over cleverness
- Readability over brevity
- Deterministic logic before AI
- Offline-first by default
- Explainable decisions
- Modular architecture
- Scientific accuracy

---

# Before You Start

Before writing code:

- Read the documentation
- Understand the architecture
- Check the roadmap
- Search for existing issues
- Discuss large changes before implementation

---

# Branch Strategy

The project follows a Git Flow inspired workflow.

## Main Branches

```
main
```

Production-ready code.

---

```
develop
```

Integration branch.

---

## Feature Branches

```
feature/workout-improvements

feature/recovery-score

feature/nutrition-engine

feature/local-ai
```

---

## Bug Fixes

```
fix/workout-crash

fix/hive-migration
```

---

## Documentation

```
docs/update-api

docs/readme
```

---

# Commit Convention

GymGenius follows the Conventional Commits specification.

Format

```
type(scope): short description
```

Example

```
feat(workout): improve exercise swapping

fix(recovery): correct fatigue calculation

docs(api): update internal contracts

refactor(decision): simplify orchestration

test(progress): add trend analysis tests
```

---

# Allowed Commit Types

| Type | Description |
|--------|-------------|
| feat | New feature |
| fix | Bug fix |
| docs | Documentation |
| style | Formatting |
| refactor | Internal refactoring |
| test | Tests |
| perf | Performance |
| build | Build system |
| ci | CI/CD |
| chore | Maintenance |
| revert | Revert previous commit |

---

# Git Hooks

GymGenius enforces quality using Git Hooks.

---

## commit-msg

Every commit message is validated.

Requirements

- Conventional Commit format
- Valid scope
- Clear description

Example

```
feat(workout): add adaptive progression
```

---

## pre-commit

Runs automatically before every commit.

Checks include

- dart format
- flutter analyze
- architecture validation
- markdown validation
- generated files
- import ordering

Commit is rejected if one check fails.

---

## pre-push

Runs before every push.

Checks include

- unit tests
- integration tests
- coverage
- build verification

Push is rejected if any verification fails.

---

# Code Style

Always use

```
dart format
```

before committing.

Never manually format code differently.

---

# Static Analysis

The project must compile with

```
flutter analyze
```

without warnings.

Avoid

- dead code
- unused imports
- ignored warnings

---

# Testing

Business logic must be tested.

Priority

- Decision Engine
- Workout Engine
- Recovery Engine
- Nutrition Engine
- Progress Engine

Every bug fix should include a regression test whenever possible.

---

# Architecture Rules

These rules are mandatory.

---

## UI Layer

Must only

- display data
- capture user actions

Never

- access Hive
- perform calculations
- call AI

---

## ViewModels

Responsible for

- state
- UI interaction
- orchestration

Must not

- contain business logic
- calculate scores
- access Hive directly

---

## Repositories

Responsible for

- persistence
- data mapping
- caching

Repositories never compute business decisions.

---

## Services

Contain reusable application logic.

Services coordinate repositories and engines.

---

## Engines

Each engine owns a single domain.

Workout Engine

Nutrition Engine

Recovery Engine

Progress Engine

Decision Engine

Engines must remain independent.

---

## Decision Engine

The only component allowed to aggregate information from multiple engines.

No engine may directly invoke another engine.

---

# AI Rules

AI enhances the system.

AI never replaces deterministic logic.

Allowed

- explanations
- summaries
- motivational coaching
- natural language

Forbidden

- modifying database
- overriding engine outputs
- inventing health metrics

---

# Offline-First Principle

GymGenius always works without internet.

Two quality modes are supported.

## Local Mode

Uses deterministic engines only.

Fast.

Reliable.

Fully offline.

---

## Enhanced AI Mode

Uses cloud AI when available.

If the provider fails

- retry automatically
- fallback to local engine
- never block the user

Offline capability must never be broken.

---

# Documentation Rules

Every major feature requires documentation updates.

Possible files

- Architecture
- API
- Roadmap
- AI documentation
- Changelog

Documentation is considered part of the implementation.

---

# Pull Requests

A Pull Request should

- describe the change
- explain why
- reference related issues
- include screenshots if UI changes
- include tests when applicable

Small focused PRs are preferred.

---

# Pull Request Checklist

Before opening a PR

- Code formatted
- Analyzer passes
- Tests pass
- Documentation updated
- Changelog updated (if needed)
- No debug code
- No commented-out code

---

# Review Guidelines

Reviewers should verify

- architecture compliance
- readability
- scientific correctness
- performance
- maintainability
- documentation quality

Approvals should prioritize long-term maintainability.

---

# Security

Never commit

- API keys
- secrets
- passwords
- tokens
- personal data

Sensitive configuration belongs in ignored local files.

---

# Performance Guidelines

Prefer

- immutable models
- const widgets
- lazy loading
- efficient rebuilds

Avoid unnecessary allocations and rebuilds.

---

# Scientific Responsibility

Health recommendations must be based on accepted fitness and nutrition principles.

Avoid unsupported claims.

When uncertain

prefer deterministic conservative recommendations.

---

# Long-Term Vision

Every contribution should move GymGenius toward becoming a complete AI Health Operating System.

The project evolves through

Workout Intelligence

↓

Nutrition Intelligence

↓

Recovery Intelligence

↓

Decision Intelligence

↓

AI Health Coach

↓

AI Health Operating System

---

# Final Principle

Before merging any change, ask one question:

> Does this make GymGenius more reliable, more maintainable and more helpful for the user's health?

If the answer is yes, the contribution is moving the project in the right direction.

---

Made with ❤️ by the GymGenius contributors.