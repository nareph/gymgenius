# GymGenius v3

# Coding Guidelines

Version 3.0

---

# 1. Purpose

This document defines the coding standards used throughout the GymGenius project.

Its objectives are to ensure:

- consistency
- readability
- maintainability
- scalability
- testability

Every contributor is expected to follow these guidelines.

---

# 2. General Principles

Good code should be:

- simple
- predictable
- modular
- reusable
- easy to test

Prefer clarity over cleverness.

Readable code is more valuable than shorter code.

---

# 3. Architecture First

Every feature must follow the project's layered architecture.

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

Data Sources
```

Business logic must never bypass these layers.

---

# 4. Single Responsibility Principle

Every class should have one clear responsibility.

Good:

```
WorkoutRepository
```

Bad:

```
WorkoutRepositoryAndGenerator
```

---

# 5. Folder Organization

New files should be placed in the appropriate module.

Example:

```
presentation/

domain/

data/

services/

ai/

core/

shared/
```

Avoid creating miscellaneous folders.

---

# 6. File Naming

Use snake_case.

Examples:

```
workout_repository.dart

nutrition_engine.dart

home_view_model.dart

exercise_card.dart
```

Avoid abbreviations unless they are widely accepted.

---

# 7. Class Naming

Use PascalCase.

Examples:

```
WorkoutEngine

RoutineValidator

NutritionService
```

---

# 8. Variable Naming

Use descriptive camelCase.

Good:

```
currentRoutine

trainingVolume

weeklyCalories
```

Avoid:

```
data

tmp

obj

value
```

---

# 9. Method Naming

Methods should describe actions.

Examples:

```
generateRoutine()

calculateRecoveryScore()

saveWorkout()

estimateCalories()
```

Avoid ambiguous names.

```
run()

process()

handle()

doStuff()
```

---

# 10. Constants

Constants should be centralized.

Example:

```
AppConstants

WorkoutConstants

NutritionConstants
```

Avoid magic numbers.

Bad:

```
if(score > 73)
```

Good:

```
if(score > RecoveryConstants.goodRecoveryThreshold)
```

---

# 11. Widgets

Widgets should remain small.

Prefer:

```
ExerciseCard

WorkoutSummary

RecoveryBanner
```

Instead of one widget containing hundreds of lines.

A widget should ideally remain under 250 lines.

---

# 12. State Management

Presentation state belongs inside ViewModels.

Widgets should never perform business calculations.

Instead of:

```
Widget

↓

Compute calories

↓

Display
```

Use:

```
Widget

↓

ViewModel

↓

Service

↓

Engine
```

---

# 13. Business Logic

Business rules belong inside Services and Engines.

Never place business logic inside:

- Widgets
- UI Screens
- Repositories

---

# 14. AI Usage

AI should never:

- modify persistent data
- replace deterministic calculations
- bypass domain rules

AI is responsible for:

- explanations
- summaries
- personalization
- language generation

---

# 15. Error Handling

Never silently ignore exceptions.

Bad:

```dart
catch (_) {}
```

Good:

```dart
catch (e, stackTrace) {
  logger.error(e, stackTrace);
}
```

Errors should provide enough context for debugging.

---

# 16. Null Safety

Prefer explicit handling.

Avoid unnecessary null assertions.

Bad:

```dart
user!.profile!.weight!
```

Prefer:

```dart
if (user?.profile != null) {
    ...
}
```

---

# 17. Dependency Injection

Dependencies should be injected.

Good:

```dart
class WorkoutService {

    final WorkoutRepository repository;

    WorkoutService(this.repository);

}
```

Avoid creating dependencies inside classes.

Bad:

```dart
final repository = WorkoutRepository();
```

---

# 18. Repository Rules

Repositories should only:

- load data
- save data
- update data
- delete data

Repositories should never contain business decisions.

---

# 19. Engine Rules

Each Engine owns one domain.

Workout Engine

↓

Workout decisions

Recovery Engine

↓

Recovery calculations

Nutrition Engine

↓

Nutrition planning

Decision Engine

↓

Cross-domain orchestration

---

# 20. Logging

Use structured logging.

Include:

- operation
- duration
- success/failure
- relevant identifiers

Never log:

- passwords
- API keys
- personal health information

---

# 21. Documentation

Public classes should include documentation.

Example:

```dart
/// Generates a workout routine using the selected AI Quality Mode.
class WorkoutEngine {}
```

Complex algorithms should include explanatory comments.

Avoid obvious comments.

Bad:

```dart
// Increment i
i++;
```

---

# 22. Testing

Every deterministic calculation should be testable.

Priority:

- Engines
- Services
- Validators
- Repositories

AI-generated language should be tested separately from business logic.

---

# 23. Performance

Prefer efficient algorithms.

Avoid:

- unnecessary rebuilds
- nested loops over large collections
- repeated Hive reads
- unnecessary allocations

Cache expensive computations when appropriate.

---

# 24. Security

Never commit:

- API keys
- secrets
- credentials
- personal datasets

Use secure local storage for sensitive information.

---

# 25. Code Reviews

Every Pull Request should verify:

- architecture compliance
- readability
- test coverage
- documentation updates
- performance considerations

---

# 26. Refactoring

Improve code continuously.

When modifying existing code:

- remove duplication
- improve naming
- simplify logic
- preserve behavior

Avoid large refactors mixed with unrelated feature work.

---

# 27. Preferred Development Workflow

For every new feature:

1. Read the documentation.
2. Design the data model.
3. Implement deterministic logic.
4. Add tests.
5. Integrate AI if required.
6. Update documentation.

Documentation and implementation should evolve together.

---

# 28. Guiding Principle

Every line of code should make GymGenius easier to understand, easier to test, and easier to evolve.

When in doubt, choose the solution that is the simplest, most deterministic, and most maintainable.