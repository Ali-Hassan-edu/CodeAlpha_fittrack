import 'package:cloud_firestore/cloud_firestore.dart';

// ─── User Profile ──────────────────────────────────────────────────────────────
class UserProfile {
  final String uid;
  final String name;
  final String email;
  final String? avatarUrl;
  final int age;
  final double heightCm;
  final double weightKg;
  final String fitnessGoal; // 'lose_weight' | 'build_muscle' | 'maintain' | 'endurance'
  final int dailyStepGoal;
  final int dailyCalorieGoal;
  final int weeklyWorkoutGoal;
  final DateTime createdAt;

  const UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.age,
    required this.heightCm,
    required this.weightKg,
    required this.fitnessGoal,
    this.dailyStepGoal = 10000,
    this.dailyCalorieGoal = 500,
    this.weeklyWorkoutGoal = 4,
    required this.createdAt,
  });

  double get bmi => weightKg / ((heightCm / 100) * (heightCm / 100));

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return UserProfile(
      uid: doc.id,
      name: d['name'] ?? '',
      email: d['email'] ?? '',
      avatarUrl: d['avatarUrl'],
      age: d['age'] ?? 25,
      heightCm: (d['heightCm'] ?? 170).toDouble(),
      weightKg: (d['weightKg'] ?? 70).toDouble(),
      fitnessGoal: d['fitnessGoal'] ?? 'maintain',
      dailyStepGoal: d['dailyStepGoal'] ?? 10000,
      dailyCalorieGoal: d['dailyCalorieGoal'] ?? 500,
      weeklyWorkoutGoal: d['weeklyWorkoutGoal'] ?? 4,
      createdAt: (d['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'name': name,
    'email': email,
    'avatarUrl': avatarUrl,
    'age': age,
    'heightCm': heightCm,
    'weightKg': weightKg,
    'fitnessGoal': fitnessGoal,
    'dailyStepGoal': dailyStepGoal,
    'dailyCalorieGoal': dailyCalorieGoal,
    'weeklyWorkoutGoal': weeklyWorkoutGoal,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}

// ─── Workout Log ───────────────────────────────────────────────────────────────
class WorkoutLog {
  final String id;
  final String userId;
  final String exerciseType;     // e.g. 'Running', 'Cycling', 'Strength'
  final String exerciseName;
  final int durationMinutes;
  final double caloriesBurned;
  final int? steps;
  final double? distanceKm;
  final int? sets;
  final int? reps;
  final double? weightKg;
  final int? heartRateBpm;
  final String? notes;
  final DateTime loggedAt;
  final WorkoutIntensity intensity;

  const WorkoutLog({
    required this.id,
    required this.userId,
    required this.exerciseType,
    required this.exerciseName,
    required this.durationMinutes,
    required this.caloriesBurned,
    this.steps,
    this.distanceKm,
    this.sets,
    this.reps,
    this.weightKg,
    this.heartRateBpm,
    this.notes,
    required this.loggedAt,
    this.intensity = WorkoutIntensity.moderate,
  });

  factory WorkoutLog.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return WorkoutLog(
      id: doc.id,
      userId: d['userId'] ?? '',
      exerciseType: d['exerciseType'] ?? '',
      exerciseName: d['exerciseName'] ?? '',
      durationMinutes: d['durationMinutes'] ?? 0,
      caloriesBurned: (d['caloriesBurned'] ?? 0).toDouble(),
      steps: d['steps'],
      distanceKm: d['distanceKm']?.toDouble(),
      sets: d['sets'],
      reps: d['reps'],
      weightKg: d['weightKg']?.toDouble(),
      heartRateBpm: d['heartRateBpm'],
      notes: d['notes'],
      loggedAt: (d['loggedAt'] as Timestamp).toDate(),
      intensity: WorkoutIntensity.values.firstWhere(
        (e) => e.name == (d['intensity'] ?? 'moderate'),
        orElse: () => WorkoutIntensity.moderate,
      ),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'userId': userId,
    'exerciseType': exerciseType,
    'exerciseName': exerciseName,
    'durationMinutes': durationMinutes,
    'caloriesBurned': caloriesBurned,
    'steps': steps,
    'distanceKm': distanceKm,
    'sets': sets,
    'reps': reps,
    'weightKg': weightKg,
    'heartRateBpm': heartRateBpm,
    'notes': notes,
    'loggedAt': Timestamp.fromDate(loggedAt),
    'intensity': intensity.name,
  };
}

enum WorkoutIntensity { low, moderate, high, extreme }

// ─── Daily Summary ─────────────────────────────────────────────────────────────
class DailySummary {
  final String id;       // format: 'uid_yyyy-MM-dd'
  final String userId;
  final DateTime date;
  final int totalSteps;
  final double totalCaloriesBurned;
  final int totalActiveMinutes;
  final int workoutCount;
  final double totalDistanceKm;
  final double waterIntakeLiters;    // 🆕 advanced feature
  final double sleepHours;           // 🆕 advanced feature
  final int? avgHeartRate;           // 🆕 advanced feature
  final int? restingHeartRate;       // 🆕 advanced feature
  final int moodScore;               // 🆕 1-5 mood tracking
  final int? weightKg;               // 🆕 daily weight log

  const DailySummary({
    required this.id,
    required this.userId,
    required this.date,
    this.totalSteps = 0,
    this.totalCaloriesBurned = 0,
    this.totalActiveMinutes = 0,
    this.workoutCount = 0,
    this.totalDistanceKm = 0,
    this.waterIntakeLiters = 0,
    this.sleepHours = 0,
    this.avgHeartRate,
    this.restingHeartRate,
    this.moodScore = 3,
    this.weightKg,
  });

  factory DailySummary.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return DailySummary(
      id: doc.id,
      userId: d['userId'] ?? '',
      date: (d['date'] as Timestamp).toDate(),
      totalSteps: d['totalSteps'] ?? 0,
      totalCaloriesBurned: (d['totalCaloriesBurned'] ?? 0).toDouble(),
      totalActiveMinutes: d['totalActiveMinutes'] ?? 0,
      workoutCount: d['workoutCount'] ?? 0,
      totalDistanceKm: (d['totalDistanceKm'] ?? 0).toDouble(),
      waterIntakeLiters: (d['waterIntakeLiters'] ?? 0).toDouble(),
      sleepHours: (d['sleepHours'] ?? 0).toDouble(),
      avgHeartRate: d['avgHeartRate'],
      restingHeartRate: d['restingHeartRate'],
      moodScore: d['moodScore'] ?? 3,
      weightKg: d['weightKg'],
    );
  }

  Map<String, dynamic> toFirestore() => {
    'userId': userId,
    'date': Timestamp.fromDate(date),
    'totalSteps': totalSteps,
    'totalCaloriesBurned': totalCaloriesBurned,
    'totalActiveMinutes': totalActiveMinutes,
    'workoutCount': workoutCount,
    'totalDistanceKm': totalDistanceKm,
    'waterIntakeLiters': waterIntakeLiters,
    'sleepHours': sleepHours,
    'avgHeartRate': avgHeartRate,
    'restingHeartRate': restingHeartRate,
    'moodScore': moodScore,
    'weightKg': weightKg,
  };
}

// ─── Goal ──────────────────────────────────────────────────────────────────────
class FitnessGoal {
  final String id;
  final String userId;
  final String title;
  final String type;         // 'steps' | 'calories' | 'weight' | 'workout_count' | 'distance'
  final double targetValue;
  final double currentValue;
  final DateTime startDate;
  final DateTime targetDate;
  final bool isCompleted;
  final String? badge;        // 🆕 achievement badge name

  const FitnessGoal({
    required this.id,
    required this.userId,
    required this.title,
    required this.type,
    required this.targetValue,
    this.currentValue = 0,
    required this.startDate,
    required this.targetDate,
    this.isCompleted = false,
    this.badge,
  });

  double get progressPercent =>
      (currentValue / targetValue).clamp(0.0, 1.0);

  factory FitnessGoal.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return FitnessGoal(
      id: doc.id,
      userId: d['userId'] ?? '',
      title: d['title'] ?? '',
      type: d['type'] ?? 'steps',
      targetValue: (d['targetValue'] ?? 0).toDouble(),
      currentValue: (d['currentValue'] ?? 0).toDouble(),
      startDate: (d['startDate'] as Timestamp).toDate(),
      targetDate: (d['targetDate'] as Timestamp).toDate(),
      isCompleted: d['isCompleted'] ?? false,
      badge: d['badge'],
    );
  }

  Map<String, dynamic> toFirestore() => {
    'userId': userId,
    'title': title,
    'type': type,
    'targetValue': targetValue,
    'currentValue': currentValue,
    'startDate': Timestamp.fromDate(startDate),
    'targetDate': Timestamp.fromDate(targetDate),
    'isCompleted': isCompleted,
    'badge': badge,
  };
}

// ─── Achievement / Badge (Advanced Feature) ────────────────────────────────────
class Achievement {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String iconCode;      // Material icon codepoint hex
  final DateTime unlockedAt;

  const Achievement({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.iconCode,
    required this.unlockedAt,
  });

  factory Achievement.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Achievement(
      id: doc.id,
      userId: d['userId'] ?? '',
      title: d['title'] ?? '',
      description: d['description'] ?? '',
      iconCode: d['iconCode'] ?? 'e838',
      unlockedAt: (d['unlockedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'userId': userId,
    'title': title,
    'description': description,
    'iconCode': iconCode,
    'unlockedAt': Timestamp.fromDate(unlockedAt),
  };
}
