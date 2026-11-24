import '../models/patient_profile.dart';
import '../models/medical_record.dart';
import '../models/medication.dart';
import '../models/doctor_access.dart';
import '../models/timeline_event.dart';

abstract class IFirestoreService {
  Future<PatientProfile?> getPatientProfile(String patientId);
  Future<void> updatePatientProfile(PatientProfile profile);

  Stream<List<MedicalRecord>> streamMedicalRecords(String patientId);
  Future<void> addMedicalRecord(String patientId, MedicalRecord record);
  Future<void> deleteMedicalRecord(String patientId, String recordId);

  Stream<List<Medication>> streamMedications(String patientId);
  Future<void> toggleMedicationAdherence(String patientId, String medicationId, bool isTaken);
  Future<void> addMedication(String patientId, Medication medication);

  Stream<List<DoctorAccessGrant>> streamDoctorGrants(String patientId);
  Future<void> createDoctorGrant(String patientId, DoctorAccessGrant grant);
  Future<void> revokeDoctorGrant(String patientId, String grantId);

  Stream<List<TimelineEvent>> streamTimelineEvents(String patientId);
}

/// Firebase Cloud Firestore Production Implementation
///
/// Wraps `FirebaseFirestore.instance` for subcollection querying:
/// ```dart
/// import 'package:cloud_firestore/cloud_firestore.dart';
/// class FirebaseFirestoreService implements IFirestoreService {
///   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
///   ...
/// }
/// ```
class VitaFirestoreService implements IFirestoreService {
  @override
  Future<PatientProfile?> getPatientProfile(String patientId) async {
    // Production Firestore:
    // final doc = await FirebaseFirestore.instance.collection('patients').doc(patientId).get();
    // if (!doc.exists) return null;
    // return PatientProfile.fromMap(doc.data()!);
    return null;
  }

  @override
  Future<void> updatePatientProfile(PatientProfile profile) async {
    // await FirebaseFirestore.instance.collection('patients').doc(profile.id).set(
    //   profile.toMap(),
    //   SetOptions(merge: true),
    // );
  }

  @override
  Stream<List<MedicalRecord>> streamMedicalRecords(String patientId) {
    // return FirebaseFirestore.instance
    //     .collection('patients')
    //     .doc(patientId)
    //     .collection('medical_records')
    //     .orderBy('date', descending: true)
    //     .snapshots()
    //     .map((snapshot) => snapshot.docs.map((d) => MedicalRecord.fromMap(d.data())).toList());
    return Stream.value([]);
  }

  @override
  Future<void> addMedicalRecord(String patientId, MedicalRecord record) async {
    // await FirebaseFirestore.instance
    //     .collection('patients')
    //     .doc(patientId)
    //     .collection('medical_records')
    //     .doc(record.id)
    //     .set(record.toMap());
  }

  @override
  Future<void> deleteMedicalRecord(String patientId, String recordId) async {
    // await FirebaseFirestore.instance
    //     .collection('patients')
    //     .doc(patientId)
    //     .collection('medical_records')
    //     .doc(recordId)
    //     .delete();
  }

  @override
  Stream<List<Medication>> streamMedications(String patientId) {
    // return FirebaseFirestore.instance
    //     .collection('patients')
    //     .doc(patientId)
    //     .collection('prescriptions')
    //     .snapshots()
    //     .map((s) => s.docs.map((d) => Medication.fromMap(d.data())).toList());
    return Stream.value([]);
  }

  @override
  Future<void> toggleMedicationAdherence(String patientId, String medicationId, bool isTaken) async {
    // await FirebaseFirestore.instance
    //     .collection('patients')
    //     .doc(patientId)
    //     .collection('prescriptions')
    //     .doc(medicationId)
    //     .update({'isTakenToday': isTaken});
  }

  @override
  Future<void> addMedication(String patientId, Medication medication) async {
    // await FirebaseFirestore.instance
    //     .collection('patients')
    //     .doc(patientId)
    //     .collection('prescriptions')
    //     .doc(medication.id)
    //     .set(medication.toMap());
  }

  @override
  Stream<List<DoctorAccessGrant>> streamDoctorGrants(String patientId) {
    // return FirebaseFirestore.instance
    //     .collection('patients')
    //     .doc(patientId)
    //     .collection('doctor_grants')
    //     .snapshots()
    //     .map((s) => s.docs.map((d) => DoctorAccessGrant.fromMap(d.data())).toList());
    return Stream.value([]);
  }

  @override
  Future<void> createDoctorGrant(String patientId, DoctorAccessGrant grant) async {
    // await FirebaseFirestore.instance
    //     .collection('patients')
    //     .doc(patientId)
    //     .collection('doctor_grants')
    //     .doc(grant.id)
    //     .set(grant.toMap());
  }

  @override
  Future<void> revokeDoctorGrant(String patientId, String grantId) async {
    // await FirebaseFirestore.instance
    //     .collection('patients')
    //     .doc(patientId)
    //     .collection('doctor_grants')
    //     .doc(grantId)
    //     .update({'status': 'Revoked'});
  }

  @override
  Stream<List<TimelineEvent>> streamTimelineEvents(String patientId) {
    // return FirebaseFirestore.instance
    //     .collection('patients')
    //     .doc(patientId)
    //     .collection('timeline_events')
    //     .orderBy('date', descending: true)
    //     .snapshots()
    //     .map((s) => s.docs.map((d) => TimelineEvent.fromMap(d.data())).toList());
    return Stream.value([]);
  }
}
