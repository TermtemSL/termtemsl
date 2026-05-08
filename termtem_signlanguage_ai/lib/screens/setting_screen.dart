import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = true;
  bool _darkMode = false;
  bool _soundEffects = true;
  String _language = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Settings',
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _buildSectionLabel('Preferences'),
            _buildSwitchTile(
              icon: Icons.notifications_outlined,
              label: 'Notifications',
              value: _notifications,
              onChanged: (v) => setState(() => _notifications = v),
            ),
            _buildSwitchTile(
              icon: Icons.dark_mode_outlined,
              label: 'Dark mode',
              value: _darkMode,
              onChanged: (v) => setState(() => _darkMode = v),
            ),
            _buildSwitchTile(
              icon: Icons.volume_up_outlined,
              label: 'Sound effects',
              value: _soundEffects,
              onChanged: (v) => setState(() => _soundEffects = v),
            ),
            const SizedBox(height: 24),

            _buildSectionLabel('Language'),
            _buildSelectTile(
              icon: Icons.language,
              label: 'App language',
              value: _language,
              options: ['English', 'Thai', 'Japanese', 'Spanish'],
              onChanged: (v) => setState(() => _language = v),
            ),
            const SizedBox(height: 24),

            _buildSectionLabel('About'),
            _buildNavTile(Icons.info_outline, 'About Nong Termtem', () {}),
            _buildNavTile(Icons.privacy_tip_outlined, 'Privacy policy', () {}),
            _buildNavTile(Icons.description_outlined, 'Terms of service', () {}),
            const SizedBox(height: 24),

            // Version
            Center(
              child: Text('Version 1.0.0',
                  style: TextStyle(color: Colors.grey[400], fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(label,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                letterSpacing: 0.5)),
      );

  Widget _buildSwitchTile({
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        secondary: Icon(icon, color: Colors.black, size: 22),
        title: Text(label,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
        value: value,
        activeColor: Colors.black,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildSelectTile({
    required IconData icon,
    required String label,
    required String value,
    required List<String> options,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon, color: Colors.black, size: 22),
        title: Text(label,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
        trailing: DropdownButton<String>(
          value: value,
          underline: const SizedBox(),
          style: const TextStyle(color: Colors.black, fontSize: 14),
          items: options
              .map((o) => DropdownMenuItem(value: o, child: Text(o)))
              .toList(),
          onChanged: (v) { if (v != null) onChanged(v); },
        ),
      ),
    );
  }

  Widget _buildNavTile(IconData icon, String label, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: Icon(icon, color: Colors.black, size: 22),
        title: Text(label,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}