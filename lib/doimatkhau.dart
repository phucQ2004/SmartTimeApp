import 'package:flutter/material.dart';

class DoiMatKhauScreen extends StatelessWidget {
  final String idNguoiDung;

  const DoiMatKhauScreen({super.key, required this.idNguoiDung});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Đổi mật khẩu",
          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF040434),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 8.0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Thay đổi mật khẩu của bạn",
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Color(0xFF040434),
              ),
            ),
            const SizedBox(height: 30.0),
            // Input mật khẩu hiện tại
            _buildPasswordField('Mật khẩu hiện tại', Icons.lock_outline),
            const SizedBox(height: 20.0),
            // Input mật khẩu mới
            _buildPasswordField('Mật khẩu mới', Icons.lock_reset),
            const SizedBox(height: 20.0),
            // Input xác nhận mật khẩu mới
            _buildPasswordField('Xác nhận mật khẩu mới', Icons.lock),
            const SizedBox(height: 40.0),
            // Nút xác nhận
            ElevatedButton(
              onPressed: () {
                // Xử lý logic đổi mật khẩu
                print("ID người dùng: $idNguoiDung");
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF040434),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0), // Bo tròn nút
                ),
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 40.0),
                elevation: 10,
                shadowColor: Colors.black.withOpacity(0.3),
              ),
              child: const Center(
                child: Text(
                  "Xác nhận",
                  style: TextStyle(fontSize: 16.0, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2, // Tập trung vào tab "Thông tin"
        onTap: (index) {
          if (index == 0) {
            // Chuyển sang màn hình danh mục
          } else if (index == 1) {
            // Chuyển sang màn hình giỏ hàng
          } else if (index == 2) {
            Navigator.pop(context); // Quay lại thông tin khách hàng
          }
        },
        selectedItemColor: const Color(0xFF040434),
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
            icon: Icon(Icons.person),
            label: 'Thông tin',
          ),
        ],
      ),
    );
  }

  // Hàm xây dựng trường nhập mật khẩu với các thông số chung
  Widget _buildPasswordField(String label, IconData icon) {
    return TextField(
      obscureText: true,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 16.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        prefixIcon: Icon(icon),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF040434), width: 2.0),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 12.0),
      ),
    );
  }
}
