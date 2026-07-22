import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/auth_service.dart';
import '../../app/routes.dart';
import '../layout/main_layout.dart';

class SidebarWidget extends StatelessWidget {
  const SidebarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      decoration: const BoxDecoration(
        color: AppColors.sidebar,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.accentGradient,
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.accent.withAlpha(60),
                          blurRadius: 12,
                          spreadRadius: 2)
                    ],
                  ),
                  child: const Icon(Icons.shield_rounded,
                      color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Elkhalfy',
                        style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                    Text('لوحة التحكم',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),

          // Nav Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              children: [
                _buildSection('الرئيسية'),
                _navItem(Icons.dashboard_rounded, 'لوحة المعلومات', 0),
                const SizedBox(height: 8),
                _buildSection('إدارة'),
                _navItem(Icons.key_rounded, 'أكواد التفعيل', 1),
                _navItem(Icons.notifications_rounded, 'الإشعارات', 2),
                const SizedBox(height: 8),
                _buildSection('التطبيق'),
                _navItem(Icons.settings_rounded, 'إعدادات التطبيق', 3),
                _navItem(Icons.live_tv_rounded, 'مصادر IPTV', 4),
                _navItem(Icons.newspaper_rounded, 'إعدادات الأخبار', 5),
                _navItem(Icons.text_fields_rounded, 'النصوص والمحتوى', 6),
                _navItem(Icons.tune_rounded, 'إعدادات متقدمة', 7),
              ],
            ),
          ),

          // User info & Logout
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.accent.withAlpha(40),
                      ),
                      child: const Icon(Icons.person_rounded,
                          color: AppColors.accent, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        Get.find<AuthService>().userEmail,
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 11),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmLogout(),
                    icon: const Icon(Icons.logout_rounded, size: 16),
                    label: const Text('تسجيل الخروج'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
      child: Text(title,
          style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1)),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    return Obx(() {
      final layout = Get.find<MainLayoutController>();
      final isActive = layout.selectedIndex.value == index;
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: isActive ? AppColors.accent.withAlpha(30) : Colors.transparent,
        ),
        child: ListTile(
          leading: Icon(icon,
              color: isActive ? AppColors.accent : AppColors.sidebarText,
              size: 20),
          title: Text(label,
              style: TextStyle(
                  color: isActive
                      ? AppColors.accent
                      : AppColors.sidebarText,
                  fontSize: 13,
                  fontWeight:
                      isActive ? FontWeight.bold : FontWeight.normal)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          onTap: () => layout.selectedIndex.value = index,
        ),
      );
    });
  }

  void _confirmLogout() {
    Get.dialog(AlertDialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('تسجيل الخروج',
          style: TextStyle(color: AppColors.textPrimary)),
      content: const Text('هل أنت متأكد من تسجيل الخروج؟',
          style: TextStyle(color: AppColors.textSecondary)),
      actions: [
        TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء',
                style: TextStyle(color: AppColors.textSecondary))),
        ElevatedButton(
          onPressed: () {
            Get.back();
            Get.find<AuthService>().signOut();
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
          child: const Text('خروج'),
        ),
      ],
    ));
  }
}
