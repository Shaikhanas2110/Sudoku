import 'package:flutter/material.dart';
import '../models/difficulty.dart';

Future<Difficulty?> pickDifficulty(
  BuildContext context, {
  Difficulty? current,
}) {
  return showModalBottomSheet<Difficulty>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'New game',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              for (final d in Difficulty.values)
                ListTile(
                  title: Text(d.label),
                  trailing: d == current
                      ? const Icon(Icons.check, size: 20)
                      : null,
                  onTap: () => Navigator.pop(ctx, d),
                ),
            ],
          ),
        ),
      );
    },
  );
}
