import 'dart:convert';
import 'package:flutter_project_ppkd/data/models/attendance_model.dart';
import 'package:http/http.dart' as http;

class AbsensiApi {
  final String baseUrl = "https://yourdomain.com/api"; // ganti sendiri

  Future<AttendanceTodayModel?> getAbsensiToday(String token) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/absensi/today"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        return attendanceTodayModelFromJson(response.body);
      }
      return null;
    } catch (e) {
      print("Error getAbsensiToday: $e");
      return null;
    }
  }
}
