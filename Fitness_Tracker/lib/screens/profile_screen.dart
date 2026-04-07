import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/firebase_service.dart';

class ProfileScreen extends StatelessWidget {
  final UserProfile user;
  const ProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 220,
            backgroundColor: AppColors.surface.withOpacity(0.85),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.surfaceContainerLow, AppColors.background],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 48),
                      // Avatar
                      Stack(
                        children: [
                          Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              gradient: AppColors.kineticGradient,
                              borderRadius: BorderRadius.circular(28),
                            ),
                            child: Center(
                              child: Text(
                                user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                                style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 36, fontWeight: FontWeight.w800, color: AppColors.onPrimary),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0, right: 0,
                            child: Container(
                              width: 26, height: 26,
                              decoration: BoxDecoration(
                                gradient: AppColors.kineticGradient,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.background, width: 2),
                              ),
                              child: const Icon(Icons.edit_rounded, size: 14, color: AppColors.onPrimary),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(user.name, style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.onSurface)),
                      Text(user.email, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: AppColors.onSurfaceVariant)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 20),
                // Body stats
                _StatsRow(user: user),
                const SizedBox(height: 20),
                // Sections
                _SettingsSection(title: 'GOALS & TARGETS', items: [
                  _SettingsItem(
                    icon: Icons.directions_walk_rounded,
                    label: 'Daily Step Goal',
                    value: '${user.dailyStepGoal.toString()} steps',
                    onTap: () {},
                  ),
                  _SettingsItem(
                    icon: Icons.local_fire_department_rounded,
                    label: 'Calorie Goal',
                    value: '${user.dailyCalorieGoal} kcal',
                    onTap: () {},
                  ),
                  _SettingsItem(
                    icon: Icons.fitness_center_rounded,
                    label: 'Weekly Workouts',
                    value: '${user.weeklyWorkoutGoal} sessions',
                    onTap: () {},
                  ),
                ]),
                const SizedBox(height: 16),
                _SettingsSection(title: 'PREFERENCES', items: [
                  _SettingsItem(icon: Icons.notifications_outlined, label: 'Notifications', onTap: () {}),
                  _SettingsItem(icon: Icons.dark_mode_outlined, label: 'Dark Mode', onTap: () {}),
                  _SettingsItem(icon: Icons.straighten_rounded, label: 'Units (kg / lbs)', onTap: () {}),
                ]),
                const SizedBox(height: 16),
                _SettingsSection(title: 'ACCOUNT', items: [
                  _SettingsItem(icon: Icons.security_rounded, label: 'Privacy & Security', onTap: () {}),
                  _SettingsItem(icon: Icons.download_rounded, label: 'Export Data', onTap: () {}),
                  _SettingsItem(
                    icon: Icons.logout_rounded,
                    label: 'Sign Out',
                    onTap: () => _confirmSignOut(context),
                    color: AppColors.error,
                  ),
                ]),
                const SizedBox(height: 16),
                const Center(
                  child: Column(
                    children: [
                      Text('FitTrack · Kinetic Sanctuary', style: TextStyle(fontFamily: 'Lexend', fontSize: 10, color: AppColors.outlineVariant, letterSpacing: 1.0)),
                      SizedBox(height: 4),
                      Text('Version 1.0.0', style: TextStyle(fontFamily: 'Lexend', fontSize: 10, color: AppColors.outlineVariant)),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Sign Out', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w700, color: AppColors.onSurface)),
        content: const Text('Are you sure you want to sign out?', style: TextStyle(fontFamily: 'Inter', color: AppColors.onSurfaceVariant)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: AppColors.onSurfaceVariant))),
          TextButton(
            onPressed: () { Navigator.pop(context); AuthService().signOut(); },
            child: const Text('Sign Out', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final UserProfile user;
  const _StatsRow({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.surfaceContainerLowest, borderRadius: BorderRadius.circular(24)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _Stat(value: '${user.age}', label: 'AGE'),
          _Divider(),
          _Stat(value: '${user.heightCm.toInt()}', label: 'HEIGHT (CM)'),
          _Divider(),
          _Stat(value: '${user.weightKg.toInt()}', label: 'WEIGHT (KG)'),
          _Divider(),
          _Stat(value: user.bmi.toStringAsFixed(1), label: 'BMI'),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  const _Stat({required this.value, required this.label});
  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(value, style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.onSurface)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontFamily: 'Lexend', fontSize: 8, color: AppColors.onSurfaceVariant, letterSpacing: 0.5)),
        ],
      );
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(width: 1, height: 36, color: AppColors.outlineVariant.withOpacity(0.3));
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<_SettingsItem> items;
  const _SettingsSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(title, style: const TextStyle(fontFamily: 'Lexend', fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant, letterSpacing: 1.2)),
        ),
        Container(
          decoration: BoxDecoration(color: AppColors.surfaceContainerLowest, borderRadius: BorderRadius.circular(20)),
          child: Column(children: items),
        ),
      ],
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final VoidCallback onTap;
  final Color? color;

  const _SettingsItem({required this.icon, required this.label, this.value, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.onSurface;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: c, size: 22),
            const SizedBox(width: 14),
            Expanded(child: Text(label, style: TextStyle(fontFamily: 'Inter', fontSize: 15, color: c))),
            if (value != null) ...[
              Text(value!, style: const TextStyle(fontFamily: 'Lexend', fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600)),
              const SizedBox(width: 8),
            ],
            const Icon(Icons.chevron_right_rounded, color: AppColors.outlineVariant, size: 20),
          ],
        ),
      ),
    );
  }
}
