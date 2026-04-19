import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';
import '../models/models.dart';
import '../services/firebase_service.dart';

class DashboardScreen extends StatelessWidget {
  final UserProfile user;
  const DashboardScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final service = FirestoreService();
    final today = DateTime.now();
    final firstName = user.name.split(' ').first;

    return StreamBuilder<DailySummary?>(
      stream: service.dailySummaryStream(today),
      builder: (context, snap) {
        final s = snap.data;
        return CustomScrollView(
          slivers: [
            // ── Inline App Bar (no duplicate from HomeShell since HomeShell
            //    no longer has its own AppBar)
            SliverAppBar(
              pinned: true,
              backgroundColor: AppColors.background,
              surfaceTintColor: Colors.transparent,
              automaticallyImplyLeading: false,
              leading: Builder(
                builder: (ctx) => IconButton(
                  icon: const Icon(Icons.menu_rounded,
                      color: AppColors.onSurface),
                  onPressed: () => Scaffold.of(ctx).openDrawer(),
                ),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Good ${_greeting()}, $firstName 👋',
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const Text(
                    "Let's crush today",
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: AppColors.kineticGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.notifications_outlined,
                      color: AppColors.onPrimary, size: 20),
                ),
              ],
            ),
            // ── Content — bottom padding 100 to clear nav bar
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _StepCard(
                    steps: s?.totalSteps ?? 0,
                    goal: user.dailyStepGoal,
                  ),
                  const SizedBox(height: 16),
                  // 4 stat cards in 2x2 grid
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _SimpleStatCard(
                              icon: Icons.local_fire_department_rounded,
                              value:
                                  '${(s?.totalCaloriesBurned ?? 0).toInt()}',
                              label: 'Calories',
                              unit: 'kcal',
                              color: AppColors.tertiary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _SimpleStatCard(
                              icon: Icons.timer_outlined,
                              value: '${s?.totalActiveMinutes ?? 0}',
                              label: 'Active',
                              unit: 'min',
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _SimpleStatCard(
                              icon: Icons.route_outlined,
                              value: (s?.totalDistanceKm ?? 0)
                                  .toStringAsFixed(1),
                              label: 'Distance',
                              unit: 'km',
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _SimpleStatCard(
                              icon: Icons.fitness_center_rounded,
                              value: '${s?.workoutCount ?? 0}',
                              label: 'Workouts',
                              unit: 'done',
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _WaterCard(
                    current: s?.waterIntakeLiters ?? 0,
                    onAdd: () async {
                      try {
                        await service.updateDailySummary(today, {
                          'waterIntakeLiters':
                              FieldValue.increment(0.25),
                        });
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: const Text('💧 +250ml added'),
                            backgroundColor: AppColors.secondary,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ));
                        }
                      } catch (_) {}
                    },
                  ),
                  const SizedBox(height: 16),
                  _MoodCard(
                    mood: s?.moodScore ?? 3,
                    onSelect: (m) {
                      try {
                        service.updateDailySummary(
                            today, {'moodScore': m});
                      } catch (_) {}
                    },
                  ),
                  const SizedBox(height: 16),
                  _WeeklyCard(service: service),
                  const SizedBox(height: 16),
                  _TodayWorkouts(service: service, today: today),
                ]),
              ),
            ),
          ],
        );
      },
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Morning';
    if (h < 17) return 'Afternoon';
    return 'Evening';
  }
}

// ─── Step Hero Card ────────────────────────────────────────────────────────────
class _StepCard extends StatelessWidget {
  final int steps;
  final int goal;
  const _StepCard({required this.steps, required this.goal});

  @override
  Widget build(BuildContext context) {
    final progress = goal > 0 ? (steps / goal).clamp(0.0, 1.0) : 0.0;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Today's Steps",
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  steps.toString(),
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 44,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface,
                    letterSpacing: -1,
                  ),
                ),
                Text(
                  'of $goal goal',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppColors.surfaceContainerHighest,
                    valueColor:
                        const AlwaysStoppedAnimation(AppColors.primary),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          ProgressRing(
            progress: progress,
            size: 100,
            strokeWidth: 10,
            child: Text(
              '${(progress * 100).toInt()}%',
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Simple Stat Card ──────────────────────────────────────────────────────────
class _SimpleStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final String unit;
  final Color color;
  const _SimpleStatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                    text: TextSpan(children: [
                  TextSpan(
                      text: value,
                      style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.onSurface)),
                  TextSpan(
                      text: ' $unit',
                      style: const TextStyle(
                          fontFamily: 'Lexend',
                          fontSize: 10,
                          color: AppColors.onSurfaceVariant)),
                ])),
                Text(label,
                    style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        color: AppColors.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Water Card ────────────────────────────────────────────────────────────────
class _WaterCard extends StatelessWidget {
  final double current;
  final VoidCallback onAdd;
  const _WaterCard({required this.current, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    const goal = 2.5;
    final pct = (current / goal).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          ProgressRing(
            progress: pct,
            size: 60,
            strokeWidth: 6,
            progressColor: AppColors.secondary,
            trackColor: AppColors.secondaryFixed,
            child: const Icon(Icons.water_drop_rounded,
                color: AppColors.secondary, size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Water Intake',
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: AppColors.onSurfaceVariant)),
                const SizedBox(height: 2),
                Text(
                  '${current.toStringAsFixed(1)} / ${goal.toStringAsFixed(1)} L',
                  style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onAdd,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                  gradient: AppColors.kineticGradient,
                  borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.add_rounded,
                  color: AppColors.onPrimary, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Mood Card ─────────────────────────────────────────────────────────────────
class _MoodCard extends StatelessWidget {
  final int mood;
  final ValueChanged<int> onSelect;
  const _MoodCard({required this.mood, required this.onSelect});

  static const _moods = ['😞', '😕', '😐', '🙂', '😄'];
  static const _labels = ['Rough', 'Meh', 'Okay', 'Good', 'Great'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('How are you feeling?',
              style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(5, (i) {
              final isSelected = mood == i + 1;
              return GestureDetector(
                onTap: () => onSelect(i + 1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryContainer.withOpacity(0.35)
                        : AppColors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(14),
                    border: isSelected
                        ? Border.all(color: AppColors.primary, width: 2)
                        : null,
                  ),
                  child: Column(
                    children: [
                      Text(_moods[i],
                          style: TextStyle(fontSize: isSelected ? 26 : 20)),
                      const SizedBox(height: 4),
                      Text(_labels[i],
                          style: TextStyle(
                            fontFamily: 'Lexend',
                            fontSize: 9,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.outlineVariant,
                            fontWeight: FontWeight.w600,
                          )),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ─── Weekly Chart Card ─────────────────────────────────────────────────────────
class _WeeklyCard extends StatelessWidget {
  final FirestoreService service;
  const _WeeklyCard({required this.service});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<DailySummary>>(
      stream: service.weeklySummariesStream(),
      builder: (ctx, snap) {
        final summaries = snap.data ?? [];
        final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
        final values = List.generate(7, (i) {
          try {
            return summaries
                .firstWhere((s) => s.date.weekday == i + 1)
                .totalCaloriesBurned;
          } catch (_) {
            return 0.0;
          }
        });
        final maxVal =
            values.isEmpty ? 1.0 : values.reduce((a, b) => a > b ? a : b);
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Weekly Calories',
                  style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface)),
              const SizedBox(height: 20),
              SizedBox(
                height: 110,
                child: WeeklyBarChart(
                  values: values,
                  labels: days,
                  selectedIndex: DateTime.now().weekday - 1,
                  maxValue: maxVal > 0 ? maxVal : 1,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Today Workouts ────────────────────────────────────────────────────────────
class _TodayWorkouts extends StatelessWidget {
  final FirestoreService service;
  final DateTime today;
  const _TodayWorkouts({required this.service, required this.today});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<WorkoutLog>>(
      stream: service.workoutsForDateStream(today),
      builder: (ctx, snap) {
        final list = snap.data ?? [];
        if (list.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Today's Workouts",
              style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface),
            ),
            const SizedBox(height: 12),
            ...list.map((w) => WorkoutTile(
                  exerciseName: w.exerciseName,
                  exerciseType: w.exerciseType,
                  durationMinutes: w.durationMinutes,
                  caloriesBurned: w.caloriesBurned,
                  intensity:
                      WorkoutIntensityBadge.fromLevel(w.intensity.name),
                  onDelete: () => service.deleteWorkoutLog(w.id),
                )),
          ],
        );
      },
    );
  }
}

