# GymGenius v3

# Getting Started

Version 3.0

---

# 1. Introduction

Welcome to GymGenius!

GymGenius is a **Local-First AI Health Coach** built with Flutter.

Unlike traditional fitness applications, GymGenius combines deterministic health engines with optional Artificial Intelligence to deliver personalized workout, nutrition, recovery, and progress recommendations.

This guide will help you set up the project and understand its development workflow.

---

# 2. Development Philosophy

Before writing code, every contributor should understand the project's core principles.

## Local First

The application must remain fully functional without an internet connection.

Cloud services enhance the experience but never replace core functionality.

---

## Deterministic Logic

Business decisions belong to the Engines.

AI assists with personalization and explanations but never replaces deterministic logic.

---

## Modular Architecture

Each feature belongs to an independent module.

Examples:

- Workout Engine
- Nutrition Engine
- Recovery Engine
- Progress Engine
- Decision Engine

Modules should remain loosely coupled.

---

## Maintainability

Code should prioritize:

- readability
- simplicity
- testability
- scalability

---

# 3. Prerequisites

Install the following tools before starting.

## Flutter

Recommended version:

```
Flutter 3.19+
```

Verify installation:

```bash
flutter doctor
```

---

## Dart

Installed automatically with Flutter.

---

## Git

```
Git 2.x+
```

---

## Android Studio

Required for:

- Android SDK
- Emulator
- Device debugging

---

## VS Code (Optional)

Recommended extensions:

- Flutter
- Dart
- Error Lens
- Better Comments
- Markdown All in One

---

# 4. Clone the Repository

```bash
git clone https://github.com/<your-org>/gymgenius.git

cd gymgenius
```

---

# 5. Install Dependencies

```bash
flutter pub get
```

---

# 6. Generate Code

Whenever model classes or Hive adapters change:

```bash
dart run build_runner build --delete-conflicting-outputs
```

For continuous generation:

```bash
dart run build_runner watch
```

---

# 7. Run the Application

Debug mode:

```bash
flutter run
```

Run on a specific device:

```bash
flutter devices

flutter run -d <device-id>
```

---

# 8. Project Structure

```
lib/

├── blocs/
├── core/
├── data/
├── domain/
├── presentation/
├── services/
├── ai/
├── shared/
└── main.dart
```

Each layer has a single responsibility.

---

# 9. Documentation Structure

Project documentation is organized into several sections.

```
docs/

00-introduction/

01-research/

02-product/

03-system-design/

04-ai-architecture/

05-development/
```

Developers are encouraged to read the documentation before implementing new features.

---

# 10. Local Storage

GymGenius uses Hive as its primary database.

Characteristics:

- offline-first
- fast
- lightweight
- schema-controlled through models

No external database is required.

---

# 11. AI Configuration

GymGenius supports multiple AI Quality Modes.

## Local

Uses only deterministic engines.

No internet connection required.

---

## Balanced

Uses cloud AI for high-value features while keeping deterministic business logic local.

Provides a balance between quality and speed.

---

## Premium

Uses the selected AI provider to maximize personalization and coaching quality.

Business decisions remain deterministic.

---

# 12. Running Tests

Execute all tests:

```bash
flutter test
```

Run a specific test:

```bash
flutter test test/path_to_test.dart
```

---

# 13. Code Formatting

Before committing:

```bash
dart format .
```

Analyze the project:

```bash
flutter analyze
```

Fix common issues:

```bash
dart fix --apply
```

The project should compile without warnings.

---

# 14. Git Workflow

Recommended workflow:

```
main

↓

feature/<feature-name>

↓

Pull Request

↓

Review

↓

Merge
```

Avoid committing directly to the `main` branch.

---

# 15. Recommended Development Process

When implementing a new feature:

1. Read the relevant documentation.
2. Understand the affected domain.
3. Design the data model.
4. Implement deterministic business logic.
5. Integrate with the appropriate Engine.
6. Add AI support if applicable.
7. Write unit tests.
8. Update the documentation if necessary.

Documentation should evolve alongside the code.

---

# 16. Useful Commands

Upgrade dependencies:

```bash
flutter pub upgrade
```

Clean the project:

```bash
flutter clean
```

Fetch dependencies again:

```bash
flutter pub get
```

Generate Hive adapters:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Analyze:

```bash
flutter analyze
```

Run tests:

```bash
flutter test
```

---

# 17. Common Issues

## Hive Adapter Errors

Regenerate code:

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## Package Conflicts

Clean the project:

```bash
flutter clean

flutter pub get
```

---

## AI Provider Errors

If the selected AI provider is unavailable:

- verify API configuration
- verify internet connectivity
- retry the request

If the request still fails, GymGenius automatically falls back according to the configured AI Quality Mode whenever applicable.

---

# 18. Before Opening a Pull Request

Ensure that:

- all tests pass
- code is formatted
- static analysis reports no errors
- documentation has been updated
- no debug code remains
- no sensitive information is committed

---

# 19. Additional Documentation

Developers should become familiar with:

- System Architecture
- Layer Architecture
- Domain Model
- AI Architecture
- Implementation Specification
- Coding Guidelines

These documents define the project's technical standards.

---

# 20. Guiding Principle

GymGenius is more than a Flutter application.

It is a modular health intelligence platform where every component should be deterministic, explainable, maintainable, and designed for long-term evolution.