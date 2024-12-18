import 'package:db_tematica/views/category_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      home: HomeView(),
      debugShowCheckedModeBanner: false,
    );
  }
}

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