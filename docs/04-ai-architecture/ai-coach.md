# AI Coach

Version: 4.0

---

# Overview

The AI Coach explains, motivates, and summarizes. It does **not** decide workouts,
nutrition targets, or recovery adaptations.

> **Decision Engine decides. AI Coach explains.**

Production cloud path: **Gemini** (when `GEMINI_API_KEY` is set and `ENABLE_AI_COACH` is true).  
Offline / fallback: **LocalCoachProvider** (deterministic templates from `CoachContext`).  
OpenAI / Claude: interface stubs only in v4.0.

---

# Position in the Architecture

```text
Domain Engines
      │
Decision Engine → DailyPlan
      │
CoachContextBuilder → CoachContext
      │
AICoachEngine → AIProvider (Gemini | Local | stubs)
      │
CoachResponseValidator (JSON + guardrails)
      │
CoachRepository (Hive cache / conversations)
      │
Home (CoachHomeCard) / CoachScreen
```

---

# Contracts

## AIProvider

```dart
Future<String> complete({
  required String systemPrompt,
  required String userPrompt,
  CoachRequestOptions options,
});
```

## CoachResponse (validated JSON)

- `message`
- `insights[]` — `{ type, title, body, priority }`
- `recommendations[]` — `{ category, text, reason, alignsWithDecision, actionTag? }`
- `tone` / `providerId` / `promptVersion` / `generatedBy`

Guardrail: if Decision Engine reduced volume, recommendations with tags like
`increase_volume` / `push_harder` are stripped.

## CoachContext

Built only from `DailyPlan` (+ embedded recovery / nutrition / progress / health
decision). The LLM layer never reads Hive directly.

---

# Flows

| Flow | Cache key | Notes |
|------|-----------|--------|
| Daily coaching | `userId_day` | 1× / user / day via `CoachRepository` |
| Weekly summary | `userId_weekStart` | Numbers come from `WeeklyProgressReport` — coach must not invent metrics |
| Chat | Conversation Hive TypeId 16 | Last N messages (`AIConfig.coachMaxHistoryMessages`, default 20) |

---

# Persistence

| Hive TypeId | Model | Box |
|-------------|--------|-----|
| 16 | `ConversationHiveModel` | `coach_conversations` |
| 17 | `CoachCacheHiveModel` | `coach_cache` |

---

# Configuration (`AIConfig`)

- `coachMaxHistoryMessages` — conversation window
- `coachMaxOutputTokens` / `coachTimeout`
- `canUseCoachCloud` — `ENABLE_AI_COACH && hasGemini`

---

# Out of scope (v4.0)

- Streaming responses
- Advanced cost monitoring
- Production OpenAI / Claude
- Automatic LLM conversation summarization

---

# Tests

See `test/engines/ai_coach/` for context builder, validator guardrails, local
provider, and DailyPlan → coaching integration.
