import 'package:flutter/material.dart';
import 'package:poc_label/pages/login_page.dart';
import '../pages/settings_page.dart';

enum ItemMenu { config, logout }

class MenuWidget extends StatelessWidget {
  const MenuWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<ItemMenu>(
      onSelected: (value) {
        if (value == ItemMenu.config) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const SettingsPage(),
            ),
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => LoginPage()),
          );
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<ItemMenu>>[
        const PopupMenuItem<ItemMenu>(
          value: ItemMenu.config,
          child: Text('Configurações'),
        ),
        const PopupMenuItem<ItemMenu>(
          value: ItemMenu.logout,
          child: Text('Sair'),
        ),
      ],
    );
  }
}
