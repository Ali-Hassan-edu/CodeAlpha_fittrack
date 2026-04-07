import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;
  late final AnimationController _slideCtrl;
  late final Animation<Offset> _slideAnim;

  final _pages = const [
    _OnboardingPage(
      headline: 'Track Every\nRep & Step',
      subtitle: 'Log workouts, monitor steps and visualize your progress — all in one place.',
      emoji: '🏋️',
    ),
    _OnboardingPage(
      headline: 'Know Your\nBody Better',
      subtitle: 'Track calories, water, sleep and mood alongside your fitness to see the full picture.',
      emoji: '📊',
    ),
    _OnboardingPage(
      headline: 'Reach Every\nGoal You Set',
      subtitle: 'Set smart goals, earn badges and celebrate every personal best you crush.',
      emoji: '🏆',
    ),
  ];

  int _page = 0;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _slideCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic));
    _fadeCtrl.forward();
    _slideCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _slideCtrl.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_page < _pages.length - 1) {
      setState(() => _page++);
      _fadeCtrl.reset();
      _slideCtrl.reset();
      _fadeCtrl.forward();
      _slideCtrl.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Logo
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: AppColors.kineticGradient,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.25),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: const Icon(Icons.bolt_rounded, color: AppColors.onPrimary, size: 36),
              ),
              const SizedBox(height: 12),
              const Text(
                'FitTrack',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
              const Text(
                'KINETIC SANCTUARY',
                style: TextStyle(
                  fontFamily: 'Lexend',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurfaceVariant,
                  letterSpacing: 2.0,
                ),
              ),
              const Spacer(),
              // Animated page content
              FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: _pages[_page],
                ),
              ),
              const Spacer(),
              // Dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == _page ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      gradient: i == _page ? AppColors.kineticGradient : null,
                      color: i == _page ? null : AppColors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // CTA
              if (_page < _pages.length - 1)
                KineticButton(label: 'Continue', onPressed: _nextPage)
              else
                Column(
                  children: [
                    KineticButton(
                      label: 'Get Started',
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SignUpScreen()),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already have an account? ',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                          ),
                          child: const Text(
                            'Sign In',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final String headline;
  final String subtitle;
  final String emoji;

  const _OnboardingPage({
    required this.headline,
    required this.subtitle,
    required this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 80)),
        const SizedBox(height: 32),
        Text(
          headline,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 38,
            fontWeight: FontWeight.w800,
            color: AppColors.onSurface,
            height: 1.1,
            letterSpacing: -1.0,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            color: AppColors.onSurfaceVariant,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}
