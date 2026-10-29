import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_card.dart';

/// Section showing the two most recent chat previews with a "View All" link.
///
/// The [_ChatTile] helper widget is kept inline because it is only used here
/// and pulling it out would add unnecessary complexity.
class RecentChatsList extends StatelessWidget {
  const RecentChatsList({super.key});

  @override
  Widget build(BuildContext context) {
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
                color: AppColors.textDark,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {},
              child: const Text(
                'View All',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _ChatTile(
          name: 'Kru Pim',
          message: "Excellent progress on the 'Family' module!",
          time: '10m',
          avatarColor: AppColors.secondaryLight,
        ),
        _ChatTile(
          name: 'Ananda',
          message: 'Wanna practice the greeting signs together?',
          time: '2h',
          avatarColor: AppColors.tertiaryLight,
        ),
      ],
    );
  }
}

/// A single chat preview row.
/// Kept inside [RecentChatsList] because it is not used outside this widget.
class _ChatTile extends StatelessWidget {
  final String name;
  final String message;
  final String time;
  final Color avatarColor;

  const _ChatTile({
    required this.name,
    required this.message,
    required this.time,
    required this.avatarColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      radius: 26,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: avatarColor,
            child: const Icon(Icons.person, color: AppColors.textDark),
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
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: const TextStyle(color: AppColors.textSoft, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(time, style: const TextStyle(color: AppColors.textSoft, fontSize: 11)),
        ],
      ),
    );
  }
}
