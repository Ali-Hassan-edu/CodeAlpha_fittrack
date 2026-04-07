import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';
import '../models/models.dart';
import '../services/firebase_service.dart';
import 'dashboard_screen.dart';
import 'history_screen.dart';
import 'progress_screen.dart';
import 'profile_screen.dart';
import 'log_workout_screen.dart';

// ─── Main App Shell ────────────────────────────────────────────────────────────
class HomeShell extends StatefulWidget {
  final UserProfile user;
  const HomeShell({super.key, required this.user});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  // 0=Home 1=History 2=Progress 3=Profile  (Log is a modal, not a tab)
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      DashboardScreen(user: widget.user),
      const HistoryScreen(),
      const ProgressScreen(),
      ProfileScreen(user: widget.user),
    ];
  }

  void _onNavTap(int i) {
    if (i == 2) {
      // Middle button → open Log Workout modal
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LogWorkoutScreen()),
      );
      return;
    }
    // Remap: 0→0, 1→1, 3→2, 4→3
    final screenIndex = i < 2 ? i : i - 1;
    setState(() => _currentIndex = screenIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _BottomNav(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}

// ─── Clean Bottom Nav — uses BottomNavigationBar properly ─────────────────────
class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Map screen index back to nav index for highlighting
    // nav: 0=Home 1=History 2=Log(modal) 3=Progress 4=Profile
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
              _NavItem(icon: Icons.home_rounded, label: 'Home', isActive: navIndex == 0, onTap: () => onTap(0)),
              _NavItem(icon: Icons.history_rounded, label: 'History', isActive: navIndex == 1, onTap: () => onTap(1)),
              // Centre FAB-style Log button
              GestureDetector(
                onTap: () => onTap(2),
                child: Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    gradient: AppColors.kineticGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 16, offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.add_rounded, color: AppColors.onPrimary, size: 28),
                ),
              ),
              _NavItem(icon: Icons.bar_chart_rounded, label: 'Progress', isActive: navIndex == 3, onTap: () => onTap(3)),
              _NavItem(icon: Icons.person_rounded, label: 'Profile', isActive: navIndex == 4, onTap: () => onTap(4)),
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
  const _NavItem({required this.icon, required this.label, required this.isActive, required this.onTap});

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
            Icon(icon, color: isActive ? AppColors.primary : AppColors.outlineVariant, size: 24),
            const SizedBox(height: 3),
            Text(label, style: TextStyle(
              fontFamily: 'Lexend', fontSize: 10, fontWeight: FontWeight.w600,
              color: isActive ? AppColors.primary : AppColors.outlineVariant,
            )),
          ],
        ),
      ),
    );
  }
}

// ─── Profile Setup Screen (Onboarding Step 2) ─────────────────────────────────
class ProfileSetupScreen extends StatefulWidget {
  final String uid;
  final String name;
  final String email;
  const ProfileSetupScreen({super.key, required this.uid, required this.name, required this.email});
  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _service = FirestoreService();
  int _step = 0;
  int _age = 25;
  double _heightCm = 170;
  double _weightKg = 70;
  String _fitnessGoal = 'maintain';
  bool _loading = false;

  static const _goals = [
    ('lose_weight', '🔥', 'Lose Weight', 'Burn fat & slim down'),
    ('build_muscle', '💪', 'Build Muscle', 'Gain strength & size'),
    ('maintain', '⚖️', 'Stay Active', 'Maintain current fitness'),
    ('endurance', '🏃', 'Build Endurance', 'Run longer, feel better'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Progress header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  if (_step > 0)
                    GestureDetector(
                      onTap: () => setState(() => _step--),
                      child: const Icon(Icons.arrow_back_rounded, color: AppColors.onSurface),
                    )
                  else
                    const SizedBox(width: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (_step + 1) / 3,
                        backgroundColor: AppColors.surfaceContainerHighest,
                        valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('${_step + 1} / 3', style: const TextStyle(
                    fontFamily: 'Lexend', fontSize: 11, color: AppColors.onSurfaceVariant,
                  )),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                child: [_buildStepAge, _buildStepBody, _buildStepGoal][_step](),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: KineticButton(
                label: _step < 2 ? 'Continue' : "Let's Go!",
                onPressed: _loading ? null : _onNext,
                isLoading: _loading,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepAge() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Hi, ${widget.name.split(' ').first}! 👋', style: const TextStyle(
        fontFamily: 'Plus Jakarta Sans', fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.onSurface,
      )),
      const SizedBox(height: 6),
      const Text("Let's set up your profile", style: TextStyle(fontFamily: 'Inter', fontSize: 15, color: AppColors.onSurfaceVariant)),
      const SizedBox(height: 40),
      const Text('How old are you?', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: AppColors.surfaceContainerLowest, borderRadius: BorderRadius.circular(20)),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text('$_age', style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 52, fontWeight: FontWeight.w800, color: AppColors.onSurface)),
                const SizedBox(width: 8),
                const Text('years', style: TextStyle(fontFamily: 'Inter', fontSize: 18, color: AppColors.onSurfaceVariant)),
              ],
            ),
            Slider(
              value: _age.toDouble(), min: 13, max: 80, divisions: 67,
              activeColor: AppColors.primary, inactiveColor: AppColors.surfaceContainerHighest,
              onChanged: (v) => setState(() => _age = v.toInt()),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _buildStepBody() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Body Metrics', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.onSurface)),
      const SizedBox(height: 6),
      const Text('Helps us personalise your experience', style: TextStyle(fontFamily: 'Inter', fontSize: 15, color: AppColors.onSurfaceVariant)),
      const SizedBox(height: 32),
      _MetricCard(
        label: 'Height',
        value: '${_heightCm.toInt()} cm',
        icon: Icons.height_rounded,
        child: Slider(
          value: _heightCm, min: 140, max: 220,
          activeColor: AppColors.primary, inactiveColor: AppColors.surfaceContainerHighest,
          onChanged: (v) => setState(() => _heightCm = v),
        ),
      ),
      const SizedBox(height: 16),
      _MetricCard(
        label: 'Weight',
        value: '${_weightKg.toStringAsFixed(1)} kg',
        icon: Icons.monitor_weight_outlined,
        child: Slider(
          value: _weightKg, min: 30, max: 200,
          activeColor: AppColors.primary, inactiveColor: AppColors.surfaceContainerHighest,
          onChanged: (v) => setState(() => _weightKg = v),
        ),
      ),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.primaryContainer.withOpacity(0.25), borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 20),
            const SizedBox(width: 12),
            Text(
              'Your BMI: ${(_weightKg / ((_heightCm / 100) * (_heightCm / 100))).toStringAsFixed(1)}',
              style: const TextStyle(fontFamily: 'Lexend', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _buildStepGoal() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text("What's your main goal?", style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.onSurface)),
      const SizedBox(height: 6),
      const Text("We'll tailor your experience", style: TextStyle(fontFamily: 'Inter', fontSize: 15, color: AppColors.onSurfaceVariant)),
      const SizedBox(height: 24),
      ...(_goals.map((g) {
        final isSelected = _fitnessGoal == g.$1;
        return GestureDetector(
          onTap: () => setState(() => _fitnessGoal = g.$1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryContainer.withOpacity(0.3) : AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(18),
              border: isSelected ? Border.all(color: AppColors.primary, width: 2) : null,
            ),
            child: Row(
              children: [
                Text(g.$2, style: const TextStyle(fontSize: 26)),
                const SizedBox(width: 14),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(g.$3, style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 15, fontWeight: FontWeight.w700,
                        color: isSelected ? AppColors.primary : AppColors.onSurface)),
                    Text(g.$4, style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppColors.onSurfaceVariant)),
                  ],
                )),
                if (isSelected) const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 22),
              ],
            ),
          ),
        );
      })),
    ],
  );

  Future<void> _onNext() async {
    if (_step < 2) { setState(() => _step++); return; }
    setState(() => _loading = true);
    final profile = UserProfile(
      uid: widget.uid, name: widget.name, email: widget.email,
      age: _age, heightCm: _heightCm, weightKg: _weightKg,
      fitnessGoal: _fitnessGoal, createdAt: DateTime.now(),
    );
    await _service.createUserProfile(profile);
    if (mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeShell(user: profile)));
    }
    setState(() => _loading = false);
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Widget child;
  const _MetricCard({required this.label, required this.value, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      decoration: BoxDecoration(color: AppColors.surfaceContainerLowest, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: AppColors.onSurfaceVariant)),
              const Spacer(),
              Text(value, style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
            ],
          ),
          child,
        ],
      ),
    );
  }
}
