# Changelog

All notable changes to **GymGenius** are documented in this file.

This project follows:

- Semantic Versioning (SemVer)
- Keep a Changelog conventions

The changelog highlights architectural changes, new features, improvements, and breaking changes across releases.

---

# [Unreleased]

### Planned

- FOOD_KNOWLEDGE_BASE
- Country-aware nutrition
- Health Connect integration
- Wearable support

# [3.0.0] - 2026-06 (Current Stable Release)

## 🚀 Major Architecture Overhaul

This version introduces a complete shift from cloud-based architecture to a **local-first AI fitness intelligence system**.

---

### 🔁 Changed

* Migrated from Firebase backend → **100% local Hive database architecture**
* Replaced Firestore with **Hive NoSQL local storage**
* Replaced Cloud Functions AI generation with:

  * Local AI engine
  * Optional Gemini integration (client-side)
* Removed server dependency for core functionality
* Authentication moved from Firebase Auth → local secure auth system

---

### 🧠 AI System Upgrade

* Introduced modular AI engine:

  * Workout Engine
  * Nutrition Engine (foundation)
  * Recovery Engine (foundation)
  * Progress Engine (new)
  * Decision Engine (new orchestration layer)

* AI is now:

  * deterministic (rule-based core)
  * optionally enhanced by Gemini API
  * validated by `RoutineValidator`

---

### 🏋️ Workout System Improvements

* Introduced advanced muscle split logic system
* Added progressive overload tracking support
* Improved exercise selection algorithm
* Added recovery-aware training distribution
* Better support for:

  * Push/Pull/Legs
  * Upper/Lower
  * Full Body splits

---

### 📊 Progress Tracking (NEW)

* Added **Progress Engine**
* Weekly evaluation system:

  * Strength Progress Index (SPI)
  * Consistency Score
  * Recovery Stability Index
* Automatic classification:

  * Rapid Progress
  * Steady Progress
  * Plateau
  * Regression

---

### 🧾 Data Layer Changes

* Replaced Firestore collections with Hive models:

  * `UserModel`
  * `RoutineModel`
  * `WorkoutLogModel`

* Added full offline persistence

* Improved data integrity with local transactional logic

---

### 🔐 Authentication

* Replaced Firebase Authentication with:

  * Local secure storage auth
  * SHA-256 password hashing
  * Device-based session management

---

### 📱 UI/UX Improvements

* Improved HomeTab state management flow
* Better routine expiration handling
* Enhanced onboarding questionnaire system
* Improved tracking calendar markers
* Added animated state transitions across screens

---

### ⚙️ Performance Improvements

* Startup time reduced significantly (no cloud initialization)
* Instant data access via Hive
* Reduced dependency overhead
* Fully offline functionality

---

### 🧪 Developer Experience

* Simplified setup (no Firebase required)
* Build process now fully local
* Removed Firebase configuration complexity
* Faster iteration cycle

---

## 🧱 Breaking Changes

* Firebase backend fully removed
* Firestore data incompatible with v3
* Cloud Functions no longer supported
* Existing Firebase users must migrate manually (if needed)

---

# [2.0.0] - Firebase AI Cloud Version

## 🚀 Major Features

* Introduced Firebase backend integration
* Added Cloud Firestore database
* Added Firebase Authentication
* Introduced Cloud Functions for AI generation (Gemini-based)

---

### 🧠 AI System

* AI routine generation via server-side Cloud Functions
* Gemini API integration through backend layer
* Centralized prompt generation

---

### 📊 Features

* Workout logging synced to Firestore
* Calendar-based tracking system
* Routine expiration + regeneration logic
* Profile management synced to cloud

---

### 🔐 Authentication

* Email/password authentication via Firebase
* User sessions managed by Firebase Auth

---

### 📱 UI Improvements

* Full onboarding system introduced
* Tracking calendar implemented
* Workout session flow stabilized

---

# [1.0.0] - Initial Firebase Release

## 🎉 Initial Release

* Basic AI-powered workout generator
* Firebase backend integration
* Simple onboarding flow
* Routine generation via Cloud Functions
* Basic workout logging system
* Minimal tracking features

---

# Migration Summary

## Firebase → Local Architecture Shift

| Component  | v1/v2 (Firebase) | v3 (Local)              |
| ---------- | ---------------- | ----------------------- |
| Auth       | Firebase Auth    | Local Secure Auth       |
| Database   | Firestore        | Hive                    |
| AI         | Cloud Functions  | Local + optional Gemini |
| Sync       | Real-time cloud  | Offline-first           |
| Dependency | High             | Low                     |
| Privacy    | Cloud-based      | 100% local              |

---

# Future Versions (Planned)

## [3.1.0]

* Nutrition Engine expansion
* Food database localization (Africa-first)
* Macro estimation improvements

---

## [3.2.0]

* Recovery Engine full implementation
* Sleep tracking integration
* Fatigue prediction model

---

## [4.0.0]

* Full AI Coach system (multi-modal)
* Voice coaching
* Mobile + Web unified dashboard
* Optional cloud sync (opt-in)

---

# Philosophy Reminder

GymGenius is evolving from:

> A fitness tracker

to:

> An adaptive AI fitness intelligence system

---

# Maintainer

Nareph — GymGenius Project Lead
