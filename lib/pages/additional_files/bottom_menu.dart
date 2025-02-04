import 'package:flutter/material.dart';
import 'color.dart';

class BottomMenu extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onItemSelected;
  final bool isDarkMode;

  const BottomMenu({
    Key? key,
    required this.currentIndex,
    required this.onItemSelected,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: isDarkMode ? Colors.black : bodyBackground,
      currentIndex: currentIndex,
      selectedItemColor: isDarkMode ? Colors.white : headerBackground,
      unselectedItemColor: isDarkMode ? Colors.grey[800] : menuUnselected,
      onTap: onItemSelected,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Main Page',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.category),
          label: 'Category',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );
  }
}
