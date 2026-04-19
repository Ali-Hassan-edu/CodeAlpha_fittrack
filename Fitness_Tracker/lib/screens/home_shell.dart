import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../widgets/widgets.dart';
import '../services/firebase_service.dart';
import 'dashboard_screen.dart';
import 'history_screen.dart';
import 'progress_screen.dart';
import 'profile_screen.dart';
import 'log_workout_screen.dart';

// ─── Main App Shell ────────────────────────────────────────────────────────────
class HomeShell extends StatefulWidget {
  /// Initial profile; shell will keep it live via Firestore stream
  final UserProfile user;
  const HomeShell({super.key, required this.user});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  // 0=Home  1=History  2=Progress  3=Profile
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Stream the live profile so name/avatar updates propagate everywhere
    return StreamBuilder<UserProfile?>(
      stream: FirestoreService().userProfileStream(widget.user.uid),
      builder: (context, snap) {
        // Use live profile if available, otherwise fall back to initial value
        final user = snap.data ?? widget.user;

        final screens = [
          DashboardScreen(user: user),
          const HistoryScreen(),
          const ProgressScreen(),
          ProfileScreen(user: user),
        ];

        return Scaffold(
          backgroundColor: AppColors.background,
          drawer: Builder(
            builder: (drawerContext) => AppNavigationDrawer(
              userName: user.name,
              userEmail: user.email,
              avatarUrl: user.avatarUrl,
              onHome: () {
                Scaffold.of(drawerContext).closeDrawer();
                setState(() => _currentIndex = 0);
              },
              onHistory: () {
                Scaffold.of(drawerContext).closeDrawer();
                setState(() => _currentIndex = 1);
              },
              onLogWorkout: () {
                Scaffold.of(drawerContext).closeDrawer();
                _openLogWorkout();
              },
              onProgress: () {
                Scaffold.of(drawerContext).closeDrawer();
                setState(() => _currentIndex = 2);
              },
              onProfile: () {
                Scaffold.of(drawerContext).closeDrawer();
                setState(() => _currentIndex = 3);
              },
              onResetPassword: () {
                Scaffold.of(drawerContext).closeDrawer();
                _showResetPasswordDialog(context);
              },
              onSignOut: () {
                Scaffold.of(drawerContext).closeDrawer();
                _confirmSignOut(context);
              },
            ),
          ),
          body: IndexedStack(
            index: _currentIndex,
            children: screens,
          ),
          bottomNavigationBar: _BottomNav(
            currentIndex: _currentIndex,
            onTap: (i) {
              if (i == 2) {
                _openLogWorkout();
                return;
              }
              // Remap: 0→0, 1→1, 3→2, 4→3
              final screenIndex = i < 2 ? i : i - 1;
              setState(() => _currentIndex = screenIndex);
            },
          ),
        );
      },
    );
  }

  void _openLogWorkout() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LogWorkoutScreen()),
    );
  }

  void _showResetPasswordDialog(BuildContext context) {
    final emailCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Reset Password',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter your email to receive a password reset link.',
              style: TextStyle(
                fontFamily: 'Inter',
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'you@example.com',
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
              if (emailCtrl.text.isNotEmpty) {
                try {
                  await AuthService().sendPasswordReset(emailCtrl.text.trim());
                  if (context.mounted) Navigator.pop(context);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Password reset link sent!'),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('❌ Error: ${e.toString()}'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              }
            },
            child: const Text(
              'Send',
              style: TextStyle(color: AppColors.primary),
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
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              AuthService().signOut();
            },
            child: const Text(
              'Sign Out',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Bottom Navigation Bar ─────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Map screen index → nav index for highlighting
    // nav: 0=Home  1=History  2=Log(modal)  3=Progress  4=Profile
    final navIndex = currentIndex < 2 ? currentIndex : currentIndex + 1;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                isActive: navIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavItem(
                icon: Icons.history_rounded,
                label: 'History',
                isActive: navIndex == 1,
                onTap: () => onTap(1),
              ),
              // Centre FAB-style Log button
              GestureDetector(
                onTap: () => onTap(2),
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: AppColors.kineticGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.add_rounded,
                      color: AppColors.onPrimary, size: 28),
                ),
              ),
              _NavItem(
                icon: Icons.bar_chart_rounded,
                label: 'Progress',
                isActive: navIndex == 3,
                onTap: () => onTap(3),
              ),
              _NavItem(
                icon: Icons.person_rounded,
                label: 'Profile',
                isActive: navIndex == 4,
                onTap: () => onTap(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? AppColors.primary : AppColors.outlineVariant,
              size: 24,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Lexend',
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isActive ? AppColors.primary : AppColors.outlineVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
