class PatientProfile {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String dateOfBirth;
  final int age;
  final String gender;
  final String bloodType;
  final bool isOrganDonor;
  final double heightCm;
  final double weightKg;
  final List<AllergyItem> allergies;
  final List<ChronicCondition> conditions;
  final List<EmergencyContact> emergencyContacts;
  final InsuranceInfo insurance;
  final String emergencyNotes;
  final String profileImageUrl;

  const PatientProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.dateOfBirth,
    required this.age,
    required this.gender,
    required this.bloodType,
    required this.isOrganDonor,
    required this.heightCm,
    required this.weightKg,
    required this.allergies,
    required this.conditions,
    required this.emergencyContacts,
    required this.insurance,
    required this.emergencyNotes,
    this.profileImageUrl = '',
  });

  double get bmi => (weightKg / ((heightCm / 100) * (heightCm / 100)));

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'dateOfBirth': dateOfBirth,
      'age': age,
      'gender': gender,
      'bloodType': bloodType,
      'isOrganDonor': isOrganDonor,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'allergies': allergies.map((x) => x.toMap()).toList(),
      'conditions': conditions.map((x) => x.toMap()).toList(),
      'emergencyContacts': emergencyContacts.map((x) => x.toMap()).toList(),
      'insurance': insurance.toMap(),
      'emergencyNotes': emergencyNotes,
      'profileImageUrl': profileImageUrl,
    };
  }

  factory PatientProfile.fromMap(Map<String, dynamic> map) {
    return PatientProfile(
      id: map['id'] ?? '',
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      dateOfBirth: map['dateOfBirth'] ?? '',
      age: map['age']?.toInt() ?? 0,
      gender: map['gender'] ?? '',
      bloodType: map['bloodType'] ?? '',
      isOrganDonor: map['isOrganDonor'] ?? false,
      heightCm: (map['heightCm'] as num?)?.toDouble() ?? 0.0,
      weightKg: (map['weightKg'] as num?)?.toDouble() ?? 0.0,
      allergies: List<AllergyItem>.from(
        (map['allergies'] ?? []).map((x) => AllergyItem.fromMap(x)),
      ),
      conditions: List<ChronicCondition>.from(
        (map['conditions'] ?? []).map((x) => ChronicCondition.fromMap(x)),
      ),
      emergencyContacts: List<EmergencyContact>.from(
        (map['emergencyContacts'] ?? []).map((x) => EmergencyContact.fromMap(x)),
      ),
      insurance: InsuranceInfo.fromMap(map['insurance'] ?? {}),
      emergencyNotes: map['emergencyNotes'] ?? '',
      profileImageUrl: map['profileImageUrl'] ?? '',
    );
  }
}

class AllergyItem {
  final String substance;
  final String severity; // High, Moderate, Mild
  final String reaction;

  const AllergyItem({
    required this.substance,
    required this.severity,
    required this.reaction,
  });

  Map<String, dynamic> toMap() => {
    'substance': substance,
    'severity': severity,
    'reaction': reaction,
  };

  factory AllergyItem.fromMap(Map<String, dynamic> map) => AllergyItem(
    substance: map['substance'] ?? '',
    severity: map['severity'] ?? 'Moderate',
    reaction: map['reaction'] ?? '',
  );
}

class ChronicCondition {
  final String name;
  final String diagnosedYear;
  final String status; // Managed, Active, In Remission

  const ChronicCondition({
    required this.name,
    required this.diagnosedYear,
    required this.status,
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'diagnosedYear': diagnosedYear,
    'status': status,
  };

  factory ChronicCondition.fromMap(Map<String, dynamic> map) => ChronicCondition(
    name: map['name'] ?? '',
    diagnosedYear: map['diagnosedYear'] ?? '',
    status: map['status'] ?? 'Managed',
  );
}

class EmergencyContact {
  final String name;
  final String relationship;
  final String phone;
  final bool isPrimary;

  const EmergencyContact({
    required this.name,
    required this.relationship,
    required this.phone,
    this.isPrimary = false,
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'relationship': relationship,
    'phone': phone,
    'isPrimary': isPrimary,
  };

  factory EmergencyContact.fromMap(Map<String, dynamic> map) => EmergencyContact(
    name: map['name'] ?? '',
    relationship: map['relationship'] ?? '',
    phone: map['phone'] ?? '',
    isPrimary: map['isPrimary'] ?? false,
  );
}

class InsuranceInfo {
  final String providerName;
  final String policyNumber;
  final String groupNumber;
  final String expiryDate;

  const InsuranceInfo({
    required this.providerName,
    required this.policyNumber,
    required this.groupNumber,
    required this.expiryDate,
  });

  Map<String, dynamic> toMap() => {
    'providerName': providerName,
    'policyNumber': policyNumber,
    'groupNumber': groupNumber,
    'expiryDate': expiryDate,
  };

  factory InsuranceInfo.fromMap(Map<String, dynamic> map) => InsuranceInfo(
    providerName: map['providerName'] ?? '',
    policyNumber: map['policyNumber'] ?? '',
    groupNumber: map['groupNumber'] ?? '',
    expiryDate: map['expiryDate'] ?? '',
  );
}
