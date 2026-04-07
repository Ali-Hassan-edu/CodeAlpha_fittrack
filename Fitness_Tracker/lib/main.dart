import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'firebase_options.dart'; // Removed for manual setup
import 'theme/app_theme.dart';
import 'services/firebase_service.dart';
import 'models/models.dart';
import 'screens/welcome_screen.dart';
import 'screens/home_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const FitTrackApp());
}

class FitTrackApp extends StatelessWidget {
  const FitTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitTrack',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const _AuthGate(),
    );
  }
}

// ─── Auth Gate — routes user based on sign-in state ───────────────────────────
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const _SplashScreen();
        }

        if (snap.data == null) {
          // Not signed in → show welcome/onboarding
          return const WelcomeScreen();
        }

        // Signed in → check if profile exists
        final uid = snap.data!.uid;
        return FutureBuilder<UserProfile?>(
          future: FirestoreService().getUserProfile(uid),
          builder: (ctx, profileSnap) {
            if (profileSnap.connectionState == ConnectionState.waiting) {
              return const _SplashScreen();
            }
            final profile = profileSnap.data;
            if (profile == null) {
              // New user → profile setup
              final user = snap.data!;
              return ProfileSetupScreen(
                uid: uid,
                name: user.displayName ?? 'Athlete',
                email: user.email ?? '',
              );
            }
            // Returning user → home
            return HomeShell(user: profile);
          },
        );
      },
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: AppColors.kineticGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 32,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: const Icon(Icons.bolt_rounded, color: AppColors.onPrimary, size: 44),
            ),
            const SizedBox(height: 20),
            const Text(
              'FitTrack',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
          ],
        ),
      ),
    );
  }
}
