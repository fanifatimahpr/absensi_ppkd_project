import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_project_ppkd/data/local/preference_handler.dart';
import 'package:flutter_project_ppkd/service/api.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
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
  String? userId;
  String name = "User";
  String greeting = "";
  String today = "";

  // Absensi
  bool isCheckedIn = false;
  String? checkInTime;
  String? checkOutTime;
  String? checkInLocation;
  String? checkOutLocation;

  // Lokasi
  LatLng? currentPosition;
  String? currentAddress = "Mendeteksi lokasi...";

  late AnimationController _animController;

  String _getInitials(String name) {
  if (name.trim().isEmpty) return "?";

  List<String> parts = name.trim().split(" ");
  if (parts.length == 1) {
    return parts.first[0].toUpperCase();
  }

  return (parts[0][0] + parts[1][0]).toUpperCase();
}


  @override
void initState() {
  super.initState();
  initUser();
  getGreeting();
  getToday();
  _initLocation();

  currentTime = DateTime.now();
  timer = Timer.periodic(const Duration(seconds: 1), (_) {
    setState(() => currentTime = DateTime.now());
  });

  _loadLocalAttendance();   // ⬅ TAMBAHAN PENTING
  _loadTodayAttendance();   // ⬅ API tetap dipanggil

  _animController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );
  _animController.forward();
}
// 🔥 LOAD LOCAL DATA DULU
void _loadLocalAttendance() async {
  final saved = await PreferenceHandler.getTodayAttendance();
  if (saved == null) return;

  setState(() {
    checkInTime = saved["check_in"];
    checkOutTime = saved["check_out"];
    checkInLocation = saved["check_in_location"];
    checkOutLocation = saved["check_out_location"];
    isCheckedIn = checkInTime != null && checkOutTime == null;
  });
}


  @override
  void dispose() {
    timer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  // LOAD USER
 Future<void> initUser() async {
  final user = await PreferenceHandler.getUserData();

  setState(() {
    name = user?["name"] ?? "User";
  });
}


  void getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) greeting = "Selamat Pagi ☀️";
    else if (hour < 17) greeting = "Selamat Siang 🌤️";
    else greeting = "Selamat Malam 🌙";
  }

  void getToday() {
    today = DateFormat("EEEE, dd MMMM yyyy", "id_ID").format(DateTime.now());
  }

  // GPS LOCATION
  Future<void> _initLocation() async {
    bool enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    Position pos = await Geolocator.getCurrentPosition();

    setState(() {
      currentPosition = LatLng(pos.latitude, pos.longitude);
    });

    final place = await placemarkFromCoordinates(pos.latitude, pos.longitude);

    setState(() {
      currentAddress =
          "${place.first.street}, ${place.first.subLocality}, ${place.first.locality}";
    });
  }

  String formatTime(DateTime date) =>
      DateFormat('HH:mm', 'id_ID').format(date);

  String formatDate(DateTime date) =>
      DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(date);

  // ABSEN MASUK
 void handleCheckIn() async {
  if (currentPosition == null) return;

  String time = formatTime(DateTime.now());
  String date = DateFormat("yyyy-MM-dd").format(DateTime.now());

  final body = {
    "attendance_date": date,
    "check_in": time,
    "check_in_lat": currentPosition!.latitude,
    "check_in_lng": currentPosition!.longitude,
    "check_in_address": currentAddress,
    "status": "masuk",
  };

  final response = await AuthAPI.checkIn(body);

  setState(() {
    checkInTime = time;
    checkInLocation = currentAddress;
  });

  // 🔥 SIMPAN LOKAL
  await PreferenceHandler.saveTodayAttendance({
    "check_in": time,
    "check_out": checkOutTime,
    "check_in_location": checkInLocation,
    "check_out_location": checkOutLocation,
  });
}

  // ABSEN KELUAR
 void handleCheckOut() async {
  if (currentPosition == null) return;

  String time = formatTime(DateTime.now());
  String date = DateFormat("yyyy-MM-dd").format(DateTime.now());

  final body = {
    "attendance_date": date,
    "check_out": time,
    "check_out_lat": currentPosition!.latitude,
    "check_out_lng": currentPosition!.longitude,
    "check_out_address": currentAddress,
  };

  final response = await AuthAPI.checkOut(body);

  setState(() {
    checkOutTime = time;
    checkOutLocation = currentAddress;
  });

  // 🔥 SIMPAN LOKAL
  await PreferenceHandler.saveTodayAttendance({
    "check_in": checkInTime,
    "check_out": time,
    "check_in_location": currentAddress,
    "check_out_location": currentAddress,
  });
}

  // LOAD Riwayat Hari Ini
 void _loadTodayAttendance() async {
  final res = await AuthAPI.getTodayAttendance();

  if (res == null || res.data == null) return;

  final d = res.data!;

  setState(() {
    checkInTime = d.checkInTime;
    checkOutTime = d.checkOutTime;
    checkInLocation = d.checkInAddress;
    checkOutLocation = d.checkOutAddress;
    isCheckedIn = d.checkInTime != null && d.checkOutTime == null;
  });

  await PreferenceHandler.saveTodayAttendance({
    "check_in": d.checkInTime,
    "check_out": d.checkOutTime,
    "check_in_location": d.checkInAddress,
    "check_out_location": d.checkOutAddress,
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _greetingCard(),
              const SizedBox(height: 20),
              _clockCard(),        // ⬅ MAP MASUK DI DALAM CARD INI
              const SizedBox(height: 20),
              _attendanceButtons(),
              const SizedBox(height: 20),
              _attendanceHistory(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _greetingCard() {
    return Row(
      children: [
        Container(
          width: 65,
          height: 65,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Color(0xff6D1F42), width: 2),
            color: const Color(0xff6D1F42), // background avatar
          ),
          alignment: Alignment.center,
          child: Text(
            _getInitials(name),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(greeting,
                style: const TextStyle(
                    color: Color(0xff6D1F42),
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
            Text(name,
                style: const TextStyle(
                    color: Color(0xff6D1F42),
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
            Text(today, style: const TextStyle(color: Colors.grey)),
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
          blurRadius: 6,
          offset: const Offset(0, 3),
        )
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// ===================== HEADER CLOCK =====================
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            /// --- text Hari Ini + waktu + tanggal
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6D1F42).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "Hari Ini",
                    style: TextStyle(
                      color: Color(0xFF6D1F42),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                Text(
                  formatTime(currentTime),
                  style: const TextStyle(
                    fontSize: 42,
                    color: Color(0xFF6D1F42),
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 16, color: Color(0xFF6D1F42)),
                    const SizedBox(width: 6),
                    Text(
                      formatDate(currentTime),
                      style: const TextStyle(
                        color: Color(0xFF6D1F42),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF6D1F42).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.access_time_filled,
                size: 42,
                color: Color(0xFF6D1F42),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        /// MINI MAP 
        ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Container(
            height: 160,
            color: Colors.white,
            child: currentPosition == null
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF6D1F42),
                    ),
                  )
                : GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: currentPosition!,
                      zoom: 16,
                    ),
                    markers: {
                      Marker(
                        markerId: const MarkerId("me"),
                        position: currentPosition!,
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueRose,
                        ),
                      ),
                    },
                    myLocationEnabled: true,
                    zoomControlsEnabled: false,
                  ),
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
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF275185).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "Absen",
                    style: TextStyle(
                      color:  Color(0xFF275185),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
        const SizedBox(height: 20),

        Row(
          children: [
            //BUTTON MASUK
            Expanded(
              child: ElevatedButton(
                onPressed: handleCheckIn,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 22),
                  backgroundColor: const Color(0xFF275185),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(35),
                  ),
                  elevation: 3,
                ),
                child: Column(
                  children: const [
                    Icon(Icons.login, size: 28, color: Colors.white),
                    SizedBox(height: 8),
                    Text(
                      "Masuk",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 12),

            // BUTTON KELUAR
            Expanded(
              child: ElevatedButton(
                onPressed:  handleCheckOut,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 22),
                  backgroundColor: const Color(0xFF275185),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(35),
                  ),
                  elevation: 3,
                ),
                child: Column(
                  children: const [
                    Icon(Icons.logout, size: 28, color: Colors.white),
                    SizedBox(height: 8),
                    Text(
                      "Keluar",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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

  // RIWAYAT ABSENSI
  Widget _attendanceHistory() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Riwayat Hari Ini",
                style: TextStyle(
                    color: Color(0xFF6d1f42),
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            _historyItem(
                dotColor: Color(0xFF6d1f42),
                title: "Waktu Masuk",
                time: checkInTime ?? "--:--",
                location: checkInLocation ?? "-"),

            _historyItem(
                dotColor: Color(0xff275185),
                title: "Waktu Keluar",
                time: checkOutTime ?? "--:--",
                location: checkOutLocation ?? "-"),
          ]),
    );
  }

 Widget _historyItem({
  required Color dotColor,
  required String title,
  required String time,
  required String location,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 14),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: dotColor.withOpacity(0.18),
      borderRadius: BorderRadius.circular(32),
      boxShadow: [
        BoxShadow(
          color: Colors.black12.withOpacity(0.05),
          blurRadius: 6,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ---------------------- HEADER (DOT + TITLE)
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF6D1F42),
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // ---------------------- TIME ROW
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF6D1F42).withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.access_time_filled,
                  size: 18, color: Color(0xFF6D1F42)),
            ),
            const SizedBox(width: 10),
            Text(
              time,
              style: const TextStyle(
                color: Color(0xFF6D1F42),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // LOCATION ROW
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF6D1F42).withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.location_on_rounded,
                  size: 18, color: Color(0xFF6D1F42)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                location,
                style: const TextStyle(
                  color: Color(0xFF6D1F42),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

}
