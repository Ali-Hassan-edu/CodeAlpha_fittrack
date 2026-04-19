import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';
import '../models/models.dart';
import '../services/firebase_service.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen>
    with SingleTickerProviderStateMixin {
  final _service = FirestoreService();
  late final TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.surface.withOpacity(0.85),
            title: const Text('Progress & Goals',
                style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w700)),
            bottom: TabBar(
              controller: _tabCtrl,
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.onSurfaceVariant,
              labelStyle: const TextStyle(
                  fontFamily: 'Lexend',
                  fontWeight: FontWeight.w700,
                  fontSize: 12),
              tabs: const [Tab(text: 'ANALYTICS'), Tab(text: 'GOALS')],
            ),
          ),
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                _AnalyticsTab(service: _service),
                _GoalsTab(service: _service),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddGoalSheet(context),
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child:
            const Icon(Icons.add_rounded, size: 28, color: AppColors.onPrimary),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void _showAddGoalSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (_) => _AddGoalSheet(service: _service),
    );
  }
}

// ─── Analytics Tab ─────────────────────────────────────────────────────────────
class _AnalyticsTab extends StatelessWidget {
  final FirestoreService service;
  const _AnalyticsTab({required this.service});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<DailySummary>>(
      stream: service.weeklySummariesStream(),
      builder: (context, snap) {
        // Silently ignore errors - show empty state
        final summaries = snap.data ?? [];
        final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

        double totalCals = 0, totalSteps = 0, totalMins = 0;
        for (final s in summaries) {
          totalCals += s.totalCaloriesBurned;
          totalSteps += s.totalSteps;
          totalMins += s.totalActiveMinutes;
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              // Summary chips
              Row(
                children: [
                  _SummaryChip(
                      label: 'TOTAL CAL', value: totalCals.toInt().toString()),
                  const SizedBox(width: 10),
                  _SummaryChip(
                      label: 'TOTAL STEPS',
                      value: '${(totalSteps / 1000).toStringAsFixed(1)}K'),
                  const SizedBox(width: 10),
                  _SummaryChip(
                      label: 'ACTIVE MINS',
                      value: totalMins.toInt().toString()),
                ],
              ),
              const SizedBox(height: 24),
              // Calorie chart
              _ChartCard(
                title: 'Calories Burned',
                subtitle: 'This week',
                child: SizedBox(
                  height: 110,
                  child: WeeklyBarChart(
                    values: List.generate(7, (i) {
                      try {
                        return summaries
                            .firstWhere((s) => s.date.weekday == i + 1)
                            .totalCaloriesBurned;
                      } catch (_) {
                        return 0.0;
                      }
                    }),
                    labels: days,
                    selectedIndex: DateTime.now().weekday - 1,
                    maxValue: summaries.isEmpty
                        ? 1
                        : summaries
                            .map((s) => s.totalCaloriesBurned)
                            .reduce((a, b) => a > b ? a : b),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Steps chart
              _ChartCard(
                title: 'Daily Steps',
                subtitle: 'This week',
                child: SizedBox(
                  height: 110,
                  child: WeeklyBarChart(
                    values: List.generate(7, (i) {
                      try {
                        return summaries
                            .firstWhere((s) => s.date.weekday == i + 1)
                            .totalSteps
                            .toDouble();
                      } catch (_) {
                        return 0.0;
                      }
                    }),
                    labels: days,
                    selectedIndex: DateTime.now().weekday - 1,
                    maxValue: summaries.isEmpty
                        ? 1
                        : summaries
                            .map((s) => s.totalSteps.toDouble())
                            .reduce((a, b) => a > b ? a : b),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Mood trend (Advanced)
              _ChartCard(
                title: 'Mood Trend',
                subtitle: 'How you\'ve been feeling',
                child: SizedBox(
                  height: 60,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: List.generate(7, (i) {
                      int mood = 3;
                      try {
                        mood = summaries
                            .firstWhere((s) => s.date.weekday == i + 1)
                            .moodScore;
                      } catch (_) {}
                      final emojis = ['', '😞', '😕', '😐', '🙂', '😄'];
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(emojis[mood.clamp(1, 5)],
                              style: const TextStyle(fontSize: 22)),
                          const SizedBox(height: 4),
                          Text(days[i],
                              style: const TextStyle(
                                  fontFamily: 'Lexend',
                                  fontSize: 9,
                                  color: AppColors.onSurfaceVariant)),
                        ],
                      );
                    }),
                  ),
                ),
              ),
              // Achievements (Advanced)
              const SizedBox(height: 16),
              const _SectionLabel('ACHIEVEMENTS'),
              const SizedBox(height: 12),
              StreamBuilder<List<Achievement>>(
                stream: service.achievementsStream(),
                builder: (ctx, snap) {
                  final achievements = snap.data ?? [];
                  if (achievements.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(20)),
                      child: const Center(
                        child: Text('Complete goals to unlock badges! 🏆',
                            style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                color: AppColors.onSurfaceVariant)),
                      ),
                    );
                  }
                  return Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: achievements
                        .map((a) => _AchievementBadge(achievement: a))
                        .toList(),
                  );
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }
}

// ─── Goals Tab ─────────────────────────────────────────────────────────────────
class _GoalsTab extends StatelessWidget {
  final FirestoreService service;
  const _GoalsTab({required this.service});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<FitnessGoal>>(
      stream: service.goalsStream(),
      builder: (context, snap) {
        // Silently ignore errors - show empty state
        final goals = snap.data ?? [];
        if (goals.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('🎯', style: TextStyle(fontSize: 56)),
                SizedBox(height: 16),
                Text('No goals yet',
                    style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface)),
                SizedBox(height: 8),
                Text('Tap + to add your first goal',
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: AppColors.onSurfaceVariant)),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
          itemCount: goals.length,
          itemBuilder: (_, i) => _GoalCard(goal: goals[i], service: service),
        );
      },
    );
  }
}

// ─── Goal Card ─────────────────────────────────────────────────────────────────
class _GoalCard extends StatelessWidget {
  final FitnessGoal goal;
  final FirestoreService service;
  const _GoalCard({required this.goal, required this.service});

  @override
  Widget build(BuildContext context) {
    final daysLeft = goal.targetDate.difference(DateTime.now()).inDays;
    final isCompleted = goal.isCompleted || goal.progressPercent >= 1.0;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: isCompleted
            ? Border.all(color: AppColors.primaryContainer, width: 2)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(goal.title,
                        style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: AppColors.onSurface)),
                    const SizedBox(height: 4),
                    Text(
                      isCompleted ? '🏆 Completed!' : '$daysLeft days left',
                      style: TextStyle(
                          fontFamily: 'Lexend',
                          fontSize: 11,
                          color: isCompleted
                              ? AppColors.primary
                              : AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              ProgressRing(
                progress: goal.progressPercent,
                size: 60,
                strokeWidth: 6,
                child: Text(
                  '${(goal.progressPercent * 100).toInt()}%',
                  style: const TextStyle(
                      fontFamily: 'Lexend',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 8,
            decoration: BoxDecoration(
                color: AppColors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4)),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: goal.progressPercent,
              child: Container(
                decoration: BoxDecoration(
                    gradient: AppColors.kineticGradient,
                    borderRadius: BorderRadius.circular(4)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                  '${goal.currentValue.toInt()} / ${goal.targetValue.toInt()} ${_unit(goal.type)}',
                  style: const TextStyle(
                      fontFamily: 'Lexend',
                      fontSize: 11,
                      color: AppColors.onSurfaceVariant)),
              GestureDetector(
                onTap: () => service.deleteGoal(goal.id),
                child: const Icon(Icons.delete_outline_rounded,
                    size: 18, color: AppColors.outlineVariant),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _unit(String type) {
    switch (type) {
      case 'steps':
        return 'steps';
      case 'calories':
        return 'kcal';
      case 'weight':
        return 'kg';
      case 'distance':
        return 'km';
      default:
        return '';
    }
  }
}

// ─── Add Goal Sheet ───────────────────────────────────────────────────────────
class _AddGoalSheet extends StatefulWidget {
  final FirestoreService service;
  const _AddGoalSheet({required this.service});

  @override
  State<_AddGoalSheet> createState() => _AddGoalSheetState();
}

class _AddGoalSheetState extends State<_AddGoalSheet> {
  final _titleCtrl = TextEditingController();
  String _type = 'steps';
  double _target = 10000;
  final DateTime _targetDate = DateTime.now().add(const Duration(days: 30));

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('New Goal',
              style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface)),
          const SizedBox(height: 20),
          TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                  hintText: 'Goal name, e.g. "Run 100km"')),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _type,
            decoration: const InputDecoration(),
            items: const [
              DropdownMenuItem(value: 'steps', child: Text('Steps')),
              DropdownMenuItem(value: 'calories', child: Text('Calories')),
              DropdownMenuItem(value: 'distance', child: Text('Distance (km)')),
              DropdownMenuItem(
                  value: 'workout_count', child: Text('Workout Sessions')),
              DropdownMenuItem(value: 'weight', child: Text('Weight (kg)')),
            ],
            onChanged: (v) => setState(() => _type = v!),
          ),
          const SizedBox(height: 16),
          const Text('TARGET',
              style: TextStyle(
                  fontFamily: 'Lexend',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurfaceVariant,
                  letterSpacing: 1.2)),
          Slider(
            value: _target,
            min: 100,
            max: 100000,
            divisions: 100,
            activeColor: AppColors.primary,
            onChanged: (v) => setState(() => _target = v),
            label: _target.toInt().toString(),
          ),
          Text('${_target.toInt()} $_type',
              style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: AppColors.primary)),
          const SizedBox(height: 24),
          KineticButton(
            label: 'Save Goal',
            onPressed: () {
              if (_titleCtrl.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a goal name')),
                );
                return;
              }
              final goal = FitnessGoal(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                userId: FirebaseAuth.instance.currentUser?.uid ?? '',
                title: _titleCtrl.text,
                type: _type,
                targetValue: _target,
                startDate: DateTime.now(),
                targetDate: _targetDate,
              );
              widget.service.addGoal(goal);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ Goal saved!'),
                  backgroundColor: AppColors.primary,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ─── Small helpers ─────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          fontFamily: 'Lexend',
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.onSurfaceVariant,
          letterSpacing: 1.2));
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryChip({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(14)),
          child: Column(
            children: [
              Text(value,
                  style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: AppColors.onSurface)),
              Text(label,
                  style: const TextStyle(
                      fontFamily: 'Lexend',
                      fontSize: 8,
                      color: AppColors.onSurfaceVariant,
                      letterSpacing: 0.8),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      );
}

class _ChartCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  const _ChartCard(
      {required this.title, required this.subtitle, required this.child});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(24)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: AppColors.onSurface)),
            Text(subtitle,
                style: const TextStyle(
                    fontFamily: 'Lexend',
                    fontSize: 10,
                    color: AppColors.onSurfaceVariant)),
            const SizedBox(height: 20),
            child,
          ],
        ),
      );
}

class _AchievementBadge extends StatelessWidget {
  final Achievement achievement;
  const _AchievementBadge({required this.achievement});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: AppColors.kineticGradient,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events_rounded,
                color: AppColors.onPrimary, size: 18),
            const SizedBox(width: 8),
            Text(achievement.title,
                style: const TextStyle(
                    fontFamily: 'Lexend',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onPrimary)),
          ],
        ),
      );
}
