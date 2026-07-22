import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/database_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _db = Get.find<DatabaseService>();
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  String _target = 'all';
  bool _sending = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('الإشعارات'),
        backgroundColor: AppColors.surface,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSendForm(),
          const SizedBox(height: 24),
          _buildHistory(),
        ],
      ),
    );
  }

  Widget _buildSendForm() {
    return Container(
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
              Icon(Icons.send_rounded, color: AppColors.accent),
              SizedBox(width: 8),
              Text('إرسال إشعار جديد',
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _titleCtrl,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(
              labelText: 'عنوان الإشعار',
              prefixIcon: Icon(Icons.title_rounded, color: AppColors.textMuted),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _bodyCtrl,
            style: const TextStyle(color: AppColors.textPrimary),
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'نص الإشعار',
              alignLabelWithHint: true,
              prefixIcon: Padding(
                padding: EdgeInsets.only(bottom: 60),
                child: Icon(Icons.message_rounded, color: AppColors.textMuted),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('المستهدفون:',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _targetChip('all', 'الكل'),
              _targetChip('active', 'المشتركون النشطون'),
              _targetChip('expired', 'المنتهية اشتراكاتهم'),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _sending ? null : _sendNotification,
              icon: _sending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.send_rounded),
              label: Text(_sending ? 'جاري الإرسال...' : 'إرسال الإشعار'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _targetChip(String value, String label) {
    final isSelected = _target == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.accent,
      backgroundColor: AppColors.surfaceLight,
      labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.textSecondary,
          fontSize: 12),
      onSelected: (_) => setState(() => _target = value),
    );
  }

  Widget _buildHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('سجل الإشعارات',
            style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
        const SizedBox(height: 12),
        StreamBuilder<QuerySnapshot>(
          stream: _db.getNotifications(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Center(
                  child: Text('لا توجد إشعارات مرسلة',
                      style: TextStyle(color: AppColors.textSecondary)),
                ),
              );
            }
            return Column(
              children: snapshot.data!.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final sentAt = data['sentAt'] != null
                    ? (data['sentAt'] as Timestamp).toDate()
                    : DateTime.now();
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withAlpha(30),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.notifications_rounded,
                            color: AppColors.accent, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(data['title'] ?? '',
                                style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13)),
                            const SizedBox(height: 4),
                            Text(data['body'] ?? '',
                                style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12)),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                _buildTargetBadge(data['target'] ?? 'all'),
                                const SizedBox(width: 8),
                                Text(
                                    DateFormat('d/M/yyyy – HH:mm').format(sentAt),
                                    style: const TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 11)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTargetBadge(String target) {
    String label = target == 'all'
        ? 'الكل'
        : target == 'active'
            ? 'النشطون'
            : 'المنتهية';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.accent.withAlpha(30),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: const TextStyle(
              color: AppColors.accent, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Future<void> _sendNotification() async {
    if (_titleCtrl.text.trim().isEmpty || _bodyCtrl.text.trim().isEmpty) {
      Get.snackbar('تنبيه', 'يرجى ملء جميع الحقول',
          backgroundColor: AppColors.warning, colorText: Colors.black);
      return;
    }
    setState(() => _sending = true);
    try {
      // Log the notification
      await _db.logNotification({
        'title': _titleCtrl.text.trim(),
        'body': _bodyCtrl.text.trim(),
        'target': _target,
        'status': 'sent',
      });
      // Note: Actual FCM sending requires a backend (Cloud Functions)
      // This saves to Firestore which triggers Cloud Functions
      Get.snackbar('تم الإرسال', 'تم إرسال الإشعار بنجاح',
          backgroundColor: AppColors.success, colorText: Colors.white);
      _titleCtrl.clear();
      _bodyCtrl.clear();
    } catch (e) {
      Get.snackbar('خطأ', 'حدث خطأ أثناء الإرسال',
          backgroundColor: AppColors.error, colorText: Colors.white);
    } finally {
      setState(() => _sending = false);
    }
  }
}
