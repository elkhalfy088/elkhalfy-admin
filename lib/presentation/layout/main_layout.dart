import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../widgets/sidebar_widget.dart';
import '../dashboard/dashboard_screen.dart';
import '../users/users_screen.dart';
import '../notifications/notifications_screen.dart';
import '../settings/app_settings_screen.dart';
import '../iptv/iptv_sources_screen.dart';
import '../news/news_api_screen.dart';
import '../content/text_content_screen.dart';
import '../advanced/advanced_settings_screen.dart';

class MainLayoutController extends GetxController {
  final RxInt selectedIndex = 0.obs;
}

class MainLayout extends StatelessWidget {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(MainLayoutController());
    final ctrl = Get.find<MainLayoutController>();
    final screens = [
      const DashboardScreen(),
      const UsersScreen(),
      const NotificationsScreen(),
      const AppSettingsScreen(),
      const IptvSourcesScreen(),
      const NewsApiScreen(),
      const TextContentScreen(),
      const AdvancedSettingsScreen(),
    ];

    final labels = [
      'لوحة المعلومات',
      'أكواد التفعيل',
      'الإشعارات',
      'إعدادات التطبيق',
      'مصادر IPTV',
      'إعدادات الأخبار',
      'النصوص',
      'إعدادات متقدمة',
    ];

    final icons = [
      Icons.dashboard_rounded,
      Icons.key_rounded,
      Icons.notifications_rounded,
      Icons.settings_rounded,
      Icons.live_tv_rounded,
      Icons.newspaper_rounded,
      Icons.text_fields_rounded,
      Icons.tune_rounded,
    ];

    return Scaffold(
      body: LayoutBuilder(builder: (context, constraints) {
        final isWide = constraints.maxWidth > 800;
        if (isWide) {
          // Desktop layout with sidebar
          return Row(
            children: [
              const SidebarWidget(),
              Expanded(
                child: Obx(() => screens[ctrl.selectedIndex.value]),
              ),
            ],
          );
        } else {
          // Mobile layout with bottom nav
          return Obx(() => Scaffold(
                backgroundColor: AppColors.background,
                body: screens[ctrl.selectedIndex.value],
                drawer: const Drawer(
                  backgroundColor: AppColors.sidebar,
                  child: SidebarWidget(),
                ),
                bottomNavigationBar: _buildBottomNav(ctrl, icons, labels),
              ));
        }
      }),
    );
  }

  Widget _buildBottomNav(
      MainLayoutController ctrl, List<IconData> icons, List<String> labels) {
    // Show only first 4 items + more
    return Obx(() => BottomNavigationBar(
          currentIndex: ctrl.selectedIndex.value > 3 ? 3 : ctrl.selectedIndex.value,
          onTap: (i) {
            if (i < 3) ctrl.selectedIndex.value = i;
          },
          backgroundColor: AppColors.sidebar,
          selectedItemColor: AppColors.accent,
          unselectedItemColor: AppColors.textMuted,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 11),
          items: [
            BottomNavigationBarItem(icon: Icon(icons[0]), label: labels[0]),
            BottomNavigationBarItem(icon: Icon(icons[1]), label: labels[1]),
            BottomNavigationBarItem(icon: Icon(icons[2]), label: labels[2]),
            BottomNavigationBarItem(
                icon: GestureDetector(
                  onTap: () => Scaffold.of(Get.context!).openDrawer(),
                  child: const Icon(Icons.menu_rounded),
                ),
                label: 'المزيد'),
          ],
        ));
  }
}
