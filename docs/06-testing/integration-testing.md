# GymGenius v3

# Integration Testing

Version 3.0

---

# 1. Purpose

Integration testing verifies that multiple components work correctly together.

Unlike unit tests, integration tests validate interactions between:

- UI
- ViewModels
- Repositories
- Services
- Engines
- Hive Database
- AI Providers

The objective is to ensure that complete user workflows behave correctly.

---

# 2. Testing Philosophy

GymGenius follows a layered architecture.

Integration tests should validate communication between layers without mocking everything.

Instead of testing isolated functions, we test complete business scenarios.

Example:

User creates a profile

↓

Routine is generated

↓

Routine is saved

↓

Dashboard displays today's workout

↓

Workout is completed

↓

Progress Engine updates statistics

↓

Decision Engine recalculates recommendations

---

# 3. Integration Test Pyramid

```text
UI Integration
──────────────

Application Workflows
─────────────────────

Repository + Services
─────────────────────

Database Integration
```

Unit tests remain the majority of the test suite.

Integration tests verify the correctness of the complete system.

---

# 4. Components Under Test

## UI + ViewModels

Verify:

- user actions
- state transitions
- screen updates

---

## ViewModels + Repositories

Verify:

- data loading
- caching
- persistence

---

## Repositories + Hive

Verify:

- object serialization
- data retrieval
- update operations

---

## Services + Engines

Verify:

- business workflows
- engine coordination

---

## Decision Engine

Verify:

- aggregation of all engine outputs
- recommendation generation

---

## AI Layer

Verify:

- structured prompts
- provider selection
- explanation generation
- deterministic fallback

---

# 5. Integration Test Environment

Tests use an isolated environment.

Example:

```text
Temporary Hive Directory

↓

Fake Preferences

↓

Test Configuration

↓

Mock AI Provider (optional)
```

Production data must never be used.

---

# 6. Example Workflow Tests

## User Onboarding

Scenario:

```text
Launch App

↓

Complete Onboarding

↓

Save Profile

↓

Open Home

↓

Generate Routine

↓

Display Dashboard
```

Assertions:

- profile stored
- routine generated
- dashboard updated

---

## Routine Generation

Scenario:

```text
Existing Profile

↓

Request New Routine

↓

Workout Engine

↓

Decision Engine

↓

AI Explanation

↓

Hive Storage
```

Assertions:

- routine valid
- saved locally
- explanation generated

---

## Routine Regeneration

Scenario:

```text
Existing Routine

↓

User Regenerates Routine

↓

Workout Engine

↓

Save New Routine

↓

Archive Previous Routine
```

Assertions:

- old routine preserved if required
- new routine valid
- dashboard refreshed

---

## Exercise Swap

Scenario:

```text
Current Workout

↓

Swap Exercise

↓

Workout Engine

↓

Replacement Validation

↓

Routine Updated
```

Assertions:

- replacement targets same muscle group
- equipment constraints respected
- progression maintained

---

## Workout Logging

Scenario:

```text
Start Workout

↓

Log Sets

↓

Finish Session

↓

Save Workout Log

↓

Update Progress Engine
```

Assertions:

- workout persisted
- statistics updated
- streak maintained

---

## Recovery Update

Scenario:

```text
User Logs Sleep

↓

Recovery Engine

↓

Decision Engine

↓

Updated Recommendation
```

Assertions:

- recovery score recalculated
- recommendation updated

---

## Nutrition Recommendation

Scenario:

```text
Workout Day

↓

Nutrition Engine

↓

Meal Recommendation

↓

Explanation Generated
```

Assertions:

- calories computed
- macros valid
- meals generated

---

# 7. AI Integration Tests

GymGenius supports multiple AI modes.

Each mode must be tested.

---

## Local Only

Expected:

- no internet required
- deterministic explanations
- immediate response

---

## Cloud Enhanced

Expected:

- provider invoked
- structured prompt sent
- explanation returned

---

## Hybrid Mode

Expected:

- engines compute decisions
- AI enriches explanation

---

## AI Failure

Scenario:

```text
Gemini Timeout

↓

Retry Policy

↓

Fallback Explanation

↓

Application Continues
```

Assertions:

- no crash
- recommendation preserved
- explanation available

---

# 8. Quality Mode Integration

GymGenius supports multiple AI quality modes.

Each workflow should be validated.

---

## Instant Mode

Expected:

- Local AI only
- Fast response
- Offline support

---

## Balanced Mode

Expected:

- Try Cloud AI
- Automatic fallback to Local AI
- No interruption for the user

---

## Premium Mode

Expected:

- Cloud AI required
- Retry policy applied
- Explicit user feedback if generation fails

---

# 9. Database Integration Tests

Verify:

- Hive initialization
- box opening
- migrations
- serialization
- transactions
- concurrent access
- data integrity

---

# 10. Decision Engine Integration

Example scenario:

```text
Recovery Score = 45

Training Load = High

Weight Trend = Stable

Goal = Build Muscle
```

Expected decision:

```text
Reduce Volume

Increase Recovery

Maintain Calories
```

Verify:

- recommendation generated
- explanation available
- history recorded

---

# 11. Error Handling Tests

Validate:

- corrupted Hive data
- missing profile
- invalid routine
- AI timeout
- storage failure
- invalid user input

Application should recover gracefully whenever possible.

---

# 12. Performance Tests

Measure:

- routine generation time
- dashboard loading
- Hive read/write speed
- recommendation latency
- explanation generation time

Target:

| Operation | Target |
|-----------|---------|
| Open Dashboard | < 200 ms |
| Load Profile | < 100 ms |
| Save Workout | < 100 ms |
| Generate Local Routine | < 2 s |
| Generate Cloud Routine | < 10 s |

---

# 13. Offline Testing

GymGenius must work without internet.

Verify:

- profile editing
- workout logging
- routine execution
- recovery calculation
- progress tracking
- deterministic recommendations

Only Cloud AI features should become unavailable.

---

# 14. Continuous Integration

Integration tests should run:

- before every merge
- before every release
- on every Pull Request
- nightly for full regression testing

Example CI pipeline:

```text
Install Dependencies

↓

Analyze

↓

Unit Tests

↓

Integration Tests

↓

AI Validation

↓

Build

↓

Release
```

---

# 15. Success Criteria

An integration test suite is considered healthy when:

- All user workflows pass
- No data corruption occurs
- Engine communication is correct
- AI failures never block the application
- Offline mode remains fully functional
- Performance targets are respected

---

# Final Principle

> Integration tests verify that GymGenius behaves as one coherent intelligent system, not just as a collection of independent modules.