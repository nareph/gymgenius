# GymGenius v3

# AI Evaluation Framework

Version 3.0

---

# 1. Purpose

The AI Evaluation Framework defines how GymGenius measures the quality, reliability, and consistency of its AI-powered features.

The objective is to ensure that every recommendation produced by the system is:

- scientifically valid
- deterministic when required
- explainable
- consistent
- useful to the user

This framework applies to every AI provider supported by GymGenius.

---

# 2. Evaluation Philosophy

GymGenius does not evaluate an AI model based on how "intelligent" it sounds.

Instead, it evaluates whether the AI helps the user make better health decisions.

The quality of an answer is determined by:

- correctness
- consistency
- usefulness
- explainability
- safety

---

# 3. Evaluation Layers

AI outputs are evaluated across several independent layers.

```
Technical Quality
        ↓
Domain Accuracy
        ↓
Decision Consistency
        ↓
User Experience
        ↓
Performance
```

Each layer contributes to the overall quality score.

---

# 4. Technical Evaluation

The generated response should satisfy several technical requirements.

## Valid Format

The response must:

- be valid JSON (when required)
- respect the expected schema
- include all mandatory fields

---

## Completeness

The AI should answer every requested task.

Missing sections reduce the evaluation score.

---

## Stability

Repeated requests with identical inputs should produce equivalent recommendations.

Small wording variations are acceptable.

Business decisions should remain stable.

---

# 5. Decision Consistency

The AI must never contradict the Decision Engine.

Example:

Decision Engine:

```
Reduce training volume by 10%
```

Acceptable AI response:

> Reduce today's training volume to improve recovery.

Invalid AI response:

> Increase training intensity today.

The deterministic engines always have priority.

---

# 6. Scientific Accuracy

Recommendations should align with established fitness and nutrition principles.

Examples include:

- progressive overload
- adequate recovery
- realistic calorie targets
- balanced macronutrient distribution
- safe exercise selection

Unsupported claims should never be generated.

---

# 7. Explainability Evaluation

Every recommendation should answer three questions.

## What?

What is being recommended?

---

## Why?

Why was this recommendation produced?

---

## Based on what?

Which user data or engine outputs influenced the recommendation?

Example:

> Your training volume was reduced because your recovery score decreased from 81 to 65 during the last three days.

---

# 8. Personalization Evaluation

The recommendation should reflect the user's context.

Relevant factors include:

- goals
- experience
- equipment
- country
- workout history
- recovery
- injuries
- preferences

Generic recommendations reduce the evaluation score.

---

# 9. Safety Evaluation

Every response is checked for safety.

The AI must never:

- prescribe medication
- diagnose diseases
- ignore injuries
- recommend dangerous exercises
- encourage unhealthy behaviors

Potentially unsafe outputs must be rejected.

---

# 10. Performance Evaluation

The AI experience should remain responsive.

Example targets:

| Metric | Target |
|---------|--------|
| Local explanation | < 100 ms |
| Local routine generation | < 1 second |
| Cloud explanation | < 3 seconds |
| Cloud workout generation | < 10 seconds |
| Timeout fallback | < 15 seconds |

---

# 11. Quality Modes Evaluation

Each AI Quality Mode has different expectations.

## Local Mode

Focus on:

- reliability
- speed
- deterministic outputs

Minor reductions in personalization are acceptable.

---

## Balanced Mode

Focus on:

- response quality
- reasonable latency
- efficient token usage

---

## Premium Mode

Focus on:

- maximum personalization
- richer explanations
- advanced coaching
- detailed summaries

Longer response times are acceptable within predefined limits.

---

# 12. Evaluation Metrics

GymGenius uses several internal metrics.

## Response Validity

Percentage of responses passing schema validation.

Target:

> 100%

---

## Decision Agreement

Percentage of AI outputs fully aligned with the Decision Engine.

Target:

> 100%

---

## Personalization Score

Measures how well the recommendation reflects the user's profile.

Target:

> Above 90%

---

## Explainability Score

Measures whether the response clearly explains:

- what changed
- why
- which data was used

Target:

> Above 90%

---

## Scientific Compliance

Percentage of recommendations that comply with accepted fitness principles.

Target:

> 100%

---

## Safety Score

Percentage of responses containing no unsafe advice.

Target:

> 100%

---

## Latency

Average response time.

Measured separately for:

- Local AI
- Cloud AI

---

# 13. Automated Testing

Every prompt template should be tested using representative scenarios.

Examples:

- beginner gaining muscle
- advanced athlete
- fat loss
- poor recovery
- limited equipment
- missed workouts
- plateau
- injury constraints

Expected outputs are compared against reference results.

---

# 14. Human Review

Certain AI-generated outputs should periodically be reviewed by developers.

Review criteria include:

- correctness
- clarity
- consistency
- usefulness
- scientific validity

These reviews help improve future prompt versions.

---

# 15. Continuous Improvement

Evaluation results should guide future improvements.

Possible actions include:

- refining prompts
- updating templates
- improving deterministic engines
- optimizing provider selection
- reducing token usage

---

# 16. Success Criteria

An AI feature is considered production-ready when it satisfies all of the following:

- deterministic decisions are preserved
- structured outputs validate successfully
- explanations are understandable
- recommendations are personalized
- safety requirements are met
- performance targets are achieved

---

# 17. Guiding Principle

The purpose of evaluation is not to determine whether an AI model is impressive.

Its purpose is to verify that GymGenius consistently helps users make better health decisions in a reliable, explainable, and scientifically grounded way.