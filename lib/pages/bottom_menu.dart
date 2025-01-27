import 'package:flutter/material.dart';

class BottomMenu extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onItemSelected;

  const BottomMenu({
    Key? key,
    required this.currentIndex,
    required this.onItemSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onItemSelected,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Main Page',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.note_add),
          label: 'Add note',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );
  }
}
