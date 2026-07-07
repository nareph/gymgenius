# GymGenius v3
## Decision Engine

Version 3.0

---

# 1. Overview

The Decision Engine is the **central intelligence orchestrator** of GymGenius.

It does not perform low-level calculations itself.

Instead, it collects, evaluates and combines the outputs of every domain engine to determine the **best action for the user today**.

Its mission is to answer one question:

> **"Given everything we know about the user today, what is the best recommendation?"**

---

# 2. Position in the Architecture

```text
Workout Engine
        │
Nutrition Engine
        │
Recovery Engine
        │
Progress Engine
        │
Profile Data
        │
Health History
        ▼
+----------------------+
|   Decision Engine    |
+----------------------+
        │
        ▼
Today's Training Session
Nutrition Plan
Recovery Advice
Daily Coaching
AI Explanation
````

The Decision Engine is the **only component** that has a complete view of the user's current state.

---

# 3. Responsibilities

The Decision Engine is responsible for:

* aggregating outputs from every engine
* detecting conflicts between recommendations
* assigning priorities
* generating a coherent action plan
* validating system consistency
* preparing data for the AI layer

It never performs:

* exercise selection
* calorie calculation
* fatigue estimation
* weight trend computation

Those remain the responsibility of their respective engines.

---

# 4. Inputs

The Decision Engine consumes structured outputs only.

## User Profile

* age
* sex
* height
* weight
* goal
* experience
* available equipment
* medical restrictions

---

## Workout Engine

Examples:

* Training Program
* Weekly Workout Plan
* Planned Training Session
* planned volume
* planned intensity
* weekly workload
* muscle groups trained

---

## Nutrition Engine

Examples:

* calorie target
* protein target
* carbohydrate target
* meal distribution

---

## Recovery Engine

Examples:

* recovery score
* fatigue score
* readiness level
* soreness analysis

---

## Progress Engine

Examples:

* body weight trend
* strength trend
* consistency score
* plateau detection

---

## Historical Data

* previous recommendations
* completed workouts
* skipped sessions
* previous nutrition adherence
* historical recovery

---

# 5. Outputs

The Decision Engine produces a single structured decision object.

Example:

```json
{
  "training_session": {
    "status": "adapted",
    "action": "reduce_volume"
  },

  "nutrition_action": "increase_protein",

  "recovery_action": "prioritize_sleep",

  "priority": "high",

  "reason_codes": [
    "LOW_RECOVERY"
  ]
}
```

The AI layer converts this object into natural language.

---

# 6. Decision Categories

The engine can produce recommendations in several domains.

## Training

Examples:

• keep planned session
• adapt today's session
• reduce volume
• reduce intensity
• replace exercises
• convert to recovery session
• schedule rest day
• request training program regeneration

---

## Nutrition

Examples:

* increase calories
* reduce calories
* increase protein
* redistribute carbohydrates
* adjust meal timing

---

## Recovery

Examples:

* full rest day
* active recovery
* mobility session
* sleep prioritization
* hydration reminder

---

## Lifestyle

Examples:

* increase daily activity
* improve workout consistency
* reduce sedentary time

---

# 7. Decision Pipeline

```text
Collect Inputs
        ↓
Validate Data
        ↓
Normalize Metrics
        ↓
Evaluate Rules
        ↓
Resolve Conflicts
        ↓
Assign Priorities
        ↓
Generate Final Decision
        ↓
Send to AI Layer
```

---

# 8. Conflict Resolution

Multiple engines may recommend different actions.

Example:

Workout Engine

→ Increase training volume

Recovery Engine

→ Reduce training volume

Progress Engine

→ Maintain training volume

The Decision Engine resolves the conflict using predefined priorities.

---

# 9. Priority Hierarchy

Highest priority:

1. Safety
2. Recovery
3. Medical restrictions
4. Long-term progression
5. User goal optimization
6. Personal preferences

Safety always wins.

---

# 10. Rule-Based Decision Matrix

Example:

| Condition                  | Decision           |
| -------------------------- | ------------------ |
| Recovery < 40              | Rest Day           |
| Recovery 40–60             | Reduce Volume      |
| Recovery > 80 & Plateau    | Increase Intensity |
| Plateau + Weight Stable    | Increase Calories  |
| High Fatigue + High Volume | Deload Week        |

This matrix remains deterministic and fully testable.

---

# 11. Confidence Score

Each decision includes a confidence level.

Example:

```json
{
  "confidence": 0.94
}
```

Confidence depends on:

* completeness of data
* consistency of metrics
* recent user activity

Low confidence may trigger more conservative recommendations.

---

# 12. Explainability Metadata

Every recommendation includes machine-readable reasons.

Example:

```json
{
  "reason_codes": [
    "RECOVERY_LOW",
    "PLATEAU_DETECTED"
  ]
}
```

These codes allow the AI layer to generate transparent explanations.

---

# 13. Safety Rules

The Decision Engine must never recommend:

* unsafe training loads
* impossible calorie targets
* contradictory advice
* medically risky behavior

All recommendations must pass validation before being exposed to the user.

---

# 14. Extensibility

New engines can be integrated without changing existing logic.

Examples:

* Sleep Engine
* Hormone Engine
* Stress Engine
* Cardiovascular Engine
* Wearable Engine

Each contributes additional structured inputs to the Decision Engine.

---

# 15. Testing Strategy

The Decision Engine is tested using deterministic scenarios.

Example:

Input:

Recovery = 35

Fatigue = High

Training Volume = High

Expected Output:

Today's Training Session:

• adapted

Adjustments:

• reduce volume

Recovery:

• recommend recovery day

Priority:

• high

Because the engine is rule-based, identical inputs must always produce identical outputs.

---

# 16. Design Principles

The Decision Engine follows five principles:

* deterministic before intelligent
* safety before performance
* explainability before complexity
* consistency before personalization
* modularity before optimization

---

# 17. Future Evolution

Future versions may introduce:

* adaptive rule weighting
* probabilistic decision support
* reinforcement learning assistance
* wearable-informed prioritization
* personalized decision profiles

Even then, deterministic validation will remain mandatory.

---

# 18. Final Principle

> The Decision Engine is the brain of GymGenius.

Every recommendation, including today's training session, nutrition guidance, and recovery advice, must originate from the Decision Engin, ensuring that decisions are:

* data-driven
* explainable
* deterministic
* safe
* consistent
* personalized






