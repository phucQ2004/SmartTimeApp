import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DonHangScreen extends StatefulWidget {
  final String idNguoiDung;
  const DonHangScreen({super.key, required this.idNguoiDung});
  @override
  DonHangScreenState createState() => DonHangScreenState();
}

class DonHangScreenState extends State<DonHangScreen> {
  int selectedTab = 0;

  // late final String idKhachHang;
  // late final int _idKhachHang;
  @override
  void initState() {
    super.initState();
    // idKhachHang = widget.idNguoiDung;
    // _idKhachHang = int.tryParse(idKhachHang) ?? 0;
    // fetchThongTinKhachHang(widget.idNguoiDung);
    // TaoDonHang(_idKhachHang, tenNguoiNhan, diaChi, soDienThoai, ID_phuong_thuc);
    //fetchPTTT();
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
