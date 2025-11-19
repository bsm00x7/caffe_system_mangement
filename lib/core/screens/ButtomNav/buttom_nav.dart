import 'package:flutter/material.dart';
import 'package:herfay/core/screens/stock/stock_screen.dart';
import 'package:herfay/core/screens/user_screen/users_page.dart';
import '../home/home_page.dart';
import '../stock/add_stock_screen.dart';

class BottomNavigationBarWidget extends StatefulWidget {
  const BottomNavigationBarWidget({super.key});

  @override
  State<BottomNavigationBarWidget> createState() =>
      _BottomNavigationBarWidgetState();
}

class _BottomNavigationBarWidgetState extends State<BottomNavigationBarWidget> {
  int _currentIndex = 0;

  final List<Widget> screens = [
    HomePage(),
    UsersPage(),
    StockScreen(),
    AddStockScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: .symmetric(horizontal: 12, vertical: 30),
        child: screens[_currentIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: true,
        selectedItemColor: Colors.black,
        selectedLabelStyle: TextStyle(
          fontFamily: 'Roboto',
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        elevation: 0,
        unselectedIconTheme: IconThemeData(color: Colors.black),
        selectedIconTheme: IconThemeData(color: Colors.blue, size: 30),
        currentIndex: _currentIndex,
        onTap: (value) {
          setState(() {
            _currentIndex = value;
          });
        },

        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Users'),
          BottomNavigationBarItem(icon: Icon(Icons.storage), label: 'Stock'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'add Stock'),
        ],
      ),
    );
  }
}
