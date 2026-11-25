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
class VitaFirestoreService implements IFirestoreService {
  @override
  Future<PatientProfile?> getPatientProfile(String patientId) async {
    return null;
  }

  @override
  Future<void> updatePatientProfile(PatientProfile profile) async {
  }

  @override
  Stream<List<MedicalRecord>> streamMedicalRecords(String patientId) {

    return Stream.value([]);
  }

  @override
  Future<void> addMedicalRecord(String patientId, MedicalRecord record) async {
  }

  @override
  Future<void> deleteMedicalRecord(String patientId, String recordId) async {
  }

  @override
  Stream<List<Medication>> streamMedications(String patientId) {
    return Stream.value([]);
  }

  @override
  Future<void> toggleMedicationAdherence(String patientId, String medicationId, bool isTaken) async {
  }

  @override
  Future<void> addMedication(String patientId, Medication medication) async {
  }

  @override
  Stream<List<DoctorAccessGrant>> streamDoctorGrants(String patientId) {
    return Stream.value([]);
  }

  @override
  Future<void> createDoctorGrant(String patientId, DoctorAccessGrant grant) async {
  }

  @override
  Future<void> revokeDoctorGrant(String patientId, String grantId) async {
  }

  @override
  Stream<List<TimelineEvent>> streamTimelineEvents(String patientId) {
    return Stream.value([]);
  }
}
