import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SanPhamDetailScreen extends StatefulWidget {
  final Map<String, dynamic> sanPham;
  final String idNguoiDung;
  const SanPhamDetailScreen(
      {required this.sanPham, Key? key, required this.idNguoiDung})
      : super(key: key);

  @override
  _SanPhamDetailScreenState createState() => _SanPhamDetailScreenState();
}

class _SanPhamDetailScreenState extends State<SanPhamDetailScreen> {
  bool isLoading = false;
  List<int> danhSachSanPhamTrongGio = [];
  void initState() {
    super.initState();
  }

  Future<void> ThemVaoGioHang(
      int idKhachHang, int idSanPham, int soLuongSP) async {
    setState(() {
      isLoading = true;
    });
    if (danhSachSanPhamTrongGio.contains(idSanPham)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sản phẩm đã có trong giỏ hàng!'),
          backgroundColor: Colors.orange,
        ),
      );
      setState(() {
        isLoading = false;
      });
      return;
    }
    final gioHangUrl = Uri.parse(
        'http://10.0.2.2:8000/api/gio-hang/them/$idKhachHang/$idSanPham');

    final gioHangData = jsonEncode({"So_luong_SP": soLuongSP});

    try {
      final gioHangResponse = await http.post(
        gioHangUrl,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: gioHangData,
      );

      if (gioHangResponse.statusCode == 200) {
        final gioHangResult = jsonDecode(gioHangResponse.body);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              gioHangResult['message'] ?? 'Sản phẩm đã được thêm vào giỏ hàng!',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi thêm vào giỏ hàng: ${gioHangResponse.body}'),
            backgroundColor: Colors.red,
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
    List<String> imageUrls = (widget.sanPham['anh_san_pham'] as List<dynamic>?)
            ?.map((img) => img['Link_anh'] ?? 'https://via.placeholder.com/300')
            .cast<String>()
            .toList() ??
        ['https://via.placeholder.com/300'];

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF040434), Color(0xFF040434)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          widget.sanPham['Ten'] ?? 'Chi tiết sản phẩm',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF3F5F9), Color(0xFFECEFF4)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade400,
                        blurRadius: 12,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox(
                      height: 180,
                      width: 180,
                      child: PageView.builder(
                        itemCount: imageUrls.length,
                        itemBuilder: (context, index) {
                          return Image.network(
                            imageUrls[index],
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                widget.sanPham['Ten'] ?? 'Không có tên sản phẩm',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF223344),
                ),
              ),
              SizedBox(height: 10),
              Text(
                widget.sanPham['Mo_ta'] ?? 'Không có mô tả',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${widget.sanPham['Gia'] ?? '0'} \$',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF223344),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Color(0xFFBBDEFB),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Còn lại: ${widget.sanPham['So_luong_ton'] ?? '0'}',
                      style: TextStyle(color: Colors.blueAccent),
                    ),
                  ),
                ],
              ),
              Divider(height: 30, color: Colors.grey[300]),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    DetailItem(
                      title: 'Thương hiệu',
                      value: widget.sanPham['Thuong_hieu'],
                      icon: Icons.workspace_premium_rounded,
                    ),
                    DetailItem(
                      title: 'Chất liệu dây đeo',
                      value: widget.sanPham['Chat_lieu_day'],
                      icon: Icons.watch_rounded,
                    ),
                    DetailItem(
                      title: 'Kích thước mặt',
                      value: widget.sanPham['Kich_thuoc_mat'],
                      icon: Icons.aspect_ratio_rounded,
                    ),
                    DetailItem(
                      title: 'Chống nước',
                      value: widget.sanPham['Chong_nuoc'] == 1 ? 'Có' : 'Không',
                      icon: Icons.water_drop_rounded,
                    ),
                    DetailItem(
                      title: 'Bảo hành',
                      value: widget.sanPham['Bao_hanh'],
                      icon: Icons.verified_user_rounded,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              Center(
                child: ElevatedButton.icon(
                  onPressed: isLoading
                      ? null
                      : () {
                          final _idKhachHang =
                              int.tryParse(widget.idNguoiDung) ?? 0;
                          ThemVaoGioHang(
                              _idKhachHang, widget.sanPham['ID_san_pham'], 1);
                        },
                  icon: Icon(
                    Icons.shopping_cart,
                    color: Colors.white,
                  ),
                  label: isLoading
                      ? CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : Text(
                          'Thêm vào giỏ hàng',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF556677),
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                    textStyle: TextStyle(fontSize: 18),
                    shadowColor: Colors.black.withOpacity(0.3),
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DetailItem extends StatelessWidget {
  final String title;
  final String? value;
  final IconData icon;

  const DetailItem(
      {required this.title, this.value, required this.icon, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.blueAccent, size: 24),
          SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.left,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value ?? '',
              style: TextStyle(color: Colors.black),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
