import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
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
      appBar: AppBar(
        backgroundColor: const Color(0xFF6D1F42),
        title: const Text(
          "Riwayat Absen",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Stack(
        children: [
          /// ---- CONTENT ----
          Padding(
            padding: const EdgeInsets.only(top: 70),
            child: TabBarView(
              controller: tabController,
              children: [
                _buildHistoryList(filterDays(7)),
                _buildHistoryList(filterDays(60)),
                _buildHistoryList(filterDays(90)),
              ],
            ),
          ),

          /// ---- FLOATING TAB BAR ----
          Positioned(
            top: 10,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 55,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: TabBar(
                controller: tabController,
                indicator: const UnderlineTabIndicator(
                  borderSide: BorderSide(width: 3, color: Color(0xFF6D1F42)),
                  insets: EdgeInsets.only(left: 30, right: 30),
                ),
                unselectedLabelColor: const Color(0xFF6D1F42),
                tabs: const [
                  Tab(text: "7 Hari"),
                  Tab(text: "60 Hari"),
                  Tab(text: "90 Hari"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ------ LIST BUILDER -------
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
      padding: const EdgeInsets.all(20),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_month, color: Color(0xFF6D1F42)),
                  const SizedBox(width: 8),
                  Text(
                    formatDate(item['date']),
                    style: const TextStyle(
                      color: Color(0xFF6D1F42),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              _historyRow(
                icon: Icons.login_rounded,
                title: "Masuk",
                value: item['checkIn'],
                color: const Color(0xFF6D1F42),
              ),

              const SizedBox(height: 8),

              _historyRow(
                icon: Icons.logout_rounded,
                title: "Keluar",
                value: item['checkOut'],
                color: const Color(0xff2A4D7F),
              ),
            ],
          ),
        );
      },
    );
  }

  /// ------ ROW ITEM ------
  Widget _historyRow({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// ---- UTIL FORMAT ----
  String formatDate(DateTime date) {
    return DateFormat('dd MMMM yyyy', 'id_ID').format(date);
  }

  List<Map<String, dynamic>> filterDays(int days) {
    final now = DateTime.now();

    final list = [
      {'date': now, 'checkIn': "08:00", 'checkOut': "16:00"},
      {
        'date': now.subtract(const Duration(days: 3)),
        'checkIn': "08:12",
        'checkOut': "16:20",
      },
    ];

    return list.where((e) {
      final date = e['date'] as DateTime?;
      if (date == null) return false;

      return date.isAfter(now.subtract(Duration(days: days)));
    }).toList();
  }
}
