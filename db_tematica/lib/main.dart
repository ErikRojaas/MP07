import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(const RocketLeagueDBApp());

class RocketLeagueDBApp extends StatelessWidget {
  const RocketLeagueDBApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

typedef MenuEntry = DropdownMenuEntry<String>;

class _HomePageState extends State<HomePage> {
  List<String> categories = [];
  String? selectedCategory;
  List<Map<String, dynamic>> items = [];
  Map<String, dynamic>? selectedItem;

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    final response = await http.get(Uri.parse('http://localhost:3000/api/categories'));

    if (response.statusCode == 200) {
      setState(() {
        categories = List<String>.from(json.decode(response.body));
        selectedCategory = categories.isNotEmpty ? categories.first : null;
        if (selectedCategory != null) fetchItems(selectedCategory!);
      });
    } else {
      print('Error fetching categories: ${response.statusCode}');
    }
  }

  Future<void> fetchItems(String category) async {
    final response = await http.get(Uri.parse('http://localhost:3000/api/items/$category'));

    if (response.statusCode == 200) {
      setState(() {
        items = List<Map<String, dynamic>>.from(json.decode(response.body));
        selectedItem = null;
      });
    } else {
      print('Error fetching items: ${response.statusCode}');
    }
  }

  Future<void> fetchItemDetails(int id) async {
    final response = await http.get(Uri.parse('http://localhost:3000/api/items/id/$id'));

    if (response.statusCode == 200) {
      setState(() {
        selectedItem = json.decode(response.body);
      });
    } else {
      print('Error fetching item details: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text(
          'Rocket League DB',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
            child: Row(
              children: [
                SizedBox(
                  child: DropdownMenu<String>(
                    width: 500.0,
                    initialSelection: selectedCategory,
                    onSelected: (String? value) {
                      if (value != null) {
                        setState(() {
                          selectedCategory = value;
                          fetchItems(value);
                        });
                      }
                    },
                    dropdownMenuEntries: categories
                        .map((category) => DropdownMenuEntry<String>(
                              value: category,
                              label: category,
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                // Left Side: List of items
                Container(
                  width: MediaQuery.of(context).size.width * 0.4,
                  color: Colors.grey[200],
                  child: items.isEmpty
                      ? const Center(child: Text('No items found'))
                      : ListView.separated(
                          itemCount: items.length,
                          separatorBuilder: (context, index) {
                            return const Divider(color: Colors.grey);
                          },
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return ListTile(
                              title: Text(item['name'] ?? 'Unknown Item'),
                              onTap: () => fetchItemDetails(item['id']),
                            );
                          },
                        ),
                ),

                // Right Side: Display selected item details
                Expanded(
                  child: selectedItem == null
                      ? const Center(
                          child: Text(
                            'Select an item to view details',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.network(
                                'http://localhost:3000/${selectedItem!['photo']}',
                                height: 256,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                selectedItem!['description'] ?? 'No Description',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.deepPurple,
                                  fontStyle: FontStyle.italic,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
