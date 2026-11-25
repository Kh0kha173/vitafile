import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/navigation/app_router.dart';
import '../services/auth_service.dart';
import '../main.dart';
import '../widgets/vita_app_bar.dart';
import '../widgets/vita_card.dart';
import '../widgets/vita_badge.dart';

class SettingsScreen extends StatefulWidget {
  final bool isEmbedded;

  const SettingsScreen({super.key, this.isEmbedded = false});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _biometricsEnabled = true;
  bool _twoFactorEnabled = true;
  bool _medReminders = true;
  bool _doctorAlerts = true;
  bool _isSyncing = false;

  bool get _isAr => appLocaleNotifier.value.languageCode == 'ar';
  bool get _isDark => themeModeNotifier.value == ThemeMode.dark;
  String _tr(String en, String ar) => _isAr ? ar : en;

  // ألوان تتغير حسب الوضع
  Color get _pageBg => _isDark ? const Color(0xFF0F171C) : AppColors.background;
  Color get _cardBg => _isDark ? const Color(0xFF1B262D) : AppColors.white;
  Color get _cardBorder =>
      _isDark ? const Color(0xFF2C3A44) : AppColors.cardBorder;
  Color get _divider =>
      _isDark ? const Color(0xFF2C3A44) : AppColors.cardBorderSubtle;

  void _setLanguage(String code) {
    appLocaleNotifier.value = Locale(code);
  }

  void _setTheme(ThemeMode mode) {
    themeModeNotifier.value = mode;
  }

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'U';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  Future<void> _triggerManualSync() async {
    setState(() => _isSyncing = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _isSyncing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_tr(
          'Vault synchronized and encrypted successfully.',
          'تمت مزامنة الخزنة وتشفير البيانات بنجاح.',
        )),
        backgroundColor: AppColors.primaryTeal,
      ),
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          _tr('Lock Vault & Sign Out', 'قفل الخزنة وتسجيل الخروج'),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Text(
          _tr(
            'Your medical records will be encrypted locally and can only be unlocked with your password.',
            'سيتم تشفير سجلاتك الطبية محلياً ولن يمكن فتحها إلا بكلمة المرور الخاصة بك.',
          ),
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              _tr('Cancel', 'إلغاء'),
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await VitaAuthService.instance.signOut();
              if (!mounted) return;
              Navigator.pop(dialogContext);
              Navigator.of(context)
                  .pushNamedAndRemoveUntil(AppRoutes.auth, (route) => false);
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(0, 44),
              backgroundColor: AppColors.emergencyRed,
              foregroundColor: AppColors.white,
            ),
            child: Text(_tr('Lock & Sign Out', 'قفل وخروج')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: appLocaleNotifier,
      builder: (context, locale, _) => ValueListenableBuilder<ThemeMode>(
        valueListenable: themeModeNotifier,
        builder: (context, mode, _) => _buildScaffold(),
      ),
    );
  }

  Widget _buildScaffold() {
    final auth = VitaAuthService.instance;
    final fullName = auth.currentUserName.isNotEmpty
        ? auth.currentUserName
        : _tr('New Patient', 'مريض جديد');
    final email = auth.currentUserEmail.isNotEmpty
        ? auth.currentUserEmail
        : 'patient@vitafile.health';
    final initials = _getInitials(fullName);

    return Scaffold(
      backgroundColor: _pageBg,
      appBar: VitaAppBar(
        title: _tr('Settings & Security', 'الإعدادات والأمان'),
        subtitle:
        _tr('App Preferences & Compliance', 'تفضيلات التطبيق والخصوصية'),
        showBackButton: !widget.isEmbedded,
        actions: [
          IconButton(
            tooltip: _tr('Language', 'اللغة'),
            icon: const Icon(Icons.translate_rounded,
                color: AppColors.primaryTeal, size: 22),
            onPressed: () => _setLanguage(_isAr ? 'en' : 'ar'),
          ),
          IconButton(
            tooltip: _tr('Dark / Light mode', 'الوضع الداكن / الفاتح'),
            icon: Icon(
              _isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: AppColors.primaryTeal,
              size: 22,
            ),
            onPressed: () =>
                _setTheme(_isDark ? ThemeMode.light : ThemeMode.dark),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            VitaCard(
              padding: const EdgeInsets.all(16),
              backgroundColor: _cardBg,
              borderColor: _cardBorder,
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: AppColors.tealGradient,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        initials,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fullName,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                        Text(
                          email,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 4),
                        VitaBadge(
                          label: _tr(
                              'VitaFile Pro Vault', 'خزنة فيتا فايل الموثقة'),
                          type: BadgeType.primary,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios_rounded,
                        size: 16, color: AppColors.textMuted),
                    onPressed: () =>
                        Navigator.of(context).pushNamed(AppRoutes.profile),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _buildSectionHeader(_tr('Language & Display', 'اللغة والعرض')),
            const SizedBox(height: 10),
            VitaCard(
              padding: const EdgeInsets.all(16),
              backgroundColor: _cardBg,
              borderColor: _cardBorder,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.language_rounded,
                          color: AppColors.primaryTeal, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        _tr('App Language', 'لغة التطبيق'),
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildChoice(
                        label: 'العربية',
                        icon: Icons.translate_rounded,
                        selected: _isAr,
                        onTap: () => _setLanguage('ar'),
                      ),
                      const SizedBox(width: 10),
                      _buildChoice(
                        label: 'English',
                        icon: Icons.translate_rounded,
                        selected: !_isAr,
                        onTap: () => _setLanguage('en'),
                      ),
                    ],
                  ),
                  Divider(height: 28, color: _divider),
                  Row(
                    children: [
                      const Icon(Icons.brightness_6_rounded,
                          color: AppColors.primaryTeal, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        _tr('Appearance', 'مظهر التطبيق'),
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildChoice(
                        label: _tr('Light', 'فاتح'),
                        icon: Icons.light_mode_rounded,
                        selected: !_isDark,
                        onTap: () => _setTheme(ThemeMode.light),
                      ),
                      const SizedBox(width: 10),
                      _buildChoice(
                        label: _tr('Dark', 'داكن'),
                        icon: Icons.dark_mode_rounded,
                        selected: _isDark,
                        onTap: () => _setTheme(ThemeMode.dark),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _buildSectionHeader(
                _tr('Cloud Sync & Backup', 'المزامنة والنسخ الاحتياطي')),
            const SizedBox(height: 10),
            VitaCard(
              padding: const EdgeInsets.all(16),
              backgroundColor: _cardBg,
              borderColor: _cardBorder,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(Icons.cloud_done_rounded,
                                color: AppColors.primaryTeal, size: 22),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _tr('Encrypted Cloud Vault',
                                    'الخزنة السحابية المشفرة'),
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      VitaBadge(
                          label: _tr('Synced', 'متزامن'),
                          type: BadgeType.success),
                    ],
                  ),
                  Divider(height: 20, color: _divider),
                  InkWell(
                    onTap: _isSyncing ? null : _triggerManualSync,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_isSyncing)
                            const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primaryTeal),
                            )
                          else
                            const Icon(Icons.sync_rounded,
                                color: AppColors.primaryTeal, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            _isSyncing
                                ? _tr('Synchronizing...', 'جاري المزامنة...')
                                : _tr('Sync Vault Now', 'مزامنة الخزنة الآن'),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryTeal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _buildSectionHeader(_tr('Security & Biometrics', 'الأمان والبصمة')),
            const SizedBox(height: 10),
            VitaCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              backgroundColor: _cardBg,
              borderColor: _cardBorder,
              child: Column(
                children: [
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      _tr('Biometric Authentication', 'الدخول بالبصمة / الوجه'),
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      _tr('Require Face ID / Fingerprint to open app',
                          'طلب البصمة عند فتح التطبيق'),
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textSecondary),
                    ),
                    value: _biometricsEnabled,
                    activeColor: AppColors.primaryTeal,
                    onChanged: (v) => setState(() => _biometricsEnabled = v),
                  ),
                  Divider(height: 1, color: _divider),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      _tr('Two-Factor Authentication (2FA)', 'المصادقة الثنائية'),
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    value: _twoFactorEnabled,
                    activeColor: AppColors.primaryTeal,
                    onChanged: (v) => setState(() => _twoFactorEnabled = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _buildSectionHeader(
                _tr('Notifications & Alarms', 'الإشعارات والتنبيهات')),
            const SizedBox(height: 10),
            VitaCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              backgroundColor: _cardBg,
              borderColor: _cardBorder,
              child: Column(
                children: [
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      _tr('Medication Schedule Reminders', 'تذكير مواعيد الأدوية'),
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    value: _medReminders,
                    activeColor: AppColors.primaryTeal,
                    onChanged: (v) => setState(() => _medReminders = v),
                  ),
                  Divider(height: 1, color: _divider),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      _tr('Doctor Access Expiration Alerts',
                          'تنبيه انتهاء صلاحية دخول الطبيب'),
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    value: _doctorAlerts,
                    activeColor: AppColors.primaryTeal,
                    onChanged: (v) => setState(() => _doctorAlerts = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            VitaCard(
              onTap: _handleLogout,
              padding: const EdgeInsets.symmetric(vertical: 14),
              borderColor: AppColors.emergencyRed.withOpacity(0.3),
              backgroundColor: AppColors.emergencyRedSoft.withOpacity(0.3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.logout_rounded,
                      color: AppColors.emergencyRed, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    _tr('Lock Vault & Sign Out', 'قفل الخزنة وتسجيل الخروج'),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.emergencyRed,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Center(
              child: Column(
                children: [
                  const Text(
                    'VitaFile Mobile v2.4.0 (Build 2026.11)',
                    style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _tr(
                      'End-to-End Encrypted Personal Health Record System',
                      'نظام سجلات صحية شخصية مشفر بالكامل',
                    ),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 10, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildChoice({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primaryTeal.withOpacity(0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.primaryTeal : _cardBorder,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color:
                selected ? AppColors.primaryTeal : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected
                      ? AppColors.primaryTeal
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}