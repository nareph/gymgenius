# GymGenius v3

## AI Architecture Overview

Version 3.0

---

# 1. Overview

The AI system in GymGenius v3 is designed as a **modular intelligence layer** built on top of deterministic engines.

Its purpose is not to replace logic, but to:

* enhance personalization
* explain decisions
* generate adaptive recommendations
* translate structured outputs into human understanding

---

# 2. Core AI Philosophy

## 2.1 AI is NOT the Brain

In GymGenius:

> The Decision Engine is the brain
> AI is the communicator and enhancer

---

## 2.2 Deterministic First

All critical decisions are made by:

* Workout Engine
* Nutrition Engine
* Recovery Engine
* Progress Engine
* Decision Engine

AI only refines outputs.

---

## 2.3 Explainable AI Mandatory

Every AI output must:

* explain reasoning
* reference structured data
* avoid hallucinated logic

---

## 2.4 Local-First AI Support

AI system supports:

* offline deterministic fallback
* optional cloud enhancement (Gemini / LLM APIs)
* pluggable model architecture

---

# 3. AI System Architecture

```text id="ai_arch_v1"
User Data
   ↓
Engines Layer (Deterministic)
   ↓
Decision Engine (Aggregator)
   ↓
AI Layer (Explanation + Enhancement)
   ↓
UI Output
```

---

# 4. AI Layer Components

---

## 4.1 Workout AI

### Role:

* explain workout structure
* adapt tone based on user level
* generate motivational guidance

### Does NOT:

* create workout logic
* decide training volume

---

## 4.2 Nutrition AI

### Role:

* convert macros into meals
* adapt food suggestions to country
* explain dietary decisions

---

## 4.3 Recovery AI

### Role:

* explain fatigue state
* suggest rest strategies
* provide recovery tips

---

## 4.4 Progress AI

### Role:

* interpret trends
* summarize weekly/monthly progress
* highlight plateaus or improvements

---

## 4.5 Decision AI (Wrapper Layer)

### Role:

* translate Decision Engine output into natural language
* provide reasoning explanations
* maintain consistency across modules

---

## 4.6 AI Coach (Phase 7 / v4.0)

The production coaching layer lives in `lib/engines/ai_coach/` and is documented in
[`ai-coach.md`](ai-coach.md).

* Gemini (prod) + Local deterministic fallback
* Structured `CoachResponse` with Decision Engine guardrails
* Explains / motivates / summarizes — never mutates plans

---

## 4.7 Health Platform (Phase 8 / v5.0)

Manual health & lifestyle tracking — see [`health-platform.md`](health-platform.md).

* Six modules + `HealthPlatformEngine` façade
* Observe-only Decision Engine rule
* Coach receives aggregated safe labels only

---

# 5. AI Data Flow

## Step-by-step pipeline

```text id="ai_flow_v1"
1. User inputs data
2. Engines compute metrics
3. Decision Engine aggregates results
4. Structured output generated
5. AI Layer transforms output into explanation
6. UI displays final response
```

---

# 6. AI Constraints

## 6.1 No Direct Data Mutation

AI CANNOT:

* modify Hive data
* change workout structure
* override engine decisions

---

## 6.2 Structured Input Only

AI receives:

* JSON data
* engine outputs
* decision payloads

No raw free-form system access.

---

## 6.3 No Autonomous Decision Making

AI must never:

* decide training volume
* set calories
* modify recovery score

---

# 7. AI Modes

GymGenius supports multiple AI modes:

---

## 7.1 Offline Mode

* deterministic responses
* template-based explanations
* no external API

---

## 7.2 Hybrid Mode

* local engine decisions
* AI enhances explanations

---

## 7.3 Cloud Enhanced Mode

* Gemini / LLM integration
* richer language generation
* advanced summarization

---

# 8. Prompt Design Strategy

AI prompts are:

* structured
* constrained
* domain-specific
* engine-driven

---

## Example Prompt Structure

```text id="prompt_v1"
Context:
- User recovery: 62
- Training load: high
- Progress: plateau

Engine Decision:
- reduce intensity by 15%

Task:
Explain this decision in simple coaching language.
```

---

# 9. AI Safety Layer

Before output is shown:

* validate against engine decision
* ensure no contradiction
* remove unsafe suggestions

---

# 10. Explainability Requirement

Every AI response must include:

## 1. What changed

## 2. Why it changed

## 3. Data used

Example:

> “Training volume was reduced because your recovery score dropped from 78 to 62 over the last 3 days.”

---

# 11. AI Extensibility

AI system is designed to support:

* new models
* new providers
* local LLM integration
* domain-specific fine-tuning

Without changing engine logic.

---

# 12. AI vs Engines Responsibility Matrix

| Component       | Responsibility    |
| --------------- | ----------------- |
| Engines         | Compute decisions |
| Decision Engine | Aggregate logic   |
| AI Layer        | Explain + enhance |
| UI              | Display only      |

---

# 13. Failure Handling

If AI fails:

* fallback to deterministic explanation templates
* never block system functionality

---

# 14. Performance Strategy

* cache frequent explanations
* reuse structured outputs
* minimize API calls
* prefer local generation

---

# 15. Final Principle

> GymGenius AI does not decide what the user should do.
> It explains why the system already decided it.

