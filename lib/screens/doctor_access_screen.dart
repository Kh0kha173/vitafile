import 'dart:math';
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/doctor_access.dart';
import '../services/auth_service.dart';
import '../main.dart';
import '../widgets/vita_app_bar.dart';
import '../widgets/vita_card.dart';
import '../widgets/vita_badge.dart';
import '../widgets/vita_button.dart';
import '../widgets/vita_text_field.dart';

class DoctorAccessScreen extends StatefulWidget {
  const DoctorAccessScreen({super.key});

  @override
  State<DoctorAccessScreen> createState() => _DoctorAccessScreenState();
}

class _DoctorAccessScreenState extends State<DoctorAccessScreen> {
final List _grants = [];
final List _auditLogs = [];

bool get _isAr => appLocaleNotifier.value.languageCode == 'ar';
String _tr(String en, String ar) => _isAr ? ar : en;

String get _patientName {
final name = VitaAuthService.instance.currentUserName;
return name.isNotEmpty ? name : _tr('Patient', 'المريض');
}

String _generatePin() {
final r = Random();
final p1 = 100 + r.nextInt(900);
final p2 = 100 + r.nextInt(900);
return '$p1-$p2';
}

void _revokeAccess(DoctorAccessGrant target) {
final idx = _grants.indexWhere((g) => (g as DoctorAccessGrant).id == target.id);
if (idx == -1) return;

setState(() {
_grants[idx] = DoctorAccessGrant(
id: target.id,
doctorName: target.doctorName,
specialty: target.specialty,
hospital: target.hospital,
accessCode: target.accessCode,
durationLabel: target.durationLabel,
grantedAt: target.grantedAt,
expiresAt: _tr('Revoked by Patient', 'تم الإلغاء بواسطة المريض'),
status: 'Revoked',
permissions: target.permissions,
logs: target.logs,
);
_auditLogs.insert(
0,
AccessAuditLog(
timestamp: _tr('Just now', 'الآن'),
action: _tr('revoked access for', 'ألغى صلاحية'),
accessor: _patientName,
resource: target.doctorName,
),
);
});

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(_tr(
'Doctor access revoked and PIN invalidated.',
'تم إلغاء صلاحية الطبيب وإبطال الكود بنجاح.',
)),
backgroundColor: AppColors.emergencyRed,
),
);
}
void _showGrantAccessSheet() {
final docNameCtrl = TextEditingController();
final hospitalCtrl = TextEditingController();
int durationIndex = 1;
bool permLabs = true;
bool permImaging = true;
bool permPrescriptions = true;
bool permNotes = false;

showModalBottomSheet(
context: context,
isScrollControlled: true,
backgroundColor: Colors.transparent,
builder: (context) => StatefulBuilder(
builder: (context, setSheetState) {
final durations = [
_tr('1 Hour', 'ساعة واحدة'),
_tr('24 Hours', '24 ساعة'),
_tr('7 Days', '7 أيام'),
];

return Container(
padding: EdgeInsets.only(
bottom: MediaQuery.of(context).viewInsets.bottom + 24,
top: 24,
left: 24,
right: 24,
),
decoration: const BoxDecoration(
color: AppColors.white,
borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
),
child: SingleChildScrollView(
child: Column(
mainAxisSize: MainAxisSize.min,
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Center(
child: Container(
width: 44,
height: 5,
decoration: BoxDecoration(
color: AppColors.cardBorder,
borderRadius: BorderRadius.circular(10),
),
),
),
const SizedBox(height: 18),
Text(
_tr('Grant Temporary Doctor Access', 'منح صلاحية مؤقتة للطبيب'),
style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
),
const SizedBox(height: 4),
Text(
_tr(
'Generate an expiring PIN code for a physician to view selected records.',
'أنشئ كود دخول مؤقت للطبيب للاطلاع على السجلات التي تحددها فقط.',
),
style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
),
const SizedBox(height: 18),
VitaTextField(
label: _tr('Physician / Specialist Name', 'اسم الطبيب المعالج'),
hint: _tr('e.g. Dr. Mohamed Ali', 'مثال: د. محمد علي'),
controller: docNameCtrl,
prefixIcon: Icons.person_rounded,
),
const SizedBox(height: 14),
VitaTextField(
label: _tr('Hospital / Clinic', 'المستشفى أو العيادة'),
hint: _tr('e.g. City Medical Center', 'مثال: المركز الطبي التخصصي'),
controller: hospitalCtrl,
prefixIcon: Icons.local_hospital_rounded,
),
const SizedBox(height: 16),
Text(
_tr('Access Duration', 'مدة الصلاحية'),
style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
),
const SizedBox(height: 8),
Row(
children: List.generate(durations.length, (i) {
final isSel = durationIndex == i;
return Padding(
padding: const EdgeInsets.only(right: 8),
child: ChoiceChip(
label: Text(durations[i]),
selected: isSel,
selectedColor: AppColors.primaryTealSoft,
labelStyle: TextStyle(
color: isSel ? AppColors.primaryTeal : AppColors.textSecondary,
fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
),
onSelected: (_) => setSheetState(() => durationIndex = i),
),
);
}),
),
const SizedBox(height: 16),
Text(
_tr('Granular Data Permissions', 'السجلات المسموح بعرضها'),
style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
),
CheckboxListTile(
title: Text(_tr('Lab Test Results & Panels', 'نتائج التحاليل المعملية'), style: const TextStyle(fontSize: 13)),
value: permLabs,
dense: true,
activeColor: AppColors.primaryTeal,
contentPadding: EdgeInsets.zero,
onChanged: (v) => setSheetState(() => permLabs = v ?? true),
),
CheckboxListTile(
title: Text(_tr('Diagnostic Imaging & X-Rays', 'الأشعة والفحوصات'), style: const TextStyle(fontSize: 13)),
value: permImaging,
dense: true,
activeColor: AppColors.primaryTeal,
contentPadding: EdgeInsets.zero,
onChanged: (v) => setSheetState(() => permImaging = v ?? true),
),
CheckboxListTile(
title: Text(_tr('Active Prescriptions & Dosages', 'الأدوية والروشتات الحالية'), style: const TextStyle(fontSize: 13)),
value: permPrescriptions,
dense: true,
activeColor: AppColors.primaryTeal,
contentPadding: EdgeInsets.zero,
onChanged: (v) => setSheetState(() => permPrescriptions = v ?? true),
),
CheckboxListTile(
title: Text(_tr('Clinical Consultation Notes', 'ملاحظات الكشوفات السابقة'), style: const TextStyle(fontSize: 13)),
value: permNotes,
dense: true,
activeColor: AppColors.primaryTeal,
contentPadding: EdgeInsets.zero,
onChanged: (v) => setSheetState(() => permNotes = v ?? false),
),
const SizedBox(height: 20),
VitaButton(
label: _tr('Generate Expiring Access PIN', 'إنشاء كود الدخول المؤقت'),
icon: Icons.key_rounded,
onPressed: () {
final docName = docNameCtrl.text.trim().isEmpty
? _tr('Attending Physician', 'الطبيب المعالج')
: docNameCtrl.text.trim();
final hospital = hospitalCtrl.text.trim().isEmpty
? _tr('Private Clinic', 'عيادة خاصة')
: hospitalCtrl.text.trim();
final durLabel = durations[durationIndex];
final pin = _generatePin();

final List<String> perms = [];
if (permLabs) perms.add(_tr('Lab Tests', 'تحاليل'));
if (permImaging) perms.add(_tr('Imaging', 'أشعة'));
if (permPrescriptions) perms.add(_tr('Prescriptions', 'روشتات'));
if (permNotes) perms.add(_tr('Notes', 'ملاحظات'));

setState(() {
_grants.insert(
0,
DoctorAccessGrant(
id: 'ACC-${DateTime.now().millisecondsSinceEpoch}',
doctorName: docName,
specialty: _tr('Physician', 'طبيب'),
hospital: hospital,
accessCode: pin,
durationLabel: durLabel,
grantedAt: _tr('Just now', 'الآن'),
expiresAt: durLabel,
status: 'Active',
permissions: perms,
logs: [],
),
);
_auditLogs.insert(
0,
AccessAuditLog(
timestamp: _tr('Just now', 'الآن'),
action: _tr('created PIN #$pin for', 'أنشأ كود #$pin لـ'),
accessor: _patientName,
resource: docName,
),
);
});

Navigator.pop(context);
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(_tr(
'Doctor access PIN #$pin generated successfully.',
'تم إنشاء كود دخول الطبيب #$pin بنجاح.',
)),
backgroundColor: AppColors.primaryTeal,
),
);
},
),
],
),
),
);
},
),
);
}
@override
Widget build(BuildContext context) {
  final activeGrants = _grants.where((g) => (g as DoctorAccessGrant).isActive).toList();
  final pastGrants = _grants.where((g) => !(g as DoctorAccessGrant).isActive).toList();

  return Scaffold(
    backgroundColor: AppColors.background,
    appBar: VitaAppBar(
      title: _tr('Doctor Access Hub', 'صلاحيات دخول الأطباء'),
      subtitle: _tr('Zero-Knowledge Granular Permissions', 'تحكم كامل في مشاركة ملفك الطبي'),
      actions: [
        IconButton(
          icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primaryTeal, size: 24),
          onPressed: _showGrantAccessSheet,
        ),
      ],
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.medicalBlueSoft,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.medicalBlue.withOpacity(0.25)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.medicalBlue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.security_rounded, color: AppColors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _tr('Encrypted Time-Limited Access', 'صلاحية مشفرة ومحددة بوقت'),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.medicalBlueDark),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _tr(
                          'Doctors only receive access to the records you authorize. Access automatically expires when time ends.',
                          'يطلع الطبيب فقط على السجلات التي تحددها، وتنتهي الصلاحية تلقائياً بانتهاء الوقت.',
                        ),
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_tr("Active Doctor Sessions", "الجلسات النشطة")} (${activeGrants.length})',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              TextButton(
                onPressed: _showGrantAccessSheet,
                child: Text(
                  _tr('+ Grant New', '+ منح صلاحية'),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primaryTeal),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (activeGrants.isEmpty)
            GestureDetector(
              onTap: _showGrantAccessSheet,
              child: VitaCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: AppColors.medicalBlueSoft, borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.key_off_rounded, color: AppColors.medicalBlue),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _tr(
                          'No active doctor sessions. Tap + Grant New to share a temporary PIN with your doctor.',
                          'لا توجد جلسات نشطة حالياً. اضغط + منح صلاحية لإنشاء كود مؤقت لطبيبك.',
                        ),
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...List.generate(activeGrants.length, (index) {
              return _buildGrantCard(activeGrants[index] as DoctorAccessGrant, isActive: true);
            }),
          const SizedBox(height: 20),
          if (pastGrants.isNotEmpty) ...[
            Text(
              _tr('Expired / Revoked Sessions', 'الجلسات المنتهية أو الملغاة'),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            ...List.generate(pastGrants.length, (index) {
              return _buildGrantCard(pastGrants[index] as DoctorAccessGrant, isActive: false);
            }),
            const SizedBox(height: 20),
          ],
          _buildAuditLogSection(),
          const SizedBox(height: 28),
        ],
      ),
    ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: _showGrantAccessSheet,
      backgroundColor: AppColors.primaryTeal,
      foregroundColor: AppColors.white,
      icon: const Icon(Icons.key_rounded),
      label: Text(_tr('Grant Doctor Access', 'منح صلاحية لطبيب'), style: const TextStyle(fontWeight: FontWeight.w700)),
    ),
  );
}

Widget _buildGrantCard(DoctorAccessGrant grant, {required bool isActive}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: VitaCard(
      padding: const EdgeInsets.all(16),
      borderColor: isActive ? AppColors.medicalBlue.withOpacity(0.3) : AppColors.cardBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.medicalBlueSoft : AppColors.cardBorderSubtle,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.medical_services_rounded, size: 18, color: isActive ? AppColors.medicalBlue : AppColors.textMuted),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(grant.doctorName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                      Text(grant.hospital, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    ],
                  ),
                ],
              ),
              VitaBadge(label: isActive ? _tr('Active', 'نشط') : _tr('Revoked', 'ملغى'), type: isActive ? BadgeType.medical : BadgeType.neutral),
            ],
          ),
          const Divider(height: 18, color: AppColors.cardBorderSubtle),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_tr('Access PIN Code', 'كود الدخول'), style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                  const SizedBox(height: 2),
                  Text(grant.accessCode, style: const TextStyle(fontSize: 16, fontFamily: 'monospace', fontWeight: FontWeight.w800, color: AppColors.primaryTeal)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_tr('Validity', 'المدة'), style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                  const SizedBox(height: 2),
                  Text(grant.durationLabel, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_tr('Status', 'الحالة'), style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                  const SizedBox(height: 2),
                  Text(grant.expiresAt, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: grant.permissions.map((p) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.cardBorderSubtle)),
                child: Text(p, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              );
            }).toList(),
          ),
          if (isActive) ...[
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: () => _revokeAccess(grant),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.emergencyRed,
                side: const BorderSide(color: AppColors.emergencyRed, width: 1.2),
                minimumSize: const Size.fromHeight(40),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.block_rounded, size: 16),
              label: Text(_tr('Revoke Doctor Access Now', 'إلغاء صلاحية الطبيب فوراً'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            ),
          ],
        ],
      ),
    ),
  );
}

Widget _buildAuditLogSection() {
  return VitaCard(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.history_rounded, size: 18, color: AppColors.primaryTeal),
            const SizedBox(width: 8),
            Text(_tr('Recent Access Audit Log', 'سجل نشاط الصلاحيات'), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          ],
        ),
        const SizedBox(height: 12),
        if (_auditLogs.isEmpty)
          Text(_tr('No access logs recorded yet.', 'لا توجد عمليات مسجلة في السجل بعد.'), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))
        else
          ..._auditLogs.take(5).map((item) {
            final AccessAuditLog log = item;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.primaryTeal, shape: BoxShape.circle)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${log.accessor} ${log.action} ${log.resource}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        Text(log.timestamp, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
      ],
    ),
  );
}
}
