enum BoardSize { classic9, big16 }

extension BoardSizeX on BoardSize {
  String get label {
    switch (this) {
      case BoardSize.classic9:
        return 'Fast';
      case BoardSize.big16:
        return '16x16';
    }
  }

  bool get isImplemented => this == BoardSize.classic9;
}
