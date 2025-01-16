import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ChiTietDonHangScreen extends StatefulWidget {
  final int idDonHang;

  const ChiTietDonHangScreen({Key? key, required this.idDonHang})
      : super(key: key);

  @override
  _ChiTietDonHangScreenState createState() => _ChiTietDonHangScreenState();
}

class _ChiTietDonHangScreenState extends State<ChiTietDonHangScreen> {
  bool _isLoading = true;
  String _errorMessage = '';
  Map<String, dynamic> _orderDetails = {};
  final formatter = NumberFormat.currency(locale: 'US', symbol: 'USD');

  @override
  void initState() {
    super.initState();
    _fetchOrderDetails();
  }

  Future<void> _fetchOrderDetails() async {
    final url = Uri.parse(
        'http://10.0.2.2:8000/api/chitietdonhang/${widget.idDonHang}');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _orderDetails = data['data'];
          print("Response data: ${response.body}");
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Lỗi server: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        _errorMessage = 'Lỗi kết nối: $error';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi Tiết Đơn Hàng'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                )
              : _buildOrderDetails(),
    );
  }

  Widget _buildOrderDetails() {
    final donHang = _orderDetails['don_hang'] ?? {};
    final chiTietDonHang = _orderDetails['chi_tiet_don_hang'] ?? [];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          "Mã đơn hàng: ${donHang['ID_don_hang'] ?? 'Không xác định'}",
          style: const TextStyle(fontSize: 18),
        ),
        Text(
          "Tổng tiền: ${formatter.format(donHang['Tong_tien'] ?? 0)}",
          style: const TextStyle(fontSize: 16),
        ),
        Text(
          "Trạng thái: ${donHang['Trang_thai_don_hang'] ?? 'Không xác định'}",
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 20),
        const Text(
          "Danh sách sản phẩm:",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        if (chiTietDonHang.isEmpty)
          const Text(
            "Không có sản phẩm nào.",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ...chiTietDonHang.map<Widget>((item) {
          final sanPham = item['sanPham'] ?? {};
          return ListTile(
            leading: sanPham['Hinh_anh'] != null
                ? Image.network(
                    sanPham['Hinh_anh'],
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  )
                : const Icon(Icons.image_not_supported),
            title: Text(sanPham['Ten'] ?? 'Tên sản phẩm không xác định'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Số lượng: ${item['So_luong'] ?? 0}"),
                Text("Giá: ${formatter.format(item['Gia'] ?? 0)}"),
                Text(
                    "Thành tiền: ${formatter.format(item['Thanh_tien'] ?? 0)}"),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}
