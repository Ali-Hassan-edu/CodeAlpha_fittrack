import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'theme/app_theme.dart';
import 'models/models.dart';
import 'screens/welcome_screen.dart';
import 'screens/home_shell.dart';
import 'screens/profile_setup_screen.dart';
import 'services/firebase_service.dart';

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

// ─── Auth Gate ─────────────────────────────────────────────────────────────────
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
          return const WelcomeScreen();
        }
        // User signed in — load their Firestore profile
        return _ProfileLoader(firebaseUser: snap.data!);
      },
    );
  }
}

// ─── Profile Loader — loads real profile or sends to setup ────────────────────
class _ProfileLoader extends StatelessWidget {
  final User firebaseUser;
  const _ProfileLoader({required this.firebaseUser});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserProfile?>(
      stream: FirestoreService().userProfileStream(firebaseUser.uid),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const _SplashScreen();
        }

        final profile = snap.data;

        // No profile in Firestore → send to setup
        if (profile == null) {
          return ProfileSetupScreen(
            uid: firebaseUser.uid,
            name: firebaseUser.displayName ?? '',
            email: firebaseUser.email ?? '',
          );
        }

        // Profile exists → go to home
        return HomeShell(user: profile);
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
              child: const Icon(
                Icons.bolt_rounded,
                color: AppColors.onPrimary,
                size: 44,
              ),
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
            const CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 2,
            ),
          ],
        ),
      ),
    );
  }
}
