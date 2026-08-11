# Recovery Engine

**Version:** 3.4 (Phase 4 vertical slice)  
**Status:** Implemented (check-in based readiness)  
**Layer:** Domain Intelligence Engine

---

# Phase 4 Scope (v3.4)

Phase 4 delivers a **deterministic, offline-first** recovery vertical slice:

1. Daily Check-in (sleep hours, soreness, energy, mood)
2. RecoveryEngine scorers → `RecoveryStatus`
3. Hive persistence (`recovery_statuses`, `daily_checkins`)
4. `RecoveryRule` → volume reduction via Decision Engine
5. Home Recovery card + Recovery / Check-in screens

## Decision policy (single source of truth)

Thresholds live in `RecoveryThresholds` and are shared by
`ReadinessCalculator` and `RecoveryRule`:

| Readiness | Volume multiplier | Meaning |
|-----------|-------------------|---------|
| ≥ 80 | 1.00 | Full volume |
| ≥ 60 | 0.85 | –15 % |
| ≥ 40 | 0.70 | –30 % |
| < 40 | 0.55 | –45 % |

Phase 4 **never forces a rest day**. `RecommendedIntensity.rest` is
informational for the UI only. Volume is applied by reducing **sets**
on today's final exercises (minimum 1 set per exercise).

## Scorer formulas

- **SleepScorer**: maps sleep hours → [0,100] (optimal window 7–9 h)
- **FatigueEstimator**: 60 % soreness + 40 % energy penalty → [0,100]
- **ReadinessCalculator**: 50 % sleep + 40 % (100 − fatigue) + 10 % mood

## Explicit Phase 4 limits

Not included yet (documented for later phases):

- Workout history / accumulated training load
- Muscle-group fatigue map
- Recovery trends over days
- Sleep quality / stress as separate scored inputs
- HRV / wearables / Health Connect

The sections below describe the **long-term target architecture**.
Phase 4 implements the check-in → readiness → volume-adaptation path only.

---

# 1. Purpose

The Recovery Engine evaluates the user's physical readiness and recovery status.

Its responsibility is to estimate how prepared the user's body is for training and to provide structured recovery metrics to the Decision Engine.

Unlike the AI Coach, the Recovery Engine is fully deterministic and rule-based.

It never generates natural language. It produces structured recovery data.

---

# 2. Objectives

The Recovery Engine must answer one question:

> **"How ready is the user's body to perform today?"**

To answer this, it continuously analyzes multiple recovery indicators.

---

# 3. Responsibilities

The Recovery Engine is responsible for:

- Calculating the Recovery Score
- Estimating physical readiness
- Detecting accumulated fatigue
- Identifying recovery trends
- Suggesting recovery actions
- Providing structured recovery data to the Decision Engine

It does **not** modify workout plans directly.

---

# 4. Recovery Inputs

The engine combines multiple sources of information.

## User Inputs

- Sleep duration
- Sleep quality
- Muscle soreness
- Energy level
- Mood
- Stress level

---

## Workout History

- Last workout date
- Training frequency
- Weekly training volume
- Muscle groups trained
- Consecutive training days

---

## Progress Data

- Recent performance
- Personal records
- Plateau detection
- Training consistency

---

## Future Integrations

- Heart Rate
- Resting Heart Rate
- Heart Rate Variability (HRV)
- Smart Watches
- Garmin
- Apple Health
- Google Fit
- Wearable sensors

---

# 5. Recovery Score

The Recovery Score is the primary output.

Range:

```text
0 — 100
```

Suggested interpretation:

| Score | Status | Recommendation |
|--------|--------|----------------|
| 90–100 | Fully Recovered | High intensity |
| 75–89 | Good Recovery | Normal training |
| 60–74 | Moderate Recovery | Slight volume reduction |
| 40–59 | Poor Recovery | Recovery session |
| 0–39 | Critical | Rest day |

---

# 6. Recovery Components

The score is calculated from several independent components.

Example:

| Component | Weight |
|-----------|---------|
| Sleep | 35% |
| Fatigue | 25% |
| Muscle Soreness | 15% |
| Training Load | 15% |
| Stress | 10% |

Weights are configurable.

---

# 7. Fatigue Estimation

The engine estimates accumulated fatigue using:

- Recent training volume
- Consecutive sessions
- Muscle overlap
- Recovery history
- Missed recovery days

Example:

```text
Chest: 82%

Back: 61%

Legs: 47%

Shoulders: 73%
```

This allows the Workout Engine to avoid overloading fatigued muscle groups.

---

# 8. Readiness Classification

Recovery status is translated into readiness levels.

| Recovery Score | Readiness |
|----------------|-----------|
| 90+ | Excellent |
| 75–89 | Good |
| 60–74 | Moderate |
| 40–59 | Low |
| Below 40 | Very Low |

---

# 9. Trend Analysis

Recovery is evaluated over time rather than in isolation.

The engine detects:

- Improving recovery
- Stable recovery
- Declining recovery
- Chronic fatigue
- Recovery after deload

These trends help the Decision Engine adapt long-term recommendations.

---

# 10. Outputs

The engine produces structured data.

Example:

```json
{
  "recoveryScore": 81,
  "readiness": "good",
  "fatigueLevel": "moderate",
  "recommendedTrainingIntensity": "normal",
  "recommendedVolumeAdjustment": -10,
  "requiresDeload": false
}
```

---

# 11. Interaction with Other Engines

The Recovery Engine communicates only through the Decision Engine.

```text
Workout Engine
        │
        │
Progress Engine
        │
        ▼
Recovery Engine
        │
        ▼
Decision Engine
```

The Recovery Engine never calls another engine directly.

---

# 12. Decision Examples

Example 1

Recovery Score:

95

↓

Decision:

```text
Increase training intensity
```

---

Example 2

Recovery Score:

42

↓

Decision:

```text
Reduce training volume
```

---

Example 3

Recovery Score:

25

↓

Decision:

```text
Recommend complete rest day
```

---

# 13. Explainability

Every recovery recommendation must be explainable.

Example:

```text
Recovery Score: 58

Reason:

• Sleep duration decreased for three consecutive nights.

• Training volume increased by 18%.

• High soreness reported for lower body.
```

The Recovery Engine provides structured explanations.

The AI Coach converts them into natural language.

---

# 14. Future Enhancements

Future versions may include:

- HRV-based recovery
- Resting Heart Rate analysis
- Sleep stage analysis
- Wearable integration
- Illness detection
- Injury risk estimation
- AI-assisted recovery predictions

---

# 15. Design Principles

The Recovery Engine follows five principles.

## Deterministic

Recovery calculations must be reproducible.

---

## Explainable

Every score must be traceable.

---

## Modular

The engine operates independently.

---

## Extensible

New recovery indicators can be added without changing the engine architecture.

---

## Local First

Recovery calculations always work offline.

Cloud AI may explain recovery but never calculate it.

---

# 16. Long-Term Vision

The Recovery Engine evolves from a simple readiness calculator into a comprehensive physiological monitoring system.

Combined with the Workout Engine, Progress Engine, Nutrition Engine and Decision Engine, it enables GymGenius to adapt training based on the user's actual physical condition rather than static workout plans.

---

# Final Principle

> **Train according to your body's readiness, not according to the calendar.**