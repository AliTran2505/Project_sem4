import 'package:flutter/material.dart';
import 'package:project_4/models/category.dart';
import 'package:project_4/models/product.dart';
import 'package:project_4/screens/cart_screen.dart';
import 'package:project_4/screens/details_screen.dart';
import 'package:project_4/screens/home_screen.dart';
import 'package:project_4/screens/login_screen.dart';
import 'package:project_4/screens/profile_screen.dart';
import 'package:project_4/screens/register_screen.dart';
import 'package:project_4/screens/search_screen.dart';
import 'package:project_4/services/account_service.dart';
import 'package:project_4/services/category_service.dart';
import 'package:project_4/services/product_service.dart';

class CategoryPage extends StatefulWidget {
  final int categoryId;
  const CategoryPage({Key? key, required this.categoryId}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  late Future<List<Category>> categories;
  late Future<List<Product>> products;
  final AccountService _accountService = AccountService();
  String? _userName;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    categories = CategoryService.getAll();
    products = ProductService().getProductsByCategoryId(widget.categoryId);
    print("Sending categoryId to API: ${widget.categoryId}");
    _fetchUserInfo();
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
                    showSearch(
                        context: context, delegate: CustomSearchDelegate());
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
                          MaterialPageRoute(
                              builder: (context) => ProfilePage()),
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
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text("Error occurred: ${snapshot.error}"));
                        } else if (snapshot.hasData &&
                            snapshot.data!.isNotEmpty) {
                          final data = snapshot.data!;
                          return ListView.separated(
                            itemCount: data.length,
                            separatorBuilder: (context, index) =>
                                SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final category = data[index];
                              return ListTile(
                                leading: Icon(Icons.category,
                                    color: Colors.blueGrey[700]),
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
                      leading:
                          Icon(Icons.person_add, color: Colors.blueGrey[700]),
                      title: Text('Đăng ký'),
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                              builder: (context) => RegisterPage()),
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
                    Center(
                      child: Text(
                        'Danh mục',
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 22),
                      ),
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    FutureBuilder(
                      future: products,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text("Error occurred: ${snapshot.error}"),
                          );
                        } else if (snapshot.hasData &&
                            snapshot.data!.isNotEmpty) {
                          final data = snapshot.data!;
                          return LayoutBuilder(
                            builder: (context, constraints) {
                              return GridView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 10.0,
                                  mainAxisSpacing: 20.0,
                                ),
                                itemCount: data
                                    .length, // Đảm bảo itemCount đúng bằng chiều dài của data
                                itemBuilder: (context, index) {
                                  if (index < data.length) {
                                    // Kiểm tra chỉ số trước khi truy cập
                                    final product = data[index];
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => DetailPage(
                                              productId: product.productID,
                                            ),
                                          ),
                                        );
                                      },
                                      child: _buildImageWithDetails(
                                        imagePath:
                                            'http://art.somee.com/images/${product.imageUrl}',
                                        name: product.productName,
                                        price: '${product.price.toString()} đ',
                                      ),
                                    );
                                  } else {
                                    return SizedBox
                                        .shrink(); // Trả về widget trống nếu index không hợp lệ
                                  }
                                },
                              );
                            },
                          );
                        } else {
                          return Center(child: Text("No data available"));
                        }
                      },
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    Text(
                      'ĐĂNG KÝ NHẬN TIN',
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
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
                          padding: EdgeInsets.fromLTRB(30, 15, 30, 15)),
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
                                child: Image.asset(
                                  'assets/images/logo.png',
                                  width: 200,
                                ),
                              ),
                              SizedBox(
                                height: 25,
                              ),
                              Text(
                                'Liên hệ',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Địa chỉ: Đà Nẵng',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          )),
                    ),
                  ],
                ),
              ),
            )));
  }

  Widget _buildImageWithDetails(
      {required String imagePath,
      required String name,
      required String price}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
        Text(price, style: TextStyle(color: Colors.green)),
      ],
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
    return FutureBuilder(
      future: ProductService().searchProducts(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error occurred: ${snapshot.error}"));
        } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          final products = snapshot.data!;
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ListTile(
                title: Text(product.productName),
                subtitle: Text('${product.price.toString()} đ'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          DetailPage(productId: product.productID),
                    ),
                  );
                },
              );
            },
          );
        } else {
          return Center(child: Text("No results found"));
        }
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }
}
