import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/database_service.dart';

class NewsApiScreen extends StatefulWidget {
  const NewsApiScreen({super.key});
  @override
  State<NewsApiScreen> createState() => _NewsApiScreenState();
}

class _NewsApiScreenState extends State<NewsApiScreen> {
  final _db = Get.find<DatabaseService>();
  final _fields = <String, TextEditingController>{};
  bool _saving = false;

  final _config = [
    {'key': 'baseUrl', 'label': 'رابط API الأساسي', 'hint': 'https://newsapi.org/v2/', 'ltr': true},
    {'key': 'apiKey', 'label': 'مفتاح API', 'hint': 'your-api-key', 'ltr': true},
    {'key': 'titleField', 'label': 'حقل العنوان', 'hint': 'title', 'ltr': true},
    {'key': 'descriptionField', 'label': 'حقل الوصف', 'hint': 'description', 'ltr': true},
    {'key': 'imageField', 'label': 'حقل الصورة', 'hint': 'urlToImage', 'ltr': true},
    {'key': 'urlField', 'label': 'حقل الرابط الكامل', 'hint': 'url', 'ltr': true},
    {'key': 'dateField', 'label': 'حقل التاريخ', 'hint': 'publishedAt', 'ltr': true},
    {'key': 'pageSize', 'label': 'عدد الأخبار في الصفحة', 'hint': '20', 'ltr': false},
    {'key': 'extraHeaders', 'label': 'هيدرز إضافية (JSON)', 'hint': '{}', 'ltr': true},
    {'key': 'extraParams', 'label': 'معاملات إضافية (JSON)', 'hint': '{}', 'ltr': true},
  ];

  @override
  void initState() {
    super.initState();
    for (final c in _config) {
      _fields[c['key']!] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final c in _fields.values) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('إعدادات API الأخبار'),
        backgroundColor: AppColors.surface,
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: _db.getNewsApiSettings(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
            final data = Map<String, dynamic>.from(
                snapshot.data!.snapshot.value as Map);
            for (final c in _config) {
              final key = c['key']!;
              if (_fields[key]!.text.isEmpty && data[key] != null) {
                _fields[key]!.text = data[key].toString();
              }
            }
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildInfoCard(),
              const SizedBox(height: 16),
              ..._config.map((c) => _buildField(c)),
              const SizedBox(height: 8),
              _buildMethodSelector(snapshot),
              const SizedBox(height: 20),
              _buildSaveButton(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.info.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.info.withAlpha(60)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_rounded, color: AppColors.info),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'اضبط إعدادات API الأخبار وستنطبق على التطبيق فوراً. يمكنك استخدام أي مزود أخبار يدعم REST API.',
              style: TextStyle(color: AppColors.info, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(Map<String, String> c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: _fields[c['key']!],
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
        textDirection: c['ltr'] == true ? TextDirection.ltr : null,
        decoration: InputDecoration(
          labelText: c['label'],
          hintText: c['hint'],
          hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 12),
        ),
      ),
    );
  }

  String _method = 'GET';

  Widget _buildMethodSelector(AsyncSnapshot snapshot) {
    if (snapshot.hasData && snapshot.data?.snapshot.value != null) {
      final data = Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);
      if (data['method'] != null) _method = data['method'];
    }
    return Row(
      children: [
        const Text('نوع الطلب:', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        const SizedBox(width: 16),
        ...['GET', 'POST'].map((m) => GestureDetector(
          onTap: () => setState(() => _method = m),
          child: Container(
            margin: const EdgeInsets.only(left: 8),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: _method == m ? AppColors.accent : AppColors.card,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _method == m ? AppColors.accent : AppColors.border),
            ),
            child: Text(m,
                style: TextStyle(
                    color: _method == m ? Colors.white : AppColors.textSecondary,
                    fontWeight: FontWeight.bold)),
          ),
        )),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: _saving ? null : _save,
        icon: _saving
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Icon(Icons.save_rounded),
        label: Text(_saving ? 'جاري الحفظ...' : 'حفظ الإعدادات'),
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final data = {for (final c in _config) c['key']!: _fields[c['key']!]!.text.trim()};
      data['method'] = _method;
      await _db.updateNewsApiSettings(data);
      Get.snackbar('تم الحفظ', 'تم حفظ إعدادات الأخبار',
          backgroundColor: AppColors.success, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('خطأ', 'فشل الحفظ', backgroundColor: AppColors.error, colorText: Colors.white);
    } finally {
      setState(() => _saving = false);
    }
  }
}
