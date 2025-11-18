import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_project_ppkd/data/local/preference_handler.dart';
import 'package:flutter_project_ppkd/views/maps/maps_screen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late DateTime currentTime;
  Timer? timer;

  String name = "User";
  String greeting = "";
  String today = "";

  bool isCheckedIn = false;
  String? checkInTime;
  String? checkOutTime;

  String selectedPermit = "";
  final TextEditingController permitNoteC = TextEditingController();

  // Animasi
  late AnimationController _animController;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;

  final List<Map<String, dynamic>> permitList = [
    {"icon": Icons.sick, "label": "Sakit"},
    {"icon": Icons.work_off, "label": "Izin"},
    {"icon": Icons.directions_walk, "label": "Dinas Luar"},
    {"icon": Icons.airplane_ticket, "label": "Cuti"},
    {"icon": Icons.watch_later, "label": "Lembur"},
  ];

  @override
  void initState() {
    super.initState();

    initUser();
    getGreeting();
    getToday();

    currentTime = DateTime.now();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => currentTime = DateTime.now());
    });

    // ANIMATION
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOut,
      ),
    );

    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(_animController);

    _animController.forward();
  }

  @override
  void dispose() {
    timer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  // ============================
  // 2.1 AMBIL NAMA USER
  // ============================
  Future<void> initUser() async {
    final savedName = await PreferenceHandler.getName();
    setState(() => name = savedName ?? "User");
  }

  void getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      greeting = "Selamat Pagi ☀️";
    } else if (hour < 17) {
      greeting = "Selamat Siang 🌤️";
    } else {
      greeting = "Selamat Malam 🌙";
    }
  }

  void getToday() {
    today = DateFormat("EEEE, dd MMMM yyyy", "id_ID").format(DateTime.now());
  }

  String formatTime(DateTime date) =>
      DateFormat('HH:mm:ss', 'id_ID').format(date);

  String formatDate(DateTime date) =>
      DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(date);

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
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Column(children: [
                buildBackground(),
                buildLayer(),
              ]),
            ),
          ),
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
        _attendanceHistory(),
        const SizedBox(height: 20),
        _permitSection(),
        const SizedBox(height: 20),
        _quickStats(),
      ],
    );
  }

  // =========================================================
  // GREETING CARD (UPDATED)
  // =========================================================
  Widget _greetingCard() {
    return Row(
      children: [
        Container(
          width: 65,
          height: 65,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Color(0xff6D1F42), width: 2),
            image: const DecorationImage(
              image: AssetImage("assets/profile.jpg"),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 16),

        // ==== UPDATED TEXT ====
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              greeting,
              style: const TextStyle(
                color: Color(0xff6D1F42),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              name,
              style: const TextStyle(
                  color: Color(0xff6D1F42),
                  fontSize: 14,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 2),
            Text(
              today,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // =========================================================
  // CLOCK CARD
  // =========================================================
  Widget _clockCard() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
                Text(
                  formatTime(currentTime),
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6D1F42),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded,
                        size: 16, color: Color(0xFF6D1F42)),
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
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.access_time_filled_rounded,
                size: 32, color: Color(0xFF6D1F42)),
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
      boxShadow: const [
        BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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

        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MapsScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 28),
                  backgroundColor: const Color.fromARGB(255, 39, 81, 133),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(35),
                  ),
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.login, size: 32, color: Colors.white),
                    SizedBox(height: 6),
                    Text("Masuk", style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MapsScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 28),
                  backgroundColor: const Color.fromARGB(255, 39, 81, 133),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(35),
                  ),
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.logout, size: 32, color: Colors.white),
                    SizedBox(height: 6),
                    Text("Keluar", style: TextStyle(fontSize: 16)),
                  ],
                ),
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
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))
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
          _historyItem(
            dotColor: Color(0xFF6d1f42),
            title: "Waktu Masuk",
            time: checkInTime ?? "--:--",
          ),
          _historyItem(
            dotColor: Color(0xff275185),
            title: "Waktu Keluar",
            time: checkOutTime ?? "--:--",
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
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 400),
      opacity: 1,
      child: Container(
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
                  decoration:
                      BoxDecoration(color: dotColor, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Text(title,
                    style: const TextStyle(
                        color: Color.fromARGB(255, 92, 92, 92),
                        fontSize: 14)),
              ],
            ),
            Text(time,
                style:
                    const TextStyle(color: Color(0xFF6d1f42), fontSize: 14)),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // PERMIT SECTION (UPDATED)
  // =========================================================
  Widget _permitSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Perizinan",
            style: TextStyle(
              color: Color(0xFF6d1f42),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          Row(
            children: const [
              Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
              SizedBox(width: 4),
              Text("Geser untuk melihat",
                  style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontStyle: FontStyle.italic)),
            ],
          ),

          const SizedBox(height: 12),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var item in permitList)
                  GestureDetector(
                    onTap: () {
                      setState(() => selectedPermit = item["label"]);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(right: 12),
                      width: 110,
                      padding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 12),
                      decoration: BoxDecoration(
                        color: selectedPermit == item["label"]
                            ? const Color(0xffb8cee8)
                            : const Color(0xfff2f2f2),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: const [
                          BoxShadow(
                              color: Color.fromARGB(40, 0, 0, 0),
                              blurRadius: 6,
                              offset: Offset(0, 3))
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(item["icon"],
                              size: 32,
                              color: selectedPermit == item["label"]
                                  ? Colors.white
                                  : Colors.grey[700]),
                          const SizedBox(height: 8),
                          Text(
                            item["label"],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: selectedPermit == item["label"]
                                  ? Colors.white
                                  : Colors.black87,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            "Keterangan Tambahan",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),

          TextField(
            controller: permitNoteC,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "Tuliskan alasan atau detail...",
              filled: true,
              fillColor: Colors.grey[200],
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
            ),
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
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))
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
          Text(label,
              style: const TextStyle(
                color: Color.fromARGB(255, 92, 92, 92),
              )),
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
