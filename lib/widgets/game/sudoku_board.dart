import 'package:flutter/material.dart';
import '../../models/sudoku_cell.dart';
import '../../theme/app_theme.dart';

class SudokuBoard extends StatelessWidget {
  final List<List<SudokuCell>> grid;
  final int? selRow;
  final int? selCol;
  final bool Function(int r, int c) hasConflict;
  final void Function(int r, int c) onCellTap;
  final bool highlightSameNumbers;

  const SudokuBoard({
    super.key,
    required this.grid,
    required this.selRow,
    required this.selCol,
    required this.hasConflict,
    required this.onCellTap,
    this.highlightSameNumbers = true,
  });

  @override
  Widget build(BuildContext context) {
    final selectedValue =
        (selRow != null && selCol != null) ? grid[selRow!][selCol!].value : 0;

    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black87, width: 2),
        ),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 81,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 9,
          ),
          itemBuilder: (context, index) {
            final r = index ~/ 9;
            final c = index % 9;
            return _buildCell(r, c, selectedValue);
          },
        ),
      ),
    );
  }

  Widget _buildCell(int r, int c, int selectedValue) {
    final cell = grid[r][c];
    final isSelected = selRow == r && selCol == c;
    final isPeer = selRow != null &&
        selCol != null &&
        (selRow == r ||
            selCol == c ||
            (r ~/ 3 == selRow! ~/ 3 && c ~/ 3 == selCol! ~/ 3));
    final isSameValue = highlightSameNumbers &&
        selectedValue != 0 &&
        cell.value == selectedValue &&
        !isSelected;
    final conflict = cell.value != 0 && hasConflict(r, c);

    Color bg = Colors.white;
    if (isSelected) {
      bg = AppColors.primary.withOpacity(0.85);
    } else if (isSameValue) {
      bg = AppColors.primary.withOpacity(0.30);
    } else if (isPeer) {
      bg = Colors.grey.withOpacity(0.12);
    }

    Color textColor;
    if (isSelected) {
      textColor = Colors.white;
    } else if (conflict) {
      textColor = AppColors.danger;
    } else if (cell.isGiven) {
      textColor = Colors.black87;
    } else {
      textColor = AppColors.primary;
    }

    return GestureDetector(
      onTap: () => onCellTap(r, c),
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          border: Border(
            right: BorderSide(
              color: (c % 3 == 2 && c != 8)
                  ? Colors.black87
                  : Colors.grey.shade300,
              width: (c % 3 == 2 && c != 8) ? 1.4 : 0.6,
            ),
            bottom: BorderSide(
              color: (r % 3 == 2 && r != 8)
                  ? Colors.black87
                  : Colors.grey.shade300,
              width: (r % 3 == 2 && r != 8) ? 1.4 : 0.6,
            ),
          ),
        ),
        alignment: Alignment.center,
        child: cell.value != 0
            ? Text(
                '${cell.value}',
                style: TextStyle(
                  fontSize: 20,
                  color: textColor,
                  fontWeight: cell.isGiven ? FontWeight.w600 : FontWeight.w500,
                ),
              )
            : (cell.notes.isNotEmpty
                ? _buildNotes(cell.notes)
                : const SizedBox.shrink()),
      ),
    );
  }

  Widget _buildNotes(Set<int> notes) {
    return GridView.builder(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 9,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
      ),
      itemBuilder: (context, i) {
        final n = i + 1;
        return Center(
          child: Text(
            notes.contains(n) ? '$n' : '',
            style: TextStyle(
              fontSize: 9,
              color: AppColors.primary.withOpacity(0.75),
              fontWeight: FontWeight.w600,
              height: 1,
            ),
          ),
        );
      },
    );
  }
}
