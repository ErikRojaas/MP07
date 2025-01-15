import 'package:flutter/material.dart'; 
import 'package:http/http.dart' as http;
import 'dart:convert';

class AppData extends ChangeNotifier {
  List<String> categories = [];
  String? selectedCategory;
  List<Map<String, dynamic>> items = [];
  Map<String, dynamic>? selectedItem;

  // Método para obtener la lista de categorías desde la API.
  Future<void> fetchCategories() async {
    try {
      // Realiza una solicitud GET a la API para obtener las categorías.
      final response = await http.get(Uri.parse('http://localhost:3000/api/categories'));
      if (response.statusCode == 200) {
        categories = List<String>.from(json.decode(response.body)); // Decodifica el cuerpo de la respuesta JSON en una lista de cadenas.
        selectedCategory = categories.isNotEmpty ? categories.first : null;
        
        // Si hay una categoría seleccionada, se obtienen sus elementos.
        if (selectedCategory != null) {
          await fetchItems(selectedCategory!);
        }
        notifyListeners(); // Notifica a los widgets interesados que los datos han cambiado.
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      debugPrint('Error fetching categories: $e');
    }
  }

  // Método para obtener la lista de elementos de una categoría específica.
  Future<void> fetchItems(String category) async {
    try {
      // Realiza una solicitud GET a la API para obtener los elementos de una categoría.
      final response = await http.get(Uri.parse('http://localhost:3000/api/items/$category'));
      if (response.statusCode == 200) {
        items = List<Map<String, dynamic>>.from(json.decode(response.body)); // Decodifica el cuerpo de la respuesta JSON en una lista de mapas.
        selectedItem = null;
        notifyListeners();  // Notifica a los widgets interesados que los datos han cambiado.
      } else {
        throw Exception('Failed to load items');
      }
    } catch (e) {
      debugPrint('Error fetching items: $e');
    }
  }

  // Método para obtener los detalles de un elemento específico.
  Future<void> fetchItemDetails(int id) async {
    try {
      // Realiza una solicitud GET a la API para obtener los detalles de un elemento.
      final response = await http.get(Uri.parse('http://localhost:3000/api/items/id/$id'));
      if (response.statusCode == 200) {
        selectedItem = json.decode(response.body); // Decodifica el cuerpo de la respuesta JSON en un mapa y lo asigna al elemento seleccionado.
        notifyListeners(); // Notifica a los widgets interesados que los datos han cambiado.
      } else {
        throw Exception('Failed to load item details');
      }
    } catch (e) {
      debugPrint('Error fetching item details: $e');
    }
  }

  // Método para cambiar la categoría seleccionada y obtener sus elementos.
  void selectCategory(String category) {
    selectedCategory = category;
    fetchItems(category); // Obtiene los elementos de la nueva categoría.
    notifyListeners(); // Notifica a los widgets interesados que los datos han cambiado.
  }
}
