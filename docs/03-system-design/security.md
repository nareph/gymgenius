# GymGenius v3

## Security Design

Version 3.0

---

# 1. Overview

GymGenius v3 is a **local-first health intelligence system**, meaning security is primarily focused on:

* device-level data protection
* secure local storage (Hive)
* safe AI integration (optional cloud)
* integrity of health data
* prevention of data corruption

There is no mandatory backend, so **security is fully client-side enforced**.

---

# 2. Security Principles

## 2.1 Local Ownership

All user data:

* remains on device
* is never required to leave the device
* is fully user-controlled

---

## 2.2 Least Privilege

Each module can only access what it needs:

* UI → no data access
* ViewModels → limited data via repositories
* Repositories → controlled Hive access
* Engines → read-only computation

---

## 2.3 Deterministic Safety

All critical calculations must be:

* predictable
* testable
* reproducible

No unpredictable AI-driven mutations of core data.

---

## 2.4 Offline-First Security

Security must work without internet:

* no cloud dependency for protection
* no remote validation required
* no external authentication server required

---

# 3. Authentication Security

## 3.1 Local Authentication System

GymGenius uses a **local auth system**:

### Mechanisms:

* SHA-256 password hashing
* device-bound session token
* secure local storage (encrypted Hive box recommended)

---

## 3.2 Password Storage

### Rule:

❌ Never store plain passwords
✔ Store only hashed passwords

Example:

```text id="hash_example"
password → SHA-256 → stored_hash
```

---

## 3.3 Session Management

Sessions are:

* device-specific
* time-limited
* stored locally

### Session structure:

```json id="session_v1"
{
  "user_id": "uuid",
  "session_token": "hashed_token",
  "created_at": "timestamp",
  "expires_at": "timestamp"
}
```

---

## 3.4 Brute Force Protection

Local protection strategies:

* login attempt counter
* temporary lockout after failed attempts
* exponential delay

---

# 4. Data Security (Hive Layer)

## 4.1 Encryption Strategy

Hive boxes containing sensitive data SHOULD be:

* encrypted at rest
* protected with device key

---

## 4.2 Sensitive Data Categories

### High sensitivity:

* user profile
* body weight logs
* health metrics
* recovery data
* workout history

---

## 4.3 Data Integrity Rules

* validate all writes
* reject corrupted models
* enforce schema consistency
* prevent negative or impossible values

Example:

```text id="validation_rule"
weight_kg < 0 → REJECT
```

---

## 4.4 Backup Safety (Future)

If backup is added:

* must be encrypted
* must be opt-in
* must be user-controlled

---

# 5. AI Security

## 5.1 AI Is Not Trusted

AI outputs are:

* suggestions only
* never directly written into core state
* always validated by engines

---

## 5.2 Prompt Safety

All AI inputs must be:

* sanitized
* structured (no raw user injection into system prompts)
* constrained to domain scope

---

## 5.3 AI Output Validation

Before applying AI suggestions:

✔ Validate against business rules
✔ Validate against deterministic engines
✔ Reject unsafe values

---

## 5.4 Example

AI suggests:

> “Train legs 3 times today”

System response:

* rejected by Workout Engine rules
* flagged as excessive load

---

# 6. Engine Security

## 6.1 Stateless Enforcement

Engines:

* do NOT store state
* only compute results
* cannot mutate storage directly

---

## 6.2 Decision Engine Protection

Decision Engine is the most sensitive component:

### Rules:

* must aggregate inputs only
* cannot bypass validation layers
* must not directly write to database

---

# 7. Input Validation Layer

Every external input must be validated:

## Examples:

### Weight input

```text id="weight_validation"
min: 20kg  
max: 300kg
```

---

### Sleep input

```text id="sleep_validation"
min: 0h  
max: 24h
```

---

### Workout sets

* reps > 0
* weight ≥ 0
* sets within safe range

---

# 8. API Security (Internal APIs)

Even internal APIs must follow strict rules:

## 8.1 Schema Enforcement

All APIs require:

* strict JSON structure
* required fields validation
* type checking

---

## 8.2 Error Handling Security

No sensitive system leakage:

❌ Bad:

```text
Null pointer in DecisionEngine.kt line 43
```

✔ Good:

```json id="safe_error"
{
  "error": true,
  "message": "Unable to process request"
}
```

---

# 9. Threat Model

## 9.1 Local Threats

* device theft
* unauthorized access
* data extraction from storage

### Mitigation:

* encrypted storage
* session lock
* optional biometric auth (future)

---

## 9.2 Application-Level Threats

* corrupted data injection
* invalid workout generation
* AI hallucinated outputs

### Mitigation:

* deterministic validation layer
* engine-based filtering

---

## 9.3 AI Threats

* prompt injection
* unsafe recommendations
* inconsistent outputs

### Mitigation:

* structured prompts only
* engine validation
* AI never directly controls state

---

# 10. Privacy Model

## 10.1 Core Principle

> User data never leaves the device unless explicitly enabled.

---

## 10.2 Data Categories

| Type         | Default             |
| ------------ | ------------------- |
| Workout data | Local only          |
| Body metrics | Local only          |
| AI requests  | Optional cloud      |
| Sync data    | Disabled by default |

---

## 10.3 No Tracking Policy

GymGenius does NOT:

* track user behavior externally
* send analytics by default
* store data remotely
* profile users

---

# 11. Future Security Enhancements

Planned improvements:

* biometric authentication (Face ID / fingerprint)
* encrypted cloud sync (opt-in only)
* secure multi-device sync
* hardware-backed encryption (Keystore / Secure Enclave)
* tamper detection for logs

---

# 12. Performance vs Security Balance

Security must NOT break UX:

* encryption must be lightweight
* validation must be fast
* offline access must remain instant

---

# 13. Final Principle

> GymGenius security is designed to protect the user without ever limiting control.

The system assumes:

* the device is the trust boundary
* the user owns their data
* the system must never silently modify health decisions

