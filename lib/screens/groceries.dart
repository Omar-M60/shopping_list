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
  bool _isLoading = true;
  String? _error;

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

    try {
      final response = await http.get(url);
      if (response.statusCode >= 400) {
        setState(() {
          _isLoading = false;
          _error = 'Failed to fetch data. Please try again later.';
        });
      }

      if (response.body == 'null') {
        setState(() {
          _isLoading = false;
          return;
        });
      }

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
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Something Went Wrong. Please try again later.';
      });
    }
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

  void _removeGrocery(BuildContext context, Grocery grocery) async {
    final index = _groceries.indexOf(grocery);
    setState(() {
      _groceries.removeAt(index);
    });

    final url = Uri.https(
      'shopping-list-1ba7a-default-rtdb.asia-southeast1.firebasedatabase.app',
      'groceries/${grocery.id}.json',
    );

    final res = await http.delete(url);

    // In case of error
    if (res.statusCode >= 400) {
      setState(() {
        _groceries.insert(index, grocery);
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Something went wrong removing the item."),
          ),
        );
      }
      return;
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Item removed"),
        ),
      );
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

    if (_isLoading) {
      activeScreen = Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    }

    if (_groceries.isNotEmpty) {
      activeScreen = ListView.builder(
        itemCount: _groceries.length,
        itemBuilder: (context, index) => Dismissible(
          key: Key(_groceries[index].id),
          background: Container(
            color: Theme.of(context).colorScheme.error,
          ),
          onDismissed: (direction) {
            _removeGrocery(context, _groceries[index]);
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

    if (_error != null) {
      activeScreen = Center(child: Text(_error!));
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
