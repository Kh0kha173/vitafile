import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/medical_record.dart';
import '../main.dart';
import '../widgets/vita_badge.dart';

class RecordsScreen extends StatefulWidget {
  final bool isEmbedded;

  const RecordsScreen({super.key, this.isEmbedded = false});

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  int _selectedCategoryIndex = 0;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final List<MedicalRecord> _records = [];
  bool get _isAr => appLocaleNotifier.value.languageCode == 'ar';
  String _tr(String en, String ar) => _isAr ? ar : en;

  @override
  void initState() {
    super.initState();
    appLocaleNotifier.addListener(_onLocaleChanged);
  }

  void _onLocaleChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    appLocaleNotifier.removeListener(_onLocaleChanged);
    _searchController.dispose();
    super.dispose();
  }

  String _categoryLabel(RecordCategory c) {
    switch (c) {
      case RecordCategory.labTest:
        return _tr('Lab Tests', 'تحاليل معملية');
      case RecordCategory.imagingXRay:
        return _tr('Imaging & X-Rays', 'أشعة وفحوصات');
      case RecordCategory.prescription:
        return _tr('Prescriptions', 'روشتات');
      case RecordCategory.doctorNote:
        return _tr('Doctor Notes', 'ملاحظات الطبيب');
      case RecordCategory.vaccination:
        return _tr('Vaccines', 'تطعيمات');
    }
  }
  static const List<RecordCategory?> _categoryValues = [
    null,
    RecordCategory.labTest,
    RecordCategory.imagingXRay,
    RecordCategory.prescription,
    RecordCategory.doctorNote,
    RecordCategory.vaccination,
  ];

  List<String> get _categories => [
    _tr('All', 'الكل'),
    ..._categoryValues.skip(1).map((c) => _categoryLabel(c!)),
  ];

  List<MedicalRecord> get _filteredRecords {
    final query = _searchQuery.toLowerCase();
    final selected = _categoryValues[_selectedCategoryIndex];

    return _records.where((record) {
      final matchesSearch = record.title.toLowerCase().contains(query) ||
          record.doctorName.toLowerCase().contains(query) ||
          record.facility.toLowerCase().contains(query);

      if (!matchesSearch) return false;
      return selected == null || record.category == selected;
    }).toList();
  }

  void _openUpload() {
    Navigator.pushNamed(context, '/upload');
  }
  void _showRecordDetailSheet(MedicalRecord record) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Directionality(
        textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr,
        child: DraggableScrollableSheet(
          initialChildSize: 0.78,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, scrollController) => Container(
            decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
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
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          VitaBadge(
                            label: _categoryLabel(record.category),
                            type: BadgeType.medical,
                          ),
                          if (record.isVerified)
                            VitaBadge(
                              label: _tr('Clinician Verified', 'موثق طبياً'),
                              type: BadgeType.success,
                              icon: Icons.verified_rounded,
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        record.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${record.facility} • ${record.date}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_tr("Ordering Physician", "الطبيب المعالج")}: ${record.doctorName}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryTeal,
                        ),
                      ),
                      const Divider(
                          height: 28, color: AppColors.cardBorderSubtle),
                      Text(
                        _tr('Clinical Summary', 'الملخص الطبي'),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        record.summary,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryTeal,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(_tr('Close', 'إغلاق')),
                        ),
                      ),
                    ],
                  ),
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
    final records = _filteredRecords;
    final categories = _categories;

    final body = Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: _tr('Search records...', 'ابحث في السجلات...'),
                    prefixIcon: const Icon(Icons.search_rounded),
                    filled: true,
                    fillColor: AppColors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                      const BorderSide(color: AppColors.cardBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                      const BorderSide(color: AppColors.cardBorder),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Tooltip(
                message: _tr('Upload file', 'رفع ملف'),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: _openUpload,
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.primaryTeal,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.upload_file_rounded,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) => ChoiceChip(
              label: Text(categories[i]),
              selected: _selectedCategoryIndex == i,
              selectedColor: AppColors.primaryTeal,
              labelStyle: TextStyle(
                color: _selectedCategoryIndex == i
                    ? Colors.white
                    : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              onSelected: (_) => setState(() => _selectedCategoryIndex = i),
            ),
          ),
        ),
        Expanded(
          child: records.isEmpty
              ? Center(
            child: Text(
              _tr('No records found', 'لا توجد سجلات'),
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          )
              : ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: records.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final r = records[i];
              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _showRecordDetailSheet(r),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      VitaBadge(
                        label: _categoryLabel(r.category),
                        type: BadgeType.medical,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        r.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${r.facility} • ${r.date}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );

    return Directionality(
      textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr,
      child: widget.isEmbedded
          ? body
          : Scaffold(
        appBar: AppBar(
          title: Text(_tr('Medical Records', 'السجلات الطبية')),
        ),
        body: body,
      ),
    );
  }
}