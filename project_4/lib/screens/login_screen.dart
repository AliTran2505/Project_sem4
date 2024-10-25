import 'package:flutter/material.dart';
import 'package:project_4/models/category.dart';
import 'package:project_4/screens/cart_screen.dart';
import 'package:project_4/screens/home_screen.dart';
import 'package:project_4/screens/register_screen.dart';
import 'package:project_4/screens/search_screen.dart';
import 'package:project_4/services/account_service.dart';
import 'package:project_4/services/category_service.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  late Future<List<Category>> categories;
  final _userNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final AccountService _accountService = AccountService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    categories = CategoryService.getAll();
  }

  void _login() async {
    setState(() {
      _isLoading = true;
    });
    try {
      // Gọi phương thức login và chờ phản hồi
      await _accountService.login(
        _userNameController.text,
        _passwordController.text,
      );
      // Nếu không có lỗi, chuyển hướng đến trang chính
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      // Hiển thị thông báo lỗi nếu có ngoại lệ
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    } finally {
      // Đặt lại trạng thái loading
      setState(() {
        _isLoading = false;
      });
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
                        'Menu',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
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
                    title: Text('Đăng nhập'),
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                  ),
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
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('ĐĂNG NHẬP',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 22
                            ),
                          ),
                          SizedBox(height: 15,),                  
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                 TextFormField(
                                  controller: _userNameController,
                                  decoration: InputDecoration(
                                    labelText: 'UserName...',
                                    border: OutlineInputBorder()
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Hãy nhập tên người dùng';
                                    } else {
                                      return null;
                                    }
                                  },
                                ),
                                SizedBox(height: 15,),
                                TextFormField(
                                  obscureText: true,
                                  controller: _passwordController,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Mật khẩu...',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Hãy nhập mật khẩu';
                                    } else {
                                      return null;
                                    }
                                  },
                                ),
                              ],
                            )
                          ),                   
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {},
                              child: Text('Quên mật khẩu?', style: TextStyle(color: Color(0xFF7A7A9D)),),
                            ),
                          ),
                          _isLoading
                              ? CircularProgressIndicator()
                              : ElevatedButton(
                            onPressed:  () {
                              if (_formKey.currentState!.validate()) {
                                 _login(); 
                              }
                            },
                            child: Text('Đăng nhập'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              padding: EdgeInsets.fromLTRB(60, 10, 60, 10),
                            ),
                          ),
                          OutlinedButton(
                            onPressed: (){
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (context) => RegisterPage()),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.fromLTRB(63, 10, 63, 10)
                            ),
                            child: Text('ĐĂNG KÝ', style: TextStyle(color: Color(0xFF7A7A9D)),),
                          ),
                          SizedBox(height: 10,),
                          Text('--- Hoặc ---',style: TextStyle(color: Colors.grey)),
                          SizedBox(height: 10,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: Icon(Icons.facebook),
                                onPressed: () {},
                              ),
                              SizedBox(width: 20),
                              IconButton(
                                icon: Icon(Icons.g_mobiledata),
                                onPressed: () {},
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10,),
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