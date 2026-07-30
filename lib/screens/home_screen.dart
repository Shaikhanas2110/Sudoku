import 'package:flutter/material.dart';
import '../state/profile_state.dart';
import '../theme/app_theme.dart';
import '../utils/formatting.dart';
import '../widgets/new_game_sheet.dart';
import '../widgets/home/daily_challenge_banner.dart';
import '../widgets/home/promo_card.dart';
import '../widgets/home/stat_badge.dart';
import 'game_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  Future<void> _startNewGame(BuildContext context) async {
    final chosen = await showNewGameSheet(context);
    if (chosen == null || !context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GameScreen(
          difficulty: chosen.difficulty,
          boardSize: chosen.boardSize,
        ),
      ),
    );
    // Score/coins/unlocks are reported into ProfileState directly by
    // GameScreen, and the AnimatedBuilder below already listens for that,
    // so nothing else needs to happen here.
  }

  void _notImplemented(BuildContext context, String what) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$what coming soon'), duration: const Duration(seconds: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = ProfileScope.of(context);
    final now = DateTime.now();
    final dateLabel = '${_months[now.month - 1]} ${now.day}';

    return AnimatedBuilder(
      animation: profile,
      builder: (context, _) {
        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    ),
                    icon: const Icon(Icons.settings_outlined),
                    tooltip: 'Settings',
                  ),
                  Row(
                    children: [
                      StatBadge(
                        icon: Icons.stars_rounded,
                        iconColor: AppColors.gold,
                        value: '${profile.coins}',
                      ),
                      const SizedBox(width: 10),
                      StatBadge(
                        icon: Icons.local_fire_department_rounded,
                        iconColor: AppColors.flame,
                        value: '${profile.streak}',
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 210,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  children: [
                    PromoCard(
                      kicker: 'Tournament',
                      seasonTag: 'S81',
                      title: 'Bronze',
                      timeLeft: '5d 2h',
                      centerIcon: Icons.change_history_rounded,
                      gradient: const [
                        AppColors.cardTeal,
                        AppColors.cardTealDark,
                      ],
                      footerTag: 'Promotion',
                      onStart: () => _notImplemented(context, 'Tournament'),
                    ),
                    PromoCard(
                      kicker: 'Event',
                      seasonTag: 'S1',
                      title: 'Abyss\nChallenge',
                      timeLeft: '1d 2h',
                      centerIcon: Icons.local_fire_department_rounded,
                      gradient: const [
                        AppColors.cardPurple,
                        AppColors.cardPurpleDark,
                      ],
                      onStart: () => _notImplemented(context, 'Abyss Challenge'),
                    ),
                    PromoCard(
                      kicker: 'Event',
                      seasonTag: 'S1',
                      title: 'Equinox',
                      timeLeft: '3d 6h',
                      centerIcon: Icons.eco_rounded,
                      gradient: const [
                        AppColors.cardGreen,
                        AppColors.cardGreenDark,
                      ],
                      onStart: () => _notImplemented(context, 'Equinox'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              DailyChallengeBanner(
                dateLabel: dateLabel,
                onTap: () => _notImplemented(context, 'Daily Challenge'),
              ),
              const SizedBox(height: 40),
              const Center(
                child: Text(
                  'Classic Sudoku',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(height: 18),
              Center(
                child: Text(
                  'BEST SCORE',
                  style: TextStyle(
                    color: AppColors.gold,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.eco, color: AppColors.gold, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      formatNumber(profile.bestScore),
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.gold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Transform.flip(
                      flipX: true,
                      child:
                          const Icon(Icons.eco, color: AppColors.gold, size: 20),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Center(
                child: OutlinedButton.icon(
                  onPressed: () => _showHowToPlay(context),
                  icon: const Icon(Icons.help_outline, size: 18),
                  label: const Text('How to Play'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textDark,
                    side: BorderSide(color: Colors.grey.shade300),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () => _startNewGame(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'New Game',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showHowToPlay(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('How to Play'),
        content: const Text(
          'Fill every row, column, and 3x3 box with the digits 1-9, each '
          'appearing exactly once.\n\nTap a cell then a number to fill it. '
          'Turn on Pencil to jot down candidate notes instead, or use Fast '
          'Pencil to auto-fill every possible candidate for the whole board '
          'in one tap.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

}