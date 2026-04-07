# 🔥 FitTrack — Firebase Setup Guide
### Complete Step-by-Step for CodeAlpha Task 3

---

## 📋 What We're Setting Up

| Service | Purpose |
|---|---|
| **Firebase Auth** | Email/password login, sign-up, password reset |
| **Cloud Firestore** | Store workouts, daily summaries, goals, achievements |
| **Firebase Storage** | Profile photo uploads |
| **FlutterFire CLI** | Auto-generates `firebase_options.dart` for all platforms |

---

## STEP 1 — Create a Firebase Project

1. Go to **[https://console.firebase.google.com](https://console.firebase.google.com)**
2. Click **"Add project"**
3. Enter project name: `fittrack-codealpha` (or any name you like)
4. **Disable** Google Analytics (not needed for this project)
5. Click **"Create project"** → wait for it to provision (~30 seconds)

---

## STEP 2 — Enable Firebase Authentication

1. In your Firebase project, click **"Authentication"** in the left sidebar
2. Click **"Get started"**
3. Under **"Sign-in method"** tab, click **"Email/Password"**
4. Toggle **"Enable"** to ON
5. Click **"Save"**

> **Optional Advanced Auth:** If you want Google Sign-In later, also enable "Google" under Sign-in providers and add your SHA-1 key.

---

## STEP 3 — Create Cloud Firestore Database

1. Click **"Firestore Database"** in the left sidebar
2. Click **"Create database"**
3. Choose **"Start in test mode"** (we'll secure it properly in Step 7)
4. Select your nearest region (e.g., `asia-south1` for Pakistan/India, `us-central` for US)
5. Click **"Enable"**

---

## STEP 4 — Enable Firebase Storage

1. Click **"Storage"** in the left sidebar
2. Click **"Get started"**
3. Choose **"Start in test mode"**
4. Select the **same region** you chose for Firestore
5. Click **"Done"**

---

## STEP 5 — Register Your App Platforms

### Android Setup

1. In the Firebase console, click the **Android icon** (⚙ Project settings → Your apps → Add app)
2. Enter your Android package name — open `android/app/build.gradle` and find `applicationId`:
   ```
   com.yourname.fittrack
   ```
3. Enter app nickname: `FitTrack Android`
4. Click **"Register app"**
5. Download **`google-services.json`**
6. Place it at: `android/app/google-services.json`

**Add to `android/build.gradle` (project-level):**
```gradle
buildscript {
    dependencies {
        // ADD THIS LINE:
        classpath 'com.google.gms:google-services:4.4.2'
    }
}
```

**Add to `android/app/build.gradle` (app-level), at the very bottom:**
```gradle
apply plugin: 'com.google.gms.google-services'
```

**Also ensure `minSdkVersion` is at least 21:**
```gradle
defaultConfig {
    minSdkVersion 21
    // ...
}
```

---

### iOS Setup

1. In Firebase console, click **"Add app"** → iOS icon
2. Enter iOS bundle ID — open `ios/Runner.xcodeproj` in Xcode → Runner target → General → Bundle Identifier:
   ```
   com.yourname.fittrack
   ```
3. Download **`GoogleService-Info.plist`**
4. Open Xcode, right-click the `Runner` folder → **"Add Files to Runner"**
5. Select `GoogleService-Info.plist` — make sure **"Copy items if needed"** is checked

---

## STEP 6 — Install FlutterFire CLI & Generate Config

This is the easiest way to connect Flutter to Firebase on all platforms at once.

### Install FlutterFire CLI

```bash
# Make sure you're logged into Firebase
npm install -g firebase-tools
firebase login

# Install FlutterFire CLI
dart pub global activate flutterfire_cli
```

### Run FlutterFire Configure

In your project root (where `pubspec.yaml` is):

```bash
flutterfire configure
```

**What this does:**
- Lists your Firebase projects — select `fittrack-codealpha`
- Auto-detects your platforms (Android, iOS, Web)
- **Auto-generates `lib/firebase_options.dart`** — this is the file imported in `main.dart`

> ✅ You do NOT need to manually create `firebase_options.dart` — FlutterFire CLI generates it for you.

---

## STEP 7 — Firestore Security Rules

Replace the default test-mode rules with these production-ready rules.

In Firebase Console → Firestore → **Rules** tab, paste:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // ── Users can only read/write their own profile ──────────────────────────
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // Subcollections: workouts and goals
      match /workouts/{workoutId} {
        allow read, write, delete: if request.auth != null 
          && request.auth.uid == userId;
      }
      
      match /goals/{goalId} {
        allow read, write, delete: if request.auth != null 
          && request.auth.uid == userId;
      }
      
      match /achievements/{achievementId} {
        allow read: if request.auth != null && request.auth.uid == userId;
        // Achievements are written by the app logic only
        allow write: if request.auth != null && request.auth.uid == userId;
      }
    }
    
    // ── Daily summaries (keyed by uid_date) ──────────────────────────────────
    match /daily_summaries/{summaryId} {
      allow read, write: if request.auth != null 
        && resource.data.userId == request.auth.uid;
      // Allow create if the summaryId starts with the user's uid
      allow create: if request.auth != null
        && summaryId.matches(request.auth.uid + '_.*');
    }
    
  }
}
```

Click **"Publish"** to activate.

---

## STEP 8 — Firebase Storage Rules

In Firebase Console → Storage → **Rules** tab:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    
    // ── Profile avatars — each user can only write their own ─────────────────
    match /avatars/{userId}.jpg {
      allow read: if request.auth != null;
      allow write: if request.auth != null 
        && request.auth.uid == userId
        && request.resource.size < 5 * 1024 * 1024  // 5MB max
        && request.resource.contentType.matches('image/.*');
    }
    
  }
}
```

Click **"Publish"**.

---

## STEP 9 — Firestore Indexes

Some queries require composite indexes. Firebase will usually show a link in the debug console when an index is needed, but you can create them proactively.

In Firebase Console → Firestore → **Indexes** tab → **Composite** → Add index:

| Collection | Fields | Order | Query scope |
|---|---|---|---|
| `daily_summaries` | `userId` ASC, `date` ASC | — | Collection |
| `users/{uid}/workouts` | `loggedAt` DESC | — | Collection group |
| `users/{uid}/goals` | `targetDate` ASC | — | Collection group |

---

## STEP 10 — Install Flutter Dependencies

In your project root:

```bash
flutter pub get
```

---

## STEP 11 — Run the App

```bash
# Android
flutter run

# iOS (Mac only)
flutter run -d ios

# Specific device
flutter devices
flutter run -d <device-id>
```

---

## 🗃️ Firestore Data Structure

```
/users/{uid}
  ├── name: "Ahmed Khan"
  ├── email: "ahmed@example.com"
  ├── age: 24
  ├── heightCm: 175
  ├── weightKg: 72
  ├── fitnessGoal: "build_muscle"
  ├── dailyStepGoal: 10000
  ├── dailyCalorieGoal: 500
  ├── weeklyWorkoutGoal: 4
  └── createdAt: Timestamp

  /workouts/{workoutId}
    ├── exerciseType: "Strength"
    ├── exerciseName: "Bench Press"
    ├── durationMinutes: 45
    ├── caloriesBurned: 280.5
    ├── sets: 4
    ├── reps: 10
    ├── weightKg: 60
    ├── heartRateBpm: 145
    ├── intensity: "high"
    ├── notes: "New PR!"
    └── loggedAt: Timestamp

  /goals/{goalId}
    ├── title: "Run 100km this month"
    ├── type: "distance"
    ├── targetValue: 100
    ├── currentValue: 42.5
    ├── startDate: Timestamp
    ├── targetDate: Timestamp
    └── isCompleted: false

  /achievements/{achievementId}
    ├── title: "First Workout"
    ├── description: "Logged your very first session!"
    ├── iconCode: "e838"
    └── unlockedAt: Timestamp

/daily_summaries/{uid_yyyy-MM-dd}
  ├── userId: "uid"
  ├── date: Timestamp
  ├── totalSteps: 8432
  ├── totalCaloriesBurned: 420.0
  ├── totalActiveMinutes: 65
  ├── workoutCount: 2
  ├── totalDistanceKm: 5.2
  ├── waterIntakeLiters: 2.25      ← Advanced feature
  ├── sleepHours: 7.5              ← Advanced feature
  ├── avgHeartRate: 138            ← Advanced feature
  ├── moodScore: 4                 ← Advanced feature (1–5)
  └── weightKg: 72                 ← Advanced feature
```

---

## 🚨 Common Issues & Fixes

### ❌ `google-services.json` not found
Make sure the file is at `android/app/google-services.json` (inside `app/`, not just `android/`)

### ❌ `PigeonUserDetails` / Auth crash on Android
Ensure `minSdkVersion` is 21 or higher in `android/app/build.gradle`

### ❌ `firebase_options.dart` not found
Run `flutterfire configure` from the project root to generate it.

### ❌ Firestore permission denied
You're in test mode and the rules expired (test mode expires after 30 days), or you haven't published the security rules from Step 7.

### ❌ iOS build fails with Firebase
Run these in `ios/` folder:
```bash
pod install --repo-update
```

### ❌ Gradle build fails
```bash
cd android
./gradlew clean
cd ..
flutter pub get
flutter run
```

---

## ✅ Quick Checklist

- [ ] Firebase project created
- [ ] Email/Password auth enabled
- [ ] Firestore database created (test mode)
- [ ] Storage bucket created
- [ ] Android: `google-services.json` placed in `android/app/`
- [ ] iOS: `GoogleService-Info.plist` added via Xcode
- [ ] `flutterfire configure` run → `firebase_options.dart` generated
- [ ] Security rules published for Firestore
- [ ] Security rules published for Storage
- [ ] Composite indexes created
- [ ] `flutter pub get` run successfully
- [ ] App runs on device/emulator

---

## 📞 Resources

| Resource | Link |
|---|---|
| Firebase Console | https://console.firebase.google.com |
| FlutterFire Docs | https://firebase.flutter.dev |
| Firestore Docs | https://firebase.google.com/docs/firestore |
| FlutterFire CLI | https://firebase.flutter.dev/docs/cli |

---

*Made for CodeAlpha App Development Internship — Task 3: Fitness Tracker App*
