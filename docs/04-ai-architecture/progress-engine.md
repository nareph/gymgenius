# Progress Engine

Version: 3.0

---

# Overview

The Progress Engine is responsible for analyzing the user's historical data to determine whether they are progressing toward their fitness goals.

Unlike the Workout Engine, which creates training plans, the Progress Engine evaluates the effectiveness of those plans over time.

Its mission is to answer one question:

> **"Is the user moving in the right direction?"**

The engine continuously monitors body metrics, workout performance, consistency, and long-term trends.

Its outputs are consumed primarily by the Decision Engine.

---

# Responsibilities

The Progress Engine is responsible for:

- tracking body weight trends
- measuring strength progression
- evaluating workout consistency
- detecting plateaus
- detecting regressions
- monitoring training volume evolution
- calculating adherence
- generating performance indicators
- providing historical insights to the Decision Engine

The engine never modifies routines directly.

---

# Position in the Architecture

```text
Workout Logs
Weight Logs
Recovery Logs
Nutrition Logs
        │
        ▼
Progress Engine
        │
        ▼
Decision Engine
        │
        ▼
AI Coach
```

---

# Inputs

The engine aggregates historical data from multiple sources.

## Workout History

Includes:

- completed workouts
- skipped workouts
- exercise performance
- repetitions
- weights
- workout duration
- estimated workload

---

## Body Metrics

Includes:

- body weight
- BMI
- body fat (future)
- lean mass (future)
- body measurements (future)

---

## Recovery History

Includes:

- recovery scores
- sleep duration
- fatigue history
- soreness trends

---

## Nutrition History

Includes:

- calorie adherence
- protein intake
- hydration
- meal consistency

---

# Outputs

The Progress Engine generates structured analytical data.

Example:

```json
{
  "progress_status": "steady_progress",
  "weight_trend": "+0.4kg",
  "strength_trend": "+5%",
  "consistency_score": 91,
  "plateau_detected": false,
  "recommendation": "continue_current_program"
}
```

No natural language is generated.

---

# Core Modules

The engine is divided into specialized analytical modules.

---

## Weight Trend Analyzer

Evaluates long-term body weight evolution.

Metrics include:

- weekly average
- monthly average
- moving average
- trend direction
- rate of change

Possible outputs:

- gaining
- losing
- stable
- fluctuating

---

## Strength Analyzer

Measures improvements in performance.

Tracks:

- estimated 1RM
- working weights
- repetitions
- training volume
- personal records

Possible outputs:

- improving
- plateau
- regression

---

## Volume Analyzer

Computes total workload.

Metrics:

- weekly sets
- repetitions
- total lifted weight
- session duration
- muscle-specific volume

Example:

Chest

Week 1:

14 sets

Week 4:

18 sets

Progress:

+28%

---

## Consistency Analyzer

Measures adherence to the training plan.

Metrics:

- completed workouts
- skipped workouts
- late sessions
- weekly adherence
- monthly adherence

Example:

```text
Scheduled Workouts: 20

Completed: 18

Consistency Score:

90%
```

---

## Goal Tracking

Evaluates progress toward the user's objective.

Examples:

Muscle Gain

- body weight
- strength
- training volume

Fat Loss

- weight trend
- waist reduction (future)
- adherence

General Fitness

- consistency
- activity
- recovery

---

## Plateau Detection

One of the most important modules.

A plateau may be detected when:

- strength remains unchanged
- weight remains unchanged
- workout performance stagnates
- recovery remains normal

for several consecutive weeks.

Example:

Bench Press

Week 1:

80 kg

Week 2:

80 kg

Week 3:

80 kg

↓

Plateau detected.

---

## Regression Detection

Detects negative trends.

Examples:

- decreasing strength
- decreasing adherence
- increasing fatigue
- unexpected weight loss
- reduced workout frequency

Regression is reported to the Decision Engine.

---

# Progress Workflow

```text
Historical Data
        │
        ▼
Weight Analysis
        │
        ▼
Strength Analysis
        │
        ▼
Consistency Analysis
        │
        ▼
Trend Detection
        │
        ▼
Progress Report
        │
        ▼
Decision Engine
```

---

# Progress Indicators

The engine computes several high-level indicators.

## Consistency Score

Measures training adherence.

Range:

0–100

---

## Strength Progress Index (SPI)

Measures strength improvements across compound movements.

Higher values indicate positive progression.

---

## Weight Progress Index (WPI)

Evaluates body weight evolution against the user's goal.

Example:

Goal:

Gain Muscle

Expected:

+0.25 kg/week

Actual:

+0.22 kg/week

Status:

On Target

---

## Volume Progress Index (VPI)

Measures workload evolution.

Considers:

- sets
- repetitions
- load
- frequency

---

## Recovery Stability Index (RSI)

Evaluates whether recovery remains stable during progression.

A stable recovery indicates sustainable progress.

---

# Interaction with Other Engines

## Workout Engine

Provides workout history and exercise performance.

---

## Nutrition Engine

Provides nutritional adherence.

---

## Recovery Engine

Provides fatigue and recovery history.

---

## Decision Engine

Consumes all analytical indicators to decide whether the user's program should change.

Example:

Progress Engine:

Plateau detected.

↓

Decision Engine:

Increase weekly training volume.

---

# AI Enhancement Layer

The Progress Engine performs all calculations locally.

Cloud AI never computes progress metrics.

Instead, AI may generate:

- progress summaries
- motivational insights
- simplified explanations
- weekly reports

Example:

Structured Output:

```json
{
  "plateau": true,
  "strength_change": 0
}
```

AI Explanation:

> "Your strength has remained stable for three consecutive weeks. A small increase in training volume may help stimulate further progress."

If cloud AI is unavailable, Local AI generates a simplified explanation.

---

# Explainability

Every analytical conclusion must be traceable.

Example:

Plateau detected.

Reason:

No measurable improvement in squat performance over the last four weeks.

---

# Performance Goals

Target execution time:

Weight analysis:

< 10 ms

Strength analysis:

< 15 ms

Trend detection:

< 20 ms

Consistency calculation:

< 5 ms

Complete Progress Engine:

< 75 ms

---

# Future Extensions

Future versions may include:

- body composition analysis
- muscle gain estimation
- fatigue forecasting
- predictive plateau detection
- machine learning trend prediction
- wearable analytics
- advanced visual dashboards
- long-term health scoring

---

# Design Principles

The Progress Engine must always be:

- deterministic
- objective
- explainable
- trend-oriented
- evidence-based
- offline-first
- extensible

Historical data should never be interpreted without context.

---

# Final Principle

> **The Progress Engine does not decide what the user should do next. It measures what has happened, identifies meaningful trends, and provides objective evidence that enables the Decision Engine to make informed recommendations.**