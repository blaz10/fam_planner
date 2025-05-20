import 'package:flutter/material.dart';

import '../../../core/utils/app_localizations.dart';
import '../../../models/shopping_item.dart';
import '../../../services/database_service.dart';

class ShoppingScreen extends StatefulWidget {
  const ShoppingScreen({super.key});

  @override
  State<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends State<ShoppingScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DatabaseService _databaseService = DatabaseService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.translate('shopping')),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: AppLocalizations.of(context)!.translate('to_buy')),
            Tab(text: AppLocalizations.of(context)!.translate('bought')),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildShoppingList(false),
                _buildShoppingList(true),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddItemDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context)!.translate('search_items'),
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
      ),
    );
  }
  
  Widget _buildShoppingList(bool showBought) {
    return FutureBuilder<List<ShoppingItem>>(
      future: _databaseService.getShoppingItems(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        
        var items = snapshot.data ?? [];
        
        // Filter by bought status and search query
        items = items.where((item) {
          final matchesBought = item.isBought == showBought;
          final matchesSearch = _searchQuery.isEmpty || 
              item.name.toLowerCase().contains(_searchQuery) ||
              (item.category?.toLowerCase().contains(_searchQuery) ?? false);
          return matchesBought && matchesSearch;
        }).toList();
        
        if (items.isEmpty) {
          return Center(
            child: Text(
              showBought 
                  ? AppLocalizations.of(context)!.translate('no_bought_items')
                  : AppLocalizations.of(context)!.translate('no_items_to_buy'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          );
        }
        
        // Group by category if there are categories
        final hasCategories = items.any((item) => item.category?.isNotEmpty ?? false);
        
        if (hasCategories) {
          final categories = <String, List<ShoppingItem>>{};
          
          for (var item in items) {
            final category = item.category ?? AppLocalizations.of(context)!.translate('uncategorized');
            if (!categories.containsKey(category)) {
              categories[category] = [];
            }
            categories[category]!.add(item);
          }
          
          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories.keys.elementAt(index);
              final categoryItems = categories[category]!;
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      category,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...categoryItems.map((item) => _buildShoppingItem(item)).toList(),
                ],
              );
            },
          );
        } else {
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              return _buildShoppingItem(items[index]);
            },
          );
        }
      },
    );
  }
  
  Widget _buildShoppingItem(ShoppingItem item) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.translate('confirm_delete')),
            content: Text(
              '${AppLocalizations.of(context)!.translate('delete_item_confirmation')} "${item.name}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(AppLocalizations.of(context)!.translate('cancel')),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: Text(AppLocalizations.of(context)!.translate('delete')),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        _databaseService.deleteShoppingItem(item.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.name} ${AppLocalizations.of(context)!.translate('deleted')}'),
            action: SnackBarAction(
              label: AppLocalizations.of(context)!.translate('undo'),
              onPressed: () {
                _databaseService.addShoppingItem(item);
              },
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: CheckboxListTile(
          value: item.isBought,
          onChanged: (value) => _toggleItemStatus(item, value ?? false),
          title: Text(
            item.name,
            style: TextStyle(
              decoration: item.isBought ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: item.quantity > 1
              ? Text('${AppLocalizations.of(context)!.translate('quantity')}: ${item.quantity}')
              : null,
          secondary: item.notes?.isNotEmpty ?? false
              ? IconButton(
                  icon: const Icon(Icons.notes),
                  onPressed: () => _showItemNotes(item),
                )
              : null,
        ),
      ),
    );
  }
  
  void _toggleItemStatus(ShoppingItem item, bool isBought) async {
    final updatedItem = item.copyWith(isBought: isBought);
    await _databaseService.updateShoppingItem(updatedItem);
    setState(() {});
  }
  
  void _showItemNotes(ShoppingItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item.name),
        content: Text(item.notes ?? ''),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.translate('close')),
          ),
        ],
      ),
    );
  }
  
  void _showAddItemDialog() {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController();
    final _quantityController = TextEditingController(text: '1');
    final _categoryController = TextEditingController();
    final _notesController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.translate('add_item')),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.translate('item_name'),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!.translate('name_required');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _quantityController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.translate('quantity'),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppLocalizations.of(context)!.translate('quantity_required');
                          }
                          final quantity = int.tryParse(value);
                          if (quantity == null || quantity < 1) {
                            return AppLocalizations.of(context)!.translate('quantity_invalid');
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: _categoryController,
                        decoration: InputDecoration(
                          labelText: '${AppLocalizations.of(context)!.translate('category')} (${AppLocalizations.of(context)!.translate('optional')})',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _notesController,
                  decoration: InputDecoration(
                    labelText: '${AppLocalizations.of(context)!.translate('notes')} (${AppLocalizations.of(context)!.translate('optional')})',
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.translate('cancel')),
          ),
          TextButton(
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                final newItem = ShoppingItem(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: _nameController.text,
                  quantity: int.parse(_quantityController.text),
                  category: _categoryController.text.isNotEmpty ? _categoryController.text : null,
                  notes: _notesController.text.isNotEmpty ? _notesController.text : null,
                  isBought: false,
                );
                
                _databaseService.addShoppingItem(newItem);
                Navigator.pop(context);
                setState(() {});
              }
            },
            child: Text(AppLocalizations.of(context)!.translate('add')),
          ),
        ],
      ),
    );
  }
}
