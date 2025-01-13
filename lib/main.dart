import 'package:flutter/material.dart';
import 'package:smart_time/danhmuc.dart';
import 'package:smart_time/giohang.dart';
import 'package:smart_time/login.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: LoginScreen(),
        ),
      ),
    );
  }
}
