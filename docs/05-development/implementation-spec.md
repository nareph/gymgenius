# GymGenius v3

# Implementation Specification

Version 3.0

---

# 1. Purpose

This document defines how the GymGenius architecture must be implemented.

It translates the architectural principles into concrete implementation rules.

Every new feature should follow this specification to ensure consistency across the project.

---

# 2. Architecture Overview

GymGenius follows a layered architecture.

```
Presentation
        ↓
ViewModels
        ↓
Repositories
        ↓
Services
        ↓
Domain Engines
        ↓
Hive Database

                 ↓

          Optional AI Layer
```

Each layer has a single responsibility.

No layer should bypass another.

---

# 3. Project Structure

```
lib/

core/

data/

domain/

presentation/

services/

ai/

shared/

main.dart
```

---

# 4. Core Layer

The Core layer contains application-wide utilities.

Examples:

```
core/

config/

constants/

errors/

exceptions/

logger/

routing/

utils/

theme/
```

Responsibilities:

- application configuration
- constants
- routing
- shared utilities
- error definitions

Business logic must never be placed here.

---

# 5. Data Layer

The Data layer is responsible for persistence.

Example:

```
data/

models/

datasources/

repositories/
```

Responsibilities:

- Hive models
- adapters
- local persistence
- serialization

Must not contain business decisions.

---

# 6. Domain Layer

The Domain layer contains business entities.

Examples:

```
User

Workout

Exercise

Meal

RecoverySnapshot

HealthDecision
```

Entities should remain independent from Flutter.

---

# 7. Presentation Layer

The Presentation layer contains everything visible to the user.

```
presentation/

screens/

widgets/

dialogs/

components/

viewmodels/
```

Responsibilities:

- rendering
- navigation
- user interaction

No business calculations.

---

# 8. ViewModels

ViewModels coordinate the UI.

Responsibilities:

- expose state
- call Services
- react to user actions
- notify listeners

ViewModels should never access Hive directly.

Example:

```
HomeScreen

↓

HomeViewModel

↓

WorkoutService
```

---

# 9. Repository Layer

Repositories abstract data access.

Responsibilities:

- load data
- save data
- update data
- delete data

Repositories never calculate recommendations.

---

# 10. Services Layer

Services implement application workflows.

Examples:

```
WorkoutService

NutritionService

RecoveryService

ProgressService

AIService
```

Responsibilities:

- orchestrate repositories
- call engines
- prepare data
- coordinate multiple modules

---

# 11. Engines Layer

Engines contain deterministic intelligence.

Each Engine owns one domain.

Workout Engine

↓

Workout generation

Nutrition Engine

↓

Nutrition planning

Recovery Engine

↓

Recovery calculations

Progress Engine

↓

Progress analysis

Decision Engine

↓

Cross-domain orchestration

---

# 12. AI Layer

The AI layer enhances deterministic outputs.

Responsibilities:

- natural language generation
- explanations
- summaries
- motivation

AI never changes deterministic decisions.

---

# 13. AI Quality Modes

GymGenius supports three execution modes.

---

## Local

Uses only deterministic algorithms.

No internet required.

---

## Balanced

Uses cloud AI for selected features while keeping deterministic logic local.

If cloud generation fails:

- retry
- fallback when applicable

---

## Premium

Uses the configured cloud provider to maximize personalization.

Business rules remain deterministic.

---

# 14. Feature Implementation Workflow

Every new feature should follow this sequence.

```
Requirements

↓

Domain Model

↓

Hive Model

↓

Repository

↓

Service

↓

Engine

↓

ViewModel

↓

UI

↓

Tests

↓

Documentation
```

Skipping layers should be avoided.

---

# 15. Example Feature

Example:

Weight Tracking

```
WeightLog

↓

Hive Model

↓

WeightRepository

↓

ProgressService

↓

ProgressEngine

↓

DecisionEngine

↓

HomeViewModel

↓

Dashboard
```

---

# 16. Dependency Rules

Allowed:

```
UI

↓

ViewModel

↓

Service

↓

Repository

↓

Hive
```

Forbidden:

```
Widget

↓

Hive
```

Forbidden:

```
ViewModel

↓

Hive
```

Forbidden:

```
Repository

↓

Decision Engine
```

---

# 17. Data Flow

Every user action follows the same pipeline.

```
User

↓

Widget

↓

ViewModel

↓

Service

↓

Engine

↓

Repository

↓

Hive

↓

Repository

↓

ViewModel

↓

Widget
```

---

# 18. Error Handling

Every layer should return meaningful failures.

Never expose technical exceptions to users.

Example:

Repository

↓

DatabaseException

↓

Service

↓

ApplicationError

↓

ViewModel

↓

Friendly Message

---

# 19. Validation

Validation occurs at multiple levels.

UI

↓

Basic validation

↓

Service

↓

Business validation

↓

Engine

↓

Decision validation

↓

Repository

↓

Persistence validation

---

# 20. Testing Strategy

Priority order.

Unit Tests

- Engines
- Services
- Validators

Integration Tests

- Repositories
- Hive

Widget Tests

- Screens
- Components

End-to-End Tests

- Complete user workflows

AI prompt testing should remain independent from deterministic logic tests.

---

# 21. Performance Requirements

The application should remain responsive.

Target examples:

- screen load < 200 ms
- Hive queries < 50 ms
- local recommendations < 1 second
- cloud recommendations < 10 seconds

Avoid unnecessary rebuilds and database reads.

---

# 22. Documentation Requirements

Every significant feature should update:

- Product documentation (if behavior changes)
- System Design (if architecture changes)
- AI documentation (if prompts or models change)
- Development documentation (if implementation changes)

Documentation is part of the implementation.

---

# 23. Future Extensibility

The architecture should allow new modules to be added without modifying existing ones.

Future examples:

```
Hydration Engine

Mental Health Engine

Habit Engine

Wearable Engine

Medical Engine
```

Each module should integrate through the existing Services and Decision Engine.

---

# 24. Implementation Checklist

Before merging a feature:

- Domain model created
- Hive model implemented
- Repository completed
- Service implemented
- Engine updated (if required)
- ViewModel connected
- UI completed
- Tests written
- Documentation updated

---

# 25. Guiding Principle

Every feature in GymGenius should be implemented in a way that is modular, deterministic, testable, and easy to evolve.

If a new feature requires breaking the architecture, the architecture should be reconsidered before the implementation proceeds.