import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: null,
          actions: null,
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProgressCard(),
                const SizedBox(height: 24),
                _buildWordOfDay(),
                const SizedBox(height: 32),
                _buildRecentChats(),
                const SizedBox(height: 32),
                const Text('Recommended Modules', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildModuleCard('Translation Dynamics', '12 Lessons • 45m', Icons.interpreter_mode),
                _buildModuleCard('Formal Etiquette', '8 Lessons • 30m', Icons.school),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('DAILY GOAL', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
          const Text('85% Complete', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          LinearProgressIndicator(value: 0.85, backgroundColor: Colors.grey[200], color: Colors.black, minHeight: 8, borderRadius: BorderRadius.circular(10)),
          const SizedBox(height: 12),
          const Text('Keep going! You\'re 15 minutes away from your target.', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildWordOfDay() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(30)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('WORD OF THE DAY', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
              const Icon(Icons.volume_up, color: Colors.white, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Serendipity', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          const Text('The occurrence and development of events by chance in a happy or beneficial way.', style: TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 20),
          TextButton(onPressed: () {}, child: const Text('LEARN USAGE →', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildRecentChats() {
     return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Recent Chats', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            TextButton(onPressed: () {}, child: const Text('View All', style: TextStyle(color: Colors.grey))),
          ],
        ),
        const SizedBox(height: 12),
        _buildChatTile('AI Language Mentor', 'Excellent usage of the...', '2m ago'),
        _buildChatTile('Sarah Jenkins', 'Did you see the new grammar...', '1h ago'),
      ],
    );
  }

  Widget _buildChatTile(String name, String msg, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: Colors.grey[100], child: const Icon(Icons.person, color: Colors.black)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(msg, style: const TextStyle(color: Colors.grey, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
            ]),
          ),
          Text(time, style: const TextStyle(color: Colors.grey, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildModuleCard(String title, String subtitle, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
      child: Row(
        children: [
          Icon(icon, size: 30),
          const SizedBox(width: 20),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ]),
        ],
      ),
    );
  }
}