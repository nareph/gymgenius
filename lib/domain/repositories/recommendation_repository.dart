// lib/domain/repositories/recommendation_repository.dart

import 'package:gymgenius/domain/entities/ai_recommendation.dart';

/// Contract for AI/Decision recommendation persistence operations.
abstract interface class RecommendationRepository {
  Future<AIRecommendation?> getLatestRecommendation(String userId);
  Future<void> saveRecommendation(AIRecommendation recommendation);
  Future<List<AIRecommendation>> getRecommendations(String userId,
      {DateTime? from, DateTime? to});
}
