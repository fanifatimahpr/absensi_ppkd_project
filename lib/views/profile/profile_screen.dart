import 'dart:ui';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  final Map<String, dynamic> user;
  final VoidCallback onLogout;

  const ProfileScreen({
    super.key,
    required this.user,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          _buildLayer(),
        ],
      ),
    );
  }

  // =========================================================
  // BACKGROUND LAYER
  // =========================================================
  Widget _buildBackground() {
    return Stack(
      children: [
        Positioned(
          top: 80,
          left: 40,
          child: _blurCircle(
            160,
            160,
            const [Colors.blue, Colors.cyan],
            40,
          ),
        ),
        Positioned(
          bottom: 140,
          right: 40,
          child: _blurCircle(
            130,
            130,
            const [Colors.pink, Colors.purple],
            30,
          ),
        ),
      ],
    );
  }

  // Circle blur reusable
  Widget _blurCircle(
      double w, double h, List<Color> colors, double blurAmount) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        shape: BoxShape.circle,
      ),
      child: Opacity(
        opacity: 0.35,
        child: ClipOval(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blurAmount, sigmaY: blurAmount),
            child: Container(color: Colors.transparent),
          ),
        ),
      ),
    );
  }

  // =========================================================
  // FRONT LAYER (Main Content)
  // =========================================================
  Widget _buildLayer() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 40),
            _buildProfilePicture(),
            const SizedBox(height: 40),
            _buildInfoCards(),
            const SizedBox(height: 30),
            _buildLogoutButton(),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // UI SECTIONS
  // =========================================================

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          "Profil Saya",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 4),
        Text(
          "Informasi data diri",
          style: TextStyle(fontSize: 15, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildProfilePicture() {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Colors.purple,
                  Colors.pink,
                  Colors.orange,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 60),
          ),
          Positioned(
            bottom: -2,
            right: -2,
            child: Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.green, Colors.teal],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 10),
                ],
              ),
              child: const Icon(Icons.check, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCards() {
    return Column(
      children: [
        _infoCard(
          icon: Icons.person,
          title: "Nama Lengkap",
          value: user["name"] ?? "-",
          colors: const [Colors.purple, Colors.pink],
        ),
        _infoCard(
          icon: Icons.mail,
          title: "Email",
          value: user["email"] ?? "-",
          colors: const [Colors.blue, Colors.cyan],
        ),
        _infoCard(
          icon: Icons.work,
          title: "Posisi",
          value: user["position"] ?? "-",
          colors: const [Colors.orange, Colors.yellow],
        ),
        _infoCard(
          icon: Icons.apartment,
          title: "Departemen",
          value: user["department"] ?? "-",
          colors: const [Colors.green, Colors.teal],
        ),
      ],
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String value,
    required List<Color> colors,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white30),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: colors),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style:
                        const TextStyle(color: Colors.black54, fontSize: 13)),
                const SizedBox(height: 4),
                Text(value,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        onPressed: onLogout,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        icon: const Icon(Icons.logout),
        label: const Text("Keluar", style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
