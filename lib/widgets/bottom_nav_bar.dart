import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../providers/language_provider.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final UserRole userRole;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.userRole,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    
    List<BottomNavigationBarItem> items;
    
    if (userRole == UserRole.wasteProvider) {
      items = [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home),
          label: languageProvider.translate('Home'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.school),
          label: languageProvider.translate('Training'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.camera_alt),
          label: languageProvider.translate('Report'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.location_on),
          label: languageProvider.translate('Facilities'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person),
          label: languageProvider.translate('Profile'),
        ),
      ];
    } else {
      items = [
        BottomNavigationBarItem(
          icon: const Icon(Icons.dashboard),
          label: languageProvider.translate('Dashboard'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.assignment),
          label: languageProvider.translate('Reports'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.map),
          label: languageProvider.translate('Map'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person),
          label: languageProvider.translate('Profile'),
        ),
      ];
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.bottomNavigationBarTheme.backgroundColor ?? theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: theme.bottomNavigationBarTheme.backgroundColor ?? theme.cardColor,
        selectedItemColor: theme.primaryColor,
        unselectedItemColor: theme.iconTheme.color?.withOpacity(0.6),
        selectedFontSize: 12,
        unselectedFontSize: 12,
        elevation: 0,
        items: items,
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          color: theme.primaryColor,
        ),
        unselectedLabelStyle: TextStyle(
          color: theme.iconTheme.color?.withOpacity(0.6),
        ),
      ),
    );
  }
}