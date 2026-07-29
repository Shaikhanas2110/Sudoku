class SudokuCell {
  int value; // 0 = empty
  final bool isGiven;
  final Set<int> notes;

  SudokuCell({this.value = 0, this.isGiven = false, Set<int>? notes})
      : notes = notes ?? <int>{};

  SudokuCell copy() =>
      SudokuCell(value: value, isGiven: isGiven, notes: Set<int>.from(notes));
}
