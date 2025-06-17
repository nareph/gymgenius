import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TrackingRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  TrackingRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  User? get _currentUser => _auth.currentUser;

  /// Provides a stream of the user's document, containing the current routine.
  Stream<DocumentSnapshot<Map<String, dynamic>>>? getUserDocumentStream() {
    if (_currentUser == null) return null;
    return _firestore.collection('users').doc(_currentUser!.uid).snapshots();
  }

  /// Provides a stream of all workout logs for the current user.
  Stream<QuerySnapshot<Map<String, dynamic>>>? getWorkoutLogsStream() {
    if (_currentUser == null) return null;
    return _firestore
        .collection('workout_logs')
        .where('userId', isEqualTo: _currentUser!.uid)
        .orderBy('savedAt', descending: true)
        .snapshots();
  }

  /// Fetches the detailed workout logs for a specific day.
  Future<List<Map<String, dynamic>>> getLogsForDay(DateTime day) async {
    if (_currentUser == null) return [];

    final startOfDay =
        Timestamp.fromDate(DateTime(day.year, day.month, day.day));
    final endOfDay = Timestamp.fromDate(
        DateTime(day.year, day.month, day.day).add(const Duration(days: 1)));

    final snapshot = await _firestore
        .collection('workout_logs')
        .where('userId', isEqualTo: _currentUser!.uid)
        .where('savedAt', isGreaterThanOrEqualTo: startOfDay)
        .where('savedAt', isLessThan: endOfDay)
        .orderBy('savedAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
  }
}
