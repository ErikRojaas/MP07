import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'category_view.dart';

class HomeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          return ViewDesktop();  // Vista para escritorio
        } else {
          return ViewMobile();  // Vista para móvil
        }
      },
    );
  }
}
