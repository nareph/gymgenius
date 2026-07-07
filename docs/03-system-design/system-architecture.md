# GymGenius v3

## System Architecture

Version 3.0

---

# 1. System Overview

GymGenius v3 is a **Local-First AI Health Intelligence System** built around deterministic domain engines coordinated by a centralized Decision Engine.

The system combines structured health data, scientific training principles, and optional AI assistance to continuously adapt a user's training program while remaining fully functional offline.

The architecture is designed to be:

- Local-First
- Deterministic
- Explainable
- Modular
- Extensible

---

# 2. Architectural Philosophy

GymGenius follows a layered architecture where every component has a single responsibility.

Business decisions are computed by deterministic engines.

Artificial Intelligence never replaces business logic.

Instead, AI enhances explanations and content generation.

> Deterministic Engines decide.
>
> AI explains.

---

# 3. High-Level Architecture

```text
                  User Interface
                         │
                         ▼
                Presentation Layer
                         │
                         ▼
                 ViewModel Layer
                         │
                         ▼
                 Repository Layer
                         │
                         ▼
                  Service Layer
                         │
                         ▼
        ┌─────────────────────────────────┐
        │      Domain Intelligence        │
        │                                 │
        │  Workout Engine                 │
        │  Nutrition Engine               │
        │  Recovery Engine                │
        │  Progress Engine                │
        └─────────────────────────────────┘
                         │
                         ▼
                 Decision Engine
                         │
              ┌──────────┴──────────┐
              ▼                     ▼
        AI Coach Layer         Hive Database
```

---

# 4. Layer Responsibilities

---

## 4.1 Presentation Layer

Responsible for:

- rendering the UI
- collecting user interactions
- displaying computed results

The UI never contains business logic.

---

## 4.2 ViewModel Layer

Responsible for:

- application state
- screen lifecycle
- user actions
- reactive updates

ViewModels orchestrate application flows without implementing domain rules.

---

## 4.3 Repository Layer

Repositories abstract all persistence.

Responsibilities:

- Hive access
- caching
- model mapping
- data persistence

No other layer accesses Hive directly.

---

## 4.4 Service Layer

Services prepare and validate data before it reaches domain engines.

Typical responsibilities include:

- validation
- aggregation
- preprocessing
- calculations
- normalization

---

## 4.5 Domain Intelligence Layer

This layer contains GymGenius' deterministic engines.

Each engine focuses on one fitness domain.

---

### Workout Engine

Responsible for:

- Training Program generation
- Weekly Plan generation
- session adaptation
- progressive overload
- exercise substitutions
- training volume

---

### Nutrition Engine

Responsible for:

- calorie calculation
- macro calculation
- meal planning
- local food recommendations

---

### Recovery Engine

Responsible for:

- recovery score
- readiness calculation
- fatigue estimation
- recovery recommendations

---

### Progress Engine

Responsible for:

- progression analysis
- plateau detection
- consistency evaluation
- historical trends

---

# 5. Decision Engine

The Decision Engine is the central orchestrator.

It receives outputs from every deterministic engine.

Its responsibilities include:

- conflict resolution
- safety enforcement
- recommendation prioritization
- daily adaptation decisions

The Decision Engine never generates exercises directly.

Instead it determines **what should change**.

Example:

Recovery ↓

↓

Reduce today's volume

↓

Workout Engine adapts today's session

---

# 6. AI Coach Layer

AI is an optional enhancement layer.

Responsibilities:

- explain decisions
- summarize progress
- generate coaching feedback
- improve communication

AI never changes business decisions.

If AI is unavailable:

- deterministic templates are used
- application remains fully operational

---

# 7. Data Architecture

Hive is the single source of truth.

Stored data includes:

- user profile
- Training Programs
- Weekly Plans
- workout logs
- nutrition logs
- recovery logs
- progress history
- decision history

All data is stored locally.

---

# 8. Core Domain Model

GymGenius separates long-term planning from daily execution.

```text
Training Program
        │
        ├── Goal
        ├── Duration
        ├── Weekly Plan
        │
        │     Monday Session
        │     Tuesday Session
        │     Wednesday Session
        │     Thursday Rest
        │     Friday Session
        │     Saturday Session
        │     Sunday Rest
        │
        └── Adaptation History
```

---

# 9. Daily Decision Flow

Every day follows the same pipeline.

```text
Current Training Program

↓

Current Weekly Plan

↓

Today's Planned Session

↓

Recovery Engine

↓

Progress Engine

↓

Nutrition Engine

↓

Decision Engine

↓

Workout Engine adapts today's session

↓

AI Coach explains changes

↓

User trains

↓

Workout Log stored

↓

Progress updated
```

The Weekly Plan remains unchanged unless a structural modification is required.

Only today's session may be adapted.

---

# 10. Training Program Lifecycle

A Training Program remains active for multiple weeks.

Typical duration:

- 4 weeks
- 6 weeks
- 8 weeks

During its lifecycle:

- daily sessions may be adapted
- intensity may change
- exercises may be swapped
- volume may increase or decrease

The complete Weekly Plan is regenerated only when necessary.

Examples:

- program expiration
- plateau
- goal change
- injury
- equipment change
- explicit user request

---

# 11. Offline-First Strategy

GymGenius always prioritizes local execution.

The application operates in three quality modes.

---

## Local Mode

Everything runs locally.

No internet required.

---

## Hybrid Mode

Deterministic engines compute decisions.

Cloud AI improves explanations and Training Program generation.

---

## Cloud Enhanced Mode

Cloud AI is preferred for rich generation.

If unavailable:

- deterministic logic remains active
- local generation becomes the fallback

Core application functionality is never blocked.

---

# 12. Engine Communication Rules

Domain engines never communicate directly.

All communication passes through the Decision Engine.

```text
Workout Engine
        │
Nutrition Engine
        │
Recovery Engine
        │
Progress Engine
        │
        ▼
Decision Engine
```

This prevents cyclic dependencies.

---

# 13. Failure Handling

Failures must never interrupt core functionality.

Examples:

AI failure

↓

Use deterministic explanations

Cloud unavailable

↓

Generate locally

Recovery data missing

↓

Use conservative assumptions

Corrupted cache

↓

Recompute from logs

---

# 14. Security Boundaries

The architecture enforces strict boundaries.

- UI cannot access Hive
- AI cannot modify data
- Engines cannot bypass repositories
- repositories validate writes
- Decision Engine validates every recommendation

---

# 15. Scalability

The architecture supports future additions such as:

- wearable integrations
- HRV analysis
- resting heart rate
- computer vision
- cloud synchronization
- local LLMs
- new nutrition databases
- additional health engines

without redesigning the core system.

---

# 16. Guiding Principles

GymGenius follows six architectural principles.

1. Local-First

The application must remain fully usable offline.

2. Deterministic Decisions

Business logic must always be reproducible.

3. Explainable Intelligence

Every recommendation must be traceable.

4. Modular Design

Each engine evolves independently.

5. Safety First

Recovery always takes priority over performance.

6. Progressive Enhancement

AI improves the experience but never becomes a requirement.

---

# Final Principle

> GymGenius is not an AI application.

It is a deterministic health intelligence platform where specialized engines compute decisions, the Decision Engine orchestrates them, and AI enhances communication without ever replacing the system's core logic.