# GymGenius v3

## Layer Architecture

Version 3.0

---

# 1. Overview

GymGenius v3 follows a **strict layered architecture** designed to enforce:

* separation of concerns
* testability
* scalability
* offline-first execution
* deterministic business logic

Each layer has a **single responsibility** and communicates only with adjacent layers.

---

# 2. Global Layer Stack

```text
UI Layer (Flutter Screens)
↓
ViewModels Layer (State Management)
↓
Repositories Layer (Data Access Abstraction)
↓
Services Layer (Business Logic)
↓
Domain Engines Layer (Intelligence Layer)
↓
Data Layer (Hive Local Database)
```

---

# 3. Layer Responsibilities

---

## 3.1 UI Layer

### Purpose

The UI layer is responsible for **presentation only**.

### Responsibilities

* Rendering screens
* Displaying state from ViewModels
* Handling user interactions
* Navigation

### Rules

* ❌ No business logic
* ❌ No direct database access
* ❌ No AI calls
* ❌ No calculations

### Example

* Show workout list
* Start workout button
* Display recovery score

---

## 3.2 ViewModels Layer

### Purpose

Acts as a **bridge between UI and business logic**.

### Responsibilities

* UI state management
* Calling repositories
* Transforming data for UI
* Handling loading/error states

### Tools

* Provider (primary state management)

### Example

```text
WorkoutViewModel
 ├── loadTodayWorkout()
 ├── startWorkout()
 ├── updateUIState()
```

---

## 3.3 Repositories Layer

### Purpose

Abstracts all data sources.

### Responsibilities

* Reading from Hive
* Writing to Hive
* Data mapping (Entity ↔ Model)
* Centralizing access logic

### Rules

* No business logic
* No AI logic
* Only data operations

### Example

* UserRepository
* WorkoutRepository
* ProgressRepository

---

## 3.4 Services Layer

### Purpose

Contains **business rules and application logic**.

### Responsibilities

* Workout calculations
* Nutrition calculations
* Recovery computations
* Validation rules
* Pre-processing data before engines

### Example

* Calculate weekly training volume
* Validate routine structure
* Compute calorie baseline

---

## 3.5 Domain Engines Layer

### Purpose

This is the **intelligence core of GymGenius**.

Each engine is responsible for a specific domain:

---

### Workout Engine

* Routine generation
* Exercise selection
* Progressive overload logic

---

### Nutrition Engine

* Calorie estimation
* Macro distribution
* Meal structuring

---

### Recovery Engine

* Fatigue scoring
* Recovery estimation
* Readiness detection

---

### Progress Engine

* Trend analysis
* Strength progression tracking
* Weight evolution detection

---

### Decision Engine (Core Brain)

The Decision Engine:

* aggregates all engine outputs
* resolves conflicts
* produces final recommendations

### Example

```text
Low recovery + high fatigue + high volume
→ reduce training intensity
```

---

## 3.6 Data Layer (Hive)

### Purpose

Single source of truth.

### Responsibilities

* Persistent storage
* Offline data access
* Fast local reads/writes

### Rules

* No business logic
* No transformations (except serialization)

---

# 4. Layer Communication Rules

---

## Rule 1: Strict Direction Flow

```text
UI → ViewModel → Repository → Service → Engine → Data
```

Reverse communication is forbidden.

---

## Rule 2: No Layer Skipping

Example (❌ forbidden):

* UI → Repository
* ViewModel → Engine
* Service → UI

---

## Rule 3: Stateless Engines

Engines must:

* not store state
* only compute outputs
* remain deterministic

---

## Rule 4: Repositories Are the Only Data Gate

All data access MUST go through repositories.

No direct Hive calls outside this layer.

---

## Rule 5: Services Prepare, Engines Decide

| Layer    | Role                       |
| -------- | -------------------------- |
| Services | compute & validate data    |
| Engines  | make intelligent decisions |

---

# 5. Example Flow (Workout Generation)

```text
UI
 ↓
ViewModel
 ↓
WorkoutRepository
 ↓
WorkoutService
 ↓
WorkoutEngine
 ↓
DecisionEngine
 ↓
ViewModel
 ↓
UI
```

---

# 6. Example Flow (Daily Recommendation)

```text
UI request
 ↓
ViewModel collects user state
 ↓
Repositories fetch data (Hive)
 ↓
Services compute baseline metrics
 ↓
Engines analyze:
   - recovery
   - progress
   - workload
 ↓
Decision Engine produces action
 ↓
ViewModel formats output
 ↓
UI displays recommendation
```

---

# 7. Design Philosophy

## 7.1 Deterministic Core

All critical logic must be:

* predictable
* testable
* reproducible

---

## 7.2 AI is Not a Layer of Truth

AI is only:

* a translator
* an enhancer
* an explainer

NOT a decision-maker.

---

## 7.3 Engines Are Replaceable

Each engine can evolve independently:

* rule-based → ML model → hybrid

without affecting other layers.

---

## 7.4 Offline First Constraint

Every layer must support:

* full offline execution
* no mandatory cloud dependency

---

# 8. Scalability Strategy

This architecture allows:

### Horizontal scaling

* add new engines (e.g., Sleep Engine, Hormone Engine)

### Vertical scaling

* improve logic inside one engine

### AI upgrades

* swap AI provider without touching core logic

---

# 9. Testing Strategy per Layer

| Layer      | Testing Type      |
| ---------- | ----------------- |
| UI         | Widget tests      |
| ViewModel  | Unit tests        |
| Repository | Integration tests |
| Service    | Unit tests        |
| Engine     | Pure logic tests  |
| Data       | Persistence tests |

---

# 10. Final Principle

> GymGenius architecture is designed so that **intelligence evolves without breaking structure**.

Each layer has one job:

* UI → show
* ViewModel → coordinate
* Repository → access
* Service → compute
* Engine → decide
* Data → store



