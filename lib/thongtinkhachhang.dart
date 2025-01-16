import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'danhmuc.dart';
import 'login.dart';
import 'giohang.dart';
import 'thongtincanhan.dart';
import 'thongtindiachi.dart';
import 'donhang.dart';

class ThongTinKhachHangScreen extends StatefulWidget {
  final String idNguoiDung;

  const ThongTinKhachHangScreen({super.key, required this.idNguoiDung});

  @override
  _ThongTinKhachHangScreenState createState() =>
      _ThongTinKhachHangScreenState();
}

class _ThongTinKhachHangScreenState extends State<ThongTinKhachHangScreen> {
  String? username;
  bool isLoading = true;
  int _currentIndex = 3; // Quản lý tab hiện tại

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      DanhMucScreen(idNguoiDung: widget.idNguoiDung),
      GioHangScreen(idNguoiDung: widget.idNguoiDung),
      DonHangScreen(idNguoiDung: widget.idNguoiDung),
      ThongTinKhachHangScreen(idNguoiDung: widget.idNguoiDung),
    ];
    fetchUsername(widget.idNguoiDung);
  }

  // Hàm lấy tên đăng nhập dựa trên idNguoiDung
  Future<void> fetchUsername(String idNguoiDung) async {
    final url = Uri.parse('http://10.0.2.2:8000/api/nguoidung/$idNguoiDung');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success']) {
          setState(() {
            username = responseData['data']['Ten_dang_nhap'];
          });
        } else {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 30),
            Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF040434),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Image(
                      image: AssetImage('images/logo.jpg'),
                      height: 100,
                      width: 100,
                    ),
                    SizedBox(width: 10),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$username',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Container(
                          padding:
                              EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Color(0xFF040434)),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            'Thành viên',
                            style: TextStyle(color: Color(0xFF040434)),
                          ),
                        )
                      ],
                    ),
                  ],
                )),
            SizedBox(height: 20),
            Divider(
              color: Color(0xFF040434),
              thickness: 1,
            ),
            SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ThongTinCaNhanScreen(idNguoiDung: widget.idNguoiDung),
                    ),
                  );
                },
                icon: Icon(Icons.info_outline_rounded, color: Colors.white),
                label: const Text(
                  'Thông tin cá nhân',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF040434),
                ),
              ),
            ),
            SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ThongTinDiaChiScreen(idNguoiDung: widget.idNguoiDung),
                    ),
                  );
                },
                icon: Icon(Icons.location_on_outlined, color: Colors.white),
                label: const Text(
                  'Thông tin địa chỉ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF040434),
                ),
              ),
            ),
            SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Add functionality here
                },
                icon: Icon(Icons.lock_clock_outlined, color: Colors.white),
                label: const Text(
                  'Đổi mật khẩu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF040434),
                ),
              ),
            ),
            SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  bool shouldLogout = await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        content: const Text(
                          'Đăng xuất khỏi tài khoản của bạn?',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            },
                            child: const Text(
                              'Hủy',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(true);
                            },
                            child: const Text(
                              'Đăng xuất',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                  if (shouldLogout) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginScreen(),
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đã đăng xuất tài khoản'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                icon: Icon(Icons.logout_rounded, color: Colors.white),
                label: const Text(
                  'Đăng xuất',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF040434),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          // Điều hướng đến màn hình tương ứng
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    DanhMucScreen(idNguoiDung: widget.idNguoiDung),
              ),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => GioHangScreen(
                    idNguoiDung: widget.idNguoiDung), // Màn hình giỏ hàng
              ),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => DonHangScreen(
                    idNguoiDung: widget.idNguoiDung), // Màn hình đơn hàng
              ),
            );
          } else if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ThongTinKhachHangScreen(
                    idNguoiDung: widget.idNguoiDung), // Truyền tên đăng nhập
              ),
            );
          }
        },
        selectedItemColor: Color(0xFF040434),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Danh mục',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Giỏ hàng',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping),
            label: 'Đơn hàng',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Thông tin',
          ),
        ],
      ),
    );
  }
}
