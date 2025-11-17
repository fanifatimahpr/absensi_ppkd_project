import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late DateTime currentTime;
  Timer? timer;

  bool isCheckedIn = false;
  String? checkInTime;
  String? checkOutTime;

  @override
  void initState() {
    super.initState();

    currentTime = DateTime.now();

    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        currentTime = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  String formatTime(DateTime date) {
    return DateFormat('HH:mm:ss', 'id_ID').format(date);
  }

  String formatDate(DateTime date) {
    return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(date);
  }

  void handleCheckIn() {
    setState(() {
      isCheckedIn = true;
      checkInTime = formatTime(DateTime.now());
    });
  }

  void handleCheckOut() {
    setState(() {
      isCheckedIn = false;
      checkOutTime = formatTime(DateTime.now());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(children: [buildBackground(), buildLayer()]),
        ),
      ),
    );
  }

  Widget buildBackground() {
    return Column(children: [_greetingCard(), const SizedBox(height: 20)]);
  }

  Widget buildLayer() {
    return Column(
      children: [
        _clockCard(),
        const SizedBox(height: 20),
        _attendanceButtons(),
        const SizedBox(height: 20),
        if (checkInTime != null || checkOutTime != null) _attendanceHistory(),
        const SizedBox(height: 20),
        _quickStats(),
      ],
    );
  }

  Widget _greetingCard() {
    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: AssetImage("assets/profile.jpg"),
              fit: BoxFit.cover,
            ),
          ),
        ),

        const SizedBox(width: 16),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Halo,",
              style: TextStyle(
                color: Color(0xff6D1F42),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              "Nama Kamu",
              style: TextStyle(color: Color(0xff6D1F42), fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }

  Widget _clockCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFD3B6D3),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "Hari Ini",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6D1F42),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // ⏱ Jam besar
                Text(
                  formatTime(currentTime),
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6D1F42),
                  ),
                ),

                const SizedBox(height: 6),

                // Tanggal
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 16,
                      color: Color(0xFF6D1F42),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      formatDate(currentTime),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6D1F42),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Clock Icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.access_time_filled_rounded,
              color: Color(0xFF6D1F42),
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _attendanceButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xffb8cee8),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ---- Container Judul ----
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 233, 243, 255),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              "Absen",
              style: TextStyle(
                fontSize: 16,
                color: Color.fromARGB(255, 39, 81, 133),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 20),

          /// ===================== BUTTON MASUK & KELUAR =====================
          Row(
            children: [
              /// ----- BUTTON MASUK -----
              Expanded(
                child: ElevatedButton(
                  onPressed: isCheckedIn ? null : handleCheckIn,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    foregroundColor: Colors.white,
                    backgroundColor: isCheckedIn
                        ? Colors.grey
                        : const Color.fromARGB(255, 39, 81, 133),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(35),
                    ),
                  ),
                  child: const Text("Masuk", style: TextStyle(fontSize: 16)),
                ),
              ),

              const SizedBox(width: 12),

              /// ----- BUTTON KELUAR -----
              Expanded(
                child: ElevatedButton(
                  onPressed: !isCheckedIn ? null : handleCheckOut,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    foregroundColor: Colors.white,
                    backgroundColor: !isCheckedIn
                        ? Colors.grey
                        : const Color.fromARGB(255, 39, 81, 133),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(35),
                    ),
                  ),
                  child: const Text("Keluar", style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _attendanceHistory() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Riwayat Absen Hari Ini",
            style: TextStyle(
              color: Color(0xFF6d1f42),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          if (checkInTime != null)
            _historyItem(
              dotColor: Color(0xFF6d1f42),
              title: "Waktu Masuk",
              time: checkInTime!,
            ),

          if (checkOutTime != null)
            _historyItem(
              dotColor: Color.fromARGB(255, 39, 81, 133),
              title: "Waktu Keluar",
              time: checkOutTime!,
            ),
        ],
      ),
    );
  }

  Widget _historyItem({
    required Color dotColor,
    required String title,
    required String time,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: dotColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Color.fromARGB(255, 92, 92, 92),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          Text(
            time,
            style: const TextStyle(color: Color(0xFF6d1f42), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _quickStats() {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            label: "Total Kehadiran",
            value: "18",
            extra: "dari 22 hari kerja",
            color: const Color(0xFFD3B6D3),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            label: "Total Jam Kerja",
            value: "142",
            extra: "jam bulan ini",
            color: const Color(0xffb8cee8),
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required String label,
    required String value,
    required String extra,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Color.fromARGB(255, 92, 92, 92)),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6d1f42),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            extra,
            style: const TextStyle(
              color: Color.fromARGB(255, 92, 92, 92),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
