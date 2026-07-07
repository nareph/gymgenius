# GymGenius v3

> **Local-First AI Health Intelligence System**

GymGenius v3 is a next-generation fitness platform designed around deterministic decision engines, local-first data storage, and explainable artificial intelligence.

Unlike traditional fitness applications that generate static workout plans, GymGenius continuously adapts to the user's progress, recovery, and health data to provide personalized daily recommendations.

---

# Vision

GymGenius aims to become a **Personal AI Health Operating System**.

Instead of asking:

> "Generate me a workout."

GymGenius answers:

> **"Given everything we know about you today, what is the best action to improve your health?"**

---

# Core Principles

- Local-First Architecture
- Offline by Default
- Explainable AI
- Deterministic Decision Making
- Evidence-Based Fitness
- Modular Domain Architecture
- Long-Term Personalization

---

# Architecture Overview

```text
Presentation Layer (Flutter UI)
            │
            ▼
State Management (ViewModels)
            │
            ▼
Repository Layer
            │
            ▼
Service Layer
            │
            ▼
Domain Engines
    ├── Workout Engine
    ├── Nutrition Engine
    ├── Recovery Engine
    └── Progress Engine
            │
            ▼
Decision Engine
            │
            ▼
AI Coach
            │
            ▼
Hive Local Database
```

The Decision Engine orchestrates all domain engines and produces a single coherent recommendation for the user.

---

# Documentation Structure

```
docs/
│
├── 00-introduction/
├── 01-research/
├── 02-product/
├── 03-system-design/
├── 04-ai-architecture/
├── 05-development/
├── 06-testing/
└── assets/
```

The documentation is organized from business vision to implementation details.

---

# Core Intelligence Modules

GymGenius is composed of specialized deterministic engines.

- Workout Engine
- Nutrition Engine
- Recovery Engine
- Progress Engine
- Decision Engine
- AI Coach

Each module has a single responsibility and communicates through structured internal contracts.

---

# Training Model

GymGenius distinguishes between three different concepts.

## Training Program

A complete multi-week strategy.

Example:

- 6 weeks
- Upper / Lower Split
- Progressive Overload Strategy

---

## Weekly Training Plan

The weekly schedule generated from the training program.

Example:

Monday → Upper A

Tuesday → Lower A

Thursday → Upper B

Friday → Lower B

---

## Training Session

The workout scheduled for a specific day.

The Decision Engine may adapt today's session according to:

- recovery
- fatigue
- soreness
- progress
- adherence

without modifying the entire Training Program.

---

# Local-First Philosophy

GymGenius stores all user data locally using Hive.

The application functions without an internet connection.

Cloud synchronization is considered an optional future capability rather than a requirement.

---

# AI Philosophy

Artificial Intelligence does **not** make business decisions.

Deterministic engines compute:

- workout programming
- nutrition targets
- recovery analysis
- progress evaluation

The AI Coach is responsible only for:

- explanations
- coaching
- motivation
- natural language generation

---

# Current Status

The v3 branch contains the complete architectural redesign of GymGenius, including:

- Product Architecture
- System Design
- Database Design
- Internal API Contracts
- Domain Engines
- Decision Engine
- Development Guidelines
- Testing Strategy

This branch serves as the architectural foundation for future implementation.

---

# Roadmap

The project evolves progressively through five stages.

1. Foundation
2. Intelligent Coaching
3. Advanced Intelligence
4. Connected Health Ecosystem
5. Personal AI Health Operating System

---

# Technology Stack

- Flutter
- Dart
- Hive
- Riverpod (planned)
- Local-First Storage
- Modular Clean Architecture

---

# Design Philosophy

GymGenius follows one fundamental rule:

> **Every recommendation must be explainable, deterministic, and driven by real user data.**

The application adapts to the user.

The user should never have to adapt to the application.