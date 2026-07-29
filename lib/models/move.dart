/// A single-cell edit that can be reverted by Undo.
class CellMove {
  final int row, col;
  final int prevValue, newValue;
  final Set<int> prevNotes, newNotes;

  CellMove({
    required this.row,
    required this.col,
    required this.prevValue,
    required this.newValue,
    required this.prevNotes,
    required this.newNotes,
  });
}

/// One "step" the player can undo. Usually a single [CellMove], but bulk
/// actions like Fast Pencil bundle many cell edits into one undoable step.
class HistoryStep {
  final List<CellMove> cellMoves;
  final int scoreDelta;
  final int mistakeDelta;
  final int hintDelta;

  HistoryStep({
    required this.cellMoves,
    this.scoreDelta = 0,
    this.mistakeDelta = 0,
    this.hintDelta = 0,
  });
}
