import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../utils/BMColors.dart';

class VGSwatchRow extends StatelessWidget {
  final String skinHex;
  final String hairHex;
  final String eyesHex;
  final String? selected;

  const VGSwatchRow({
    super.key,
    required this.skinHex,
    required this.hairHex,
    required this.eyesHex,
    this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _chip('Skin', skinHex, selected == 'skin'),
        _chip('Hair', hairHex, selected == 'hair'),
        _chip('Eyes', eyesHex, selected == 'eyes'),
      ],
    );
  }

  Widget _chip(String label, String hex, bool isSelected) {
    Color color;
    try {
      final h = hex.replaceFirst('#', '');
      color = Color(int.parse('FF$h', radix: 16));
    } catch (_) {
      color = bmPrimaryColor;
    }
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? bmSpecialColor : bmPrimaryColor.withValues(alpha: 0.3),
              width: isSelected ? 3 : 1,
            ),
          ),
        ),
        6.height,
        Text(label, style: secondaryTextStyle(size: 12)),
      ],
    );
  }
}
