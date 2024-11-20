import 'package:shopping_list/models/grocery.model.dart';
import 'package:shopping_list/models/category.model.dart';
import 'package:shopping_list/data/categories.dart';

final groceryItems = [
  Grocery(
      id: 'a',
      name: 'Milk',
      quantity: 1,
      category: categories[Categories.dairy]!),
  Grocery(
      id: 'b',
      name: 'Bananas',
      quantity: 5,
      category: categories[Categories.fruit]!),
  Grocery(
      id: 'c',
      name: 'Beef Steak',
      quantity: 1,
      category: categories[Categories.meat]!),
];
