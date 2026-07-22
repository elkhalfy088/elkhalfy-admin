import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/database_service.dart';
import '../../core/services/auth_service.dart';

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen>
    with SingleTickerProviderStateMixin {
  final _db = Get.find<DatabaseService>();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('إعدادات التطبيق'),
        backgroundColor: AppColors.surface,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.accent,
          labelColor: AppColors.accent,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: 'عام'),
            Tab(text: 'البانرات'),
            Tab(text: 'الأمان'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _GeneralSettingsTab(db: _db),
          _BannersTab(db: _db),
          _SecurityTab(),
        ],
      ),
    );
  }
}

class _GeneralSettingsTab extends StatelessWidget {
  final DatabaseService db;
  const _GeneralSettingsTab({required this.db});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DatabaseEvent>(
      stream: db.getAppSettings(),
      builder: (context, snapshot) {
        final settings = snapshot.data?.snapshot.value != null
            ? Map<String, dynamic>.from(
                snapshot.data!.snapshot.value as Map)
            : <String, dynamic>{};

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSwitchSetting(
              'وضع الصيانة',
              'تعطيل التطبيق مؤقتاً لجميع المستخدمين',
              Icons.build_circle_rounded,
              settings['maintenanceMode'] == true,
              AppColors.warning,
              (v) => db.updateAppSettings('maintenanceMode', v),
            ),
            _buildSwitchSetting(
              'بانر تيليجرام',
              'إظهار بانر الانضمام لقناة التيليجرام',
              Icons.telegram_rounded,
              settings['showTelegramBanner'] == true,
              AppColors.info,
              (v) => db.updateAppSettings('showTelegramBanner', v),
            ),
            _buildSwitchSetting(
              'تفعيل الاشتراك',
              'تطلب أكواد تفعيل عند فتح التطبيق',
              Icons.verified_user_rounded,
              settings['requireActivation'] ?? true,
              AppColors.success,
              (v) => db.updateAppSettings('requireActivation', v),
            ),
            _buildSwitchSetting(
              'السماح بالتسجيل',
              'السماح للمستخدمين الجدد بالتسجيل',
              Icons.app_registration_rounded,
              settings['allowRegistration'] ?? true,
              AppColors.accent,
              (v) => db.updateAppSettings('allowRegistration', v),
            ),
            const SizedBox(height: 8),
            _buildTextSetting(
              'رابط التيليجرام',
              settings['telegramLink'] ?? '',
              Icons.link_rounded,
              (v) => db.updateAppSettings('telegramLink', v),
            ),
            _buildTextSetting(
              'رابط واتساب الدعم',
              settings['whatsappLink'] ?? '',
              Icons.support_agent_rounded,
              (v) => db.updateAppSettings('whatsappLink', v),
            ),
            _buildTextSetting(
              'الموقع الإلكتروني',
              settings['websiteUrl'] ?? '',
              Icons.language_rounded,
              (v) => db.updateAppSettings('websiteUrl', v),
            ),
            _buildTextSetting(
              'رابط التحديث (APK)',
              settings['updateUrl'] ?? '',
              Icons.system_update_rounded,
              (v) => db.updateAppSettings('updateUrl', v),
            ),
            _buildTextSetting(
              'الإصدار الإجباري',
              settings['minVersion'] ?? '1.0.0',
              Icons.new_releases_rounded,
              (v) => db.updateAppSettings('minVersion', v),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSwitchSetting(String title, String subtitle, IconData icon,
      bool value, Color color, Function(bool) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withAlpha(30),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
                Text(subtitle,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _buildTextSetting(
      String label, String currentValue, IconData icon, Function(String) onSave) {
    final ctrl = TextEditingController(text: currentValue);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.accent, size: 18),
              const SizedBox(width: 8),
              Text(label,
                  style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: ctrl,
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13),
                  textDirection: TextDirection.ltr,
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () async {
                  await onSave(ctrl.text.trim());
                  Get.snackbar('تم', 'تم الحفظ',
                      backgroundColor: AppColors.success,
                      colorText: Colors.white,
                      duration: const Duration(seconds: 1));
                },
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8)),
                child: const Text('حفظ', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BannersTab extends StatelessWidget {
  final DatabaseService db;
  const _BannersTab({required this.db});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DatabaseEvent>(
      stream: db.getBanners(),
      builder: (context, snapshot) {
        final banners = snapshot.data?.snapshot.value != null
            ? (snapshot.data!.snapshot.value as Map).entries.toList()
            : [];

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: () => _addBannerDialog(db),
                icon: const Icon(Icons.add_photo_alternate_rounded),
                label: const Text('إضافة بانر جديد'),
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48)),
              ),
            ),
            Expanded(
              child: banners.isEmpty
                  ? const Center(
                      child: Text('لا توجد بانرات',
                          style:
                              TextStyle(color: AppColors.textSecondary)))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: banners.length,
                      itemBuilder: (_, i) {
                        final key = banners[i].key as String;
                        final data =
                            Map<String, dynamic>.from(banners[i].value as Map);
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: data['imageUrl'] != null
                                  ? Image.network(data['imageUrl'],
                                      width: 60, height: 40, fit: BoxFit.cover)
                                  : const Icon(Icons.image_rounded,
                                      color: AppColors.textMuted),
                            ),
                            title: Text(data['title'] ?? 'بانر',
                                style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 13)),
                            subtitle: Text(data['link'] ?? '',
                                style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 11)),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_rounded,
                                  color: AppColors.error),
                              onPressed: () => db.deleteBanner(key),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  void _addBannerDialog(DatabaseService db) {
    final titleCtrl = TextEditingController();
    final imageCtrl = TextEditingController();
    final linkCtrl = TextEditingController();
    Get.dialog(AlertDialog(
      backgroundColor: AppColors.card,
      title: const Text('إضافة بانر', style: TextStyle(color: AppColors.textPrimary)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: titleCtrl, style: const TextStyle(color: AppColors.textPrimary), decoration: const InputDecoration(labelText: 'العنوان')),
          const SizedBox(height: 12),
          TextField(controller: imageCtrl, style: const TextStyle(color: AppColors.textPrimary), decoration: const InputDecoration(labelText: 'رابط الصورة'), textDirection: TextDirection.ltr),
          const SizedBox(height: 12),
          TextField(controller: linkCtrl, style: const TextStyle(color: AppColors.textPrimary), decoration: const InputDecoration(labelText: 'الرابط عند الضغط'), textDirection: TextDirection.ltr),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('إلغاء', style: TextStyle(color: AppColors.textSecondary))),
        ElevatedButton(
          onPressed: () async {
            await db.addBanner({'title': titleCtrl.text, 'imageUrl': imageCtrl.text, 'link': linkCtrl.text, 'isActive': true});
            Get.back();
          },
          child: const Text('إضافة'),
        ),
      ],
    ));
  }
}

class _SecurityTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthService>();
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.lock_rounded, color: AppColors.accent),
                    SizedBox(width: 8),
                    Text('تغيير كلمة المرور',
                        style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: currentCtrl,
                  obscureText: true,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(labelText: 'كلمة المرور الحالية'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: newCtrl,
                  obscureText: true,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(labelText: 'كلمة المرور الجديدة'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: confirmCtrl,
                  obscureText: true,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(labelText: 'تأكيد كلمة المرور'),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (newCtrl.text != confirmCtrl.text) {
                        Get.snackbar('خطأ', 'كلمات المرور غير متطابقة',
                            backgroundColor: AppColors.error, colorText: Colors.white);
                        return;
                      }
                      if (newCtrl.text.length < 6) {
                        Get.snackbar('خطأ', 'كلمة المرور قصيرة جداً',
                            backgroundColor: AppColors.error, colorText: Colors.white);
                        return;
                      }
                      final success = await auth.changePassword(
                          currentCtrl.text, newCtrl.text);
                      if (success) {
                        Get.snackbar('تم', 'تم تغيير كلمة المرور بنجاح',
                            backgroundColor: AppColors.success, colorText: Colors.white);
                        currentCtrl.clear();
                        newCtrl.clear();
                        confirmCtrl.clear();
                      } else {
                        Get.snackbar('خطأ', auth.errorMessage.value,
                            backgroundColor: AppColors.error, colorText: Colors.white);
                      }
                    },
                    child: const Text('تغيير كلمة المرور'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.info_rounded, color: AppColors.info),
                    SizedBox(width: 8),
                    Text('معلومات الحساب',
                        style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 12),
                Text('البريد الإلكتروني: ${auth.userEmail}',
                    style: const TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                const Text('الدور: مشرف رئيسي',
                    style: TextStyle(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
