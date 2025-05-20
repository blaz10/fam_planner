import 'package:flutter/material.dart';

class ShoppingListScreen extends StatelessWidget {
  const ShoppingListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping List'),
      ),
      body: const Center(
        child: Text('Shopping List - Coming Soon!'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Add shopping item
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
