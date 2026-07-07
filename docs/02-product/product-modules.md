# GymGenius v3

## Product Modules

Version: 3.0

---

# 1. Overview

GymGenius v3 is composed of independent but interconnected intelligence modules.

Each module is responsible for a specific health domain:

- Training (Workout)
- Nutrition
- Recovery
- Progress
- Decision Making
- AI Coaching

All modules exchange structured data and are orchestrated by the **Decision Engine**.

---

# 2. Module Architecture Philosophy

Each module must be:

- Independent (no tight coupling)
- Deterministic (rule-based core logic)
- Observable (traceable decisions)
- Adaptive (continuously improved via user data)

---

# 3. Core Modules

---

# 3.1 User Profile Module

## Responsibility

Stores and manages user identity and baseline physiological characteristics.

## Data

- age
- height
- weight
- gender
- goal
- experience level
- equipment
- preferences
- restrictions

## Output

- baseline caloric needs
- training level classification
- macro targets
- initial Training Program constraints

---

# 3.2 Workout Engine

## Responsibility

Generates and adapts:

- Training Programs (multi-week structure)
- Weekly Workouts (weekly structure)
- Workout Days (daily structure)

## Inputs

- user profile
- training history
- recovery state
- progress data

## Functions

- Training Program generation (4–8 weeks cycles)
- Weekly Workout generation and adaptation
- Workout Day generation
- exercise selection
- split planning
- progressive overload
- fatigue-based adaptation

## Output

- Training Program (long-term structure)
- Weekly Workout (weekly structure)
- Workout Day (daily execution plan)

---

# 3.3 Nutrition Engine

## Responsibility

Generates daily nutrition targets and meal suggestions.

## Inputs

- weight trends
- goal (bulk, cut, maintain)
- training intensity
- recovery state
- local food availability

## Functions

- calorie estimation
- macro calculation
- meal structuring
- regional food adaptation

## Output

- daily calorie target
- macronutrient breakdown
- meal suggestions

---

# 3.4 Recovery Engine

## Responsibility

Evaluates user recovery state and training readiness.

## Inputs

- sleep duration
- fatigue level
- soreness
- training load
- consistency history

## Functions

- recovery score calculation
- fatigue estimation
- rest recommendation
- intensity adjustment signal

## Output

- recovery score (0–100)
- readiness state (ready / moderate / low)

---

# 3.5 Progress Engine

## Responsibility

Tracks long-term user evolution.

## Inputs

- weight history
- Workout Session logs
- strength progression
- adherence metrics

## Functions

- trend detection
- plateau detection
- regression detection
- performance forecasting

## Output

- weekly progress report
- status (progressing / plateau / regression)

---

# 3.6 Decision Engine (Core Brain)

## Responsibility

Central orchestration layer that merges all intelligence modules.

## Inputs

- Workout Engine (Training Program / Weekly Workout / Workout Day)
- Nutrition Engine
- Recovery Engine
- Progress Engine
- User Profile

## Functions

- resolve conflicts between modules
- prioritize actions
- ensure safety constraints
- decide adaptations (not generation logic)
- trigger Weekly Workout updates when needed

## Output

- final daily recommendation
- Weekly Workout adaptation decisions
- Training Program evolution signals
- alerts & warnings

---

# 3.7 AI Coach Module

## Responsibility

Transforms structured system outputs into human-readable coaching.

## Inputs

- Decision Engine output

## Functions

- explanation generation
- motivation messaging
- contextual coaching
- feedback communication

## Output

- natural language coaching message
- insights & explanations

---

# 4. Module Communication Flow

```text
User Input
   ↓
User Profile Module
   ↓
Workout / Nutrition / Recovery / Progress Engines
   ↓
Decision Engine
   ↓
AI Coach
   ↓
User Interface
```

---

# 5. Module Independence Rules

## Rule 1: No Direct Engine Coupling

- Workout Engine cannot call Nutrition Engine directly
- All interactions go through Decision Engine

---

## Rule 2: Stateless Computation

- Modules compute only from inputs
- No hidden state dependencies

---

## Rule 3: Deterministic Core Logic

- AI does not decide training structure
- AI only explains system decisions

---

# 6. Data Consistency Model

All modules rely on:

- Hive as single source of truth
- structured JSON contracts
- immutable historical logs (Workout Sessions, Exercise Logs)

---

# 7. Module Evolution Strategy

Each module evolves independently:

Example:

- Workout Engine v1 → v2 → adaptive v3
- Nutrition Engine can evolve without affecting Recovery Engine

---

# 8. Cross-Module Intelligence

System intelligence emerges from interactions:

- Recovery affects Workout Day intensity
- Progress affects Nutrition targets
- Workout Sessions affect Recovery scoring
- Nutrition affects Progress outcomes

---

# 9. Safety Constraints

All modules must respect:

- no overtraining risk
- no extreme diets
- recovery-first logic
- safe progressive overload principles

---

# 10. Final Principle

> GymGenius is not a single AI system.

It is a **network of specialized intelligence modules coordinated by a central Decision Engine**.