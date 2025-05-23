import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fam_planner/core/service_locator.dart';
import 'shopping_screen.dart';
import 'package:fam_planner/services/shopping_service.dart';

class ShoppingListScreen extends StatelessWidget {
  const ShoppingListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ShoppingService>.value(
      value: locator<ShoppingService>(),
      child: const ShoppingScreen(),
    );
  }
}
