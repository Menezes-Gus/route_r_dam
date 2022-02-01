import 'package:flutter/material.dart';
import 'package:route_r_dam/pages/homepage.dart';

void main() {
  runApp(RouteRDam());
}

class RouteRDam extends StatelessWidget {
  const RouteRDam({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.teal,
        fontFamily: 'Montserrat',
      ),
      home: const HomePage(),
    );
  }
}
