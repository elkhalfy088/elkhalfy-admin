import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';

class DatabaseService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseDatabase _rtdb = FirebaseDatabase.instance;

  // =================== ACTIVATION CODES ===================
  CollectionReference get _codesRef => _firestore.collection('activation_codes');

  Stream<QuerySnapshot> getActivationCodes() {
    return _codesRef.orderBy('createdAt', descending: true).snapshots();
  }

  Future<void> addActivationCode(Map<String, dynamic> data) async {
    await _codesRef.add({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
      'isActive': true,
      'usedBy': null,
      'usedAt': null,
    });
  }

  Future<void> updateActivationCode(String id, Map<String, dynamic> data) async {
    await _codesRef.doc(id).update(data);
  }

  Future<void> deleteActivationCode(String id) async {
    await _codesRef.doc(id).delete();
  }

  Future<void> deleteMultipleCodes(List<String> ids) async {
    final batch = _firestore.batch();
    for (final id in ids) {
      batch.delete(_codesRef.doc(id));
    }
    await batch.commit();
  }

  Future<Map<String, int>> getCodesStats() async {
    final snapshot = await _codesRef.get();
    final docs = snapshot.docs;
    int total = docs.length;
    int active = 0, used = 0, expired = 0;
    final now = DateTime.now();
    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final isUsed = data['usedBy'] != null;
      final expiry = data['expiryDate'] != null
          ? (data['expiryDate'] as Timestamp).toDate()
          : null;
      final isExpired = expiry != null && expiry.isBefore(now);
      if (isUsed) {
        used++;
      } else if (isExpired) {
        expired++;
      } else {
        active++;
      }
    }
    return {'total': total, 'active': active, 'used': used, 'expired': expired};
  }

  // =================== APP SETTINGS ===================
  DatabaseReference get _settingsRef => _rtdb.ref('settings');

  Stream<DatabaseEvent> getAppSettings() => _settingsRef.onValue;

  Future<void> updateAppSettings(String key, dynamic value) async {
    await _settingsRef.child(key).set(value);
  }

  Future<void> updateMultipleSettings(Map<String, dynamic> data) async {
    await _settingsRef.update(data);
  }

  // =================== IPTV SOURCES ===================
  CollectionReference get _iptvRef => _firestore.collection('iptv_sources');

  Stream<QuerySnapshot> getIptvSources() => _iptvRef.snapshots();

  Future<void> addIptvSource(Map<String, dynamic> data) async {
    await _iptvRef.add({...data, 'createdAt': FieldValue.serverTimestamp()});
  }

  Future<void> updateIptvSource(String id, Map<String, dynamic> data) async {
    await _iptvRef.doc(id).update(data);
  }

  Future<void> deleteIptvSource(String id) async {
    await _iptvRef.doc(id).delete();
  }

  // =================== NOTIFICATIONS ===================
  CollectionReference get _notifsRef => _firestore.collection('notifications_log');

  Stream<QuerySnapshot> getNotifications() {
    return _notifsRef.orderBy('sentAt', descending: true).limit(50).snapshots();
  }

  Future<void> logNotification(Map<String, dynamic> data) async {
    await _notifsRef.add({...data, 'sentAt': FieldValue.serverTimestamp()});
  }

  // =================== BANNERS ===================
  DatabaseReference get _bannersRef => _rtdb.ref('banners');

  Stream<DatabaseEvent> getBanners() => _bannersRef.onValue;

  Future<void> addBanner(Map<String, dynamic> data) async {
    final newRef = _bannersRef.push();
    await newRef.set({...data, 'id': newRef.key, 'createdAt': ServerValue.timestamp});
  }

  Future<void> deleteBanner(String key) async {
    await _bannersRef.child(key).remove();
  }

  Future<void> updateBanner(String key, Map<String, dynamic> data) async {
    await _bannersRef.child(key).update(data);
  }

  // =================== STATS OVERVIEW ===================
  Future<Map<String, dynamic>> getDashboardStats() async {
    final codesStats = await getCodesStats();
    return {
      'totalCodes': codesStats['total'],
      'activeCodes': codesStats['active'],
      'usedCodes': codesStats['used'],
      'expiredCodes': codesStats['expired'],
    };
  }

  // =================== TEXT CONTENT ===================
  DatabaseReference get _contentRef => _rtdb.ref('text_content');

  Stream<DatabaseEvent> getTextContent() => _contentRef.onValue;

  Future<void> updateTextContent(String key, String value) async {
    await _contentRef.child(key).set(value);
  }

  // =================== ADVANCED SETTINGS ===================
  DatabaseReference get _advancedRef => _rtdb.ref('advanced_settings');

  Stream<DatabaseEvent> getAdvancedSettings() => _advancedRef.onValue;

  Future<void> updateAdvancedSetting(String key, dynamic value) async {
    await _advancedRef.child(key).set(value);
  }

  // =================== NEWS API SETTINGS ===================
  DatabaseReference get _newsRef => _rtdb.ref('news_api');

  Stream<DatabaseEvent> getNewsApiSettings() => _newsRef.onValue;

  Future<void> updateNewsApiSettings(Map<String, dynamic> data) async {
    await _newsRef.update(data);
  }
}
