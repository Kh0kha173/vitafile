
class FirebaseConfig {
  FirebaseConfig._();

  static const String appName = 'VitaFile';
  static const String projectId = 'vitafile-prod-vault';
  static const String storageBucket = 'vitafile-prod-vault.appspot.com';
  static const String colUsers = 'patients';
  static const String colRecords = 'medical_records';
  static const String colMedications = 'prescriptions';
  static const String colDoctorGrants = 'doctor_grants';
  static const String colAuditLogs = 'access_audit_logs';
  static const String colTimeline = 'timeline_events';

  static String userStoragePath(String userId, String filename) =>
      'vault/$userId/records/$filename';

  static String emergencyQrPath(String userId) =>
      'vault/$userId/emergency/qr_pass.png';
}
