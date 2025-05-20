import 'package:hive/hive.dart';
import 'package:fam_planner/models/base_model.dart';

part 'shopping_item.g.dart';

@HiveType(typeId: 3)
class ShoppingItem extends HiveObject implements BaseModel<ShoppingItem> {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final int quantity;
  
  @HiveField(3)
  final bool isBought;
  
  @HiveField(4)
  final String? addedBy;
  
  @HiveField(5)
  final String? category;
  
  @HiveField(6)
  final String? notes;
  
  ShoppingItem({
    required this.id,
    required this.name,
    this.quantity = 1,
    this.isBought = false,
    this.addedBy,
    this.category,
    this.notes,
  });
  
  @override
  int get typeId => 3;
  
  @override
  Map<String, dynamic> toHive() => toJson();
  
  @override
  ShoppingItem fromHive(Map<String, dynamic> json) => fromJson(json);
  
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'isBought': isBought,
      'addedBy': addedBy,
      'category': category,
      'notes': notes,
    };
  }
  
  @override
  ShoppingItem fromJson(Map<String, dynamic> json) {
    return ShoppingItem(
      id: json['id'],
      name: json['name'],
      quantity: json['quantity'] ?? 1,
      isBought: json['isBought'] ?? false,
      addedBy: json['addedBy'],
      category: json['category'],
      notes: json['notes'],
    );
  }
  
  ShoppingItem copyWith({
    String? id,
    String? name,
    int? quantity,
    bool? isBought,
    String? addedBy,
    String? category,
    String? notes,
  }) {
    return ShoppingItem(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      isBought: isBought ?? this.isBought,
      addedBy: addedBy ?? this.addedBy,
      category: category ?? this.category,
      notes: notes ?? this.notes,
    );
  }
}
