import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';
import '../models/models.dart';
import '../services/firebase_service.dart';

class ProfileSetupScreen extends StatefulWidget {
  final String uid;
  final String name;
  final String email;

  const ProfileSetupScreen({
    super.key,
    required this.uid,
    required this.name,
    required this.email,
  });

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen>
    with TickerProviderStateMixin {
  late TabController _tabCtrl;
  int _step = 0; // 0=Personal, 1=Goals, 2=Details

  // Step 0 - Personal Info
  late TextEditingController _nameCtrl;
  int _age = 25;
  double _heightCm = 170;
  double _weightKg = 70;

  // Step 1 - Goals
  String _fitnessGoal = 'maintain';
  int _dailyStepGoal = 10000;
  int _dailyCalorieGoal = 500;
  int _weeklyWorkoutGoal = 4;

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.name);
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _completeSetup() async {
    setState(() => _loading = true);
    try {
      final profile = UserProfile(
        uid: widget.uid,
        name: _nameCtrl.text.trim(),
        email: widget.email,
        age: _age,
        heightCm: _heightCm,
        weightKg: _weightKg,
        fitnessGoal: _fitnessGoal,
        dailyStepGoal: _dailyStepGoal,
        dailyCalorieGoal: _dailyCalorieGoal,
        weeklyWorkoutGoal: _weeklyWorkoutGoal,
        createdAt: DateTime.now(),
      );

      await FirestoreService().createUserProfile(profile);

      // Create default daily summary
      await FirestoreService().updateDailySummary(DateTime.now(), {});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Welcome to FitTrack! Let\'s get moving 🎉'),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
        // _AuthGate's StreamBuilder detects the new profile and routes to HomeShell automatically.
        // No manual navigation needed here.
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text(
          'Complete Your Profile',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Progress indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: LinearProgressIndicator(
              value: (_step + 1) / 3,
              backgroundColor: AppColors.surfaceContainer,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _buildStep(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                KineticButton(
                  label: _step == 2 ? 'Complete Setup' : 'Next',
                  onPressed: _loading ? null : _handleNext,
                  isLoading: _loading,
                ),
                if (_step > 0)
                  TextButton(
                    onPressed: _loading ? null : () => setState(() => _step--),
                    child: const Text('Back',
                        style: TextStyle(color: AppColors.primary)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildStep() {
    switch (_step) {
      case 0:
        return _buildPersonalStep();
      case 1:
        return _buildGoalsStep();
      case 2:
        return _buildDetailsStep();
      default:
        return [];
    }
  }

  List<Widget> _buildPersonalStep() {
    return [
      const Text(
        'Personal Information',
        style: TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: AppColors.onSurface,
        ),
      ),
      const SizedBox(height: 8),
      const Text(
        'Help us get to know you better',
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          color: AppColors.onSurfaceVariant,
        ),
      ),
      const SizedBox(height: 24),
      TextField(
        controller: _nameCtrl,
        decoration: const InputDecoration(
          labelText: 'Your Name',
          prefixIcon:
              Icon(Icons.person_outline, color: AppColors.onSurfaceVariant),
        ),
      ),
      const SizedBox(height: 20),
      _SliderRow(
        label: 'Age',
        value: _age.toDouble(),
        min: 13,
        max: 100,
        onChanged: (v) => setState(() => _age = v.toInt()),
        unit: 'years',
      ),
      const SizedBox(height: 20),
      _SliderRow(
        label: 'Height',
        value: _heightCm,
        min: 140,
        max: 220,
        onChanged: (v) => setState(() => _heightCm = v),
        unit: 'cm',
      ),
      const SizedBox(height: 20),
      _SliderRow(
        label: 'Weight',
        value: _weightKg,
        min: 30,
        max: 200,
        onChanged: (v) => setState(() => _weightKg = v),
        unit: 'kg',
      ),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primaryFixedDim.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'BMI: ${(_weightKg / ((_heightCm / 100) * (_heightCm / 100))).toStringAsFixed(1)}',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _buildGoalsStep() {
    return [
      const Text(
        'Fitness Goals',
        style: TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: AppColors.onSurface,
        ),
      ),
      const SizedBox(height: 8),
      const Text(
        'What\'s your primary fitness goal?',
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          color: AppColors.onSurfaceVariant,
        ),
      ),
      const SizedBox(height: 24),
      Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          _GoalCard(
            icon: Icons.trending_down_rounded,
            label: 'Lose Weight',
            value: 'lose_weight',
            isSelected: _fitnessGoal == 'lose_weight',
            onTap: () => setState(() => _fitnessGoal = 'lose_weight'),
          ),
          _GoalCard(
            icon: Icons.fitness_center_rounded,
            label: 'Build Muscle',
            value: 'build_muscle',
            isSelected: _fitnessGoal == 'build_muscle',
            onTap: () => setState(() => _fitnessGoal = 'build_muscle'),
          ),
          _GoalCard(
            icon: Icons.balance_rounded,
            label: 'Maintain',
            value: 'maintain',
            isSelected: _fitnessGoal == 'maintain',
            onTap: () => setState(() => _fitnessGoal = 'maintain'),
          ),
          _GoalCard(
            icon: Icons.directions_run_rounded,
            label: 'Endurance',
            value: 'endurance',
            isSelected: _fitnessGoal == 'endurance',
            onTap: () => setState(() => _fitnessGoal = 'endurance'),
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildDetailsStep() {
    return [
      const Text(
        'Target Goals',
        style: TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: AppColors.onSurface,
        ),
      ),
      const SizedBox(height: 8),
      const Text(
        'Set your daily and weekly targets',
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          color: AppColors.onSurfaceVariant,
        ),
      ),
      const SizedBox(height: 24),
      _SliderRow(
        label: 'Daily Steps',
        value: _dailyStepGoal.toDouble(),
        min: 1000,
        max: 50000,
        step: 1000,
        onChanged: (v) => setState(() => _dailyStepGoal = v.toInt()),
        unit: 'steps',
      ),
      const SizedBox(height: 20),
      _SliderRow(
        label: 'Daily Activity Calories',
        value: _dailyCalorieGoal.toDouble(),
        min: 100,
        max: 5000,
        step: 100,
        onChanged: (v) => setState(() => _dailyCalorieGoal = v.toInt()),
        unit: 'kcal',
      ),
      const SizedBox(height: 20),
      _SliderRow(
        label: 'Weekly Workouts',
        value: _weeklyWorkoutGoal.toDouble(),
        min: 1,
        max: 7,
        step: 1,
        onChanged: (v) => setState(() => _weeklyWorkoutGoal = v.toInt()),
        unit: 'sessions',
      ),
      const SizedBox(height: 24),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.secondaryFixed.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle_rounded,
                    color: AppColors.secondary, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'You\'re all set! 🎉',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.secondary,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Your profile is ready. Start logging workouts and tracking your progress!',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: AppColors.onSurface,
              ),
            ),
          ],
        ),
      ),
    ];
  }

  void _handleNext() {
    if (_step < 2) {
      setState(() => _step++);
    } else {
      _completeSetup();
    }
  }
}

class _SliderRow extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final double step;
  final ValueChanged<double> onChanged;
  final String unit;

  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.unit,
    this.step = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${value.toInt()} $unit',
                style: const TextStyle(
                  fontFamily: 'Lexend',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SliderTheme(
          data: const SliderThemeData(
            trackHeight: 8,
            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12),
            overlayShape: RoundSliderOverlayShape(overlayRadius: 20),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: ((max - min) / step).toInt(),
            activeColor: AppColors.primary,
            inactiveColor: AppColors.primaryFixedDim.withOpacity(0.3),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class _GoalCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isSelected;
  final VoidCallback onTap;

  const _GoalCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: isSelected ? AppColors.kineticGradient : null,
            color: isSelected ? null : AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: !isSelected
                ? Border.all(
                    color: AppColors.outlineVariant.withOpacity(0.3),
                  )
                : null,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: isSelected ? AppColors.onPrimary : AppColors.primary,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppColors.onPrimary : AppColors.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
