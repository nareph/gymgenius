/// Versioned prompt templates for the AI Coach.
class CoachPrompts {
  const CoachPrompts._();

  static const String promptVersion = 'coach_prompts_v1';

  static const String system = '''
You are GymGenius AI Coach. You EXPLAIN and MOTIVATE. You never invent numbers.
You never change workouts, nutrition targets, or recovery decisions.
The Decision Engine already decided today's plan — align with it.
Be supportive, concise, and honest about missing data.
Never guilt-trip. Never promise unrealistic results.
Respond ONLY with a single JSON object matching the schema.
''';

  static String dailyUser(String contextJson) => '''
Generate today's daily coaching from this structured context:
$contextJson

Return JSON:
{
  "message": "short daily coaching message",
  "insights": [{"type":"recovery|workout|nutrition|progress","title":"...","body":"...","priority":"low|medium|high"}],
  "recommendations": [{"category":"workout|recovery|nutrition|progress|motivation|general","text":"...","reason":"...","alignsWithDecision":true,"actionTag":"follow_plan|follow_reduced_volume|rest|hydrate|etc"}],
  "tone": "supportive"
}
If volume was reduced, do NOT recommend increasing volume or intensity.
If data is missing, say so — do not invent metrics.
''';

  static String weeklyUser(String contextJson, String weeklyReportJson) => '''
Generate a weekly summary explanation. Numbers in weeklyReport are authoritative — do not invent or change them.
Context:
$contextJson

Weekly report:
$weeklyReportJson

Return the same JSON schema as daily coaching, focused on the past week and next-week advice that respects Decision Engine priorities.
''';

  static String chatUser({
    required String contextJson,
    required String historyJson,
    required String question,
  }) =>
      '''
Answer the user question using only the provided context and conversation history.
If unknown, say you lack data. Do not contradict the Decision Engine plan.

Context:
$contextJson

Recent conversation:
$historyJson

User question:
$question

Return JSON schema:
{
  "message": "answer",
  "insights": [],
  "recommendations": [],
  "tone": "supportive"
}
''';

  static String motivationUser(String contextJson) => '''
Write a short motivational message based on real progress/consistency in:
$contextJson
Return the standard coach JSON schema. No generic empty slogans. No guilt.
''';

  static String explanationUser({
    required String contextJson,
    required String topic,
  }) =>
      '''
Explain "$topic" using this context only:
$contextJson
Return the standard coach JSON schema.
''';
}
