# GymGenius v3

## API Specification (Internal Contracts)

Version 3.0

---

# 1. Overview

GymGenius v3 does not expose a traditional backend API.

Instead, it defines a **strict internal contract system** used between:

- ViewModels
- Services
- Repository Layer
- Domain Engines
- Decision Engine
- AI Coach Layer
- Hive Database

All communication is:

> **Structured, deterministic, versioned, and JSON-based.**

These contracts define how every module exchanges information while preserving loose coupling, deterministic behavior, and long-term maintainability.

---

# 2. Core Principles

The internal APIs follow several architectural principles.

## 2.1 Structured Communication

System components never exchange free-form data.

Every payload follows a predefined schema.

---

## 2.2 Deterministic Contracts

Identical inputs must always produce identical outputs.

Business logic never depends on AI.

---

## 2.3 Engine Isolation

Domain Engines never invoke one another directly.

Every interaction is coordinated through the Decision Engine.

---

## 2.4 Single Source of Truth

Hive remains the only persistent source of truth.

Internal APIs never maintain state.

---

## 2.5 Versioned Contracts

Every contract may evolve independently while remaining backward compatible.

---

# 3. Internal API Architecture

```text
Flutter UI
      │
      ▼
ViewModels
      │
      ▼
Repositories
      │
      ▼
Services
      │
      ▼
Internal API Contracts
      │
      ▼
Workout Engine
Nutrition Engine
Recovery Engine
Progress Engine
      │
      ▼
Decision Engine
      │
      ▼
AI Coach
      │
      ▼
Hive Database
```

---

# 4. Internal API Categories

GymGenius organizes its internal contracts into six domains.

---

## 4.1 Profile API

Responsible for retrieving and updating the user's baseline information.

---

### Get User Profile

#### Request

```json
{
  "user_id": "string"
}
```

#### Response

```json
{
  "user_id": "u123",
  "age": 28,
  "height_cm": 180,
  "weight_kg": 78,
  "goal": "muscle_gain",
  "experience": "intermediate",
  "training_days_per_week": 5,
  "equipment": [
    "gym",
    "barbell",
    "dumbbells"
  ],
  "created_at": "2026-01-01"
}
```

---

## 4.2 Workout API

The Workout Engine exposes two primary contracts:

- Generate Training Program
- Get Today's Training Session

---

### Generate Training Program

This contract is executed when:

- onboarding completes
- the current Training Program expires
- a plateau requires structural changes
- the user's goal changes
- the user explicitly requests a new program

---

#### Request

```json
{
  "profile": {},
  "recovery_state": {},
  "progress_state": {},
  "previous_training_program": {}
}
```

---

#### Response

```json
{
  "training_program_id": "tp_001",
  "name": "Hypertrophy Block A",
  "goal": "muscle_gain",
  "duration_weeks": 6,
  "split": "push_pull_legs",
  "weekly_plan": [
    {
      "day": "monday",
      "focus": "push",
      "session": {
        "exercises": [
          {
            "name": "Bench Press",
            "sets": 4,
            "reps": "8-10",
            "rest_seconds": 90,
            "load_type": "progressive"
          },
          {
            "name": "Incline Dumbbell Press",
            "sets": 3,
            "reps": "10-12",
            "rest_seconds": 75
          }
        ]
      }
    }
  ]
}
```

---

### Get Today's Training Session

The client always requests today's session.

Whether the returned session is identical to the Weekly Plan or adapted based on the Decision Engine is an implementation detail hidden inside the Workout Engine.

---

#### Request

```json
{
  "training_program_id": "tp_001",
  "date": "2026-07-04"
}
```

---

#### Response (No Adaptation)

```json
{
  "session_type": "planned",
  "day": "friday",
  "focus": "shoulders",
  "session": {
    "exercises": [
      {
        "name": "Overhead Press",
        "sets": 4,
        "reps": "8-10"
      }
    ]
  }
}
```

---

#### Response (Adapted Session)

```json
{
  "session_type": "adapted",
  "adaptation_reason": "low_recovery",
  "day": "friday",
  "session": {
    "volume": "reduced",
    "intensity": "moderate",
    "exercise_changes": [
      {
        "replace": "Barbell Overhead Press",
        "with": "Seated Dumbbell Press"
      }
    ],
    "exercises": [
      {
        "name": "Seated Dumbbell Press",
        "sets": 3,
        "reps": "10-12"
      }
    ]
  }
}
```

---

## 4.3 Nutrition API

### Generate Nutrition Plan

#### Request

```json
{
  "profile": {},
  "goal": "muscle_gain",
  "training_day": true,
  "recovery_score": 82
}
```

#### Response

```json
{
  "daily_calories": 3100,
  "macros": {
    "protein_g": 160,
    "carbs_g": 400,
    "fat_g": 80
  },
  "meals": [
    {
      "type": "breakfast",
      "items": [
        "Eggs",
        "Bread",
        "Banana"
      ]
    },
    {
      "type": "post_workout",
      "items": [
        "Rice",
        "Chicken"
      ]
    }
  ]
}
```

---

## 4.4 Recovery API

### Compute Recovery State

#### Request

```json
{
  "sleep_hours": 7,
  "soreness": 4,
  "stress_level": 3,
  "training_load": "high"
}
```

#### Response

```json
{
  "recovery_score": 74,
  "status": "moderate_recovery",
  "recommendation": "reduce_volume",
  "fatigue_map": {
    "legs": 80,
    "chest": 60
  }
}
```

---

## 4.5 Progress API

### Track Progress

#### Request

```json
{
  "user_id": "u123",
  "weight_kg": 78,
  "workout_logs": []
}
```

#### Response

```json
{
  "weekly_trend": "-0.4kg",
  "monthly_trend": "-1.2kg",
  "strength_changes": {
    "bench_press": "+5kg"
  },
  "status": "progressing"
}
```

---

## 4.6 Decision Engine API

### Compute Final Decision

The Decision Engine aggregates all domain outputs before determining the safest and most effective action.

#### Request

```json
{
  "profile": {},
  "training_program": {},
  "today_session": {},
  "nutrition_plan": {},
  "recovery_state": {},
  "progress_state": {}
}
```

#### Response

```json
{
  "decision": "adapt_today_session",
  "priority": "high",
  "reason": "Low recovery score combined with high training load",
  "adaptations": {
    "volume": "reduce",
    "intensity": "moderate",
    "exercise_substitution": true,
    "nutrition_adjustment": false
  }
}
```
# 4. API Categories

GymGenius internal APIs are grouped by domain.

---

# 4.1 Profile API

## Get User Profile

### Request

```json
{
  "user_id": "string"
}
```

### Response

```json
{
  "user_id": "u123",
  "age": 28,
  "height_cm": 180,
  "weight_kg": 78,
  "goal": "muscle_gain",
  "experience": "intermediate",
  "training_days_per_week": 5,
  "preferred_training_days": [
    "monday",
    "tuesday",
    "wednesday",
    "friday",
    "saturday"
  ],
  "equipment": [
    "gym"
  ]
}
```

---

# 4.2 Workout API

## Generate Training Program

Creates a complete multi-week training program composed of one reusable weekly workout plan.

### Request

```json
{
  "profile": {},
  "recovery_baseline": {},
  "progress_state": {},
  "previous_training_program": {}
}
```

### Response

```json
{
  "training_program_id": "tp_001",
  "name": "Hypertrophy Block A",
  "goal": "muscle_gain",
  "duration_weeks": 6,
  "start_date": "2026-07-06",
  "end_date": "2026-08-16",

  "weekly_workout_plan": {
    "training_days_per_week": 5,

    "days": [
      {
        "day": "monday",
        "focus": "push",
        "exercises": [
          {
            "exercise": "Bench Press",
            "sets": 4,
            "reps": "8-10",
            "rest_seconds": 90
          }
        ]
      },
      {
        "day": "tuesday",
        "focus": "pull",
        "exercises": []
      },
      {
        "day": "wednesday",
        "focus": "legs",
        "exercises": []
      },
      {
        "day": "friday",
        "focus": "upper",
        "exercises": []
      },
      {
        "day": "saturday",
        "focus": "lower",
        "exercises": []
      }
    ]
  }
}
```

---

## Get Today's Training Session

Returns today's workout after the Decision Engine has evaluated the user's current state.

The endpoint may return:

- the planned session
- an adapted session
- a recovery session
- a complete rest day

The client does not need to know which case occurred.

### Request

```json
{
  "training_program_id": "tp_001",
  "date": "2026-07-08"
}
```

### Response

```json
{
  "date": "2026-07-08",

  "status": "adapted",

  "source_day": "wednesday",

  "decision": "reduce_volume",

  "reason": "Recovery score below threshold",

  "training_session": {

    "focus": "legs",

    "intensity": "moderate",

    "estimated_duration_minutes": 55,

    "exercises": [
      {
        "exercise": "Squat",
        "sets": 3,
        "reps": "8-10"
      },
      {
        "exercise": "Romanian Deadlift",
        "sets": 2,
        "reps": "10-12"
      }
    ]
  }
}
```

Possible values for **status**:

- planned
- adapted
- recovery
- rest_day

The adaptation mechanism is entirely handled internally by the Decision Engine.

# 5. Data Contract Rules

## 5.1 Strict Schema Enforcement

All internal APIs must validate requests before execution.

Rules:

- all required fields must be present
- field types must match the schema
- unknown fields are ignored unless explicitly supported
- business validation occurs before engine execution

---

## 5.2 Versioning

Internal contracts are versioned independently from the application.

Example:

```text
Workout API v1
        ↓
Workout API v2
        ↓
Workout API v3
```

Backward compatibility should be preserved whenever possible.

---

## 5.3 Stateless Design

Every API call must be deterministic.

No component stores temporary execution state.

Persistent state always comes from Hive.

---

## 5.4 Deterministic Outputs

Given the same inputs, deterministic engines must always produce identical outputs.

Only the AI Coach may vary the wording of explanations.

Business decisions must never vary.

---

# 6. Error Handling

## Standard Error Format

```json
{
  "error": true,
  "code": "INVALID_INPUT",
  "message": "Sleep hours must be between 0 and 24."
}
```

---

## Common Error Codes

| Code | Description |
|-------|-------------|
| INVALID_INPUT | Request validation failed |
| MISSING_DATA | Required data unavailable |
| ENGINE_FAILURE | Engine computation failed |
| DECISION_FAILURE | Decision Engine unable to resolve state |
| DATABASE_ERROR | Hive operation failed |
| AI_UNAVAILABLE | AI provider unavailable |
| INTERNAL_ERROR | Unexpected system error |

---

# 7. Internal Communication Rules

## Rule 1 — Engines Never Call Each Other

Domain engines are isolated.

Allowed communication:

```text
Workout Engine
        │
Nutrition Engine
        │
Recovery Engine
        │
Progress Engine
        │
        ▼
Decision Engine
```

Direct engine-to-engine communication is prohibited.

---

## Rule 2 — Services Are Gatekeepers

The Service Layer is responsible for:

- validating inputs
- loading data
- coordinating repositories
- invoking domain engines
- returning normalized outputs

---

## Rule 3 — Decision Engine Owns Final Decisions

Only the Decision Engine can:

- validate today's action
- adapt today's training session
- approve nutrition adjustments
- trigger recovery interventions
- request training program regeneration

---

## Rule 4 — AI Is Read-Only

The AI Coach:

- cannot modify Hive
- cannot modify engine outputs
- cannot override decisions
- only generates explanations from structured data

---

# 8. Performance Strategy

Internal APIs should remain lightweight.

Optimization principles include:

- minimal JSON payloads
- lazy loading where possible
- cache immutable data
- avoid duplicated computations
- reuse engine outputs during the same execution cycle

Daily session generation should complete within the application's performance budget.

---

# 9. Security Rules

Every internal contract must satisfy the following requirements.

## Input Validation

- validate all user inputs
- reject malformed requests
- enforce domain constraints

---

## Repository Protection

Repositories are the only components allowed to access Hive.

No other layer may perform direct database operations.

---

## AI Isolation

AI providers receive only the minimum structured context required.

Sensitive local data must never be exposed unnecessarily.

---

## Immutable Historical Records

Historical logs must never be modified after creation.

Corrections should create new records rather than overwrite existing history.

---

# 10. Future API Extensions

The internal contract system is designed for future expansion.

Potential additions include:

### Wearable API

- Health Connect
- Apple Health
- Garmin
- Fitbit

---

### Coach API

- voice coaching
- conversational coaching
- personalized coaching styles

---

### Computer Vision API

- exercise form analysis
- posture estimation
- repetition counting

---

### Cloud Synchronization API

Optional synchronization between devices while preserving the Local-First architecture.

---

### Plugin API

Allow future extensions without modifying the core application.

Possible examples:

- custom nutrition providers
- alternative workout algorithms
- wearable integrations
- community-developed modules

---

# Final Principle

> Every system output must originate from structured data, deterministic engine logic, and a traceable decision made by the Decision Engine.

The internal API layer exists to guarantee consistency, modularity, and long-term maintainability across the entire GymGenius platform.