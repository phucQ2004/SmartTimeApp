import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'ChiTietDonHang_Admin.dart'; // Import trang chi tiết đơn hàng

class DonHangScreen extends StatefulWidget {
  @override
  _DonHangScreenState createState() => _DonHangScreenState();
}

class _DonHangScreenState extends State<DonHangScreen> {
  bool _isLoading = true;
  List<dynamic> _donHangList = [];
  String _errorMessage = '';
  String _selectedFilter = 'Tất cả';

  @override
  void initState() {
    super.initState();
    fetchDonHang();
  }

  Future<void> fetchDonHang({String status = ''}) async {
    final baseUrl = 'http://10.0.2.2:8000/api/donhang/filter';
    final url = Uri.parse('$baseUrl?status=$status');

    try {
      final response = await http.get(url);
      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          setState(() {
            _donHangList = responseData['data'] ?? [];
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = 'Lỗi dữ liệu từ server.';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage =
              'Không thể tải danh sách đơn hàng. Lỗi: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        _errorMessage = 'Lỗi kết nối tới server: $error';
        _isLoading = false;
      });
    }
  }

  Future<void> updateTrangThaiDonHang(
      int idDonHang, String trangThaiMoi) async {
    final url =
        Uri.parse('http://10.0.2.2:8000/api/don-hang/$idDonHang/trang-thai');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'Trang_thai': trangThaiMoi}),
    );

    if (response.statusCode == 200) {
      print('Cập nhật trạng thái thành công');
    } else {
      print('Cập nhật trạng thái thất bại');
    }
  }

  String formatDate(String dateString) {
    try {
      final dateTime = DateTime.parse(dateString);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Danh Sách Đơn Hàng'),
        backgroundColor: const Color(0xFF1A237E),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.filter_list),
            onSelected: (String value) {
              setState(() {
                _selectedFilter = value;
                _isLoading = true;
              });
              fetchDonHang(status: value == 'Tất cả' ? '' : value);
            },
            itemBuilder: (BuildContext context) {
              return [
                'Tất cả',
                'Chờ xác nhận',
                'Đã duyệt đơn',
                'Đang giao đơn',
                'Đã giao đơn'
              ].map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_errorMessage,
                                style: TextStyle(color: Colors.red)),
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () => fetchDonHang(
                                  status: _selectedFilter == 'Tất cả'
                                      ? ''
                                      : _selectedFilter),
                              child: Text("Thử lại"),
                            ),
                          ],
                        ),
                      )
                    : _donHangList.isEmpty
                        ? Center(child: Text('Không có đơn hàng nào.'))
                        : ListView.builder(
                            itemCount: _donHangList.length,
                            itemBuilder: (context, index) {
                              final donHang = _donHangList[index];
                              final List<dynamic> chiTietDonHang =
                                  donHang['chi_tiet_don_hang'] ?? [];
                              final String tenSanPham =
                                  chiTietDonHang.isNotEmpty &&
                                          chiTietDonHang[0]['san_pham'] != null
                                      ? chiTietDonHang[0]['san_pham']['Ten']
                                      : 'Không có tên sản phẩm';
                              final String moTaSanPham =
                                  chiTietDonHang.isNotEmpty &&
                                          chiTietDonHang[0]['san_pham'] != null
                                      ? chiTietDonHang[0]['san_pham']['Mo_ta']
                                      : 'Không có mô tả';
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ChiTietDonHangScreen(
                                        donHang['ID_don_hang'],
                                      ),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 16.0),
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    elevation: 5,
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Mã đơn hàng: ${donHang['ID_don_hang']}',
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            'Tên sản phẩm: $tenSanPham',
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.black),
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            'Mô tả: $moTaSanPham',
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[700]),
                                          ),
                                          SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Icon(Icons.calendar_today,
                                                  size: 16, color: Colors.grey),
                                              SizedBox(width: 4),
                                              Text(
                                                'Ngày đặt: ${formatDate(donHang['Ngay_tao'])}',
                                                style: TextStyle(
                                                    color: Colors.grey[600]),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Icon(Icons.attach_money,
                                                  size: 16,
                                                  color: Colors.green),
                                              SizedBox(width: 4),
                                              Text(
                                                'Tổng tiền: ${donHang['Tong_tien']} USD',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.green[700]),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Icon(Icons.local_shipping,
                                                  size: 16, color: Colors.blue),
                                              SizedBox(width: 4),
                                              Text(
                                                'Trạng thái: ${donHang['Trang_thai_don_hang']}',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.blue[700]),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}

class ChiTietDonHangScreen extends StatelessWidget {
  final int idDonHang;

  ChiTietDonHangScreen(this.idDonHang);

  Future<List<dynamic>> fetchChiTietDonHang() async {
    final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/chi-tiet-don-hang/$idDonHang'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Không thể tải chi tiết đơn hàng');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chi Tiết Đơn Hàng')),
      body: FutureBuilder<List<dynamic>>(
        future: fetchChiTietDonHang(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          } else {
            final chiTietDonHang = snapshot.data!;
            return ListView.builder(
              itemCount: chiTietDonHang.length,
              itemBuilder: (context, index) {
                final item = chiTietDonHang[index];
                return ListTile(
                  title: Text(item['sanPham'] != null
                      ? item['sanPham']['Ten']
                      : 'Không có tên sản phẩm'),
                  subtitle: Text(
                      'Giá: ${item['Gia']} x Số lượng: ${item['So_luong']}'),
                );
              },
            );
          }
        },
      ),
    );
  }
}
