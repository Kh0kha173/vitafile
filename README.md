# VitaFile - Digital Medical Records & Health Vault 🩺🔐

VitaFile is a modern, HIPAA-compliant digital healthcare mobile application built with **Flutter & Dart**. It empowers patients to securely manage, organize, and share their medical records, diagnostic imaging, prescriptions, and emergency passes with military-grade encryption.

---

## 🎨 Design System & Visual Identity

VitaFile adheres to a premium healthcare design language featuring high contrast, rounded card surfaces, and authoritative medical colors:

| Color Token | Hex Code | Purpose |
| :--- | :--- | :--- |
| **Primary Teal** | `#006D77` | Primary brand authority, buttons, active states |
| **Dark Teal** | `#004D54` | High-contrast headers and dark gradients |
| **Teal Light / Soft** | `#83C5BE` / `#E8F4F5` | Badge backgrounds, surface highlights |
| **Medical Blue** | `#0284C7` | Clinical accents, diagnostic imaging tags |
| **Emergency Red** | `#EF4444` | Critical allergies, SOS Pass, urgent alerts |
| **Success Emerald** | `#10B981` | Verification checks, medication completion |
| **Warning Amber** | `#F59E0B` | Refill reminders, moderate allergy warnings |
| **Pure White** | `#FFFFFF` | Primary card background |
| **Off-White Slate** | `#F8FAFC` | App scaffold background |

---

## 📱 Complete 12-Screen Navigation Flow

Every screen is interconnected with smooth page transitions and named routes managed by `AppRouter`:

```
                             [ Splash Screen (/) ]
                                       │
                           [ Onboarding (/onboarding) ]
                                       │
                           [ Login & Sign Up (/auth) ]
                                       │
                      [ Main Navigation Shell (/main) ]
       ┌───────────────────────┬───────────────────────┬───────────────────────┐
       ▼                       ▼                       ▼                       ▼
 [ Dashboard ]           [ Records ]            [ Medications ]         [ Settings ]
       │                       │                       │                       │
       ├─► [ Profile ]         ├─► [ Upload ]          └─► [ Refill Alert ]    └─► [ Cloud Sync ]
       ├─► [ Timeline ]        └─► [ Biomarkers ]
       ├─► [ Doctor Access ]
       └─► [ Emergency QR Pass ]
```

### Screens Summary:
1. **Splash Screen (`/`)**: Animated medical pulse logo, cryptographic AES initialization, automatic route transition.
2. **Onboarding (`/onboarding`)**: 3-step carousel explaining the unified vault, life-saving emergency pass, and doctor permissions.
3. **Login and Sign Up (`/auth`)**: Segmented switcher, biometric fingerprint/Face ID unlock, HIPAA terms consent, social health SSO.
4. **Home Dashboard (`/dashboard`)**: Patient header, Emergency Pass card (O+ Blood & Penicillin alert), live vitals grid, 6 quick actions, medication checklist, upcoming cardiology review.
5. **Digital Medical Profile (`/profile`)**: Official Vitanational Health ID layout, physical biometrics (BMI, height, weight), categorized allergies with severity tags, chronic conditions, ICE contacts, insurance policy card.
6. **Medical Records (`/records`)**: Instant keyword search, category filter chips (Labs, X-Rays, Rx, Notes, Vaccines), clinician verification badges, and comprehensive biomarker inspection sheet.
7. **Upload Lab Results & X-rays (`/upload`)**: Multi-source intake (Camera Scan, PDF Document, Gallery, DICOM), smart AI OCR extraction banner, metadata form, animated AES-256 upload progress.
8. **Medical Timeline (`/timeline`)**: Chronological health milestone tree with category nodes, year filters (2026, 2025), expandable physician diagnosis and treatment notes.
9. **Medication Tracker (`/medications`)**: Daily adherence progress circle (75% completed), 5-day perfect streak counter, tap check-off dose controls, pharmacy refill warnings, "+ Add Prescription" modal.
10. **Emergency QR Code Screen (`/emergency`)**: High-contrast first-responder view, vector scannable QR pass with cryptographic token, Blood Type O+, Penicillin anaphylaxis warning, 1-tap ICE contact dialing, lockscreen wallpaper export.
11. **Doctor Access Screen (`/doctor-access`)**: Zero-knowledge temporary access hub, generate expiring 6-digit PIN codes (1 hour, 24 hours, 7 days), granular data permissions, instant access revocation, audit log.
12. **Settings Screen (`/settings`)**: Biometric authentication, 2FA, Firebase Cloud Firestore & Storage synchronization status with manual trigger, complete HIPAA PDF export, auto-lock timeout, sign out.

---

## 🗂 Project Architecture

```
lib/
├── core/
│   ├── constants/
│   │   └── app_colors.dart         # Global color tokens and gradients
│   ├── theme/
│   │   └── app_theme.dart          # Material 3 theme & typography
│   └── navigation/
│       └── app_router.dart         # 12 named routes with custom slide/fade transitions
├── models/
│   ├── patient_profile.dart        # Profile, allergies, conditions, insurance
│   ├── medical_record.dart         # Records, categories, biomarker panels
│   ├── medication.dart             # Prescriptions, frequency, dosage, schedules
│   ├── doctor_access.dart          # Expiring grants, access PINs, audit logs
│   └── timeline_event.dart         # Chronological milestones
├── data/
│   └── sample_data.dart            # Realistic clinical sample data for testing
├── widgets/
│   ├── vita_app_bar.dart           # Unified app bar with actions
│   ├── vita_badge.dart             # Pill badges for categories & urgency
│   ├── vita_button.dart            # Primary gradient, outline & emergency buttons
│   ├── vita_card.dart              # Rounded 20px card with subtle borders
│   └── vita_text_field.dart        # Medical input fields with icon prefixes
├── screens/
│   ├── splash_screen.dart
│   ├── onboarding_screen.dart
│   ├── auth_screen.dart
│   ├── main_navigation_shell.dart
│   ├── dashboard_screen.dart
│   ├── profile_screen.dart
│   ├── records_screen.dart
│   ├── upload_screen.dart
│   ├── timeline_screen.dart
│   ├── medication_tracker_screen.dart
│   ├── emergency_qr_screen.dart
│   ├── doctor_access_screen.dart
│   └── settings_screen.dart
├── services/
│   ├── firebase_config.dart        # Cloud architecture paths & guide
│   ├── auth_service.dart           # Firebase Authentication interface & wrapper
│   ├── firestore_service.dart      # Cloud Firestore collections & CRUD
│   └── storage_service.dart        # Firebase Storage encrypted upload stream
└── main.dart                       # Entry point
```

---

## 🔥 Firebase Integration Guide

When ready to link with live Google Firebase services:

1. **Install Firebase CLI and FlutterFire**:
   ```bash
   npm install -g firebase-tools
   dart pub global activate flutterfire_cli
   flutterfire configure --project=YOUR_PROJECT_ID
   ```
2. **Add Firebase packages to `pubspec.yaml`**:
   ```yaml
   dependencies:
     firebase_core: ^3.0.0
     firebase_auth: ^5.0.0
     cloud_firestore: ^5.0.0
     firebase_storage: ^12.0.0
   ```
3. **Initialize in `main.dart`**:
   ```dart
   WidgetsFlutterBinding.ensureInitialized();
   await Firebase.initializeApp(
     options: DefaultFirebaseOptions.currentPlatform,
   );
   ```

---

## 🚀 Running the App

```bash
cd "C:\Users\F16\.gemini\antigravity\scratch\vitafile"
flutter pub get
flutter run
```
