import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/database_service.dart';
import '../../core/services/auth_service.dart';
import '../widgets/stat_card.dart';
import '../layout/main_layout.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _db = Get.find<DatabaseService>();
  Map<String, dynamic> _stats = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _loading = true);
    _stats = await _db.getDashboardStats();
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _loadStats,
        color: AppColors.accent,
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.accent))
            : ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildWelcome(),
                  const SizedBox(height: 24),
                  _buildStatsGrid(),
                  const SizedBox(height: 24),
                  _buildQuickActions(),
                  const SizedBox(height: 24),
                  _buildRecentActivity(),
                ],
              ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      title: const Text('لوحة المعلومات'),
      leading: Builder(
        builder: (ctx) => IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: () {
            try {
              Scaffold.of(ctx).openDrawer();
            } catch (_) {}
          },
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded),
          onPressed: _loadStats,
          tooltip: 'تحديث',
        ),
        IconButton(
          icon: const Icon(Icons.logout_rounded, color: AppColors.error),
          onPressed: () => Get.find<AuthService>().signOut(),
          tooltip: 'خروج',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildWelcome() {
    final hour = DateTime.now().hour;
    String greeting = hour < 12
        ? 'صباح الخير'
        : hour < 17
            ? 'مساء الخير'
            : 'مساء النور';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.accentGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: AppColors.accent.withAlpha(60),
              blurRadius: 20,
              offset: const Offset(0, 8))
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.waving_hand_rounded, color: Colors.white, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$greeting، مشرف Elkhalfy',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                    'اليوم: ${DateFormat('EEEE، d MMMM yyyy', 'ar').format(DateTime.now())}',
                    style: TextStyle(
                        color: Colors.white.withAlpha(200), fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    final stats = [
      {
        'title': 'إجمالي الأكواد',
        'value': '${_stats['totalCodes'] ?? 0}',
        'icon': Icons.key_rounded,
        'gradient': AppColors.infoGradient,
      },
      {
        'title': 'أكواد نشطة',
        'value': '${_stats['activeCodes'] ?? 0}',
        'icon': Icons.check_circle_rounded,
        'gradient': AppColors.successGradient,
      },
      {
        'title': 'أكواد مستخدمة',
        'value': '${_stats['usedCodes'] ?? 0}',
        'icon': Icons.person_rounded,
        'gradient': AppColors.accentGradient,
      },
      {
        'title': 'أكواد منتهية',
        'value': '${_stats['expiredCodes'] ?? 0}',
        'icon': Icons.timer_off_rounded,
        'gradient': AppColors.errorGradient,
      },
    ];

    return LayoutBuilder(builder: (context, constraints) {
      final isWide = constraints.maxWidth > 600;
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isWide ? 4 : 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: isWide ? 1.4 : 1.2,
        ),
        itemCount: stats.length,
        itemBuilder: (_, i) => StatCard(
          title: stats[i]['title'] as String,
          value: stats[i]['value'] as String,
          icon: stats[i]['icon'] as IconData,
          gradient: stats[i]['gradient'] as LinearGradient,
        ),
      );
    });
  }

  Widget _buildQuickActions() {
    final ctrl = Get.find<MainLayoutController>();
    final actions = [
      {'label': 'إضافة كود', 'icon': Icons.add_circle_rounded, 'index': 1, 'color': AppColors.success},
      {'label': 'إرسال إشعار', 'icon': Icons.send_rounded, 'index': 2, 'color': AppColors.accent},
      {'label': 'الإعدادات', 'icon': Icons.settings_rounded, 'index': 3, 'color': AppColors.warning},
      {'label': 'IPTV', 'icon': Icons.live_tv_rounded, 'index': 4, 'color': AppColors.info},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'إجراءات سريعة'),
        const SizedBox(height: 12),
        Row(
          children: actions.map((a) => Expanded(
            child: GestureDetector(
              onTap: () => ctrl.selectedIndex.value = a['index'] as int,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: (a['color'] as Color).withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: (a['color'] as Color).withAlpha(60)),
                ),
                child: Column(
                  children: [
                    Icon(a['icon'] as IconData,
                        color: a['color'] as Color, size: 24),
                    const SizedBox(height: 6),
                    Text(a['label'] as String,
                        style: TextStyle(
                            color: a['color'] as Color,
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    return StreamBuilder(
      stream: Get.find<DatabaseService>().getActivationCodes(),
      builder: (context, snapshot) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: 'آخر الأكواد المضافة'),
            const SizedBox(height: 12),
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Center(
                  child: Text('لا توجد أكواد حتى الآن',
                      style: TextStyle(color: AppColors.textSecondary)),
                ),
              )
            else
              ...snapshot.data!.docs.take(5).map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final isUsed = data['usedBy'] != null;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: (isUsed ? AppColors.success : AppColors.accent)
                              .withAlpha(30),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.key_rounded,
                            color: isUsed
                                ? AppColors.success
                                : AppColors.accent,
                            size: 16),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(data['code'] ?? '',
                                style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'monospace',
                                    fontSize: 13)),
                            Text(data['plan'] ?? 'غير محدد',
                                style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 11)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: (isUsed ? AppColors.success : AppColors.accent)
                              .withAlpha(30),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(isUsed ? 'مستخدم' : 'نشط',
                            style: TextStyle(
                                color: isUsed
                                    ? AppColors.success
                                    : AppColors.accent,
                                fontSize: 10,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                );
              }),
          ],
        );
      },
    );
  }
}
