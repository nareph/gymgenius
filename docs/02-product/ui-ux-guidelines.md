# GymGenius v3

## UI/UX Guidelines

Version: 3.0

---

# 1. Design Philosophy

GymGenius UI is not designed to entertain.

It is designed to:

> **guide behavior, reduce friction, and support daily execution.**

The interface must always prioritize:

* clarity over aesthetics
* action over exploration
* speed over complexity

---

# 2. Core UX Principles

---

## 2.1 One Screen → One Purpose

Each screen must answer one question:

* “What do I do today?”
* “Am I progressing?”
* “What is my status?”

No mixed intentions per screen.

---

## 2.2 Minimal Cognitive Load

Users should never think about:

* system logic
* AI decision-making
* data structure

They should only see:

> what action to take next

---

## 2.3 Action-First Design

Every screen must have:

* 1 primary action
* optional secondary actions
* no unnecessary choices

---

## 2.4 Progressive Disclosure

Complex data must be hidden by default.

Only show:

* essentials first
* details on demand

---

## 2.5 Feedback Everywhere

Every user action must trigger:

* visual confirmation
* system response
* progress feedback

No silent interactions.

---

# 3. Visual Hierarchy

---

## 3.1 Primary Element

Always highlight:

* today's workout
* recovery status
* main recommendation

---

## 3.2 Secondary Elements

* weekly summary
* progress charts
* history logs

---

## 3.3 Tertiary Elements

* settings
* advanced analytics
* system data

---

# 4. Home Screen Design

---

## Purpose

Answer:

> “What should I do today?”

---

## States

### 4.1 Ready State

* Today’s workout visible
* Start button prominent
* recovery indicator shown

---

### 4.2 Recovery Alert State

* reduced intensity suggestion
* warning color (orange/red)
* explanation visible

---

### 4.3 No Routine State

* onboarding CTA
* generate routine action

---

# 5. Workout Screen UX

---

## Core Principle

> During training, UI must disappear.

---

## Design Rules

* large exercise display
* minimal text
* one action per interaction
* fast set logging

---

## Interaction Flow

```text id="ux_workout_flow_v1"
Exercise → Set Entry → Confirm → Next Exercise
```

---

## Rest Timer

* full-screen countdown
* subtle animation
* no distractions

---

# 6. Tracking Screen UX

---

## Purpose

Answer:

> “Am I improving?”

---

## Components

* weekly calendar
* workout completion markers
* progress trend indicator

---

## Visual Encoding

| Color | Meaning           |
| ----- | ----------------- |
| Green | Completed workout |
| Blue  | Planned workout   |
| Grey  | Rest day          |

---

# 7. Profile Screen UX

---

## Purpose

User configuration only.

Includes:

* goals
* equipment
* preferences
* body metrics

---

## Rules

* never overwhelm user
* group settings logically
* show impact of changes

---

# 8. AI Interaction UX

---

## Principle

AI must feel:

* invisible unless needed
* helpful but not intrusive
* predictable and consistent

---

## Output Format

AI outputs must always include:

* recommendation
* reason
* simplified explanation

---

## Example

> “Your recovery is moderate today. Reducing training volume will help improve performance tomorrow.”

---

# 9. Emotional Design

---

## 9.1 Positive Reinforcement

* highlight progress
* show improvements
* reward consistency

---

## 9.2 No Guilt Design

GymGenius must never:

* shame missed workouts
* punish inconsistency
* create pressure anxiety

---

## 9.3 Motivation Style

* calm
* factual
* supportive
* non-aggressive

---

# 10. Motion & Animation

---

## Rules

* animations < 300ms
* must serve function
* no decorative motion

---

## Usage

* transitions between screens
* feedback on actions
* progress indicators

---

# 11. Performance UX

---

## Requirements

* instant response (<200ms local operations)
* no loading screens for core actions
* skeleton loaders preferred

---

## Offline First

UI must:

* work fully offline
* never depend on network state

---

# 12. Accessibility

---

## Requirements

* high contrast mode support
* large tap targets
* readable typography
* no color-only meaning

---

# 13. Notification Strategy

---

## Rules

* minimal notifications
* context-aware only
* actionable messages only

---

## Examples

✔ Good:

* “Your workout starts in 1 hour”
* “Recovery is low today, consider light training”

❌ Bad:

* random motivational spam
* non-actionable alerts

---

# 14. Mobile-First Design

GymGenius is designed for:

* gym environments
* quick interactions
* one-hand usage
* low attention scenarios

---

# 15. Error UX

---

## Principle

Errors must be:

* human-readable
* actionable
* non-technical

---

## Example

❌ Bad:

> NullPointerException in WorkoutEngine

✔ Good:

> “We couldn’t load today’s workout. Please try again.”

---

# 16. Core UX Rule

> If the user is thinking about the interface, the interface has failed.

---

# 17. Final Principle

GymGenius UI is not a dashboard.

It is a **silent execution assistant for daily physical improvement.**




