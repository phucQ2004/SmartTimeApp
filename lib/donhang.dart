import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DonHangScreen extends StatefulWidget {
  final String idNguoiDung;
  const DonHangScreen({super.key, required this.idNguoiDung});
  @override
  _DonHangScreenState createState() => _DonHangScreenState();
}

class _DonHangScreenState extends State<DonHangScreen> {
  List orders = [];
  List displayOrders = [];
  int selectedTab = 0;
  List<String> LStatus = [];
  late final String idKhachHang;
  late final int _idKhachHang;
  @override
  void initState() {
    super.initState();
    idKhachHang = widget.idNguoiDung;
    _idKhachHang = int.tryParse(idKhachHang) ?? 0;
    // fetchThongTinKhachHang(widget.idNguoiDung);
    // TaoDonHang(_idKhachHang, tenNguoiNhan, diaChi, soDienThoai, ID_phuong_thuc);
    //fetchPTTT();
    fetchAllOrders();
  }

  Future<void> fetchAllOrders() async {
    // Thay thế bằng logic lấy ID_khach_hang của bạn
    try {
      final String apiUrl =
          'http://10.0.2.2:8000/api/donhang/list/$_idKhachHang';
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success']) {
          setState(() {
            orders = responseData['data'];
            displayOrders = List.from(orders);
          });
        } else {
          print("Danh sách không hợp lệ");
        }
      } else {
        print('Yêu cầu thất bại với mã lỗi: ${response.statusCode}');
        setState(() {});
      }
    } catch (e) {
      print('Đã xảy ra lỗi: $e');
      setState(() {});
    }
  }

  // Phương thức để lọc đơn hàng theo trạng thái
  Future<void> filterOrdersByStatus(String status) async {
    try {
      final String apiUrl = 'http://10.0.2.2:8000/api/donhang/filter/$status';
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success']) {
          setState(() {
            displayOrders = responseData['data'];
          });
        } else {
          print("Danh sách không hợp lệ");
        }
      } else {
        print('Yêu cầu thất bại với mã lỗi: ${response.statusCode}');
      }
    } catch (e) {
      print('Đã xảy ra lỗi: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Đơn hàng'),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          // Tab bar section
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTab('Tất cả', 0, 884),
                _buildTab('Chờ xác nhận', 1, 9),
                _buildTab('Đang giao', 2, 104),
                _buildTab('Đã giao', 3, 695),
                _buildTab('Đã hủy', 4, 76),
              ],
            ),
          ),

          Divider(),

          // Search bar section

          // Table header
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                    flex: 2,
                    child: Text('Thông tin đơn hàng',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    child: Text('Ngày tạo',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    child: Text('Trạng thái',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    child: Text('Tổng tiền',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    child: Text('Hành động',
                        style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
          ),

          Divider(),

          // Order list section
          Expanded(
            child: ListView.builder(
              itemCount: 1,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey[300],
                    child: Icon(Icons.person, color: Colors.black),
                  ),
                  title: Text('Khách lẻ'),
                  subtitle: Text('28/09/2022 14:07'),
                  trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('527.000đ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('Đã giao', style: TextStyle(color: Colors.green)),
                    ],
                  ),
                  onTap: () {},
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTab(String title, int index, int count) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = index;
        });
      },
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: selectedTab == index ? Colors.green : Colors.black,
              fontWeight:
                  selectedTab == index ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          SizedBox(height: 4),
          Text(
            '$count',
            style: TextStyle(
              color: selectedTab == index ? Colors.green : Colors.black,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
