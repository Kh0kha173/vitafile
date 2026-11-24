import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../core/constants/app_colors.dart';
import '../services/auth_service.dart';
import '../main.dart';
import '../widgets/vita_app_bar.dart';
import '../widgets/vita_card.dart';
import '../widgets/vita_badge.dart';
import '../widgets/vita_button.dart';

class EmergencyQrScreen extends StatefulWidget {
  final bool isEmbedded;

  const EmergencyQrScreen({super.key, this.isEmbedded = false});

  @override
  State<EmergencyQrScreen> createState() => _EmergencyQrScreenState();
}

class _EmergencyQrScreenState extends State<EmergencyQrScreen> {
  bool _showInsurance = true;
  bool _showPrescriptions = true;

  String _allergy = '';
  String _condition = '';
  bool _isOrganDonor = false;
  String _iceName = '';
  String _icePhone = '';

  bool get _isAr =>
      appLocaleNotifier.value.languageCode == 'ar';

  String _tr(String en, String ar) => _isAr ? ar : en;

  bool _isBloodNotSet(String raw) {
    final v = raw.trim().toLowerCase();
    return v.isEmpty || v == '--' || v == 'not set';
  }

  String _bloodLabel(String raw) {
    if (_isBloodNotSet(raw)) {
      return _tr('Not Set', 'غير محددة');
    }
    return raw.trim();
  }

  void _editEmergencyDetailsDialog() {
    final auth = VitaAuthService.instance;

    final bloodCtrl = TextEditingController(
      text: _isBloodNotSet(auth.currentUserBloodType)
          ? ''
          : auth.currentUserBloodType,
    );

    final allergyCtrl = TextEditingController(text: _allergy);
    final condCtrl = TextEditingController(text: _condition);
    final iceNameCtrl = TextEditingController(text: _iceName);
    final icePhoneCtrl = TextEditingController(text: _icePhone);

    bool tempDonor = _isOrganDonor;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            _tr('Edit Emergency Pass', 'تعديل بطاقة الطوارئ'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: bloodCtrl,
                  decoration: InputDecoration(
                    labelText: _tr(
                      'Blood Group (e.g. O+, A-)',
                      'فصيلة الدم (مثال: O+, A-)',
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: allergyCtrl,
                  decoration: InputDecoration(
                    labelText: _tr(
                      'Severe Allergy (if any)',
                      'الحساسية الحرجة (إن وجدت)',
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: condCtrl,
                  decoration: InputDecoration(
                    labelText: _tr(
                      'Chronic Condition (if any)',
                      'الأمراض المزمنة (إن وجدت)',
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: iceNameCtrl,
                  decoration: InputDecoration(
                    labelText: _tr(
                      'Emergency Contact Name',
                      'اسم جهة اتصال الطوارئ',
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: icePhoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: _tr(
                      'Emergency Contact Phone',
                      'رقم هاتف الطوارئ',
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    _tr('Organ Donor', 'متبرع بالأعضاء'),
                    style: const TextStyle(fontSize: 13),
                  ),
                  value: tempDonor,
                  activeColor: AppColors.primaryTeal,
                  onChanged: (v) => setDialogState(() => tempDonor = v),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(_tr('Cancel', 'إلغاء')),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryTeal,
              ),
              onPressed: () {
                setState(() {
                  if (bloodCtrl.text.trim().isNotEmpty) {
                    auth.currentUserBloodType =
                        bloodCtrl.text.trim().toUpperCase();
                  }

                  _allergy = allergyCtrl.text.trim();
                  _condition = condCtrl.text.trim();
                  _iceName = iceNameCtrl.text.trim();
                  _icePhone = icePhoneCtrl.text.trim();
                  _isOrganDonor = tempDonor;
                });

                Navigator.pop(ctx);
              },
              child: Text(
                _tr('Save', 'حفظ'),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: appLocaleNotifier,
      builder: (context, locale, _) => _buildScaffold(),
    );
  }

  Widget _buildScaffold() {
    final auth = VitaAuthService.instance;

    final fullName = auth.currentUserName.isNotEmpty
        ? auth.currentUserName
        : _tr('New Patient', 'مريض جديد');

    final patientId = auth.currentUserId ?? 'VF-NEW';
    final bloodType = _bloodLabel(auth.currentUserBloodType);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: VitaAppBar(
        title: _tr('Emergency QR Pass', 'بطاقة الطوارئ QR'),
        subtitle: _tr(
          'First Responder Triage Protocol',
          'بروتوكول الإسعاف والطوارئ السريع',
        ),
        showBackButton: !widget.isEmbedded,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.edit_outlined,
              color: AppColors.emergencyRed,
              size: 22,
            ),
            onPressed: _editEmergencyDetailsDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppColors.emergencyGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.emergencyRed.withOpacity(0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.emergency_rounded,
                      color: AppColors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _tr(
                            'PARAMEDIC / ER PROTOCOL',
                            'بروتوكول المسعفين وغرف الطوارئ',
                          ),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.white,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _tr(
                            'Scan QR code below for instant offline medical profile & allergy warnings.',
                            'امسح رمز QR بالأسفل للوصول الفوري للملف الطبي وتحذيرات الحساسية.',
                          ),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFFFEE2E2),
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            VitaCard(
              padding: const EdgeInsets.all(22),
              hasShadow: true,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: AppColors.successGreen,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                _tr(
                                  'CRYPTOGRAPHIC VERIFIED PASS',
                                  'بطاقة موثقة ومشفرة',
                                ),
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textSecondary,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      VitaBadge(
                        label: '${_tr("BLOOD", "فصيلة الدم")}: $bloodType',
                        type: BadgeType.emergency,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _buildCustomQrGraphic(),
                  const SizedBox(height: 16),
                  Text(
                    fullName.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_tr("Vault ID", "رقم الخزنة")}: $patientId',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.lock_rounded,
                          size: 14,
                          color: AppColors.primaryTeal,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'https://vitafile.health/emergency/$patientId',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              fontFamily: 'monospace',
                              color: AppColors.primaryTeal,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildCriticalInfoGrid(bloodType),
            const SizedBox(height: 18),
            _buildIceContactSection(),
            const SizedBox(height: 18),
            VitaCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _tr(
                      'Emergency Public Display Controls',
                      'إعدادات العرض العام في الطوارئ',
                    ),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _tr(
                      'Select what information is visible upon scanning without unlocking the app.',
                      'اختر البيانات التي تظهر عند مسح الكود دون الحاجة لفتح قفل التطبيق.',
                    ),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile.adaptive(
                    value: _showInsurance,
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      _tr(
                        'Show Insurance Policy Details',
                        'إظهار بيانات التأمين الصحي',
                      ),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    activeColor: AppColors.primaryTeal,
                    onChanged: (v) => setState(() => _showInsurance = v),
                  ),
                  SwitchListTile.adaptive(
                    value: _showPrescriptions,
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      _tr(
                        'Show Active Prescriptions',
                        'إظهار الأدوية الحالية',
                      ),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    activeColor: AppColors.primaryTeal,
                    onChanged: (v) => setState(() => _showPrescriptions = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            VitaButton(
              label: _tr(
                'Edit Emergency Information',
                'تعديل بيانات الطوارئ',
              ),
              icon: Icons.edit_note_rounded,
              onPressed: _editEmergencyDetailsDialog,
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomQrGraphic() {
    final patientId = VitaAuthService.instance.currentUserId ?? 'VF-NEW';

    return Container(
      width: 200,
      height: 200,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder, width: 2),
      ),
      child: QrImageView(
        data: 'VitaFile Emergency Patient ID: $patientId',
        version: QrVersions.auto,
        size: 176,
        backgroundColor: Colors.white,
      ),
    );
  }

  Widget _buildCriticalInfoGrid(String bloodType) {
    return GestureDetector(
      onTap: _editEmergencyDetailsDialog,
      child: VitaCard(
        padding: const EdgeInsets.all(16),
        borderColor: AppColors.emergencyRed.withOpacity(0.3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: AppColors.emergencyRed,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          _tr(
                            'CRITICAL LIFE-SAVING DATA',
                            'بيانات الطوارئ الحرجة',
                          ),
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.emergencyRed,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _tr('Edit', 'تعديل'),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryTeal,
                  ),
                ),
              ],
            ),
            const Divider(height: 18, color: AppColors.cardBorderSubtle),
            _buildCriticalRow(
              _tr('Blood Group', 'فصيلة الدم'),
              bloodType,
              isAlert: false,
            ),
            const SizedBox(height: 8),
            _buildCriticalRow(
              _tr('Severe Allergy', 'حساسية حرجة'),
              _allergy.isEmpty
                  ? _tr('None recorded', 'لا يوجد')
                  : _allergy,
              isAlert: _allergy.isNotEmpty,
            ),
            const SizedBox(height: 8),
            _buildCriticalRow(
              _tr('Chronic Condition', 'حالة مزمنة'),
              _condition.isEmpty
                  ? _tr('None recorded', 'لا يوجد')
                  : _condition,
              isAlert: false,
            ),
            const SizedBox(height: 8),
            _buildCriticalRow(
              _tr('Organ Donor', 'تبرع بالأعضاء'),
              _isOrganDonor
                  ? _tr('YES', 'نعم')
                  : _tr('NO', 'لا'),
              isAlert: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCriticalRow(
      String label,
      String value, {
        bool isAlert = false,
      }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 3,
            ),
            decoration: BoxDecoration(
              color: isAlert
                  ? AppColors.emergencyRedSoft
                  : AppColors.background,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isAlert
                    ? AppColors.emergencyRed
                    : AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIceContactSection() {
    return VitaCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _tr('Emergency Contacts (ICE)', 'جهة اتصال الطوارئ'),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              InkWell(
                onTap: _editEmergencyDetailsDialog,
                child: Text(
                  _iceName.isEmpty
                      ? _tr('+ Add', '+ إضافة')
                      : _tr('Edit', 'تعديل'),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryTeal,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_iceName.isEmpty)
            Text(
              _tr(
                'No emergency contact added yet. Tap + Add above.',
                'لم يتم إضافة جهة اتصال طوارئ بعد. اضغط + إضافة بالأعلى.',
              ),
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            )
          else
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryTealSoft,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.phone_in_talk_rounded,
                    color: AppColors.primaryTeal,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _iceName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        _icePhone,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${_tr("Calling", "جاري الاتصال بـ")} $_iceName ($_icePhone)...',
                        ),
                        backgroundColor: AppColors.emergencyRed,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.emergencyRed,
                    foregroundColor: AppColors.white,
                    minimumSize: const Size(80, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.call, size: 14),
                  label: Text(
                    _tr('Call', 'اتصال'),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}