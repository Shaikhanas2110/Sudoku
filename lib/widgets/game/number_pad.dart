import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class NumberPad extends StatelessWidget {
  /// Returns how many of digit [v] (1-9) are still left to place.
  final int Function(int v) remainingCount;
  final void Function(int v) onTap;
  final void Function(int v) onLongPress;

  const NumberPad({
    super.key,
    required this.remainingCount,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(9, (i) {
        final v = i + 1;
        final remaining = remainingCount(v);
        final done = remaining <= 0;
        return Expanded(
          child: Opacity(
            opacity: done ? 0.0 : 1.0,
            child: IgnorePointer(
              ignoring: done,
              child: GestureDetector(
                onTap: () => onTap(v),
                onLongPress: () => onLongPress(v),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$v',
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                          height: 1.1,
                        ),
                      ),
                      Text(
                        '$remaining',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade400,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
