import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'chinhsuaTTCN.dart';

class ThongTinCaNhanScreen extends StatefulWidget {
  final String idNguoiDung;

  const ThongTinCaNhanScreen({super.key, required this.idNguoiDung});

  @override
  _ThongTinCaNhanScreenState createState() => _ThongTinCaNhanScreenState();
}

class _ThongTinCaNhanScreenState extends State<ThongTinCaNhanScreen> {
  String? tenKhachHang;
  String? email;
  String? soDienThoai;
  String? ngaySinh;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchThongTinKhachHang(widget.idNguoiDung);
  }

  String _formatDate(String rawDate) {
    try {
      // Chuyển chuỗi thành DateTime
      final DateTime parsedDate = DateTime.parse(rawDate);
      // Định dạng ngày thành dd/MM/yyyy
      return DateFormat('dd/MM/yyyy').format(parsedDate);
    } catch (e) {
      return 'Không hợp lệ'; // Trường hợp dữ liệu không đúng định dạng
    }
}

  // Hàm lấy thông tin khách hàng từ API
  Future<void> fetchThongTinKhachHang(String idNguoiDung) async {

    final url = Uri.parse('http://10.0.2.2:8000/api/khachhang/$idNguoiDung');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success']) {
          final data = responseData['data'];
          setState(() {
            tenKhachHang = data['Ten_day_du'];
            email = data['Email'];
            soDienThoai = data['So_dien_thoai'];
            // Xử lý ngày sinh
            final rawNgaySinh = data['Ngay_sinh'];
            if (rawNgaySinh != null && rawNgaySinh is String) {
              final DateTime parsedNgaySinh = DateTime.parse(rawNgaySinh);
              ngaySinh = DateFormat('dd/MM/yyyy').format(parsedNgaySinh);
            } else {
              ngaySinh = 'Chưa cập nhật';
            }

          });
        } else {
          setState(() {
            tenKhachHang = null; // Không có thông tin khách hàng
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(responseData['message']),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi máy chủ: ${response.statusCode}'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể kết nối đến máy chủ: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Thông Tin Cá Nhân',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          backgroundColor: Color(0xFF040434),
          leading: IconButton(
            icon: Icon(Icons.undo, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : tenKhachHang == null
                ? const Center(
                    child: Text(
                      'Chưa có thông tin khách hàng.',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Color(0xFF040434), width: 2), // Viền màu xanh
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: SizedBox(
                          width: 350, // Cố định chiều rộng
                          height: 500, // Cố định chiều cao
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 8,
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(
                                    child: const Image(
                                      image: AssetImage('images/logo.png'),
                                      height: 120,
                                      width: 120,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Expanded(
                                    child: SingleChildScrollView(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          buildInfoRow('Tên', tenKhachHang ?? 'Chưa cập nhật'),
                                          Divider(height: 1, color: Colors.grey),
                                          buildInfoRow('Email', email ?? 'Chưa cập nhật'),
                                          Divider(height: 1, color: Colors.grey),
                                          buildInfoRow('Số điện thoại', soDienThoai ?? 'Chưa cập nhật'),
                                          Divider(height: 1, color: Colors.grey),
                                          buildInfoRow('Ngày sinh', ngaySinh ?? 'Chưa cập nhật'),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Center(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(0xFF040434), // Màu nút
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                      ),
                                      onPressed: () {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(builder: (context) => CapNhatThongTinScreen(idNguoiDung: widget.idNguoiDung)),
                                        );
                                      },
                                      child: const Text(
                                        'Chỉnh sửa thông tin',
                                        style: TextStyle(fontSize: 16, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
      );
    }

    Widget buildInfoRow(String title, String value) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$title:',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            Flexible(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  color: value == 'Chưa cập nhật' ? Colors.grey : Colors.black,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

}
