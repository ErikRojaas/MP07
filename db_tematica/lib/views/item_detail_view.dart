import 'package:flutter/cupertino.dart';

class ItemDetailView extends StatelessWidget {
  final String name;

  const ItemDetailView({required this.name, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/$name.png', width: 200, height: 200),  // Aumentar el tamaño de la imagen
        SizedBox(height: 16),
        Text(
          'Descripción de $name',  // Aquí puedes poner una descripción del ítem
          style: TextStyle(fontSize: 18),
        ),
      ],
    );
  }
}
