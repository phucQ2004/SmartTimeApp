import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'chinhsuaDC.dart';
import 'themdiachi.dart';

class ThongTinDiaChiScreen extends StatefulWidget {
  final String idNguoiDung;
  const ThongTinDiaChiScreen({super.key, required this.idNguoiDung});
  
  @override
  _ThongTinDiaChiScreenState createState() => _ThongTinDiaChiScreenState();
}

class _ThongTinDiaChiScreenState extends State<ThongTinDiaChiScreen> {
  List<Map<String, dynamic>> diaChiList = [];  // Danh sách địa chỉ
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchThongTinDiaChi(widget.idNguoiDung);
  }

  Future<void> fetchThongTinDiaChi(String idNguoiDung) async {
    final url = Uri.parse('http://10.0.2.2:8000/api/diachi/all/$idNguoiDung');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success']) {
          final List<dynamic> dataList = responseData['data'];  // Danh sách các địa chỉ
          setState(() {
            diaChiList.clear();  // Xóa dữ liệu cũ nếu có
            // Lặp qua danh sách và thêm mỗi địa chỉ vào diaChiList
            for (var data in dataList) {
              diaChiList.add({
                'idDiaChi': data['ID_dia_chi'].toString(),
                'tenDayDu': data['Ten_day_du'],
                'soDienThoai': data['So_dien_thoai'],
                'diaChi': data['Dia_chi'],
                'moTa': data['Mo_ta'],
                'macDinh': (data['Mac_dinh'] as int) == 1,
              });
            }
          });
        } else {
          setState(() {
            diaChiList.clear();  // Nếu không có dữ liệu, xóa danh sách
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
        isLoading = false;  // Đặt trạng thái tải xong
      });
    }
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text(
        'Thông Tin Địa Chỉ',
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
        ? const Center(child: CircularProgressIndicator()) // Chờ dữ liệu tải
        : diaChiList.isEmpty
            ? const Center(
                child: Text(
                  'Chưa có thông tin địa chỉ.',
                  style: TextStyle(fontSize: 16),
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView.builder(
                  itemCount: diaChiList.length,
                  itemBuilder: (context, index) {
                    var diaChiItem = diaChiList[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16), // Thêm khoảng cách giữa các Card
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xFF040434), width: 1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    '${diaChiItem['tenDayDu']}   ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Container(
                                    height: 20,
                                    width: 1,
                                    color: Color(0xFF040434),
                                  ),
                                  Text(
                                    '   ${diaChiItem['soDienThoai']}',
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      '${diaChiItem['diaChi']}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  if (diaChiItem['macDinh'])
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.red),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        'Mặc định',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  const Spacer(),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF040434),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    ),
                                    onPressed: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => CapNhatDiaChiScreen(
                                            idDiaChi: diaChiItem['idDiaChi'],
                                          ),
                                        ),
                                      );
                                    },
                                    child: Icon(Icons.edit, color: Colors.white),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
    // Nút thêm địa chỉ
    floatingActionButton: FloatingActionButton(
      onPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ThemDiaChiScreen(idNguoiDung: widget.idNguoiDung),
          ),
        );
      },
      child: Icon(Icons.add, color: Colors.white),
      backgroundColor: Color(0xFF040434),
    ),
  );
}

}
