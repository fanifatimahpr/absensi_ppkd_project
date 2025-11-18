import 'package:flutter/material.dart';
import 'package:flutter_project_ppkd/data/models/attendance_model.dart';
import 'package:flutter_project_ppkd/service/api_absensi.dart';
import 'package:shimmer/shimmer.dart';

class AttendancePage extends StatefulWidget {
  final String token;

  const AttendancePage({super.key, required this.token});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage>
    with SingleTickerProviderStateMixin {
  AttendanceData? today;
  bool loading = true;
  late AnimationController _controller;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    fetchData();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
  }

  Future<void> fetchData() async {
    final api = AbsensiApi();
    final res = await api.getAbsensiToday(widget.token);

    setState(() {
      today = res?.data;
      loading = false;
    });

    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Absensi Hari Ini")),
      body: loading ? shimmerLoader() : FadeTransition(opacity: _fade, child: content()),
    );
  }

  Widget shimmerLoader() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.white,
      child: Column(
        children: [
          Container(height: 90, margin: const EdgeInsets.all(16), color: Colors.grey),
          Container(height: 90, margin: const EdgeInsets.all(16), color: Colors.grey),
        ],
      ),
    );
  }

  Widget content() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          absensiCard(
            title: "Absen Masuk",
            value: today?.checkInTime ?? "Belum Absen",
            subtitle: today?.checkInAddress ?? "-",
            icon: Icons.login,
            color: Colors.green,
          ),
          const SizedBox(height: 12),
          absensiCard(
            title: "Absen Keluar",
            value: today?.checkOutTime ?? "Belum Absen",
            subtitle: today?.checkOutAddress ?? "-",
            icon: Icons.logout,
            color: Colors.red,
          ),
          const SizedBox(height: 24),
          izinCard(),
        ],
      ),
    );
  }

  Widget absensiCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0,3)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: color.withOpacity(0.15),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(value,
                    style: TextStyle(
                        fontSize: 22,
                        color: (value == "Belum Absen")
                            ? Colors.red
                            : Colors.black,
                        fontWeight: FontWeight.w600)),
                Text(subtitle, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget izinCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.note_alt, color: Colors.blue, size: 26),
          const SizedBox(width: 12),
          const Expanded(
            child: Text("Ajukan Perizinan",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),

          /// ➤ Tambahan icon panah kanan (indikasi slider)
          const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.blue),
        ],
      ),
    );
  }
}
