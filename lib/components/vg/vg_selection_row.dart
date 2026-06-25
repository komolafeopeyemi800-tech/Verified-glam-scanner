import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../utils/BMColors.dart';

class VGSelectionRow extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const VGSelectionRow({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: selected ? bmSpecialColor : Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: selected ? null : Border.all(color: bmSpecialColor),
            ),
            child: Row(
              children: [
                Icon(
                  selected ? Icons.check_circle : Icons.circle_outlined,
                  color: selected ? Colors.white : bmSpecialColor,
                  size: 22,
                ),
                12.width,
                Expanded(
                  child: Text(
                    label,
                    style: boldTextStyle(color: selected ? Colors.white : bmSpecialColor, size: 15),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
