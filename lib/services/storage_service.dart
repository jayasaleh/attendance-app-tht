import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/attendance_record.dart';

class StorageService {
  static const _kRecords = 'records';
  static const _kUserName = 'user_name'; // key untuk simpan nama user

  // ===== Attendance Records =====
  Future<List<AttendanceRecord>> getRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kRecords);
    return AttendanceRecord.listFromJsonString(raw);
  }

  Future<void> addRecord(AttendanceRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getRecords();
    list.insert(0, record);
    await prefs.setString(_kRecords, AttendanceRecord.listToJsonString(list));
  }

  Future<void> clearRecords() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kRecords);
  }

  // ===== User Data =====
  Future<void> saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUserName, name);
  }

  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kUserName);
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kUserName);
  }

  Future<bool> hasCheckedInToday() async {
    final records = await getRecords();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    return records.any(
      (r) => DateFormat('yyyy-MM-dd').format(r.timestamp) == today,
    );
  }
}
