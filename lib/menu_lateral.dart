import 'package:flutter/material.dart';
import 'package:ing_software_grupo4/handlers/session_handler.dart';
import 'package:ing_software_grupo4/cambio_contactos.dart';
import 'package:ing_software_grupo4/menu_reportes.dart';
import 'package:ing_software_grupo4/menu_pendientes.dart';

class MenuLateral extends StatelessWidget {
  const MenuLateral({super.key, required this.navKey});

  final GlobalKey<NavigatorState> navKey;

  @override
  Widget build(BuildContext context) {
    final appBarHeight = AppBar().preferredSize.height;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final totalHeaderHeight = appBarHeight + statusBarHeight;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            height: totalHeaderHeight,
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(top: statusBarHeight),
              child: Text(
                'Objetos Perdidos',
                style: TextStyle(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Inicio'),
            onTap: () {
              navKey.currentState?.pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const MenuReportes()),
                (route) => false,
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text('Reportes'),
            onTap: () {
              navKey.currentState?.push(
                MaterialPageRoute(builder: (_) => const MenuReportes()),
              );
            },
          ),
          if (SessionHandler.isAdmin)
            ListTile(
              leading: const Icon(Icons.pending_actions),
              title: const Text('Pendientes'),
              onTap: () {
                navKey.currentState?.push(
                  MaterialPageRoute(builder: (_) => const MenuPendientes()),
                );
              },
            ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Mi Perfil'),
            onTap: () {
              navKey.currentState!.push(
                MaterialPageRoute(builder: (_) => const CambioContactos()),
              );
            },
          ),
        ],
      ),
    );
  }
}
