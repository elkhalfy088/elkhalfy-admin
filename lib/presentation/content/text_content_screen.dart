import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/database_service.dart';

class TextContentScreen extends StatefulWidget {
  const TextContentScreen({super.key});
  @override
  State<TextContentScreen> createState() => _TextContentScreenState();
}

class _TextContentScreenState extends State<TextContentScreen> {
  final _db = Get.find<DatabaseService>();
  final Map<String, TextEditingController> _ctrls = {};

  final _items = [
    {'key': 'welcomeMessage', 'label': 'رسالة الترحيب', 'icon': Icons.waving_hand_rounded, 'multiline': false},
    {'key': 'maintenanceMessage', 'label': 'رسالة وضع الصيانة', 'icon': Icons.build_rounded, 'multiline': true},
    {'key': 'telegramBannerText', 'label': 'نص بانر التيليجرام', 'icon': Icons.telegram_rounded, 'multiline': false},
    {'key': 'activationButtonText', 'label': 'نص زر الحصول على كود التفعيل', 'icon': Icons.key_rounded, 'multiline': false},
    {'key': 'supportText', 'label': 'نص صفحة الدعم الفني', 'icon': Icons.support_agent_rounded, 'multiline': true},
    {'key': 'noConnectionText', 'label': 'نص خطأ الاتصال بالإنترنت', 'icon': Icons.wifi_off_rounded, 'multiline': false},
    {'key': 'emptyStateText', 'label': 'نص الصفحة الفارغة', 'icon': Icons.inbox_rounded, 'multiline': false},
    {'key': 'loadingText', 'label': 'نص شاشة التحميل', 'icon': Icons.hourglass_empty_rounded, 'multiline': false},
    {'key': 'settingsTitle', 'label': 'عنوان صفحة الإعدادات', 'icon': Icons.settings_rounded, 'multiline': false},
    {'key': 'homeTitle', 'label': 'عنوان الصفحة الرئيسية', 'icon': Icons.home_rounded, 'multiline': false},
    {'key': 'footerText', 'label': 'نص التذييل', 'icon': Icons.text_fields_rounded, 'multiline': false},
  ];

  @override
  void initState() {
    super.initState();
    for (final item in _items) {
      _ctrls[item['key'] as String] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final c in _ctrls.values) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('النصوص والمحتوى'),
        backgroundColor: AppColors.surface,
        actions: [
          TextButton.icon(
            onPressed: _saveAll,
            icon: const Icon(Icons.save_rounded, color: AppColors.accent),
            label: const Text('حفظ الكل', style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: _db.getTextContent(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
            final data = Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);
            for (final item in _items) {
              final key = item['key'] as String;
              if (_ctrls[key]!.text.isEmpty && data[key] != null) {
                _ctrls[key]!.text = data[key].toString();
              }
            }
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _items.length,
            itemBuilder: (_, i) => _buildItem(_items[i]),
          );
        },
      ),
    );
  }

  Widget _buildItem(Map<String, Object> item) {
    final key = item['key'] as String;
    final isMultiline = item['multiline'] as bool;
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
              Icon(item['icon'] as IconData, color: AppColors.accent, size: 18),
              const SizedBox(width: 8),
              Text(item['label'] as String,
                  style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: _ctrls[key],
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                  maxLines: isMultiline ? 3 : 1,
                  decoration: const InputDecoration(isDense: true),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _saveOne(key),
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                child: const Text('حفظ', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _saveOne(String key) async {
    await _db.updateTextContent(key, _ctrls[key]!.text.trim());
    Get.snackbar('تم', 'تم الحفظ',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        duration: const Duration(seconds: 1));
  }

  Future<void> _saveAll() async {
    for (final item in _items) {
      final key = item['key'] as String;
      await _db.updateTextContent(key, _ctrls[key]!.text.trim());
    }
    Get.snackbar('تم الحفظ', 'تم حفظ جميع النصوص',
        backgroundColor: AppColors.success, colorText: Colors.white);
  }
}
