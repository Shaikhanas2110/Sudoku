import 'package:flutter/material.dart';

import '../state/profile_state.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = ProfileScope.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Settings')),
      body: AnimatedBuilder(
        animation: profile,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 12),
            children: [
              _sectionLabel('Gameplay'),
              _switchTile(
                icon: Icons.volume_up_outlined,
                title: 'Sound Effects',
                subtitle: 'Play a sound on taps and wins',
                value: profile.soundEnabled,
                onChanged: (v) => profile.updateSettings(soundEnabled: v),
              ),
              _switchTile(
                icon: Icons.vibration_rounded,
                title: 'Vibration',
                subtitle: 'Haptic feedback when selecting a cell',
                value: profile.vibrationEnabled,
                onChanged: (v) => profile.updateSettings(vibrationEnabled: v),
              ),
              _switchTile(
                icon: Icons.grid_view_rounded,
                title: 'Highlight Same Numbers',
                subtitle: 'Shade every cell matching the selected number',
                value: profile.highlightSameNumbers,
                onChanged: (v) =>
                    profile.updateSettings(highlightSameNumbers: v),
              ),
              const SizedBox(height: 8),
              _sectionLabel('Appearance'),
              _switchTile(
                icon: Icons.dark_mode_outlined,
                title: 'Dark Mode',
                subtitle: 'Switch the whole app to a dark theme',
                value: profile.darkMode,
                onChanged: (v) => profile.updateSettings(darkMode: v),
              ),
              const SizedBox(height: 8),
              _sectionLabel('Stats'),
              _statTile('Games played', '${profile.gamesPlayed}'),
              _statTile('Games won', '${profile.gamesWon}'),
              _statTile('Win rate', '${profile.weeklyWinRatePercent}%'),
              _statTile('Best score', '${profile.bestScore}'),
              const SizedBox(height: 8),
              _sectionLabel('Data'),
              ListTile(
                leading: const Icon(Icons.restart_alt_rounded,
                    color: AppColors.danger),
                title: const Text(
                  'Reset Progress',
                  style: TextStyle(color: AppColors.danger),
                ),
                subtitle: const Text(
                  'Clears coins, best score, and difficulty unlocks',
                ),
                onTap: () => _confirmReset(context, profile),
              ),
              const SizedBox(height: 24),
              const Center(
                child: Text(
                  'Sudoku · v1.0.0',
                  style: TextStyle(color: Colors.black38, fontSize: 12),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
          color: Colors.black45,
        ),
      ),
    );
  }

  Widget _switchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(icon, color: AppColors.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      value: value,
      activeColor: AppColors.primary,
      onChanged: onChanged,
    );
  }

  Widget _statTile(String label, String value) {
    return ListTile(
      title: Text(label),
      trailing: Text(
        value,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }

  void _confirmReset(BuildContext context, ProfileState profile) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Reset progress?'),
        content: const Text(
          'This clears your coins, best score, and every difficulty '
          'unlock. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () {
              profile.resetProgress();
              Navigator.pop(ctx);
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
