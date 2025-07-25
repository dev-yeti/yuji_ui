import 'package:flutter/material.dart';
import '../session/session_manager.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), () async {
      String? userId = await SessionManager.getUserId();
      if (userId != null && userId.isNotEmpty) {
        // User is logged in, navigate to home
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // User is not logged in, navigate to login
        Navigator.pushReplacementNamed(context, '/login');
      }
      
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/yuji_splash.png',
              fit: BoxFit.cover,
            ),
            const Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: 48),
                child: CircularProgressIndicator(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

