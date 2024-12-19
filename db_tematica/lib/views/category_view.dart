import 'package:flutter/material.dart';
import 'item_list_view.dart';

const List<String> categories = <String>['Stadiums', 'Game Modes', 'Cars'];

class ViewMobile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.black87,
      ),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Categorias'),
          titleTextStyle: TextStyle(fontSize: 30, color: Colors.white),
          backgroundColor: Colors.black,
        ),
        body: const Center(
          child: CategoryDropdown(isMobile: true),
        ),
      ),
    );
  }
}

class ViewDesktop extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.black87,
      ),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Categorias'),
          titleTextStyle: TextStyle(fontSize: 60, color: Colors.white),
          toolbarHeight: 100,
          backgroundColor: Colors.black,
        ),
        body: const Center(
          child: CategoryDropdown(isMobile: false),
        ),
      ),
    );
  }
}

class CategoryDropdown extends StatefulWidget {
  final bool isMobile;
  const CategoryDropdown({required this.isMobile, super.key});

  @override
  _CategoryDropdownState createState() => _CategoryDropdownState();
}

class _CategoryDropdownState extends State<CategoryDropdown> {
  static final List<DropdownMenuEntry<String>> menuEntries = categories
      .map<DropdownMenuEntry<String>>(
          (String name) => DropdownMenuEntry(value: name, label: name))
      .toList();

  String? _selectedCategory = categories.first;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 200.0),
      child: Align(
        alignment: Alignment.center,
        child: SizedBox(
          width: MediaQuery.of(context).size.width * (widget.isMobile ? 0.6 : 0.8),
          child: DropdownMenu<String>(
            initialSelection: _selectedCategory,
            onSelected: (String? value) {
              setState(() {
                _selectedCategory = value;
              });
              if (value != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ItemListView(category: value),
                  ),
                );
              }
            },
            dropdownMenuEntries: menuEntries,
            textStyle: TextStyle(fontSize: widget.isMobile ? 30 : 50, color: Colors.white),
            menuStyle: MenuStyle(
              backgroundColor: MaterialStateProperty.all(Colors.yellow),
              side: MaterialStateProperty.all(BorderSide(color: Colors.yellow, width: 2.0)),
              surfaceTintColor: MaterialStateProperty.all(Colors.yellow.withOpacity(0.2)),
            ),
            width: widget.isMobile ? 400 : 600,
            menuHeight: widget.isMobile ? 400 : 600,
          ),
        ),
      ),
    );
  }
}
