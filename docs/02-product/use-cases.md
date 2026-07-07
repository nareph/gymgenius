# GymGenius v3

# Use Cases

**Version:** 3.0

---

# 1. Overview

This document defines the primary business use cases of GymGenius v3.

Each use case represents a real-world scenario in which the system transforms user data into personalized health and fitness decisions.

GymGenius does not simply execute user commands—it continuously evaluates the user's state and determines the most appropriate action.

---

# 2. Terminology

To ensure consistency across the entire architecture, GymGenius uses the following terminology.

| Term | Definition |
|------|------------|
| **Training Program** | A complete multi-week training program (typically 4–8 weeks). |
| **Weekly Workout** | The workout schedule for one week inside a Training Program. |
| **Workout Day** | The planned exercises for a specific day of the Weekly Workout. |
| **Workout Session** | The actual workout completed and logged by the user. |
| **Exercise Log** | The recorded performance of one exercise during a Workout Session. |

The Decision Engine continuously evaluates whether to maintain, adapt or regenerate these planning levels.

---

# 3. Core Design Principle

> GymGenius does not respond to user requests—it responds to user states.

Every use case represents a transition from one health state to another.

---

# 4. Primary Use Cases

---

# UC-01 — Daily Workout Planning

## Actor

User

---

## Trigger

User opens the application.

---

## Preconditions

- user profile exists
- active Training Program exists
- current Weekly Workout is available
- recovery data is available

---

## Main Flow

1. Collect latest user data
2. Recovery Engine evaluates readiness
3. Workout Engine evaluates today's Workout Day
4. Decision Engine validates the recommendation
5. AI Coach explains today's plan
6. User receives today's workout

---

## Output

- Workout Day
- intensity recommendation
- coaching explanation

---

## Success Condition

User clearly understands today's training objectives.

---

# UC-02 — Workout Logging

## Actor

User

---

## Trigger

User completes a Workout Session.

---

## Main Flow

1. User logs completed exercises
2. Workout Session stored locally
3. Exercise Logs recorded
4. Progress Engine updates metrics
5. Recovery Engine recalculates fatigue
6. Decision Engine updates adaptation state

---

## Output

- updated progress
- updated recovery
- adaptation signal

---

## Success Condition

The system learns from actual user performance.

---

# UC-03 — Recovery-Based Adaptation

## Actor

System

---

## Trigger

Recovery score falls below threshold.

---

## Main Flow

1. Recovery Engine computes readiness
2. Decision Engine evaluates risk
3. Workout Engine adapts today's Workout Day
4. AI Coach explains the adaptation

---

## Output

- reduced intensity
- additional recovery guidance

---

## Success Condition

Overtraining risk is minimized.

---

# UC-04 — Nutrition Recommendation

## Actor

User / System

---

## Trigger

Daily evaluation or post-workout analysis.

---

## Main Flow

1. Nutrition Engine calculates calorie target
2. Macronutrients calculated
3. Local food database consulted
4. Decision Engine validates recommendations
5. AI Coach explains nutrition strategy

---

## Output

- calorie target
- macro distribution
- meal suggestions

---

## Success Condition

User receives realistic nutrition guidance.

---

# UC-05 — Weekly Progress Analysis

## Actor

System

---

## Trigger

Weekly evaluation cycle.

---

## Main Flow

1. Progress Engine analyzes the week's data
2. Evaluate:

   - body weight
   - strength
   - consistency
   - recovery

3. Classify progress

   - progressing
   - plateau
   - regression

4. Decision Engine updates strategy

---

## Output

- weekly report
- adaptation recommendations

---

## Success Condition

The system continuously improves future recommendations.

---

# UC-06 — Plateau Detection

## Actor

System

---

## Trigger

No measurable progress across multiple evaluation cycles.

---

## Main Flow

1. Detect plateau
2. Analyze recovery history
3. Evaluate current Weekly Workout
4. Adjust exercise selection, volume or intensity
5. Update nutrition if necessary
6. Decision Engine validates changes

---

## Output

- adapted Weekly Workout
- updated nutrition strategy

---

## Success Condition

Training progression resumes.

---

# UC-07 — Regression Management

## Actor

System

---

## Trigger

Performance regression combined with poor recovery.

---

## Main Flow

1. Detect regression
2. Prioritize recovery
3. Reduce training load
4. Adjust nutritional targets
5. Recommend additional recovery

---

## Output

- temporary deload strategy
- recovery-first recommendation

---

## Success Condition

User safely returns to positive progression.

---

# UC-08 — Weekly Workout Adaptation

## Actor

Decision Engine

---

## Trigger

Weekly evaluation completed.

---

## Main Flow

1. Analyze Training Program
2. Evaluate current Weekly Workout
3. Analyze adherence
4. Analyze recovery
5. Analyze progression
6. Decide whether to:

   - maintain the current Weekly Workout
   - adapt the Weekly Workout
   - generate a new Training Program (when necessary)

---

## Output

- maintained Weekly Workout

or

- adapted Weekly Workout

or

- new Training Program

---

## Success Condition

Training remains continuously optimized while minimizing unnecessary changes.

---

# UC-09 — Onboarding & Training Program Creation

## Actor

User

---

## Trigger

First application launch.

---

## Main Flow

1. User completes onboarding
2. System estimates baseline metrics
3. Initial Training Program generated
4. Initial Weekly Workout created
5. Nutrition baseline calculated
6. Recovery baseline established

---

## Output

- personalized Training Program
- first Weekly Workout

---

## Success Condition

User is immediately ready to begin training.

---

# UC-10 — Daily Health Decision

## Actor

Decision Engine

---

## Trigger

Daily evaluation cycle.

---

## Main Flow

1. Collect engine outputs
2. Resolve conflicts
3. Determine optimal daily action
4. Send structured recommendation to AI Coach

---

## Output

- unified daily recommendation

---

## Success Condition

The user receives one clear and consistent recommendation.

---

# 5. Secondary Use Cases

---

## UC-11 — Missed Workout Handling

Automatically adapt future Workout Days after missed sessions.

---

## UC-12 — Fatigue Spike Detection

Reduce workload before overtraining occurs.

---

## UC-13 — Weight Trend Adaptation

Adjust nutritional targets according to long-term body weight trends.

---

## UC-14 — Motivation Reinforcement

Generate personalized coaching messages based on recent progress.

---

# 6. Edge Cases

---

## EC-01 — Insufficient Data

Generate a conservative recommendation using available information.

---

## EC-02 — Conflicting Signals

Decision Engine resolves priorities:

Recovery → Safety → Progress → Optimization

---

## EC-03 — Low Adherence

Simplify the Training Program instead of increasing complexity.

---

# 7. System Behavior Principle

> GymGenius always prefers safe adaptation over aggressive progression.

Meaning:

- reduce load before increasing it
- preserve consistency before maximizing intensity
- prioritize long-term adherence over short-term performance

---

# 8. Final Principle

GymGenius use cases are not feature-oriented.

They represent **adaptive decision loops** driven by deterministic engines and continuously refined using user data.