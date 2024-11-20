import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:shopping_list/data/categories.dart';

import 'package:shopping_list/models/grocery.model.dart';
import 'package:shopping_list/screens/groceries_form.dart';
// import 'package:shopping_list/widgets/groceries_list.dart';

class GroceriesScreen extends StatefulWidget {
  const GroceriesScreen({super.key});

  @override
  State<GroceriesScreen> createState() => _GroceriesScreenState();
}

class _GroceriesScreenState extends State<GroceriesScreen> {
  List<Grocery> _groceries = [];

  @override
  void initState() {
    super.initState();
    _fetchGroceries();
  }

  void _fetchGroceries() async {
    final url = Uri.https(
      'shopping-list-1ba7a-default-rtdb.asia-southeast1.firebasedatabase.app',
      'groceries.json',
    );
    final response = await http.get(url);
    final Map<String, dynamic> loadedGroceries = json.decode(response.body);
    final List<Grocery> loadedGroceriesList = [];
    for (final grocery in loadedGroceries.entries) {
      final category = categories.entries
          .firstWhere((item) => grocery.value['category'] == item.value.title)
          .value;
      loadedGroceriesList.add(
        Grocery(
          id: grocery.key,
          name: grocery.value['name'],
          quantity: grocery.value['quantity'],
          category: category,
        ),
      );
    }
    setState(() {
      _groceries = loadedGroceriesList;
    });
  }

  void _addGrocery() async {
    final results = await Navigator.push<Grocery>(
      context,
      MaterialPageRoute(
        builder: (ctx) => const GroceriesFormScreen(),
      ),
    );
    if (results != null) {
      setState(() {
        _groceries.add(results);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget activeScreen = Center(
      child: Text(
        "No Groceries added",
        style: Theme.of(context).textTheme.displaySmall,
      ),
    );

    if (_groceries.isNotEmpty) {
      activeScreen = ListView.builder(
        itemCount: _groceries.length,
        itemBuilder: (context, index) => Dismissible(
          key: Key(_groceries[index].id),
          background: Container(
            color: Theme.of(context).colorScheme.error,
          ),
          onDismissed: (direction) {
            setState(() {
              _groceries.removeAt(index);
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Item removed"),
              ),
            );
          },
          child: ListTile(
            title: Text(
              _groceries[index].name,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(fontWeight: FontWeight.normal),
            ),
            leading: Container(
              color: _groceries[index].category.color,
              height: 24,
              width: 24,
            ),
            trailing: Text(
              '${_groceries[index].quantity}',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(fontWeight: FontWeight.normal),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "My Groceries",
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        actions: [
          IconButton(
            onPressed: _addGrocery,
            icon: const Icon(Icons.add),
          ),
        ],
        actionsIconTheme: Theme.of(context).appBarTheme.actionsIconTheme,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
      body: activeScreen,
    );
  }
}
