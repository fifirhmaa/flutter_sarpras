class ItemModel {
  final int id;
  final String codeItem;
  final String name;
  final int categoryId;
  final String image;
  final int stock;
  final String condition;
  final String location;
  final DateTime createdAt;
  final DateTime updatedAt;

  ItemModel({
    required this.id,
    required this.codeItem,
    required this.name,
    required this.categoryId,
    required this.image,
    required this.stock,
    required this.condition,
    required this.location,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['id'],
      codeItem: json['code_item'],
      name: json['name'],
      categoryId: json['category_id'],
      image: json['image'],
      stock: json['stock'],
      condition: json['condition'],
      location: json['location'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
