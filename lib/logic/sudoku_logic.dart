import 'dart:math';

class SudokuLogic {
  static final Random _rand = Random();

  static List<List<int>> _emptyGrid() =>
      List.generate(9, (_) => List.filled(9, 0));

  static bool isValidPlacement(List<List<int>> g, int r, int c, int v) {
    for (int i = 0; i < 9; i++) {
      if (i != c && g[r][i] == v) return false;
      if (i != r && g[i][c] == v) return false;
    }
    final br = (r ~/ 3) * 3, bc = (c ~/ 3) * 3;
    for (int i = br; i < br + 3; i++) {
      for (int j = bc; j < bc + 3; j++) {
        if ((i != r || j != c) && g[i][j] == v) return false;
      }
    }
    return true;
  }

  static bool _fill(List<List<int>> g) {
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (g[r][c] == 0) {
          final nums = List.generate(9, (i) => i + 1)..shuffle(_rand);
          for (final v in nums) {
            if (isValidPlacement(g, r, c, v)) {
              g[r][c] = v;
              if (_fill(g)) return true;
              g[r][c] = 0;
            }
          }
          return false;
        }
      }
    }
    return true;
  }

  static List<List<int>> generateSolution() {
    final g = _emptyGrid();
    _fill(g);
    return g;
  }

  static int _countSolutions(List<List<int>> g, int limit) {
    int count = 0;

    bool solve(List<List<int>> grid) {
      for (int r = 0; r < 9; r++) {
        for (int c = 0; c < 9; c++) {
          if (grid[r][c] == 0) {
            for (int v = 1; v <= 9; v++) {
              if (isValidPlacement(grid, r, c, v)) {
                grid[r][c] = v;
                if (solve(grid)) return true;
                grid[r][c] = 0;
              }
            }
            return false;
          }
        }
      }
      count++;
      return count >= limit;
    }

    solve(g);
    return count;
  }

  static List<List<int>> generatePuzzle(List<List<int>> solution, int clues) {
    final puzzle = solution.map((row) => List<int>.from(row)).toList();
    final target = 81 - clues;
    int removed = 0;

    // A single shuffled pass typically plateaus before reaching very low
    // clue counts (Extreme). Re-shuffle the remaining filled cells and try
    // again for a few extra passes so harder tiers can get closer to their
    // target without an expensive unbounded search.
    for (int pass = 0; pass < 4 && removed < target; pass++) {
      final positions = [
        for (int r = 0; r < 9; r++)
          for (int c = 0; c < 9; c++)
            if (puzzle[r][c] != 0) [r, c]
      ]..shuffle(_rand);

      for (final pos in positions) {
        if (removed >= target) break;
        final r = pos[0], c = pos[1];
        if (puzzle[r][c] == 0) continue;
        final backup = puzzle[r][c];
        puzzle[r][c] = 0;
        final copy = puzzle.map((row) => List<int>.from(row)).toList();
        final solutions = _countSolutions(copy, 2);
        if (solutions == 1) {
          removed++;
        } else {
          puzzle[r][c] = backup;
        }
      }
    }
    return puzzle;
  }

  /// Returns every digit 1-9 that could legally go in (r, c) given the
  /// digits currently placed elsewhere on the board. Used by Fast Pencil
  /// to instantly compute pencil-mark candidates for empty cells.
  static Set<int> candidatesFor(List<List<int>> values, int r, int c) {
    final used = <int>{};
    for (int i = 0; i < 9; i++) {
      if (values[r][i] != 0) used.add(values[r][i]);
      if (values[i][c] != 0) used.add(values[i][c]);
    }
    final br = (r ~/ 3) * 3, bc = (c ~/ 3) * 3;
    for (int i = br; i < br + 3; i++) {
      for (int j = bc; j < bc + 3; j++) {
        if (values[i][j] != 0) used.add(values[i][j]);
      }
    }
    return {for (int v = 1; v <= 9; v++) v}..removeAll(used);
  }
}
