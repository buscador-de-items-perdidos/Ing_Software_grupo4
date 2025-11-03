import 'package:flutter/material.dart';
import 'package:ing_software_grupo4/handlers/session_handler.dart';

AppBar appbar(BuildContext context) {
  return AppBar(
    title: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Brr Brr Patapim",
          style: TextStyle(
            color: Theme.of(context).scaffoldBackgroundColor,
            fontWeight: FontWeight.w900,
          ),
        ),
        !SessionHandler.isAdmin ? SizedBox.shrink() :SizedBox.shrink(),
        BotonPublicar(),
      ],
    ),
    backgroundColor: Theme.of(context).primaryColor,
  );
}

class BotonPublicar extends StatelessWidget {
  const BotonPublicar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty<Color>.fromMap(
          <WidgetStatesConstraint, Color>{
            WidgetState.any: Theme.of(context).scaffoldBackgroundColor,
          },
        ),
      ),
      onPressed: () {},
      child: Row(
        children: [
          Icon(Icons.add, color: Theme.of(context).primaryColor),
          Text(
            "Publicar",
            style: TextStyle(color: Theme.of(context).primaryColor),
          ),
        ],
      ),
    );
  }
}
