import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AppData extends ChangeNotifier {
  List<String> categories = [];
  String? selectedCategory;
  List<Map<String, dynamic>> items = [];
  Map<String, dynamic>? selectedItem;

  Future<void> fetchCategories() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/api/categories'));
      if (response.statusCode == 200) {
        categories = List<String>.from(json.decode(response.body));
        selectedCategory = categories.isNotEmpty ? categories.first : null;
        if (selectedCategory != null) {
          await fetchItems(selectedCategory!);
        }
        notifyListeners();
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      debugPrint('Error fetching categories: $e');
    }
  }

  Future<void> fetchItems(String category) async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/api/items/$category'));
      if (response.statusCode == 200) {
        items = List<Map<String, dynamic>>.from(json.decode(response.body));
        selectedItem = null;
        notifyListeners();
      } else {
        throw Exception('Failed to load items');
      }
    } catch (e) {
      debugPrint('Error fetching items: $e');
    }
  }

  Future<void> fetchItemDetails(int id) async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/api/items/id/$id'));
      if (response.statusCode == 200) {
        selectedItem = json.decode(response.body);
        notifyListeners();
      } else {
        throw Exception('Failed to load item details');
      }
    } catch (e) {
      debugPrint('Error fetching item details: $e');
    }
  }

  void selectCategory(String category) {
    selectedCategory = category;
    fetchItems(category);
    notifyListeners();
  }
}
