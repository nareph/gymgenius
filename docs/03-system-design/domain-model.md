# GymGenius v3

## Domain Model

Version 3.0

---

# 1. Overview

The GymGenius domain model defines the **core business entities** and their relationships.

It represents the conceptual structure of the system, independent of UI, storage, or implementation details.

---

# 2. Core Principle

> The domain model is the “truth layer” of GymGenius.

Everything else (UI, AI, services) is derived from it.

---

# 3. Domain Boundaries

GymGenius is divided into 5 main domains:

* User Domain
* Workout Domain
* Recovery Domain
* Nutrition Domain
* Progress Domain
* Decision Domain

Each domain is **independent but interconnected via the Decision Engine**.

---

# 4. Core Entity Overview

```text id="domain_1"
User
 ├── Workout
 ├── Recovery
 ├── Nutrition
 ├── Progress
 └── Decisions
```

---

# 5. User Domain

## 5.1 User Entity

Represents the core user profile.

### Attributes

* user_id
* age
* height
* weight
* goal
* experience_level
* training_frequency
* equipment_available
* preferences

---

## 5.2 Profile State

Represents dynamic user state.

* current_fatigue
* motivation_level
* adherence_score
* training_readiness

---

# 6. Workout Domain

## 6.1 Routine Entity

Represents a structured training plan.

### Attributes

* routine_id
* name
* split_type
* duration_weeks
* is_active

---

## 6.2 Workout Session

Represents a single training execution.

* session_id
* date
* routine_id
* status
* exercises

---

## 6.3 Exercise Entity

* name
* muscle_group
* sets
* reps
* rest_time
* intensity
* equipment

---

## 6.4 Training Load Model

Represents total stress applied.

* volume
* intensity
* frequency
* fatigue_impact

---

# 7. Recovery Domain

## 7.1 Recovery State

Represents user readiness.

* recovery_score
* fatigue_level
* soreness
* stress_level
* sleep_quality

---

## 7.2 Sleep Record

* hours_slept
* sleep_quality
* sleep_debt

---

## 7.3 Fatigue Map

Per-muscle fatigue tracking:

```text id="fatigue_map"
chest → 70%
legs → 85%
back → 60%
```

---

# 8. Nutrition Domain

## 8.1 Nutrition Plan

* daily_calories
* protein_target
* carbs_target
* fat_target

---

## 8.2 Meal Entity

* meal_type
* ingredients
* macros
* timing

---

## 8.3 Food Preference Model

* country_based_foods
* dietary_restrictions
* budget_level

---

# 9. Progress Domain

## 9.1 Weight Tracking

* weight_kg
* timestamp
* trend_direction

---

## 9.2 Strength Progression

* exercise_name
* weight_increase
* rep_progress

---

## 9.3 Performance Index

Composite metrics:

* strength_score
* endurance_score
* consistency_score

---

## 9.4 Trend Model

* weekly_trend
* monthly_trend
* plateau_detection

---

# 10. Decision Domain (Core Intelligence)

## 10.1 Decision Entity

Represents system output.

* action_type
* adjustments
* reason
* priority

---

## 10.2 Decision Types

* increase_intensity
* reduce_volume
* maintain_plan
* deload_week
* adjust_calories
* prioritize_recovery

---

## 10.3 System State Output

Final system interpretation:

* training_load_adjustment
* nutrition_adjustment
* recovery_adjustment

---

# 11. Relationships Between Domains

```text id="domain_rel"
User
  ↓
Workout → Generates Load
  ↓
Recovery ← Affected by Load
  ↓
Progress ← Measured from Workout + Weight
  ↓
Nutrition → Supports Recovery + Workout
  ↓
Decision Engine → Balances All Domains
```

---

# 12. Domain Interaction Rules

## Rule 1: No Direct Cross-Domain Mutation

Domains do NOT modify each other directly.

---

## Rule 2: Decision Engine is the Mediator

All cross-domain effects go through:

> Decision Engine

---

## Rule 3: Domains are Stateless in Computation

They compute results but do not store derived decisions.

---

## Rule 4: Deterministic Output

Given same inputs:

> domain output must always be identical

---

# 13. Aggregated System State

The system periodically builds:

## Health Snapshot

* recovery_score
* training_load
* nutrition_balance
* progress_rate

---

# 14. Domain Evolution Strategy

Each domain can evolve independently:

* Workout Engine → ML-based progression model
* Recovery Engine → wearable integration
* Nutrition Engine → regional food AI mapping
* Progress Engine → predictive modeling

---

# 15. Failure Isolation

If one domain fails:

* others continue working
* Decision Engine applies fallback logic
* system remains stable

---

# Final Principle

> “Each domain knows only what it must know — nothing more.”


