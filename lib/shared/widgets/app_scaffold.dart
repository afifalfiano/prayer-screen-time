import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({super.key, required this.child});

  final Widget child;

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/qibla')) return 1;
    if (location.startsWith('/blocking')) return 2;
    if (location.startsWith('/settings')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex(context),
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/prayer');
            case 1:
              context.go('/qibla');
            case 2:
              context.go('/blocking');
            case 3:
              context.go('/settings');
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time),
            label: 'Prayer',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Qibla',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.block),
            label: 'Blocked',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
