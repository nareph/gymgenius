# GymGenius v3

## Project Structure

Version 3.0

---

# 1. Overview

This document defines the **recommended Flutter project structure** for GymGenius v3.

The goal is to ensure:

* scalability
* clean architecture alignment
* clear separation of concerns
* maintainability
* offline-first support

---

# 2. Root Structure

```text
lib/
├── blocs/
├── models/
├── repositories/
├── services/
├── viewmodels/
├── screens/
├── widgets/
├── providers/
├── theme/
├── core/
├── engines/
└── main.dart
```

---

# 3. Layer Mapping

| Folder        | Layer in Architecture |
| ------------- | --------------------- |
| screens/      | UI Layer              |
| viewmodels/   | ViewModels Layer      |
| repositories/ | Repositories Layer    |
| services/     | Services Layer        |
| engines/      | Domain Engines Layer  |
| models/       | Data Models           |
| providers/    | State Management      |
| core/         | Shared utilities      |
| theme/        | UI design system      |
| blocs/        | Auth / onboarding     |

---

# 4. Detailed Folder Breakdown

---

## 4.1 `screens/` (UI Layer)

### Purpose

Contains all application screens.

### Examples

```text
screens/
├── home/
├── workout/
├── tracking/
├── profile/
├── onboarding/
```

### Rules

* no business logic
* only UI rendering
* consumes ViewModels

---

## 4.2 `viewmodels/`

### Purpose

State + UI logic bridge.

### Examples

```text
viewmodels/
├── workout_viewmodel.dart
├── home_viewmodel.dart
├── profile_viewmodel.dart
```

---

## 4.3 `repositories/`

### Purpose

Data access abstraction layer.

### Examples

```text
repositories/
├── user_repository.dart
├── workout_repository.dart
├── progress_repository.dart
```

---

## 4.4 `services/`

### Purpose

Business logic layer (non-AI).

### Examples

```text
services/
├── workout_service.dart
├── nutrition_service.dart
├── recovery_service.dart
```

---

## 4.5 `engines/` (Core Intelligence)

### Purpose

Decision-making system of GymGenius.

### Structure

```text
engines/
├── workout_engine/
├── nutrition_engine/
├── recovery_engine/
├── progress_engine/
├── decision_engine/
```

### Rule

Each engine = isolated module

---

## 4.6 `models/`

### Purpose

Data structures.

### Examples

```text
models/
├── user_model.dart
├── workout_model.dart
├── routine_model.dart
├── progress_model.dart
```

---

## 4.7 `providers/`

### Purpose

Global state providers.

### Examples

```text
providers/
├── auth_provider.dart
├── theme_provider.dart
```

---

## 4.8 `core/`

### Purpose

Shared utilities used across the system.

### Examples

```text
core/
├── constants/
├── utils/
├── errors/
├── extensions/
```

---

## 4.9 `theme/`

### Purpose

Design system configuration.

### Contains

* colors
* typography
* spacing
* themes (dark/light)

---

## 4.10 `blocs/`

### Purpose

Used ONLY for:

* authentication
* onboarding flows

### Rule

Do NOT use BLoC for general app logic.

---

# 5. Engine Structure (Deep Dive)

Each engine follows the same internal pattern:

```text
engine/
├── models/
├── services/
├── engine.dart
├── calculator.dart
├── rules.dart
```

---

## Example: Workout Engine

```text
workout_engine/
├── models/
├── workout_engine.dart
├── volume_calculator.dart
├── split_generator.dart
├── overload_rules.dart
```

---

# 6. Dependency Flow

```text
UI
 ↓
ViewModel
 ↓
Repository
 ↓
Service
 ↓
Engine
 ↓
Model/Data
```

---

# 7. Import Rules

## Rule 1: Downward Imports Only

Allowed:

* UI → ViewModels
* ViewModels → Services
* Services → Engines
* Engines → Models

Forbidden:

* Engines → UI
* Models → Services
* Repositories → ViewModels

---

## Rule 2: No Circular Dependencies

Each module must remain independent.

---

## Rule 3: Engines Must Be Pure

No:

* Flutter imports
* UI dependencies
* Hive calls

---

# 8. Feature-Based Organization (Recommended Extension)

Future improvement:

```text
features/
├── workout/
├── nutrition/
├── recovery/
├── profile/
```

Each feature contains:

* screens
* viewmodels
* services
* models

---

# 9. Scaling Strategy

This structure supports:

### Vertical scaling

Improve internal logic without restructuring app

### Horizontal scaling

Add new modules:

* sleep_engine
* hormone_engine
* stress_engine

---

# 10. Testing Alignment

| Folder       | Test Type         |
| ------------ | ----------------- |
| screens      | widget tests      |
| viewmodels   | unit tests        |
| services     | unit tests        |
| engines      | pure logic tests  |
| repositories | integration tests |

---

# 11. Performance Philosophy

* lazy loading of engines
* no heavy logic in UI
* caching in repositories
* stateless engines

---

# 12. Final Principle

> GymGenius structure is designed so that every new feature fits into the system without rewriting the system itself.

Each folder represents a **predictable responsibility boundary**.


