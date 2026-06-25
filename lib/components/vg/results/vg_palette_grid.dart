import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../utils/BMColors.dart';

/// Season palette swatch grid for color analysis results.
class VGPaletteGrid extends StatelessWidget {
  final List<String> paletteNames;
  final List<String>? paletteHex;

  const VGPaletteGrid({super.key, required this.paletteNames, this.paletteHex});

  @override
  Widget build(BuildContext context) {
    final colors = _resolveColors();
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: List.generate(paletteNames.length, (i) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: colors[i],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: bmPrimaryColor.withValues(alpha: 0.3)),
              ),
            ),
            4.height,
            SizedBox(
              width: 64,
              child: Text(
                paletteNames[i],
                style: secondaryTextStyle(size: 10),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      }),
    );
  }

  List<Color> _resolveColors() {
    if (paletteHex != null && paletteHex!.length == paletteNames.length) {
      return paletteHex!.map(_parseHex).toList();
    }
    const fallbacks = [
      Color(0xFFC67B5C),
      Color(0xFF6B7A4A),
      Color(0xFF9C8575),
      Color(0xFF1E4D4A),
    ];
    return List.generate(paletteNames.length, (i) => fallbacks[i % fallbacks.length]);
  }

  Color _parseHex(String hex) {
    try {
      final h = hex.replaceFirst('#', '');
      return Color(int.parse('FF$h', radix: 16));
    } catch (_) {
      return bmPrimaryColor;
    }
  }
}
