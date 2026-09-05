import 'package:flutter/material.dart';
import '../models/difficulty.dart';

/// App-wide profile data: currency, streak, best score, per-difficulty
/// completion counts (used to unlock harder tiers), and user settings.
/// Everything here is a plain [ChangeNotifier] so the project doesn't need
/// any extra state-management package. Data lives in memory for the
/// session (there's no local persistence wired up yet).
class ProfileState extends ChangeNotifier {
  int coins;
  int streak;
  int bestScore;

  int gamesPlayed;
  int gamesWon;

  /// How many times each difficulty has been *won*. Drives the unlock


  final Map<Difficulty, int> completedByDifficulty;

  // --- Settings -----------------------------------------------------
  bool soundEnabled;
  bool vibrationEnabled;
  bool highlightSameNumbers;
  bool darkMode;

  ProfileState({
    this.coins = 0,
    this.streak = 0,
    this.bestScore = 0,
    this.gamesPlayed = 0,
    this.gamesWon = 0,
    Map<Difficulty, int>? completedByDifficulty,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.highlightSameNumbers = true,
    this.darkMode = false,
  }) : completedByDifficulty =
            completedByDifficulty ?? {Difficulty.hard: 0, Difficulty.expert: 0};

  /// Win rate shown on the New Game sheet, derived from real play data.
  int get weeklyWinRatePercent {
    if (gamesPlayed == 0) return 0;
    return ((gamesWon / gamesPlayed) * 100).round();
  }

  bool isUnlocked(Difficulty d) {
    final req = d.unlockRequirementDifficulty;
    if (req == null) return true;
    final have = completedByDifficulty[req] ?? 0;
    return have >= d.unlockRequirementCount;
  }

  void addCoins(int amount) {
    coins += amount;
    notifyListeners();
  }

  /// Called when a game ends. Updates coins, best score, win rate and
  /// unlock progress.
  void registerGameResult({
    required Difficulty difficulty,
    required int score,
    required bool won,
  }) {
    gamesPlayed++;
    if (score > bestScore) bestScore = score;
    if (won) {
      gamesWon++;
      coins += 15;
      completedByDifficulty[difficulty] =
          (completedByDifficulty[difficulty] ?? 0) + 1;
    }
    notifyListeners();
  }

  void updateSettings({
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? highlightSameNumbers,
    bool? darkMode,
  }) {
    if (soundEnabled != null) this.soundEnabled = soundEnabled;
    if (vibrationEnabled != null) this.vibrationEnabled = vibrationEnabled;
    if (highlightSameNumbers != null) {
      this.highlightSameNumbers = highlightSameNumbers;
    }
    if (darkMode != null) this.darkMode = darkMode;
    notifyListeners();
  }

  void resetProgress() {
    coins = 200;
    streak = 0;
    bestScore = 0;
    gamesPlayed = 0;
    gamesWon = 0;
    completedByDifficulty.clear();
    notifyListeners();
  }
}

class ProfileScope extends InheritedNotifier<ProfileState> {
  const ProfileScope({
    super.key,
    required ProfileState profile,
    required super.child,
  }) : super(notifier: profile);

  static ProfileState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ProfileScope>();
    assert(scope != null, 'ProfileScope not found in context');
    return scope!.notifier!;
  }
}
