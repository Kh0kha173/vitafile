/// VitaFile Firebase Configuration & Initialization Guide
///
/// To connect this application to live Firebase services:
/// 1. Run `flutterfire configure --project=vitafile-health-vault`
/// 2. Place `google-services.json` inside `android/app/`
/// 3. Place `GoogleService-Info.plist` inside `ios/Runner/`
/// 4. Add the following dependencies to `pubspec.yaml`:
///    - firebase_core: ^3.0.0
///    - firebase_auth: ^5.0.0
///    - cloud_firestore: ^5.0.0
///    - firebase_storage: ^12.0.0

class FirebaseConfig {
  FirebaseConfig._();

  static const String appName = 'VitaFile';
  static const String projectId = 'vitafile-prod-vault';
  static const String storageBucket = 'vitafile-prod-vault.appspot.com';

  // Firestore Collection Paths
  static const String colUsers = 'patients';
  static const String colRecords = 'medical_records';
  static const String colMedications = 'prescriptions';
  static const String colDoctorGrants = 'doctor_grants';
  static const String colAuditLogs = 'access_audit_logs';
  static const String colTimeline = 'timeline_events';

  // Storage Paths
  static String userStoragePath(String userId, String filename) =>
      'vault/$userId/records/$filename';

  static String emergencyQrPath(String userId) =>
      'vault/$userId/emergency/qr_pass.png';
}
