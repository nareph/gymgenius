# GymGenius v3

# User Journey

**Version:** 3.0

---

# 1. Overview

The GymGenius user journey describes how a user evolves from onboarding into a continuously adaptive, data-driven fitness experience.

Rather than following a static training plan, the user follows a **Training Program** that evolves over time through weekly evaluations and intelligent adaptations.

The journey is cyclical, adaptive, and personalized.

---

# 2. Terminology

GymGenius uses the following planning hierarchy throughout the application.

| Term | Definition |
|------|------------|
| **Training Program** | A complete multi-week training strategy (typically 4–8 weeks). |
| **Weekly Workout** | One week of scheduled workouts within the Training Program. |
| **Workout Day** | The exercises planned for a specific training day. |
| **Workout Session** | The workout actually completed by the user. |
| **Exercise Log** | The recorded performance of an exercise during a Workout Session. |

---

# 3. Core Journey Philosophy

GymGenius does not treat users as static profiles.

Instead, it continuously learns from user behavior through three principles.

## Continuous Adaptation

Every interaction improves the system's understanding of the user.

---

## Feedback-Driven Decisions

Every Workout Session, weight entry, sleep log and recovery report influences future recommendations.

---

## Minimal User Effort

The user only provides essential information.

Typical daily inputs include:

- body weight
- sleep duration
- recovery feeling
- workout completion

Everything else is inferred automatically.

---

# 4. Global User Lifecycle

The GymGenius experience is divided into five major phases.

---

# Phase 1 — Onboarding

## Objective

Create the initial user model.

### Steps

1. Create account
2. Complete onboarding

   - age
   - height
   - weight
   - goal
   - experience
   - available equipment
   - preferred training days

3. Generate the initial Training Program
4. Generate the first Weekly Workout

---

### System Output

- personalized Training Program
- first Weekly Workout
- nutrition baseline
- recovery baseline

---

# Phase 2 — First Training Cycle

## Objective

Validate initial assumptions using real user behavior.

### Steps

1. User completes Workout Sessions
2. Exercise Logs are recorded
3. Adherence is measured
4. Recovery Engine begins calibration

---

### System Behavior

The system gradually learns:

- exercise preferences
- recovery speed
- workload tolerance
- consistency level

---

# Phase 3 — Daily Adaptive Loop

## Objective

Deliver the best recommendation for today.

---

### Daily Flow

1. User opens the application
2. User records:

   - body weight
   - sleep
   - recovery feeling
   - energy level

3. Recovery Engine evaluates readiness
4. Progress Engine updates trends
5. Decision Engine determines today's recommendation
6. Workout Engine prepares today's Workout Day
7. AI Coach explains today's plan

---

### Daily Outputs

- today's Workout Day
- nutrition recommendations
- recovery guidance
- coaching explanation

---

# Phase 4 — Weekly Evaluation Cycle

## Objective

Evaluate the effectiveness of the current Weekly Workout.

---

### Weekly Flow

Every seven days the system evaluates:

- workout adherence
- strength progression
- body weight trend
- fatigue accumulation
- recovery quality

The Decision Engine then determines whether to:

- keep the current Weekly Workout
- adapt the Weekly Workout
- recommend additional recovery
- modify nutrition targets

---

### Weekly Outputs

- weekly performance report
- adaptation summary
- next week's Weekly Workout

---

# Phase 5 — Training Program Evolution

## Objective

Continuously optimize long-term progression.

A Training Program is not regenerated every week.

Instead, GymGenius continuously evaluates whether the current program remains effective.

---

### Evaluation Process

The system analyzes:

- multiple Weekly Workouts
- long-term progression
- adherence history
- plateau detection
- recovery trends

---

### Possible Decisions

The Decision Engine may decide to:

- maintain the current Training Program
- regenerate only the next Weekly Workout
- modify exercise selection
- adjust training volume
- change intensity progression
- generate an entirely new Training Program

---

### Result

The user always follows the most appropriate long-term strategy without unnecessary changes.

---

# 5. Daily User Flow

---

## Morning

1. Open GymGenius
2. Record weight
3. Record sleep
4. Record recovery
5. Receive today's Workout Day

---

## During Training

1. Start Workout Session
2. Follow today's Workout Day
3. Record Exercise Logs
4. Complete Workout Session

---

## After Training

1. Save Workout Session
2. Update Progress Engine
3. Update Recovery Engine
4. Update Decision Engine

---

## Evening (Optional)

The user may review:

- today's summary
- estimated calories burned
- muscle groups trained
- recovery estimation

---

# 6. Continuous Adaptation Loop

## Inputs

- Workout Sessions
- Exercise Logs
- body weight
- sleep
- recovery
- missed workouts

---

## Decision Engines

- Recovery Engine
- Workout Engine
- Nutrition Engine
- Progress Engine

↓

Decision Engine

↓

AI Coach

---

## Outputs

- Weekly Workout adaptations
- nutrition adjustments
- exercise substitutions
- recovery recommendations
- progressive overload updates

---

# 7. Adaptive Intelligence Flow

```text
User Data
      ↓
Workout Sessions
      ↓
Domain Engines
      ↓
Decision Engine
      ↓
Workout Engine
      ↓
Today's Workout Day
      ↓
AI Coach
      ↓
User Action
      ↓
New Data
```

---

# 8. User Maturity Levels

## Beginner

(0–4 weeks)

- maximum guidance
- conservative progression
- high automation

---

## Intermediate

(1–6 months)

- adaptive Weekly Workouts
- progressive overload
- personalized optimization

---

## Advanced

(6+ months)

- precision adaptations
- plateau management
- high personalization
- advanced analytics

---

# 9. Key Experience Moments

## First Workout Session

The user successfully completes the first Workout Session, establishing confidence in the system.

---

## First Weekly Adaptation

The system intelligently adapts the Weekly Workout based on real user performance.

---

## First Plateau Detection

The Decision Engine detects stagnation and adjusts strategy.

---

## First Recovery Intervention

The system proactively reduces training load to prevent overtraining.

---

# 10. Retention Strategy

GymGenius improves long-term adherence by:

- reducing decision fatigue
- adapting progressively
- avoiding overtraining
- clearly showing progress
- celebrating small improvements

---

# 11. Long-Term Outcome

Over months of use, GymGenius gradually learns the user's physiology and behavior.

The system becomes increasingly capable of:

- predicting fatigue
- anticipating plateaus
- optimizing Training Programs
- improving Weekly Workouts
- maximizing long-term consistency

---

# Final Principle

> The user does not adapt to the application.

> The application continuously adapts the Training Program and Weekly Workouts to the user.