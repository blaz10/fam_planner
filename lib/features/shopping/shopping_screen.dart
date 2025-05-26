import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fam_planner/models/shopping_item.dart';
import 'package:fam_planner/services/shopping_service.dart';
import 'package:fam_planner/widgets/shopping_item_tile.dart';

class ShoppingScreen extends StatefulWidget {
  const ShoppingScreen({super.key});

  @override
  State<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends State<ShoppingScreen> {
  final TextEditingController _itemController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController(text: '1');
  String? _selectedCategory;
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _itemController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  bool _isInitializing = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeShoppingService();
  }

  Future<void> _initializeShoppingService() async {
    if (_isInitializing) return;
    
    final shoppingService = Provider.of<ShoppingService>(context, listen: false);
    if (!shoppingService.isInitialized) {
      setState(() => _isInitializing = true);
      try {
        await shoppingService.init();
      } catch (e) {
        debugPrint('Error initializing shopping service: $e');
        // Handle error if needed
      } finally {
        if (mounted) {
          setState(() => _isInitializing = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _showClearAllDialog,
            tooltip: 'Clear All',
          ),
        ],
      ),
      body: Consumer<ShoppingService>(
        builder: (context, shoppingService, _) {
          if (_isInitializing || !shoppingService.isInitialized) {
            return const Center(child: CircularProgressIndicator());
          }
          final itemsByCategory = shoppingService.getItemsByCategory();
          
          if (itemsByCategory.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 64,
                    color: Theme.of(context).hintColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your shopping list is empty',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to add an item',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: itemsByCategory.length,
            itemBuilder: (context, index) {
              final category = itemsByCategory.keys.elementAt(index);
              final items = itemsByCategory[category]!;
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      category,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return ShoppingItemTile(
                        item: item,
                        onToggleBought: () => _toggleBoughtStatus(shoppingService, item.id),
                        onDelete: () => _deleteItem(shoppingService, item.id),
                        onEdit: () => _showEditDialog(shoppingService, item),
                      );
                    },
                  ),
                  const Divider(height: 1),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddItemDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showAddItemDialog() async {
    _clearForm();
    await _showItemDialog(
      title: 'Add Item',
      onSave: (ShoppingService shoppingService) async {
        if (_itemController.text.trim().isEmpty) return;
        
        final newItem = ShoppingItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: _itemController.text.trim(),
          quantity: int.tryParse(_quantityController.text) ?? 1,
          category: _selectedCategory,
          notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
        );
        
        await shoppingService.addItem(newItem);
      },
    );
  }

  Future<void> _showEditDialog(ShoppingService shoppingService, ShoppingItem item) async {
    _itemController.text = item.name;
    _quantityController.text = item.quantity.toString();
    _selectedCategory = item.category;
    _notesController.text = item.notes ?? '';
    
    await _showItemDialog(
      title: 'Edit Item',
      onSave: (shoppingService) async {
        if (_itemController.text.trim().isEmpty) return;
        
        final updatedItem = item.copyWith(
          name: _itemController.text.trim(),
          quantity: int.tryParse(_quantityController.text) ?? 1,
          category: _selectedCategory,
          notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
        );
        
        await shoppingService.updateItem(updatedItem);
      },
    );
  }

  Future<void> _showItemDialog({
    required String title,
    required Function(ShoppingService) onSave,
  }) async {
    final categories = [
      'Fruits & Veg',
      'Dairy & Eggs',
      'Meat & Fish',
      'Bakery',
      'Beverages',
      'Snacks',
      'Household',
      'Other',
    ];

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.9,
            ),
            child: StatefulBuilder(
              builder: (context, setState) {
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _itemController,
                          decoration: const InputDecoration(
                            labelText: 'Item name',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                          autofocus: true,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 80,
                              child: TextField(
                                controller: _quantityController,
                                decoration: const InputDecoration(
                                  labelText: 'Qty',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Category',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _selectedCategory,
                                    isExpanded: true,
                                    hint: const Text(
                                      'Select category',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                    items: categories.map((String category) {
                                      return DropdownMenuItem<String>(
                                        value: category,
                                        child: Text(
                                          category,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        _selectedCategory = newValue;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _notesController,
                          decoration: const InputDecoration(
                            labelText: 'Notes (optional)',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('CANCEL'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () async {
                                final shoppingService = Provider.of<ShoppingService>(
                                  context,
                                  listen: false,
                                );
                                await onSave(shoppingService);
                                if (mounted) {
                                  Navigator.of(context).pop();
                                }
                              },
                              child: const Text('SAVE'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _showClearAllDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear All Items'),
          content: const Text('Are you sure you want to remove all items from your shopping list?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                final shoppingService = Provider.of<ShoppingService>(context, listen: false);
                shoppingService.clearAll();
                if (mounted) {
                  Navigator.of(context).pop();
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('CLEAR ALL'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _toggleBoughtStatus(ShoppingService shoppingService, String id) async {
    await shoppingService.toggleBoughtStatus(id);
  }

  Future<void> _deleteItem(ShoppingService shoppingService, String id) async {
    await shoppingService.deleteItem(id);
    
    if (!mounted) return;
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item removed'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _clearForm() {
    _itemController.clear();
    _quantityController.text = '1';
    _selectedCategory = null;
    _notesController.clear();
  }
}
