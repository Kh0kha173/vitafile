import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/navigation/app_router.dart';
import '../widgets/vita_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingItem> _pages = const [
    _OnboardingItem(
      title: 'Unified Digital Health Vault',
      subtitle: 'Consolidate all your medical records, laboratory tests, prescriptions, and radiology scans into one military-grade encrypted hub.',
      icon: Icons.folder_shared_rounded,
      tag: 'Complete Medical History',
      accentColor: AppColors.primaryTeal,
      highlightBadge: 'Zero Data Loss',
    ),
    _OnboardingItem(
      title: 'Life-Saving Emergency Pass',
      subtitle: 'First responders can scan your emergency QR pass directly from your phone to immediately detect critical allergies, blood group, and ICE contacts.',
      icon: Icons.qr_code_scanner_rounded,
      tag: 'Critical Care Protocol',
      accentColor: AppColors.emergencyRed,
      highlightBadge: 'Instant 1-Tap Access',
    ),
    _OnboardingItem(
      title: 'Granular Doctor Access',
      subtitle: 'Share temporary, encrypted access with specialists and hospitals using time-limited PINs. Revoke permissions at any moment with real-time audit logs.',
      icon: Icons.admin_panel_settings_rounded,
      tag: 'Patient-First Privacy',
      accentColor: AppColors.medicalBlue,
      highlightBadge: 'HIPAA & GDPR Compliant',
    ),
  ];

  void _onNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).pushReplacementNamed(AppRoutes.auth);
    }
  }

  void _onSkip() {
    Navigator.of(context).pushReplacementNamed(AppRoutes.auth);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _onSkip,
            child: const Text(
              'Skip',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final item = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 290,
                          decoration: BoxDecoration(
                            color: item.accentColor.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: item.accentColor.withOpacity(0.15),
                              width: 1.5,
                            ),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Positioned(
                                top: 20,
                                right: 20,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.04),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.verified_rounded, size: 14, color: item.accentColor),
                                      const SizedBox(width: 4),
                                      Text(
                                        item.highlightBadge,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: item.accentColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                width: 130,
                                height: 130,
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: item.accentColor.withOpacity(0.18),
                                      blurRadius: 24,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  item.icon,
                                  size: 64,
                                  color: item.accentColor,
                                ),
                              ),
                              Positioned(
                                bottom: 20,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.white.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    item.tag,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 36),
                        Text(
                          item.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          item.subtitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Bottom control bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  // Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppColors.primaryTeal
                              : AppColors.cardBorder,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  VitaButton(
                    label: _currentPage == _pages.length - 1 ? 'Get Started' : 'Continue',
                    icon: _currentPage == _pages.length - 1
                        ? Icons.check_circle_outline_rounded
                        : Icons.arrow_forward_rounded,
                    onPressed: _onNext,
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

class _OnboardingItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final String tag;
  final Color accentColor;
  final String highlightBadge;

  const _OnboardingItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.tag,
    required this.accentColor,
    required this.highlightBadge,
  });
}
