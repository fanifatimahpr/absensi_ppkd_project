import 'package:flutter/material.dart';

class BottomNavAbsensi extends StatefulWidget {
  const BottomNavAbsensi({super.key});

  @override
  State<BottomNavAbsensi> createState() => _BottomNavAbsensiState();
}

class _BottomNavAbsensiState extends State<BottomNavAbsensi> {
  int currentIndex = 0;

  final List<Widget> pages = const [
    Center(child: Text("Home Page")),
    Center(child: Text("Perizinan Page")),
    Center(child: Text("Maps Page")),
    Center(child: Text("Profile Page")),
  ];

  final List<Color> activeColors = const [
    Color(0xff6d1f42),
    Color(0xffd3b6d3),
    Color(0xffefce7b),
    Color(0xffef6f3c),
  ];

  final List<IconData> icons = const [
    Icons.home_rounded,
    Icons.assignment_rounded,
    Icons.map_rounded,
    Icons.person_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // allow floating effect
      body: pages[currentIndex],

      // ------------------ FLOATING NAVIGATION BAR ------------------
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 24, left: 20, right: 20),
        child: Container(
          height: 75,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(35),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(4, (index) {
              final isActive = index == currentIndex;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    currentIndex = index;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutBack,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isActive ? activeColors[index].withOpacity(.2) : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: AnimatedScale(
                    scale: isActive ? 1.3 : 1.0,
                    duration: const Duration(milliseconds: 250),
                    child: Icon(
                      icons[index],
                      size: isActive ? 30 : 26,
                      color: isActive ? activeColors[index] : Colors.grey.shade500,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
