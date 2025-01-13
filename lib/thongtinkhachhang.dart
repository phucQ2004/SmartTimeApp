import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ThongTinKhachHangScreen extends StatefulWidget {
  final String idNguoiDung;

  const ThongTinKhachHangScreen({super.key, required this.idNguoiDung});

  @override
  _ThongTinKhachHangScreenState createState() => _ThongTinKhachHangScreenState();
}

class _ThongTinKhachHangScreenState extends State<ThongTinKhachHangScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thông tin khách hàng'),
      ),
      body: Center(
        child: Text('ID người dùng của bạn: ${widget.idNguoiDung}'),
      ),
    );
  }
}
