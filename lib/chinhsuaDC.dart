import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CapNhatDiaChiScreen extends StatefulWidget {
  final String idDiaChi;

  const CapNhatDiaChiScreen({super.key, required this.idDiaChi});

  @override
  _CapNhatDiaChiScreenState createState() => _CapNhatDiaChiScreenState();
}

class _CapNhatDiaChiScreenState extends State<CapNhatDiaChiScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _tenController;
  late TextEditingController _soDienThoaiController;
  late TextEditingController _diaChiController;
  late TextEditingController _moTaController;

  Map<String, dynamic> originalData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tenController = TextEditingController();
    _soDienThoaiController = TextEditingController();
    _diaChiController = TextEditingController();
    _moTaController = TextEditingController();
    fetchThongTinDiaChi();
  }

  @override
  void dispose() {
    _tenController.dispose();
    _diaChiController.dispose();
    _soDienThoaiController.dispose();
    _moTaController.dispose();
    super.dispose();
  }

  Future<void> fetchThongTinDiaChi() async {
    final url = Uri.parse('http://10.0.2.2:8000/api/diachi/${widget.idDiaChi}');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success']) {
          setState(() {
            originalData = responseData['data'];
            _tenController.text = originalData['Ten_day_du'] ?? '';
            _soDienThoaiController.text = originalData['So_dien_thoai'] ?? '';
            _diaChiController.text = originalData['Dia_chi'] ?? '';
            _moTaController.text = originalData['Mo_ta'] ?? '';
            isLoading = false;
          });
        }
      } else {
        _showSnackBar('Không thể tải thông tin địa chỉ', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Lỗi kết nối: $e', Colors.red);
    }
  }

  Future<void> _capNhatDiaChi() async {
    if (_formKey.currentState!.validate()) {
      final updatedData = <String, dynamic>{};

      if (_tenController.text != originalData['ten_day_du']) {
        updatedData['ten_day_du'] = _tenController.text;
      }
      if (_soDienThoaiController.text != originalData['so_dien_thoai']) {
        updatedData['so_dien_thoai'] = _soDienThoaiController.text;
      }
      if (_diaChiController.text != originalData['dia_chi']) {
        updatedData['dia_chi'] = _diaChiController.text;
      }
      if (_moTaController.text != originalData['mo_ta']) {
        updatedData['mo_ta'] = _moTaController.text;
      }

      if (updatedData.isEmpty) {
        _showSnackBar('Không có thay đổi nào để cập nhật.', Colors.orange);
        return;
      }

      print('Dữ liệu gửi lên: $updatedData');

      final url = Uri.parse('http://10.0.2.2:8000/api/diachi/update/${widget.idDiaChi}');
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
          _showSnackBar('Lỗi máy chủ: ${response.statusCode}, ${response.body}', Colors.orange);
        }
      } catch (e) {
        _showSnackBar('Lỗi kết nối: $e', Colors.red);
      }
    }
  }

  Future<void> _xoaDiaChi() async {
    final url = Uri.parse('http://10.0.2.2:8000/api/diachi/delete/${widget.idDiaChi}');
    try {
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success']) {
          _showSnackBar('Địa chỉ đã được xóa thành công!', Colors.green);
          Navigator.pop(context, true); // Quay lại màn hình trước
        } else {
          _showSnackBar(responseData['message'], Colors.red);
        }
      } else {
        _showSnackBar('Lỗi máy chủ: ${response.statusCode}, ${response.body}', Colors.orange);
      }
    } catch (e) {
      _showSnackBar('Lỗi kết nối: $e', Colors.red);
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
                      label: 'Tên người nhận',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Tên không được để trống';
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
                      controller: _diaChiController,
                      label: 'Địa chỉ',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Địa chỉ không được để trống';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    buildTextFormField(
                      controller: _moTaController,
                      label: 'Mô tả',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Mô tả không được để trống';
                        }
                        return null;
                      },
                    ),  
                    const SizedBox(height: 32),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF040434),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      onPressed: _capNhatDiaChi,
                      child: const Text(
                        'Cập Nhật',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      onPressed: () {
                        // Hiển thị hộp thoại xác nhận trước khi xóa
                        _showDeleteConfirmationDialog();
                      },
                      child: const Text(
                        'Xóa Địa Chỉ',
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }
  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: const Text('Bạn có chắc chắn muốn xóa địa chỉ này không?',
                            style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                           ),),
          actions: <Widget>[
            TextButton(
              child:const Text('Hủy',
                            style: TextStyle(
                            color: Colors.blue,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            ),),
              onPressed: () {
                Navigator.of(context).pop(); // Đóng hộp thoại
              },
            ),
            TextButton(
              child:const Text('Xóa',
                            style: TextStyle(
                            color: Colors.red,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                              ),
                            ),
              onPressed: () {
                Navigator.of(context).pop(); // Đóng hộp thoại
                _xoaDiaChi(); // Gọi phương thức xóa địa chỉ
              },
            ),
          ],
        );
      },
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
