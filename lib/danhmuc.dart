import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'detailSanPham.dart';
import 'giohang.dart';
import 'thongtinkhachhang.dart';
import 'donhang.dart';

class DanhMucScreen extends StatefulWidget {
  final String idNguoiDung;

  const DanhMucScreen({super.key, required this.idNguoiDung});
  @override
  _SanPhamScreenState createState() => _SanPhamScreenState();
}

class _SanPhamScreenState extends State<DanhMucScreen> {
  List<dynamic> dsSanPham = [];
  List<dynamic> dsSanPhamHienThi = []; // Danh sách sản phẩm hiển thị
  List<dynamic> dsHang = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();
  int? selectedHangID; // ID hãng được chọn

  int _currentIndex = 0; // Quản lý tab hiện tại

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      DanhMucScreen(idNguoiDung: widget.idNguoiDung),
      GioHangScreen(idNguoiDung: widget.idNguoiDung),
      ThongTinKhachHangScreen(idNguoiDung: widget.idNguoiDung),
    ];
    fetchSanPham();
    fetchHang();
  }

  //Lấy danh sách sản phẩm
  Future<void> fetchSanPham() async {
    final url = Uri.parse('http://10.0.2.2:8000/api/sanpham/all');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['data'] is List) {
          setState(() {
            dsSanPham = data['data']; // Lưu toàn bộ sản phẩm
            dsSanPhamHienThi =
                List.from(dsSanPham); // Gán danh sách hiển thị ban đầu
            isLoading = false;
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

  //Tìm kiếm sản phẩm theo tên
  void onSearch(String query) {
    final results = dsSanPham.where((sanPham) {
      final tenSanPham = sanPham['Ten']?.toString().toLowerCase() ?? '';
      final input = query.toLowerCase();
      return tenSanPham.contains(input);
    }).toList();

    setState(() {
      dsSanPhamHienThi = results; // Cập nhật danh sách hiển thị
    });
  }

  Future<void> fetchHang() async {
    final url = Uri.parse('http://10.0.2.2:8000/api/hang/all');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['data'] is List) {
          setState(() {
            dsHang = data['data'];
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

  void filterSanPhamByHang(int? idHang) {
    if (idHang == null) {
      setState(() {
        dsSanPhamHienThi = List.from(dsSanPham); // Hiển thị tất cả sản phẩm
        selectedHangID = null;
      });
    } else {
      setState(() {
        dsSanPhamHienThi = dsSanPham.where((sanPham) {
          return sanPham['ID_hang'] == idHang; // Lọc theo ID_hang
        }).toList();
        selectedHangID = idHang;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: TextField(
          controller: searchController,
          onChanged: onSearch,
          decoration: InputDecoration(
            hintText: 'Tìm kiếm trên SmartTime ',
            prefixIcon: const Icon(Icons.search, color: Color(0xFF040434)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            fillColor: Colors.grey[200],
            filled: true,
          ),
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 10),
          // Danh sách các hãng
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(vertical: 1.0),
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: dsHang.length + 1, // Thêm 1 cho nút "Tất cả"
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        // Nút "Tất cả"
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: selectedHangID == null
                                  ? Color(0xFF040434)
                                  : Colors.grey,
                              borderRadius:
                                  BorderRadius.circular(8.0), // Bo góc
                              border: Border.all(
                                color: Colors.grey, // Viền
                                width: 1.0,
                              ),
                            ),
                            child: TextButton(
                              onPressed: () {
                                filterSanPhamByHang(
                                    null); // Không lọc theo hãng
                              },
                              child: const Text(
                                "Tất cả",
                                style:
                                    TextStyle(color: Colors.white), // Màu chữ
                              ),
                            ),
                          ),
                        );
                      }

                      final hang = dsHang[index - 1];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: selectedHangID == hang['ID_hang']
                                ? Color(0xFF040434)
                                : Colors.grey,
                            borderRadius: BorderRadius.circular(8.0), // Bo góc
                            border: Border.all(
                              color: Colors.grey, // Viền
                              width: 1.0,
                            ),
                          ),
                          child: TextButton(
                            onPressed: () {
                              filterSanPhamByHang(hang['ID_hang']);
                            },
                            child: Text(
                              hang['Ten_hang'],
                              style: const TextStyle(
                                  color: Colors.white), // Màu chữ
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Danh sách sản phẩm
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : dsSanPhamHienThi.isEmpty
                    ? Center(child: Text("Không tìm thấy sản phẩm"))
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.7,
                          ),
                          itemCount: dsSanPhamHienThi.length,
                          itemBuilder: (context, index) {
                            final sanPham = dsSanPhamHienThi[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SanPhamDetailScreen(
                                      idNguoiDung: widget.idNguoiDung,
                                      sanPham: sanPham,
                                    ),
                                  ),
                                );
                              },
                              child: _buildSanPhamCard(sanPham),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          // Điều hướng đến màn hình tương ứng
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    DanhMucScreen(idNguoiDung: widget.idNguoiDung),
              ),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => GioHangScreen(
                    idNguoiDung: widget.idNguoiDung), // Màn hình giỏ hàng
              ),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => DonhangSreen(),
              ),
            );
          } else if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ThongTinKhachHangScreen(idNguoiDung: widget.idNguoiDung),
              ),
            );
          }
        },
        selectedItemColor: Color(0xFF040434),
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
            icon: Icon(Icons.local_shipping),
            label: 'Đơn hàng',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Thông tin',
          ),
        ],
      ),
    );
  }

  Widget _buildSanPhamCard(dynamic sanPham) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              child: PageView.builder(
                itemCount: sanPham['anh_san_pham']?.length ?? 1,
                itemBuilder: (context, index) {
                  final imageUrl = sanPham['anh_san_pham'] != null &&
                          sanPham['anh_san_pham'].isNotEmpty &&
                          index < sanPham['anh_san_pham'].length
                      ? sanPham['anh_san_pham'][index]['Link_anh']
                      : 'https://via.placeholder.com/150';
                  return Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sanPham['Ten'],
                  style: TextStyle(
                    color: Color(0xFF040434),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  sanPham['Mo_ta'],
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${NumberFormat("#,###", "vi_VN").format(double.tryParse(sanPham['Gia'] ?? '0') ?? 0)} VNĐ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.shopping_cart,
                        color: Color(0xFF040434),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
