import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../models/vg_feature_model.dart';
import '../../utils/BMColors.dart';
import 'vg_feature_card.dart';

class VGFeatureCarousel extends StatefulWidget {
  final List<VGFeatureModel> features;
  final ValueChanged<VGFeatureModel>? onFeatureTap;

  const VGFeatureCarousel({
    super.key,
    required this.features,
    this.onFeatureTap,
  });

  @override
  State<VGFeatureCarousel> createState() => _VGFeatureCarouselState();
}

class _VGFeatureCarouselState extends State<VGFeatureCarousel> {
  final PageController _controller = PageController(viewportFraction: 0.82);
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.features.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: 348,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.features.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) {
              final feature = widget.features[i];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: VGFeatureCard(
                    feature: feature,
                    carouselLayout: true,
                    onStartScan: widget.onFeatureTap == null ? null : () => widget.onFeatureTap!(feature),
                  ),
                ),
              );
            },
          ),
        ),
        12.height,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.features.length, (i) {
            final active = i == _index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 8,
              width: active ? 22 : 8,
              decoration: BoxDecoration(
                color: active ? bmSpecialColor : bmPrimaryColor.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(999),
              ),
            );
          }),
        ),
      ],
    );
  }
}
