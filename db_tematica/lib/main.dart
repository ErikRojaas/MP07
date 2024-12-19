import 'package:flutter/cupertino.dart';
import 'package:db_tematica/views/home_view.dart';

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
