# 🏋️ FitTrack — Kinetic Sanctuary
### CodeAlpha App Development Internship — Task 3: Fitness Tracker App

---

## 📱 App Overview

FitTrack is a premium Flutter fitness tracker built on the **"Kinetic Sanctuary"** design system — a mint-and-blue editorial aesthetic that feels like a high-end gym: airy, clean, and data-rich.

---

## ✨ Features Implemented

### ✅ Required (Task 3)
| Feature | Screen |
|---|---|
| Track steps, workouts, calories burned | Dashboard + Log Workout |
| Manual data logging (workout type, duration, calories) | Log Workout Screen |
| Dashboard with daily summary | Daily Dashboard |
| Weekly progress with bar charts | Progress Screen |
| Local + Firebase data storage | Firestore + Daily Summaries |

### 🆕 Advanced Features (Beyond Task 3)
| Feature | Description |
|---|---|
| **Water Intake Tracker** | Log 250ml increments, daily goal with progress ring |
| **Mood Tracker** | 1–5 emoji mood score per day, weekly mood trend chart |
| **Heart Rate Logging** | Log avg BPM per workout |
| **BMI Calculator** | Auto-computed from height/weight in profile |
| **MET-based Calorie Estimation** | If user leaves calories blank, app estimates using METs |
| **Achievements / Badges** | Firestore-backed achievement system |
| **Workout Search & Filter** | Filter history by type, search by name |
| **Grouped History** | Workouts grouped by Today / Yesterday / Date |
| **Sleep Tracking** | Sleep hours logged in daily summary |
| **3-Step Onboarding** | Age → body metrics → fitness goal setup |
| **Glassmorphism UI** | Frosted teal app bars with backdrop blur |
| **Animated Progress Rings** | Custom-painted circular progress indicators |
| **Floating Island Nav Bar** | Rounded floating bottom nav bar |
| **Animated Onboarding** | Fade + slide animations between onboarding pages |

---

## 📁 Project Structure

```
lib/
├── main.dart                    ← App entry + Firebase init + auth routing
├── theme/
│   └── app_theme.dart           ← Kinetic Sanctuary color tokens & ThemeData
├── models/
│   └── models.dart              ← UserProfile, WorkoutLog, DailySummary, FitnessGoal, Achievement
├── services/
│   └── firebase_service.dart    ← AuthService + FirestoreService (all Firestore ops)
├── widgets/
│   └── widgets.dart             ← KineticButton, ProgressRing, StatCard, WorkoutTile,
│                                   WeeklyBarChart, WaterIntakeWidget, MoodTrackerWidget,
│                                   KineticBottomNav, GlassAppBar
└── screens/
    ├── welcome_screen.dart       ← Animated 3-page onboarding
    ├── login_screen.dart         ← Login + SignUp screens
    ├── home_shell.dart           ← Bottom nav shell + Profile Setup (3-step)
    ├── dashboard_screen.dart     ← Daily dashboard, step hero, stat cards, weekly chart
    ├── log_workout_screen.dart   ← Full workout logging form with all metrics
    ├── history_screen.dart       ← Searchable, filterable workout history
    ├── progress_screen.dart      ← Analytics tab + Goals tab with CRUD
    └── profile_screen.dart       ← User stats, settings, sign out
```

---

## 🎨 Design System — Kinetic Sanctuary

| Token | Value | Usage |
|---|---|---|
| `primary` | `#006854` | Buttons, rings, active states |
| `primaryContainer` | `#33F5CB` | Gradient endpoint, highlights |
| `secondary` | `#0055C4` | Electric blue accents, water widget |
| `tertiary` | `#9B3F00` | High intensity, PRs |
| `surface` | `#D5FFF7` | App background (Frosted Teal) |
| `surfaceContainerLowest` | `#FFFFFF` | Cards ("clean white workout towel") |
| `onSurface` | `#003530` | Primary text (never pure black) |

**Fonts:** Plus Jakarta Sans (headlines) · Inter (body) · Lexend (labels/micro-data)

---

## 🚀 Getting Started

1. **Clone / open** this project in VS Code or Android Studio
2. Run `flutter pub get`
3. Follow `FIREBASE_SETUP.md` to connect Firebase
4. Run `flutterfire configure` to generate `lib/firebase_options.dart`
5. `flutter run`

---

## 📤 Submission Notes (CodeAlpha)

- GitHub repo name: `CodeAlpha_FitnessTrackerApp`
- Record a screen-recorded demo video showing all screens
- Post on LinkedIn tagging @CodeAlpha with GitHub link
- Submit via the CodeAlpha submission form

---

*Built with Flutter 3.x · Firebase · Dart 3 · Material Design 3*
