import 'package:flutter/material.dart';
import 'package:ing_software_grupo4/handlers/session_handler.dart';
import 'package:ing_software_grupo4/login_screen.dart';

class MenuLateral extends StatelessWidget {
  final Function(int) select;

  const MenuLateral({super.key, required this.select});

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
            onTap: () => select(0),
          ),
          if (SessionHandler.isAdmin)
            ListTile(
              leading: const Icon(Icons.pending_actions),
              title: const Text('Pendientes'),
              onTap: () => select(1),
            ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Mi Perfil'),
            onTap: () => select(2),
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text('Mis Reportes'),
            onTap: () => select(3),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Cerrar Sesión'),
            onTap: () {
              SessionHandler.logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
