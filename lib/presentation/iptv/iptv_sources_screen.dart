import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/database_service.dart';

class IptvSourcesScreen extends StatefulWidget {
  const IptvSourcesScreen({super.key});
  @override
  State<IptvSourcesScreen> createState() => _IptvSourcesScreenState();
}

class _IptvSourcesScreenState extends State<IptvSourcesScreen> {
  final _db = Get.find<DatabaseService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('مصادر IPTV'),
        backgroundColor: AppColors.surface,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddSourceDialog,
        backgroundColor: AppColors.accent,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('إضافة مصدر', style: TextStyle(color: Colors.white)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _db.getIptvSources(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmpty();
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (_, i) {
              final doc = snapshot.data!.docs[i];
              final data = doc.data() as Map<String, dynamic>;
              return _buildSourceCard(doc.id, data);
            },
          );
        },
      ),
    );
  }

  Widget _buildSourceCard(String id, Map<String, dynamic> data) {
    final type = data['type'] ?? 'xtream';
    Color typeColor = AppColors.accent;
    if (type == 'm3u') typeColor = AppColors.success;
    if (type == 'mac') typeColor = AppColors.warning;

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
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: typeColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.live_tv_rounded, color: typeColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data['name'] ?? 'مصدر بدون اسم',
                        style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14)),
                    Text(data['url'] ?? '',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 11),
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: typeColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(type.toUpperCase(),
                    style: TextStyle(
                        color: typeColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          if (type == 'xtream') ...[
            const SizedBox(height: 12),
            const Divider(color: AppColors.border, height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _infoItem('اسم المستخدم', data['username'] ?? '')),
                Expanded(child: _infoItem('كلمة المرور', '••••••')),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showEditDialog(id, data),
                  icon: const Icon(Icons.edit_rounded, size: 16),
                  label: const Text('تعديل', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.accent,
                    side: const BorderSide(color: AppColors.accent),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _deleteSource(id),
                  icon: const Icon(Icons.delete_rounded, size: 16),
                  label: const Text('حذف', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
        Text(value, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      ],
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.live_tv_rounded, size: 64, color: AppColors.textMuted),
          const SizedBox(height: 16),
          const Text('لا توجد مصادر IPTV',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
          const SizedBox(height: 8),
          const Text('اضغط + لإضافة مصدر جديد',
              style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
        ],
      ),
    );
  }

  void _showAddSourceDialog() => _showSourceDialog(null, null);
  void _showEditDialog(String id, Map<String, dynamic> data) => _showSourceDialog(id, data);

  void _showSourceDialog(String? id, Map<String, dynamic>? existing) {
    String type = existing?['type'] ?? 'xtream';
    final nameCtrl = TextEditingController(text: existing?['name'] ?? '');
    final urlCtrl = TextEditingController(text: existing?['url'] ?? '');
    final userCtrl = TextEditingController(text: existing?['username'] ?? '');
    final passCtrl = TextEditingController(text: existing?['password'] ?? '');
    final macCtrl = TextEditingController(text: existing?['mac'] ?? '');

    Get.dialog(StatefulBuilder(builder: (_, ss) {
      return AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(id == null ? 'إضافة مصدر IPTV' : 'تعديل المصدر',
            style: const TextStyle(color: AppColors.textPrimary)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, style: const TextStyle(color: AppColors.textPrimary), decoration: const InputDecoration(labelText: 'اسم المصدر')),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: type,
                dropdownColor: AppColors.card,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(labelText: 'نوع المصدر'),
                items: const [
                  DropdownMenuItem(value: 'xtream', child: Text('Xtream Codes')),
                  DropdownMenuItem(value: 'm3u', child: Text('M3U / M3U8')),
                  DropdownMenuItem(value: 'mac', child: Text('MAC Address')),
                ],
                onChanged: (v) => ss(() => type = v!),
              ),
              const SizedBox(height: 12),
              TextField(controller: urlCtrl, style: const TextStyle(color: AppColors.textPrimary), decoration: InputDecoration(labelText: type == 'm3u' ? 'رابط M3U' : 'رابط الخادم'), textDirection: TextDirection.ltr),
              if (type == 'xtream') ...[
                const SizedBox(height: 12),
                TextField(controller: userCtrl, style: const TextStyle(color: AppColors.textPrimary), decoration: const InputDecoration(labelText: 'اسم المستخدم'), textDirection: TextDirection.ltr),
                const SizedBox(height: 12),
                TextField(controller: passCtrl, obscureText: true, style: const TextStyle(color: AppColors.textPrimary), decoration: const InputDecoration(labelText: 'كلمة المرور'), textDirection: TextDirection.ltr),
              ],
              if (type == 'mac') ...[
                const SizedBox(height: 12),
                TextField(controller: macCtrl, style: const TextStyle(color: AppColors.textPrimary), decoration: const InputDecoration(labelText: 'MAC Address'), textDirection: TextDirection.ltr),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('إلغاء', style: TextStyle(color: AppColors.textSecondary))),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.isEmpty || urlCtrl.text.isEmpty) {
                Get.snackbar('تنبيه', 'يرجى ملء الحقول الإلزامية', backgroundColor: AppColors.warning, colorText: Colors.black);
                return;
              }
              final data = {
                'name': nameCtrl.text.trim(),
                'type': type,
                'url': urlCtrl.text.trim(),
                if (type == 'xtream') 'username': userCtrl.text.trim(),
                if (type == 'xtream') 'password': passCtrl.text.trim(),
                if (type == 'mac') 'mac': macCtrl.text.trim(),
                'isActive': true,
              };
              Get.back();
              if (id == null) {
                await _db.addIptvSource(data);
              } else {
                await _db.updateIptvSource(id, data);
              }
              Get.snackbar('تم', id == null ? 'تمت الإضافة' : 'تم التعديل', backgroundColor: AppColors.success, colorText: Colors.white);
            },
            child: Text(id == null ? 'إضافة' : 'حفظ'),
          ),
        ],
      );
    }));
  }

  void _deleteSource(String id) {
    Get.dialog(AlertDialog(
      backgroundColor: AppColors.card,
      title: const Text('حذف المصدر', style: TextStyle(color: AppColors.textPrimary)),
      content: const Text('هل تريد حذف هذا المصدر؟', style: TextStyle(color: AppColors.textSecondary)),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('إلغاء')),
        ElevatedButton(
          onPressed: () async { Get.back(); await _db.deleteIptvSource(id); },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
          child: const Text('حذف'),
        ),
      ],
    ));
  }
}
