import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordController2 = TextEditingController();
  bool isLoading = false;
  bool isPasswordVisible = false;

  // Hàm kiểm tra nhập liệu
  void kiemTraNhapLieu() {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();
    final password2 = passwordController2.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập đầy đủ thông tin đăng ký!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (password.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mật khẩu phải có ít nhất 8 ký tự!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (password != password2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mật khẩu và xác nhận mật khẩu không giống nhau!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    // Gọi hàm đăng ký
    dangKyTaiKhoan();
  }

  // Hàm đăng ký tài khoản
  Future<void> dangKyTaiKhoan() async {
    setState(() {
      isLoading = true;
    });

    final url =
        Uri.parse('http://10.0.2.2:8000/api/register'); // Địa chỉ máy chủ
    final body = jsonEncode({
      "Ten_dang_nhap": usernameController.text.trim(),
      "Mat_khau": passwordController.text.trim(),
      "isAdmin": false,
    });

    try {
      // Gửi yêu cầu POST
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: body,
      );

      // Xử lý phản hồi dựa trên mã trạng thái HTTP
      if (response.statusCode == 201) {
        // Thành công 201
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Tạo tài khoản thành công!'),
            backgroundColor: Colors.green,
          ),
        );

        // Điều hướng đến màn hình đăng nhập
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } else if (response.statusCode == 422) {
        // Lỗi 422: Tên đăng nhập đã tồn tại
        final data = jsonDecode(response.body);
        final errors = data['errors'];
        String errorMessage = 'Tên đăng nhập đã tồn tại!';
        errors.forEach((key, value) {
          errorMessage += '\n$value'; // Hiển thị từng lỗi
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage.trim()),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        // Lỗi không xác định
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi máy chủ: ${response.statusCode}'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      // Lỗi kết nối hoặc lỗi khác
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể kết nối đến máy chủ: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      // Kết thúc tải
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
            const SizedBox(height: 16.0),

            // Nhập lại mật khẩu
            TextField(
              controller: passwordController2,
              decoration: InputDecoration(
                labelText: 'Xác nhận mật khẩu ',
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

            // Nút đăng ký
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: kiemTraNhapLieu,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF040434),
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                    ),
                    child: const Text(
                      'Đăng ký ',
                      style: TextStyle(fontSize: 16.0, color: Colors.white),
                    ),
                  ),
            const SizedBox(height: 16.0),

            // Đã có tài khoản
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // Chuyển đến trang đăng nhập
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()),
                  );
                },
                child: const Row(
                  children: [
                    Text(
                      'Bạn đã có tài khoản ? ',
                      style: TextStyle(color: Colors.blueGrey),
                    ),
                    Text(
                      'Đăng nhập',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
