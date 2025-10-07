import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:railtime/styles/themes.dart';
import 'package:railtime/view_model/live_info_view_model.dart';
import 'package:railtime/views/screens/live_info_page.dart';
import 'package:railtime/views/widgets/bottom_nav_bar.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final List<Widget> _pages = [
    ChangeNotifierProvider(
      create: (_) => LiveInfoViewModel(),
      child: Builder(builder: (context) => LiveInfoPage()),
    ),
    Placeholder(),
    Placeholder(),
    Placeholder(),
  ];

  int _currentPageIndex = 0;

  void _onBottomNavBarTap(int index) {
    setState(() {
      _currentPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: lightTheme,
      home: Scaffold(
        body: _pages.elementAt(_currentPageIndex),
        bottomNavigationBar: BottomNavBar(
          currentIndex: _currentPageIndex,
          onTap: _onBottomNavBarTap,
        ),
      ),
    );
  }
}
