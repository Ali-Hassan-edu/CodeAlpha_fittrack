import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/models.dart';

// ─── Auth Service ──────────────────────────────────────────────────────────────
class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;
  String? get uid => _auth.currentUser?.uid;

  Future<UserCredential> signInWithEmail(String email, String password) =>
      _auth.signInWithEmailAndPassword(email: email, password: password);

  Future<UserCredential> signUpWithEmail(
    String email,
    String password,
    String name,
  ) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await cred.user?.updateDisplayName(name);
    return cred;
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email);
}

// ─── Firestore Service ─────────────────────────────────────────────────────────
class FirestoreService {
  final _db = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  // ── User Profile ─────────────────────────────────────────────────────────────
  Future<void> createUserProfile(UserProfile profile) =>
      _db.collection('users').doc(profile.uid).set(profile.toFirestore());

  Future<UserProfile?> getUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.exists ? UserProfile.fromFirestore(doc) : null;
  }

  Stream<UserProfile?> userProfileStream(String uid) => _db
      .collection('users')
      .doc(uid)
      .snapshots()
      .map((d) => d.exists ? UserProfile.fromFirestore(d) : null);

  Future<void> updateUserProfile(String uid, Map<String, dynamic> fields) =>
      _db.collection('users').doc(uid).update(fields);

  Future<String?> uploadAvatar(String uid, File imageFile) async {
    final ref = _storage.ref('avatars/$uid.jpg');
    await ref.putFile(imageFile);
    return ref.getDownloadURL();
  }

  // ── Workout Logs ──────────────────────────────────────────────────────────────
  Future<void> addWorkoutLog(WorkoutLog log) async {
    final ref = await _db
        .collection('users')
        .doc(_uid)
        .collection('workouts')
        .add(log.toFirestore());
    // Also update daily summary
    await _upsertDailySummary(log);
  }

  Future<void> updateWorkoutLog(String logId, Map<String, dynamic> fields) =>
      _db
          .collection('users')
          .doc(_uid)
          .collection('workouts')
          .doc(logId)
          .update(fields);

  Future<void> deleteWorkoutLog(String logId) =>
      _db
          .collection('users')
          .doc(_uid)
          .collection('workouts')
          .doc(logId)
          .delete();

  Stream<List<WorkoutLog>> workoutsStream({int limit = 30}) => _db
      .collection('users')
      .doc(_uid)
      .collection('workouts')
      .orderBy('loggedAt', descending: true)
      .limit(limit)
      .snapshots()
      .map((s) => s.docs.map(WorkoutLog.fromFirestore).toList());

  Stream<List<WorkoutLog>> workoutsForDateStream(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return _db
        .collection('users')
        .doc(_uid)
        .collection('workouts')
        .where('loggedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('loggedAt', isLessThan: Timestamp.fromDate(end))
        .orderBy('loggedAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(WorkoutLog.fromFirestore).toList());
  }

  // ── Daily Summary ─────────────────────────────────────────────────────────────
  String _summaryId(DateTime date) =>
      '${_uid}_${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  Future<void> _upsertDailySummary(WorkoutLog log) async {
    final id = _summaryId(log.loggedAt);
    final ref = _db.collection('daily_summaries').doc(id);
    final doc = await ref.get();

    if (doc.exists) {
      await ref.update({
        'totalCaloriesBurned':
            FieldValue.increment(log.caloriesBurned),
        'totalActiveMinutes': FieldValue.increment(log.durationMinutes),
        'workoutCount': FieldValue.increment(1),
        'totalSteps': FieldValue.increment(log.steps ?? 0),
        'totalDistanceKm': FieldValue.increment(log.distanceKm ?? 0),
      });
    } else {
      await ref.set(DailySummary(
        id: id,
        userId: _uid,
        date: log.loggedAt,
        totalCaloriesBurned: log.caloriesBurned,
        totalActiveMinutes: log.durationMinutes,
        workoutCount: 1,
        totalSteps: log.steps ?? 0,
        totalDistanceKm: log.distanceKm ?? 0,
      ).toFirestore());
    }
  }

  Future<void> updateDailySummary(
    DateTime date,
    Map<String, dynamic> fields,
  ) async {
    final id = _summaryId(date);
    final ref = _db.collection('daily_summaries').doc(id);
    final doc = await ref.get();
    if (doc.exists) {
      await ref.update(fields);
    } else {
      await ref.set({
        'userId': _uid,
        'date': Timestamp.fromDate(date),
        ...fields,
      }, SetOptions(merge: true));
    }
  }

  Stream<DailySummary?> dailySummaryStream(DateTime date) {
    final id = _summaryId(date);
    return _db
        .collection('daily_summaries')
        .doc(id)
        .snapshots()
        .map((d) => d.exists ? DailySummary.fromFirestore(d) : null);
  }

  Stream<List<DailySummary>> weeklySummariesStream() {
    final start = DateTime.now().subtract(const Duration(days: 7));
    return _db
        .collection('daily_summaries')
        .where('userId', isEqualTo: _uid)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .orderBy('date', descending: false)
        .snapshots()
        .map((s) => s.docs.map(DailySummary.fromFirestore).toList());
  }

  // ── Goals ─────────────────────────────────────────────────────────────────────
  Future<void> addGoal(FitnessGoal goal) =>
      _db
          .collection('users')
          .doc(_uid)
          .collection('goals')
          .doc(goal.id)
          .set(goal.toFirestore());

  Future<void> updateGoal(String goalId, Map<String, dynamic> fields) =>
      _db
          .collection('users')
          .doc(_uid)
          .collection('goals')
          .doc(goalId)
          .update(fields);

  Future<void> deleteGoal(String goalId) =>
      _db
          .collection('users')
          .doc(_uid)
          .collection('goals')
          .doc(goalId)
          .delete();

  Stream<List<FitnessGoal>> goalsStream() => _db
      .collection('users')
      .doc(_uid)
      .collection('goals')
      .orderBy('targetDate')
      .snapshots()
      .map((s) => s.docs.map(FitnessGoal.fromFirestore).toList());

  // ── Achievements (Advanced) ───────────────────────────────────────────────────
  Stream<List<Achievement>> achievementsStream() => _db
      .collection('users')
      .doc(_uid)
      .collection('achievements')
      .orderBy('unlockedAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map(Achievement.fromFirestore).toList());

  Future<void> unlockAchievement(Achievement a) =>
      _db
          .collection('users')
          .doc(_uid)
          .collection('achievements')
          .doc(a.id)
          .set(a.toFirestore());

  // ── Analytics helpers (Advanced) ─────────────────────────────────────────────
  Future<Map<String, double>> getWeeklyCalorieTrend() async {
    final docs = await _db
        .collection('daily_summaries')
        .where('userId', isEqualTo: _uid)
        .where(
          'date',
          isGreaterThanOrEqualTo: Timestamp.fromDate(
            DateTime.now().subtract(const Duration(days: 7)),
          ),
        )
        .orderBy('date')
        .get();
    return {
      for (final d in docs.docs)
        (d['date'] as Timestamp)
                .toDate()
                .weekday
                .toString():
            (d['totalCaloriesBurned'] ?? 0).toDouble()
    };
  }
}
