import 'package:flutter/material.dart';
import 'package:flutter_project_ppkd/data/local/preference_handler.dart';
import 'package:flutter_project_ppkd/service/api.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  List<Map<String, dynamic>> rawAttendance = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
    loadData();
  }


  // LOAD DATA AMAN (ANTI ERROR FORMAT API)

  Future<void> loadData() async {
  try {
    setState(() => isLoading = true);

    // 1. MUAT DARI LOCAL DULU
    rawAttendance = await PreferenceHandler.getHistory();

    // 2. MUAT DARI API DAN TIMPA LOCAL
    final apiData = await AuthAPI.getAttendanceHistory(90);

    if (apiData is List) {
      rawAttendance = apiData;
    }

  } catch (e) {
    debugPrint("Error load attendance: $e");
  }

  if (mounted) {
    setState(() => isLoading = false);
  }
}

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      body: Stack(
        children: [
          _backgroundDecor(),

          /// TITLE + TAB
          Positioned(
            top: 40,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Riwayat Absensi",
                  style: TextStyle(
                    color: Color(0xFF6D1F42),
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 14),
                _tabBar(),
              ],
            ),
          ),

          /// CONTENT
          Padding(
            padding: const EdgeInsets.only(top: 150),
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: tabController,
                    children: [
                      _buildHistoryList(_filterDays(7)),
                      _buildHistoryList(_filterDays(60)),
                      _buildHistoryList(_filterDays(90)),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // TAB BAR
  // --------------------------------------------------------------------------
  Widget _tabBar() {
    return TabBar(
      controller: tabController,
      labelColor: const Color(0xFF6D1F42),
      unselectedLabelColor: const Color(0xFF6D1F42).withOpacity(.5),
      labelStyle: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 14,
      ),
      indicator: const UnderlineTabIndicator(
        borderSide: BorderSide(
          color: Color(0xFF6D1F42),
          width: 3,
        ),
        insets: EdgeInsets.symmetric(horizontal: 20),
      ),
      tabs: const [
        Tab(text: "7 Hari"),
        Tab(text: "60 Hari"),
        Tab(text: "90 Hari"),
      ],
    );
  }

  // --------------------------------------------------------------------------
  // SAFE DATE PARSER
  // --------------------------------------------------------------------------
  DateTime? _safeParseDate(String date) {
    try {
      return DateTime.parse(date);
    } catch (e) {
      return null;
    }
  }

  // --------------------------------------------------------------------------
  // GROUP DATA DAN FILTER
  List<Map<String, dynamic>> _filterDays(int days) {
  final now = DateTime.now();
  Map<String, Map<String, dynamic>> grouped = {};

  for (var item in rawAttendance) {
    String date = item["date"];
    DateTime? d = _safeParseDate(date);
    if (d == null) continue;

    // Filter range hari
    if (d.isBefore(now.subtract(Duration(days: days)))) continue;

    // Buat grup per tanggal
    if (!grouped.containsKey(date)) {
      grouped[date] = {
        "date": d,
        "checkIn": "--:--",
        "checkOut": "--:--",
      };
    }

    // Isi data sesuai tipe
    if (item["type"] == "in") {
      grouped[date]!["checkIn"] = item["time"] ?? "--:--";
    } else if (item["type"] == "out") {
      grouped[date]!["checkOut"] = item["time"] ?? "--:--";
    }
  }

  // urutkan dari terbaru ke terlama
  final list = grouped.values.toList()
    ..sort((a, b) => b["date"].compareTo(a["date"]));

  return list;
}

  // LIST UI
  Widget _buildHistoryList(List<Map<String, dynamic>> list) {
    if (list.isEmpty) {
      return const Center(
        child: Text(
          "Belum ada riwayat absen.",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _dateHeader(item['date']),
              const SizedBox(height: 22),

              _historyItem(
                color: const Color(0xFF6D1F42),
                title: "Waktu Masuk",
                time: item['checkIn'],
              ),
              const SizedBox(height: 16),

              _historyItem(
                color: const Color(0xFF275185),
                title: "Waktu Keluar",
                time: item['checkOut'],
              ),
            ],
          ),
        );
      },
    );
  }

  // --------------------------------------------------------------------------
  // DATE HEADER
  // --------------------------------------------------------------------------
  Widget _dateHeader(DateTime date) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF6D1F42).withOpacity(.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.calendar_month,
            size: 22,
            color: Color(0xFF6D1F42),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(date),
          style: const TextStyle(
            color: Color(0xFF6D1F42),
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  // --------------------------------------------------------------------------
  // ITEM UI
  // --------------------------------------------------------------------------
  Widget _historyItem({
    required Color color,
    required String title,
    required String time,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(.18),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(.15),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              Icons.access_time_filled,
              size: 20,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6D1F42),
              ),
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // BACKGROUND DECORATION
  // --------------------------------------------------------------------------
  Widget _backgroundDecor() {
    return Stack(
      children: [
        Positioned(
          top: -120,
          right: -80,
          child: _circle(280, const Color(0xFFD3B6D3).withOpacity(.25)),
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
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
