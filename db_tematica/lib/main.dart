import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_data.dart'; // Importa tu clase AppData.

void main() => runApp(
      ChangeNotifierProvider(
        create: (_) => AppData()..fetchCategories(),
        child: const RocketLeagueDBApp(),
      ),
    );

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

class _HomePageState extends State<HomePage> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final appData = Provider.of<AppData>(context);
    
    final filteredItems = appData.items.where((item) {
      return item['name'].toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text(
          'Rocket League DB',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 1500),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: isMobile ? buildMobileLayout(appData, filteredItems) : buildDesktopLayout(appData, filteredItems),
      ),
    );
  }

  Widget buildMobileLayout(AppData appData, List filteredItems) {
    return SingleChildScrollView(
      child: Column(
        children: [
          categoryDropdown(appData),
          searchBar(),
          itemList(filteredItems, appData),
        ],
      ),
    );
  }

  Widget buildDesktopLayout(AppData appData, List filteredItems) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Flexible(child: categoryDropdown(appData)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              Flexible(child: searchBar()),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              Flexible(flex: 2, child: itemList(filteredItems, appData)),
              Flexible(
                flex: 3,
                child: appData.selectedItem == null
                    ? const Center(child: Text('Select an item to view details', style: TextStyle(fontSize: 16, color: Colors.grey)))
                    : itemDetails(appData),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget categoryDropdown(AppData appData) {
    return DropdownMenu<String>(
      initialSelection: appData.selectedCategory,
      onSelected: (String? value) {
        if (value != null) {
          appData.selectCategory(value);
        }
      },
      dropdownMenuEntries: appData.categories
          .map((category) => DropdownMenuEntry<String>(value: category, label: category))
          .toList(),
    );
  }

  Widget searchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: TextField(
        decoration: const InputDecoration(
          hintText: 'Search items...',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.search),
        ),
        onChanged: (value) {
          setState(() {
            searchQuery = value;
          });
        },
      ),
    );
  }

  Widget itemList(List filteredItems, AppData appData) {
    return Container(
      height: 200,
      color: Colors.grey[200],
      child: filteredItems.isEmpty
          ? const Center(child: Text('No items found'))
          : ListView.separated(
              itemCount: filteredItems.length,
              separatorBuilder: (context, index) => const Divider(color: Colors.grey),
              itemBuilder: (context, index) {
                final item = filteredItems[index];
                return ListTile(
                  title: Text(item['name'] ?? 'Unknown Item'),
                  onTap: () => appData.fetchItemDetails(item['id']),
                );
              },
            ),
    );
  }

  Widget itemDetails(AppData appData) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network('http://localhost:3000/${appData.selectedItem!['photo']}', height: 256, fit: BoxFit.contain),
            const SizedBox(height: 16),
            Text(
              appData.selectedItem!['description'] ?? 'No Description',
              style: const TextStyle(fontSize: 14, color: Colors.deepPurple, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}