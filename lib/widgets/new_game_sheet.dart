import 'package:flutter/material.dart';

import '../models/board_size.dart';
import '../models/difficulty.dart';
import '../models/new_game_selection.dart';
import '../state/profile_state.dart';
import '../theme/app_theme.dart';

Future<NewGameSelection?> showNewGameSheet(
  BuildContext context, {
  Difficulty? current,
}) {
  final profile = ProfileScope.of(context);
  return showModalBottomSheet<NewGameSelection>(
    context: context,
    backgroundColor: Colors.white,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => _NewGameSheet(profile: profile, current: current),
  );
}

class _NewGameSheet extends StatefulWidget {
  final ProfileState profile;
  final Difficulty? current;

  const _NewGameSheet({required this.profile, required this.current});

  @override
  State<_NewGameSheet> createState() => _NewGameSheetState();
}

class _NewGameSheetState extends State<_NewGameSheet> {
  BoardSize _boardSize = BoardSize.classic9;

  void _pickBoardSize(BoardSize size) {
    if (!size.isImplemented) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('16x16 puzzles are coming in a future update'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    setState(() => _boardSize = size);
  }

  void _pickDifficulty(Difficulty d) {
    if (!widget.profile.isUnlocked(d)) return;
    Navigator.pop(context, NewGameSelection(d, _boardSize));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.profile,
      builder: (context, _) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const Text(
                  'New Game',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Weekly Win Rate  ',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    Text(
                      '${widget.profile.weeklyWinRatePercent}%',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                for (final d in Difficulty.values) ...[
                  _difficultyRow(d),
                  const SizedBox(height: 10),
                ],
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: _boardSizeChip(BoardSize.classic9),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _boardSizeChip(BoardSize.big16),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _difficultyRow(Difficulty d) {
    final unlocked = widget.profile.isUnlocked(d);
    final isCurrent = d == widget.current;

    if (!unlocked) {
      final req = d.unlockRequirementDifficulty!;
      final count = d.unlockRequirementCount;
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(Icons.lock_outline, size: 18, color: Colors.grey.shade400),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  d.label,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade400,
                  ),
                ),
                Text(
                  'Complete $count ${req.label.toLowerCase()} games to unlock',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => _pickDifficulty(d),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isCurrent ? AppColors.primary : Colors.grey.shade200,
            width: isCurrent ? 1.6 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          d.label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _boardSizeChip(BoardSize size) {
    final selected = _boardSize == size;
    final locked = !size.isImplemented;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => _pickBoardSize(size),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.grey.shade200,
            width: selected ? 1.6 : 1,
          ),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (locked) ...[
              Icon(Icons.lock_outline, size: 15, color: Colors.grey.shade400),
              const SizedBox(width: 6),
            ],
            Text(
              size.label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: locked ? Colors.grey.shade400 : AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
