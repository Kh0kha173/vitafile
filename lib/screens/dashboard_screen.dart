import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/navigation/app_router.dart';
import '../services/auth_service.dart';
import '../main.dart';
import '../widgets/vita_card.dart';

class DashboardScreen extends StatefulWidget {
  final void Function(int index)? onNavigateTab;

  const DashboardScreen({super.key, this.onNavigateTab});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
String _bloodType = '--';
String _allergy = '';

bool get _isAr => appLocaleNotifier.value.languageCode == 'ar';
String _tr(String en, String ar) => _isAr ? ar : en;

String _getInitials(String name) {
final parts = name.trim().split(RegExp(r'\s+'));
if (parts.isEmpty || parts.first.isEmpty) return 'U';
if (parts.length == 1) return parts.first[0].toUpperCase();
return (parts[0][0] + parts[1][0]).toUpperCase();
}

void _editEmergencyDialog() {
final bloodController = TextEditingController(text: _bloodType == '--' ? '' : _bloodType);
final allergyController = TextEditingController(text: _allergy);
showDialog(
context: context,
builder: (ctx) => AlertDialog(
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
title: Text(
_tr('Emergency Info', 'بيانات الطوارئ'),
style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
),
content: Column(
mainAxisSize: MainAxisSize.min,
children: [
TextField(
controller: bloodController,
decoration: InputDecoration(
labelText: _tr('Blood Type (e.g. A+, O-)', 'فصيلة الدم (مثال: A+, O-)'),
border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
),
),
const SizedBox(height: 12),
TextField(
controller: allergyController,
decoration: InputDecoration(
labelText: _tr('Critical Allergies (if any)', 'الحساسية الحرجة (إن وجدت)'),
border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
),
),
],
),
actions: [
TextButton(
onPressed: () => Navigator.pop(ctx),
child: Text(_tr('Cancel', 'إلغاء')),
),
ElevatedButton(
style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryTeal),
onPressed: () {
setState(() {
if (bloodController.text.trim().isNotEmpty) {
_bloodType = bloodController.text.trim().toUpperCase();
VitaAuthService.instance.currentUserBloodType = _bloodType;
}
_allergy = allergyController.text.trim();
});
Navigator.pop(ctx);
},
child: Text(_tr('Save', 'حفظ'), style: const TextStyle(color: Colors.white)),
),
],
),
);
}

@override
Widget build(BuildContext context) {
final auth = VitaAuthService.instance;
final displayName = auth.currentUserName.isNotEmpty
? auth.currentUserName
: _tr('New Patient', 'مريض جديد');
final initials = _getInitials(displayName);

return Scaffold(
backgroundColor: AppColors.background,
body: SafeArea(
child: SingleChildScrollView(
padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
_buildHeader(context, displayName, initials),
const SizedBox(height: 18),
_buildEmergencyCard(),
const SizedBox(height: 22),
_buildSectionHeader(
_tr('Quick Vault Actions', 'إجراءات سريعة'),
_tr('Manage your health records', 'إدارة ملفاتك وسجلاتك الطبية'),
),
const SizedBox(height: 12),
_buildQuickActions(context),
const SizedBox(height: 22),
_buildSectionHeader(
_tr("Today's Medications", 'أدوية اليوم'),
_tr('No medications scheduled yet', 'لا توجد أدوية مسجلة بعد'),
),
const SizedBox(height: 12),
_buildEmptyStateCard(
icon: Icons.medication_outlined,
message: _tr(
'No medications added yet. Tap Medications to add your prescriptions.',
'لم يتم إضافة أدوية بعد. اضغط على الأدوية لإضافة جرعاتك.',
),
),
const SizedBox(height: 22),
Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
_buildSectionHeader(
_tr('Recent Records', 'أحدث السجلات الطبية'),
_tr('Latest medical documents', 'آخر التحاليل والأشعات'),
),
TextButton(
onPressed: () {
if (widget.onNavigateTab != null) {
widget.onNavigateTab!(1);
} else {
Navigator.of(context).pushNamed(AppRoutes.records);
}
},
child: Text(
_tr('View All', 'عرض الكل'),
style: const TextStyle(
fontSize: 13,
fontWeight: FontWeight.w700,
color: AppColors.primaryTeal,
),
),
),
],
),
const SizedBox(height: 8),
_buildEmptyStateCard(
icon: Icons.folder_open_rounded,
message: _tr(
'Your medical vault is empty. Upload your first lab test or prescription.',
'خزنتك الطبية فارغة حالياً. ارفع أول تحليل أو روشتة طبية.',
),
),
const SizedBox(height: 24),
],
),
),
),
);
}
Widget _buildEmptyStateCard({required IconData icon, required String message}) {
  return VitaCard(
    padding: const EdgeInsets.all(16),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primaryTealSoft,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primaryTeal, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildHeader(BuildContext context, String displayName, String initials) {
  return Row(
    children: [
      GestureDetector(
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.profile),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: AppColors.tealGradient,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.white, width: 2),
          ),
          child: Center(
            child: Text(
              initials,
              style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Flexible(
                  child: Text(
                    displayName,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.verified_rounded, size: 16, color: AppColors.primaryTeal),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              _tr('Vault Encrypted • Synced', 'خزنة مشفرة • متزامنة'),
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      InkWell(
        onTap: () {
          appLocaleNotifier.value = _isAr ? const Locale('en') : const Locale('ar');
          setState(() {});
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primaryTealSoft,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primaryTeal.withOpacity(0.3)),
          ),
          child: Text(
            _isAr ? 'EN' : 'عربي',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryTealDark,
            ),
          ),
        ),
      ),
      const SizedBox(width: 8),
      InkWell(
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.emergency),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.emergencyRedSoft,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.emergencyRed.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.sos_rounded, color: AppColors.emergencyRed, size: 18),
              const SizedBox(width: 4),
              Text(
                _tr('SOS', 'طوارئ'),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.emergencyRed,
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

Widget _buildEmergencyCard() {
  return VitaCard(
    onTap: _editEmergencyDialog,
    padding: const EdgeInsets.all(16),
    gradient: const LinearGradient(
      colors: [Color(0xFF005B60), Color(0xFF007A78)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.emergency_rounded, color: AppColors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  _tr('EMERGENCY MEDICAL PASS', 'بطاقة الطوارئ الطبية'),
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.emergencyRed,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_tr("BLOOD", "فصيلة")}: $_bloodType',
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _allergy.isEmpty
                        ? _tr('Tap to add blood type & allergies', 'اضغط لإضافة فصيلة الدم والحساسية')
                        : '${_tr("Allergy Alert:", "تنبيه حساسية:")} $_allergy',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _tr(
                      'Paramedics can scan QR code for instant triage protocol.',
                      'يمكن للمسعفين مسح رمز QR للوصول الفوري لبيانات الطوارئ.',
                    ),
                    style: const TextStyle(
                      color: Color(0xFFE0F2FE),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.qr_code_rounded, color: AppColors.primaryTeal, size: 32),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _buildSectionHeader(String title, String subtitle) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      const SizedBox(height: 2),
      Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
      ),
    ],
  );
}

Widget _buildQuickActions(BuildContext context) {
  return GridView.count(
    crossAxisCount: 3,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    mainAxisSpacing: 10,
    crossAxisSpacing: 10,
    childAspectRatio: 1.15,
    children: [
      _buildActionTile(
        icon: Icons.cloud_upload_rounded,
        label: _tr('Upload File', 'رفع ملف'),
        color: AppColors.primaryTeal,
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.upload),
      ),
      _buildActionTile(
        icon: Icons.key_rounded,
        label: _tr('Doctor Access', 'دخول الطبيب'),
        color: AppColors.medicalBlue,
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.doctorAccess),
      ),
      _buildActionTile(
        icon: Icons.timeline_rounded,
        label: _tr('Timeline', 'السجل الزمني'),
        color: AppColors.infoPurple,
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.timeline),
      ),
      _buildActionTile(
        icon: Icons.badge_outlined,
        label: _tr('Digital ID', 'الهوية الطبية'),
        color: AppColors.primaryTealDark,
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.profile),
      ),
      _buildActionTile(
        icon: Icons.medication_liquid_rounded,
        label: _tr('Medications', 'الأدوية'),
        color: AppColors.warningOrange,
        onTap: () {
          if (widget.onNavigateTab != null) {
            widget.onNavigateTab!(2);
          } else {
            Navigator.of(context).pushNamed(AppRoutes.medications);
          }
        },
      ),
      _buildActionTile(
        icon: Icons.emergency_share_rounded,
        label: _tr('Emergency QR', 'كود الطوارئ'),
        color: AppColors.emergencyRed,
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.emergency),
      ),
    ],
  );
}

Widget _buildActionTile({
  required IconData icon,
  required String label,
  required Color color,
  required VoidCallback onTap,
}) {
  return VitaCard(
    onTap: onTap,
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
    borderRadius: 16,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    ),
  );
}
}