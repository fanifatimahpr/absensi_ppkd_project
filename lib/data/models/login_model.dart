import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_project_ppkd/config/endpoint.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_project_ppkd/views/home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  bool showPassword = false;

  //  FUNGSI LOGIN KE API
  Future<void> handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final body = {
        "email": emailCtrl.text.trim(),
        "password": passwordCtrl.text.trim(),
      };

      try {
        final response = await http.post(
          Uri.parse(Endpoint.login),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(body),
        );

        final result = jsonDecode(response.body);

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result["message"] ?? "Login berhasil")),
          );

          // NAVIGASI KE HOME SETELAH LOGIN
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => HomeScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result["message"] ?? "Login gagal")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffefce7b),
      body: Stack(
        children: [
          _buildBackground(),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _buildMainCard(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Stack(
      children: [
        Positioned(
          top: -80,
          left: -80,
          child: _circle(250, const Color(0xffd3b6d3), opacity: .6),
        ),
        Positioned(
          bottom: -120,
          right: -100,
          child: _circle(360, const Color(0xffef6f3c), opacity: .4),
        ),
      ],
    );
  }

  Widget _circle(double size, Color color, {double opacity = 1}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(opacity),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildMainCard() {
    return Container(
      width: 340,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [BoxShadow(blurRadius: 20, color: Colors.black26)],
      ),
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          children: [_buildHeader(), const SizedBox(height: 15), _buildForm()],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Text(
      "Log In",
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 32,
        foreground: Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xff6d1f42), Color(0xffef6f3c), Color(0xff6d1f42)],
          ).createShader(const Rect.fromLTWH(0, 0, 200, 100)),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        _inputField(
          label: "Email",
          icon: Icons.email,
          controller: emailCtrl,
          hint: "contoh: nama@example.com",
          validator: (value) {
            if (value == null || value.isEmpty)
              return "Email tidak boleh kosong";
            if (!RegExp(
              r"^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$",
            ).hasMatch(value)) {
              return "Format email tidak valid";
            }
            return null;
          },
        ),
        const SizedBox(height: 15),

        _passwordField(),
        const SizedBox(height: 25),

        _submitButton(),
      ],
    );
  }

  Widget _inputField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required String hint,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xff6d1f42)),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(color: Color(0xff6d1f42))),
          ],
        ),
        const SizedBox(height: 3),

        TextFormField(
          controller: controller,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white.withOpacity(.6),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Color(0xff6d1f42), width: 3),
            ),
          ),
        ),
      ],
    );
  }

  Widget _passwordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.lock, size: 18, color: Color(0xff6d1f42)),
            SizedBox(width: 6),
            Text("Password", style: TextStyle(color: Color(0xff6d1f42))),
          ],
        ),
        const SizedBox(height: 6),

        TextFormField(
          controller: passwordCtrl,
          obscureText: !showPassword,
          validator: (value) {
            if (value!.isEmpty) return "Password tidak boleh kosong";
            return null;
          },
          decoration: InputDecoration(
            hintText: "Masukkan password",
            filled: true,
            fillColor: Colors.white.withOpacity(.6),
            suffixIcon: IconButton(
              icon: Icon(
                showPassword ? Icons.visibility_off : Icons.visibility,
                color: const Color(0xff6d1f42),
              ),
              onPressed: () => setState(() => showPassword = !showPassword),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Color(0xff6d1f42), width: 3),
            ),
          ),
        ),
      ],
    );
  }

  Widget _submitButton() {
    return ElevatedButton(
      onPressed: handleLogin,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(15),
        backgroundColor: const Color(0xffef6f3c),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(26),
          side: const BorderSide(color: Colors.white, width: 4),
        ),
      ),
      child: const Text(
        "Log In",
        style: TextStyle(color: Colors.white, fontSize: 18),
      ),
    );
  }
}
