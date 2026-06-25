import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../utils/BMColors.dart';

/// Horizontal exercise chips for symmetry balance suggestions.
class VGExerciseRow extends StatelessWidget {
  final List<String> exercises;

  const VGExerciseRow({super.key, required this.exercises});

  static const _icons = [
    Icons.sentiment_satisfied_alt_outlined,
    Icons.face_outlined,
    Icons.visibility_outlined,
    Icons.favorite_border,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bmSecondBackgroundColorLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: bmPrimaryColor.withValues(alpha: 0.2)),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        children: List.generate(exercises.length, (i) {
          return SizedBox(
            width: 72,
            child: Column(
              children: [
                Icon(_icons[i % _icons.length], color: bmSpecialColor, size: 28),
                6.height,
                Text(
                  exercises[i],
                  style: secondaryTextStyle(size: 9),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
