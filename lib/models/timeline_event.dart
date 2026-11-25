class TimelineEvent {
  final String id;
  final String title;
  final String date;
  final int year;
  final String category;
  final String doctorName;
  final String facility;
  final String diagnosis;
  final String treatment;
  final int attachmentsCount;
  final String iconType;

  const TimelineEvent({
    required this.id,
    required this.title,
    required this.date,
    required this.year,
    required this.category,
    required this.doctorName,
    required this.facility,
    required this.diagnosis,
    required this.treatment,
    this.attachmentsCount = 0,
    required this.iconType,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'date': date,
    'year': year,
    'category': category,
    'doctorName': doctorName,
    'facility': facility,
    'diagnosis': diagnosis,
    'treatment': treatment,
    'attachmentsCount': attachmentsCount,
    'iconType': iconType,
  };

  factory TimelineEvent.fromMap(Map<String, dynamic> map) => TimelineEvent(
    id: (map['id'] ?? '').toString(),
    title: (map['title'] ?? '').toString(),
    date: (map['date'] ?? '').toString(),
    year: int.tryParse((map['year'] ?? '').toString()) ?? 2026,
    category: (map['category'] ?? 'Consultation').toString(),
    doctorName: (map['doctorName'] ?? '').toString(),
    facility: (map['facility'] ?? '').toString(),
    diagnosis: (map['diagnosis'] ?? '').toString(),
    treatment: (map['treatment'] ?? '').toString(),
    attachmentsCount:
    int.tryParse((map['attachmentsCount'] ?? '').toString()) ?? 0,
    iconType: (map['iconType'] ?? 'stethoscope').toString(),
  );
}