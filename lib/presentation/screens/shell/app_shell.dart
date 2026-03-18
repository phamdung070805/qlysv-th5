import 'package:flutter/material.dart';

import '../classrooms/class_list_screen.dart';
import '../profile/profile_screen.dart';
import '../settings/settings_screen.dart';
import '../students/student_list_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = [
    ClassListScreen(),
    StudentListScreen(),
    ProfileScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          const _ShellBackdrop(),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 420),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              final slide = Tween<Offset>(
                begin: const Offset(0.08, 0),
                end: Offset.zero,
              ).animate(animation);
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(position: slide, child: child),
              );
            },
            child: KeyedSubtree(
              key: ValueKey<int>(_selectedIndex),
              child: _pages[_selectedIndex],
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        elevation: 0,
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.school_outlined),
            selectedIcon: Icon(Icons.school, color: theme.colorScheme.primary),
            label: 'Lớp học',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups, color: theme.colorScheme.primary),
            label: 'Sinh viên',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: theme.colorScheme.primary),
            label: 'Cá nhân',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings, color: theme.colorScheme.primary),
            label: 'Cài đặt',
          ),
        ],
      ),
    );
  }
}

class _ShellBackdrop extends StatelessWidget {
  const _ShellBackdrop();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? const [Color(0xFF081117), Color(0xFF0D1B26)]
                : const [Color(0xFFE9F8FB), Color(0xFFF6F9FB)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -80,
              right: -50,
              child: _Blob(
                color: isDark
                    ? const Color(0xFF164E63).withValues(alpha: 0.42)
                    : const Color(0xFF67E8F9).withValues(alpha: 0.28),
                size: 220,
              ),
            ),
            Positioned(
              bottom: -90,
              left: -70,
              child: _Blob(
                color: isDark
                    ? const Color(0xFF0E7490).withValues(alpha: 0.34)
                    : const Color(0xFF0EA5E9).withValues(alpha: 0.2),
                size: 260,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size),
      ),
    );
  }
}
