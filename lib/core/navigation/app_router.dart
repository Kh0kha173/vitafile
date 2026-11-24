import 'package:flutter/material.dart';
import '../../screens/splash_screen.dart';
import '../../screens/onboarding_screen.dart';
import '../../screens/auth_screen.dart';
import '../../screens/main_navigation_shell.dart';
import '../../screens/profile_screen.dart';
import '../../screens/records_screen.dart';
import '../../screens/upload_screen.dart';
import '../../screens/timeline_screen.dart';
import '../../screens/medication_tracker_screen.dart';
import '../../screens/emergency_qr_screen.dart';
import '../../screens/doctor_access_screen.dart';
import '../../screens/settings_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String auth = '/auth';
  static const String mainShell = '/main';
  static const String dashboard = '/dashboard';
  static const String profile = '/profile';
  static const String records = '/records';
  static const String upload = '/upload';
  static const String timeline = '/timeline';
  static const String medications = '/medications';
  static const String emergency = '/emergency';
  static const String doctorAccess = '/doctor-access';
  static const String settings = '/settings';
}

class AppRouter {
  AppRouter._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return _buildPageRoute(const SplashScreen(), settings);
      case AppRoutes.onboarding:
        return _buildPageRoute(const OnboardingScreen(), settings);
      case AppRoutes.auth:
        return _buildPageRoute(const AuthScreen(), settings);
      case AppRoutes.mainShell:
        final initialIndex = settings.arguments as int? ?? 0;
        return _buildPageRoute(MainNavigationShell(initialIndex: initialIndex), settings);
      case AppRoutes.profile:
        return _buildPageRoute(const ProfileScreen(), settings);
      case AppRoutes.records:
        return _buildPageRoute(const RecordsScreen(), settings);
      case AppRoutes.upload:
        return _buildPageRoute(const UploadScreen(), settings);
      case AppRoutes.timeline:
        return _buildPageRoute(const TimelineScreen(), settings);
      case AppRoutes.medications:
        return _buildPageRoute(const MedicationTrackerScreen(), settings);
      case AppRoutes.emergency:
        return _buildPageRoute(const EmergencyQrScreen(), settings);
      case AppRoutes.doctorAccess:
        return _buildPageRoute(const DoctorAccessScreen(), settings);
      case AppRoutes.settings:
        return _buildPageRoute(const SettingsScreen(), settings);
      default:
        return _buildPageRoute(const SplashScreen(), settings);
    }
  }

  static PageRouteBuilder _buildPageRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.05, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var fadeTween = Tween<double>(begin: 0.0, end: 1.0).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(
            opacity: animation.drive(fadeTween),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 280),
    );
  }
}
