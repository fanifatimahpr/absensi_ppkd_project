import 'package:flutter/material.dart';

class PermitScreen extends StatefulWidget {
  const PermitScreen({super.key});

  @override
  State<PermitScreen> createState() => _PermitScreenState();
}

class _PermitScreenState extends State<PermitScreen> {
  int selectedIndex = -1;

  final List<Map<String, dynamic>> permitList = [
    {"icon": Icons.sick, "label": "Sakit"},
    {"icon": Icons.work_off, "label": "Izin"},
    {"icon": Icons.directions_walk, "label": "Dinas Luar"},
    {"icon": Icons.airplane_ticket, "label": "Cuti"},
    {"icon": Icons.watch_later, "label": "Lembur"},
  ];

  final TextEditingController permitNoteC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      body: Stack(
        children: [
          _backgroundDecor(),

          Positioned(
            top: 40,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Pengajuan Izin",
                  style: TextStyle(
                    color: Color(0xFF6D1F42),
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Pilih jenis izin yang ingin diajukan",
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                  ),
                )
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(top: 130),
            child: _contentSection(),
          )
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // CONTENT
  // --------------------------------------------------------------------------
  Widget _contentSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _permitCards(),

          const SizedBox(height: 30),

          const Text(
            "Keterangan",
            style: TextStyle(
              color: Color(0xFF6D1F42),
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                    color: Colors.black12, blurRadius: 8, offset: Offset(0, 5))
              ],
            ),
            child: TextField(
              controller: permitNoteC,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Tuliskan alasan izin...",
                border: InputBorder.none,
              ),
            ),
          ),

          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // submit izin
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6D1F42),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
                elevation: 6,
                shadowColor: const Color(0xFF6D1F42).withOpacity(.4),
              ),
              child: const Text(
                "Kirim Izin",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // PERMIT OPTIONS
  // --------------------------------------------------------------------------
  Widget _permitCards() {
    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: permitList.length,
        itemBuilder: (context, index) {
          final item = permitList[index];
          final bool active = selectedIndex == index;

          return GestureDetector(
            onTap: () => setState(() => selectedIndex = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 18),
              padding: const EdgeInsets.all(18),
              width: 130,
              decoration: BoxDecoration(
                color: active
                    ? const Color(0xffb8cee8)
                    : Colors.white,
                borderRadius: BorderRadius.circular(36),
                border: Border.all(
                  color: active
                      ? Color(0xff275185)
                      : Colors.grey.shade300,
                  // width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    item["icon"],
                    size: 36,
                    color: active
                        ? Color(0xff275185)
                        : const Color(0xffb8cee8),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    item["label"],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Color(0xff275185),
                    ),
                  )
                ],
              ),
            ),
          );
        },
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
      decoration:
          BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
