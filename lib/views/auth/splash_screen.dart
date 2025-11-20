import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project_ppkd/data/local/preference_handler.dart';
import 'package:flutter_project_ppkd/views/auth/bottom_nav.dart';
import 'package:flutter_project_ppkd/views/auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 3));

    bool isLogin = await PreferenceHandler.isLoggedIn();
    Map<String, dynamic>? user = await PreferenceHandler.getUserData();

    if (!mounted) return;

    print("DEBUG: isLogin=$isLogin");
    print("DEBUG: userData=$user");

    if (isLogin && user != null) {
      // Sudah login → arahkan ke Home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreenAbs()), 
        
      );
    } else {
      // Belum login → arahkan ke halaman login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreenAbs()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xff6d1f42), Color(0xffd3b6d3)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Image.asset(
                'assets/images/Snaptrack 512.png',
                height: 160,
                width: 160,
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              "Snaptrack",
              style: TextStyle(
                color: Color.fromARGB(255, 255, 255, 255),
                fontSize: 34,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
