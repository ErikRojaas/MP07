import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'app_data.dart'; // Importa tu clase AppData.



void main() => runApp(

      ChangeNotifierProvider(

        create: (_) => AppData()..fetchCategories(), // Inicializa AppData y carga las categorías.

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



class HomePage extends StatelessWidget {

  const HomePage({super.key});



  @override

  Widget build(BuildContext context) {

    final isMobile = MediaQuery.of(context).size.width < 600;

    final appData = Provider.of<AppData>(context);



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

        child: isMobile ? buildMobileLayout(appData) : buildDesktopLayout(appData),

      ),

    );

  }



  Widget buildMobileLayout(AppData appData) {

    return SingleChildScrollView(

      child: Column(

        children: [

          Padding(

            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),

            child: DropdownMenu<String>(

              initialSelection: appData.selectedCategory,

              onSelected: (String? value) {

                if (value != null) {

                  appData.selectCategory(value);

                }

              },

              dropdownMenuEntries: appData.categories

                  .map((category) => DropdownMenuEntry<String>(

                        value: category,

                        label: category,

                      ))

                  .toList(),

            ),

          ),

          Container(

            height: 200,

            color: Colors.grey[200],

            child: appData.items.isEmpty

                ? const Center(child: Text('No items found'))

                : ListView.separated(

                    itemCount: appData.items.length,

                    separatorBuilder: (context, index) {

                      return const Divider(color: Colors.grey);

                    },

                    itemBuilder: (context, index) {

                      final item = appData.items[index];

                      return ListTile(

                        title: Text(item['name'] ?? 'Unknown Item'),

                        onTap: () => appData.fetchItemDetails(item['id']),

                      );

                    },

                  ),

          ),

          const SizedBox(height: 16),

          if (appData.selectedItem != null)

            Column(

              children: [

                Image.network(

                  'http://localhost:3000/${appData.selectedItem!['photo']}',

                  height: 200,

                  fit: BoxFit.contain,

                ),

                const SizedBox(height: 16),

                Text(

                  appData.selectedItem!['description'] ?? 'No Description',

                  style: const TextStyle(

                    fontSize: 14,

                    color: Colors.deepPurple,

                    fontStyle: FontStyle.italic,

                  ),

                  textAlign: TextAlign.center,

                ),

              ],

            ),

          if (appData.selectedItem == null)

            const Padding(

              padding: EdgeInsets.symmetric(vertical: 16.0),

              child: Text(

                'Select an item to view details',

                style: TextStyle(fontSize: 16, color: Colors.grey),

              ),

            ),

        ],

      ),

    );

  }



  Widget buildDesktopLayout(AppData appData) {

    return Column(

      children: [

        Padding(

          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),

          child: Row(

            mainAxisAlignment: MainAxisAlignment.start,

            children: [

              Flexible(

                child: Container(

                  child: Builder(

                    builder: (BuildContext context) {

                      return DropdownMenu<String>(

                        width: MediaQuery.of(context).size.width * 0.39,

                        initialSelection: appData.selectedCategory,

                        onSelected: (String? value) {

                          if (value != null) {

                            appData.selectCategory(value);

                          }

                        },

                        dropdownMenuEntries: appData.categories

                            .map((category) => DropdownMenuEntry<String>(

                                  value: category,

                                  label: category,

                                ))

                            .toList(),

                      );

                    },

                  ),

                ),

              ),

            ],

          ),

        ),

        Expanded(

          child: Row(

            children: [

              Flexible(

                flex: 2,

                child: Container(

                  color: Colors.grey[200],

                  child: appData.items.isEmpty

                      ? const Center(child: Text('No items found'))

                      : ListView.separated(

                          itemCount: appData.items.length,

                          separatorBuilder: (context, index) {

                            return const Divider(color: Colors.grey);

                          },

                          itemBuilder: (context, index) {

                            final item = appData.items[index];

                            return ListTile(

                              title: Text(item['name'] ?? 'Unknown Item'),

                              onTap: () => appData.fetchItemDetails(item['id']),

                            );

                          },

                        ),

                ),

              ),

              Flexible(

                flex: 3,

                child: appData.selectedItem == null

                    ? const Center(

                        child: Text(

                          'Select an item to view details',

                          style: TextStyle(fontSize: 16, color: Colors.grey),

                        ),

                      )

                    : SingleChildScrollView(

                        child: Center(

                          child: Column(

                            mainAxisAlignment: MainAxisAlignment.center,

                            children: [

                              Image.network(

                                'http://localhost:3000/${appData.selectedItem!['photo']}',

                                height: 256,

                                fit: BoxFit.contain,

                              ),

                              const SizedBox(height: 16),

                              Text(

                                appData.selectedItem!['description'] ?? 'No Description',

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

              ),

            ],

          ),

        ),

      ],

    );

  }

}
