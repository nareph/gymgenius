# Nutrition Engine

Version: 3.0

---

# Overview

The Nutrition Engine is responsible for transforming user health data into structured nutritional recommendations.

Its mission is not to generate random meal plans.

Instead, it answers one question:

> **"What should this user eat today to support their current health objective?"**

The engine operates entirely offline using deterministic rules.

Cloud AI can optionally improve meal personalization and explanations but never replaces the core calculations.

---

# Responsibilities

The Nutrition Engine is responsible for:

- estimating daily calorie requirements
- calculating macronutrient targets
- adapting nutrition to training days
- adapting nutrition to recovery status
- generating meal structures
- suggesting locally available foods
- tracking nutritional adherence
- preparing structured outputs for the Decision Engine

It never makes autonomous decisions outside its domain.

---

# Position in the Architecture

```text
User Profile
        │
        ▼
Workout Engine
        │
Recovery Engine
        │
Progress Engine
        │
        ▼
Nutrition Engine
        │
        ▼
Decision Engine
        │
        ▼
AI Coach
```

---

# Inputs

The Nutrition Engine combines information from multiple sources.

## User Profile

- age
- sex
- height
- weight
- goal
- activity level
- dietary preferences
- allergies
- country
- available budget

---

## Workout Information

Provided by the Workout Engine.

Includes:

- training day
- workout duration
- estimated energy expenditure
- training intensity
- muscle groups trained

---

## Recovery Information

Provided by the Recovery Engine.

Includes:

- recovery score
- fatigue level
- soreness
- sleep quality

---

## Progress Information

Provided by the Progress Engine.

Includes:

- weight trend
- body composition trend
- adherence
- weekly progress

---

# Outputs

The engine produces structured nutritional recommendations.

Example:

```json
{
  "daily_calories": 2850,
  "protein_g": 165,
  "carbohydrates_g": 340,
  "fat_g": 75,
  "hydration_l": 3.2,
  "meal_plan": [],
  "nutrition_status": "on_target"
}
```

No natural language is generated.

---

# Core Modules

The Nutrition Engine is divided into independent modules.

## Calorie Estimator

Computes daily energy needs.

Inputs:

- BMR
- activity multiplier
- workout expenditure
- goal

Outputs:

- maintenance calories
- target calories

---

## Macronutrient Calculator

Determines:

- protein
- carbohydrates
- fats

using evidence-based recommendations.

Example:

Protein:

1.6–2.2 g/kg for muscle gain

---

## Meal Planner

Distributes calories across meals.

Example:

Breakfast

↓

Lunch

↓

Snack

↓

Pre-workout

↓

Post-workout

↓

Dinner

Meal timing depends on training schedule.

---

## Local Food Mapper

Maps nutrients to foods available in the user's country.

Example

Country:

Cameroon

Protein options:

- Eggs
- Chicken
- Fish
- Beans
- Groundnuts

Carbohydrates:

- Rice
- Plantain
- Cassava
- Sweet potato
- Corn

Healthy fats:

- Avocado
- Groundnuts
- Palm oil (moderation)

The nutrition targets remain identical.

Only food suggestions change.

---

## Adherence Tracker

Measures how closely users follow recommendations.

Metrics include:

- calorie adherence
- protein adherence
- hydration consistency
- meal completion

---

# Nutrition Workflow

```text
User Data
      │
      ▼
Calorie Estimator
      │
      ▼
Macro Calculator
      │
      ▼
Meal Planner
      │
      ▼
Local Food Mapper
      │
      ▼
Structured Nutrition Plan
      │
      ▼
Decision Engine
```

---

# Scientific Principles

The Nutrition Engine follows established sports nutrition principles.

Including:

- energy balance
- progressive nutrition
- protein optimization
- nutrient timing
- hydration
- recovery nutrition

No recommendation should violate established nutritional science.

---

# Interaction with Other Engines

## Workout Engine

Provides:

- training volume
- workout intensity
- calorie expenditure

---

## Recovery Engine

May recommend:

- increasing carbohydrates
- increasing hydration
- electrolyte support
- recovery meals

---

## Progress Engine

May trigger:

- calorie increase
- calorie reduction
- macro adjustment

based on long-term trends.

---

## Decision Engine

The Decision Engine validates all nutritional outputs before presenting them to the user.

Example:

Nutrition Engine:

3200 kcal

Decision Engine:

Reduce to 3000 kcal because recovery is poor and activity decreased this week.

---

# AI Enhancement Layer

The Nutrition Engine always computes deterministic nutrition first.

Afterwards, the AI layer may improve presentation depending on the selected AI Quality Mode.

## Local Mode

Generates:

- simple meal suggestions
- basic food substitutions
- offline explanations

No internet connection required.

---

## Enhanced Mode (Cloud AI)

If a cloud AI provider is available, it may enrich the structured nutrition plan with:

- personalized recipes
- culturally relevant meal ideas
- ingredient substitutions
- shopping suggestions
- cooking tips
- motivational coaching

The structured nutritional targets remain unchanged.

If the cloud request fails, GymGenius continues using the deterministic nutrition plan and Local AI explanations.

---

# Explainability

Every recommendation should include its reason.

Example:

Increase protein intake.

Reason:

Training volume increased by 18% over the previous two weeks.

---

# Performance Goals

Target execution time:

- Calorie estimation < 5 ms
- Macro calculation < 2 ms
- Meal generation < 20 ms
- Food mapping < 30 ms

Entire Nutrition Engine:

< 75 ms

---

# Future Extensions

Future versions may include:

- barcode scanning
- nutrition label recognition
- AI recipe generation
- grocery planning
- fasting protocols
- micronutrient tracking
- supplement recommendations
- restaurant meal estimation

---

# Design Principles

The Nutrition Engine must always be:

- deterministic
- explainable
- modular
- evidence-based
- offline-first
- country-aware
- extensible

Cloud AI enhances personalization but never replaces nutritional calculations.

---

# Final Principle

> **The Nutrition Engine does not decide what sounds healthy. It computes what is nutritionally appropriate based on the user's goals, physiology, training, recovery, and progress, then adapts food recommendations to the user's local environment.**