class DoctorAccessGrant {
  final String id;
  final String doctorName;
  final String specialty;
  final String hospital;
  final String accessCode;
  final String durationLabel;
  final String grantedAt;
  final String expiresAt;
  final String status; // "Active", "Expired", "Revoked"
  final List<String> permissions;
  final List<AccessAuditLog> logs;

  const DoctorAccessGrant({
    required this.id,
    required this.doctorName,
    required this.specialty,
    required this.hospital,
    required this.accessCode,
    required this.durationLabel,
    required this.grantedAt,
    required this.expiresAt,
    required this.status,
    required this.permissions,
    this.logs = const [],
  });

  bool get isActive => status == 'Active';

  Map<String, dynamic> toMap() => {
    'id': id,
    'doctorName': doctorName,
    'specialty': specialty,
    'hospital': hospital,
    'accessCode': accessCode,
    'durationLabel': durationLabel,
    'grantedAt': grantedAt,
    'expiresAt': expiresAt,
    'status': status,
    'permissions': permissions,
    'logs': logs.map((x) => x.toMap()).toList(),
  };

  factory DoctorAccessGrant.fromMap(Map<String, dynamic> map) => DoctorAccessGrant(
    id: map['id'] ?? '',
    doctorName: map['doctorName'] ?? '',
    specialty: map['specialty'] ?? '',
    hospital: map['hospital'] ?? '',
    accessCode: map['accessCode'] ?? '',
    durationLabel: map['durationLabel'] ?? '',
    grantedAt: map['grantedAt'] ?? '',
    expiresAt: map['expiresAt'] ?? '',
    status: map['status'] ?? 'Active',
    permissions: List<String>.from(map['permissions'] ?? []),
    logs: List<AccessAuditLog>.from(
      (map['logs'] ?? []).map((x) => AccessAuditLog.fromMap(x)),
    ),
  );
}

class AccessAuditLog {
  final String timestamp;
  final String action;
  final String accessor;
  final String resource;

  const AccessAuditLog({
    required this.timestamp,
    required this.action,
    required this.accessor,
    required this.resource,
  });

  Map<String, dynamic> toMap() => {
    'timestamp': timestamp,
    'action': action,
    'accessor': accessor,
    'resource': resource,
  };

  factory AccessAuditLog.fromMap(Map<String, dynamic> map) => AccessAuditLog(
    timestamp: map['timestamp'] ?? '',
    action: map['action'] ?? '',
    accessor: map['accessor'] ?? '',
    resource: map['resource'] ?? '',
  );
}
