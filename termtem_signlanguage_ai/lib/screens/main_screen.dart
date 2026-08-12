import 'package:flutter/material.dart';
// ignore: unused_import — HoverAvatar will be wired in Phase 6 shell refactor
import '../shared/widgets/hover_avatar.dart';
import 'translate_screen.dart';
import '../features/chat/chat_screen.dart';
import 'education_screen.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import 'setting_screen.dart';
import 'home_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Mock auth state — true = logged in
  bool _isLoggedIn = false;
  String _userName = 'Alex Johnson';
  String _userEmail = 'alex@example.com';

  final List<Widget> _screens = [
    const HomeScreen(),
    const TranslateScreen(),
    const ChatScreen(),
    const EducationScreen(),
  ];

  // ── Avatar button handler ──────────────────────────────────────────────────
  void _onAvatarTap(BuildContext ctx) {
    if (!_isLoggedIn) {
    Navigator.of(ctx).push(
      MaterialPageRoute(
        builder: (_) => const LoginScreen(), // ✅ ไม่มี onLoginSuccess
      ),
    ).then((_) {
      // หลัง pop กลับมา ถ้าอยากให้ login state อัพเดท
      // ให้เพิ่ม logic ตรงนี้ในภายหลังเมื่อทำ auth จริง
    });
      return;
    }

    // Logged in → show popup menu anchored to avatar
    final RenderBox button = ctx.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(ctx).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(
            button.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu<void>(
      context: ctx,
      position: position,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      items: <PopupMenuEntry<void>>[
        // User info header (non-tappable)
        PopupMenuItem<void>(
          enabled: false,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.black,
              child: Text(
                _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            ),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_userName,
                  style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
              Text(_userEmail,
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ]),
          ]),
        ),

        const PopupMenuDivider(),

        // Profile
        PopupMenuItem(
          onTap: () => Future.microtask(() => Navigator.of(ctx).push(
                MaterialPageRoute(
                  builder: (_) => ProfileScreen(
                      userName: _userName, userEmail: _userEmail),
                ),
              )),
          child: Row(children: const [
            Icon(Icons.person_outline, size: 20),
            SizedBox(width: 12),
            Text('Profile'),
          ]),
        ),

        // Settings
        PopupMenuItem(
          onTap: () => Future.microtask(() => Navigator.of(ctx).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              )),
          child: Row(children: const [
            Icon(Icons.settings_outlined, size: 20),
            SizedBox(width: 12),
            Text('Settings'),
          ]),
        ),

        const PopupMenuDivider(),

        // Logout
        PopupMenuItem(
          onTap: () => Future.microtask(() => _confirmLogout(ctx)),
          child: Row(children: const [
            Icon(Icons.logout, size: 20, color: Colors.red),
            SizedBox(width: 12),
            Text('Log out', style: TextStyle(color: Colors.red)),
          ]),
        ),
      ],
    );
  }

  // ── Logout confirmation dialog ─────────────────────────────────────────────
  void _confirmLogout(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Log out?',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() => _isLoggedIn = false);
            },
            child: const Text('Log out',
                style: TextStyle(
                    color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

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

// HoverAvatar → see lib/shared/widgets/hover_avatar.dart