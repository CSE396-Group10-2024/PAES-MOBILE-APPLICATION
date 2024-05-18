import 'package:flutter/material.dart';
import 'package:cengproject/dbhelper/mongodb.dart';
import 'login_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    initializeApp();
  }

  Future<void> initializeApp() async {
    await MongoDatabase.connect();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            left: mq.width * .3,
            top: mq.height * .3,
            width: mq.width * .4,
            child: Image.asset(
              'images/PAES.png',
              height: 200,
              width: 200,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            bottom: mq.height * .15,
            width: mq.width,
            child: const Text(
              'PAES',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, letterSpacing: 1),
            ),
          ),
        ],
      ),
    );
  }
}
