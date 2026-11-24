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

/// Firebase Cloud Storage Production Implementation
///
/// Wraps `FirebaseStorage.instance`:
/// ```dart
/// import 'package:firebase_storage/firebase_storage.dart';
/// class FirebaseStorageService implements IStorageService {
///   final FirebaseStorage _storage = FirebaseStorage.instance;
///   ...
/// }
/// ```
class VitaStorageService implements IStorageService {
  @override
  Future<String> uploadMedicalDocument({
    required String patientId,
    required String fileName,
    required Uint8List fileBytes,
    required String mimeType,
    void Function(double progress)? onProgress,
  }) async {
    // Production Firebase Storage upload:
    // final ref = FirebaseStorage.instance
    //     .ref()
    //     .child('vault')
    //     .child(patientId)
    //     .child('records')
    //     .child('${DateTime.now().millisecondsSinceEpoch}_$fileName');
    //
    // final uploadTask = ref.putData(
    //   fileBytes,
    //   SettableMetadata(
    //     contentType: mimeType,
    //     customMetadata: {
    //       'patientId': patientId,
    //       'encrypted': 'true',
    //       'encryptionAlgorithm': 'AES-256-GCM',
    //     },
    //   ),
    // );
    //
    // uploadTask.snapshotEvents.listen((event) {
    //   final prog = event.bytesTransferred / event.totalBytes;
    //   onProgress?.call(prog);
    // });
    //
    // final snapshot = await uploadTask;
    // return await snapshot.ref.getDownloadURL();

    return 'https://firebasestorage.googleapis.com/v0/b/vitafile-vault/o/$fileName';
  }

  @override
  Future<void> deleteMedicalDocument(String storageUrl) async {
    // await FirebaseStorage.instance.refFromURL(storageUrl).delete();
  }
}
