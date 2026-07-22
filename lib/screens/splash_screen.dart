import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () {
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
    return Scaffold(
      backgroundColor: Color(0xFFFDF6E3),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lightbulb, size: 120, color: Colors.amber),
            SizedBox(height: 24),
            Text('akshara', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
            Text(
              'Learn Indian languages\nthe fun way!',
              style: TextStyle(fontSize: 20, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
