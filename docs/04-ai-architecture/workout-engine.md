# GymGenius v3
## Workout Engine

Version 3.0

---

# 1. Overview

The Workout Engine is responsible for generating, adapting and optimizing workout routines.

Its objective is to create training programs that maximize long-term progress while respecting the user's profile, recovery status and training history.

The engine operates entirely through deterministic business rules.

Artificial Intelligence may improve explanations or personalization, but it never replaces the core decision logic.

---

# 2. Mission

The Workout Engine answers the question:

> **"What is the optimal training program for this user?"**

---

# 3. Responsibilities

The Workout Engine is responsible for:

- training program generation
- weekly workout plan generation
- exercise selection
- split selection
- progression planning
- training program lifecycle management
- training program regeneration
- muscle group distribution

The engine does **not**:

- calculate calories
- estimate recovery
- analyze body weight trends
- make final recommendations

Those responsibilities belong to other engines.

---

# 4. Inputs

The engine consumes structured data from multiple sources.

## User Profile

- age
- sex
- height
- weight
- goal
- experience level
- available equipment
- medical restrictions
- preferred training days
- preferred session duration

---

## Progress Data

- previous training programs
- completed workouts
- missed workouts
- personal records
- training consistency

---

## Recovery Data

- recovery score
- fatigue score
- soreness
- readiness level

---

## System Settings

- training philosophy
- overload strategy
- progression limits

---

# 5. Outputs

The Workout Engine returns a structured routine object.

Example:

```json
{
  "training_program_id": "uuid",
  "duration_weeks": 6,
  "split": "Upper / Lower",
  "weekly_workout_plan": [],
  "progression_strategy": "linear"
}
```

---

# 6. Internal Architecture

```text
Profile Analysis
        │
        ▼
Goal Analysis
        │
        ▼
Split Selection
        │
        ▼
Exercise Selection
        │
        ▼
Volume Planning
        │
        ▼
Intensity Planning
        │
        ▼
Training Program Validation
        │
        ▼
Workout Plan
```

---

# 7. Generation Pipeline

The engine follows a deterministic pipeline.

## Step 1

Analyze user profile.

---

## Step 2

Determine training objective.

Examples:

- Build muscle
- Lose fat
- Improve strength
- General fitness

---

## Step 3

Determine weekly frequency.

Example:

| Experience | Recommended Sessions |
|------------|----------------------|
| Beginner | 3 |
| Intermediate | 4–5 |
| Advanced | 5–6 |

---

## Step 4

Select optimal split.

Possible splits include:

- Full Body
- Upper / Lower
- Push Pull Legs
- Bro Split
- Hybrid Split

---

## Step 5

Select exercises.

Selection criteria:

- available equipment
- user experience
- movement balance
- exercise history
- injury restrictions

---

## Step 6

Determine weekly volume.

Based on:

- experience
- recovery
- goal
- consistency

---

## Step 7

Assign intensity.

Variables:

- sets
- repetitions
- RPE
- rest time
- tempo

---

## Step 8

Validate training program.

The validator checks:

- balanced muscle distribution
- sufficient recovery
- realistic duration
- exercise diversity

---

# 8. Exercise Selection Strategy

Exercises are categorized into:

## Compound

Examples:

- Squat
- Deadlift
- Bench Press
- Pull-up

---

## Isolation

Examples:

- Biceps Curl
- Lateral Raise
- Leg Extension

---

## Mobility

Examples:

- Hip Mobility
- Shoulder Mobility
- Dynamic Stretching

---

## Core

Examples:

- Plank
- Hanging Leg Raise
- Cable Crunch

---

# 9. Progressive Overload

Supported strategies:

### Linear

Increase weight gradually.

---

### Double Progression

Increase repetitions first.

Increase weight after reaching the upper repetition range.

---

### Volume Progression

Increase total sets.

---

### Intensity Progression

Increase load while maintaining volume.

---

The strategy depends on user experience and training goal.

---

# 10. Volume Planning

The engine estimates weekly volume per muscle group.

Example:

| Muscle Group | Weekly Sets |
|--------------|------------:|
| Chest | 12–18 |
| Back | 14–20 |
| Shoulders | 10–16 |
| Quadriceps | 12–18 |
| Hamstrings | 10–14 |
| Biceps | 8–14 |
| Triceps | 8–14 |

These ranges are adjusted according to:

- recovery
- experience
- available frequency

---

# 11. Training Program Regeneration

A Training Program is designed to remain active for a predefined duration (typically 4–8 weeks).

The Workout Engine does not modify an active Training Program on a daily basis.

Instead, daily adaptations are handled by the Decision Engine, while the Workout Engine generates a new Training Program only when regeneration is required.

---

## Regeneration Triggers

A new Training Program may be generated when one or more of the following conditions are met:

- program duration completed
- long-term plateau detected
- major goal change
- significant fitness progression
- equipment availability changes
- medical restriction changes
- manual regeneration requested by the user

---

## Daily Adaptation vs Program Regeneration

Daily adjustments do **not** regenerate the Training Program.

Examples of daily adaptations include:

- reducing training volume
- lowering intensity
- replacing an exercise temporarily
- converting a session into a recovery session
- scheduling a rest day

These short-term adaptations are performed by the Decision Engine while preserving the current Training Program.

---

## Regeneration Outcome

When regeneration occurs, the Workout Engine creates:

- a new Training Program
- an updated Weekly Workout Plan
- revised progression parameters
- optimized exercise selection

The previous Training Program is preserved for historical analysis.
---

# 12. Exercise Replacement

Replacement occurs when:

- equipment unavailable
- injury restriction
- repeated exercise fatigue
- user preference

Replacement rules:

- same movement pattern
- same primary muscle
- similar difficulty
- equivalent equipment if possible

---

# 13. Safety Rules

The engine must never:

- exceed safe weekly volume
- overload beginners
- ignore recovery constraints
- create impossible schedules

Safety always overrides optimization.

---

# 14. Interaction with Other Engines

The Workout Engine receives information from:

- Recovery Engine
- Progress Engine

Its output is consumed by:

- Decision Engine

The Workout Engine never communicates directly with other engines.

---

# 15. Performance Requirements

Training Program generation should:

- complete in under 500 ms
- require no internet connection
- produce deterministic results
- support instant regeneration

---

# 16. Testing Strategy

The engine is validated using deterministic scenarios.

Example:

Input:

- Beginner
- Goal: Build Muscle
- 3 sessions/week
- Dumbbells only

Expected Output:

- Full Body split
- Moderate volume
- Compound-focused routine
- Progressive overload enabled

---

# 17. Future Enhancements

Planned improvements include:

- autoregulation using RPE history
- wearable-informed intensity adjustments
- machine learning assisted exercise ranking
- adaptive periodization
- exercise recommendation based on enjoyment
- fatigue-aware exercise ordering

---

# 18. Design Principles

The Workout Engine follows these principles:

- deterministic generation
- scientific training principles
- progressive overload
- balanced development
- recovery-aware planning
- modular design

---

# 19. Final Principle

> A training program is not a collection of workouts. It is a structured multi-week strategy composed of a reusable weekly workout plan that evolves over time according to the user's progress and recovery.

It is a structured training strategy designed to move the user toward a long-term objective while respecting recovery, consistency and progressive adaptation.

# Current Implementation Status

The Workout Engine is the most mature intelligence module in GymGenius.

Already implemented capabilities include:

- AI-powered routine generation
- Routine validation
- Full routine regeneration
- Single-day regeneration
- Exercise swapping
- Routine expiration management
- Progressive overload support
- Split generation (PPL, Upper/Lower, Full Body...)
- Equipment-aware exercise selection
- Goal-based programming
- Workout logging integration

Future versions will extend this engine with:

- Periodization
- Fatigue-aware programming
- Automatic deload planning
- Recovery-driven volume adjustments
- Decision Engine integration