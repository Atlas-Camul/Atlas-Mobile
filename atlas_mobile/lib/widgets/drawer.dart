import 'package:flutter/material.dart';
import 'package:atlas_mobile/map_page.dart';


Widget _buildMenuItem(
    BuildContext context, Widget title, String routeName, String currentRoute) {
  final isSelected = routeName == currentRoute;

  return ListTile(
    title: title,
    selected: isSelected,
    onTap: () {
      if (isSelected) {
        Navigator.pop(context);
      } else {
        Navigator.pushReplacementNamed(context, routeName);
      }
    },
  );
}

Drawer buildDrawer(BuildContext context, String currentRoute) {
  return Drawer(
    child: ListView(
      children: <Widget>[
        DrawerHeader(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/ProjectIcon.png',
                height: 48,
              ),
              const SizedBox(height: 16),
              const Text(
                'flutter_map Demo',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text(
                '© flutter_map Authors & Contributors',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
        _buildMenuItem(
          context,
          const Text('Polylines'),
          MapPage.route,
          currentRoute,
        ),
      ],
    ),
  );
}
