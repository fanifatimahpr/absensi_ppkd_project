import 'dart:convert';
import 'package:flutter_project_ppkd/config/endpoint.dart';
import 'package:flutter_project_ppkd/data/local/preference_handler.dart';
import 'package:flutter_project_ppkd/data/models/absentoday_model.dart';
import 'package:flutter_project_ppkd/data/models/user_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthAPI {
  // BASE URL (harus static)
  static const String baseUrl = "https://appabsensi.mobileprojp.com/api";

  // GET TOKEN
  // static Future<String?> getToken() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   return prefs.getString("token");
  // }
  static Future<String?> getToken() async {
  return await PreferenceHandler.getToken();
}

  // REGISTER
static Future<UserModel> register(Map<String, dynamic> data) async {
  final url = Uri.parse(Endpoint.register);

  final response = await http.post(
    url,
    headers: {
      "Content-Type": "application/json",
      "Accept": "application/json",
    },
    body: jsonEncode(data),
  );

  final json = jsonDecode(response.body);

  // Simpan token
  if (json['token'] != null) {
    await PreferenceHandler.saveToken(json['token']);
  }

  // 🔥 Simpan data user lengkap
  if (json['user'] != null) {
    await PreferenceHandler.saveUserData(json['user']);
  }

  return UserModel.fromJson(json);
}


  // LOGIN
static Future<UserModel> login(String email, String password) async {
  final url = Uri.parse(Endpoint.login);

  final response = await http.post(
    url,
    headers: {
      "Accept": "application/json",
      "Content-Type": "application/x-www-form-urlencoded",
    },
    body: {
      'email': email,
      'password': password,
    },
  );

  print("RAW RESPONSE LOGIN: ${response.body}");

  final json = jsonDecode(response.body);

  // Jika login berhasil (status 200 dan ada data)
  if (response.statusCode == 200 && json['data'] != null) {
    final data = json["data"];

    // Simpan token
    if (data["token"] != null) {
      await PreferenceHandler.saveToken(data["token"]);
    }

    // Simpan data user lengkap
    if (data["user"] != null) {
      await PreferenceHandler.saveUserData(data["user"]);
    }
  }

  return UserModel.fromJson(json);
}

  // GET TRAININGS
  Future<Map<String, dynamic>> getTrainings() async {
    final url = Uri.parse("$baseUrl/trainings");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return {"data": []};
  }

  // GET BATCHES
  Future<Map<String, dynamic>> getBatches() async {
    final url = Uri.parse("$baseUrl/batches");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return {"data": []};
  }


  // CHECK-IN
 static Future<Map<String, dynamic>> checkIn(Map<String, dynamic> data) async {
    final token = await PreferenceHandler.getToken();
    // print(token);
    final url = Uri.parse(Endpoint.checkIn);

    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode(data),
    );

    print("CHECK-IN RESPONSE: ${response.body}");
    return jsonDecode(response.body);
  }


  // CHECK-OUT
  static Future<Map<String, dynamic>> checkOut(Map<String, dynamic> data) async {
    final token = await PreferenceHandler.getToken();
    final url = Uri.parse(Endpoint.checkOut);

    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode(data),
    );

    print("CHECK-OUT RESPONSE: ${response.body}");
    return jsonDecode(response.body);
  }

  // GET TODAY ATTENDANCE
 static Future<absenTodayModel?> getTodayAttendance() async {
  final token = await PreferenceHandler.getToken();
  final url = Uri.parse(Endpoint.absenToday);

  final response = await http.get(
    url,
    headers: {
      "Authorization": "Bearer $token",
      "Accept": "application/json",
    },
  );

  print("ABSEN TODAY RESPONSE: ${response.body}");

  return absenTodayModelFromJson(response.body);
}


  //GET HISTORY 
  // static Future<List<dynamic>> getAttendanceHistory(int days) async {
  //   final token = await getToken();
  //   final url = Uri.parse("${Endpoint.history}?days=$days");

  //   final response = await http.get(
  //     url,
  //     headers: {
  //       "Authorization": "Bearer $token",
  //       "Accept": "application/json",
  //     },
  //   );

  //   print("HISTORY RESPONSE: ${response.body}");

  //   final json = jsonDecode(response.body);
  //   return json["data"] ?? [];
  // }

  static Future<List<Map<String, dynamic>>> getAttendanceHistory(int days) async {
  final token = await getToken();
  final url = Uri.parse("${Endpoint.history}?days=$days");

  final response = await http.get(
    url,
    headers: {
      "Authorization": "Bearer $token",
      "Accept": "application/json",
    },
  );

  print("HISTORY RESPONSE: ${response.body}");

  final json = jsonDecode(response.body);

  if (json["data"] == null) return [];

  final list = <Map<String, dynamic>>[];

  for (var item in json["data"]) {
    final date = item["attendance_date"] ?? "";
    final inTime = item["check_in_time"];
    final outTime = item["check_out_time"];

    if (inTime != null) {
      list.add({
        "date": date,
        "time": inTime,
        "type": "in",
      });
    }

    if (outTime != null) {
      list.add({
        "date": date,
        "time": outTime,
        "type": "out",
      });
    }
  }

  // SIMPAN LOCAL HISTORY
  await PreferenceHandler.saveHistory(list);

  return list;
}



static Future<Map<String, dynamic>> updateProfile(String name) async {
  final token = await PreferenceHandler.getToken();

  final url = Uri.parse(Endpoint.updateUser);

  final response = await http.put(
    url,
    headers: {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
      "Accept": "application/json",
    },
    body: jsonEncode({
      "name": name,
    }),
  );

  // Pastikan body bisa di-parse JSON — tangani error parse
  Map<String, dynamic> json;
  try {
    json = jsonDecode(response.body);
  } catch (e) {
    // Jika server tidak return JSON, kembalikan struktur error
    return {
      "message": "Server tidak mengembalikan JSON",
      "status_code": response.statusCode,
    };
  }

  // Jika sukses (200) dan ada data → simpan ke shared prefs
  if (response.statusCode == 200 && json["data"] != null) {
    try {
      await PreferenceHandler.saveUserData(json["data"]);
      // juga simpan nama terpisah supaya UI yang membaca getName() ikut terupdate
      if (json["data"]["name"] != null) {
        await PreferenceHandler.saveName(json["data"]["name"]);
      }
    } catch (e) {
      // ignore save error, tapi tetap kembalikan response
      print("Gagal menyimpan user data lokal: $e");
    }
  }

  // Kembalikan json mentah supaya UI bisa membaca message/data
  return json;
}
}
  