import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'item_detail_view.dart';

class ItemListView extends StatelessWidget {
  final String category;

  const ItemListView({required this.category, super.key});

  @override
  Widget build(BuildContext context) {
    // Simulamos datos para cada categoría con 8 elementos
    List<String> items;
    if (category == 'Stadiums') {
      items = ['Stadium1', 'Stadium2', 'Stadium3', 'Stadium4', 'Stadium5', 'Stadium6', 'Stadium7', 'Stadium8'];
    } else if (category == 'Game Modes') {
      items = ['Mode1', 'Mode2', 'Mode3', 'Mode4', 'Mode5', 'Mode6', 'Mode7', 'Mode8'];
    } else {
      items = ['Car1', 'Car2', 'Car3', 'Car4', 'Car5', 'Car6', 'Car7', 'Car8'];
    }

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(category),
        automaticallyImplyLeading: true,  // Botón de retroceso
      ),
      child: SafeArea(
        child: ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            return Column(
              children: [
                ItemListItem(name: items[index]),
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
    );
  }
}

class ItemListItem extends StatelessWidget {
  final String name;

  const ItemListItem({required this.name, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => ItemDetailView(name: name),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),  // Reducir padding vertical
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // El texto tiene más espacio entre el nombre y la imagen
            Expanded(
              child: Text(
                name,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(width: 12),  // Añadir un espacio entre el texto y la imagen
            // La imagen mantiene el tamaño original
            Image.asset(
              'assets/$name.png',  // Asegúrate de tener imágenes con los nombres de los items
              width: 120,  // Mantener el tamaño de la imagen
              height: 120, // Reducción en la altura para que no sea tan grande
            ),
          ],
        ),
      ),
    );
  }
}
