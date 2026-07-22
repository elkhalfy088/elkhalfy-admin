import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/database_service.dart';
import '../widgets/stat_card.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final _db = Get.find<DatabaseService>();
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String _filterStatus = 'الكل';
  final List<String> _selectedIds = [];
  bool _selectMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('أكواد التفعيل'),
        backgroundColor: AppColors.surface,
        actions: [
          if (_selectMode) ...[
            IconButton(
              icon: const Icon(Icons.delete_rounded, color: AppColors.error),
              onPressed: _selectedIds.isEmpty ? null : _deleteSelected,
              tooltip: 'حذف المحدد',
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () => setState(() {
                _selectMode = false;
                _selectedIds.clear();
              }),
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.checklist_rounded),
              onPressed: () => setState(() => _selectMode = true),
              tooltip: 'تحديد متعدد',
            ),
            IconButton(
              icon: const Icon(Icons.file_download_rounded),
              onPressed: _exportCodes,
              tooltip: 'تصدير',
            ),
          ],
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddCodeDialog,
        backgroundColor: AppColors.accent,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('إضافة كود', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(),
          Expanded(child: _buildCodesList()),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.surface,
      child: Column(
        children: [
          TextField(
            controller: _searchCtrl,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'البحث في الأكواد...',
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, color: AppColors.textMuted),
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() => _searchQuery = '');
                      })
                  : null,
            ),
            onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['الكل', 'نشط', 'مستخدم', 'منتهي'].map((f) {
                final isSelected = _filterStatus == f;
                return GestureDetector(
                  onTap: () => setState(() => _filterStatus = f),
                  child: Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.accent : AppColors.card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: isSelected ? AppColors.accent : AppColors.border),
                    ),
                    child: Text(f,
                        style: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodesList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _db.getActivationCodes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.accent));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmpty();
        }

        var docs = snapshot.data!.docs;
        final now = DateTime.now();

        // Filter
        docs = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final code = (data['code'] ?? '').toString().toLowerCase();
          final matchSearch = _searchQuery.isEmpty || code.contains(_searchQuery);

          final isUsed = data['usedBy'] != null;
          final expiry = data['expiryDate'] != null
              ? (data['expiryDate'] as Timestamp).toDate()
              : null;
          final isExpired = expiry != null && expiry.isBefore(now);

          bool matchFilter = true;
          if (_filterStatus == 'نشط') matchFilter = !isUsed && !isExpired;
          if (_filterStatus == 'مستخدم') matchFilter = isUsed;
          if (_filterStatus == 'منتهي') matchFilter = isExpired && !isUsed;

          return matchSearch && matchFilter;
        }).toList();

        if (docs.isEmpty) {
          return const Center(
              child: Text('لا توجد نتائج',
                  style: TextStyle(color: AppColors.textSecondary)));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (_, i) {
            final doc = docs[i];
            final data = doc.data() as Map<String, dynamic>;
            return _buildCodeCard(doc.id, data, now);
          },
        );
      },
    );
  }

  Widget _buildCodeCard(String id, Map<String, dynamic> data, DateTime now) {
    final isUsed = data['usedBy'] != null;
    final expiry = data['expiryDate'] != null
        ? (data['expiryDate'] as Timestamp).toDate()
        : null;
    final isExpired = expiry != null && expiry.isBefore(now);
    final isSelected = _selectedIds.contains(id);

    Color statusColor = AppColors.success;
    String statusText = 'نشط';
    if (isUsed) {
      statusColor = AppColors.info;
      statusText = 'مستخدم';
    } else if (isExpired) {
      statusColor = AppColors.error;
      statusText = 'منتهي';
    }

    return GestureDetector(
      onLongPress: () => setState(() {
        _selectMode = true;
        _toggleSelect(id);
      }),
      onTap: () {
        if (_selectMode) {
          _toggleSelect(id);
        } else {
          _showCodeDetails(id, data);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent.withAlpha(20) : AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: isSelected ? AppColors.accent : AppColors.border),
        ),
        child: Row(
          children: [
            if (_selectMode)
              Checkbox(
                value: isSelected,
                onChanged: (_) => _toggleSelect(id),
                activeColor: AppColors.accent,
              ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: statusColor.withAlpha(30),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.key_rounded, color: statusColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(data['code'] ?? '',
                            style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                                fontSize: 14)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy_rounded,
                            color: AppColors.textMuted, size: 16),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: data['code'] ?? ''));
                          Get.snackbar('تم النسخ', 'تم نسخ الكود',
                              backgroundColor: AppColors.success,
                              colorText: Colors.white,
                              duration: const Duration(seconds: 1));
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _badge(data['plan'] ?? 'غير محدد', AppColors.accent),
                      const SizedBox(width: 6),
                      if (expiry != null)
                        _badge(
                            'ينتهي: ${DateFormat('d/M/yyyy').format(expiry)}',
                            isExpired ? AppColors.error : AppColors.textMuted),
                    ],
                  ),
                  if (isUsed && data['usedBy'] != null) ...[
                    const SizedBox(height: 4),
                    Text('مستخدم من: ${data['usedBy']}',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 11)),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(30),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(statusText,
                      style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 8),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded,
                      color: AppColors.textMuted, size: 18),
                  color: AppColors.card,
                  onSelected: (v) {
                    if (v == 'delete') _deleteCode(id);
                    if (v == 'edit') _showEditDialog(id, data);
                    if (v == 'copy') {
                      Clipboard.setData(ClipboardData(text: data['code'] ?? ''));
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                        value: 'copy',
                        child: Row(children: [
                          Icon(Icons.copy_rounded, size: 16),
                          SizedBox(width: 8),
                          Text('نسخ')
                        ])),
                    const PopupMenuItem(
                        value: 'edit',
                        child: Row(children: [
                          Icon(Icons.edit_rounded, size: 16),
                          SizedBox(width: 8),
                          Text('تعديل')
                        ])),
                    const PopupMenuItem(
                        value: 'delete',
                        child: Row(children: [
                          Icon(Icons.delete_rounded,
                              size: 16, color: AppColors.error),
                          SizedBox(width: 8),
                          Text('حذف', style: TextStyle(color: AppColors.error))
                        ])),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text,
          style: TextStyle(
              color: color, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.key_off_rounded, size: 64, color: AppColors.textMuted),
          const SizedBox(height: 16),
          const Text('لا توجد أكواد تفعيل',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
          const SizedBox(height: 8),
          const Text('اضغط + لإضافة كود جديد',
              style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
        ],
      ),
    );
  }

  void _toggleSelect(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
      if (_selectedIds.isEmpty) _selectMode = false;
    });
  }

  void _showAddCodeDialog() {
    final codeCtrl = TextEditingController(
        text: const Uuid().v4().replaceAll('-', '').substring(0, 16).toUpperCase());
    final planCtrl = TextEditingController();
    DateTime? expiry;
    int quantity = 1;

    Get.dialog(StatefulBuilder(builder: (_, setState) {
      return AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('إضافة كود تفعيل',
            style: TextStyle(color: AppColors.textPrimary)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: codeCtrl,
                style: const TextStyle(
                    color: AppColors.textPrimary, fontFamily: 'monospace'),
                decoration: InputDecoration(
                  labelText: 'الكود',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.refresh_rounded),
                    onPressed: () {
                      codeCtrl.text = const Uuid()
                          .v4()
                          .replaceAll('-', '')
                          .substring(0, 16)
                          .toUpperCase();
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: planCtrl,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(labelText: 'الخطة (مثال: شهري، سنوي)'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('الكمية:', style: TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: () => setState(() => quantity = (quantity - 1).clamp(1, 100)),
                    icon: const Icon(Icons.remove_circle_rounded, color: AppColors.error),
                  ),
                  Text('$quantity', style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                    onPressed: () => setState(() => quantity = (quantity + 1).clamp(1, 100)),
                    icon: const Icon(Icons.add_circle_rounded, color: AppColors.success),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  expiry == null
                      ? 'تاريخ الانتهاء (اختياري)'
                      : 'ينتهي: ${DateFormat('d/M/yyyy').format(expiry!)}',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                ),
                trailing: const Icon(Icons.calendar_today_rounded, color: AppColors.accent),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: Get.context!,
                    initialDate: DateTime.now().add(const Duration(days: 30)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 3650)),
                    builder: (ctx, child) => Theme(
                      data: ThemeData.dark().copyWith(
                        colorScheme: const ColorScheme.dark(primary: AppColors.accent),
                      ),
                      child: child!,
                    ),
                  );
                  if (picked != null) setState(() => expiry = picked);
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Get.back(),
              child: const Text('إلغاء',
                  style: TextStyle(color: AppColors.textSecondary))),
          ElevatedButton(
            onPressed: () async {
              if (codeCtrl.text.isEmpty) return;
              Get.back();
              for (int i = 0; i < quantity; i++) {
                final code = quantity == 1
                    ? codeCtrl.text.trim()
                    : const Uuid()
                        .v4()
                        .replaceAll('-', '')
                        .substring(0, 16)
                        .toUpperCase();
                await _db.addActivationCode({
                  'code': code,
                  'plan': planCtrl.text.trim().isNotEmpty
                      ? planCtrl.text.trim()
                      : 'غير محدد',
                  'expiryDate': expiry != null ? Timestamp.fromDate(expiry!) : null,
                });
              }
              Get.snackbar('تم', 'تم إضافة $quantity كود بنجاح',
                  backgroundColor: AppColors.success, colorText: Colors.white);
            },
            child: const Text('إضافة'),
          ),
        ],
      );
    }));
  }

  void _showEditDialog(String id, Map<String, dynamic> data) {
    final planCtrl = TextEditingController(text: data['plan'] ?? '');
    DateTime? expiry = data['expiryDate'] != null
        ? (data['expiryDate'] as Timestamp).toDate()
        : null;
    Get.dialog(StatefulBuilder(builder: (_, ss) {
      return AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('تعديل الكود',
            style: TextStyle(color: AppColors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(data['code'] ?? '',
                style: const TextStyle(
                    color: AppColors.accent,
                    fontFamily: 'monospace',
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextFormField(
              controller: planCtrl,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(labelText: 'الخطة'),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                expiry == null ? 'تاريخ الانتهاء' : DateFormat('d/M/yyyy').format(expiry!),
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              trailing: const Icon(Icons.calendar_today_rounded, color: AppColors.accent),
              onTap: () async {
                final picked = await showDatePicker(
                  context: Get.context!,
                  initialDate: expiry ?? DateTime.now().add(const Duration(days: 30)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 3650)),
                  builder: (ctx, child) => Theme(
                    data: ThemeData.dark().copyWith(colorScheme: const ColorScheme.dark(primary: AppColors.accent)),
                    child: child!,
                  ),
                );
                if (picked != null) ss(() => expiry = picked);
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('إلغاء', style: TextStyle(color: AppColors.textSecondary))),
          ElevatedButton(
            onPressed: () async {
              await _db.updateActivationCode(id, {
                'plan': planCtrl.text.trim(),
                if (expiry != null) 'expiryDate': Timestamp.fromDate(expiry!),
              });
              Get.back();
              Get.snackbar('تم', 'تم التعديل بنجاح', backgroundColor: AppColors.success, colorText: Colors.white);
            },
            child: const Text('حفظ'),
          ),
        ],
      );
    }));
  }

  void _showCodeDetails(String id, Map<String, dynamic> data) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Text(data['code'] ?? '', style: const TextStyle(color: AppColors.accent, fontFamily: 'monospace', fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            InfoRow(label: 'الخطة', value: data['plan'] ?? 'غير محدد'),
            InfoRow(label: 'الحالة', value: data['usedBy'] != null ? 'مستخدم' : 'نشط'),
            if (data['usedBy'] != null) InfoRow(label: 'مستخدم من', value: data['usedBy']),
            if (data['expiryDate'] != null) InfoRow(label: 'تاريخ الانتهاء', value: DateFormat('d/M/yyyy').format((data['expiryDate'] as Timestamp).toDate())),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () { Get.back(); _deleteCode(id); },
                    icon: const Icon(Icons.delete_rounded, color: AppColors.error, size: 16),
                    label: const Text('حذف', style: TextStyle(color: AppColors.error)),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.error)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: data['code'] ?? ''));
                      Get.back();
                      Get.snackbar('تم النسخ', '', backgroundColor: AppColors.success, colorText: Colors.white, duration: const Duration(seconds: 1));
                    },
                    icon: const Icon(Icons.copy_rounded, size: 16),
                    label: const Text('نسخ'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
    );
  }

  void _deleteCode(String id) {
    Get.dialog(AlertDialog(
      backgroundColor: AppColors.card,
      title: const Text('حذف الكود', style: TextStyle(color: AppColors.textPrimary)),
      content: const Text('هل تريد حذف هذا الكود؟', style: TextStyle(color: AppColors.textSecondary)),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('إلغاء')),
        ElevatedButton(
          onPressed: () async {
            Get.back();
            await _db.deleteActivationCode(id);
            Get.snackbar('تم', 'تم الحذف', backgroundColor: AppColors.error, colorText: Colors.white);
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
          child: const Text('حذف'),
        ),
      ],
    ));
  }

  void _deleteSelected() {
    Get.dialog(AlertDialog(
      backgroundColor: AppColors.card,
      title: const Text('حذف المحدد', style: TextStyle(color: AppColors.textPrimary)),
      content: Text('سيتم حذف ${_selectedIds.length} كود. هل أنت متأكد؟', style: const TextStyle(color: AppColors.textSecondary)),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('إلغاء')),
        ElevatedButton(
          onPressed: () async {
            Get.back();
            await _db.deleteMultipleCodes(List.from(_selectedIds));
            setState(() { _selectedIds.clear(); _selectMode = false; });
            Get.snackbar('تم', 'تم الحذف بنجاح', backgroundColor: AppColors.error, colorText: Colors.white);
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
          child: const Text('حذف الكل'),
        ),
      ],
    ));
  }

  void _exportCodes() {
    Get.snackbar('تصدير', 'جاري تصدير الأكواد...',
        backgroundColor: AppColors.info, colorText: Colors.white);
  }
}
