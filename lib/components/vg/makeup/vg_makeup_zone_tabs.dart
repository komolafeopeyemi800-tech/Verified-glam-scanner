import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../models/vg_makeup_state.dart';
import '../../../utils/BMColors.dart';
import '../../../utils/vg_copy.dart';

class VGMakeupZoneTabs extends StatelessWidget {
  final VGMakeupZone active;
  final ValueChanged<VGMakeupZone> onChanged;

  const VGMakeupZoneTabs({
    super.key,
    required this.active,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _tab(VGMakeupZone.lips, VGCopy.makeupZoneLips),
        8.width,
        _tab(VGMakeupZone.eyes, VGCopy.makeupZoneEyes),
        8.width,
        _tab(VGMakeupZone.blush, VGCopy.makeupZoneBlush),
      ],
    );
  }

  Widget _tab(VGMakeupZone zone, String label) {
    final selected = active == zone;
    return Expanded(
      child: Material(
        color: selected ? bmSpecialColor.withValues(alpha: 0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => onChanged(zone),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? bmSpecialColor : bmPrimaryColor.withValues(alpha: 0.35),
                width: selected ? 1.5 : 1,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: boldTextStyle(
                color: selected ? bmSpecialColor : appTextColorSecondary,
                size: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
