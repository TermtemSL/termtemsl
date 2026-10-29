import 'package:flutter/material.dart';
import '../features/translate/translate_screen.dart';
import '../features/chat/chat_screen.dart';
import '../features/education/education_screen.dart';
import '../features/home/home_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const TranslateScreen(),
    const ChatScreen(),
    const EducationScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),

      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
            showSelectedLabels: true,
            showUnselectedLabels: true,
            selectedItemColor: Colors.black,
            unselectedItemColor: Colors.grey,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            items: [
              BottomNavigationBarItem(
                icon: Image.asset(
                  'assets/icons/home.png',
                  width: 30,
                  height: 30,
                ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  'assets/icons/translate.png',
                  width: 30,
                  height: 30,
                ),
                label: 'Translate',
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  'assets/icons/chatbot.png',
                  width: 30,
                  height: 30,
                ),
                label: 'Chat',
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  'assets/icons/education.png',
                  width: 30,
                  height: 30,
                ),
                label: 'Education',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
