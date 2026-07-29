enum Difficulty { beginner, easy, medium, hard, expert, extreme }

extension DifficultyX on Difficulty {
  String get label {
    switch (this) {
      case Difficulty.beginner:
        return 'Beginner';
      case Difficulty.easy:
        return 'Easy';
      case Difficulty.medium:
        return 'Medium';
      case Difficulty.hard:
        return 'Hard';
      case Difficulty.expert:
        return 'Expert';
      case Difficulty.extreme:
        return 'Extreme';
    }
  }

  /// Number of starting clues left on the board.
  int get clues {
    switch (this) {
      case Difficulty.beginner:
        return 46;
      case Difficulty.easy:
        return 40;
      case Difficulty.medium:
        return 32;
      case Difficulty.hard:
        return 27;
      case Difficulty.expert:
        return 23;
      case Difficulty.extreme:
        return 22;
    }
  }

  /// Points earned per correctly placed digit.
  int get pointsPerCorrectCell {
    switch (this) {
      case Difficulty.beginner:
        return 4;
      case Difficulty.easy:
        return 6;
      case Difficulty.medium:
        return 8;
      case Difficulty.hard:
        return 11;
      case Difficulty.expert:
        return 15;
      case Difficulty.extreme:
        return 20;
    }
  }

  /// Number of allowed mistakes before the run ends.
  int get maxMistakes => 3;

  /// Number of Smart Hints available per game.
  int get maxHints => 3;

  /// Which difficulty must be completed (and how many times) before this
  /// tier unlocks. Null means it's always unlocked.
  Difficulty? get unlockRequirementDifficulty {
    switch (this) {
      case Difficulty.expert:
        return Difficulty.hard;
      case Difficulty.extreme:
        return Difficulty.expert;
      default:
        return null;
    }
  }

  int get unlockRequirementCount {
    switch (this) {
      case Difficulty.expert:
        return 1;
      case Difficulty.extreme:
        return 8;
      default:
        return 0;
    }
  }
}
