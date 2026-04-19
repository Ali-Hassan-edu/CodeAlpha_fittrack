import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/firebase_service.dart';

class ProfileScreen extends StatefulWidget {
  final UserProfile user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _service = FirestoreService();
  bool _uploadingAvatar = false;

  Widget _buildAvatarContent(UserProfile user) {
    if (_uploadingAvatar) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.onPrimary,
          strokeWidth: 2,
        ),
      );
    }
    if (user.avatarUrl != null && user.avatarUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Image.network(
          user.avatarUrl!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _initialsWidget(user.name),
        ),
      );
    }
    return _initialsWidget(user.name);
  }

  Widget _initialsWidget(String name) => Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 36,
            fontWeight: FontWeight.w800,
            color: AppColors.onPrimary,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    // Stream live profile so edits (name, avatar) reflect immediately
    return StreamBuilder<UserProfile?>(
      stream: _service.userProfileStream(widget.user.uid),
      builder: (context, snap) {
        final user = snap.data ?? widget.user;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 220,
                backgroundColor: AppColors.surface.withOpacity(0.85),
                automaticallyImplyLeading: false,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.surfaceContainerLow,
                          AppColors.background
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 48),
                          // Avatar with edit button
                          GestureDetector(
                            onTap: () => _showProfileEditDialog(context, user),
                            child: Stack(
                              children: [
                                Container(
                                  width: 88,
                                  height: 88,
                                  decoration: BoxDecoration(
                                    gradient: AppColors.kineticGradient,
                                    borderRadius: BorderRadius.circular(28),
                                  ),
                                  child: _buildAvatarContent(user),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 26,
                                    height: 26,
                                    decoration: BoxDecoration(
                                      gradient: AppColors.kineticGradient,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: AppColors.background,
                                        width: 2,
                                      ),
                                    ),
                                    child: const Icon(Icons.edit_rounded,
                                        size: 14, color: AppColors.onPrimary),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            user.name,
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.onSurface,
                            ),
                          ),
                          Text(
                            user.email,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
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
                    _StatsRow(user: user),
                    const SizedBox(height: 20),
                    _SettingsSection(title: 'GOALS & TARGETS', items: [
                      _SettingsItem(
                        icon: Icons.directions_walk_rounded,
                        label: 'Daily Step Goal',
                        value: '${user.dailyStepGoal} steps',
                        onTap: () => _editGoal(
                          context,
                          'Daily Step Goal',
                          user.dailyStepGoal.toDouble(),
                          'steps',
                          user,
                        ),
                      ),
                      _SettingsItem(
                        icon: Icons.local_fire_department_rounded,
                        label: 'Calorie Goal',
                        value: '${user.dailyCalorieGoal} kcal',
                        onTap: () => _editGoal(
                          context,
                          'Calorie Goal',
                          user.dailyCalorieGoal.toDouble(),
                          'calories',
                          user,
                        ),
                      ),
                      _SettingsItem(
                        icon: Icons.fitness_center_rounded,
                        label: 'Weekly Workouts',
                        value: '${user.weeklyWorkoutGoal} sessions',
                        onTap: () => _editGoal(
                          context,
                          'Weekly Workouts',
                          user.weeklyWorkoutGoal.toDouble(),
                          'workouts',
                          user,
                        ),
                      ),
                    ]),
                    const SizedBox(height: 16),
                    _SettingsSection(title: 'ACCOUNT', items: [
                      _SettingsItem(
                        icon: Icons.security_rounded,
                        label: 'Privacy & Security',
                        onTap: () {},
                      ),
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
                          Text(
                            'FitTrack · Kinetic Sanctuary',
                            style: TextStyle(
                              fontFamily: 'Lexend',
                              fontSize: 10,
                              color: AppColors.outlineVariant,
                              letterSpacing: 1.0,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Version 1.0.0',
                            style: TextStyle(
                              fontFamily: 'Lexend',
                              fontSize: 10,
                              color: AppColors.outlineVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showProfileEditDialog(
      BuildContext context, UserProfile user) async {
    final nameCtrl = TextEditingController(text: user.name);
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Your Name',
                hintText: 'Enter your name',
                prefixIcon: Icon(Icons.person_rounded),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.tertiary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.tertiary),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image_rounded, color: AppColors.tertiary),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Profile pictures coming soon! (Storage plan upgrading)',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.tertiary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isNotEmpty) {
                try {
                  await _service.updateUserProfile(
                    user.uid,
                    {'name': nameCtrl.text.trim()},
                  );
                  if (context.mounted) Navigator.pop(context);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Profile updated!'),
                        backgroundColor: AppColors.primary,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('❌ Error: $e'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              }
            },
            child: const Text(
              'Save',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _uploadProfilePicture(UserProfile user) async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );
      if (image == null) return;

      setState(() => _uploadingAvatar = true);
      final file = File(image.path);
      final url = await _service.uploadAvatar(user.uid, file);
      if (url != null) {
        await _service.updateUserProfile(user.uid, {'avatarUrl': url});
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Profile picture updated!'),
              backgroundColor: AppColors.primary,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Upload failed: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _uploadingAvatar = false);
    }
  }

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Sign Out',
            style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface)),
        content: const Text('Are you sure you want to sign out?',
            style: TextStyle(
                fontFamily: 'Inter', color: AppColors.onSurfaceVariant)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.onSurfaceVariant)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              AuthService().signOut();
            },
            child: const Text('Sign Out',
                style: TextStyle(
                    color: AppColors.error, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _editGoal(BuildContext context, String label, double currentValue,
      String type, UserProfile user) {
    double newValue = currentValue;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          backgroundColor: AppColors.surfaceContainerLowest,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text('Edit $label',
              style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Slider(
                value: newValue,
                min: type == 'workouts' ? 1 : 100,
                max: type == 'workouts' ? 14 : (type == 'steps' ? 50000 : 5000),
                divisions: 50,
                activeColor: AppColors.primary,
                onChanged: (v) => setS(() => newValue = v),
                label: newValue.toInt().toString(),
              ),
              const SizedBox(height: 8),
              Text(
                '${newValue.toInt()} ${type == 'steps' ? 'steps' : type == 'calories' ? 'kcal' : 'sessions'}',
                style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            TextButton(
              onPressed: () async {
                final updates = <String, dynamic>{};
                if (type == 'steps') {
                  updates['dailyStepGoal'] = newValue.toInt();
                } else if (type == 'calories') {
                  updates['dailyCalorieGoal'] = newValue.toInt();
                } else if (type == 'workouts') {
                  updates['weeklyWorkoutGoal'] = newValue.toInt();
                }
                try {
                  await _service.updateUserProfile(user.uid, updates);
                  if (context.mounted) Navigator.pop(context);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('✅ Updated!'),
                          backgroundColor: AppColors.primary,
                          behavior: SnackBarBehavior.floating),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('❌ Error: $e'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              },
              child: const Text('Save',
                  style: TextStyle(
                      color: AppColors.primary, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
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
      decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(24)),
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
          Text(value,
              style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  fontFamily: 'Lexend',
                  fontSize: 8,
                  color: AppColors.onSurfaceVariant,
                  letterSpacing: 0.5)),
        ],
      );
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
      width: 1, height: 36, color: AppColors.outlineVariant.withOpacity(0.3));
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
          child: Text(title,
              style: const TextStyle(
                  fontFamily: 'Lexend',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurfaceVariant,
                  letterSpacing: 1.2)),
        ),
        Container(
          decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(20)),
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

  const _SettingsItem({
    required this.icon,
    required this.label,
    this.value,
    required this.onTap,
    this.color,
  });

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
            Expanded(
                child: Text(label,
                    style: TextStyle(
                        fontFamily: 'Inter', fontSize: 15, color: c))),
            if (value != null) ...[
              Text(value!,
                  style: const TextStyle(
                      fontFamily: 'Lexend',
                      fontSize: 11,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600)),
              const SizedBox(width: 8),
            ],
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.outlineVariant, size: 20),
          ],
        ),
      ),
    );
  }
}
