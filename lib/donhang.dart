import 'package:flutter/material.dart';

class DonHangScreen extends StatefulWidget {
  @override
  _DonHangScreenState createState() => _DonHangScreenState();
}

class _DonHangScreenState extends State<DonHangScreen> {
  final List<Map<String, dynamic>> cartItems = [
    {
      'image': 'https://via.placeholder.com/150', // Replace with actual image
      'name': 'Casio G-Shock GA-2100',
      'price': 2500000,
      'quantity': 2,
    },
    {
      'image': 'https://via.placeholder.com/150',
      'name': 'Hublot Classic Fusion Automatic 18K Gold',
      'price': 10000000,
      'quantity': 4,
    },
    {
      'image': 'https://via.placeholder.com/150',
      'name': 'Hublot Big Bang',
      'price': 20000000,
      'quantity': 5,
    },
    {
      'image': 'https://via.placeholder.com/150',
      'name': 'Omega Speedmaster Professional',
      'price': 15000000,
      'quantity': 3,
    },
  ];

  double get totalPrice {
    return cartItems.fold(
        0, (sum, item) => sum + (item['price'] * item['quantity']));
  }

  void updateQuantity(int index, int delta) {
    setState(() {
      cartItems[index]['quantity'] =
          (cartItems[index]['quantity'] + delta).clamp(1, 99);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Đơn hàng của bạn'),
        backgroundColor: Colors.grey,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: ListTile(
                    leading:
                        Image.network(item['image'], width: 50, height: 50),
                    title: Text(item['name']),
                    subtitle: Text('${item['price'].toString()}đ',
                        style: TextStyle(color: Colors.red)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove),
                          onPressed: () => updateQuantity(index, -1),
                        ),
                        Text('${item['quantity']}'),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () => updateQuantity(index, 1),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.grey),
                          onPressed: () {
                            setState(() {
                              cartItems.removeAt(index);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              //mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tổng cộng:   ',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${totalPrice.toString()}đ',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red),
                ),
                Spacer(),
                ElevatedButton(
                  onPressed: () {
                    // Xử lý thanh toán
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 185, 111, 111),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  child: Text(
                    'Thanh toán',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
