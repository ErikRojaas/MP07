import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'item_list_view.dart';

class HomeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          return ItemListView();  // Vista para escritorio
        } else {
          return ItemListView();  // Vista para móvil
        }
      },
    );
  }
}
