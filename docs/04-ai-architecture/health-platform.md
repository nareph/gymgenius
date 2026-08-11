# Health Platform

Version: 5.0

---

# Overview

Phase 8 expands GymGenius beyond training into **manual health & lifestyle
tracking**. Engines are deterministic and informational.

> **Never a medical or psychological diagnosis.**

Manual entry only in v5.0 — no Health Connect / wearables.

---

# Modules

| Module | Engine | Notes |
|--------|--------|-------|
| Blood pressure | `BloodPressureEngine` | Categories + caution messages |
| Blood glucose | `BloodGlucoseEngine` | Internal **mmol/L**; display mg/dL |
| Hydration | `HydrationEngine` | Target ~30 ml/kg, +300 training day |
| Mental wellness | `MentalWellnessEngine` | Separate from Recovery `DailyCheckIn` |
| Habits | `HabitEngine` | Streaks + completion % |
| Lifestyle | `LifestyleEngine` | Aggregate recommendations |

Facade: [`HealthPlatformEngine`](../../lib/engines/health_platform/health_platform_engine.dart)
→ `HealthPlatformSnapshot`.

---

# Architecture

```text
Manual UI
   → HealthPlatformRepository (Hive TypeIds 18–23)
   → Sub-engines + HealthPlatformEngine
   → HealthPlatformSnapshot
        → Tracking / HealthDashboard
        → DecisionEngine (HealthPlatformRule observe-only)
        → CoachContext (safe labels only)
```

---

# Decision Engine

`HealthPlatformRule` is **observe-only** (same pattern as `ProgressRule`).
It never mutates workouts. Snapshot is attached to `DailyPlan.healthPlatformSnapshot`.

---

# AI Coach privacy

Coach receives only aggregated safe fields:

- `hydrationPercent`, `habitsCompletionPercent`, `habitsStreakSummary`
- `wellnessTrend`, `hasBpCaution`, `hasGlucoseCaution`, `healthPlatformCaution`

**Never** raw systolic/diastolic/glucose mmol values in prompts.

---

# Persistence

| TypeId | Model |
|--------|--------|
| 18 | BloodPressureHiveModel |
| 19 | BloodGlucoseHiveModel |
| 20 | HydrationLogHiveModel |
| 21 | MentalWellnessHiveModel |
| 22 | HabitHiveModel |
| 23 | HabitLogHiveModel |

---

# Out of scope (v5.0)

- Health Connect / wearables / screen-time
- Advanced charts
- Full GDPR export tooling
- Heavy dedicated Health onboarding
- Mutating Nutrition / Recovery from Health Platform
