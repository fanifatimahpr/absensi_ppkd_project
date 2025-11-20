import 'package:flutter/material.dart';
import 'package:flutter_project_ppkd/data/local/preference_handler.dart';
import 'package:flutter_project_ppkd/data/models/login_model.dart';
import 'package:flutter_project_ppkd/service/api.dart';
import 'package:flutter_project_ppkd/views/auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String name = "";
  String email = "";
  String batchId = "-";
  String trainingId = "-";

  String _getInitials(String name) {
  if (name.trim().isEmpty) return "?";
  List<String> parts = name.trim().split(" ");
  if (parts.length == 1) return parts[0][0].toUpperCase();
  return (parts[0][0] + parts[1][0]).toUpperCase();
}


  @override
  void initState() {
    super.initState();
    loadUser();
  }

 Future<void> loadUser() async {
  final user = await PreferenceHandler.getUserData(); 
  final localName = await PreferenceHandler.getName();

  if (user != null) {
    setState(() {
      name = user["name"] ?? localName ?? "User";  // 🔥 gunakan userData dulu
      email = user["email"] ?? "-";
      batchId = user["batch_id"]?.toString() ?? "-";
      trainingId = user["training_id"]?.toString() ?? "-";
    });
    return;
  }

  // fallback kalau userData tidak ada
  if (localName != null) {
    setState(() {
      name = localName;
      email = "-";
      batchId = "-";
      trainingId = "-";
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      body: Stack(
        children: [
          _backgroundDecor(),

          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Column(
              children: const [
                Text(
                  "Profil Saya",
                  style: TextStyle(
                    color: Color(0xFF6D1F42),
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(top: 120),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              children: [
                _profileHeader(),
                const SizedBox(height: 28),
                _infoCard(),
                const SizedBox(height: 28),

                // EDIT PROFIL BUTTON
                _actionButton(
                  label: "Edit Profil",
                  icon: Icons.edit,
                  color: const Color(0xFF275185),
                  onTap: () async {
                    final updated = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EditProfileScreen(),
                      ),
                    );
                    if (updated == true) {
                      loadUser();
                    }
                  },
                ),
                const SizedBox(height: 14),

               _actionButton(
                label: "Logout",
                icon: Icons.logout_rounded,
                color: const Color(0xFF6D1F42),
                onTap: () async {
                  await PreferenceHandler.logout();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreenAbs()),
                    (route) => false,
                  );
                },
              ),

              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _profileHeader() {
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF6D1F42).withOpacity(.15),
            ),
            child: CircleAvatar(
              radius: 48,
              backgroundColor: const Color(0xFF6D1F42), // warna avatar
              child: Text(
                _getInitials(name),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

          ),
          const SizedBox(height: 14),
          Text(
            name,
            style: const TextStyle(
              color: Color(0xFF6D1F42),
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            email,
            style: const TextStyle(
              color: Color(0xFF275185),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _infoRow("Nama Lengkap", name),
          const SizedBox(height: 12),
          _infoRow("Email", email),
          const SizedBox(height: 12),
          _infoRow("Batch ID", batchId),
          const SizedBox(height: 12),
          _infoRow("Training ID", trainingId),
        ],
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(
                color: Color(0xFF6D1F42),
                fontSize: 14,
                fontWeight: FontWeight.w600)),
        Text(value,
            style: const TextStyle(
                color: Color(0xFF275185),
                fontSize: 14,
                fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 22),
        decoration: BoxDecoration(
          color: color.withOpacity(.12),
          borderRadius: BorderRadius.circular(35),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                    color: color, fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
            Icon(Icons.chevron_right, color: color, size: 26),
          ],
        ),
      ),
    );
  }

  Widget _backgroundDecor() {
    return Stack(
      children: [
        Positioned(
            top: -120,
            right: -80,
            child: _circle(280, const Color(0xFFD3B6D3).withOpacity(.25))),
        Positioned(
            bottom: -150,
            left: -100,
            child: _circle(340, const Color(0xFF275185).withOpacity(.25))),
      ],
    );
  }

  Widget _circle(double size, Color color) {
    return Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, color: color));
  }
}
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController nameController = TextEditingController();
  bool loading = false;

  @override
  void initState() {
    super.initState();
    loadCurrentName();
  }

  void loadCurrentName() async {
    final user = await PreferenceHandler.getUserData();
    if (user != null) {
      nameController.text = user["name"] ?? "";
    } else {
      final n = await PreferenceHandler.getName();
      if (n != null) nameController.text = n;
    }
  }

  Future<void> save() async {
    final newName = nameController.text.trim();
    if (newName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nama tidak boleh kosong")),
      );
      return;
    }

    setState(() => loading = true);

    Map<String, dynamic> response;
    try {
      response = await AuthAPI.updateProfile(newName);
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Terjadi kesalahan jaringan")),
      );
      return;
    }

    setState(() => loading = false);

    if (response["data"] != null) {
      await PreferenceHandler.saveUserData(response["data"]);

      if (response["data"]["name"] != null) {
        await PreferenceHandler.saveName(response["data"]["name"]);
      } 
      else {
        await PreferenceHandler.saveName(newName);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profil berhasil diperbarui")),
      );

      Navigator.pop(context, true);
      return;
    }

    final errorMessage = response["message"] ??
        "Gagal memperbarui profil. Silakan coba lagi.";
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(errorMessage)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      appBar: AppBar(
        title: const Text("Edit Profil"),
        backgroundColor: const Color(0xFF6D1F42),
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      // 🔥 Menggunakan box/card ala theme Profil
      body: Stack(
        children: [
          // BACKGROUND DEKORASI SAMA TEMA PROFIL
          Positioned(
            top: -120,
            right: -80,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFD3B6D3).withOpacity(.25),
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            left: -100,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF275185).withOpacity(.25),
              ),
            ),
          ),

          // CARD / BOX
          Center(
            child: Container(
              padding: const EdgeInsets.all(22),
              margin: const EdgeInsets.symmetric(horizontal: 28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(35),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Edit Nama Lengkap",
                    style: TextStyle(
                      color: Color(0xFF6D1F42),
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // TEXTFIELD
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: "Nama Lengkap",
                      labelStyle: const TextStyle(color: Color(0xFF275185)),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Color(0xFF275185), width: 2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // BUTTON SIMPAN
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF275185),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: loading ? null : save,
                      child: loading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              "Simpan Perubahan",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
