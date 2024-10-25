import 'package:flutter/material.dart';
import 'package:project_4/models/category.dart';
import 'package:project_4/screens/checkout_screen.dart';
import 'package:project_4/screens/home_screen.dart';
import 'package:project_4/screens/login_screen.dart';
import 'package:project_4/screens/product_screen.dart';
import 'package:project_4/screens/profile_screen.dart';
import 'package:project_4/screens/register_screen.dart';
import 'package:project_4/screens/search_screen.dart';
import 'package:project_4/services/account_service.dart';
import 'package:project_4/services/cart_service.dart';
import 'package:project_4/services/category_service.dart';

class CartPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<dynamic> _cartItems = [];
  late Future<List<Category>> categories;
  final AccountService _accountService = AccountService();
  final CartService _cartService = CartService();
  String? _userName;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    categories = CategoryService.getAll();
    _fetchUserInfo();
    _loadCart();
  }

  // Lấy thông tin người dùng
  Future<void> _fetchUserInfo() async {
    try {
      final userInfo = await _accountService.getMe(); 
      setState(() {
        _userName = userInfo['userName']; 
        _isLoggedIn = true;
      });
    } catch (e) {
      print('Error fetching user info: $e');
    }
  }

  // Xử lý đăng xuất
  Future<void> _logout() async {
    if (_isLoggedIn) {
      try {
        await _accountService.logout(); 
        setState(() {
          _isLoggedIn = false;
          _userName = null;
        });
      } catch (e) {
        print('Error logging out: $e');
      }
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  // Cập nhật số lượng sản phẩm
  void _updateQuantity(int index, String type) async {
    if (index < 0 || index >= _cartItems.length) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Index không hợp lệ')));
      return;
    }
    final item = _cartItems[index];
    var cartId = item['cartID']; // Lấy cartId từ item
    if (cartId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cart ID không hợp lệ')));
      return;
    }
    try {
      await _cartService.updateCart(cartId, type);
      _loadCart(); // Tải lại giỏ hàng sau khi cập nhật
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

   // Tải giỏ hàng từ API
  void _loadCart() async {
    try {
      List<dynamic> items = await _cartService.getCartByAccount();
      if (mounted) {
        setState(() {
          _cartItems = items; // Cập nhật danh sách sản phẩm
        });
        print(_cartItems);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  // xóa sản phẩm
  void _deleteItem(dynamic item) async {
    final cartId = item['cartID']; 
    if (cartId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ID không hợp lệ')));
      return;
    }
    try {
      bool success = await _cartService.deleteProductFromCart(cartId);
      if (success) {
        setState(() {
          _cartItems.remove(item); 
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã xóa sản phẩm')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  // xóa nhiều sản phẩm
  void _deleteSelectedItems() async {
    List<int> selectedIds = [];
    for (var item in _cartItems) {
      if (item['isChecked'] == true) { // Kiểm tra sản phẩm có được chọn không
        if (item['cartID'] != null) { // Kiểm tra xem cartID có tồn tại không
          selectedIds.add(item['cartID']); // Thêm cartID vào danh sách
        }
      }
    }
    if (selectedIds.isNotEmpty) {
      try {
        bool success = await _cartService.deleteMultipleProductsFromCart(selectedIds);   
        if (success) {
          setState(() {
            _cartItems.removeWhere((item) => selectedIds.contains(item['cartID'])); // Cập nhật giỏ hàng
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Đã xóa sản phẩm đã chọn')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Có lỗi xảy ra.')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Có lỗi xảy ra: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng chọn ít nhất một sản phẩm để xóa.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: Align(
                alignment: Alignment.center,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                    );
                  },
                  child: Image.asset('assets/images/logo.png'),
                ),
              ),
              backgroundColor: Colors.black,
              automaticallyImplyLeading: true,
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    showSearch(context: context, delegate: CustomSearchDelegate());
                  },
                ),
                IconButton(
                  icon: Icon(Icons.card_travel),
                  onPressed: () => {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => CartPage()),
                    )
                  },
                ),
              ],
            ),
            drawer: Drawer(
              child: Column(
                children: <Widget>[
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: Color(0xFF2C3848),
                    ),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        _userName != null ? 'Hello $_userName' : 'Menu',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  if (_isLoggedIn) ...[
                    ListTile(
                      leading: Icon(Icons.person, color: Colors.blueGrey[700]),
                      title: Text('Hồ sơ'),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => ProfilePage()),
                        );
                      },
                    ),
                  ],
                  ListTile(
                    leading: Icon(Icons.home, color: Colors.blueGrey[700]),
                    title: Text('Trang chủ'),
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => HomePage()),
                      );
                    },
                  ),
                  Expanded(
                    child: FutureBuilder(
                      future: categories,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.hasError) {
                          return Center(child: Text("Error occurred: ${snapshot.error}"));
                        } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                          final data = snapshot.data!;
                          return ListView.separated(
                            itemCount: data.length,
                            separatorBuilder: (context, index) => SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final category = data[index];
                              return ListTile(
                                leading: Icon(Icons.category, color: Colors.blueGrey[700]),
                                title: Text(category.categoryName),
                                onTap: () {},
                              );
                            },
                          );
                        } else {
                          return Center(child: Text("No data available"));
                        }
                      },
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.login, color: Colors.blueGrey[700]),
                    title: Text(_isLoggedIn ? 'Đăng xuất' : 'Đăng nhập'),
                    onTap: _logout,
                  ), 
                  if (!_isLoggedIn)         
                  ListTile(
                    leading: Icon(Icons.person_add, color: Colors.blueGrey[700]),
                    title: Text('Đăng ký'),
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => RegisterPage()),
                      );
                    },
                  ),
                ],
              ),
            ),
            body: SingleChildScrollView(
              padding: EdgeInsets.all(5),
              child: Container(
                child: Column(
                  children: [
                   _isLoggedIn
                  ? Column(
                      children: [
                        // Kiểm tra xem giỏ hàng có sản phẩm không
                        if (_cartItems.isNotEmpty) ...[
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: _cartItems.length,
                            itemBuilder: (context, index) {
                              final item = _cartItems[index];
                              final product = item['product'];
                              bool isChecked = item['isChecked'] ?? false;
                              String imageUrl = product != null ? 'http://art.somee.com/images/${product['imageUrl']}' : '';
                              String productName = product != null ? product['productName'] : 'Tên sản phẩm không có';
                              double price = product != null ? (product['price'] is int
                                  ? (product['price'] as int).toDouble()
                                  : product['price'] ?? 0.0)
                                  : 0.0;
                              int quantity = item['quantity'] ?? 1;
                              return Card(
                                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Checkbox(
                                        value: isChecked,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            item['isChecked'] = value;
                                          });
                                        },
                                      ),
                                      SizedBox(width: 8),
                                      Image.network(imageUrl, width: 80, height: 80, fit: BoxFit.cover),
                                      SizedBox(width: 16),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(productName, style: TextStyle(fontWeight: FontWeight.bold)),
                                          Text('${(price * quantity).toStringAsFixed(0)}đ', style: TextStyle(color: Colors.green)),
                                          Row(
                                            children: [
                                              IconButton(icon: Icon(Icons.remove), onPressed: () => _updateQuantity(index, 'minus')),
                                              Text('$quantity'),
                                              IconButton(icon: Icon(Icons.add), onPressed: () => _updateQuantity(index, 'plus')),
                                            ],
                                          ),
                                        ],
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.cancel),
                                        onPressed: () => _deleteItem(item),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: _deleteSelectedItems,
                             style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF343a40),
                            ),
                            child: Text('Xóa đã chọn'),
                          ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Tổng cộng:',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                 '${_cartItems.fold(0.0, (sum, item) {
                                  final product = item['product'];
                                  double price = product != null ? (product['price'] is int ? (product['price'] as int).toDouble() : product['price'] ?? 0.0) : 0.0;
                                  int quantity = item['quantity'] ?? 1;
                                  return sum + (price * quantity);
                                }).toStringAsFixed(0)}đ',
                                style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {
                            // Lấy danh sách sản phẩm đã chọn
                              List<dynamic> selectedProducts = _cartItems.where((item) => item['isChecked'] == true).map((item) => item['product']).toList();
                              // Chuyển đến trang Checkout với danh sách sản phẩm đã chọn
                              if (selectedProducts.isNotEmpty) {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(builder: (context) => CheckoutPage(selectedProducts: selectedProducts)),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Vui lòng chọn ít nhất một sản phẩm để thanh toán.')));
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.fromLTRB(80, 10, 80, 10),
                              backgroundColor: Color(0xFF343a40),
                            ),
                            child: Text('Thanh toán'),
                          ),
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                onPressed: () {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(builder: (context) => HomePage()),
                                  );
                                },
                                icon: Icon(Icons.keyboard_backspace),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(builder: (context) => ProductPage()),
                                  );
                                },
                                child: Text('Tiếp tục mua hàng', style: TextStyle(color: Colors.black)),
                              ),
                            ],
                          ),
                        ] else ...[
                          // Hiển thị thông báo nếu giỏ hàng trống
                          Center(
                            child: Container(
                              height: 300,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Giỏ hàng của bạn đang trống',
                                    style: TextStyle(fontSize: 18),
                                    textAlign: TextAlign.center,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          Navigator.of(context).pushReplacement(
                                            MaterialPageRoute(builder: (context) => HomePage()),
                                          );
                                        },
                                        icon: Icon(Icons.keyboard_backspace),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pushReplacement(
                                            MaterialPageRoute(builder: (context) => ProductPage()),
                                          );
                                        },
                                        child: Text('Tiếp tục mua hàng', style: TextStyle(color: Colors.black)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    )
                  : Center(
                      child: Container(
                        height: 300,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Bạn cần đăng nhập để xem giỏ hàng.',
                              style: TextStyle(fontSize: 18),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(builder: (context) => LoginPage()),
                                );
                              },
                              child: Text('Đăng nhập'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                padding: EdgeInsets.fromLTRB(60, 10, 60, 10),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'ĐĂNG KÝ NHẬN TIN',
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Nhập Email',
                        border: OutlineInputBorder(),
                        labelStyle: TextStyle(color: Colors.black),
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF86590d),
                        padding: EdgeInsets.fromLTRB(30, 15, 30, 15),
                      ),
                      child: Text('ĐĂNG KÍ'),
                    ),
                    SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        color: Colors.black,
                        padding: EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Align(
                              alignment: Alignment.topLeft,
                              child: Image.asset('assets/images/logo.png', width: 200),
                            ),
                            SizedBox(height: 25),
                            Row(
                              children: [
                                IconButton(onPressed: () {}, icon: Icon(Icons.location_on, color: Colors.white)),
                                Text('Địa chỉ: Quận 7, TP.HCM', style: TextStyle(color: Colors.white)),
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                IconButton(onPressed: () {}, icon: Icon(Icons.phone, color: Colors.white)),
                                Text('Điện thoại: 0888883200', style: TextStyle(color: Colors.white)),
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                IconButton(onPressed: () {}, icon: Icon(Icons.mail, color: Colors.white)),
                                Text('Email: hunganhparis@gmail.com', style: TextStyle(color: Colors.white)),
                              ],
                            ),
                            SizedBox(height: 20),
                            Center(
                              child: Text(
                                'Copyright © 2024 Deal Hub',
                                style: TextStyle(
                                  color: Color(0xFFACACAC),
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
        )
    );
  }
}

class CustomSearchDelegate extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Sử dụng callback sau khi khung hình để điều hướng
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (query.isNotEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SearchResultsPage(name: query),
          ),
        );
      } else {
        // Xử lý trường hợp query rỗng
        print('Query is empty');
      }
    });

    // Trả về một container trống vì chúng ta đang điều hướng đi
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = [
      'Gucci',
      'Balenciaga',
      'Acme De La Vie'
    ];

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(suggestions[index]),
          onTap: () {
            query = suggestions[index];
            showResults(context);
          },
        );
      },
    );
  }
}

