import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _titleController =
  TextEditingController();

  final TextEditingController _doctorController =
  TextEditingController();

  final TextEditingController _hospitalController =
  TextEditingController();

  final TextEditingController _notesController =
  TextEditingController();

  String _selectedType = 'تحليل معملي';

  Uint8List? _selectedBytes;
  String? _fileName;
  bool _isImage = false;
  bool _isPicking = false;

  final List<String> _analysisTypes = [
    'تحليل معملي',
    'أشعة',
    'تحاليل دم',
    'تحاليل بول',
    'تقرير طبي',
    'روشتة طبية',
    'أخرى',
  ];

  // عرض رسالة للمستخدم
  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // اختيار ملف PDF
  Future<void> _pickPDF() async {
    if (_isPicking) return;

    try {
      setState(() => _isPicking = true);

      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (files.isEmpty) return;

      final file = files.first;
      final bytes = await file.readAsBytes();

      if (!mounted) return;

      setState(() {
        _selectedBytes = bytes;
        _fileName = file.name;
        _isImage = false;
      });

    } catch (e) {
      debugPrint('PDF Error: $e');
      _showMessage('حدث خطأ أثناء اختيار ملف PDF');
    } finally {
      if (mounted) {
        setState(() => _isPicking = false);
      }
    }
  }

  // اختيار صورة من المعرض
  Future<void> _pickGallery() async {
    if (_isPicking) return;

    try {
      setState(() => _isPicking = true);

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image == null) return;

      final bytes = await image.readAsBytes();

      if (!mounted) return;

      setState(() {
        _selectedBytes = bytes;
        _fileName = image.name;
        _isImage = true;
      });

    } catch (e) {
      debugPrint('Gallery Error: $e');
      _showMessage('حدث خطأ أثناء فتح المعرض');
    } finally {
      if (mounted) {
        setState(() => _isPicking = false);
      }
    }
  }

  // فتح الكاميرا والتقاط صورة
  Future<void> _openCamera() async {
    if (_isPicking) return;

    try {
      setState(() => _isPicking = true);

      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (photo == null) return;

      final bytes = await photo.readAsBytes();

      if (!mounted) return;

      setState(() {
        _selectedBytes = bytes;
        _fileName = photo.name;
        _isImage = true;
      });

    } catch (e) {
      debugPrint('Camera Error: $e');
      _showMessage('تعذر فتح الكاميرا، تأكدي من صلاحيات المتصفح');
    } finally {
      if (mounted) {
        setState(() => _isPicking = false);
      }
    }
  }

  // حذف الملف
  void _removeFile() {
    setState(() {
      _selectedBytes = null;
      _fileName = null;
      _isImage = false;
    });
  }

  // حفظ بيانات الملف
  void _saveRecord() {
    if (_selectedBytes == null) {
      _showMessage('اختاري ملف أو صورة أولاً');
      return;
    }

    if (_titleController.text.trim().isEmpty) {
      _showMessage('اكتبي عنوان الملف');
      return;
    }

    // بيانات الملف جاهزة للربط مع Firebase
    debugPrint('Type: $_selectedType');
    debugPrint('File: $_fileName');
    debugPrint('Doctor: ${_doctorController.text}');
    debugPrint('Hospital: ${_hospitalController.text}');
    debugPrint('Notes: ${_notesController.text}');
    debugPrint('Bytes: ${_selectedBytes!.length}');

    _showMessage('تم تجهيز بيانات الملف بنجاح');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _doctorController.dispose();
    _hospitalController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF176B87);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7FAFC),

        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          foregroundColor: primaryColor,
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'رفع ملف طبي',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 19,
                ),
              ),
              Text(
                'أضف ملفاً إلى خزانتك الصحية',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),

        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const Text(
                'المصدر',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 15),

              // مصادر رفع الملفات
              Row(
                children: [
                  Expanded(
                    child: _sourceButton(
                      icon: Icons.picture_as_pdf,
                      title: 'ملف PDF',
                      onTap: _pickPDF,
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: _sourceButton(
                      icon: Icons.photo_library,
                      title: 'المعرض',
                      onTap: _pickGallery,
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: _sourceButton(
                      icon: Icons.camera_alt,
                      title: 'الكاميرا',
                      onTap: _openCamera,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // معاينة الملف المختار
              if (_isPicking)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(15),
                    child: CircularProgressIndicator(),
                  ),
                ),

              if (_selectedBytes != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: primaryColor.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      if (_isImage)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(
                            _selectedBytes!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.contain,
                          ),
                        )
                      else
                        const Icon(
                          Icons.picture_as_pdf,
                          color: Colors.red,
                          size: 65,
                        ),

                      const SizedBox(height: 10),

                      Text(
                        _fileName ?? '',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      TextButton.icon(
                        onPressed: _removeFile,
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        label: const Text(
                          'إزالة الملف',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 25),

              _fieldLabel('النوع'),

              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: _inputDecoration(),
                items: _analysisTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedType = value;
                    });
                  }
                },
              ),

              const SizedBox(height: 18),

              _fieldLabel('عنوان الملف'),

              TextFormField(
                controller: _titleController,
                decoration: _inputDecoration(
                  hint: 'مثال: تحليل صورة دم',
                ),
              ),

              const SizedBox(height: 18),

              _fieldLabel('اسم الطبيب'),

              TextFormField(
                controller: _doctorController,
                decoration: _inputDecoration(
                  hint: 'اسم الطبيب',
                ),
              ),

              const SizedBox(height: 18),

              _fieldLabel('المستشفى أو العيادة'),

              TextFormField(
                controller: _hospitalController,
                decoration: _inputDecoration(
                  hint: 'اسم المستشفى أو العيادة',
                ),
              ),

              const SizedBox(height: 18),

              _fieldLabel('ملاحظات'),

              TextFormField(
                controller: _notesController,
                maxLines: 4,
                decoration: _inputDecoration(
                  hint: 'أضف أي ملاحظات...',
                ),
              ),

              const SizedBox(height: 30),

              // زر الحفظ
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isPicking ? null : _saveRecord,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'حفظ الملف الطبي',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // تصميم أزرار المصادر
  Widget _sourceButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: _isPicking ? null : onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        height: 95,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: const Color(0xFFDCE5EC),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: const Color(0xFF176B87),
              size: 27,
            ),

            const SizedBox(height: 8),

            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color(0xFF34495E),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFFDCE5EC),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFFDCE5EC),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFF176B87),
          width: 1.5,
        ),
      ),
    );
  }
}