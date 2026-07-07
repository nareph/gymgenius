# Explainable AI

Version: 3.0

---

# Overview

GymGenius is designed around a fundamental principle:

> **Artificial Intelligence should explain decisions, not make them.**

Unlike many AI-powered fitness applications that rely on opaque language models, GymGenius separates decision-making from language generation.

All recommendations originate from deterministic engines.

Artificial Intelligence transforms those structured decisions into clear, human-readable explanations.

This architecture guarantees that recommendations remain:

- reproducible
- auditable
- scientifically grounded
- understandable

---

# Philosophy

Most AI fitness applications follow this workflow:

```text
User Data
      │
      ▼
Large Language Model
      │
      ▼
Recommendation
```

The reasoning process is hidden.

The same input may produce different outputs.

GymGenius intentionally avoids this architecture.

Instead, GymGenius follows:

```text
User Data
      │
      ▼
Domain Engines
      │
      ▼
Decision Engine
      │
      ▼
Structured Decision
      │
      ▼
AI Coach
      │
      ▼
Human Explanation
```

The AI never invents recommendations.

It only communicates them.

---

# Why Explainable AI?

Users should understand why recommendations change.

Examples:

Instead of:

> Train legs today.

GymGenius explains:

> Train legs today because your upper body session was completed yesterday, your recovery score is excellent, and your weekly lower-body volume is currently below the target.

Instead of:

> Eat more protein.

GymGenius explains:

> Protein intake has been increased because your training volume has increased by 18% over the past two weeks.

Every recommendation should be understandable.

---

# Core Principles

## Deterministic First

Business rules always execute before AI.

The engines compute:

- workout adjustments
- calorie targets
- recovery scores
- progression analysis

AI never replaces these calculations.

---

## Structured Before Natural Language

The Decision Engine produces structured outputs.

Example:

```json
{
  "action": "increase_training_volume",
  "reason": "consistent_progress",
  "confidence": 0.96
}
```

The AI converts this into:

> Your performance has improved consistently over recent weeks, so your training volume has been increased to continue stimulating progress.

---

## Traceability

Every recommendation must be traceable.

Users—and developers—should always be able to answer:

- What changed?
- Why?
- Which engine produced the recommendation?
- Which data were used?

Nothing should appear "magical."

---

## Transparency

GymGenius should clearly distinguish between:

- facts
- calculations
- recommendations
- AI explanations

Example:

Facts

- Weight: 82 kg
- Sleep: 8 hours
- Recovery: 91%

Decision

Increase workout intensity.

Explanation

Your recovery indicators suggest that your body is well prepared for a more challenging session today.

---

# Explainability Pipeline

```text
User Data
      │
      ▼
Workout Engine
Recovery Engine
Nutrition Engine
Progress Engine
      │
      ▼
Decision Engine
      │
      ▼
Structured Decision
      │
      ▼
AI Coach
      │
      ▼
Explanation
      │
      ▼
User Interface
```

---

# Explanation Levels

GymGenius supports multiple explanation depths.

---

## Level 1 — Summary

Displayed directly on the dashboard.

Example:

> Recovery is excellent. Today's workout intensity has been increased.

---

## Level 2 — Detailed Explanation

Visible when the user expands the recommendation.

Example:

Recovery score increased from 82 to 91.

Sleep duration improved.

No significant muscle soreness detected.

Training intensity has therefore been increased.

---

## Level 3 — Technical Details

Designed for advanced users.

Displays:

- engine outputs
- confidence values
- thresholds
- metrics
- contributing factors

Example:

```text
Recovery Score

91 / 100

Training Readiness

High

Weekly Volume

+12%

Decision

Increase intensity
```

---

# AI Quality Modes

Explainability adapts to the selected AI Quality Mode.

---

## Offline Mode

Uses Local AI only.

Produces:

- concise explanations
- deterministic summaries
- no internet dependency

Example:

> Your recovery is good. Today's workout intensity has been increased.

---

## Enhanced Mode

Uses a cloud AI provider when available.

The cloud model may improve:

- readability
- coaching style
- motivation
- educational content
- examples

The recommendation itself never changes.

Example:

> You've recovered very well since your last workout, and your recent performance trends indicate you're ready for a greater challenge. Increasing today's intensity should help maintain your progress while staying within a safe workload.

---

## Failure Handling

If a cloud AI request fails:

```text
Decision Engine
      │
      ▼
Local Explanation
      │
      ▼
Display Recommendation
```

The application never blocks the user.

No recommendation is lost.

Cloud AI is an enhancement—not a dependency.

---

# Confidence Levels

Every recommendation may include a confidence score.

Example:

```json
{
  "recommendation": "Increase Calories",
  "confidence": 0.94
}
```

Confidence is calculated by deterministic engines.

AI never invents confidence values.

---

# Educational Coaching

The AI Coach also helps users learn.

Example:

Recommendation:

Increase carbohydrates.

Educational Note:

Carbohydrates replenish muscle glycogen, helping improve performance during high-volume training.

Education should remain factual and evidence-based.

---

# Motivation

Motivational messages should always reflect reality.

Good example:

> You completed every scheduled workout this week. Great consistency!

Bad example:

> You're unstoppable!

GymGenius avoids exaggerated or misleading encouragement.

---

# Personalization

AI explanations should adapt to:

- fitness level
- preferred language
- coaching style
- health objective
- experience

Example

Beginner:

Use simple language.

Advanced athlete:

Include more technical details.

The underlying recommendation remains identical.

---

# Privacy

Explainability must respect user privacy.

No personal information is transmitted unless the user has enabled Enhanced Mode.

When cloud AI is used:

- only required data are transmitted
- unnecessary identifiers are removed
- structured data are preferred over raw history

---

# Developer Benefits

Explainable AI also improves development.

Advantages include:

- easier debugging
- deterministic testing
- reproducible recommendations
- easier model replacement
- simpler auditing

Developers can inspect structured decisions independently from AI-generated text.

---

# Future Enhancements

Future versions may include:

- visual decision trees
- recommendation timelines
- confidence breakdowns
- evidence references
- scientific citations
- interactive explanations
- conversational coaching

---

# Design Principles

The Explainable AI layer must always be:

- deterministic-aware
- transparent
- traceable
- educational
- trustworthy
- privacy-first
- offline-capable

It should simplify complex decisions without hiding the underlying reasoning.

---

# Final Principle

> **GymGenius earns user trust by ensuring that every recommendation can be explained, every explanation can be traced to objective data, and every AI-generated sentence faithfully represents a deterministic decision produced by the system.**