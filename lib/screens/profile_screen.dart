
import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../services/auth_service.dart';
import '../main.dart';
import '../widgets/vita_app_bar.dart';
import '../widgets/vita_card.dart';
import '../widgets/vita_badge.dart';
import '../widgets/vita_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _dob = '--/--/----';
  String _gender = '--';
  String _bloodType = '--';

  bool _isOrganDonor = false;

  double? _heightCm;
  double? _weightKg;

  final List _allergies = [];
  final List _conditions = [];
  final List _contacts = [];

  static const List<String> _validBloodTypes = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  @override
  void initState() {
    super.initState();

    final savedBloodType =
        VitaAuthService.instance.currentUserBloodType;

    _bloodType = _validBloodTypes.contains(savedBloodType)
        ? savedBloodType
        : '--';
  }

  bool get _isAr =>
      appLocaleNotifier.value.languageCode == 'ar';

  String _tr(String en, String ar) => _isAr ? ar : en;

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));

    if (parts.isEmpty || parts.first.isEmpty) {
      return 'U';
    }

    if (parts.length == 1) {
      return parts.first[0].toUpperCase();
    }

    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  double? get _bmi {
    if (_heightCm == null ||
        _weightKg == null ||
        _heightCm! <= 0) {
      return null;
    }

    final hMeters = _heightCm! / 100;
    return _weightKg! / (hMeters * hMeters);
  }

  String _bmiCategory(double bmi) {
    if (bmi < 18.5) {
      return _tr('Underweight', 'نقص وزن');
    }

    if (bmi < 25) {
      return _tr('Normal', 'طبيعي');
    }

    if (bmi < 30) {
      return _tr('Overweight', 'زيادة وزن');
    }

    return _tr('Obese', 'سمنة');
  }

  void _showEditProfileDialog() {
    final dobCtrl = TextEditingController(
      text: _dob == '--/--/----' ? '' : _dob,
    );

    final genderCtrl = TextEditingController(
      text: _gender == '--' ? '' : _gender,
    );

    final heightCtrl = TextEditingController(
      text: _heightCm?.toString() ?? '',
    );

    final weightCtrl = TextEditingController(
      text: _weightKg?.toString() ?? '',
    );

    String? tempBloodType =
    _validBloodTypes.contains(_bloodType)
        ? _bloodType
        : null;

    bool tempDonor = _isOrganDonor;
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            _tr('Edit Medical Profile', 'تعديل الملف الطبي'),
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
                  controller: dobCtrl,
                  decoration: InputDecoration(
                    labelText: _tr(
                      'Date of Birth (e.g. 15/05/2002)',
                      'تاريخ الميلاد',
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: genderCtrl,
                  decoration: InputDecoration(
                    labelText: _tr(
                      'Gender (Female / Male)',
                      'النوع (أنثى / ذكر)',
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Blood type selection
                DropdownButtonFormField<String>(
                  value: tempBloodType,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: _tr(
                      'Blood Type',
                      'فصيلة الدم',
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  hint: Text(
                    _tr(
                      'Select blood type',
                      'اختاري فصيلة الدم',
                    ),
                  ),
                  items: _validBloodTypes.map((type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      tempBloodType = value;
                    });
                  },
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: heightCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: _tr('Height (cm)', 'الطول (سم)'),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: TextField(
                        controller: weightCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: _tr('Weight (kg)', 'الوزن (كجم)'),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    _tr('Organ Donor', 'متبرع بالأعضاء'),
                    style: const TextStyle(fontSize: 13),
                  ),
                  value: tempDonor,
                  activeColor: AppColors.primaryTeal,
                  onChanged: (v) {
                    setDialogState(() {
                      tempDonor = v;
                    });
                  },
                ),
              ],
            ),
          ),

          actions: [
            TextButton(
              onPressed: isSaving
                  ? null
                  : () => Navigator.pop(ctx),
              child: Text(_tr('Cancel', 'إلغاء')),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryTeal,
              ),
              onPressed: isSaving
                  ? null
                  : () async {
                setDialogState(() {
                  isSaving = true;
                });

                try {
                  // Save blood type to Firebase only
                  // when the user selected a valid option.
                  if (tempBloodType != null) {
                    await VitaAuthService.instance
                        .updateBloodType(tempBloodType!);
                  }

                  if (!mounted) return;

                  setState(() {
                    if (dobCtrl.text.trim().isNotEmpty) {
                      _dob = dobCtrl.text.trim();
                    }

                    if (genderCtrl.text.trim().isNotEmpty) {
                      _gender = genderCtrl.text.trim();
                    }

                    if (tempBloodType != null) {
                      _bloodType = tempBloodType!;
                    }

                    _heightCm = double.tryParse(
                      heightCtrl.text.trim(),
                    );

                    _weightKg = double.tryParse(
                      weightCtrl.text.trim(),
                    );

                    _isOrganDonor = tempDonor;
                  });

                  Navigator.pop(ctx);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        _tr(
                          'Medical profile saved successfully.',
                          'تم حفظ الملف الطبي بنجاح.',
                        ),
                      ),
                      backgroundColor: AppColors.primaryTeal,
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;

                  setDialogState(() {
                    isSaving = false;
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        _tr(
                          'Failed to save blood type. Please try again.',
                          'فشل حفظ فصيلة الدم. حاولي مرة أخرى.',
                        ),
                      ),
                      backgroundColor: AppColors.emergencyRed,
                    ),
                  );
                }
              },
              child: isSaving
                  ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : Text(
                _tr('Save', 'حفظ'),
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    ).whenComplete(() {
      dobCtrl.dispose();
      genderCtrl.dispose();
      heightCtrl.dispose();
      weightCtrl.dispose();
    });
  }

  void _showAddItemDialog({
    required String title,
    required String field1Label,
    required String field2Label,
    required void Function(String v1, String v2) onAdd,
  }) {
    final c1 = TextEditingController();
    final c2 = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: c1,
              decoration: InputDecoration(
                labelText: field1Label,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: c2,
              decoration: InputDecoration(
                labelText: field2Label,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryTeal,
            ),
            onPressed: () {
              if (c1.text.trim().isNotEmpty) {
                setState(() {
                  onAdd(
                    c1.text.trim(),
                    c2.text.trim(),
                  );
                });
              }

              Navigator.pop(ctx);
            },
            child: Text(
              _tr('Add', 'إضافة'),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    ).whenComplete(() {
      c1.dispose();
      c2.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = VitaAuthService.instance;

    final fullName = auth.currentUserName.isNotEmpty
        ? auth.currentUserName
        : _tr('New Patient', 'مريض جديد');

    final patientId = auth.currentUserId ?? 'VF-NEW';
    final initials = _getInitials(fullName);

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: VitaAppBar(
        title: _tr(
          'Digital Medical Profile',
          'الملف الطبي الرقمي',
        ),
        subtitle:
        '${_tr("Verified Patient Vault ID", "رقم الخزنة الموثق")} #$patientId',
        actions: [
          IconButton(
            icon: const Icon(
              Icons.edit_outlined,
              color: AppColors.primaryTeal,
              size: 22,
            ),
            onPressed: _showEditProfileDialog,
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMedicalIDCard(
              fullName,
              initials,
              patientId,
            ),

            const SizedBox(height: 20),

            _buildVitalsSummary(),

            const SizedBox(height: 20),

            _buildSectionHeader(
              title: _tr(
                'Known Allergies & Reactions',
                'الحساسية والتفاعلات الدوائية',
              ),
              icon: Icons.warning_amber_rounded,
              color: AppColors.emergencyRed,
              onAdd: () => _showAddItemDialog(
                title: _tr('Add Allergy', 'إضافة حساسية'),
                field1Label: _tr(
                  'Allergy Substance',
                  'اسم المادة المسببة للحساسية',
                ),
                field2Label: _tr(
                  'Reaction / Severity',
                  'الأعراض / درجة الخطورة',
                ),
                onAdd: (s, r) {
                  _allergies.add({
                    'substance': s,
                    'reaction': r,
                  });
                },
              ),
            ),

            const SizedBox(height: 10),

            if (_allergies.isEmpty)
              _buildEmptyNote(
                _tr(
                  'No allergies recorded. Tap + to add.',
                  'لا توجد حساسية مسجلة. اضغط + للإضافة.',
                ),
              )
            else
              ..._allergies.map((a) => _buildAllergyTile(a)),

            const SizedBox(height: 20),

            _buildSectionHeader(
              title: _tr(
                'Chronic Medical Conditions',
                'الأمراض المزمنة',
              ),
              icon: Icons.healing_rounded,
              color: AppColors.medicalBlue,
              onAdd: () => _showAddItemDialog(
                title: _tr(
                  'Add Medical Condition',
                  'إضافة حالة مرضية',
                ),
                field1Label: _tr(
                  'Condition Name',
                  'اسم الحالة المرضية',
                ),
                field2Label: _tr(
                  'Diagnosis Year / Notes',
                  'سنة التشخيص / ملاحظات',
                ),
                onAdd: (n, y) {
                  _conditions.add({
                    'name': n,
                    'year': y,
                  });
                },
              ),
            ),

            const SizedBox(height: 10),

            if (_conditions.isEmpty)
              _buildEmptyNote(
                _tr(
                  'No chronic conditions recorded. Tap + to add.',
                  'لا توجد أمراض مزمنة مسجلة. اضغط + للإضافة.',
                ),
              )
            else
              ..._conditions.map(
                    (c) => _buildConditionTile(c),
              ),

            const SizedBox(height: 20),

            _buildSectionHeader(
              title: _tr(
                'Emergency Contacts (ICE)',
                'جهات اتصال الطوارئ',
              ),
              icon: Icons.contact_phone_rounded,
              color: AppColors.primaryTeal,
              onAdd: () => _showAddItemDialog(
                title: _tr(
                  'Add Emergency Contact',
                  'إضافة جهة اتصال طوارئ',
                ),
                field1Label: _tr(
                  'Contact Name & Relation',
                  'الاسم وصلة القرابة',
                ),
                field2Label: _tr(
                  'Phone Number',
                  'رقم الهاتف',
                ),
                onAdd: (n, p) {
                  _contacts.add({
                    'name': n,
                    'phone': p,
                  });
                },
              ),
            ),

            const SizedBox(height: 10),

            if (_contacts.isEmpty)
              _buildEmptyNote(
                _tr(
                  'No emergency contacts added. Tap + to add.',
                  'لا توجد جهات اتصال طوارئ. اضغط + للإضافة.',
                ),
              )
            else
              ..._contacts.map(
                    (contact) => _buildContactTile(
                  context,
                  contact,
                ),
              ),

            const SizedBox(height: 24),

            VitaButton(
              label: _tr(
                'Edit Basic Info & Measurements',
                'تعديل البيانات الأساسية والقياسات',
              ),
              icon: Icons.edit_note_rounded,
              variant: VitaButtonVariant.outline,
              onPressed: _showEditProfileDialog,
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyNote(String text) {
    return VitaCard(
      padding: const EdgeInsets.all(14),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildMedicalIDCard(
      String fullName,
      String initials,
      String patientId,
      ) {
    return GestureDetector(
      onTap: _showEditProfileDialog,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppColors.blueTealGradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryTeal.withOpacity(0.3),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.shield_rounded,
                      color: AppColors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _tr(
                        'VITANATIONAL HEALTH ID',
                        'الهوية الصحية الرقمية',
                      ),
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _tr('ACTIVE VAULT', 'خزنة نشطة'),
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.white,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryTeal,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.white,
                        ),
                      ),

                      const SizedBox(height: 2),

                      Text(
                        '${_tr("DOB", "الميلاد")}: $_dob • $_gender',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFE0F2FE),
                        ),
                      ),

                      const SizedBox(height: 2),

                      Text(
                        '${_tr("Patient ID", "رقم المريض")}: $patientId',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildCardAttribute(
                    _tr('BLOOD TYPE', 'فصيلة الدم'),
                    _bloodType,
                    isHighlight: true,
                  ),

                  Container(
                    width: 1,
                    height: 28,
                    color: Colors.white.withOpacity(0.2),
                  ),

                  _buildCardAttribute(
                    _tr('ORGAN DONOR', 'تبرع بالأعضاء'),
                    _isOrganDonor
                        ? _tr('YES', 'نعم')
                        : _tr('NO', 'لا'),
                  ),

                  Container(
                    width: 1,
                    height: 28,
                    color: Colors.white.withOpacity(0.2),
                  ),

                  _buildCardAttribute(
                    'BMI',
                    _bmi != null
                        ? _bmi!.toStringAsFixed(1)
                        : '--',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardAttribute(
      String label,
      String value, {
        bool isHighlight = false,
      }) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: Colors.white.withOpacity(0.8),
          ),
        ),

        const SizedBox(height: 2),

        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: isHighlight
                ? const Color(0xFFFDE047)
                : AppColors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildVitalsSummary() {
    final bmiVal = _bmi;

    return GestureDetector(
      onTap: _showEditProfileDialog,
      child: Row(
        children: [
          Expanded(
            child: VitaCard(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _tr('Height', 'الطول'),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    _heightCm != null
                        ? '${_heightCm!.toStringAsFixed(0)} cm'
                        : '-- cm',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  Text(
                    _tr('Tap to edit', 'اضغط للتعديل'),
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: VitaCard(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _tr('Weight', 'الوزن'),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    _weightKg != null
                        ? '${_weightKg!.toStringAsFixed(1)} kg'
                        : '-- kg',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  Text(
                    _tr('Tap to edit', 'اضغط للتعديل'),
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: VitaCard(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _tr('Body Mass', 'مؤشر الكتلة'),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    bmiVal != null
                        ? bmiVal.toStringAsFixed(1)
                        : '--',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryTeal,
                    ),
                  ),

                  Text(
                    bmiVal != null
                        ? _bmiCategory(bmiVal)
                        : _tr('Auto-calc', 'يحسب تلقائياً'),
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onAdd,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),

        InkWell(
          onTap: onAdd,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: AppColors.primaryTealSoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.add,
                  size: 16,
                  color: AppColors.primaryTeal,
                ),
                const SizedBox(width: 2),
                Text(
                  _tr('Add', 'إضافة'),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryTeal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAllergyTile(Map allergy) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: VitaCard(
        padding: const EdgeInsets.all(12),
        borderColor: AppColors.emergencyRed.withOpacity(0.3),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppColors.emergencyRedSoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                size: 18,
                color: AppColors.emergencyRed,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    allergy['substance'] ?? '',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  if ((allergy['reaction'] ?? '').isNotEmpty)
                    Text(
                      allergy['reaction']!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConditionTile(Map condition) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: VitaCard(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppColors.medicalBlueSoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_outline_rounded,
                size: 18,
                color: AppColors.medicalBlue,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    condition['name'] ?? '',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  if ((condition['year'] ?? '').isNotEmpty)
                    Text(
                      condition['year']!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),

            VitaBadge(
              label: _tr('Tracked', 'متابع'),
              type: BadgeType.medical,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactTile(
      BuildContext context,
      Map contact,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: VitaCard(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppColors.primaryTealSoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.phone_rounded,
                size: 18,
                color: AppColors.primaryTeal,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contact['name'] ?? '',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  Text(
                    contact['phone'] ?? '',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            IconButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${_tr("Dialing", "جاري الاتصال بـ")} ${contact['name']}...',
                    ),
                    backgroundColor: AppColors.primaryTeal,
                  ),
                );
              },
              icon: const Icon(
                Icons.call,
                color: AppColors.primaryTeal,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
