# 🏋️ FitTrack - Personal Fitness Tracking Application

> A modern, feature-rich Flutter fitness tracking app with real-time data synchronization, Google Sign-In authentication, and comprehensive workout analytics.

[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?style=flat-square&logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Cloud-orange?style=flat-square&logo=firebase)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)](LICENSE)
[![Status](https://img.shields.io/badge/Status-Production%20Ready-success?style=flat-square)](/)

---

## 📋 Table of Contents

- [Features](#-features)
- [Tech Stack](#-tech-stack)
- [Prerequisites](#-prerequisites)
- [Installation](#-installation)
- [Configuration](#-configuration)
- [Project Structure](#-project-structure)
- [Usage Guide](#-usage-guide)
- [Architecture](#-architecture)
- [Data Structure](#-data-structure)
- [API Reference](#-api-reference)
- [Troubleshooting](#-troubleshooting)
- [Contributing](#-contributing)
- [License](#-license)

---

## ✨ Features

### 🔐 Authentication
- **Email/Password Sign-In**: Secure authentication with Firebase Auth
- **Google Sign-In**: One-tap sign-up and sign-in with Google accounts
- **Auto-Routing**: Intelligent navigation based on authentication state
- **Persistent Sessions**: Automatic login on app restart

### 📊 Dashboard
- **Daily Statistics**: Real-time display of steps, calories burned, water intake
- **Progress Tracking**: Visual representations of fitness goals
- **Weekly Analytics**: Charts and graphs for trend analysis
- **Quick Stats**: At-a-glance summary of key metrics

### 💪 Workout Logging
- **Easy Log Entry**: Simple form to record exercises and activities
- **Multiple Fields**: Exercise name, duration, calories burned, date/time
- **Instant Save**: Auto-save with cloud synchronization
- **Edit/Delete**: Modify or remove past workouts

### 🎯 Goal Management
- **Set Goals**: Create fitness goals with target values and deadlines
- **Track Progress**: Monitor goal completion in real-time
- **Multiple Types**: Support for step goals, calorie burn targets, water intake, etc.
- **Achievements**: Unlock badges when completing milestones

### 👤 Profile Management
- **Personal Info**: Set age, height, weight, and fitness level
- **Profile Picture**: Upload and manage avatar with image optimization
- **Edit Details**: Update any profile information anytime
- **Reset Password**: Secure password recovery via email

### 📱 User Interface
- **Bottom Navigation**: Quick access to all main screens (Home, History, Log, Progress, Profile)
- **Side Drawer**: Menu with navigation, settings, and sign-out
- **Responsive Design**: Optimized for various screen sizes
- **Material Design**: Clean, modern UI following Material 3 guidelines
- **Dark Mode Ready**: Theme system for light/dark mode support

### 📈 Workout History
- **Complete Log**: View all past workouts with details
- **Filter & Sort**: Search by date, exercise type, or duration
- **Statistics**: Aggregate data for fitness insights
- **Export Ready**: Data structure supports easy data export

---

## 🛠 Tech Stack

### Frontend
- **Framework**: [Flutter 3.x](https://flutter.dev) - Cross-platform mobile development
- **State Management**: RxDart, Streams, StreamBuilder
- **Navigation**: Go Router with nested navigation support
- **UI Components**: Material 3 Design System

### Backend & Cloud
- **Authentication**: [Firebase Authentication](https://firebase.google.com/products/auth)
- **Database**: [Cloud Firestore](https://firebase.google.com/products/firestore) - Real-time NoSQL
- **Storage**: [Firebase Storage](https://firebase.google.com/products/storage) - Image storage
- **Cloud Functions**: Ready for serverless backend logic

### Key Packages
```yaml
firebase_core: ^2.24.2
firebase_auth: ^4.15.3
cloud_firestore: ^4.14.0
firebase_storage: ^11.5.6
google_sign_in: ^6.2.1
image_picker: ^1.0.4
uuid: ^4.0.0
rxdart: ^0.27.7
```

---

## 📦 Prerequisites

Before you begin, ensure you have:

- **Flutter SDK**: v3.0 or higher
  ```bash
  flutter --version
  ```
- **Dart SDK**: v3.0 or higher (included with Flutter)
- **Android SDK**: API level 21 or higher
- **Firebase Project**: Active Firebase project with Firestore enabled
- **Google Play Services**: Latest version installed on Android
- **IDE**: Android Studio, VS Code, or IntelliJ IDEA with Flutter plugin

### System Requirements
| Component | Minimum | Recommended |
|-----------|---------|-------------|
| RAM | 4 GB | 8 GB |
| Storage | 2 GB | 5 GB |
| Android API | 21 | 33+ |
| Flutter | 3.0 | 3.16+ |

---

## 🚀 Installation

### 1. Clone the Repository
```bash
git clone https://github.com/Ali-Hassan-edu/CodeAlpha_fittrack.git
cd Fitness_Tracker
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Generate Build Files (if needed)
```bash
flutter pub run build_runner build
```

### 4. Clean Build (recommended for fresh setup)
```bash
flutter clean
flutter pub get
```

---

## ⚙️ Configuration

### Step 1: Firebase Project Setup

#### 1.1 Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click **Add Project** and follow the wizard
3. Project name: `CodeAlpha_fittrack`
4. Enable Google Analytics (optional)

#### 1.2 Add Android App
1. In Firebase Console → **Project Settings**
2. Click **Add App** → Select **Android**
3. Package name: `com.example.fitness_tracker`
4. Enter app nickname: `FitTrack Android`
5. Download `google-services.json`
6. Place file in: `android/app/google-services.json`

#### 1.3 Enable Firestore Database
1. Firebase Console → **Build** → **Firestore Database**
2. Click **Create Database**
3. Select location (e.g., `us-central1`)
4. Start in **Test Mode** initially (will update rules later)

#### 1.4 Enable Firebase Authentication
1. Firebase Console → **Build** → **Authentication**
2. Click **Get Started**
3. Enable providers:
   - **Email/Password**: Click enable
   - **Google**: Click enable, add project support email

### Step 2: Configure Firebase Security Rules

#### 2.1 Firestore Rules
1. Firebase Console → **Firestore Database** → **Rules** tab
2. Replace all content with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // User data and subcollections
    match /users/{userId} {
      allow read, create, update, delete: if request.auth.uid == userId;
      
      // Workouts subcollection
      match /workouts/{document=**} {
        allow read, create, update, delete: if request.auth.uid == userId;
      }
      
      // Daily summaries subcollection
      match /daily_summaries/{document=**} {
        allow read, create, update, delete: if request.auth.uid == userId;
      }
      
      // Goals subcollection
      match /goals/{document=**} {
        allow read, create, update, delete: if request.auth.uid == userId;
      }
      
      // Achievements subcollection
      match /achievements/{document=**} {
        allow read, create, update, delete: if request.auth.uid == userId;
      }
    }
  }
}
```

3. Click **Publish**
4. Wait for confirmation (usually 30 seconds - 1 minute)

#### 2.2 Storage Rules
1. Firebase Console → **Storage** → **Rules** tab
2. Replace with:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /avatars/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId 
                   && request.resource.size < 5 * 1024 * 1024
                   && request.resource.contentType.matches('image/.*');
    }
  }
}
```

3. Click **Publish**

### Step 3: Configure Google Sign-In

#### 3.1 Get Debug SHA-1 Fingerprint
```bash
cd android
./gradlew signingReport
```

Look for `Variant: debug` → copy the **SHA1** value

#### 3.2 Add to Firebase Console
1. Firebase Console → **Project Settings**
2. Select **Your Apps** → Android app
3. Scroll to **SHA certificate fingerprints**
4. Click **Add fingerprint**
5. Paste the SHA1 from step 3.1
6. Click **Save**

#### 3.3 Download Updated google-services.json
1. Firebase Console → **Project Settings** → Android app
2. Click **google-services.json** download button
3. Replace file at: `android/app/google-services.json`

### Step 4: Build Configuration

Ensure `android/app/build.gradle.kts` contains:

```kotlin
plugins {
    id 'com.android.application'
    id 'kotlin-android'
    id 'com.google.gms.google-services'
}

android {
    compileSdk 34
    
    defaultConfig {
        applicationId "com.example.fitness_tracker"
        minSdk 21
        targetSdk 34
        versionCode 1
        versionName "1.0.0"
    }
}

dependencies {
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
}
```

---

## 📱 Usage Guide

### First Time Setup

1. **Launch App**
   ```bash
   flutter run
   ```

2. **Welcome Screen**
   - Tap **Sign In with Email** or **Sign In with Google**

3. **Create Account**
   - Enter email and password (or use Google account)
   - Click **Sign Up**

4. **Profile Setup**
   - Enter personal information (name, age, height, weight)
   - Set fitness goals
   - Add profile picture (optional)
   - Click **Complete Setup**

5. **Dashboard**
   - View today's stats
   - Navigate using bottom navigation bar

### Daily Usage

#### Log a Workout
1. Tap **+** button (center of bottom nav)
2. Enter exercise details:
   - Exercise name
   - Duration (minutes)
   - Calories burned
   - Date & time
3. Tap **Save Workout**

#### View History
1. Tap **History** tab
2. Scroll to view past workouts
3. Swipe to delete (optional)

#### Track Goals
1. Tap **Progress** tab
2. View current goals and progress
3. Tap **+** to add new goal:
   - Goal type (steps, calories, water, etc.)
   - Target value
   - Target date
4. Tap **Add Goal**

#### Manage Profile
1. Tap **Profile** tab
2. **Edit Name**: Tap name field
3. **Upload Picture**: Tap avatar
4. **Reset Password**: Open drawer → **Reset Password**
5. **Sign Out**: Open drawer → **Sign Out**

---

## 🏗 Project Structure

```
lib/
├── main.dart                          # Entry point, auth routing
├── models/
│   └── models.dart                   # Data models (UserProfile, Workout, etc.)
├── screens/
│   ├── home_shell.dart              # Main navigation container
│   ├── dashboard_screen.dart        # Home/stats screen
│   ├── history_screen.dart          # Workout history
│   ├── log_workout_screen.dart      # Add workout form
│   ├── progress_screen.dart         # Goals & analytics
│   ├── profile_screen.dart          # User profile
│   ├── profile_setup_screen.dart    # Onboarding wizard
│   ├── welcome_screen.dart          # Login/signup
│   └── login_screen.dart            # Email/password login
├── services/
│   └── firebase_service.dart        # All Firebase operations
├── theme/
│   └── app_theme.dart               # Colors, typography, themes
└── widgets/
    └── widgets.dart                  # Reusable UI components

android/
├── app/
│   ├── build.gradle.kts             # App-level Gradle config
│   └── src/
│       ├── main/
│       ├── debug/
│       └── google-services.json     # Firebase config
└── gradle.properties                 # Gradle properties

pubspec.yaml                          # Dependencies & metadata
```

---

## 🏛 Architecture

### Authentication Flow
```
App Start
    ↓
[Firebase Auth State]
    ↓
No Auth ──→ WelcomeScreen
    ↓
Auth Exists
    ↓
[Load Firestore Profile]
    ↓
Profile Exists ──→ HomeShell (Main App)
    ↓
No Profile ──→ ProfileSetupScreen (Onboarding)
    ↓
Setup Complete ──→ HomeShell
```

### Data Flow Architecture
```
UI Screens
    ↓
[StreamBuilder]
    ↓
FirebaseService Methods (Streams)
    ↓
[Cloud Firestore / Firebase Auth]
    ↓
Cloud ↔ Local Cache
```

### Key Components

| Component | Purpose | Status |
|-----------|---------|--------|
| `_AuthGate` | Manages auth state changes | ✅ Active |
| `_ProfileLoader` | Streams user profile from Firestore | ✅ Active |
| `HomeShell` | Main navigation container | ✅ Active |
| `FirebaseService` | All cloud operations | ✅ Active |
| `StreamBuilder` | Real-time UI updates | ✅ Active |

---

## 📊 Data Structure

### Firestore Collections

```
/users/{uid}
│
├── Personal Info
│   ├── name (string)
│   ├── email (string)
│   ├── age (number)
│   ├── heightCm (number)
│   ├── weightKg (number)
│   ├── avatarUrl (string)
│   ├── fitnessLevel (string)
│   └── createdAt (timestamp)
│
├── /workouts (subcollection)
│   └── {workoutId}
│       ├── exerciseName (string)
│       ├── durationMinutes (number)
│       ├── caloriesBurned (number)
│       ├── loggedAt (timestamp)
│       └── notes (string, optional)
│
├── /daily_summaries (subcollection)
│   └── {yyyy-MM-dd}
│       ├── totalSteps (number)
│       ├── totalCaloriesBurned (number)
│       ├── waterIntakeLiters (number)
│       ├── moodScore (number, 1-5)
│       └── date (timestamp)
│
├── /goals (subcollection)
│   └── {goalId}
│       ├── title (string)
│       ├── type (string: "steps" | "calories" | "water" | "weight")
│       ├── targetValue (number)
│       ├── currentValue (number)
│       ├── targetDate (timestamp)
│       ├── createdAt (timestamp)
│       └── completed (boolean)
│
└── /achievements (subcollection)
    └── {achievementId}
        ├── title (string)
        ├── description (string)
        ├── iconCode (number)
        ├── unlockedAt (timestamp)
        └── category (string)
```

### Example Documents

**User Profile:**
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "age": 28,
  "heightCm": 180,
  "weightKg": 75,
  "avatarUrl": "https://storage.googleapis.com/...",
  "fitnessLevel": "intermediate",
  "createdAt": "2024-01-15T10:30:00Z"
}
```

**Workout Entry:**
```json
{
  "exerciseName": "Running",
  "durationMinutes": 30,
  "caloriesBurned": 350,
  "loggedAt": "2024-01-20T06:00:00Z",
  "notes": "Morning jog at park"
}
```

---

## 🔌 API Reference

### FirebaseService Methods

#### Authentication
```dart
// Sign up with email/password
Future<UserCredential> signUpWithEmail(String email, String password)

// Sign in with email/password
Future<UserCredential> signInWithEmail(String email, String password)

// Sign in with Google
Future<UserCredential> signInWithGoogle()

// Sign out
Future<void> signOut()

// Reset password
Future<void> resetPassword(String email)
```

#### Profile Management
```dart
// Get user profile stream
Stream<UserProfile?> userProfileStream(String uid)

// Create new user profile
Future<void> createUserProfile(UserProfile profile)

// Update user profile
Future<void> updateUserProfile(String uid, Map<String, dynamic> data)

// Upload avatar
Future<String> uploadAvatar(String uid, File imageFile)
```

#### Workouts
```dart
// Add workout
Future<String> addWorkoutLog(String uid, Workout workout)

// Get workouts stream
Stream<List<Workout>> workoutsStream(String uid)

// Delete workout
Future<void> deleteWorkout(String uid, String workoutId)
```

#### Goals
```dart
// Add goal
Future<String> addGoal(String uid, Goal goal)

// Get goals stream
Stream<List<Goal>> goalsStream(String uid)

// Update goal progress
Future<void> updateGoalProgress(String uid, String goalId, num newValue)

// Complete goal
Future<void> completeGoal(String uid, String goalId)
```

---

## 🐛 Troubleshooting

### Common Issues & Solutions

#### ❌ "PERMISSION_DENIED" Errors
**Problem:** All Firestore operations fail with permission errors
**Solution:**
1. Verify Firestore rules are published:
   - Firebase Console → Firestore Database → Rules tab
   - Ensure all rules are applied correctly
   - Click **Publish** button
2. Check auth state: User must be authenticated before accessing Firestore
3. Wait 1-2 minutes for rules to propagate

#### ❌ Google Sign-In Not Working
**Problem:** Google sign-in button appears but doesn't authenticate
**Solution:**
1. Verify SHA-1 fingerprint is added:
   ```bash
   cd android && ./gradlew signingReport
   ```
2. Copy SHA1 value and add to Firebase Console
3. Download updated `google-services.json`
4. Clean and rebuild:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

#### ❌ Profile Picture Not Showing
**Problem:** Avatar uploads but doesn't display
**Solution:**
1. Check Storage rules are published correctly
2. Verify image file is smaller than 5MB
3. Ensure JPEG/PNG format is used
4. Clear app cache and restart

#### ❌ Data Not Persisting
**Problem:** Added workouts/goals disappear after app restart
**Solution:**
1. Verify Firestore database is enabled
2. Check internet connection is active
3. Monitor Firestore rules and permissions
4. Check Android device storage is sufficient

#### ❌ App Crashes on Launch
**Problem:** App crashes immediately after starting
**Solution:**
1. Check Flutter SDK is updated:
   ```bash
   flutter upgrade
   ```
2. Clean everything:
   ```bash
   flutter clean
   flutter pub get
   ```
3. Check for SDK conflicts
4. Rebuild Android app:
   ```bash
   cd android && ./gradlew clean
   ```

#### ❌ Bottom Navigation Bar Hidden
**Problem:** Navigation buttons overlap with content
**Solution:**
- Verify padding in screens: Each screen should have `bottom: 100px` padding
- Check `home_shell.dart` BottomNavigationBar height matches padding
- Restart app with hot restart

### Debug Mode

Enable verbose logging:
```bash
flutter run -v
```

Monitor Firestore operations:
1. Firebase Console → Firestore Database
2. Open **Monitoring** tab
3. Watch read/write activity in real-time

---

## 🤝 Contributing

Contributions are welcome! Please follow these guidelines:

1. **Fork** the repository
2. **Create** a feature branch: `git checkout -b feature/AmazingFeature`
3. **Commit** changes: `git commit -m 'Add AmazingFeature'`
4. **Push** to branch: `git push origin feature/AmazingFeature`
5. **Open** a Pull Request

### Code Style
- Follow [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use meaningful variable names
- Add comments for complex logic
- Format code: `flutter format .`
- Run analyzer: `flutter analyze`

### Testing
- Add tests for new features
- Run tests: `flutter test`
- Maintain >80% code coverage

---

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2024 Ali Hassan

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
```

---

## 📞 Support & Contact

**Issues & Bug Reports**
- Create an issue on [GitHub Issues](https://github.com/Ali-Hassan-edu/CodeAlpha_fittrack/issues)
- Provide detailed description and steps to reproduce

**Questions & Discussions**
- Open a [GitHub Discussion](https://github.com/Ali-Hassan-edu/CodeAlpha_fittrack/discussions)
- Check FAQ section before asking

**Email Support**
- Contact: [ali.hassan.edu@gmail.com]

---

## 🎯 Roadmap

### Version 1.1 (Q2 2024)
- [ ] Dark mode support
- [ ] Export workout data to CSV
- [ ] Social features (share achievements)
- [ ] Push notifications for reminders

### Version 1.2 (Q3 2024)
- [ ] Wearable integration (Google Fit, Apple HealthKit)
- [ ] Offline mode with sync
- [ ] Advanced analytics & insights
- [ ] Nutrition tracking

### Version 2.0 (Q4 2024)
- [ ] AI-powered workout recommendations
- [ ] Social community & challenges
- [ ] Premium subscription features
- [ ] Web app version

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend infrastructure
- Material Design for UI guidelines
- All contributors and testers

---

**Last Updated:** April 2024 | **Version:** 1.0.0
