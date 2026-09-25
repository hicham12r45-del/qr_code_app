import 'package:shared_preferences/shared_preferences.dart';
import '../models/qr_item.dart';

/// Handles persistence of QR history using SharedPreferences.
class StorageService {
  static const _historyKey = 'qr_history';

  Future<List<QrItem>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_historyKey);
    final items = QrItem.decodeList(raw);
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  Future<void> saveHistory(List<QrItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_historyKey, QrItem.encodeList(items));
  }

  Future<List<QrItem>> addItem(QrItem item) async {
    final items = await loadHistory();
    items.insert(0, item);
    await saveHistory(items);
    return items;
  }

  Future<List<QrItem>> updateItem(QrItem item) async {
    final items = await loadHistory();
    final idx = items.indexWhere((e) => e.id == item.id);
    if (idx != -1) {
      items[idx] = item;
      await saveHistory(items);
    }
    return items;
  }

  Future<List<QrItem>> deleteItem(String id) async {
    final items = await loadHistory();
    items.removeWhere((e) => e.id == id);
    await saveHistory(items);
    return items;
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }
}
