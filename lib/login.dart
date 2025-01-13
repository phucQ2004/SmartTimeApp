import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'danhmuc.dart';
import 'register.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  bool isPasswordVisible = false;

  // Hàm kiểm tra nhập liệu
  void kiemTraNhapLieu() {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập đầy đủ tên đăng nhập và mật khẩu!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    login();
  }

  // Hàm đăng nhập
  Future<void> login() async {
    setState(() {
      isLoading = true;
    });

    final url = Uri.parse('http://10.0.2.2:8000/api/login');
    final body = jsonEncode({
      "Ten_dang_nhap": usernameController.text.trim(),
      "Mat_khau": passwordController.text.trim(),
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          String idNguoiDung = data['data']['ID_nguoi_dung']
              .toString(); // Lấy id người dùng từ API
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message']),
              backgroundColor: Colors.green,
            ),
          );
          // Điều hướng đến màn hình danh mục
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => DanhMucScreen(idNguoiDung: idNguoiDung)),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message']),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        // Xử lý lỗi khi không phải mã 200
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
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Logo
            const Image(
              image: AssetImage('images/logo.jpg'),
              height: 150,
              width: 150,
            ),
            const SizedBox(height: 40.0),

            // Tên đăng nhập
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: 'Tên đăng nhập',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),

            // Mật khẩu
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Mật khẩu',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      isPasswordVisible = !isPasswordVisible;
                    });
                  },
                ),
              ),
              obscureText: !isPasswordVisible,
            ),
            const SizedBox(height: 30.0),

            // Nút đăng nhập
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: kiemTraNhapLieu,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF040434),
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                    ),
                    child: const Text(
                      'Đăng nhập',
                      style: TextStyle(fontSize: 16.0, color: Colors.white),
                    ),
                  ),
            const SizedBox(height: 16.0),

            // Chưa có tài khoản
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                  onPressed: () {
                    // Chuyển đến trang đăng ký
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RegisterScreen()),
                    );
                  },
                  child: const Row(children: [
                    Text(
                      'Bạn chưa có tài khoản ? ',
                      style: TextStyle(color: Colors.blueGrey),
                    ),
                    Text(
                      'Đăng ký',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ])),
            ),
          ],
        ),
      ),
    );
  }
}
