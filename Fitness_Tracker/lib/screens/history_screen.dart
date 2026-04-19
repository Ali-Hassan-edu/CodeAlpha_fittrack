import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';
import '../models/models.dart';
import '../services/firebase_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _service = FirestoreService();
  String _filterType = 'All';
  String _searchQuery = '';

  static const _filters = [
    'All',
    'Cardio',
    'Strength',
    'Cycling',
    'Yoga',
    'HIIT'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withOpacity(0.85),
        title: const Text('Log & History',
            style: TextStyle(
                fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w700)),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search workouts...',
                prefixIcon: const Icon(Icons.search_rounded,
                    color: AppColors.onSurfaceVariant),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide: BorderSide.none),
              ),
            ),
          ),
          // Filter chips - responsive
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: _filters.map((f) {
                final isSelected = _filterType == f;
                return GestureDetector(
                  onTap: () => setState(() => _filterType = f),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.only(right: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.secondary
                          : AppColors.secondaryFixed,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      f,
                      style: TextStyle(
                        fontFamily: 'Lexend',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? AppColors.onSecondary
                            : AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          // Workout list
          Expanded(
            child: StreamBuilder<List<WorkoutLog>>(
              stream: _service.workoutsStream(limit: 50),
              builder: (context, snap) {
                // Silently ignore errors - show empty state
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child:
                          CircularProgressIndicator(color: AppColors.primary));
                }
                var workouts = snap.data ?? [];
                // Filter by type
                if (_filterType != 'All') {
                  workouts = workouts
                      .where((w) => w.exerciseType == _filterType)
                      .toList();
                }
                // Filter by search
                if (_searchQuery.isNotEmpty) {
                  workouts = workouts
                      .where((w) =>
                          w.exerciseName.toLowerCase().contains(_searchQuery) ||
                          w.exerciseType.toLowerCase().contains(_searchQuery))
                      .toList();
                }

                if (workouts.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('🏋️', style: TextStyle(fontSize: 48)),
                        SizedBox(height: 16),
                        Text('No workouts found',
                            style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.onSurface)),
                        SizedBox(height: 8),
                        Text('Log your first session!',
                            style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                color: AppColors.onSurfaceVariant)),
                      ],
                    ),
                  );
                }

                // Group by date
                final grouped = <String, List<WorkoutLog>>{};
                for (final w in workouts) {
                  final key = _dateLabel(w.loggedAt);
                  grouped.putIfAbsent(key, () => []).add(w);
                }

                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                  children: grouped.entries.map((entry) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            entry.key,
                            style: const TextStyle(
                                fontFamily: 'Lexend',
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.outline,
                                letterSpacing: 1.2),
                          ),
                        ),
                        ...entry.value.map((w) => WorkoutTile(
                              exerciseName: w.exerciseName,
                              exerciseType: w.exerciseType,
                              durationMinutes: w.durationMinutes,
                              caloriesBurned: w.caloriesBurned,
                              intensity: WorkoutIntensityBadge.fromLevel(
                                  w.intensity.name),
                              onDelete: () => _confirmDelete(context, w.id),
                            )),
                      ],
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _dateLabel(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'TODAY';
    }
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day - 1) {
      return 'YESTERDAY';
    }
    return '${_month(date.month)} ${date.day}, ${date.year}'.toUpperCase();
  }

  String _month(int m) => const [
        '',
        'JAN',
        'FEB',
        'MAR',
        'APR',
        'MAY',
        'JUN',
        'JUL',
        'AUG',
        'SEP',
        'OCT',
        'NOV',
        'DEC'
      ][m];

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Workout?',
            style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface)),
        content: const Text('This will permanently remove this entry.',
            style: TextStyle(
                fontFamily: 'Inter', color: AppColors.onSurfaceVariant)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              _service.deleteWorkoutLog(id);
              Navigator.pop(context);
            },
            child:
                const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
