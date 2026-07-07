# Model Selection

Version: 3.0

---

# Overview

GymGenius is designed around a provider-agnostic AI architecture.

The application never depends on a specific Large Language Model (LLM).

Instead, every AI provider implements the same internal interface, allowing models to be replaced without affecting the rest of the system.

This ensures:

- long-term maintainability
- vendor independence
- offline capability
- easy experimentation
- future extensibility

---

# Design Philosophy

GymGenius separates:

- business logic
- decision making
- language generation

Only the language generation layer depends on an AI model.

Everything else remains deterministic.

```text
Workout Engine
Recovery Engine
Nutrition Engine
Progress Engine
        │
        ▼
Decision Engine
        │
        ▼
AI Provider
        │
        ▼
User
```

Changing the AI provider must never modify engine behavior.

---

# Supported AI Quality Modes

GymGenius supports multiple quality levels depending on device capabilities and user preferences.

---

## Offline Mode

Purpose:

Provide a complete offline experience.

Characteristics:

- no internet required
- deterministic templates
- lightweight local generation
- instant response

Suitable for:

- daily recommendations
- workout explanations
- recovery summaries
- basic coaching

Advantages:

- private
- reliable
- zero API cost
- always available

Limitations:

- simpler language
- limited creativity
- fewer personalized examples

---

## Enhanced Mode

Purpose:

Improve the quality of explanations and coaching.

Characteristics:

- uses cloud AI
- richer language
- better personalization
- educational responses
- contextual examples

Suitable for:

- weekly reports
- nutrition coaching
- motivational feedback
- AI chat
- advanced explanations

Advantages:

- higher quality output
- better natural language
- improved personalization

Limitations:

- internet connection required
- API costs
- possible latency
- provider availability

---

# AI Provider Architecture

Every AI provider implements the same contract.

```text
                 AIService
                     │
     ┌───────────────┼────────────────┐
     │               │                │
     ▼               ▼                ▼
Local AI        Gemini AI        Future Provider
```

Examples of future providers:

- OpenAI
- Claude
- Mistral
- Ollama
- LM Studio
- Local LLMs

The rest of GymGenius never depends on a specific provider.

---

# Provider Interface

Each provider should expose identical capabilities.

Example:

```dart
abstract class AIProvider {

  Future<String> explainDecision(...);

  Future<Routine> generateWorkout(...);

  Future<MealPlan> generateMealPlan(...);

  Future<String> summarizeProgress(...);

}
```

New providers only implement this interface.

No engine modifications are required.

---

# Provider Selection

The AI Service selects the appropriate provider according to:

1. user settings
2. Quality Mode
3. internet availability
4. provider availability
5. request type

Example:

```text
Cloud Enabled?

        │
   Yes──┴──No
    │        │
    ▼        ▼
Gemini    Local AI
```

---

# Fallback Strategy

Cloud AI should never become a single point of failure.

If the preferred provider cannot respond:

```text
Decision Engine
        │
        ▼
Cloud AI
        │
   Failure
        │
        ▼
Local AI
        │
        ▼
Display Response
```

The user should always receive a recommendation.

Only the explanation quality changes.

---

# Selecting the Best Model

Different tasks require different capabilities.

| Task | Offline | Cloud |
|-------|----------|--------|
| Workout explanations | ✓ | ✓ |
| Recovery explanations | ✓ | ✓ |
| Nutrition explanations | ✓ | ✓ |
| Weekly reports | ✓ | ✓ |
| Meal ideas | Basic | Advanced |
| Recipe generation | Limited | Excellent |
| Coaching conversations | Basic | Excellent |
| Educational content | Basic | Excellent |

---

# Why GymGenius Doesn't Depend on a Single Model

Large Language Models evolve rapidly.

Today's best model may become obsolete next year.

GymGenius therefore treats AI providers as interchangeable components.

Benefits include:

- easier upgrades
- lower migration cost
- reduced vendor lock-in
- better long-term sustainability

---

# Local AI Requirements

The local AI implementation should:

- execute without internet
- require minimal resources
- produce deterministic responses
- operate on structured inputs only

Its objective is reliability rather than creativity.

---

# Cloud AI Requirements

Cloud providers should support:

- structured prompting
- JSON-friendly outputs
- low latency
- configurable temperature
- high availability

The provider must never receive unnecessary personal information.

---

# Privacy Considerations

When using cloud AI:

Only the minimum required context should be transmitted.

Examples:

Send:

- structured decision
- recovery score
- calorie target

Avoid sending:

- complete database
- unnecessary identifiers
- sensitive historical data

Privacy remains a core design principle.

---

# Performance Considerations

Provider selection should optimize:

- response time
- reliability
- operating cost
- energy consumption

Simple explanations should remain local whenever possible.

Cloud AI should be reserved for tasks that genuinely benefit from advanced language generation.

---

# Future Model Support

GymGenius is designed to support:

- Gemini
- OpenAI GPT models
- Claude
- Mistral
- DeepSeek
- Llama
- Phi
- Gemma
- Ollama
- LM Studio
- on-device LLMs

Adding a new provider should require only a new adapter implementation.

---

# Design Principles

The model selection architecture must always be:

- provider-agnostic
- modular
- offline-first
- privacy-first
- scalable
- maintainable
- deterministic-aware

---

# Final Principle

> **GymGenius is built around intelligent engines—not around a specific AI model. AI providers are replaceable components whose role is to communicate decisions, never to define them.**