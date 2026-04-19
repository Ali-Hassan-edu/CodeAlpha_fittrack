import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';
import '../models/models.dart';
import '../services/firebase_service.dart';

class LogWorkoutScreen extends StatefulWidget {
  const LogWorkoutScreen({super.key});

  @override
  State<LogWorkoutScreen> createState() => _LogWorkoutScreenState();
}

class _LogWorkoutScreenState extends State<LogWorkoutScreen> {
  final _service = FirestoreService();

  // Form state
  String _exerciseType = 'Cardio';
  String _exerciseName = '';
  int _durationMinutes = 30;
  double _caloriesBurned = 0;
  int _steps = 0;
  double _distanceKm = 0;
  int _sets = 0;
  int _reps = 0;
  double _weightKg = 0;
  int _heartRate = 0;
  WorkoutIntensity _intensity = WorkoutIntensity.moderate;
  String _notes = '';
  bool _loading = false;

  static const _exerciseTypes = [
    ('Cardio', Icons.directions_run_rounded),
    ('Strength', Icons.fitness_center_rounded),
    ('Cycling', Icons.directions_bike_rounded),
    ('Swimming', Icons.pool_rounded),
    ('Yoga', Icons.self_improvement_rounded),
    ('HIIT', Icons.bolt_rounded),
    ('Other', Icons.sports_rounded),
  ];

  static const _cardioExercises = [
    'Running',
    'Walking',
    'Jogging',
    'Treadmill',
    'Elliptical',
    'Jump Rope',
    'Stair Climber'
  ];
  static const _strengthExercises = [
    'Bench Press',
    'Squat',
    'Deadlift',
    'Pull-Ups',
    'Push-Ups',
    'Overhead Press',
    'Rows',
    'Lunges',
    'Plank'
  ];
  static const _otherExercises = [
    'Cycling',
    'Swimming',
    'Yoga',
    'Pilates',
    'HIIT Circuit',
    'CrossFit',
    'Dance',
    'Boxing',
    'Rock Climbing'
  ];

  List<String> get _exercises {
    switch (_exerciseType) {
      case 'Strength':
        return _strengthExercises;
      case 'Cardio':
        return _cardioExercises;
      default:
        return _otherExercises;
    }
  }

  double _estimateCalories() {
    // METs-based estimation
    final metMap = {
      'Running': 9.8,
      'Walking': 3.5,
      'Jogging': 7.0,
      'Cycling': 6.8,
      'Swimming': 7.0,
      'HIIT Circuit': 10.0,
      'Yoga': 3.0,
      'Bench Press': 4.0,
      'Squat': 5.0,
      'Deadlift': 5.0,
    };
    final met = metMap[_exerciseName] ?? 5.0;
    const weight = 70.0; // default; ideally from user profile
    return met * weight * (_durationMinutes / 60);
  }

  Future<void> _logWorkout() async {
    if (_exerciseName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select or enter an exercise.')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final calories =
          _caloriesBurned > 0 ? _caloriesBurned : _estimateCalories();
      final log = WorkoutLog(
        id: const Uuid().v4(),
        userId: FirebaseAuth.instance.currentUser?.uid ?? '',
        exerciseType: _exerciseType,
        exerciseName: _exerciseName,
        durationMinutes: _durationMinutes,
        caloriesBurned: calories,
        steps: _steps > 0 ? _steps : null,
        distanceKm: _distanceKm > 0 ? _distanceKm : null,
        sets: _sets > 0 ? _sets : null,
        reps: _reps > 0 ? _reps : null,
        weightKg: _weightKg > 0 ? _weightKg : null,
        heartRateBpm: _heartRate > 0 ? _heartRate : null,
        notes: _notes.isNotEmpty ? _notes : null,
        loggedAt: DateTime.now(),
        intensity: _intensity,
      );
      await _service.addWorkoutLog(log);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '🎉 $_exerciseName logged! ${calories.toInt()} kcal burned.'),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving workout: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withOpacity(0.85),
        title: const Text('Log Workout'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Exercise Type Chips
            const _SectionLabel('ACTIVITY TYPE'),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _exerciseTypes.map((t) {
                  final isSelected = _exerciseType == t.$1;
                  return GestureDetector(
                    onTap: () => setState(() {
                      _exerciseType = t.$1;
                      _exerciseName = '';
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: isSelected ? AppColors.kineticGradient : null,
                        color: isSelected
                            ? null
                            : AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Icon(t.$2,
                              size: 18,
                              color: isSelected
                                  ? AppColors.onPrimary
                                  : AppColors.onSurfaceVariant),
                          const SizedBox(width: 8),
                          Text(t.$1,
                              style: TextStyle(
                                  fontFamily: 'Lexend',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? AppColors.onPrimary
                                      : AppColors.onSurface)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
            // ── Exercise Name
            const _SectionLabel('EXERCISE NAME'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _exercises.map((e) {
                final isSelected = _exerciseName == e;
                return GestureDetector(
                  onTap: () => setState(() => _exerciseName = e),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryContainer.withOpacity(0.5)
                          : AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(10),
                      border: isSelected
                          ? Border.all(color: AppColors.primary, width: 1.5)
                          : null,
                    ),
                    child: Text(e,
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.onSurface,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            // ── Duration
            const _SectionLabel('DURATION (MINUTES)'),
            const SizedBox(height: 8),
            _NumberField(
              value: _durationMinutes.toDouble(),
              min: 1,
              max: 300,
              onChanged: (v) => setState(() => _durationMinutes = v.toInt()),
              suffix: 'min',
            ),
            const SizedBox(height: 20),
            // ── Intensity
            const _SectionLabel('INTENSITY'),
            const SizedBox(height: 12),
            Row(
              children: WorkoutIntensity.values.map((i) {
                final isSelected = _intensity == i;
                final colors = {
                  WorkoutIntensity.low: (
                    AppColors.secondary,
                    AppColors.secondaryFixed
                  ),
                  WorkoutIntensity.moderate: (
                    AppColors.primary,
                    AppColors.primaryContainer
                  ),
                  WorkoutIntensity.high: (
                    AppColors.tertiary,
                    AppColors.tertiaryContainer
                  ),
                  WorkoutIntensity.extreme: (
                    AppColors.error,
                    AppColors.errorContainer
                  ),
                };
                final c = colors[i]!;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _intensity = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? c.$1
                            : AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        i.name.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: 'Lexend',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? Colors.white
                                : AppColors.onSurfaceVariant,
                            letterSpacing: 0.5),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            // ── Advanced Fields
            if (_exerciseType == 'Cardio' || _exerciseType == 'Cycling') ...[
              Row(
                children: [
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        const _SectionLabel('STEPS'),
                        const SizedBox(height: 8),
                        _NumberField(
                            value: _steps.toDouble(),
                            min: 0,
                            max: 50000,
                            onChanged: (v) =>
                                setState(() => _steps = v.toInt()),
                            suffix: 'steps'),
                      ])),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        const _SectionLabel('DISTANCE (KM)'),
                        const SizedBox(height: 8),
                        _NumberField(
                            value: _distanceKm,
                            min: 0,
                            max: 100,
                            onChanged: (v) => setState(() => _distanceKm = v),
                            suffix: 'km',
                            isDecimal: true),
                      ])),
                ],
              ),
              const SizedBox(height: 20),
            ],
            if (_exerciseType == 'Strength') ...[
              Row(
                children: [
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        const _SectionLabel('SETS'),
                        const SizedBox(height: 8),
                        _NumberField(
                            value: _sets.toDouble(),
                            min: 0,
                            max: 20,
                            onChanged: (v) => setState(() => _sets = v.toInt()),
                            suffix: 'sets'),
                      ])),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        const _SectionLabel('REPS'),
                        const SizedBox(height: 8),
                        _NumberField(
                            value: _reps.toDouble(),
                            min: 0,
                            max: 100,
                            onChanged: (v) => setState(() => _reps = v.toInt()),
                            suffix: 'reps'),
                      ])),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        const _SectionLabel('WEIGHT (KG)'),
                        const SizedBox(height: 8),
                        _NumberField(
                            value: _weightKg,
                            min: 0,
                            max: 300,
                            onChanged: (v) => setState(() => _weightKg = v),
                            suffix: 'kg',
                            isDecimal: true),
                      ])),
                ],
              ),
              const SizedBox(height: 20),
            ],
            // ── Heart Rate (Advanced)
            Row(
              children: [
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      const _SectionLabel('AVG HEART RATE'),
                      const SizedBox(height: 8),
                      _NumberField(
                          value: _heartRate.toDouble(),
                          min: 0,
                          max: 220,
                          onChanged: (v) =>
                              setState(() => _heartRate = v.toInt()),
                          suffix: 'bpm'),
                    ])),
                const SizedBox(width: 12),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      const _SectionLabel('CALORIES (LEAVE 0 TO AUTO)'),
                      const SizedBox(height: 8),
                      _NumberField(
                          value: _caloriesBurned,
                          min: 0,
                          max: 5000,
                          onChanged: (v) => setState(() => _caloriesBurned = v),
                          suffix: 'kcal',
                          isDecimal: true),
                    ])),
              ],
            ),
            const SizedBox(height: 20),
            // ── Notes
            const _SectionLabel('NOTES (OPTIONAL)'),
            const SizedBox(height: 8),
            TextField(
              onChanged: (v) => _notes = v,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'How did it feel? Personal best?',
                border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.all(Radius.circular(20))),
              ),
            ),
            const SizedBox(height: 36),
            KineticButton(
                label: 'Log Workout',
                onPressed: _logWorkout,
                isLoading: _loading),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
            fontFamily: 'Lexend',
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurfaceVariant,
            letterSpacing: 1.2),
      );
}

class _NumberField extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final String suffix;
  final bool isDecimal;

  const _NumberField({
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.suffix,
    this.isDecimal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (value > min) onChanged(value - (isDecimal ? 0.1 : 1));
            },
            child: const Icon(Icons.remove_rounded,
                color: AppColors.onSurfaceVariant, size: 20),
          ),
          Expanded(
            child: Text(
              isDecimal ? value.toStringAsFixed(1) : value.toInt().toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: AppColors.onSurface),
            ),
          ),
          Text(suffix,
              style: const TextStyle(
                  fontFamily: 'Lexend',
                  fontSize: 10,
                  color: AppColors.onSurfaceVariant)),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              if (value < max) onChanged(value + (isDecimal ? 0.1 : 1));
            },
            child: const Icon(Icons.add_rounded,
                color: AppColors.primary, size: 20),
          ),
        ],
      ),
    );
  }
}
