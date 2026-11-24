import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/timeline_event.dart';
import '../main.dart';
import '../widgets/vita_app_bar.dart';
import '../widgets/vita_card.dart';
import '../widgets/vita_badge.dart';

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({super.key});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  int _selectedYear = 0;
  final Set<String> _expandedEventIds = {};
  final List<TimelineEvent> _events = [];

  bool get _isAr => appLocaleNotifier.value.languageCode == 'ar';
  String _tr(String en, String ar) => _isAr ? ar : en;

  List<TimelineEvent> get _filteredEvents {
    if (_selectedYear == 0) return _events;
    return _events.where((e) => e.year == _selectedYear).toList();
  }

  void _toggleExpanded(String id) {
    setState(() {
      if (_expandedEventIds.contains(id)) {
        _expandedEventIds.remove(id);
      } else {
        _expandedEventIds.add(id);
      }
    });
  }

  String _iconTypeForCategory(String cat) {
    switch (cat.toLowerCase()) {
      case 'lab test':
        return 'biotech';
      case 'imaging':
        return 'scanner';
      case 'vaccination':
        return 'vaccines';
      case 'surgery':
        return 'healing';
      default:
        return 'stethoscope';
    }
  }

  void _showAddEventDialog() {
    final titleCtrl = TextEditingController();
    final facilityCtrl = TextEditingController();
    final doctorCtrl = TextEditingController();
    final diagnosisCtrl = TextEditingController();
    final treatmentCtrl = TextEditingController();
    String selectedCat = 'Lab Test';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            _tr('Add Timeline Event', 'إضافة حدث للسجل الزمني'),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedCat,
                  decoration: InputDecoration(
                    labelText: _tr('Category', 'النوع'),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: [
                    DropdownMenuItem<String>(
                        value: 'Lab Test', child: Text(_tr('Lab Test', 'تحليل معملي'))),
                    DropdownMenuItem<String>(
                        value: 'Imaging', child: Text(_tr('Imaging / X-Ray', 'أشعة'))),
                    DropdownMenuItem<String>(
                        value: 'Doctor Visit', child: Text(_tr('Doctor Visit', 'كشف طبي'))),
                    DropdownMenuItem<String>(
                        value: 'Vaccination', child: Text(_tr('Vaccination', 'تطعيم'))),
                    DropdownMenuItem<String>(
                        value: 'Surgery', child: Text(_tr('Surgery', 'عملية جراحية'))),
                  ],
                  onChanged: (v) {
                    if (v != null) setDialogState(() => selectedCat = v);
                  },
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: titleCtrl,
                  decoration: InputDecoration(
                    labelText: _tr('Title (e.g. Cardiology Checkup)',
                        'العنوان (مثال: متابعة باطنة)'),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: doctorCtrl,
                  decoration: InputDecoration(
                    labelText: _tr('Doctor Name', 'اسم الطبيب'),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: facilityCtrl,
                  decoration: InputDecoration(
                    labelText: _tr('Hospital / Clinic', 'المستشفى أو العيادة'),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: diagnosisCtrl,
                  decoration: InputDecoration(
                    labelText: _tr('Diagnosis / Summary', 'التشخيص أو الملخص'),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: treatmentCtrl,
                  decoration: InputDecoration(
                    labelText: _tr('Treatment Prescribed', 'العلاج الموصوف'),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
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
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryTeal),
              onPressed: () {
                if (titleCtrl.text.trim().isEmpty) return;
                final now = DateTime.now();
                final newId = 'TLE-${now.millisecondsSinceEpoch}';
                setState(() {
                  _events.insert(
                    0,
                    TimelineEvent(
                      id: newId,
                      year: now.year,
                      date: '${now.day}/${now.month}/${now.year}',
                      category: selectedCat,
                      title: titleCtrl.text.trim(),
                      facility: facilityCtrl.text.trim().isEmpty
                          ? _tr('Clinic', 'عيادة خاصة')
                          : facilityCtrl.text.trim(),
                      doctorName: doctorCtrl.text.trim().isEmpty
                          ? _tr('Doctor', 'الطبيب المعالج')
                          : doctorCtrl.text.trim(),
                      diagnosis: diagnosisCtrl.text.trim().isEmpty
                          ? _tr('Routine medical follow-up', 'متابعة طبية دورية')
                          : diagnosisCtrl.text.trim(),
                      treatment: treatmentCtrl.text.trim().isEmpty
                          ? _tr('No specific medication', 'لا يوجد علاج محدد')
                          : treatmentCtrl.text.trim(),
                      attachmentsCount: 0,
                      iconType: _iconTypeForCategory(selectedCat),
                    ),
                  );
                  _expandedEventIds.add(newId);
                });
                Navigator.pop(ctx);
              },
              child: Text(_tr('Save', 'حفظ'), style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredEvents;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: VitaAppBar(
        title: _tr('Medical Timeline', 'السجل الزمني الطبي'),
        subtitle: _tr('Chronological Health Journey', 'تاريخك الصحي مرتباً زمنياً'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded,
                color: AppColors.primaryTeal, size: 22),
            onPressed: _showAddEventDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                _buildYearChip(_tr('All History', 'كل السجل'), 0),
                const SizedBox(width: 8),
                _buildYearChip('2026', 2026),
                const SizedBox(width: 8),
                _buildYearChip('2025', 2025),
              ],
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.timeline_rounded,
                      size: 48, color: AppColors.textMuted),
                  const SizedBox(height: 12),
                  Text(
                    _tr('No timeline events recorded yet',
                        'لا توجد أحداث طبية مسجلة بعد'),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _tr('Tap + Add Event below to log a visit or test',
                        'اضغط على + إضافة حدث بالأسفل لتسجيل زيارة أو تحليل'),
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final TimelineEvent event = filtered[index];
                final isLast = index == filtered.length - 1;
                final isExpanded = _expandedEventIds.contains(event.id);
                return _buildTimelineRow(event, isLast, isExpanded);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddEventDialog,
        backgroundColor: AppColors.primaryTeal,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          _tr('Add Event', 'إضافة حدث'),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildYearChip(String label, int year) {
    final isSelected = _selectedYear == year;
    return GestureDetector(
      onTap: () => setState(() => _selectedYear = year),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryTeal : AppColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primaryTeal : AppColors.cardBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppColors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  String _translateCategory(String cat) {
    switch (cat.toLowerCase()) {
      case 'lab test':
        return _tr('Lab Test', 'تحليل معملي');
      case 'imaging':
        return _tr('Imaging', 'أشعة');
      case 'vaccination':
        return _tr('Vaccination', 'تطعيم');
      case 'surgery':
        return _tr('Surgery', 'عملية جراحية');
      default:
        return _tr('Doctor Visit', 'كشف طبي');
    }
  }

  Widget _buildTimelineRow(TimelineEvent event, bool isLast, bool isExpanded) {
    Color nodeColor;
    IconData nodeIcon;

    switch (event.category.toLowerCase()) {
      case 'lab test':
        nodeColor = AppColors.primaryTeal;
        nodeIcon = Icons.biotech_rounded;
        break;
      case 'imaging':
        nodeColor = AppColors.medicalBlue;
        nodeIcon = Icons.document_scanner_rounded;
        break;
      case 'vaccination':
        nodeColor = AppColors.successGreen;
        nodeIcon = Icons.vaccines_rounded;
        break;
      case 'surgery':
        nodeColor = AppColors.warningOrange;
        nodeIcon = Icons.healing_rounded;
        break;
      default:
        nodeColor = AppColors.infoPurple;
        nodeIcon = Icons.medical_services_rounded;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: nodeColor.withOpacity(0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: nodeColor, width: 2),
                ),
                child: Icon(nodeIcon, size: 18, color: nodeColor),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: AppColors.cardBorder,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: VitaCard(
                onTap: () => _toggleExpanded(event.id),
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        VitaBadge(
                          label: _translateCategory(event.category),
                          type: BadgeType.neutral,
                        ),
                        Text(
                          event.date,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      event.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${event.facility} • ${event.doctorName}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      event.diagnosis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textPrimary,
                        height: 1.35,
                      ),
                    ),
                    if (isExpanded) ...[
                      const Divider(height: 18, color: AppColors.cardBorderSubtle),
                      Text(
                        _tr('Treatment / Action Prescribed:',
                            'العلاج / الإجراء الموصوف:'),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        event.treatment,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textPrimary,
                          height: 1.35,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          isExpanded
                              ? _tr('Show less', 'عرض أقل')
                              : _tr('View full notes', 'عرض التفاصيل'),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryTeal,
                          ),
                        ),
                        Icon(
                          isExpanded
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          size: 16,
                          color: AppColors.primaryTeal,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}