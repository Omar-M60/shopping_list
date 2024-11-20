import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/category.model.dart';
import 'package:shopping_list/models/grocery.model.dart';
import 'package:shopping_list/validators/text_validator.dart';

class GroceriesFormScreen extends StatefulWidget {
  const GroceriesFormScreen({super.key});

  @override
  State<GroceriesFormScreen> createState() {
    return _GroceriesFormScreenState();
  }
}

class _GroceriesFormScreenState extends State<GroceriesFormScreen> {
  final _formKey = GlobalKey<FormState>();
  var _inputTitle = "";
  var _inputQuantity = 1;
  var _inputCategory = categories[Categories.dairy]!;
  bool _isSending = false;

  void _saveItems(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isSending = true;
      });
      final url = Uri.https(
        'shopping-list-1ba7a-default-rtdb.asia-southeast1.firebasedatabase.app',
        'groceries.json',
      );
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(
          {
            'name': _inputTitle,
            'quantity': _inputQuantity,
            'category': _inputCategory.title,
          },
        ),
      );

      final Map<String, dynamic> resData = json.decode(response.body);
      if (context.mounted) {
        Navigator.of(context).pop(
          Grocery(
            id: resData['name'],
            name: _inputTitle,
            quantity: _inputQuantity,
            category: _inputCategory,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Add Grocery Item",
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                maxLength: 100,
                decoration: InputDecoration(
                  label: Text(
                    "Item Name",
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge!
                        .copyWith(fontSize: 16),
                  ),
                ),
                validator: (value) {
                  final results = validateTextField(value);
                  if (!results.status) return results.message;
                  return null;
                },
                onSaved: (newValue) => _inputTitle = newValue!,
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                          label: Text(
                        "Quantity",
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge!
                            .copyWith(fontSize: 16),
                      )),
                      keyboardType: TextInputType.number,
                      initialValue: _inputQuantity.toString(),
                      validator: (value) {
                        final results = validateNumberField(value);
                        if (!results.status) return results.message;
                        return null;
                      },
                      onSaved: (newValue) =>
                          _inputQuantity = int.parse(newValue!),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField(
                      value: _inputCategory,
                      items: [
                        for (final category in categories.entries)
                          DropdownMenuItem(
                            value: category.value,
                            child: Row(
                              children: [
                                Container(
                                  color: category.value.color,
                                  height: 12,
                                  width: 12,
                                ),
                                const SizedBox(width: 8),
                                Text(category.value.title),
                              ],
                            ),
                          ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _inputCategory = value!;
                        });
                      },
                    ),
                  )
                ],
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSending
                        ? null
                        : () {
                            _formKey.currentState!.reset();
                          },
                    style: Theme.of(context).textButtonTheme.style,
                    child: const Text("Reset"),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _isSending ? null : () => _saveItems(context),
                    style: Theme.of(context).elevatedButtonTheme.style,
                    child: _isSending
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          )
                        : const Text("Add Item"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
