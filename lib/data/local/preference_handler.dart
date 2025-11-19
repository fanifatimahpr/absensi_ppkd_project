import 'dart:convert';
import 'package:flutter_project_ppkd/config/endpoint.dart';
import 'package:flutter_project_ppkd/data/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferenceHandler {
  static const String tokenKey = "user_token";
  static const String userKey = "user_data";
  static const String userName = "user_name";

  // SAVE TOKEN
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
  }

  // GET TOKEN
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  // DELETE TOKEN
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
  }

  // SAVE USER DATA
  static Future<void> saveUserData(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(userKey, jsonEncode(user));
  }

  // GET USER DATA
  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(userKey);
    if (data == null) return null;
    return jsonDecode(data);
  }

  // CLEAR USER DATA
  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(userKey);
  }

  // CHECK LOGIN STATUS
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey) != null;
  }

  // LOGOUT CLEAR ALL
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
    await prefs.remove(userKey);
    await prefs.remove("today_attendance");
  }

  // GET USER NAME
  static Future<String?> getName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(userName);
  }

  // 🔥 SAVE TODAY ATTENDANCE LOCALLY
  static Future<void> saveTodayAttendance(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("today_attendance", jsonEncode(data));
  }

  // 🔥 GET TODAY ATTENDANCE
  static Future<Map<String, dynamic>?> getTodayAttendance() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString("today_attendance");
    if (jsonString == null) return null;
    return jsonDecode(jsonString);
  }

}
