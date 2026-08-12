import 'package:flutter/material.dart'; // Flutter Widgets package for building UI components
import '../shared/widgets/termtem_header.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key}); // Constructor for HomeScreen widget

  static const Color background = Color(0xFFF9F9FC);
  static const Color primary = Color(0xFF9B4500);
  static const Color primaryLight = Color(0xFFFFDBC9);
  static const Color secondaryLight = Color(0xFF8AF5B3);
  static const Color tertiaryLight = Color(0xFFC6E7FF);
  static const Color textDark = Color(0xFF1A1C1E);
  static const Color textSoft = Color(0xFF564338);

  @override // Replace the build method from StatelessWidget
  Widget build(BuildContext context) {
    return Column(
      // Arrang widgets vertically
      children: [
        const TermtemHeader(),
        Expanded(
          // Use the remmaining space in the parent widget
          child: CustomScrollView(
            //Makes the content scrollable
            slivers: [
              //home page content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWelcomeSection(),
                      const SizedBox(height: 16),
                      _buildProgressCard(),
                      const SizedBox(height: 16),
                      _buildTranslateCard(),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: _buildSmallActionCard(
                              icon: Icons.front_hand,
                              title: 'Practice\nSigns',
                              backgroundColor: secondaryLight,
                              iconColor: const Color(0xFF006D3F),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildSmallActionCard(
                              icon: Icons.smart_toy_outlined,
                              title: 'Ask AI\nMentor',
                              backgroundColor: tertiaryLight,
                              iconColor: const Color(0xFF00658D),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      _buildSignOfTheDay(),
                      const SizedBox(height: 28),
                      _buildRecentChats(),
                      const SizedBox(height: 28),

                      const Text(
                        'Recommended Modules',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: textDark,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildModuleCard(
                        'Translation Dynamics',
                        '12 Lessons • 45m',
                        Icons.interpreter_mode,
                      ),
                      _buildModuleCard(
                        'Formal Etiquette',
                        '8 Lessons • 30m',
                        Icons.school_outlined,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeSection() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sawatdee👋',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: textDark,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Ready to continue your sign journey?',
          style: TextStyle(fontSize: 15, color: textSoft),
        ),
      ],
    );
  }

  Widget _buildProgressCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'YOUR PROGRESS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: primary,
                        letterSpacing: 1,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Level 4',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: textDark,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: primaryLight,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.stars, size: 18, color: primary),
                    SizedBox(width: 4),
                    Text(
                      '1,240 XP',
                      style: TextStyle(
                        color: primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPathStep(
                icon: Icons.check,
                backgroundColor: secondaryLight,
                iconColor: const Color(0xFF006D3F),
                size: 42,
              ),
              _buildPathStep(
                icon: Icons.school,
                backgroundColor: primary,
                iconColor: Colors.white,
                size: 54,
              ),
              _buildPathStep(
                icon: Icons.lock_outline,
                backgroundColor: const Color(0xFFEEEFF0),
                iconColor: textSoft,
                size: 42,
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            children: const [
              Text(
                'Daily Goal: 85% reached',
                style: TextStyle(color: textSoft, fontSize: 13),
              ),
              Spacer(),
              Text(
                '150 XP left',
                style: TextStyle(
                  color: textSoft,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPathStep({
    required IconData icon,
    required Color backgroundColor,
    required Color iconColor,
    required double size,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, color: iconColor),
    );
  }

  Widget _buildTranslateCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.black,
            child: const Icon(
              Icons.video_library_outlined,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Translate Video',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: textDark,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Real-time sign recognition',
                  style: TextStyle(fontSize: 13, color: textSoft),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 18, color: textSoft),
        ],
      ),
    );
  }

  Widget _buildSmallActionCard({
    required IconData icon,
    required String title,
    required Color backgroundColor,
    required Color iconColor,
  }) {
    return Container(
      height: 160,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white,
            child: Icon(icon, color: iconColor, size: 30),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 19,
              height: 1.1,
              fontWeight: FontWeight.w900,
              color: textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignOfTheDay() {
    return Container(
      decoration: _cardDecoration(),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 170,
            width: double.infinity,
            color: const Color(0xFFEAF7FF),
            child: const Icon(
              Icons.front_hand,
              size: 90,
              color: Color(0xFF00658D),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: primaryLight,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'SIGN OF THE DAY',
                    style: TextStyle(
                      color: primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Khop Khun',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Thank You',
                  style: TextStyle(fontSize: 15, color: textSoft),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentChats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Recent Chats',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: textDark,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {},
              child: const Text(
                'View All',
                style: TextStyle(color: primary, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildChatTile(
          'Kru Pim',
          "Excellent progress on the 'Family' module!",
          '10m',
          secondaryLight,
        ),
        _buildChatTile(
          'Ananda',
          'Wanna practice the greeting signs together?',
          '2h',
          tertiaryLight,
        ),
      ],
    );
  }

  Widget _buildChatTile(
    String name,
    String message,
    String time,
    Color avatarColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(radius: 26),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: avatarColor,
            child: const Icon(Icons.person, color: textDark),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: const TextStyle(color: textSoft, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(time, style: const TextStyle(color: textSoft, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildModuleCard(String title, String subtitle, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(radius: 28),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: primaryLight,
            child: Icon(icon, color: primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(color: textSoft, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration({double radius = 32}) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: const [
        BoxShadow(
          color: Color(0x149B4500),
          blurRadius: 20,
          offset: Offset(0, 10),
        ),
      ],
    );
  }
}
