import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:fam_planner/models/shopping_item.dart';

class ShoppingService extends ChangeNotifier {
  static const String _boxName = 'shopping_items';
  
  late Box<ShoppingItem> _shoppingBox;
  bool _isInitialized = false;
  
  bool get isInitialized => _isInitialized;
  
  Future<void> init() async {
    if (_isInitialized) return;
    
    try {
      if (!Hive.isAdapterRegistered(3)) {
        Hive.registerAdapter(ShoppingItemAdapter());
      }
      _shoppingBox = await Hive.openBox<ShoppingItem>(_boxName);
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing ShoppingService: $e');
      rethrow;
    }
  }
  
  // Add a new shopping item
  Future<void> addItem(ShoppingItem item) async {
    await _shoppingBox.put(item.id, item);
    notifyListeners();
  }
  
  // Update an existing shopping item
  Future<void> updateItem(ShoppingItem item) async {
    await _shoppingBox.put(item.id, item);
    notifyListeners();
  }
  
  // Delete a shopping item
  Future<void> deleteItem(String id) async {
    await _shoppingBox.delete(id);
    notifyListeners();
  }
  
  // Toggle the 'isBought' status of an item
  Future<void> toggleBoughtStatus(String id) async {
    final item = _shoppingBox.get(id);
    if (item != null) {
      final updatedItem = item.copyWith(isBought: !item.isBought);
      await _shoppingBox.put(id, updatedItem);
      notifyListeners();
    }
  }
  
  // Get all shopping items
  List<ShoppingItem> getAllItems() {
    return _shoppingBox.values.toList();
  }
  
  // Get items by category
  Map<String, List<ShoppingItem>> getItemsByCategory() {
    final items = getAllItems();
    final Map<String, List<ShoppingItem>> categorized = {};
    
    for (var item in items) {
      final category = item.category ?? 'Uncategorized';
      if (!categorized.containsKey(category)) {
        categorized[category] = [];
      }
      categorized[category]!.add(item);
    }
    
    // Sort categories
    final sortedCategories = categorized.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    
    return Map.fromEntries(sortedCategories);
  }
  
  // Clear all items
  Future<void> clearAll() async {
    await _shoppingBox.clear();
    notifyListeners();
  }
}
