import 'package:flutter/material.dart';
import 'package:ing_software_grupo4/menu_reportes.dart';
import 'package:ing_software_grupo4/appbar.dart';

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
      builder: (context, child) {
        return Scaffold(appBar: appbar(context), body: child);
      },
      home: const MenuReportes(),
      debugShowCheckedModeBanner: false,
    );
  }
}
