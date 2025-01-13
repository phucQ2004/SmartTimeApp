import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'detailSanPham.dart';
import 'giohang.dart';
import 'thongtinkhachhang.dart';

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
  late final String idKhachHang;
  @override
  void initState() {
    super.initState();
    idKhachHang = widget.idNguoiDung;
    _screens = [
      DanhMucScreen(idNguoiDung: widget.idNguoiDung),
      GioHangScreen(idNguoiDung: widget.idNguoiDung),
      ThongTinKhachHangScreen(idNguoiDung: widget.idNguoiDung),
    ];
    fetchSanPham();
    fetchHang();
  }

  Future<void> ThemVaoGioHang(
      int idKhachHang, int idSanPham, int soLuongSP) async {
    setState(() {
      isLoading = true;
    });
    print(
        "Adding to cart: idKhachHang = $idKhachHang, idSanPham = $idSanPham, soLuongSP = $soLuongSP");
    // URL API thêm vào giỏ hàng
    final gioHangUrl = Uri.parse(
        'http://10.0.2.2:8000/api/gio-hang/them/$idKhachHang/$idSanPham');

    // Dữ liệu JSON gửi lên API
    final gioHangData = jsonEncode({
      "So_luong_SP": soLuongSP, // Gửi kèm số lượng sản phẩm
    });
    print("JSON Data: $gioHangData");
    try {
      // Gửi request thêm vào giỏ hàng
      final gioHangResponse = await http.post(
        gioHangUrl,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: gioHangData,
      );

      // Kiểm tra nếu thêm vào giỏ hàng thành công
      if (gioHangResponse.statusCode == 200) {
        // Parse kết quả từ API
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
        // Trường hợp lỗi từ server
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi thêm vào giỏ hàng: ${gioHangResponse.body}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Xử lý lỗi kết nối
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
            hintText: 'ID : ${widget.idNguoiDung}',
            prefixIcon: const Icon(Icons.search, color: Colors.grey),
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
                                  ? Colors.blueGrey
                                  : Colors.white,
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
                                    TextStyle(color: Colors.black), // Màu chữ
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
                                ? Colors.blueGrey
                                : Colors.white,
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
                                  color: Colors.black), // Màu chữ
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
                                      sanPham: sanPham,
                                      idNguoiDung: idKhachHang,
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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    DanhMucScreen(idNguoiDung: widget.idNguoiDung),
              ),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GioHangScreen(
                    idNguoiDung: idKhachHang), // Màn hình giỏ hàng
              ),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ThongTinKhachHangScreen(
                    idNguoiDung: widget.idNguoiDung), // Truyền tên đăng nhập
              ),
            );
          }
        },
        selectedItemColor: Colors.blueGrey,
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
              child: Image.network(
                sanPham['anh_san_pham'] != null &&
                        sanPham['anh_san_pham'].isNotEmpty
                    ? sanPham['anh_san_pham'][0]['Link_anh']
                    : 'https://via.placeholder.com/150',
                fit: BoxFit.cover,
                width: double.infinity,
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
                        '${sanPham['Gia'] ?? '0'} \VNĐ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        final _idKhachHang = int.tryParse(idKhachHang) ?? 0;
                        // ScaffoldMessenger.of(context).showSnackBar(
                        //   SnackBar(
                        //     content: Text(
                        //         'id khachs hangf ${_idKhachHang.runtimeType}'),
                        //     backgroundColor: Colors.red,
                        //   ),
                        // );
                        if (_idKhachHang != 0) {
                          ThemVaoGioHang(
                              _idKhachHang, sanPham['ID_san_pham'], 1);
                        }

                        //print('${sanPham['ID_san_pham']}');
                      },
                      icon: Icon(
                        Icons.shopping_cart,
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
