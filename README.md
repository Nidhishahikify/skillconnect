# SkillConnect

A Flutter marketplace app connecting **users** with local **skilled workers** —
signup/login, browse & search workers, book appointments, leave feedback, and
AI-generated feedback summaries.

> This repo ships with **no real API keys or credentials** — see
> [Configuration](#configuration) below before running it.


## Features

- Email/password-style signup & login (stored as Firestore profile documents)
- Separate **User** and **Worker** roles
- Search & browse workers by name, skill, or location
- Book a worker (date/time picker, business-hour + overlap validation)
- Accept/reject bookings from the worker dashboard
- Leave star ratings + written feedback
- Optional AI-generated feedback summary per worker
- Optional transactional emails (booking confirmation, status update, password recovery)

## Project structure

```
lib/
├── main.dart                 # entry point
├── app/                      # MaterialApp, routes, theme
├── core/
│   ├── constants/             # colors, strings, API key loader
│   ├── services/               # Firebase + Email services
│   └── utils/                   # validators, helpers
├── firebase/                 # firebase_options.dart (placeholder values)
├── models/                   # plain data models
├── repositories/             # Firestore/SharedPreferences data access
├── features/                 # one folder per screen/flow
└── widgets/                  # shared reusable widgets
```

## Getting started

### 1. Install Flutter

https://docs.flutter.dev/get-started/install

### 2. Clone & install dependencies

```bash
git clone https://github.com/<your-username>/skillconnect.git
cd skillconnect
flutter pub get
```

### 3. Configuration

This project intentionally ships **without** real API keys so it's safe to
host publicly. You need to supply your own before running it.

#### Firebase (required)

The app uses **Cloud Firestore** for all data (no Firebase Auth — accounts
are plain profile documents). To connect your own Firebase project:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

This regenerates `lib/firebase/firebase_options.dart` with your project's
real values. Keep that file **out of version control** if your Firebase
project isn't meant to be public, or lock it down with Firestore security
rules instead.

Minimum required Firestore collections: `profiles`, `bookings`, `feedbacks`,
`summaries`.

#### EmailJS (optional — booking/status/password emails)

Create a free account at https://www.emailjs.com/, then run the app with:

```bash
flutter run \
  --dart-define=EMAILJS_SERVICE_ID=your_service_id \
  --dart-define=EMAILJS_PUBLIC_KEY=your_public_key \
  --dart-define=EMAILJS_TEMPLATE_ID=your_template_id \
  --dart-define=EMAILJS_PASSWORD_TEMPLATE_ID=your_password_template_id
```

If these are left blank, the app runs fine — emails are just skipped.

#### AI feedback summaries (optional)

Uses Google's Gemini API by default (see
`lib/repositories/summary_repository.dart`). Run with:

```bash
flutter run --dart-define=AI_SUMMARY_API_KEY=your_gemini_api_key
```

If left blank, the app runs fine — summaries are just skipped.

### 4. Run it

```bash
flutter run
```

## Hosting on GitHub

This repo is safe to push publicly as-is — `lib/firebase/firebase_options.dart`
and `lib/core/constants/api_keys.dart` contain **placeholder values only**.
Never commit a version of those files with real secrets; prefer
`--dart-define` (as above) or a CI/CD secret manager for production builds.

**Live demo:** https://skillhubz-83837.web.app