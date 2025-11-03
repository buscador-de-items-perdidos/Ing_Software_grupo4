import 'package:flutter/material.dart';
import 'package:ing_software_grupo4/menu_reportes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      home: const MenuReportes(),
      debugShowCheckedModeBanner: false,
    );
  }
}


