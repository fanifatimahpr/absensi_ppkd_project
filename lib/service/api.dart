import 'dart:convert';
import 'package:flutter_project_ppkd/config/endpoint.dart';
import 'package:flutter_project_ppkd/data/models/user_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthAPI {
  final String baseUrl = "https://appabsensi.mobileprojp.com/api";

  // REGISTER
  static Future<UserModel> register(Map<String, dynamic> data) async {
  final url = Uri.parse(Endpoint.register);

  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json", "Accept": "application/json"},
    body: jsonEncode(data),
  );

  print("RAW RESPONSE: ${response.body}"); // Debug

  // Jika server tidak return JSON (biasanya HTML error)
  bool isJson;
  try {
    jsonDecode(response.body);
    isJson = true;
  } catch (_) {
    isJson = false;
  }

  if (!isJson) {
    throw Exception(
      "Server tidak mengembalikan JSON.\n"
      "Kemungkinan URL salah: ${Endpoint.register}\n"
      "Response: ${response.body}",
    );
  }

  final json = jsonDecode(response.body);

  // Jika status code 200 → simpan token
  if (response.statusCode == 200 && json['token'] != null) {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", json['token']);
  }

  return UserModel.fromJson(json);
}

  // LOGIN
  static Future<UserModel> login(String email, String password) async {
  // final url = Uri.parse('$baseUrl/login');
  // final response = await http.post(
  //   url,
  //   headers: {"Content-Type": "application/json"},
  //   body: jsonEncode({
  //     "email": email,
  //     "password": password,
  //   }),
  // );

  // if (response.statusCode == 200) {
  //   final json = jsonDecode(response.body);

  //   // Pastikan ambil token dari `data`
  //   final token = json['data']['token'];

  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.setString("token", token);

  //   return true;
  // }
  // return false;
  final url = Uri.parse(Endpoint.login);

  final response = await http.post(
    url,
    headers: {"Accept": "application/json"},
    body: {'email' : email, 'password' : password},
  );

  print("RAW RESPONSE: ${response.body}"); // Debug

  // Jika server tidak return JSON (biasanya HTML error)
  bool isJson;
  try {
    jsonDecode(response.body);
    isJson = true;
  } catch (_) {
    isJson = false;
  }

  if (!isJson) {
    throw Exception(
      "Server tidak mengembalikan JSON.\n"
      "Kemungkinan URL salah: ${Endpoint.register}\n"
      "Response: ${response.body}",
    );
  }

  final json = jsonDecode(response.body);

  // Jika status code 200 → simpan token
  if (response.statusCode == 200 && json['token'] != null) {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", json['token']);
  }

  return UserModel.fromJson(json);
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
