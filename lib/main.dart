import 'package:flutter/material.dart';
import 'package:ing_software_grupo4/menu_reportes.dart';
import 'package:ing_software_grupo4/appbar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      builder: (context, child) {
        return Scaffold(appBar: appbar(context, navigatorKey), body: child);
      },
      home: const MenuReportes(),
      debugShowCheckedModeBanner: false,
    );
  }
}
