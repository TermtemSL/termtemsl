import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../screens/profile_screen.dart';
import '../../services/auth_scope.dart';

/// The global app header shown at the top of every main screen.
///
/// Displays the Termtem brand logo and an avatar/profile button.
/// The [onProfileTap] callback lets each screen handle profile navigation;
/// if omitted the header pushes a default [ProfileScreen].
///
class TermtemHeader extends StatelessWidget {
  final VoidCallback? onProfileTap;

  /// When true, a subtle shadow is rendered beneath the header.
  final bool showShadow;

  const TermtemHeader({
    super.key,
    this.onProfileTap,
    this.showShadow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
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
                backgroundColor: AppColors.primaryLight,
                child: Icon(Icons.pets, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              const Text(
                'Termtem',
                style: TextStyle(
                  color: AppColors.primary,
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
                          builder: (_) => ProfileScreen(
                            userName: AuthScope.of(context).user?.userMetadata?['full_name'] as String? ?? 'Member',
                            userEmail: AuthScope.of(context).user?.email ?? '',
                          ),
                        ),
                      );
                    },
                icon: const Icon(
                  Icons.account_circle_outlined,
                  color: AppColors.primary,
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
