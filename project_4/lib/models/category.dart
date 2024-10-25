class Category {
  final int categoryID;
  final String categoryName;
  final String description;
  final bool status;

  Category({
    required this.categoryID,
    required this.categoryName,
    required this.description,
    required this.status,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        categoryID: json['categoryID'] != null ? json['categoryID'] as int : 0,
        categoryName: json['categoryName'],
        description: json['description'],
        status: json['status'],
      );

  Map<String, dynamic> toJson() => {
        "categoryID": categoryID,
        "categoryName": categoryName,
        "description": description,
        "status": status,
      };

  static List<Category> listFromJson(List<dynamic> json) {
    return json
        .map((data) => Category.fromJson(data as Map<String, dynamic>))
        .toList();
  }
}
