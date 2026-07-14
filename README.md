# ALU Connect

**A role-based talent matching platform connecting African Leadership University students with ALU student-led startups.**

ALU Connect bridges the gap between ALU students seeking real-world experience and student-led startups that need vetted, committed talent from within the ALU community. Every startup is verified by an admin before they can post a single opportunity  trust is built into the architecture, not added as an afterthought.

---

## Demo Video

<!-- ─────────────────────────────────────────────────────────────────────────
     REPLACE the placeholder below with your actual demo video embed.
     
     OPTION A — YouTube (recommended):
     1. Upload your video to YouTube
     2. Replace VIDEO_ID with your video's ID (from the YouTube URL)

     OPTION B — Loom:
     Replace the entire <a> block with your Loom embed code

     OPTION C — GitHub-hosted MP4 (small files only, < 10 MB):
     Replace with:  https://github.com/YOUR_USERNAME/YOUR_REPO/raw/main/demo.mp4
──────────────────────────────────────────────────────────────────────────── -->

[![ALU Connect Demo Video](https://www.youtube.com/watch?v=eAo4bEJJHoI)]

> *Click the thumbnail above to watch the full 10-minute demo walkthrough.*

---

## What It Does

| Role | Capabilities |
|---|---|
| **Student** | Browse & search opportunities, apply with a pitch, track application status, receive startup invitations, save opportunities, get skill-matched notifications |
| **Startup** | Post and manage opportunities, review applicants, update application status, invite students from the talent explorer, view venture analytics |
| **Admin** | Review and approve/reject startup registrations, send approval/rejection emails, manage the verified startup roster |

---

## Tech Stack

| Layer | Technology |
|---|---|
| **Framework** | Flutter 3.x (Android + Web) |
| **State Management** | `flutter_bloc` BLoC for auth, Cubit for all other domains |
| **Backend** | Firebase Cloud Firestore (NoSQL, 5 collections) |
| **Authentication** | Firebase Authentication (email/password) |
| **Hosting** | Firebase Hosting  [alu-spark-connect.web.app](https://alu-spark-connect.web.app) |
| **Navigation** | Custom `onGenerateRoute` with slide/fade transitions |
| **Key packages** | `equatable`, `uuid`, `url_launcher`, `file_picker`, `shimmer` |

---

## Architecture

```
┌─────────────────────────────────────────────┐
│           Presentation Layer                │
│   Screens · Widgets · Shell Navigation      │
└────────────────┬────────────────────────────┘
                 │  BlocProvider / context.watch
┌────────────────▼────────────────────────────┐
│         Business Logic Layer                │
│   AuthBloc · OpportunityCubit · AppCubit    │
│   StartupCubit · InvitationCubit · ...      │
└────────────────┬────────────────────────────┘
                 │  Repository calls
┌────────────────▼────────────────────────────┐
│             Data Layer                      │
│   8 Repository classes · Models · Enums     │
└────────────────┬────────────────────────────┘
                 │  Firebase SDK
┌────────────────▼────────────────────────────┐
│              Firebase                       │
│   Auth · Firestore · Hosting                │
└─────────────────────────────────────────────┘
```

Screens never touch Firestore directly. All I/O goes through the repository layer. 
---

## Firestore Collections

```
users/           — student, startup, and admin profiles
opportunities/   — job/role postings by approved startups
applications/    — student applications with status tracking
invitations/     — startup-initiated talent invitations
notifications/   — cross-role in-app notification feed
```

---

## Getting Started

### Prerequisites

- Flutter SDK `^3.11.5`
- Dart SDK `^3.0`
- Firebase CLI (`npm install -g firebase-tools`)
- An active Firebase project

### 1. Clone the repo

```bash
git clone https://github.com/YOUR_USERNAME/alu_spark_connect.git
cd alu_spark_connect
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Connect Firebase

```bash
firebase login
flutterfire configure
```

This generates `lib/firebase_options.dart` for your project. If you already have one, skip this step.

### 4. Deploy Firestore rules and indexes

```bash
firebase deploy --only firestore
```

### 5. Run the app

```bash
# Android
flutter run

# Web
flutter run -d chrome
```

---

## Deploying the Web Build

```bash
flutter build web --release
firebase deploy --only hosting
```

The app will be live at your Firebase Hosting URL.

---

## Creating an Admin Account

1. Sign up normally through the app using an ALU email as a **Student**
2. Open Firebase Console → Firestore → `users` collection
3. Find the document where the doc ID matches your Firebase Auth UID
4. Change the `role` field from `"student"` to `"admin"`
5. Sign out and sign back in — you will be routed to the admin panel

---

## Key Features

- **Domain-validated registration** — only `@alustudent.com` and `@alueducation.com` emails accepted
- **Startup verification gate** — startups cannot post until an admin approves them
- **Atomic batch writes** — related documents (application + notification + counter increment) are written in a single Firestore batch
- **Skill-based matching** — opportunities fan out notifications to students whose skills overlap on post
- **Optimistic UI** — bookmarks update instantly without waiting for Firestore confirmation
- **Dual-role support** — one email can hold both a student and startup profile
- **Role-level security rules** — Firestore rules enforce field-level access control server-side

---

## Project Structure

```
lib/
├── blocs/              # BLoC and Cubit state containers (one per domain)
│   ├── auth/           # AuthBloc — event-driven auth state machine
│   ├── opportunity/    # OpportunityCubit
│   ├── application/    # ApplicationCubit
│   ├── startup/        # StartupCubit
│   ├── invitation/     # InvitationCubit
│   ├── bookmark/       # BookmarkCubit (optimistic updates)
│   ├── notification/   # NotificationCubit
│   ├── admin/          # AdminCubit
│   ├── profile/        # ProfileCubit
│   └── onboarding/     # OnboardingCubit
├── core/
│   ├── constants/      # Email domains, skill lists, categories
│   └── theme/          # AppColors, AppTextStyles, AppTheme
├── data/
│   ├── models/         # UserModel, OpportunityModel, ApplicationModel, ...
│   └── repositories/   # 8 repository classes (all Firestore I/O lives here)
├── screens/
│   ├── auth/           # Welcome, SignIn, SignUp, Pending
│   ├── admin/          # AdminScreen
│   ├── onboarding/     # TailorFeed, CompleteProfile, StartupOnboarding
│   ├── student/        # Home, Explore, Apply, Applications, Profile, ...
│   └── startup/        # Dashboard, PostOpportunity, Applicants, Talent, ...
├── widgets/            # Shared reusable widgets
├── main.dart           # App bootstrap, provider setup
└── router.dart         # Named route generation with transitions
```

---

## Author

**Janviere-dev**
African Leadership University · 2026

---

## License

This project is submitted as academic coursework for the African Leadership University. All rights reserved.
