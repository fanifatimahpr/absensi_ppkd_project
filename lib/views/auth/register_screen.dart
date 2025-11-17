import 'package:flutter/material.dart';
import 'package:flutter_project_ppkd/service/api.dart';
import 'package:flutter_project_ppkd/views/auth/login_screen.dart';

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

  bool isLoadingTraining = true;
  bool isLoadingBatch = true;

    String? selectedGender;

  final _formKey = GlobalKey<FormState>();

  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final batchCtrl = TextEditingController();
  final trainingCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final AuthAPI _api = AuthAPI();


  bool showPassword = false;

  void handleSubmit() {
  if (_formKey.currentState!.validate()) {
    final formData = {
      "name": nameCtrl.text,
      "email": emailCtrl.text,
      "gender": selectedGender,
      "batches": selectedBatch,
      "trainings": selectedTraining,
      "password": passwordCtrl.text,
    };

    print("Form submitted: $formData");

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Registrasi berhasil!")),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }
}

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
    trainingList = response["data"];   // ✔ Ambil list yg benar
    isLoadingTraining = false;
  });
}

void fetchBatchData() async {
  final response = await _api.getBatches();
  if (!mounted) return;

  setState(() {
    batchList = response["data"];      // ✔ Ambil list yg benar
    isLoadingBatch = false;
  });
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
          children: [
            _buildHeader(),
            const SizedBox(height: 15),
            _buildForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Text(
      "Register",
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 32,
        foreground: Paint()
          ..shader = const LinearGradient(
            colors: [
              Color(0xff6d1f42),
              Color(0xffef6f3c),
              Color(0xff6d1f42),
            ],
          ).createShader(const Rect.fromLTWH(0, 0, 200, 100)),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        _inputField(
          label: "Nama",
          icon: Icons.person,
          controller: nameCtrl,
          hint: "Nama Lengkap",
          validator: (value) =>
              value!.isEmpty ? "Nama tidak boleh kosong" : null,
        ),
        const SizedBox(height: 15),

        _inputField(
          label: "Email",
          icon: Icons.email,
          controller: emailCtrl,
          hint: "contoh: nama@example.com",
          validator: (value) {
                  if (value == null || value.isEmpty)
                    return "Email must be filled";
                  if (!RegExp(
                    r"^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$",
                  ).hasMatch(value)) {
                    return "Email not valid";
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
          Icon(icon, size: 18, color: Color(0xff6d1f42)),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Color(0xff6d1f42))),
        ]),
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
              focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide:
                const BorderSide(color: Color(0xffef6f3c), width: 3),
            ),
            ),
          ),
        ]
      );
  }
  Widget _genderDropdown() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(children: const [
        Icon(Icons.people, size: 18, color: Color(0xff6d1f42)),
        SizedBox(width: 6),
        Text("Jenis Kelamin",
            style: TextStyle(color: Color(0xff6d1f42))),
      ]),
      const SizedBox(height: 6),

      DropdownButtonFormField<String>(
        value: selectedGender,
        hint: const Text("Pilih Jenis Kelamin"),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white.withOpacity(.6),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide:
                const BorderSide(color: Color(0xff6d1f42), width: 3),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide:
                const BorderSide(color: Color(0xffef6f3c), width: 3),
          ),
        ),
        items: const [
          DropdownMenuItem(
            value: "L",
            child: Text("Laki-Laki"),
          ),
          DropdownMenuItem(
            value: "P",
            child: Text("Perempuan"),
          ),
        ],
        onChanged: (value) {
          setState(() {
            selectedGender = value;
          });
        },
        validator: (value) =>
            value == null ? "Jenis kelamin wajib dipilih" : null,
      ),
    ],
  );
}
Widget _trainingDropdown() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(children: const [
        Icon(Icons.book, size: 18, color: Color(0xff6d1f42)),
        SizedBox(width: 6),
        Text("Training", style: TextStyle(color: Color(0xff6d1f42))),
      ]),
      const SizedBox(height: 6),

      isLoadingTraining
          ? const CircularProgressIndicator()
          : DropdownButtonFormField<String>(
              value: selectedTraining,
              hint: const Text("Pilih Training"),
              decoration: _dropdownDecoration(),
              items: trainingList.map((item) {
                return DropdownMenuItem(
                  value: item["id"].toString(),
                  child: Text(item["title"]),
                );
              }).toList(),
              onChanged: (value) => setState(() {
                selectedTraining = value;
              }),
              validator: (value) =>
                  value == null ? "Training wajib dipilih" : null,
            ),
    ],
  );
}
Widget _batchDropdown() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(children: const [
        Icon(Icons.calendar_month, size: 18, color: Color(0xff6d1f42)),
        SizedBox(width: 6),
        Text("Batch", style: TextStyle(color: Color(0xff6d1f42))),
      ]),
      const SizedBox(height: 6),

      isLoadingBatch
          ? const CircularProgressIndicator()
          : DropdownButtonFormField<String>(
              value: selectedBatch,
              hint: const Text("Pilih Batch"),
              decoration: _dropdownDecoration(),
              items: batchList.map((item) {
                return DropdownMenuItem(
                  value: item["id"].toString(),
                  child: Text("Batch ${item["batch_ke"]}"),
                );
              }).toList(),
              onChanged: (value) => setState(() {
                selectedBatch = value;
              }),
              validator: (value) =>
                  value == null ? "Batch wajib dipilih" : null,
            ),
    ],
  );
}
InputDecoration _dropdownDecoration() {
  return InputDecoration(
    filled: true,
    fillColor: Colors.white.withOpacity(.6),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: const BorderSide(color: Color(0xff6d1f42), width: 3),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: const BorderSide(color: Color(0xffef6f3c), width: 3),
    ),
  );
}


  Widget _passwordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: const [
          Icon(Icons.lock, size: 18, color: Color(0xff6d1f42)),
          SizedBox(width: 6),
          Text("Password", style: TextStyle(color: Color(0xff6d1f42))),
        ]),
        const SizedBox(height: 6),

        TextFormField(
          controller: passwordCtrl,
          obscureText: !showPassword,
          validator: (value) {
            if (value!.isEmpty) return "Password tidak boleh kosong";
            if (value.length < 6) return "Password minimal 6 karakter";
            return null;
          },
          decoration: InputDecoration(
            hintText: "Minimal 6 karakter",
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
      onPressed: handleSubmit,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(15),
        backgroundColor: const Color(0xffef6f3c),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(26),
          side: const BorderSide(color: Colors.white, width: 4),
        ),
      ),
      child: const Text(
        "Register Here",
        style: TextStyle(color: Colors.white, fontSize: 18),
      ),
    );
  }
}
