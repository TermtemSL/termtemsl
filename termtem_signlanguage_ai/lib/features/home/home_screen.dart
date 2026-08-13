import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/termtem_header.dart';
import 'widgets/welcome_section.dart';
import 'widgets/progress_card.dart';
import 'widgets/translate_quick_card.dart';
import 'widgets/small_action_card.dart';
import 'widgets/sign_of_the_day.dart';
import 'widgets/recent_chats_list.dart';
import 'widgets/module_card.dart';

/// Home feature screen.
///
/// Acts as an orchestrator — it wires together all Home sub-widgets but
/// contains no business logic or inline widget-building itself.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const TermtemHeader(),
        Expanded(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const WelcomeSection(),
                      const SizedBox(height: 16),
                      const ProgressCard(),
                      const SizedBox(height: 16),
                      const TranslateQuickCard(),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: SmallActionCard(
                              icon: Icons.front_hand,
                              title: 'Practice\nSigns',
                              backgroundColor: AppColors.secondaryLight,
                              iconColor: AppColors.secondary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: SmallActionCard(
                              icon: Icons.smart_toy_outlined,
                              title: 'Ask AI\nMentor',
                              backgroundColor: AppColors.tertiaryLight,
                              iconColor: const Color(0xFF00658D),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      const SignOfTheDay(),
                      const SizedBox(height: 28),
                      const RecentChatsList(),
                      const SizedBox(height: 28),

                      const Text(
                        'Recommended Modules',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const ModuleCard(
                        title: 'Translation Dynamics',
                        subtitle: '12 Lessons • 45m',
                        icon: Icons.interpreter_mode,
                      ),
                      const SizedBox(height: 14),
                      const ModuleCard(
                        title: 'Formal Etiquette',
                        subtitle: '8 Lessons • 30m',
                        icon: Icons.school_outlined,
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
}
