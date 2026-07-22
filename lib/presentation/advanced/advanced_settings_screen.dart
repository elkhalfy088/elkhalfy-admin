import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/database_service.dart';

class AdvancedSettingsScreen extends StatefulWidget {
  const AdvancedSettingsScreen({super.key});
  @override
  State<AdvancedSettingsScreen> createState() => _AdvancedSettingsScreenState();
}

class _AdvancedSettingsScreenState extends State<AdvancedSettingsScreen>
    with SingleTickerProviderStateMixin {
  final _db = Get.find<DatabaseService>();
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('إعدادات متقدمة'),
        backgroundColor: AppColors.surface,
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: AppColors.accent,
          labelColor: AppColors.accent,
          unselectedLabelColor: AppColors.textSecondary,
          isScrollable: true,
          tabs: const [
            Tab(text: 'الذاكرة المؤقتة'),
            Tab(text: 'التشغيل'),
            Tab(text: 'الأمان'),
            Tab(text: 'الشبكة'),
          ],
        ),
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: _db.getAdvancedSettings(),
        builder: (context, snapshot) {
          final settings = snapshot.data?.snapshot.value != null
              ? Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map)
              : <String, dynamic>{};
          return TabBarView(
            controller: _tabCtrl,
            children: [
              _CacheTab(settings: settings, db: _db),
              _PlaybackTab(settings: settings, db: _db),
              _SecurityTab(settings: settings, db: _db),
              _NetworkTab(settings: settings, db: _db),
            ],
          );
        },
      ),
    );
  }
}

class _CacheTab extends StatelessWidget {
  final Map<String, dynamic> settings;
  final DatabaseService db;
  const _CacheTab({required this.settings, required this.db});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SliderSetting(
          label: 'حجم ذاكرة التخزين المؤقت للصور',
          value: (settings['imageCacheSize'] ?? 200).toDouble(),
          min: 50, max: 1000, divisions: 19,
          unit: 'MB',
          onChanged: (v) => db.updateAdvancedSetting('imageCacheSize', v.round()),
        ),
        _SliderSetting(
          label: 'مدة صلاحية الكاش',
          value: (settings['cacheDuration'] ?? 7).toDouble(),
          min: 1, max: 30, divisions: 29,
          unit: 'يوم',
          onChanged: (v) => db.updateAdvancedSetting('cacheDuration', v.round()),
        ),
        _SwitchSetting(
          label: 'تنظيف الكاش تلقائياً',
          subtitle: 'حذف الكاش المنتهي تلقائياً',
          icon: Icons.auto_delete_rounded,
          value: settings['autoClearCache'] == true,
          onChanged: (v) => db.updateAdvancedSetting('autoClearCache', v),
        ),
        _DropdownSetting(
          label: 'يوم تنظيف الكاش الأسبوعي',
          icon: Icons.calendar_today_rounded,
          value: settings['cacheClearDay']?.toString() ?? '5',
          options: const {'0': 'الأحد', '1': 'الاثنين', '2': 'الثلاثاء', '3': 'الأربعاء', '4': 'الخميس', '5': 'الجمعة', '6': 'السبت'},
          onChanged: (v) => db.updateAdvancedSetting('cacheClearDay', v),
        ),
      ],
    );
  }
}

class _PlaybackTab extends StatelessWidget {
  final Map<String, dynamic> settings;
  final DatabaseService db;
  const _PlaybackTab({required this.settings, required this.db});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _DropdownSetting(
          label: 'جودة الفيديو الافتراضية',
          icon: Icons.hd_rounded,
          value: settings['defaultQuality']?.toString() ?? 'auto',
          options: const {'auto': 'تلقائي', '1080p': '1080p FHD', '720p': '720p HD', '480p': '480p SD', '360p': '360p'},
          onChanged: (v) => db.updateAdvancedSetting('defaultQuality', v),
        ),
        _SwitchSetting(
          label: 'التشغيل التلقائي',
          subtitle: 'تشغيل الفيديو التالي تلقائياً',
          icon: Icons.play_circle_rounded,
          value: settings['autoPlay'] ?? true,
          onChanged: (v) => db.updateAdvancedSetting('autoPlay', v),
        ),
        _SwitchSetting(
          label: 'إعادة المحاولة التلقائية',
          subtitle: 'إعادة الاتصال عند انقطاع البث',
          icon: Icons.refresh_rounded,
          value: settings['autoRetry'] ?? true,
          onChanged: (v) => db.updateAdvancedSetting('autoRetry', v),
        ),
        _SliderSetting(
          label: 'عدد محاولات إعادة الاتصال',
          value: (settings['retryCount'] ?? 3).toDouble(),
          min: 1, max: 10, divisions: 9,
          unit: 'مرات',
          onChanged: (v) => db.updateAdvancedSetting('retryCount', v.round()),
        ),
        _SliderSetting(
          label: 'مهلة الانتظار قبل إعادة المحاولة',
          value: (settings['retryDelay'] ?? 5).toDouble(),
          min: 1, max: 30, divisions: 29,
          unit: 'ثانية',
          onChanged: (v) => db.updateAdvancedSetting('retryDelay', v.round()),
        ),
        _SwitchSetting(
          label: 'دعم Chromecast',
          subtitle: 'السماح ببث المحتوى على التلفاز',
          icon: Icons.cast_rounded,
          value: settings['enableCast'] ?? true,
          onChanged: (v) => db.updateAdvancedSetting('enableCast', v),
        ),
      ],
    );
  }
}

class _SecurityTab extends StatelessWidget {
  final Map<String, dynamic> settings;
  final DatabaseService db;
  const _SecurityTab({required this.settings, required this.db});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SwitchSetting(
          label: 'تشفير الروابط',
          subtitle: 'تشفير روابط البث لمنع المشاركة',
          icon: Icons.lock_rounded,
          value: settings['encryptLinks'] ?? true,
          onChanged: (v) => db.updateAdvancedSetting('encryptLinks', v),
        ),
        _SwitchSetting(
          label: 'تجديد الرابط تلقائياً',
          subtitle: 'تجديد رابط البث عند انتهاء صلاحيته',
          icon: Icons.autorenew_rounded,
          value: settings['autoRenewLinks'] ?? true,
          onChanged: (v) => db.updateAdvancedSetting('autoRenewLinks', v),
        ),
        _SliderSetting(
          label: 'مدة صلاحية الرابط',
          value: (settings['linkExpiry'] ?? 6).toDouble(),
          min: 1, max: 24, divisions: 23,
          unit: 'ساعة',
          onChanged: (v) => db.updateAdvancedSetting('linkExpiry', v.round()),
        ),
        _SwitchSetting(
          label: 'منع لقطات الشاشة',
          subtitle: 'منع تصوير الشاشة داخل التطبيق',
          icon: Icons.screenshot_monitor_rounded,
          value: settings['preventScreenshot'] ?? false,
          onChanged: (v) => db.updateAdvancedSetting('preventScreenshot', v),
        ),
        _SwitchSetting(
          label: 'التحقق من الجهاز',
          subtitle: 'ربط كود التفعيل بجهاز واحد',
          icon: Icons.phone_android_rounded,
          value: settings['deviceBinding'] ?? false,
          onChanged: (v) => db.updateAdvancedSetting('deviceBinding', v),
        ),
      ],
    );
  }
}

class _NetworkTab extends StatelessWidget {
  final Map<String, dynamic> settings;
  final DatabaseService db;
  const _NetworkTab({required this.settings, required this.db});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SliderSetting(
          label: 'مهلة انتظار الاتصال',
          value: (settings['connectionTimeout'] ?? 10).toDouble(),
          min: 5, max: 60, divisions: 11,
          unit: 'ثانية',
          onChanged: (v) => db.updateAdvancedSetting('connectionTimeout', v.round()),
        ),
        _SliderSetting(
          label: 'حجم بافر الفيديو',
          value: (settings['bufferSize'] ?? 30).toDouble(),
          min: 5, max: 120, divisions: 23,
          unit: 'ثانية',
          onChanged: (v) => db.updateAdvancedSetting('bufferSize', v.round()),
        ),
        _SwitchSetting(
          label: 'العمل بدون إنترنت',
          subtitle: 'تفعيل المحتوى المحمّل مسبقاً',
          icon: Icons.wifi_off_rounded,
          value: settings['offlineMode'] ?? true,
          onChanged: (v) => db.updateAdvancedSetting('offlineMode', v),
        ),
        _SwitchSetting(
          label: 'ضغط البيانات',
          subtitle: 'تقليل استهلاك البيانات',
          icon: Icons.compress_rounded,
          value: settings['dataCompression'] ?? false,
          onChanged: (v) => db.updateAdvancedSetting('dataCompression', v),
        ),
        _DropdownSetting(
          label: 'بروتوكول البث المفضّل',
          icon: Icons.stream_rounded,
          value: settings['preferredProtocol']?.toString() ?? 'hls',
          options: const {'hls': 'HLS (m3u8)', 'dash': 'MPEG-DASH', 'rtmp': 'RTMP', 'rtsp': 'RTSP'},
          onChanged: (v) => db.updateAdvancedSetting('preferredProtocol', v),
        ),
      ],
    );
  }
}

// =================== Reusable Widgets ===================

class _SwitchSetting extends StatelessWidget {
  final String label, subtitle;
  final IconData icon;
  final bool value;
  final Function(bool) onChanged;
  const _SwitchSetting({required this.label, required this.subtitle, required this.icon, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accent, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
              Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
            ]),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _SliderSetting extends StatefulWidget {
  final String label, unit;
  final double value, min, max;
  final int divisions;
  final Function(double) onChanged;
  const _SliderSetting({required this.label, required this.value, required this.min, required this.max, required this.divisions, required this.unit, required this.onChanged});

  @override
  State<_SliderSetting> createState() => _SliderSettingState();
}

class _SliderSettingState extends State<_SliderSetting> {
  late double _val;
  @override
  void initState() { super.initState(); _val = widget.value; }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(widget.label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: AppColors.accent.withAlpha(30), borderRadius: BorderRadius.circular(8)),
              child: Text('${_val.round()} ${widget.unit}', style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ]),
          Slider(
            value: _val,
            min: widget.min, max: widget.max, divisions: widget.divisions,
            activeColor: AppColors.accent,
            inactiveColor: AppColors.border,
            onChanged: (v) => setState(() => _val = v),
            onChangeEnd: widget.onChanged,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('${widget.min.round()}', style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
            Text('${widget.max.round()}', style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
          ]),
        ],
      ),
    );
  }
}

class _DropdownSetting extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Map<String, String> options;
  final Function(String) onChanged;
  const _DropdownSetting({required this.label, required this.icon, required this.value, required this.options, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accent, size: 22),
          const SizedBox(width: 14),
          Expanded(child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600))),
          DropdownButton<String>(
            value: options.containsKey(value) ? value : options.keys.first,
            dropdownColor: AppColors.card,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
            underline: const SizedBox(),
            items: options.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
            onChanged: (v) { if (v != null) onChanged(v); },
          ),
        ],
      ),
    );
  }
}
