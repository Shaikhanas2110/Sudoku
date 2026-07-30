import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../logic/sudoku_logic.dart';
import '../models/board_size.dart';
import '../models/difficulty.dart';
import '../models/move.dart';
import '../models/sudoku_cell.dart';
import '../state/profile_state.dart';
import '../theme/app_theme.dart';
import '../utils/formatting.dart';
import '../widgets/new_game_sheet.dart';
import '../widgets/game/control_button.dart';
import '../widgets/game/number_pad.dart';
import '../widgets/game/sudoku_board.dart';
import 'settings_screen.dart';

class GameScreen extends StatefulWidget {
  final Difficulty difficulty;
  final BoardSize boardSize;
  const GameScreen({
    super.key,
    required this.difficulty,
    this.boardSize = BoardSize.classic9,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late Difficulty difficulty;
  late List<List<SudokuCell>> grid;
  late List<List<int>> solution;

  int? selRow;
  int? selCol;
  bool pencilMode = false;

  final List<HistoryStep> _history = [];
  Timer? _timer;
  int _seconds = 0;
  int _score = 0;
  int _mistakes = 0;
  int _hintsLeft = 0;
  bool _paused = false;
  bool _completed = false;
  bool _gameOver = false;
  bool _resultReported = false;

  @override
  void initState() {
    super.initState();
    difficulty = widget.difficulty;
    _newGame(difficulty);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // --------------------------------------------------------------------
  // Game lifecycle
  // --------------------------------------------------------------------

  void _newGame(Difficulty d) {
    _timer?.cancel();
    final sol = SudokuLogic.generateSolution();
    final puzzle = SudokuLogic.generatePuzzle(sol, d.clues);
    setState(() {
      difficulty = d;
      solution = sol;
      grid = List.generate(
        9,
        (r) => List.generate(9, (c) {
          final v = puzzle[r][c];
          return SudokuCell(value: v, isGiven: v != 0);
        }),
      );
      selRow = null;
      selCol = null;
      pencilMode = false;
      _history.clear();
      _seconds = 0;
      _score = 0;
      _mistakes = 0;
      _hintsLeft = d.maxHints;
      _paused = false;
      _completed = false;
      _gameOver = false;
      _resultReported = false;
    });
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_paused && !_completed && !_gameOver) {
        setState(() => _seconds++);
      }
    });
  }

  String get _timeLabel => formatTime(_seconds);

  bool get _locked => _paused || _completed || _gameOver;

  // --------------------------------------------------------------------
  // Selection / conflict helpers
  // --------------------------------------------------------------------

  void _selectCell(int r, int c) {
    if (_locked) return;
    if (ProfileScope.of(context).vibrationEnabled) {
      HapticFeedback.selectionClick();
    }
    setState(() {
      selRow = r;
      selCol = c;
    });
  }

  bool _hasConflict(int r, int c) {
    final v = grid[r][c].value;
    if (v == 0) return false;
    return v != solution[r][c];
  }

  // --------------------------------------------------------------------
  // Editing
  // --------------------------------------------------------------------

  List<List<int>> _currentValues() =>
      List.generate(9, (r) => List.generate(9, (c) => grid[r][c].value));

  void _pushStep(HistoryStep step) {
    if (step.cellMoves.isEmpty) return;
    _history.add(step);
  }

  void _inputNumber(int v, {bool forceNote = false}) {
    if (_locked) return;
    if (selRow == null || selCol == null) return;
    final r = selRow!, c = selCol!;
    final cell = grid[r][c];
    if (cell.isGiven) return;

    final useNoteMode = forceNote || pencilMode;

    setState(() {
      if (useNoteMode) {
        if (cell.value != 0) return;
        final prevNotes = Set<int>.from(cell.notes);
        if (cell.notes.contains(v)) {
          cell.notes.remove(v);
        } else {
          cell.notes.add(v);
        }
        _pushStep(HistoryStep(cellMoves: [
          CellMove(
            row: r,
            col: c,
            prevValue: cell.value,
            newValue: cell.value,
            prevNotes: prevNotes,
            newNotes: Set<int>.from(cell.notes),
          ),
        ]));
        return;
      }

      final prevValue = cell.value;
      if (prevValue == v) return; // already set, tap does nothing
      final prevNotes = Set<int>.from(cell.notes);

      cell.value = v;
      cell.notes.clear();
      _clearPeerNotes(r, c, v);

      final correct = v == solution[r][c];
      final scoreDelta = correct ? difficulty.pointsPerCorrectCell : 0;
      final mistakeDelta = correct ? 0 : 1;

      _score += scoreDelta;
      _mistakes += mistakeDelta;

      _pushStep(HistoryStep(
        cellMoves: [
          CellMove(
            row: r,
            col: c,
            prevValue: prevValue,
            newValue: v,
            prevNotes: prevNotes,
            newNotes: <int>{},
          ),
        ],
        scoreDelta: scoreDelta,
        mistakeDelta: mistakeDelta,
      ));

      if (_mistakes >= difficulty.maxMistakes) {
        _gameOver = true;
        _timer?.cancel();
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _showGameOverDialog());
        return;
      }
      _checkComplete();
    });
  }

  void _clearPeerNotes(int r, int c, int v) {
    for (int i = 0; i < 9; i++) {
      grid[r][i].notes.remove(v);
      grid[i][c].notes.remove(v);
    }
    final br = (r ~/ 3) * 3, bc = (c ~/ 3) * 3;
    for (int i = br; i < br + 3; i++) {
      for (int j = bc; j < bc + 3; j++) {
        grid[i][j].notes.remove(v);
      }
    }
  }

  void _erase() {
    if (_locked) return;
    if (selRow == null || selCol == null) return;
    final r = selRow!, c = selCol!;
    final cell = grid[r][c];
    if (cell.isGiven) return;
    if (cell.value == 0 && cell.notes.isEmpty) return;
    setState(() {
      final prevValue = cell.value;
      final prevNotes = Set<int>.from(cell.notes);
      cell.value = 0;
      cell.notes.clear();
      _pushStep(HistoryStep(cellMoves: [
        CellMove(
          row: r,
          col: c,
          prevValue: prevValue,
          newValue: 0,
          prevNotes: prevNotes,
          newNotes: <int>{},
        ),
      ]));
    });
  }

  void _undo() {
    if (_locked && !_gameOver) return;
    if (_history.isEmpty) return;
    final step = _history.removeLast();
    setState(() {
      for (final move in step.cellMoves.reversed) {
        final cell = grid[move.row][move.col];
        cell.value = move.prevValue;
        cell.notes
          ..clear()
          ..addAll(move.prevNotes);
      }
      _score -= step.scoreDelta;
      _mistakes = (_mistakes - step.mistakeDelta).clamp(0, 99);
      _hintsLeft = (_hintsLeft + step.hintDelta).clamp(0, difficulty.maxHints);
      if (_gameOver && _mistakes < difficulty.maxMistakes) {
        _gameOver = false;
        _startTimer();
      }
      final last = step.cellMoves.last;
      selRow = last.row;
      selCol = last.col;
    });
  }

  void _togglePencil() {
    if (_locked) return;
    setState(() => pencilMode = !pencilMode);
  }

  /// Fast Pencil: instantly fills every empty cell with its full set of
  /// currently-valid candidate numbers (pencil marks), computed from the
  /// digits already placed on the board.
  void _fastPencil() {
    if (_locked) return;
    final values = _currentValues();
    final moves = <CellMove>[];
    setState(() {
      for (int r = 0; r < 9; r++) {
        for (int c = 0; c < 9; c++) {
          final cell = grid[r][c];
          if (cell.value != 0) continue;
          final candidates = SudokuLogic.candidatesFor(values, r, c);
          if (setEquals(cell.notes, candidates)) continue;
          moves.add(CellMove(
            row: r,
            col: c,
            prevValue: 0,
            newValue: 0,
            prevNotes: Set<int>.from(cell.notes),
            newNotes: candidates,
          ));
          cell.notes
            ..clear()
            ..addAll(candidates);
        }
      }
      _pushStep(HistoryStep(cellMoves: moves));
    });
    if (moves.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pencil marks are already up to date'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  /// Smart Hint: reveals the correct digit for the selected cell (or the
  /// first empty cell if none is selected).
  void _useSmartHint() {
    if (_locked) return;
    if (_hintsLeft <= 0) return;

    int? r = selRow, c = selCol;
    if (r == null || c == null || grid[r][c].value != 0) {
      outer:
      for (int i = 0; i < 9; i++) {
        for (int j = 0; j < 9; j++) {
          if (grid[i][j].value == 0) {
            r = i;
            c = j;
            break outer;
          }
        }
      }
    }
    if (r == null || c == null) return;
    final cell = grid[r][c];
    if (cell.value != 0) return;

    setState(() {
      final prevValue = cell.value;
      final prevNotes = Set<int>.from(cell.notes);
      final v = solution[r!][c!];
      cell.value = v;
      cell.notes.clear();
      _clearPeerNotes(r!, c!, v);
      _hintsLeft--;
      selRow = r;
      selCol = c;

      _pushStep(HistoryStep(
        cellMoves: [
          CellMove(
            row: r!,
            col: c!,
            prevValue: prevValue,
            newValue: v,
            prevNotes: prevNotes,
            newNotes: <int>{},
          ),
        ],
        hintDelta: 1,
      ));
      _checkComplete();
    });
  }

  void _togglePause() {
    if (_completed || _gameOver) return;
    setState(() => _paused = !_paused);
  }

  int _remainingCount(int v) {
    int count = 0;
    for (final row in grid) {
      for (final cell in row) {
        if (cell.value == v) count++;
      }
    }
    return 9 - count;
  }

  void _checkComplete() {
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (grid[r][c].value != solution[r][c]) return;
      }
    }
    _completed = true;
    _timer?.cancel();
    _reportResult(won: true);
    WidgetsBinding.instance.addPostFrameCallback((_) => _showWinDialog());
  }

  void _reportResult({required bool won}) {
    if (_resultReported) return;
    _resultReported = true;
    ProfileScope.of(context).registerGameResult(
      difficulty: difficulty,
      score: _score,
      won: won,
    );
  }

  // --------------------------------------------------------------------
  // Dialogs
  // --------------------------------------------------------------------

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Solved! 🎉'),
        content: Text(
          'You finished the ${difficulty.label} puzzle in $_timeLabel with a '
          'score of ${formatNumber(_score)}.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Home'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _newGame(difficulty);
            },
            child: const Text('New game'),
          ),
        ],
      ),
    );
  }

  void _showGameOverDialog() {
    _reportResult(won: false);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Game Over'),
        content: Text(
          'You hit ${difficulty.maxMistakes} mistakes. '
          'Score: ${formatNumber(_score)}.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Home'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _newGame(difficulty);
            },
            child: const Text('Try again'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickNewDifficulty() async {
    final chosen = await showNewGameSheet(context, current: difficulty);
    if (chosen != null) _newGame(chosen.difficulty);
  }

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  // --------------------------------------------------------------------
  // Build
  // --------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            const SizedBox(height: 6),
            _buildScoreRow(),
            const SizedBox(height: 14),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        children: [
                          SudokuBoard(
                            grid: grid,
                            selRow: selRow,
                            selCol: selCol,
                            hasConflict: _hasConflict,
                            onCellTap: _selectCell,
                            highlightSameNumbers:
                                ProfileScope.of(context).highlightSameNumbers,
                          ),
                          if (_paused)
                            Positioned.fill(
                              child: GestureDetector(
                                onTap: _togglePause,
                                child: Container(
                                  color: Colors.white.withOpacity(0.9),
                                  alignment: Alignment.center,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(Icons.pause_circle_filled,
                                          size: 48, color: AppColors.primary),
                                      SizedBox(height: 8),
                                      Text(
                                        'Paused — tap to resume',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      _buildControlRow(),
                      const SizedBox(height: 14),
                      NumberPad(
                        remainingCount: _remainingCount,
                        onTap: (v) => _inputNumber(v),
                        onLongPress: (v) => _inputNumber(v, forceNote: true),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 16, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.star_border_rounded),
            onPressed: () {},
            tooltip: 'Favorite',
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _pickNewDifficulty,
            tooltip: 'New game',
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: _openSettings,
            tooltip: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildScoreRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Text(
            'Score: ${formatNumber(_score)}',
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                'Mistakes: $_mistakes/${difficulty.maxMistakes}',
                style: TextStyle(
                  fontSize: 13,
                  color: _mistakes > 0 ? AppColors.danger : Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    difficulty.label,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: _togglePause,
                child: Row(
                  children: [
                    const Icon(Icons.timer_outlined,
                        size: 16, color: Colors.black54),
                    const SizedBox(width: 4),
                    Text(
                      _timeLabel,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      _paused
                          ? Icons.play_circle_outline
                          : Icons.pause_circle_outline,
                      size: 18,
                      color: Colors.black54,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ControlButton(
          icon: Icons.undo_rounded,
          label: 'Undo',
          onTap: _history.isEmpty ? null : _undo,
        ),
        ControlButton(
          icon: Icons.backspace_outlined,
          label: 'Erase',
          onTap: _erase,
        ),
        ControlButton(
          icon: Icons.flash_on_rounded,
          label: 'Fast Pencil',
          onTap: _fastPencil,
          badgeText: 'AUTO',
        ),
        ControlButton(
          icon: Icons.edit_outlined,
          label: pencilMode ? 'Pencil ON' : 'Pencil',
          onTap: _togglePencil,
          active: pencilMode,
        ),
        ControlButton(
          icon: Icons.lightbulb_outline_rounded,
          label: 'Smart Hint',
          onTap: _hintsLeft > 0 ? _useSmartHint : null,
          badgeText: '$_hintsLeft',
          badgeColor: AppColors.gold,
        ),
      ],
    );
  }
}
