import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ThemDiaChiScreen extends StatefulWidget {
  final String idNguoiDung;
  const ThemDiaChiScreen({super.key, required this.idNguoiDung});
  @override
  _ThemDiaChiScreenState createState() => _ThemDiaChiScreenState();
}

class _ThemDiaChiScreenState extends State<ThemDiaChiScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _tenDayDuController = TextEditingController();
  final TextEditingController _soDienThoaiController = TextEditingController();
  final TextEditingController _diaChiController = TextEditingController();
  final TextEditingController _moTaController = TextEditingController();
  bool _macDinh = false;
  bool _isLoading = false;

  Future<void> _submitData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    // Dữ liệu cần gửi
    final Map<String, dynamic> requestData = {
      "ten_day_du": _tenDayDuController.text,
      "so_dien_thoai": _soDienThoaiController.text,
      "dia_chi": _diaChiController.text,
      "mac_dinh": _macDinh,
      "mo_ta": _moTaController.text.isNotEmpty ? _moTaController.text : null,
    };

    try {
      final String url = "http://10.0.2.2:8000/api/diachi/add/${widget.idNguoiDung}";

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
        },
        body: json.encode(requestData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Thành công
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Thêm địa chỉ thành công!'),
          backgroundColor: Colors.green,),
        );Navigator.pop(context);
      } else {
        // Thất bại
        final responseBody = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${responseBody['message']}')),
        );
      }
    } catch (e) {
      // Lỗi kết nối hoặc xử lý
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xảy ra lỗi. Vui lòng thử lại!')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Thêm Địa Chỉ",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),),
        backgroundColor: Color(0xFF040434),
        leading: IconButton(
        icon: Icon(Icons.undo, color: Colors.white),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _tenDayDuController,
                  decoration: InputDecoration(labelText: "Tên đầy đủ"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Vui lòng nhập tên đầy đủ";
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _soDienThoaiController,
                  decoration: InputDecoration(labelText: "Số điện thoại"),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Vui lòng nhập số điện thoại";
                    }
                    if (value.length > 15) {
                      return "Số điện thoại không được quá 15 ký tự";
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _diaChiController,
                  decoration: InputDecoration(labelText: "Địa chỉ"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Vui lòng nhập địa chỉ";
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _moTaController,
                  decoration: InputDecoration(labelText: "Mô tả (tuỳ chọn)"),
                ),
                Row(
                  children: [
                    Checkbox(
                      value: _macDinh,
                      onChanged: (value) {
                        setState(() {
                          _macDinh = value!;
                        });
                      },
                    ),
                    Text("Đặt làm địa chỉ mặc định"),
                  ],
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF040434),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                  onPressed: _isLoading ? null : _submitData,
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text("Thêm địa chỉ",
                      style:TextStyle(color: Colors.white)
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
