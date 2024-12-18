import 'package:flutter/cupertino.dart';

class ItemDetailView extends StatelessWidget {
  final String name;

  const ItemDetailView({required this.name, super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(name),
        automaticallyImplyLeading: true,  // Este agrega el botón de retroceso automáticamente
      ),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/$name.png'),  // Aquí se espera una imagen con el nombre del item
              Text(
                'Description for $name', // Aquí puedes poner una descripción del item
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
