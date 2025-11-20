import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_project_ppkd/service/api.dart';
import 'package:flutter_project_ppkd/views/auth/login_screen.dart';
import 'package:http/http.dart' as http;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  List<dynamic> trainingList = [];
  List<dynamic> batchList = [];

  String? selectedTraining;
  String? selectedBatch;
  String? selectedGender;

  bool isLoadingTraining = true;
  bool isLoadingBatch = true;
  bool showPassword = false;
  bool isLoading = false;

  final _formKey = GlobalKey<FormState>();

  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final batchCtrl = TextEditingController();
  final trainingCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final AuthAPI _api = AuthAPI();

  @override
  void initState() {
    super.initState();
    fetchTrainingData();
    fetchBatchData();
  }

  void fetchTrainingData() async {
    final response = await _api.getTrainings();
    if (!mounted) return;

    setState(() {
      trainingList = response["data"];
      isLoadingTraining = false;
    });
  }

  void fetchBatchData() async {
    final response = await _api.getBatches();
    if (!mounted) return;

    setState(() {
      batchList = response["data"];
      isLoadingBatch = false;
    });
  }

  void handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      final formData = {
        "name": nameCtrl.text,
        "email": emailCtrl.text,
        "password": passwordCtrl.text,
        "jenis_kelamin": selectedGender,
        "profile_photo": "",
        "batch_id": selectedBatch,
        "training_id": selectedTraining,
      };

      try {
        final response = await AuthAPI.register(formData);

        if (response.data != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Registrasi berhasil")),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreenAbs()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Gagal registrasi")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  // =========================================================================
  // UI BUILD
  // =========================================================================
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

  // ---------------------------------------------------------------------------
  // BACKGROUND
  // ---------------------------------------------------------------------------
  Widget _backgroundDecor() {
    return Stack(
      children: [
        Positioned(
          top: -120,
          right: -80,
          child: _circle(280, const Color(0xFFD3B6D3).withOpacity(.35)),
        ),
        Positioned(
          bottom: -150,
          left: -100,
          child: _circle(340, const Color(0xFF275185).withOpacity(.25)),
        ),
      ],
    );
  }

  Widget _circle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }

  // ---------------------------------------------------------------------------
  // CARD UTAMA
  // ---------------------------------------------------------------------------
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
            _buildForm(),
            _loginText(),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return const Text(
      "Register",
      style: TextStyle(
        fontWeight: FontWeight.w900,
        fontSize: 30,
        color: Color(0xFF6D1F42),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // FORM INPUT
  // ---------------------------------------------------------------------------
  Widget _buildForm() {
    return Column(
      children: [
        _textField(
          label: "Nama",
          icon: Icons.person,
          controller: nameCtrl,
          hint: "Nama lengkap",
          validator: (v) => v!.isEmpty ? "Nama tidak boleh kosong" : null,
        ),
        const SizedBox(height: 15),

        _textField(
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

        _genderDropdown(),
        const SizedBox(height: 15),

        _batchDropdown(),
        const SizedBox(height: 15),

        _trainingDropdown(),
        const SizedBox(height: 15),

        _passwordField(),
        const SizedBox(height: 25),

        _submitButton(),
      ],
    );
  }

  Widget _textField({
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
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6D1F42))),
        ]),
        const SizedBox(height: 6),

        TextFormField(
          controller: controller,
          validator: validator,
          decoration: _inputDecoration(hint),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white.withOpacity(.7),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(26),
        borderSide: const BorderSide(color: Color(0xFF6D1F42), width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(26),
        borderSide: const BorderSide(color: Color(0xFF275185), width: 2.6),
      ),
    );
  }

  Widget _genderDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: const [
          Icon(Icons.people, size: 18, color: Color(0xFF6D1F42)),
          SizedBox(width: 6),
          Text("Jenis Kelamin",
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6D1F42))),
        ]),
        const SizedBox(height: 6),

        DropdownButtonFormField<String>(
          value: selectedGender,
          hint: const Text("Pilih jenis kelamin"),
          decoration: _inputDecoration(""),
          items: const [
            DropdownMenuItem(value: "L", child: Text("Laki-laki")),
            DropdownMenuItem(value: "P", child: Text("Perempuan")),
          ],
          onChanged: (v) => setState(() => selectedGender = v),
          validator: (v) =>
              v == null ? "Jenis kelamin wajib dipilih" : null,
        ),
      ],
    );
  }

  Widget _batchDropdown() {
    return isLoadingBatch
        ? const Center(child: CircularProgressIndicator())
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: const [
                Icon(Icons.calendar_month,
                    size: 18, color: Color(0xFF6D1F42)),
                SizedBox(width: 6),
                Text("Batch",
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6D1F42))),
              ]),
              const SizedBox(height: 6),

              DropdownButtonFormField<String>(
                value: selectedBatch,
                hint: const Text("Pilih batch"),
                decoration: _inputDecoration(""),
                items: batchList.map((item) {
                  return DropdownMenuItem(
                    value: item["id"].toString(),
                    child: Text("Batch ${item["batch_ke"]}"),
                  );
                }).toList(),
                onChanged: (v) => setState(() => selectedBatch = v),
                validator: (v) =>
                    v == null ? "Batch wajib dipilih" : null,
              ),
            ],
          );
  }

  Widget _trainingDropdown() {
    return isLoadingTraining
        ? const Center(child: CircularProgressIndicator())
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: const [
                Icon(Icons.school, size: 18, color: Color(0xFF6D1F42)),
                SizedBox(width: 6),
                Text("Training",
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6D1F42))),
              ]),
              const SizedBox(height: 6),

              DropdownButtonFormField<String>(
                value: selectedTraining,
                hint: const Text("Pilih training"),
                decoration: _inputDecoration(""),
                items: trainingList.map((item) {
                  return DropdownMenuItem(
                    value: item["id"].toString(),
                    child: Text(item["title"]),
                  );
                }).toList(),
                onChanged: (v) => setState(() => selectedTraining = v),
                validator: (v) =>
                    v == null ? "Training wajib dipilih" : null,
              ),
            ],
          );
  }

  Widget _passwordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: const [
          Icon(Icons.lock, size: 18, color: Color(0xFF6D1F42)),
          SizedBox(width: 6),
          Text("Password",
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6D1F42))),
        ]),
        const SizedBox(height: 6),

        TextFormField(
          controller: passwordCtrl,
          obscureText: !showPassword,
          validator: (v) {
            if (v!.isEmpty) return "Password wajib diisi";
            if (v.length < 6) return "Minimal 6 karakter";
            return null;
          },
          decoration: _inputDecoration("Minimal 6 karakter").copyWith(
            suffixIcon: IconButton(
              icon: Icon(
                showPassword ? Icons.visibility_off : Icons.visibility,
                color: const Color(0xFF6D1F42),
              ),
              onPressed: () =>
                  setState(() => showPassword = !showPassword),
            ),
          ),
        ),
      ],
    );
  }

  Widget _submitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6D1F42),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
        ),
        child: const Text(
          "Daftar Sekarang",
          style: TextStyle(color: Colors.white, fontSize: 17),
        ),
      ),
    );
  }

  Widget _loginText() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreenAbs()),
        );
      },
      child: const Padding(
        padding: EdgeInsets.only(top: 10),
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: "Sudah punya akun? ",
                style: TextStyle(color: Color(0xFF6D1F42)),
              ),
              TextSpan(
                text: "Login",
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
