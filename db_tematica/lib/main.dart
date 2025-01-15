import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_data.dart'; // Importa tu clase AppData.

void main() => runApp(
      ChangeNotifierProvider(
        create: (_) => AppData()..fetchCategories(), // Inicializa AppData y carga las categorías desde el inicio.
        child: const RocketLeagueDBApp(),
      ),
    );

class RocketLeagueDBApp extends StatelessWidget {
  const RocketLeagueDBApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      debugShowCheckedModeBanner: false, // Oculta el banner de depuración.
      home: const HomePage(), // Página principal de la aplicación.
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600; // Determina si es una pantalla móvil.
    final appData = Provider.of<AppData>(context); // Obtiene la instancia de AppData proporcionada por Provider.

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
        // Cambia entre layouts móvil y escritorio con una animación de desvanecimiento.
        duration: const Duration(milliseconds: 1500), // Duración de la animación.
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(opacity: animation, child: child); // Efecto de desvanecimiento.
        },
        // Cambia entre layouts dependiendo del tamaño de la pantalla.
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
              // Menú desplegable para seleccionar una categoría.
              initialSelection: appData.selectedCategory, 
              onSelected: (String? value) {
                if (value != null) {
                  appData.selectCategory(value); // Cambia la categoría seleccionada.
                }
              },
              // Convierte la lista de categorías en entradas para el menú.
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
                ? const Center(child: Text('No items found')) // Muestra un mensaje si no hay elementos.
                : ListView.separated(
                    // Lista de elementos con separadores entre ellos.
                    itemCount: appData.items.length,
                    separatorBuilder: (context, index) {
                      return const Divider(color: Colors.grey);
                    },
                    itemBuilder: (context, index) {
                      final item = appData.items[index];
                      return ListTile(
                        title: Text(item['name'] ?? 'Unknown Item'), // Nombre del elemento.
                        onTap: () => appData.fetchItemDetails(item['id']), // Carga detalles al tocar.
                      );
                    },
                  ),
          ),
          const SizedBox(height: 16),
          if (appData.selectedItem != null)
            Column(
              children: [
                // Imagen del elemento seleccionado.
                Image.network(
                  'http://localhost:3000/${appData.selectedItem!['photo']}',
                  height: 200,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 16),
                // Descripción del elemento seleccionado.
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
                'Select an item to view details', // Mensaje cuando no hay un elemento seleccionado.
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
                child: DropdownMenu<String>(
                  width: MediaQuery.of(context).size.width * 0.39, // Ancho adaptado al tamaño de pantalla.
                  initialSelection: appData.selectedCategory, // Selección inicial basada en el estado.
                  onSelected: (String? value) {
                    if (value != null) {
                      appData.selectCategory(value); // Cambia la categoría seleccionada.
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
                      ? const Center(child: Text('No items found')) // Muestra mensaje si no hay elementos.
                      : ListView.separated(
                          // Lista de elementos con separadores.
                          itemCount: appData.items.length,
                          separatorBuilder: (context, index) {
                            return const Divider(color: Colors.grey);
                          },
                          itemBuilder: (context, index) {
                            final item = appData.items[index];
                            return ListTile(
                              title: Text(item['name'] ?? 'Unknown Item'),
                              onTap: () => appData.fetchItemDetails(item['id']), // Carga detalles al pulsar.
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
                          'Select an item to view details', // Mensaje cuando no hay selección.
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : SingleChildScrollView(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Imagen del elemento seleccionado.
                              Image.network(
                                'http://localhost:3000/${appData.selectedItem!['photo']}',
                                height: 256,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(height: 16),
                              // Descripción del elemento seleccionado.
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
