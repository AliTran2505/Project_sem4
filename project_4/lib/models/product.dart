class Product{
  final int productID;
  final String productName;
  final String imageUrl;
  final double price;
  final String description;
  final int categoryID;
  final int quantity;
  final bool status;

  Product({
    required this.productID,
    required this.productName,
    required this.imageUrl,
    required this.price,
    required this.description,
    required this.categoryID,
    required this.quantity,
    required this.status,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product (
    productID: json['productID'] != null ? json['productID'] as int : 0,
    productName: json['productName'],
    imageUrl: json['imageUrl'],
    price: json['price'] != null ? (json['price'] as num).toDouble() : 0.0,
    description: json['description'],
    categoryID: json['categoryId'] != null ? json['categoryId'] as int : 0,
    quantity: json['quantity'] != null ? json['quantity'] as int : 0,
    status: json['status'],
  );

  Map<String, dynamic> toJson() => {
    "productID": productID,
    "productName": productName,
    "imageUrl": imageUrl,
    "price": price,
    "description": description,
    "categoryID": categoryID,
    "quantity": quantity,
    "status": status,
  };

  static List<Product> listFromJson(List<dynamic> json) {
    return json.map((data) => Product.fromJson(data as Map<String, dynamic>)).toList();
  }
}