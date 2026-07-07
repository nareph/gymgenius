# GymGenius v3

# AI Benchmark Suite

Version 3.0

---

# 1. Purpose

The GymGenius Benchmark Suite defines a standardized set of scenarios used to evaluate the quality, consistency, safety and performance of the GymGenius intelligence system.

Its objectives are to ensure that every new version of:

- Workout Engine
- Nutrition Engine
- Recovery Engine
- Progress Engine
- Decision Engine
- AI Providers

produces reliable and scientifically valid results.

---

# 2. Benchmark Philosophy

Every benchmark must be:

- reproducible
- deterministic whenever possible
- representative of real users
- measurable
- version-controlled

Benchmark results allow objective comparison between versions.

---

# 3. Evaluation Scope

The benchmark evaluates:

✓ Workout recommendations

✓ Nutrition recommendations

✓ Recovery recommendations

✓ Decision Engine outputs

✓ AI explanations

✓ Performance

✓ Safety

---

# 4. Benchmark Categories

The benchmark suite is divided into several categories.

| Category | Purpose |
|-----------|---------|
| User Profiles | Validate personalization |
| Workout | Validate routine generation |
| Nutrition | Validate calorie and meal recommendations |
| Recovery | Validate fatigue estimation |
| Progress | Validate trend analysis |
| Decision Engine | Validate final recommendations |
| Explainable AI | Validate coaching explanations |
| Performance | Measure execution speed |

---

# 5. Reference User Profiles

GymGenius maintains a fixed set of reference users.

---

## Profile A

### Beginner

Age:

22

Goal:

Lose Fat

Experience:

Beginner

Training:

2 days/week

Recovery:

Good

Expected:

- Simple Full Body routine
- Moderate calorie deficit
- High educational guidance

---

## Profile B

### Beginner Muscle Gain

Age:

19

Goal:

Build Muscle

Experience:

Beginner

Training:

3 days/week

Recovery:

Excellent

Expected:

- Full Body
- Progressive overload
- Calorie surplus

---

## Profile C

### Intermediate

Age:

28

Goal:

Hypertrophy

Training:

5 days/week

Recovery:

Good

Expected:

- Upper/Lower split
- Higher volume
- Progressive overload

---

## Profile D

### Advanced Athlete

Training:

6 days/week

Recovery:

Moderate

Goal:

Strength

Expected:

- Advanced programming
- Fatigue management
- Recovery optimization

---

## Profile E

### Weight Loss Plateau

Characteristics:

Weight unchanged

Training consistency high

Nutrition adherence high

Expected:

- Small calorie adjustment
- Activity increase
- No aggressive restriction

---

## Profile F

### Low Recovery

Sleep:

5 hours

Fatigue:

High

Muscle soreness:

High

Expected:

- Reduced training volume
- Recovery priority
- Rest recommendations

---

## Profile G

### Missed Workouts

Missed sessions:

4

Consistency:

Low

Expected:

- Simpler program
- Motivation
- Progressive return

---

# 6. Workout Engine Benchmarks

Metrics:

- Appropriate split selection
- Muscle balance
- Exercise diversity
- Equipment compatibility
- Progressive overload
- Weekly volume

Pass criteria:

100% valid routines.

---

# 7. Nutrition Benchmarks

Validate:

- calorie estimation
- protein calculation
- carbohydrate distribution
- fat allocation
- meal timing
- local food suggestions

Acceptable deviation:

Calories:

±5%

Protein:

±5 g

Fat:

±5 g

Carbohydrates:

±10 g

---

# 8. Recovery Benchmarks

Validate:

- recovery score
- readiness level
- fatigue estimation
- deload detection

Expected:

Higher fatigue

↓

Lower readiness

↓

Reduced workload recommendation

---

# 9. Progress Engine Benchmarks

Validate:

- weight trends
- strength progression
- consistency score
- plateau detection

Expected outputs:

- Improving
- Stable
- Plateau
- Regression

---

# 10. Decision Engine Benchmarks

This is the most important benchmark.

Input:

Workout

+

Nutrition

+

Recovery

+

Progress

↓

Expected decision

Example:

Recovery = Low

Training Load = High

Goal = Muscle Gain

Expected:

Reduce training volume

Maintain calories

Increase recovery

Every recommendation must match expected business rules.

---

# 11. Explainable AI Benchmarks

Every explanation should answer:

1. What happened?

2. Why?

3. Which data was used?

4. What should the user do?

Responses are evaluated for:

- clarity
- correctness
- completeness
- coaching quality

---

# 12. AI Provider Comparison

Every supported model is evaluated using identical benchmark scenarios.

Example:

| Provider | Decision Accuracy | Explanation Quality | Latency |
|-----------|------------------|---------------------|---------|
| Local AI | 100% | Medium | Excellent |
| Gemini | 100% | Excellent | Good |
| OpenAI | 100% | Excellent | Good |
| Claude | 100% | Excellent | Good |

Decision quality should remain identical.

Only explanation quality may differ.

---

# 13. Performance Benchmarks

Target execution times.

| Operation | Target |
|-----------|---------|
| Local Recommendation | <100 ms |
| Decision Engine | <50 ms |
| Local Explanation | <500 ms |
| Cloud Explanation | <10 s |
| Routine Generation (Local) | <2 s |
| Routine Generation (Cloud) | <10 s |

---

# 14. Offline Benchmarks

Disconnect the network.

Verify:

- workout generation (Local AI)
- workout execution
- recovery analysis
- nutrition calculations
- progress analysis
- decision engine
- deterministic explanations

Cloud-only features should fail gracefully.

---

# 15. Regression Benchmarks

Every release executes the complete benchmark suite.

Compare with previous versions.

Metrics:

- recommendation consistency
- execution time
- explanation quality
- scientific validity

No regression should be introduced.

---

# 16. Release Gates

A release is approved only if:

✓ All benchmark scenarios pass

✓ No safety violation detected

✓ Performance targets met

✓ No regression introduced

✓ AI validation successful

---

# 17. Continuous Benchmarking

Benchmarks should run automatically:

- before every release
- on Pull Requests affecting AI
- after prompt updates
- after engine modifications
- after model upgrades

Results should be archived to monitor long-term quality trends.

---

# 18. Benchmark Evolution

The benchmark suite is a living document.

As GymGenius grows, new scenarios should be added for:

- wearable integrations
- Health Connect
- Apple Health
- injury management
- adaptive periodization
- predictive coaching
- country-specific nutrition
- new AI providers

Old benchmark scenarios should never be removed to preserve backward compatibility.

---

# Final Principle

> A new AI model is not considered better because it generates more impressive text.

> It is considered better only if it consistently produces recommendations that are equally correct, scientifically valid, explainable, safe, and measurable according to the GymGenius Benchmark Suite.