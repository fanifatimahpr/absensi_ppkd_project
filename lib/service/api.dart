import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthAPI {
  final String baseUrl = "https://appabsensi.mobileprojp.com/api";

  // REGISTER
  Future<bool> register(Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/register');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      final token = jsonDecode(response.body)['token'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", token);
      return true;
    }
    return false;
  }

  // LOGIN
  Future<bool> login(String email, String password) async {
  final url = Uri.parse('$baseUrl/login');
  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "email": email,
      "password": password,
    }),
  );

  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);

    // Pastikan ambil token dari `data`
    final token = json['data']['token'];

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", token);

    return true;
  }
  return false;
  }

  Future<Map<String, dynamic>> getTrainings() async {
    final url = Uri.parse("$baseUrl/trainings");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body); // return MAP, bukan LIST
    }
    return {"data": []};
  }

  Future<Map<String, dynamic>> getBatches() async {
    final url = Uri.parse("$baseUrl/batches");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return {"data": []};
  }

}
