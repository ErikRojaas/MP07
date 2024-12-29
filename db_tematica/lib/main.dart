import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(const RocketLeagueDBApp()); // Ejecuta el widget principal.

class RocketLeagueDBApp extends StatelessWidget {
  const RocketLeagueDBApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      debugShowCheckedModeBanner: false, // Desactiva el banner de depuración.
      home: const HomePage(), // Página inicial de la aplicación.
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
  List<String> categories = []; // Lista de categorías obtenidas desde la API.
  String? selectedCategory; // Categoría seleccionada por el usuario.
  List<Map<String, dynamic>> items = []; // Lista de elementos de la categoría seleccionada.
  Map<String, dynamic>? selectedItem; // Elemento seleccionado para mostrar detalles.

  @override
  void initState() {
    super.initState();
    fetchCategories(); // Llama a la API para obtener las categorías al inicio.
  }

  // Función para obtener las categorías desde la API.
  Future<void> fetchCategories() async {
    final response = await http.get(Uri.parse('http://localhost:3000/api/categories'));

    if (response.statusCode == 200) {
      setState(() {
        categories = List<String>.from(json.decode(response.body)); // Decodifica la respuesta JSON y la guarda en 'categories'.
        selectedCategory = categories.isNotEmpty ? categories.first : null; // Establece la primera categoría si está disponible.
        if (selectedCategory != null) fetchItems(selectedCategory!); // Obtiene los ítems de la categoría seleccionada.
      });
    } else {
      print('Error fetching categories: ${response.statusCode}');
    }
  }

  // Función para obtener los ítems de una categoría desde la API.
  Future<void> fetchItems(String category) async {
    final response = await http.get(Uri.parse('http://localhost:3000/api/items/$category'));

    if (response.statusCode == 200) {
      setState(() {
        items = List<Map<String, dynamic>>.from(json.decode(response.body)); // Actualiza la lista de ítems.
        selectedItem = null; // Limpia la selección de ítem.
      });
    } else {
      print('Error fetching items: ${response.statusCode}');
    }
  }

  // Función para obtener los detalles de un ítem específico.
  Future<void> fetchItemDetails(int id) async {
    final response = await http.get(Uri.parse('http://localhost:3000/api/items/id/$id'));

    if (response.statusCode == 200) {
      setState(() {
        selectedItem = json.decode(response.body); // Guarda los detalles del ítem seleccionado.
      });
    } else {
      print('Error fetching item details: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600; // Detecta si la pantalla es móvil o escritorio.

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple, // Color de fondo de la barra superior.
        title: const Text(
          'Rocket League DB', // Título de la app.
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center, // Centra el texto del título.
        ),
        centerTitle: true,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 1500), // Duración de la animación (1.5 segundos).
        switchInCurve: Curves.easeInOut, // Curva de entrada para la animación.
        switchOutCurve: Curves.easeInOut, // Curva de salida para la animación.
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation, // Efecto de desvanecimiento (fade) durante la transición.
            child: child,
          );
        },
        child: isMobile ? buildMobileLayout() : buildDesktopLayout(), // Elige el layout móvil o de escritorio según el tamaño de la pantalla.
      ),
    );
  }

  // Layout para pantallas móviles
  Widget buildMobileLayout() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
            child: DropdownMenu<String>(
              initialSelection: selectedCategory, // Muestra la categoría seleccionada.
              onSelected: (String? value) {
                if (value != null) {
                  setState(() {
                    selectedCategory = value; // Actualiza la categoría seleccionada.
                    fetchItems(value); // Obtiene los ítems de la nueva categoría.
                  });
                }
              },
              dropdownMenuEntries: categories
                  .map((category) => DropdownMenuEntry<String>( // Crea un menú desplegable con las categorías.
                        value: category,
                        label: category,
                      ))
                  .toList(),
            ),
          ),
          Container(
            height: 200,
            color: Colors.grey[200],
            child: items.isEmpty
                ? const Center(child: Text('No items found')) // Muestra mensaje si no hay ítems.
                : ListView.separated(
                    itemCount: items.length, // Muestra la lista de ítems.
                    separatorBuilder: (context, index) {
                      return const Divider(color: Colors.grey); // Separa los ítems con una línea.
                    },
                    itemBuilder: (context, index) {
                      final item = items[index]; // Obtiene el ítem en la posición actual.
                      return ListTile(
                        title: Text(item['name'] ?? 'Unknown Item'), // Muestra el nombre del ítem.
                        onTap: () => fetchItemDetails(item['id']), // Llama a la función para obtener detalles del ítem.
                      );
                    },
                  ),
          ),
          const SizedBox(height: 16),
          if (selectedItem != null) // Si un ítem está seleccionado, muestra sus detalles.
            Column(
              children: [
                Image.network(
                  'http://localhost:3000/${selectedItem!['photo']}', // Muestra la imagen del ítem.
                  height: 200,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 16),
                Text(
                  selectedItem!['description'] ?? 'No Description', // Muestra la descripción del ítem.
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.deepPurple,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          if (selectedItem == null) // Si no hay un ítem seleccionado, muestra un mensaje.
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                'Select an item to view details', // Mensaje que pide seleccionar un ítem.
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Layout para pantallas de escritorio
  Widget buildDesktopLayout() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start, // Alinea el dropdown a la izquierda.
            children: [
              Flexible(
                child: Container(
                  child: DropdownMenu<String>(
                    width: MediaQuery.of(context).size.width * 0.39, // Ajusta el ancho del menú.
                    initialSelection: selectedCategory,
                    onSelected: (String? value) {
                      if (value != null) {
                        setState(() {
                          selectedCategory = value; // Actualiza la categoría seleccionada.
                          fetchItems(value); // Obtiene los ítems de la nueva categoría.
                        });
                      }
                    },
                    dropdownMenuEntries: categories
                        .map((category) => DropdownMenuEntry<String>( // Crea un menú desplegable con las categorías.
                              value: category,
                              label: category,
                            ))
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              // Lista de ítems
              Flexible(
                flex: 2,
                child: Container(
                  color: Colors.grey[200],
                  child: items.isEmpty
                      ? const Center(child: Text('No items found')) // Muestra mensaje si no hay ítems.
                      : ListView.separated(
                          itemCount: items.length, // Muestra la lista de ítems.
                          separatorBuilder: (context, index) {
                            return const Divider(color: Colors.grey); // Separa los ítems con una línea.
                          },
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return ListTile(
                              title: Text(item['name'] ?? 'Unknown Item'), // Muestra el nombre del ítem.
                              onTap: () => fetchItemDetails(item['id']), // Llama a la función para obtener detalles del ítem.
                            );
                          },
                        ),
                ),
              ),
              // Detalles del ítem seleccionado
              Flexible(
                flex: 3,
                child: selectedItem == null
                    ? const Center(
                        child: Text(
                          'Select an item to view details', // Mensaje que pide seleccionar un ítem.
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.network(
                                'http://localhost:3000/${selectedItem!['photo']}', // Muestra la imagen del ítem.
                                height: 256,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                selectedItem!['description'] ?? 'No Description', // Muestra la descripción del ítem.
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
