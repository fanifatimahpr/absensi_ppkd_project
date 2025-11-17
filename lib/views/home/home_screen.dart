import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  DateTime currentTime = DateTime.now();
  bool isCheckedIn = false;
  String? checkInTime;
  String? checkOutTime;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        currentTime = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  String formatTime(DateTime date) => DateFormat.Hms('id_ID').format(date);
  String formatDate(DateTime date) => DateFormat.yMMMMEEEEd('id_ID').format(date);

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
    final Color primary = const Color(0xFF6D1F42);
    final Color secondary = const Color(0xFFEF6F3C);
    final Color accent = const Color(0xFFEFCE7B);
    final Color pastel = const Color(0xFFD3B6D3);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Greeting Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [primary, secondary]),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: -20,
                    right: -20,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white.withOpacity(0.15),
                    ),
                  ),
                  Positioned(
                    bottom: -20,
                    left: -20,
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white.withOpacity(0.15),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('hai!', style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 4),
                      const Text(
                        'selamat datang kembali!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: const [
                          Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                          SizedBox(width: 4),
                          Text('semangat hari ini ya! 🚀', style: TextStyle(color: Colors.white70)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Real-Time Clock
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))],
              ),
              child: Column(
                children: [
                  Text('waktu sekarang', style: TextStyle(color: primary)),
                  const SizedBox(height: 8),
                  Text(
                    formatTime(currentTime),
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      foreground: Paint()
                        ..shader = LinearGradient(colors: [primary, accent, secondary])
                            .createShader(const Rect.fromLTWH(0, 0, 200, 70)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(formatDate(currentTime), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Attendance Buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: accent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  const Text('jangan lupa absen ya! ⏰', style: TextStyle(color: Color(0xFF6D1F42))),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: isCheckedIn ? null : handleCheckIn,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: 100,
                            decoration: BoxDecoration(
                              gradient: isCheckedIn
                                  ? null
                                  : LinearGradient(colors: [primary, secondary]),
                              color: isCheckedIn ? Colors.grey[300] : null,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.white, width: 4),
                              boxShadow: [
                                BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.login, color: isCheckedIn ? Colors.grey : Colors.white),
                                const SizedBox(height: 4),
                                Text('masuk', style: TextStyle(color: isCheckedIn ? Colors.grey : Colors.white)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GestureDetector(
                          onTap: !isCheckedIn ? null : handleCheckOut,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: 100,
                            decoration: BoxDecoration(
                              gradient: !isCheckedIn
                                  ? null
                                  : LinearGradient(colors: [secondary, primary]),
                              color: !isCheckedIn ? Colors.grey[300] : null,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.white, width: 4),
                              boxShadow: [
                                BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.logout, color: !isCheckedIn ? Colors.grey : Colors.white),
                                const SizedBox(height: 4),
                                Text('keluar', style: TextStyle(color: !isCheckedIn ? Colors.grey : Colors.white)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Attendance History
            if (checkInTime != null || checkOutTime != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
                ),
                child: Column(
                  children: [
                    const Text('riwayat hari ini', style: TextStyle(color: Color(0xFF6D1F42))),
                    const SizedBox(height: 8),
                    if (checkInTime != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: pastel.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                                const SizedBox(width: 8),
                                const Text('absen masuk', style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                            Text(checkInTime!, style: TextStyle(color: primary)),
                          ],
                        ),
                      ),
                    if (checkOutTime != null)
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: secondary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
                                const SizedBox(width: 8),
                                const Text('absen keluar', style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                            Text(checkOutTime!, style: TextStyle(color: primary)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
