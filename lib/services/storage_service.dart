import 'dart:async';
import 'dart:typed_data';

abstract class IStorageService {
  Future<String> uploadMedicalDocument({
    required String patientId,
    required String fileName,
    required Uint8List fileBytes,
    required String mimeType,
    void Function(double progress)? onProgress,
  });

  Future<void> deleteMedicalDocument(String storageUrl);
}
class VitaStorageService implements IStorageService {
  @override
  Future<String> uploadMedicalDocument({
    required String patientId,
    required String fileName,
    required Uint8List fileBytes,
    required String mimeType,
    void Function(double progress)? onProgress,
  }) async {
    return 'https://firebasestorage.googleapis.com/v0/b/vitafile-vault/o/$fileName';
  }

  @override
  Future<void> deleteMedicalDocument(String storageUrl) async {
  }
}
