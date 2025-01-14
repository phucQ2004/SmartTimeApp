import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // Thêm gói intl để xử lý định dạng ngày

class CapNhatThongTinScreen extends StatefulWidget {
  final String idNguoiDung;

  const CapNhatThongTinScreen({super.key, required this.idNguoiDung});

  @override
  _CapNhatThongTinScreenState createState() => _CapNhatThongTinScreenState();
}

class _CapNhatThongTinScreenState extends State<CapNhatThongTinScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _tenController;
  late TextEditingController _emailController;
  late TextEditingController _soDienThoaiController;
  late TextEditingController _ngaySinhController;

  Map<String, dynamic> originalData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tenController = TextEditingController();
    _emailController = TextEditingController();
    _soDienThoaiController = TextEditingController();
    _ngaySinhController = TextEditingController();
    fetchThongTinKhachHang();
  }

  @override
  void dispose() {
    _tenController.dispose();
    _emailController.dispose();
    _soDienThoaiController.dispose();
    _ngaySinhController.dispose();
    super.dispose();
  }

  Future<void> fetchThongTinKhachHang() async {
    final url = Uri.parse('http://10.0.2.2:8000/api/khachhang/${widget.idNguoiDung}');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success']) {
          setState(() {
            originalData = responseData['data'];
            _tenController.text = originalData['Ten_day_du'] ?? '';
            _emailController.text = originalData['Email'] ?? '';
            _soDienThoaiController.text = originalData['So_dien_thoai'] ?? '';
            _ngaySinhController.text = _convertDateForDisplay(originalData['Ngay_sinh']);
            isLoading = false;
          });
        }
      } else {
        _showSnackBar('Không thể tải thông tin người dùng', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Lỗi kết nối: $e', Colors.red);
    }
  }

  String? _validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ngày sinh không được để trống';
    }
    try {
      DateFormat('dd/MM/yyyy').parseStrict(value);
      return null;
    } catch (e) {
      return 'Định dạng ngày không hợp lệ (dd/MM/yyyy)';
    }
  }

  String _convertDateForDisplay(String? date) {
    if (date == null || date.isEmpty) return '';
    try {
      final parsedDate = DateFormat('yyyy-MM-dd').parse(date);
      return DateFormat('dd/MM/yyyy').format(parsedDate);
    } catch (e) {
      return date; // Trả về chuỗi gốc nếu không thể chuyển đổi
    }
  }

  String? _convertDateForAPI(String? date) {
    if (date == null || date.isEmpty) return null;
    try {
      final parsedDate = DateFormat('dd/MM/yyyy').parseStrict(date);
      return DateFormat('yyyy-MM-dd').format(parsedDate); // Định dạng chuẩn cho API
    } catch (e) {
      return null; // Trả về null nếu không thể chuyển đổi
    }
  }

  Future<void> _capNhatThongTin() async {
    if (_formKey.currentState!.validate()) {
      final updatedData = {};

      if (_tenController.text != originalData['Ten_day_du']) {
        updatedData['Ten_day_du'] = _tenController.text;
      }
      if (_emailController.text != originalData['Email']) {
        updatedData['Email'] = _emailController.text;
      }
      if (_soDienThoaiController.text != originalData['So_dien_thoai']) {
        updatedData['So_dien_thoai'] = _soDienThoaiController.text;
      }
      if (_ngaySinhController.text != _convertDateForDisplay(originalData['Ngay_sinh'])) {
        updatedData['Ngay_sinh'] = _convertDateForAPI(_ngaySinhController.text);
      }

      if (updatedData.isEmpty) {
        _showSnackBar('Không có thay đổi nào để cập nhật.', Colors.orange);
        return;
      }

      final url = Uri.parse('http://10.0.2.2:8000/api/khachhang/update/${widget.idNguoiDung}');
      try {
        final response = await http.put(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(updatedData),
        );

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          if (responseData['success']) {
            _showSnackBar('Cập nhật thành công!', Colors.green);
            Navigator.pop(context, true);
          } else {
            _showSnackBar(responseData['message'], Colors.red);
          }
        } else {
          _showSnackBar('Lỗi máy chủ: ${response.statusCode}', Colors.orange);
        }
      } catch (e) {
        _showSnackBar('Lỗi kết nối: $e', Colors.red);
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Thông Tin Cá Nhân',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: const Color(0xFF040434),
        leading: IconButton(
          icon: const Icon(Icons.undo, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    buildTextFormField(
                      controller: _tenController,
                      label: 'Tên đầy đủ',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Tên không được để trống';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    buildTextFormField(
                      controller: _emailController,
                      label: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email không được để trống';
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Email không hợp lệ';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    buildTextFormField(
                      controller: _soDienThoaiController,
                      label: 'Số điện thoại',
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Số điện thoại không được để trống';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    buildTextFormField(
                      controller: _ngaySinhController,
                      label: 'Ngày sinh',
                      hintText: 'dd/MM/yyyy',
                      keyboardType: TextInputType.datetime,
                      validator: _validateDate,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF040434),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      onPressed: _capNhatThongTin,
                      child: const Text(
                        'Cập Nhật',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget buildTextFormField({
    required TextEditingController controller,
    required String label,
    String? hintText,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        border: const OutlineInputBorder(),
      ),
      validator: validator,
    );
  }
}
