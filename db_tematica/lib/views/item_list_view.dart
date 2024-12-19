import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'item_detail_view.dart';

class ItemListView extends StatefulWidget {
  const ItemListView({super.key});

  @override
  _ItemListViewState createState() => _ItemListViewState();
}

class _ItemListViewState extends State<ItemListView> {
  String selectedCategory = 'Stadiums';
  String? selectedItem;

  List<String> getItems(String category) {
    if (category == 'Stadiums') {
      return ['Stadium1', 'Stadium2', 'Stadium3', 'Stadium4', 'Stadium5', 'Stadium6', 'Stadium7', 'Stadium8'];
    } else if (category == 'Game Modes') {
      return ['Mode1', 'Mode2', 'Mode3', 'Mode4', 'Mode5', 'Mode6', 'Mode7', 'Mode8'];
    } else {
      return ['Car1', 'Car2', 'Car3', 'Car4', 'Car5', 'Car6', 'Car7', 'Car8'];
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> items = getItems(selectedCategory);

    return CupertinoPageScaffold(

      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Si el ancho es mayor que 600, mostramos la vista para Desktop
            if (constraints.maxWidth > 600) {
              return ViewDesktop(
                selectedCategory: selectedCategory,
                items: items,
                onCategoryChanged: (category) {
                  setState(() {
                    selectedCategory = category;
                    selectedItem = null; // Resetear la selección de ítem
                  });
                },
                onItemSelected: (item) {
                  setState(() {
                    selectedItem = item;
                  });
                },
                selectedItem: selectedItem,
              );
            } else {
              // Si el ancho es menor o igual a 600, mostramos la vista para Mobile
              return ViewMobile(
                selectedCategory: selectedCategory,
                items: items,
                onCategoryChanged: (category) {
                  setState(() {
                    selectedCategory = category;
                    selectedItem = null; // Resetear la selección de ítem
                  });
                },
                onItemSelected: (item) {
                  setState(() {
                    selectedItem = item;
                  });
                },
                selectedItem: selectedItem,
              );
            }
          },
        ),
      ),
    );
  }
}

class ViewDesktop extends StatelessWidget {
  final String selectedCategory;
  final List<String> items;
  final Function(String) onCategoryChanged;
  final Function(String) onItemSelected;
  final String? selectedItem;

  const ViewDesktop({
    required this.selectedCategory,
    required this.items,
    required this.onCategoryChanged,
    required this.onItemSelected,
    required this.selectedItem,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Lista de ítems a la izquierda
        Container(
          width: MediaQuery.of(context).size.width * 0.3, // 30% del ancho de la pantalla
          padding: EdgeInsets.all(8),
          child: Column(
            children: [
              // Dropdown para seleccionar la categoría
              CupertinoPicker(
                itemExtent: 32.0,
                onSelectedItemChanged: (index) {
                  onCategoryChanged(['Stadiums', 'Game Modes', 'Cars'][index]);
                },
                children: const [
                  Text('Stadiums'),
                  Text('Game Modes'),
                  Text('Cars'),
                ],
              ),
              // Lista de ítems
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        ItemListItem(
                          name: items[index],
                          onTap: () {
                            onItemSelected(items[index]); // Actualiza el ítem seleccionado
                          },
                        ),
                        if (index < items.length - 1)
                          const Divider(
                            height: 1,
                            thickness: 1,
                            color: CupertinoColors.separator,
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // Vista de detalle a la derecha
        Container(
          width: MediaQuery.of(context).size.width * 0.7, // 70% del ancho de la pantalla
          padding: EdgeInsets.all(16),
          child: selectedItem == null
              ? Center(child: Text('Selecciona un ítem'))
              : ItemDetailView(name: selectedItem!),
        ),
      ],
    );
  }
}

class ViewMobile extends StatelessWidget {
  final String selectedCategory;
  final List<String> items;
  final Function(String) onCategoryChanged;
  final Function(String) onItemSelected;
  final String? selectedItem;

  const ViewMobile({
    required this.selectedCategory,
    required this.items,
    required this.onCategoryChanged,
    required this.onItemSelected,
    required this.selectedItem,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Dropdown para seleccionar la categoría
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: CupertinoPicker(
            itemExtent: 32.0,
            onSelectedItemChanged: (index) {
              onCategoryChanged(['Stadiums', 'Game Modes', 'Cars'][index]);
            },
            children: const [
              Text('Stadiums'),
              Text('Game Modes'),
              Text('Cars'),
            ],
          ),
        ),
        // Lista de ítems a la izquierda
        Expanded(
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  ItemListItem(
                    name: items[index],
                    onTap: () {
                      onItemSelected(items[index]); // Actualiza el ítem seleccionado
                    },
                  ),
                  if (index < items.length - 1)
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: CupertinoColors.separator,
                    ),
                ],
              );
            },
          ),
        ),

        // Vista de detalle a la derecha
        Container(
          width: MediaQuery.of(context).size.width * 0.7, // 70% del ancho de la pantalla
          padding: EdgeInsets.all(16),
          child: selectedItem == null
              ? Center(child: Text('Selecciona un ítem'))
              : ItemDetailView(name: selectedItem!),
        ),
      ],
    );
  }
}

class ItemListItem extends StatelessWidget {
  final String name;
  final VoidCallback onTap;

  const ItemListItem({required this.name, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Solo el nombre del ítem
            Expanded(
              child: Text(
                name,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
