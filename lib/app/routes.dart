import 'package:get/get.dart';
import '../presentation/auth/login_screen.dart';
import '../presentation/splash/splash_screen.dart';
import '../presentation/layout/main_layout.dart';
import '../presentation/dashboard/dashboard_screen.dart';
import '../presentation/users/users_screen.dart';
import '../presentation/settings/app_settings_screen.dart';
import '../presentation/notifications/notifications_screen.dart';
import '../presentation/iptv/iptv_sources_screen.dart';
import '../presentation/news/news_api_screen.dart';
import '../presentation/content/text_content_screen.dart';
import '../presentation/advanced/advanced_settings_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String main = '/main';
  static const String dashboard = '/dashboard';
  static const String users = '/users';
  static const String settings = '/settings';
  static const String notifications = '/notifications';
  static const String iptv = '/iptv';
  static const String news = '/news';
  static const String content = '/content';
  static const String advanced = '/advanced';

  static final pages = [
    GetPage(name: splash, page: () => const SplashScreen()),
    GetPage(name: login, page: () => const LoginScreen()),
    GetPage(name: main, page: () => const MainLayout()),
    GetPage(name: dashboard, page: () => const DashboardScreen()),
    GetPage(name: users, page: () => const UsersScreen()),
    GetPage(name: settings, page: () => const AppSettingsScreen()),
    GetPage(name: notifications, page: () => const NotificationsScreen()),
    GetPage(name: iptv, page: () => const IptvSourcesScreen()),
    GetPage(name: news, page: () => const NewsApiScreen()),
    GetPage(name: content, page: () => const TextContentScreen()),
    GetPage(name: advanced, page: () => const AdvancedSettingsScreen()),
  ];
}
