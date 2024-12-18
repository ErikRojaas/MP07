import 'package:flutter/cupertino.dart';
import 'item_list_view.dart';

class ViewMobile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Categorias'),
      ),
      child: SafeArea(
        child: ListView(
          children: [
            CategoryItem(title: 'Stadiums'),
            CategoryItem(title: 'Game Modes'),
            CategoryItem(title: 'Cars'),
          ],
        ),
      ),
    );
  }
}

class ViewDesktop extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Categorias'),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(child: CategoryItem(title: 'Stadiums')),
            Expanded(child: CategoryItem(title: 'Game Modes')),
            Expanded(child: CategoryItem(title: 'Cars')),
          ],
        ),
      ),
    );
  }
}

class CategoryItem extends StatelessWidget {
  final String title;

  const CategoryItem({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => ItemListView(category: title),
          ),
        );
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Si la pantalla es ancha (mayor a 600px), centrar el texto (escritorio)
          // Si la pantalla es estrecha (menos de 600px), alinearlo a la derecha (móvil)
          bool isMobile = constraints.maxWidth < 600;

          return Container(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            alignment: isMobile ? Alignment.centerRight : Alignment.center,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: isMobile ? TextAlign.right : TextAlign.center,
            ),
          );
        },
      ),
    );
  }
}
