# GymGenius v3

# Unit Testing Guide

Version 3.0

---

# Overview

Unit testing is the foundation of GymGenius quality assurance.

Because GymGenius makes health-related recommendations, every deterministic algorithm must be independently validated.

Unit tests verify that a single component behaves correctly in complete isolation.

---

# Objectives

Unit tests should guarantee that:

- deterministic calculations are correct
- business rules remain stable
- regressions are detected immediately
- engines produce reproducible results
- edge cases are handled safely

---

# Testing Philosophy

A unit test should test only one unit.

It should

- have no network dependency
- have no Hive dependency
- have no UI dependency
- execute quickly
- produce deterministic results

---

# What Is a Unit?

Examples

- one function
- one service
- one engine method
- one validator
- one utility class

Never test multiple architectural layers together.

---

# Test Structure

GymGenius follows the Arrange–Act–Assert pattern.

```text
Arrange
↓

Act
↓

Assert
```

Example

```dart
test('Calculates maintenance calories correctly', () {
  // Arrange
  final calculator = NutritionCalculator();

  // Act
  final result = calculator.calculateMaintenanceCalories(...);

  // Assert
  expect(result, 2650);
});
```

---

# Naming Convention

Use descriptive names.

Good

```
should_calculate_calories_for_male_user()

should_detect_plateau_after_four_weeks()

should_reduce_volume_when_recovery_is_low()
```

Bad

```
test1()

engineTest()

works()
```

---

# Engine Testing

Each engine has dedicated responsibilities.

Every public method should have unit tests.

---

# Workout Engine

Critical tests

## Routine Generation

Verify

- split selection
- weekly frequency
- exercise selection
- volume calculation
- progression rules

---

## Progressive Overload

Test

- volume increase
- intensity increase
- plateau handling
- deload scheduling

---

## Exercise Swapping

Verify

- muscle group preserved
- equipment compatibility
- difficulty compatibility
- duplicate prevention

---

## Routine Regeneration

Test

- complete regeneration
- day regeneration
- exercise regeneration
- expired routine replacement

---

# Nutrition Engine

Test

- calorie estimation
- macro calculation
- meal distribution
- protein requirements
- country food selection

Edge cases

- weight gain
- fat loss
- maintenance
- underweight
- obesity

---

# Recovery Engine

Test

Recovery Score

Inputs

- sleep
- soreness
- fatigue
- energy

Expected

- score
- recovery state
- readiness level

---

# Progress Engine

Test

- weekly trends
- monthly trends
- plateau detection
- regression detection
- strength progression

---

# Decision Engine

Highest priority.

Test

- rule aggregation
- priority resolution
- conflict handling
- recommendation generation

Every possible decision path should be covered.

---

# Services

Services coordinate multiple objects.

Verify

- correct repository usage
- correct engine invocation
- proper error handling

---

# Validators

Every validator should be tested.

Examples

- onboarding validation
- profile validation
- workout validation
- nutrition validation

---

# Utilities

Utility functions should also have tests.

Examples

- date formatting
- percentage calculations
- BMI
- BMR
- calorie conversion

---

# Mocking

Dependencies should be mocked.

Examples

- Repository
- AI Provider
- Hive
- Secure Storage

Never access real implementations.

---

# Fixtures

Reusable test data should be stored in fixtures.

Example

```
test/
    fixtures/
        user_fixture.dart
        workout_fixture.dart
        nutrition_fixture.dart
        recovery_fixture.dart
```

Fixtures improve readability and consistency.

---

# Edge Cases

Every algorithm should test

- minimum values
- maximum values
- null inputs
- empty collections
- invalid values
- unexpected combinations

Example

```
weight = 0

height = 0

negative calories

empty workout history
```

---

# Error Handling

Unit tests should verify

- exceptions
- validation failures
- fallback logic
- invalid inputs

No unexpected crashes should occur.

---

# AI Components

Cloud AI is never unit tested directly.

Instead

- mock responses
- validate prompt generation
- verify response parsing
- verify fallback behavior

---

# Offline Mode

Every deterministic engine must be tested without internet.

Offline mode is the primary execution path.

---

# Coverage Targets

| Component | Target |
|------------|---------|
| Decision Engine | 100% |
| Workout Engine | 95% |
| Nutrition Engine | 95% |
| Recovery Engine | 95% |
| Progress Engine | 95% |
| Services | 90% |
| Validators | 100% |
| Utilities | 100% |

Coverage is a minimum expectation.

Quality remains the primary objective.

---

# Example Test Organization

```
test/

    engines/

        workout_engine_test.dart

        nutrition_engine_test.dart

        recovery_engine_test.dart

        progress_engine_test.dart

        decision_engine_test.dart

    services/

    repositories/

    validators/

    utils/

    fixtures/
```

---

# Best Practices

✔ One behavior per test

✔ Independent tests

✔ Fast execution

✔ Deterministic outputs

✔ Clear assertions

✔ Reusable fixtures

✔ Meaningful names

---

# Avoid

Do not

- test Flutter widgets here
- access Hive
- call network services
- call Gemini
- depend on execution order
- use random values

Unit tests must remain isolated.

---

# Definition of Done

A unit is considered complete when

- all expected behaviors are tested
- edge cases are covered
- invalid inputs are handled
- regression tests exist
- coverage target is achieved

---

# Final Principle

> A deterministic engine without comprehensive unit tests cannot be considered trustworthy.

Every recommendation generated by GymGenius begins with code that has been independently verified through unit testing.