import 'package:flutter/material.dart';
import 'package:project_4/models/category.dart';
import 'package:project_4/models/product.dart';
import 'package:project_4/screens/cart_screen.dart';
import 'package:project_4/screens/home_screen.dart';
import 'package:project_4/screens/login_screen.dart';
import 'package:project_4/screens/profile_screen.dart';
import 'package:project_4/screens/register_screen.dart';
import 'package:project_4/screens/search_screen.dart';
import 'package:project_4/services/account_service.dart';
import 'package:project_4/services/cart_service.dart';
import 'package:project_4/services/category_service.dart';
import 'package:project_4/services/product_service.dart';

class DetailPage extends StatefulWidget {
  final int productId;
  DetailPage({ required this.productId});
  @override
  State<StatefulWidget> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  Product? _product;
  late Future<List<Category>> categories;
  final AccountService _accountService = AccountService();
  final CartService _cartService = CartService();
  String? _userName;
  bool _isLoggedIn = false;
  @override
  void initState() {
    super.initState();
    categories = CategoryService.getAll();
    _fetchProduct();
    _fetchUserInfo();
  }

 Future<void> _fetchProduct() async {
    try {
      final product = await ProductService.getById(widget.productId);
      if (mounted) {
        setState(() {
          _product = product;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load product')),
        );
      }
    }
  }

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

  int _quantity = 1;
  void _incrementQuantity() {
    setState(() {
      _quantity++;
    });
  }

  void _decrementQuantity() {
    setState(() {
      if (_quantity > 1) {
        _quantity--;
      }
    });
  }

  void _addToCart() async {
    try {
      await _cartService.addProductToCart(widget.productId, _quantity);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Thêm vào giỏ hàng thành công!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add to cart: $e')));
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
            body: _product == null
            ? Center(child: CircularProgressIndicator()) : 
            SingleChildScrollView(
              padding: EdgeInsets.all(5),
              child: Container(
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Image.network('http://art.somee.com/images/${_product?.imageUrl}')
                        ],
                      ),
                    ),
                    SizedBox(height: 20,),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          '${_product?.productName}',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 22,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          '${_product?.price.toString()} đ',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove),
                          onPressed: _decrementQuantity,
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            '$_quantity',
                            style: TextStyle(fontSize: 20.0),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: _incrementQuantity,
                        ),
                      ],
                    ),
                    SizedBox(height: 20,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: _addToCart,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: EdgeInsets.fromLTRB(40, 10, 40, 10),
                          ),
                          child: Text('Thêm vào giỏ'),
                        ),
                        SizedBox(width: 10,),
                        OutlinedButton(onPressed: (){},
                          style: OutlinedButton.styleFrom(
                              foregroundColor: Color(0xFF2C3848),
                              padding: EdgeInsets.fromLTRB(52, 10, 52, 10)
                          ),
                          child: Text('Mua ngay'),
                        ),
                      ],
                    ),
                    SizedBox(height: 10,),
                    TextButton(onPressed: (){
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Thông tin sản phẩm'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Chất liệu: ${_product?.description}'),
                                Text('HƯỚNG DẪN BẢO QUẢN:'),
                                Text('- Lộn trái sản phẩm khi giặt, không giặt chung sản phẩm trắng với quần áo tối màu.'),
                                Text('- Sử dụng xà phòng trung tính,không sử dụng xà phòng có chất tẩy mạnh.'),
                                Text('- Không sử dụng chất tẩy, không ngâm sản phẩm.'),
                                Text('- Phơi ngang, không treo móc khi sản phẩm ướt, không phơi trực tiếp dưới ánh nắng mặt trời.'),
                                Text('- Hạn chế sấy ở nhiệt độ cao, bảo quản nơi khô ráo, thoáng mát.'),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('Đóng'),
                              ),
                            ],
                          );
                        },
                      );
                    }, child: Text('Thông tin sản phẩm', style: TextStyle(color: Colors.black),)),
                    SizedBox(height: 20,),
                    Align(
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Image.asset('assets/images/size_chart.jpg')
                        ],
                      )
                    ),
                    SizedBox(height: 20,),
                    Text('ĐĂNG KÝ NHẬN TIN',
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Nhập EmaiL',
                        border: OutlineInputBorder(),
                        labelStyle: TextStyle(color: Colors.black),
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF86590d),
                          padding: EdgeInsets.fromLTRB(30, 15, 30, 15)
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
                                child: Image.asset('assets/images/logo.png', width: 200,),
                              ),
                              SizedBox(height: 25,),
                              Row(
                                children: [
                                  IconButton(onPressed: (){}, icon: Icon(Icons.location_on, color: Colors.white,)
                                  ),
                                  Text('Địa chỉ: Quận 7, TP.HCM', style: TextStyle(color: Colors.white),)
                                ],
                              ),
                              SizedBox(height: 10,),
                              Row(
                                children: [
                                  IconButton(onPressed: (){}, icon: Icon(Icons.phone, color: Colors.white,)
                                  ),
                                  Text('Điện thoại: 0888883200', style: TextStyle(color: Colors.white),)
                                ],
                              ),
                              SizedBox(height: 10,),
                              Row(
                                children: [
                                  IconButton(onPressed: (){}, icon: Icon(Icons.mail, color: Colors.white,)
                                  ),
                                  Text('Email: hunganhparis@gmail.com', style: TextStyle(color: Colors.white),)
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
                              )
                            ],
                          )
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