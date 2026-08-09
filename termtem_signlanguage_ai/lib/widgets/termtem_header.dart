import 'package:flutter/material.dart';
import '../screens/profile_screen.dart';

class TermtemHeader extends StatelessWidget {
  final VoidCallback? onProfileTap;
  final bool showShadow;

  const TermtemHeader({
    super.key,
    this.onProfileTap,
    this.showShadow = false,
  });

  static const Color primary = Color(0xFF9B4500);
  static const Color primaryLight = Color(0xFFFFDBC9);
  static const Color background = Color(0xFFF9F9FC);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: background,
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundColor: primaryLight,
                child: Icon(Icons.pets, color: primary, size: 22),
              ),
              const SizedBox(width: 12),
              const Text(
                'Termtem',
                style: TextStyle(
                  color: primary,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: onProfileTap ??
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ProfileScreen(
                            userName: 'Alex Johnson',
                            userEmail: 'alex@example.com',
                          ),
                        ),
                      );
                    },
                icon: const Icon(
                  Icons.account_circle_outlined,
                  color: primary,
                  size: 30,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
