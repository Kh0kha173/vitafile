enum RecordCategory {
  labTest,
  imagingXRay,
  prescription,
  doctorNote,
  vaccination,
}

extension RecordCategoryExtension on RecordCategory {
  String get displayName {
    switch (this) {
      case RecordCategory.labTest:
        return 'Lab Test';
      case RecordCategory.imagingXRay:
        return 'Imaging & X-Ray';
      case RecordCategory.prescription:
        return 'Prescription';
      case RecordCategory.doctorNote:
        return 'Doctor Note';
      case RecordCategory.vaccination:
        return 'Vaccination';
    }
  }

  String get idName {
    switch (this) {
      case RecordCategory.labTest:
        return 'lab';
      case RecordCategory.imagingXRay:
        return 'imaging';
      case RecordCategory.prescription:
        return 'prescription';
      case RecordCategory.doctorNote:
        return 'note';
      case RecordCategory.vaccination:
        return 'vaccine';
    }
  }
}

class MedicalRecord {
  final String id;
  final String title;
  final RecordCategory category;
  final String date;
  final String doctorName;
  final String facility;
  final String summary;
  final String detailedNotes;
  final String fileUrl;
  final String fileName;
  final String fileSize;
  final bool isVerified;
  final bool isAbnormal;
  final List<BiomarkerResult> biomarkers;

  const MedicalRecord({
    required this.id,
    required this.title,
    required this.category,
    required this.date,
    required this.doctorName,
    required this.facility,
    required this.summary,
    required this.detailedNotes,
    this.fileUrl = '',
    this.fileName = '',
    this.fileSize = '',
    this.isVerified = true,
    this.isAbnormal = false,
    this.biomarkers = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category.idName,
      'date': date,
      'doctorName': doctorName,
      'facility': facility,
      'summary': summary,
      'detailedNotes': detailedNotes,
      'fileUrl': fileUrl,
      'fileName': fileName,
      'fileSize': fileSize,
      'isVerified': isVerified,
      'isAbnormal': isAbnormal,
      'biomarkers': biomarkers.map((b) => b.toMap()).toList(),
    };
  }

  factory MedicalRecord.fromMap(Map<String, dynamic> map) {
    RecordCategory cat = RecordCategory.labTest;
    switch (map['category']) {
      case 'imaging':
        cat = RecordCategory.imagingXRay;
        break;
      case 'prescription':
        cat = RecordCategory.prescription;
        break;
      case 'note':
        cat = RecordCategory.doctorNote;
        break;
      case 'vaccine':
        cat = RecordCategory.vaccination;
        break;
      default:
        cat = RecordCategory.labTest;
    }

    return MedicalRecord(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      category: cat,
      date: map['date'] ?? '',
      doctorName: map['doctorName'] ?? '',
      facility: map['facility'] ?? '',
      summary: map['summary'] ?? '',
      detailedNotes: map['detailedNotes'] ?? '',
      fileUrl: map['fileUrl'] ?? '',
      fileName: map['fileName'] ?? '',
      fileSize: map['fileSize'] ?? '',
      isVerified: map['isVerified'] ?? true,
      isAbnormal: map['isAbnormal'] ?? false,
      biomarkers: List<BiomarkerResult>.from(
        (map['biomarkers'] ?? []).map((x) => BiomarkerResult.fromMap(x)),
      ),
    );
  }
}

class BiomarkerResult {
  final String name;
  final String value;
  final String unit;
  final String referenceRange;
  final bool isFlagged;

  const BiomarkerResult({
    required this.name,
    required this.value,
    required this.unit,
    required this.referenceRange,
    this.isFlagged = false,
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'value': value,
    'unit': unit,
    'referenceRange': referenceRange,
    'isFlagged': isFlagged,
  };

  factory BiomarkerResult.fromMap(Map<String, dynamic> map) => BiomarkerResult(
    name: map['name'] ?? '',
    value: map['value'] ?? '',
    unit: map['unit'] ?? '',
    referenceRange: map['referenceRange'] ?? '',
    isFlagged: map['isFlagged'] ?? false,
  );
}
