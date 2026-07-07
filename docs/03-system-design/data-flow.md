# GymGenius v3

## Data Flow Design

Version 3.0

---

# 1. Overview

The GymGenius data flow describes how information moves through the system from user input to final AI explanation.

The system is designed as a **strict unidirectional pipeline** to ensure:

* predictability
* traceability
* deterministic outcomes
* modular intelligence

---

# 2. Core Principle

> Data always flows forward — never backward.

There is no circular dependency between layers.

---

# 3. Global Data Flow Architecture

```text id="flow_1"
User Input
   ↓
ViewModel Layer
   ↓
Repository Layer
   ↓
Service Layer
   ↓
Domain Engines
   ↓
Decision Engine
   ↓
AI Coach Layer
   ↓
UI Output
   ↓
User Feedback Loop
```

---

# 4. Data Flow Categories

GymGenius has 3 main flows:

---

## 4.1 Read Flow (Data Retrieval)

Used when displaying information to the user.

```text id="read_flow"
Hive Database
   ↓
Repository
   ↓
Service Layer
   ↓
Engines
   ↓
ViewModel
   ↓
UI
```

### Example

* loading workout history
* displaying progress
* showing recovery score

---

## 4.2 Write Flow (Data Persistence)

Used when user submits new data.

```text id="write_flow"
User Action
   ↓
ViewModel
   ↓
Repository
   ↓
Hive Database
```

### Example

* logging workout
* updating weight
* saving sleep data

---

## 4.3 Intelligence Flow (Core System Loop)

Used for generating decisions.

```text id="intelligence_flow"
User Data
   ↓
Service Layer
   ↓
Domain Engines
   ↓
Decision Engine
   ↓
AI Coach Layer
   ↓
UI Recommendation
```

---

# 5. Domain-Specific Flows

---

## 5.1 Workout Flow

```text id="workout_flow"
User starts session
   ↓
Workout Engine
   ↓
Routine execution
   ↓
Workout logging
   ↓
Progress Engine update
   ↓
Decision Engine adjustment
   ↓
AI explanation
```

---

## 5.2 Recovery Flow

```text id="recovery_flow"
User inputs sleep & fatigue
   ↓
Recovery Engine
   ↓
Readiness score calculation
   ↓
Decision Engine
   ↓
Training adjustment
   ↓
AI explanation
```

---

## 5.3 Nutrition Flow

```text id="nutrition_flow"
User goal + activity level
   ↓
Nutrition Engine
   ↓
Macro calculation
   ↓
Decision Engine
   ↓
Meal plan adjustment
   ↓
AI explanation
```

---

## 5.4 Progress Flow

```text id="progress_flow"
Workout logs + weight logs
   ↓
Progress Engine
   ↓
Trend analysis
   ↓
Decision Engine
   ↓
Training adjustment
```

---

# 6. Decision Loop (Core System Cycle)

This is the **heart of GymGenius intelligence**.

```text id="decision_loop"
Input Data
   ↓
Engines Process Data
   ↓
Decision Engine Aggregates
   ↓
System Decision Generated
   ↓
AI Coach Explains
   ↓
User Executes Action
   ↓
New Data Created
   ↓
Loop Restarts
```

---

# 7. Feedback Loop System

GymGenius continuously learns from:

## User Actions

* workouts completed
* skipped sessions
* nutrition adherence
* recovery input

---

## System Outputs

* training adjustments
* calorie changes
* recovery recommendations

---

## Feedback Effect

Each cycle improves:

* personalization
* prediction accuracy
* training optimization

---

# 8. Event-Driven Flow Model

GymGenius uses event-driven updates internally.

## Example Events

* `WORKOUT_COMPLETED`
* `WEIGHT_UPDATED`
* `RECOVERY_SUBMITTED`
* `ROUTINE_GENERATED`

---

## Event Flow

```text id="event_flow"
Event Triggered
   ↓
Service Layer Handler
   ↓
Engine Processing
   ↓
Decision Engine Update
   ↓
UI Refresh
```

---

# 9. Data Transformation Rules

## Rule 1: Raw → Structured → Decision

```text
Raw Input → Normalized Data → Engine Output → Decision Output
```

---

## Rule 2: No Direct UI Logic

UI never processes raw fitness logic.

---

## Rule 3: Engines Only Process Data

No storage responsibility in engines.

---

## Rule 4: Decision Engine Final Authority

Only Decision Engine can modify system behavior.

---

# 10. Synchronization Strategy

Even in local-first mode:

* all flows remain synchronous by default
* async operations used only for performance
* UI always reacts to final state

---

# 11. Performance Flow Optimization

## Techniques

* caching recent engine outputs
* batching Hive writes
* lazy evaluation of trends
* precomputed weekly summaries

---

# 12. Error Flow Handling

```text id="error_flow"
Error Detected
   ↓
Service Layer catches
   ↓
Fallback Logic Applied
   ↓
Safe UI State Returned
```

---

## Example

If Recovery Engine fails:

* default recovery score used
* system continues safely

---

# 13. Data Integrity Flow

Before data is accepted:

```text id="validation_flow"
Input
   ↓
Validation Layer
   ↓
Sanitization
   ↓
Repository Storage
```

---

# 14. AI Integration Flow

AI is always **post-decision layer**.

```text id="ai_flow"
Decision Engine Output
   ↓
AI Coach Layer
   ↓
Natural Language Explanation
   ↓
UI Display
```

---

# 15. Long-Term Evolution Flow

Future upgrades will introduce:

* predictive flows (before user input)
* biometric real-time streams
* adaptive UI flows based on fatigue state

---

# Final Principle

> “Every action in the system is part of a continuous learning loop.”


