import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({super.key, required this.child});

  final Widget child;

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/focus')) return 1;
    if (location.startsWith('/reflect')) return 2;
    if (location.startsWith('/settings')) return 3;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/prayer');
      case 1:
        context.go('/focus');
      case 2:
        context.go('/reflect');
      case 3:
        context.go('/settings');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentIndex = _currentIndex(context);

    return Scaffold(
      extendBody: true,
      body: child,
      bottomNavigationBar: _SacredBottomNav(
        currentIndex: currentIndex,
        isDark: isDark,
        onTap: (i) => _onTap(context, i),
      ),
    );
  }
}

class _SacredBottomNav extends StatelessWidget {
  const _SacredBottomNav({
    required this.currentIndex,
    required this.isDark,
    required this.onTap,
  });

  final int currentIndex;
  final bool isDark;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor =
        isDark ? AppColors.dividerDark : AppColors.dividerLight;

    final items = [
      _NavItem(
          icon: Icons.access_time_outlined,
          activeIcon: Icons.access_time,
          label: 'PRAYERS'),
      _NavItem(
          icon: Icons.explore_outlined,
          activeIcon: Icons.explore,
          label: 'FOCUS'),
      _NavItem(
          icon: Icons.auto_stories_outlined,
          activeIcon: Icons.auto_stories,
          label: 'REFLECT'),
      _NavItem(
          icon: Icons.tune_outlined,
          activeIcon: Icons.tune,
          label: 'SETTINGS'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          top: BorderSide(color: borderColor, width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 68,
          child: Row(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isActive = index == currentIndex;
              final activeColor =
                  isDark ? AppColors.primaryLight : AppColors.primary;
              final inactiveColor = isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight;

              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(index),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        decoration: isActive
                            ? BoxDecoration(
                                color: activeColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                              )
                            : null,
                        child: Icon(
                          isActive ? item.activeIcon : item.icon,
                          size: 22,
                          color: isActive ? activeColor : inactiveColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.label,
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                          color: isActive ? activeColor : inactiveColor,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
  final IconData icon;
  final IconData activeIcon;
  final String label;
}
