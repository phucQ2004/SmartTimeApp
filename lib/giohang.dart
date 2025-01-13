import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GioHangScreen extends StatefulWidget {
  final String idNguoiDung;
  const GioHangScreen({super.key, required this.idNguoiDung});
  @override
  _GioHangScreenState createState() => _GioHangScreenState();
}

class _GioHangScreenState extends State<GioHangScreen> {
  List<bool> isChecked = []; // Danh sách trạng thái checkbox
  late final String idKhachHang;
  late final int _idKhachHang;
  List<dynamic> dsSanPham = [];
  List<dynamic> dsSanPhamHienThi = []; // Danh sách sản phẩm hiển thị
  bool isLoading = true;
  double tongTien = 0.0; // Biến để lưu tổng tiền
  void incrementQuantity(int index) {
    setState(() {
      // Lấy sản phẩm hiện tại
      final sanPham = dsSanPhamHienThi[index];

      // Tăng số lượng trong dsSanPhamHienThi
      sanPham['So_luong_SP']++;

      // Gọi API cập nhật số lượng lên server
      updateQuantityOnServer(sanPham['ID_san_pham'], sanPham['So_luong_SP']);
    });
  }

  void decrementQuantity(int index) {
    setState(() {
      // Lấy sản phẩm hiện tại
      final sanPham = dsSanPhamHienThi[index];

      // Kiểm tra để không giảm số lượng dưới 1
      if (sanPham['So_luong_SP'] > 1) {
        // Giảm số lượng
        sanPham['So_luong_SP']--;

        // Gọi API cập nhật số lượng lên server
        updateQuantityOnServer(sanPham['ID_san_pham'], sanPham['So_luong_SP']);
      }
    });
  }

  Future<void> updateQuantityOnServer(int idSanPham, int soLuong) async {
    final url = Uri.parse(
        'http://10.0.2.2:8000/api/gio-hang/cap-nhat/$_idKhachHang/$idSanPham');
    try {
      final response = await http.put(
        url,
        body: jsonEncode({'So_luong_SP': soLuong}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          print('Cập nhật số lượng thành công');
          print('Updating quantity for: $_idKhachHang, $idSanPham');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Không thể cập nhật số lượng: ${data['message']}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi server: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Lỗi khi cập nhật số lượng: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi kết nối: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    idKhachHang = widget.idNguoiDung;
    _idKhachHang = int.tryParse(idKhachHang) ?? 0; // Nếu không hợp lệ, gán 0
    if (_idKhachHang == 0) {
      print("ID khách hàng không hợp lệ: $idKhachHang");
    } else {
      fetchSanPham(); // Gọi API nếu ID hợp lệ
    }
  }

  void updateTotalAmount() {
    tongTien = 0.0; // Reset tổng tiền mỗi lần cập nhật
    for (int i = 0; i < dsSanPhamHienThi.length; i++) {
      if (isChecked[i]) {
        // Nếu sản phẩm được chọn (checkbox checked), cộng tiền
        double gia =
            double.tryParse(dsSanPhamHienThi[i]['sanpham']['Gia']) ?? 0.0;
        int soLuong = dsSanPhamHienThi[i]['So_luong_SP'] ?? 0;
        tongTien += gia * soLuong;
      }
    }
  }

  Future<void> fetchSanPham() async {
    final url =
        Uri.parse('http://10.0.2.2:8000/api/gio-hang/xem/$_idKhachHang');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['data'] is List) {
          setState(() {
            dsSanPham = data['data'];
            dsSanPhamHienThi = List.from(dsSanPham);
            isChecked = List.filled(dsSanPhamHienThi.length,
                false); // Khởi tạo danh sách trạng thái checkbox
            isLoading = false;
            updateTotalAmount();
          });
        } else {
          print("API không trả về danh sách hợp lệ");
        }
      } else {
        print("Lỗi server: ${response.statusCode}");
      }
    } catch (e) {
      print("Lỗi kết nối: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> removeSanPhamFromCart(int idSanPham) async {
    final url = Uri.parse(
        'http://10.0.2.2:8000/api/gio-hang/xoa/$_idKhachHang/$idSanPham');

    try {
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          setState(() {
            dsSanPhamHienThi.removeWhere(
                (sanPham) => sanPham['sanpham']['ID'] == idSanPham);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Xóa sản phẩm thành công')),
          );
          fetchSanPham(); // Gọi lại API để cập nhật danh sách
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Không thể xóa sản phẩm: ${data['message']}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi server: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print("Lỗi kết nối: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi kết nối: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Giỏ hàng của bạn",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // AppBar tùy chỉnh
            Container(
              width: double.infinity,
              height: 60, // Adjust the height as needed
              margin: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: IconButton(
                  icon: Icon(
                    Icons.shopping_cart,
                    size: 28,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    // Hành động khi bấm vào icon giỏ hàng
                  },
                ),
              ),
            ),

            // Divider dưới AppBar
            Divider(
              thickness: 1,
              color: Colors.grey[300],
              height: 1,
            ),

            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: dsSanPhamHienThi.length,
              itemBuilder: (context, index) {
                final _sanPham = dsSanPhamHienThi[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 3,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Row 1: Checkbox, Image, Name and Price
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Checkbox
                            Checkbox(
                              value: isChecked[index],
                              onChanged: (bool? value) {
                                setState(() {
                                  isChecked[index] = value ?? false;
                                  updateTotalAmount();
                                });
                              },
                            ),
                            SizedBox(width: 8),
                            // Image
                            Container(
                              width: 70,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: NetworkImage(
                                    _sanPham['sanpham']['anh_san_pham'] !=
                                                null &&
                                            _sanPham['sanpham']['anh_san_pham']
                                                .isNotEmpty
                                        ? _sanPham['sanpham']['anh_san_pham'][0]
                                            ['Link_anh']
                                        : 'https://via.placeholder.com/150',
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            // Title and Price
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _sanPham['sanpham']['Ten'],
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        '${_sanPham['sanpham']['Gia']}đ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.red,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        // Row 2: Quantity Controls and Delete Icon
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: IconButton(
                                icon: Icon(Icons.remove, size: 18),
                                onPressed: () {
                                  decrementQuantity(index);
                                  setState(() {
                                    updateTotalAmount();
                                  });
                                },
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              '${_sanPham['So_luong_SP']}',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(width: 8),
                            Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: IconButton(
                                icon: Icon(Icons.add, size: 18),
                                onPressed: () {
                                  incrementQuantity(index);
                                  setState(() {
                                    updateTotalAmount();
                                  });
                                },
                              ),
                            ),
                            SizedBox(width: 8),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.grey),
                              onPressed: () {
                                final _idSanPham = _sanPham['ID_san_pham'];
                                if (_idSanPham != null) {
                                  removeSanPhamFromCart(_idSanPham);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content:
                                            Text('ID sản phẩm không hợp lệ')),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // Phần tổng cộng
            Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 5,
                    color: Colors.grey.withOpacity(0.5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tổng cộng:',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '\$${tongTien.toStringAsFixed(2)}',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      // Xử lý thanh toán
                    },
                    child: Text('Thanh toán'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
