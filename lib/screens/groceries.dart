import 'package:flutter/material.dart';
import 'package:shopping_list/models/grocery.model.dart';
import 'package:shopping_list/screens/groceries_form.dart';
// import 'package:shopping_list/widgets/groceries_list.dart';

class GroceriesScreen extends StatefulWidget {
  const GroceriesScreen({super.key});

  @override
  State<GroceriesScreen> createState() => _GroceriesScreenState();
}

class _GroceriesScreenState extends State<GroceriesScreen> {
  final List<Grocery> _groceries = [];

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
