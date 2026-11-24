import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/medication.dart';
import '../services/notification_service.dart';
import '../main.dart';
import '../widgets/vita_app_bar.dart';
import '../widgets/vita_card.dart';
import '../widgets/vita_badge.dart';
import '../widgets/vita_button.dart';
import '../widgets/vita_text_field.dart';

class MedicationTrackerScreen extends StatefulWidget {
  final bool isEmbedded;

  const MedicationTrackerScreen({super.key, this.isEmbedded = false});

  @override
  State<MedicationTrackerScreen> createState() =>
      _MedicationTrackerScreenState();
}

class _MedicationTrackerScreenState extends State<MedicationTrackerScreen> {
  final List<Medication> _medications = [];

  bool get _isAr => appLocaleNotifier.value.languageCode == 'ar';
  String _tr(String en, String ar) => _isAr ? ar : en;

  void _toggleMedicationTaken(int index) {
    setState(() {
      final Medication med = _medications[index];
      final newStatus = !med.isTakenToday;
      _medications[index] = med.copyWith(
        isTakenToday: newStatus,
        pillsRemaining: newStatus
            ? (med.pillsRemaining > 0 ? med.pillsRemaining - 1 : 0)
            : med.pillsRemaining + 1,
      );
    });
  }

  void _showAddMedicationSheet() {
    final nameCtrl = TextEditingController();
    final dosageCtrl = TextEditingController();
    final instructionsCtrl = TextEditingController();
    TimeOfDay selectedTime = TimeOfDay.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
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
                  _tr('Add New Prescription', 'إضافة دواء جديد'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _tr(
                    'Schedule automatic reminder notifications and track doses.',
                    'اضبط مواعيد التنبيه التلقائي وتابع جرعاتك اليومية.',
                  ),
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 18),
                VitaTextField(
                  label: _tr('Medication Name', 'اسم الدواء'),
                  hint: _tr('e.g. Panadol / Augmentin', 'مثال: بنادول / أوجمنتين'),
                  controller: nameCtrl,
                  prefixIcon: Icons.medication_rounded,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: VitaTextField(
                        label: _tr('Dosage', 'الجرعة'),
                        hint: _tr('e.g. 1 Tablet', 'مثال: قرص واحد'),
                        controller: dosageCtrl,
                        prefixIcon: Icons.format_paint_outlined,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: ctx,
                            initialTime: selectedTime,
                          );
                          if (picked != null) {
                            setSheetState(() => selectedTime = picked);
                          }
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 14),
                          decoration: BoxDecoration(
                            color: AppColors.primaryTealSoft,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: AppColors.primaryTeal.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Icon(Icons.alarm_rounded,
                                  color: AppColors.primaryTeal, size: 20),
                              Text(
                                selectedTime.format(ctx),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primaryTealDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                VitaTextField(
                  label: _tr('Instructions', 'تعليمات الاستخدام'),
                  hint: _tr('e.g. Take after meals', 'مثال: يؤخذ بعد الأكل'),
                  controller: instructionsCtrl,
                  prefixIcon: Icons.info_outline_rounded,
                ),
                const SizedBox(height: 24),
                VitaButton(
                  label: _tr('Save Medication & Set Alarm',
                      'حفظ الدواء وتفعيل المنبه'),
                  icon: Icons.check_circle_outline_rounded,
                  onPressed: () async {
                    if (nameCtrl.text.trim().isEmpty) return;
                    final medId =
                        DateTime.now().millisecondsSinceEpoch ~/ 1000;
                    final medName = nameCtrl.text.trim();
                    final medDose = dosageCtrl.text.trim().isEmpty
                        ? _tr('1 dose', 'جرعة واحدة')
                        : dosageCtrl.text.trim();
                    final timeStr = selectedTime.format(ctx);

                    setState(() {
                      _medications.add(
                        Medication(
                          id: 'MED-$medId',
                          name: medName,
                          dosage: medDose,
                          type: _tr('Tablet', 'قرص'),
                          frequency: _tr('Daily', 'يومياً'),
                          scheduledTimes: [timeStr],
                          instructions: instructionsCtrl.text.trim().isEmpty
                              ? _tr('Take with water', 'يؤخذ مع الماء')
                              : instructionsCtrl.text.trim(),
                          prescribedBy: _tr('Self / Doctor', 'الطبيب المعالج'),
                          pillsRemaining: 30,
                          totalPills: 30,
                          isTakenToday: false,
                        ),
                      );
                    });

                    await VitaNotificationService.instance
                        .scheduleDailyMedication(
                      id: medId,
                      medName: medName,
                      dosage: medDose,
                      time: selectedTime,
                    );

                    if (!mounted) return;
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          _tr(
                            'Reminder set for $medName at $timeStr',
                            'تم ضبط إشعار يومي لـ $medName الساعة $timeStr',
                          ),
                        ),
                        backgroundColor: AppColors.primaryTeal,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // يسمع لتغيير اللغة فتتحدث الصفحة تلقائياً
    return ValueListenableBuilder<Locale>(
      valueListenable: appLocaleNotifier,
      builder: (context, locale, _) => _buildScaffold(),
    );
  }

  Widget _buildScaffold() {
    final takenCount = _medications.where((m) => m.isTakenToday).length;
    final progress =
    _medications.isEmpty ? 0.0 : (takenCount / _medications.length);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: VitaAppBar(
        title: _tr('Medication Tracker', 'متابعة الأدوية'),
        subtitle: _tr('Prescriptions & Adherence', 'الروشتات ومواعيد الجرعات'),
        showBackButton: !widget.isEmbedded,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded,
                color: AppColors.primaryTeal, size: 24),
            onPressed: _showAddMedicationSheet,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAdherenceCard(takenCount, _medications.length, progress),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _tr('Daily Prescriptions', 'الأدوية اليومية'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  _tr('Tap pill to toggle taken', 'اضغط لتأكيد أخذ الجرعة'),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_medications.isEmpty)
              GestureDetector(
                onTap: _showAddMedicationSheet,
                child: VitaCard(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primaryTealSoft,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.medication_outlined,
                            color: AppColors.primaryTeal),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _tr(
                            'No medications added yet. Tap + Add Medication to set daily reminders.',
                            'لا توجد أدوية مسجلة حالياً. اضغط على + إضافة دواء لضبط مواعيدك.',
                          ),
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...List.generate(_medications.length, (index) {
                return _buildMedicationCard(_medications[index], index);
              }),
            const SizedBox(height: 28),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddMedicationSheet,
        backgroundColor: AppColors.primaryTeal,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          _tr('Add Medication', 'إضافة دواء'),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildAdherenceCard(int taken, int total, double progress) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.tealGradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryTeal.withOpacity(0.28),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 68,
                height: 68,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 6,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.white),
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _tr("Today's Adherence Rate", 'نسبة الالتزام اليومية'),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _tr(
                    '$taken of $total medications checked off',
                    'تم تناول $taken من أصل $total أدوية',
                  ),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFE0F2FE),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationCard(Medication med, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: VitaCard(
        onTap: () => _toggleMedicationTaken(index),
        padding: const EdgeInsets.all(16),
        borderColor: med.isTakenToday
            ? AppColors.successGreen.withOpacity(0.4)
            : AppColors.cardBorder,
        backgroundColor: med.isTakenToday
            ? AppColors.successGreenSoft.withOpacity(0.2)
            : AppColors.white,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => _toggleMedicationTaken(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: med.isTakenToday
                      ? AppColors.successGreen
                      : AppColors.background,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: med.isTakenToday
                        ? AppColors.successGreen
                        : AppColors.cardBorder,
                    width: 2,
                  ),
                ),
                child: med.isTakenToday
                    ? const Icon(Icons.check_rounded,
                    color: AppColors.white, size: 20)
                    : null,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          med.name,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            decoration: med.isTakenToday
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      VitaBadge(
                        label: med.scheduledTimes.first,
                        type: BadgeType.neutral,
                        icon: Icons.schedule_rounded,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${med.dosage} • ${med.frequency}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryTeal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    med.instructions,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${med.pillsRemaining} ${_tr("doses left", "جرعة متبقية")}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      InkWell(
                        onTap: () =>
                            setState(() => _medications.removeAt(index)),
                        child: const Icon(Icons.delete_outline,
                            color: AppColors.emergencyRed, size: 18),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}