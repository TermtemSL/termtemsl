import 'package:flutter/material.dart';
import 'translate_screen.dart';
import 'chat_screen.dart';
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Termtem',
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w900,
              letterSpacing: -1),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Builder(
              builder: (btnCtx) => _HoverAvatar(
                isLoggedIn: _isLoggedIn,
                initial: _isLoggedIn && _userName.isNotEmpty
                    ? _userName[0].toUpperCase()
                    : null,
                onTap: () => _onAvatarTap(btnCtx),
              ),
            ),
          ),
        ],
      ),
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
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.interpreter_mode), label: 'Translate'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.forum), label: 'Chat'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.school), label: 'Education'),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Hover avatar button ────────────────────────────────────────────────────────
class _HoverAvatar extends StatefulWidget {
  final bool isLoggedIn;
  final String? initial;
  final VoidCallback onTap;

  const _HoverAvatar({
    required this.isLoggedIn,
    required this.onTap,
    this.initial,
  });

  @override
  State<_HoverAvatar> createState() => _HoverAvatarState();
}

class _HoverAvatarState extends State<_HoverAvatar> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final active = _hovered || _pressed;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: widget.isLoggedIn
                ? (active ? Colors.grey[800]! : Colors.black)
                : (active ? Colors.grey[300]! : Colors.grey[200]!),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: widget.isLoggedIn && widget.initial != null
                ? Text(
                    widget.initial!,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  )
                : Icon(Icons.person,
                    color: active ? Colors.black : Colors.black54, size: 20),
          ),
        ),
      ),
    );
  }
}