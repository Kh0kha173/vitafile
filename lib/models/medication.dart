class Medication {
  final String id;
  final String name;
  final String dosage; // e.g. "500 mg"
  final String type; // Tablet, Capsule, Inhaler, Injection
  final String frequency; // "Once daily", "Twice daily", "As needed"
  final List<String> scheduledTimes; // ["08:00 AM", "08:00 PM"]
  final String instructions; // "Take with meals"
  final String prescribedBy;
  final int pillsRemaining;
  final int totalPills;
  final bool isTakenToday;

  const Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.type,
    required this.frequency,
    required this.scheduledTimes,
    required this.instructions,
    required this.prescribedBy,
    required this.pillsRemaining,
    required this.totalPills,
    this.isTakenToday = false,
  });

  Medication copyWith({
    bool? isTakenToday,
    int? pillsRemaining,
  }) {
    return Medication(
      id: id,
      name: name,
      dosage: dosage,
      type: type,
      frequency: frequency,
      scheduledTimes: scheduledTimes,
      instructions: instructions,
      prescribedBy: prescribedBy,
      pillsRemaining: pillsRemaining ?? this.pillsRemaining,
      totalPills: totalPills,
      isTakenToday: isTakenToday ?? this.isTakenToday,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'type': type,
      'frequency': frequency,
      'scheduledTimes': scheduledTimes,
      'instructions': instructions,
      'prescribedBy': prescribedBy,
      'pillsRemaining': pillsRemaining,
      'totalPills': totalPills,
      'isTakenToday': isTakenToday,
    };
  }

  factory Medication.fromMap(Map<String, dynamic> map) {
    return Medication(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      dosage: map['dosage'] ?? '',
      type: map['type'] ?? 'Tablet',
      frequency: map['frequency'] ?? 'Once daily',
      scheduledTimes: List<String>.from(map['scheduledTimes'] ?? []),
      instructions: map['instructions'] ?? '',
      prescribedBy: map['prescribedBy'] ?? '',
      pillsRemaining: map['pillsRemaining']?.toInt() ?? 0,
      totalPills: map['totalPills']?.toInt() ?? 30,
      isTakenToday: map['isTakenToday'] ?? false,
    );
  }
}
