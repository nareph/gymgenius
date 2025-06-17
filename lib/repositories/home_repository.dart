import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gymgenius/models/onboarding.dart';
import 'package:gymgenius/models/routine.dart';
import 'package:gymgenius/services/logger_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class HomeRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _uuid = const Uuid();

  User? get _currentUser => _auth.currentUser;

  Stream<DocumentSnapshot<Map<String, dynamic>>>? getUserProfileStream() {
    if (_currentUser == null) return null;
    return _firestore.collection('users').doc(_currentUser!.uid).snapshots();
  }

  Future<WeeklyRoutine> generateNewRoutine(
      OnboardingData onboardingData, WeeklyRoutine? previousRoutine) async {
    try {
      final callable = _functions.httpsCallable(
        'generateAiRoutine',
        options: HttpsCallableOptions(timeout: const Duration(seconds: 120)),
      );

      final Map<String, dynamic> payload = {
        'onboardingData': onboardingData.toMap()
      };
      if (previousRoutine != null) {
        payload['previousRoutineData'] =
            previousRoutine.toMapForCloudFunction();
      }

      Log.debug("HomeRepository: Calling Cloud Function 'generateAiRoutine'.");
      final result = await callable.call(payload);

      final aiRoutineData = Map<String, dynamic>.from(result.data as Map);

      final String newRoutineId = _uuid.v4();
      Map<String, dynamic> dailyWorkoutsFromAIConverted = {};
      final dynamic rawDailyWorkouts = aiRoutineData['dailyWorkouts'];

      if (rawDailyWorkouts is Map) {
        rawDailyWorkouts.forEach((dayKey, exercisesForDay) {
          if (dayKey is String && exercisesForDay is List) {
            dailyWorkoutsFromAIConverted[dayKey.toLowerCase()] = exercisesForDay
                .map((exercise) => exercise is Map
                    ? Map<String, dynamic>.from(exercise)
                    : null)
                .where((item) => item != null)
                .toList()
                .cast<Map<String, dynamic>>();
          }
        });
      }

      int durationInWeeks =
          (aiRoutineData['durationInWeeks'] as num?)?.toInt() ?? 4;
      durationInWeeks = durationInWeeks.clamp(1, 12);

      final newRoutine = WeeklyRoutine.fromMap({
        'id': newRoutineId,
        'name': aiRoutineData['name'] as String? ?? "My New Routine",
        'durationInWeeks': durationInWeeks,
        'dailyWorkouts': dailyWorkoutsFromAIConverted,
        'generatedAt': Timestamp.now(),
        'expiresAt': Timestamp.fromDate(
            DateTime.now().add(Duration(days: durationInWeeks * 7))),
      });

      await _firestore.collection('users').doc(_currentUser!.uid).update({
        'currentRoutine': newRoutine.toMapForFirestore(),
        'lastRoutineGeneratedAt': FieldValue.serverTimestamp(),
      });

      await cacheRoutineData(newRoutine);
      return newRoutine;
    } catch (e, s) {
      Log.error("HomeRepository: Error generating routine",
          error: e, stackTrace: s);
      rethrow;
    }
  }

  Future<void> clearCurrentRoutine() async {
    if (_currentUser == null) return;
    await _firestore
        .collection('users')
        .doc(_currentUser!.uid)
        .update({'currentRoutine': null});
    await clearRoutineCache();
  }

  Future<void> cacheRoutineData(WeeklyRoutine routine) async {
    if (_currentUser == null) return;
    final prefs = await SharedPreferences.getInstance();
    final routineMap = routine.toMapForFirestore();
    routineMap['generatedAt'] =
        routineMap['generatedAt']?.millisecondsSinceEpoch;
    routineMap['expiresAt'] = routineMap['expiresAt']?.millisecondsSinceEpoch;
    await prefs.setString(
        'cached_routine_${_currentUser!.uid}', json.encode(routineMap));
  }

  Future<void> cacheOnboardingData(OnboardingData data) async {
    if (_currentUser == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'cached_onboarding_${_currentUser!.uid}', json.encode(data.toMap()));
  }

  Future<(WeeklyRoutine?, OnboardingData?)> loadCachedData() async {
    if (_currentUser == null) return (null, null);
    final prefs = await SharedPreferences.getInstance();
    WeeklyRoutine? cachedRoutine;
    OnboardingData? cachedOnboardingData;

    final routineJson = prefs.getString('cached_routine_${_currentUser!.uid}');
    if (routineJson != null) {
      final routineMap = json.decode(routineJson) as Map<String, dynamic>;
      if (routineMap['generatedAt'] != null) {
        routineMap['generatedAt'] =
            Timestamp.fromMillisecondsSinceEpoch(routineMap['generatedAt']);
      }
      if (routineMap['expiresAt'] != null) {
        routineMap['expiresAt'] =
            Timestamp.fromMillisecondsSinceEpoch(routineMap['expiresAt']);
      }
      cachedRoutine = WeeklyRoutine.fromMap(routineMap);
      if (cachedRoutine.isExpired()) {
        await clearRoutineCache();
        cachedRoutine = null;
      }
    }

    final onboardingJson =
        prefs.getString('cached_onboarding_${_currentUser!.uid}');
    if (onboardingJson != null) {
      cachedOnboardingData =
          OnboardingData.fromMap(json.decode(onboardingJson));
    }

    return (cachedRoutine, cachedOnboardingData);
  }

  Future<void> clearRoutineCache() async {
    if (_currentUser == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cached_routine_${_currentUser!.uid}');
  }

  Future<bool> checkInternetConnection() async {
    if (_currentUser == null) return false;
    try {
      await _firestore
          .collection('users')
          .doc(_currentUser!.uid)
          .get(const GetOptions(source: Source.server))
          .timeout(const Duration(seconds: 4));
      return true;
    } catch (e) {
      return false;
    }
  }
}
