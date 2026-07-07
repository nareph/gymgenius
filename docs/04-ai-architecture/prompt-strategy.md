# GymGenius v3

# Prompt Strategy

Version 3.0

---

# 1. Purpose

GymGenius uses prompts to communicate with Large Language Models (LLMs) such as Gemini or future providers.

The goal of the prompt strategy is to ensure that AI-generated content is:

- consistent
- deterministic
- explainable
- provider-independent
- easy to evolve over time

Prompts are treated as part of the application's architecture rather than simple text templates.

---

# 2. Core Philosophy

The AI never receives raw application state.

Instead, every prompt is built from structured data produced by the deterministic engines.

```
User Data
        ↓
Domain Engines
        ↓
Decision Engine
        ↓
Prompt Builder
        ↓
LLM
        ↓
Structured Response
```

The prompt is therefore a translation layer between GymGenius and the selected AI model.

---

# 3. Prompt Builder

Prompt generation is centralized inside a dedicated component.

```
PromptBuilder
```

Responsibilities include:

- assembling structured context
- selecting the appropriate prompt template
- injecting user data
- enforcing formatting rules
- minimizing unnecessary tokens

No other component should manually build prompts.

---

# 4. Prompt Types

GymGenius defines several categories of prompts.

---

## Workout Generation

Purpose:

Generate a complete workout routine.

Input:

- user profile
- goals
- experience
- equipment
- available days
- session duration
- injuries
- previous routine summary (optional)

Expected output:

Structured JSON only.

---

## Workout Regeneration

Purpose:

Modify an existing routine.

Examples:

- regenerate one day
- regenerate one exercise
- regenerate an entire week

Input includes:

- current routine
- regeneration scope
- reason for regeneration

---

## Nutrition Recommendation

Purpose:

Generate localized meal recommendations.

Input:

- calories
- macros
- country
- budget
- dietary preferences
- training day

---

## Recovery Coaching

Purpose:

Explain recovery status and suggest practical actions.

Input:

- recovery score
- fatigue
- soreness
- sleep
- stress

---

## Progress Summary

Purpose:

Generate weekly or monthly reports.

Input:

- weight trend
- workout adherence
- strength progression
- consistency
- recovery trend

---

## AI Coach Conversation

Purpose:

Answer user questions using the current health context.

Example:

> "Should I train today?"

---

# 5. Prompt Structure

Every prompt follows the same high-level structure.

```
Role

↓

Context

↓

Structured User Data

↓

Decision Engine Output

↓

Task

↓

Output Format
```

---

## Example

```
ROLE

You are an experienced strength coach.

CONTEXT

The user wants to build muscle.

STRUCTURED DATA

Recovery Score: 63

Training Frequency: 5 days/week

Decision:

Reduce volume by 15%.

TASK

Explain today's recommendation.

OUTPUT

Return JSON only.
```

---

# 6. Prompt Design Principles

Every prompt should be:

- explicit
- concise
- deterministic
- domain-specific
- easy to maintain

Avoid:

- unnecessary storytelling
- ambiguous instructions
- hidden assumptions

---

# 7. Structured Context

Prompts should receive structured values instead of natural language whenever possible.

Good:

```
RecoveryScore = 72
```

Better than:

```
The user seems reasonably recovered.
```

Structured values reduce hallucinations and improve consistency.

---

# 8. Output Constraints

Whenever possible, AI responses must follow predefined schemas.

Example:

```json
{
  "summary": "",
  "recommendation": "",
  "reason": ""
}
```

The application should validate every response before using it.

---

# 9. Provider Independence

Prompt templates should not depend on any specific AI provider.

Supported providers may include:

- Gemini
- OpenAI
- Claude
- Local LLMs
- Future providers

Only the adapter layer should handle provider-specific formatting.

---

# 10. Prompt Versioning

Each prompt template should have a version identifier.

Example:

```
WorkoutPrompt_v1
WorkoutPrompt_v2
NutritionPrompt_v1
```

Versioning allows:

- A/B testing
- gradual improvements
- backward compatibility

---

# 11. Token Optimization

Prompt size should remain as small as possible.

Strategies include:

- removing unused fields
- summarizing historical data
- referencing identifiers instead of repeating information
- avoiding duplicate instructions

This reduces latency and API costs.

---

# 12. Safety Rules

Every prompt must instruct the AI to:

- avoid unsupported medical advice
- avoid inventing user data
- respect engine decisions
- never contradict deterministic calculations

If information is missing, the AI should acknowledge the limitation instead of guessing.

---

# 13. Quality Modes

The Prompt Builder adapts prompts according to the selected AI Quality Mode.

## Local Mode

- no cloud prompts
- deterministic templates
- no external API

---

## Balanced Mode

- optimized prompts
- concise context
- reduced token usage
- fast response time

---

## Premium Mode

- full context
- richer personalization
- deeper explanations
- more detailed coaching
- advanced summaries

The underlying business decisions remain identical across all modes.

---

# 14. Prompt Lifecycle

```
User Action
      ↓
Domain Engines
      ↓
Decision Engine
      ↓
Prompt Builder
      ↓
AI Provider
      ↓
Response Validation
      ↓
Explainable AI
      ↓
User Interface
```

---

# 15. Future Improvements

Future versions may introduce:

- dynamic prompt compression
- multilingual prompt generation
- retrieval-augmented generation (RAG)
- memory-aware prompts
- personalized coaching styles
- context caching
- few-shot prompting for specialized tasks

---

# 16. Guiding Principle

A good prompt should not compensate for missing business logic.

The deterministic engines decide **what** the application recommends.

The prompt only determines **how** those recommendations are communicated.

Prompt engineering enhances the user experience, but it never replaces the intelligence of GymGenius.