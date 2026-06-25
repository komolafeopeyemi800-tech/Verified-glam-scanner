import 'package:flutter/material.dart';

import '../../../models/vg_makeup_state.dart';
import '../../../utils/BMColors.dart';
import '../../../utils/vg_copy.dart';

class VGMakeupColorGrid extends StatelessWidget {
  final List<VGMakeupSwatch> swatches;
  final Color? selectedColor;
  final ValueChanged<VGMakeupSwatch?> onSelected;
  final Future<bool> Function(VGMakeupSwatch swatch)? onProSwatchTap;

  const VGMakeupColorGrid({
    super.key,
    required this.swatches,
    required this.selectedColor,
    required this.onSelected,
    this.onProSwatchTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      itemCount: swatches.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) return _clearCell();
        final swatch = swatches[index - 1];
        return _colorCell(swatch);
      },
    );
  }

  Widget _clearCell() {
    final isClear = selectedColor == null;
    return Semantics(
      label: VGCopy.makeupClearColor,
      button: true,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: () => onSelected(null),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isClear ? bmSpecialColor : bmPrimaryColor.withValues(alpha: 0.4),
                width: isClear ? 2.5 : 1,
              ),
            ),
            child: const Icon(Icons.close, color: bmSpecialColorDark, size: 22),
          ),
        ),
      ),
    );
  }

  Widget _colorCell(VGMakeupSwatch swatch) {
    final selected = selectedColor != null &&
        selectedColor!.toARGB32() == swatch.color.toARGB32();
    return Material(
      color: swatch.color,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: () async {
          if (swatch.isPro && onProSwatchTap != null) {
            final allowed = await onProSwatchTap!(swatch);
            if (!allowed) return;
          }
          onSelected(swatch);
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? bmSpecialColorDark : Colors.white.withValues(alpha: 0.5),
              width: selected ? 3 : 1,
            ),
          ),
          child: swatch.isPro
              ? Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(3),
                    child: Icon(Icons.workspace_premium, size: 14, color: Colors.amber.shade700),
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
