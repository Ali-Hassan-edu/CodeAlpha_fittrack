# FitTrack — Fixed Version

## What was fixed

### 1. Firestore Rules (`firestore.rules`)
**Root cause of most failures.**  
The original app used a top-level `daily_summaries` collection and had no rules file, so every Firestore write was denied.

**Fix:**
- All data is now stored as subcollections under `/users/{uid}/` (workouts, daily_summaries, goals, achievements)
- Proper security rules added — each user can only read/write their own data
- No more `PERMISSION_DENIED` errors

### 2. Google Sign-In (`main.dart`, `firebase_service.dart`)
**Root cause:** After Google sign-in the app jumped straight to HomeShell with a fake temp profile, skipping profile setup.

**Fix:**
- `_AuthGate` now uses `_ProfileLoader` which streams the real Firestore profile
- If no profile exists (new Google user), it redirects to `ProfileSetupScreen`
- After setup, the real profile is always used — no more fake "Athlete" names

### 3. Home Screen not working (`main.dart`, `home_shell.dart`)
**Root cause:** `HomeShell` received a static `UserProfile` passed at login time; it never updated, and the temp profile had wrong/default data.

**Fix:**
- `HomeShell` now streams the live profile from Firestore via `userProfileStream()`
- Name, avatar, step goals — all update instantly everywhere when changed

### 4. Add Workout / Add Goal (`firebase_service.dart`)
**Root cause:** Firestore writes went to paths not covered by any rules.

**Fix:**
- Moved all data to user-owned subcollections
- `_upsertDailySummary` now writes to `/users/{uid}/daily_summaries/{date}`
- Proper error handling in UI with user-visible snackbars

### 5. Profile Picture Upload (`profile_screen.dart`)
**Root cause:** After uploading, the old static `user` object was displayed (no stream); avatar never showed.

**Fix:**
- `ProfileScreen` now streams its own `userProfileStream()` so the avatar shows immediately after upload
- Upload shows a loading spinner while in progress
- Image is compressed (max 800×800, 80% quality) before upload

### 6. Overlapping / Layout Issues (`dashboard_screen.dart`, `home_shell.dart`)
**Root cause:** `HomeShell` had its own `AppBar` AND `DashboardScreen` had a `SliverAppBar`, causing a double app bar. Bottom padding was too small (120px) and sometimes content scrolled under the nav bar.

**Fix:**
- Removed the `AppBar` from `HomeShell`; each screen manages its own app bar
- Bottom padding set to `100px` (matches actual nav bar height)
- The drawer menu button is now inside the `DashboardScreen`'s `SliverAppBar`

---

## Setup Instructions

### Step 1 — Apply Firestore Rules
1. Open [Firebase Console](https://console.firebase.google.com)
2. Select your project → **Firestore Database** → **Rules** tab
3. Replace the existing rules with the contents of `firestore.rules`
4. Click **Publish**

### Step 2 — Apply Storage Rules
1. In Firebase Console → **Storage** → **Rules** tab
2. Replace with the contents of `storage.rules`
3. Click **Publish**

### Step 3 — Enable Google Sign-In
1. Firebase Console → **Authentication** → **Sign-in method**
2. Enable **Google** provider
3. In Android Studio / your keystore tool, get your **debug SHA-1**:
   ```
   cd android
   ./gradlew signingReport
   ```
4. Firebase Console → **Project Settings** → **Your apps** → Add the SHA-1 fingerprint
5. Download the updated `google-services.json` and place it in `android/app/`

### Step 4 — Replace source files
Copy all files from this `fixed_app/lib/` folder into your project's `lib/` folder, replacing existing files.

### Step 5 — Run
```bash
flutter pub get
flutter run
```

---

## Data Structure (after fix)
```
/users/{uid}
  ├── name, email, avatarUrl, age, heightCm, weightKg, ...
  ├── /workouts/{workoutId}
  │     └── exerciseName, durationMinutes, caloriesBurned, loggedAt, ...
  ├── /daily_summaries/{yyyy-MM-dd}
  │     └── totalSteps, totalCaloriesBurned, waterIntakeLiters, moodScore, ...
  ├── /goals/{goalId}
  │     └── title, type, targetValue, currentValue, targetDate, ...
  └── /achievements/{achievementId}
        └── title, description, iconCode, unlockedAt
```
