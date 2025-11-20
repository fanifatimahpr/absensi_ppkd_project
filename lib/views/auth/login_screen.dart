import 'package:flutter/material.dart';
import 'package:flutter_project_ppkd/data/local/preference_handler.dart';
import 'package:flutter_project_ppkd/service/api.dart';
import 'package:flutter_project_ppkd/views/auth/bottom_nav.dart';
import 'package:flutter_project_ppkd/views/auth/register_screen.dart';

class LoginScreenAbs extends StatefulWidget {
  const LoginScreenAbs({super.key});

  @override
  State<LoginScreenAbs> createState() => _LoginScreenAbsState();
}

class _LoginScreenAbsState extends State<LoginScreenAbs> {
  final _formKey = GlobalKey<FormState>();

  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  bool showPassword = false;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      body: Stack(
        children: [
          _backgroundDecor(),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _mainCard(),
            ),
          ),
        ],
      ),
    );
  }

  // BACKGROUND (SAMA DENGAN REGISTER)
  Widget _backgroundDecor() {
    return Stack(
      children: [
        Positioned(
          top: -120,
          right: -80,
          child:
              _circle(280, const Color(0xFFD3B6D3).withOpacity(.35)),
        ),
        Positioned(
          bottom: -150,
          left: -100,
          child:
              _circle(340, const Color(0xFF275185).withOpacity(.25)),
        ),
      ],
    );
  }

  Widget _circle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }

  // MAIN CARD
  Widget _mainCard() {
    return Container(
      width: 360,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _header(),
            const SizedBox(height: 10),
            _formFields(),            
            const SizedBox(height: 10),
            _registerText(),
          ],
        ),
      ),
    );
  }
  // HEADER TITLE
  Widget _header() {
    return const Text(
      "Login",
      style: TextStyle(
        fontWeight: FontWeight.w900,
        fontSize: 30,
        color: Color(0xFF6D1F42),
      ),
    );
  }

  // FORM FIELDS
  Widget _formFields() {
    return Column(
      children: [
        _inputField(
          label: "Email",
          icon: Icons.email,
          controller: emailCtrl,
          hint: "email@example.com",
          validator: (value) {
            if (value == null || value.isEmpty) return "Email wajib diisi";
            if (!RegExp(r"^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$")
                .hasMatch(value)) {
              return "Format email salah";
            }
            return null;
          },
        ),

        const SizedBox(height: 15),

        _passwordField(),

        const SizedBox(height: 25),

        _loginButton(),
      ],
    );
  }

  // GENERIC INPUT FIELD (MATCH REGISTER STYLE)
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
        Row(children: [
          Icon(icon, size: 18, color: const Color(0xFF6D1F42)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF6D1F42),
            ),
          ),
        ]),
        const SizedBox(height: 6),

        TextFormField(
          controller: controller,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white.withOpacity(.7),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(26),
              borderSide: const BorderSide(
                color: Color(0xFF6D1F42),
                width: 2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(26),
              borderSide: const BorderSide(
                color: Color(0xFF275185),
                width: 2.6,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // PASSWORD FIELD
  Widget _passwordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: const [
          Icon(Icons.lock, size: 18, color: Color(0xFF6D1F42)),
          SizedBox(width: 6),
          Text(
            "Password",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF6D1F42),
            ),
          ),
        ]),
        const SizedBox(height: 6),

        TextFormField(
          controller: passwordCtrl,
          obscureText: !showPassword,
          validator: (v) =>
              v!.isEmpty ? "Password wajib diisi" : null,
          decoration: InputDecoration(
            hintText: "Minimal 6 karakter",
            filled: true,
            fillColor: Colors.white.withOpacity(.7),
            suffixIcon: IconButton(
              icon: Icon(
                showPassword ? Icons.visibility_off : Icons.visibility,
                color: const Color(0xFF6D1F42),
              ),
              onPressed: () =>
                  setState(() => showPassword = !showPassword),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(26),
              borderSide: const BorderSide(
                color: Color(0xFF6D1F42),
                width: 2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(26),
              borderSide:
                  const BorderSide(color: Color(0xFF275185), width: 2.6),
            ),
          ),
        ),
      ],
    );
  }

  // LOGIN BUTTON (MATCH REGISTER)
  Widget _loginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6D1F42),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
        ),
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                "Masuk",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                ),
              ),
      ),
    );
  }

  // LOGIN PROCESS
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final response =
        await AuthAPI.login(emailCtrl.text.trim(), passwordCtrl.text.trim());

    setState(() => isLoading = false);

    if (response.data != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login berhasil")),
      );
      final token = response.data!.token;
      print(token);
      PreferenceHandler.saveToken(token!);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => const BottomNavAbsensi()),
      );

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email atau password salah")),
      );
    }
  }
  Widget _registerText() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const RegisterScreen()),
        );
      },
      child: const Padding(
        padding: EdgeInsets.only(top: 10),
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: "Belum punya akun? ",
                style: TextStyle(color: Color(0xFF6D1F42)),
              ),
              TextSpan(
                text: "Register",
                style: TextStyle(
                  color: Color(0xFF275185),
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              )
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

}
