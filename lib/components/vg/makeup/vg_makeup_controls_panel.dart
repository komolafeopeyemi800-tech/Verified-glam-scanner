import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../models/vg_makeup_state.dart';
import '../../../utils/BMColors.dart';
import '../../../utils/vg_copy.dart';
import '../../../utils/vg_makeup_palettes.dart';
import '../../../services/vg_subscription_store.dart';
import '../../../utils/vg_navigation.dart';
import 'vg_makeup_color_grid.dart';
import 'vg_makeup_zone_tabs.dart';

class VGMakeupControlsPanel extends StatelessWidget {
  final VGMakeupState state;
  final List<String> seasonPaletteHex;
  final ValueChanged<VGMakeupState> onStateChanged;

  const VGMakeupControlsPanel({
    super.key,
    required this.state,
    required this.seasonPaletteHex,
    required this.onStateChanged,
  });

  @override
  Widget build(BuildContext context) {
    final swatches = VGMakeupPalettes.swatchesForZone(state.activeZone, seasonPaletteHex);
    final activeColor = state.colorFor(state.activeZone);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          VGMakeupZoneTabs(
            active: state.activeZone,
            onChanged: (z) => onStateChanged(state.copyWith(activeZone: z)),
          ),
          16.height,
          Text(VGCopy.makeupIntensity, style: boldTextStyle(color: bmSpecialColorDark, size: 13)),
          8.height,
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: bmSpecialColor,
              inactiveTrackColor: bmLightScaffoldBackgroundColor,
              thumbColor: bmSpecialColor,
              overlayColor: bmSpecialColor.withValues(alpha: 0.15),
            ),
            child: Slider(
              value: state.intensity,
              min: 0,
              max: 1,
              onChanged: (v) => onStateChanged(state.copyWith(intensity: v)),
            ),
          ),
          8.height,
          VGMakeupColorGrid(
            swatches: swatches,
            selectedColor: activeColor,
            onSelected: (swatch) {
              if (swatch == null) {
                onStateChanged(state.clearActiveZone());
                return;
              }
              switch (state.activeZone) {
                case VGMakeupZone.lips:
                  onStateChanged(state.copyWith(lipsColor: swatch.color));
                case VGMakeupZone.eyes:
                  onStateChanged(state.copyWith(eyesColor: swatch.color));
                case VGMakeupZone.blush:
                  onStateChanged(state.copyWith(blushColor: swatch.color));
              }
            },
            onProSwatchTap: (swatch) async {
              if (!swatch.isPro) return true;
              if (await VGSubscriptionStore.isPro()) return true;
              if (!context.mounted) return false;
              await vgShowPaywall(context);
              if (!context.mounted) return false;
              return await VGSubscriptionStore.isPro();
            },
          ),
        ],
      ),
    );
  }
}
