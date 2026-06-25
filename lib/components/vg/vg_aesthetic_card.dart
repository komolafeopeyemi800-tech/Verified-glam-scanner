import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../models/vg_aesthetic_option.dart';
import '../../utils/BMColors.dart';
import 'vg_line_art_illustration.dart';

class VGAestheticIllustration extends StatelessWidget {
  final VGAestheticOption option;
  final double size;

  const VGAestheticIllustration({super.key, required this.option, this.size = 88});

  @override
  Widget build(BuildContext context) {
    return VGLineArtIllustration(
      motif: motifForAestheticId(option.id),
      size: size,
    );
  }
}

class VGAestheticCard extends StatelessWidget {
  final VGAestheticOption option;
  final bool selected;
  final VoidCallback onTap;

  const VGAestheticCard({super.key, required this.option, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          width: context.width() * 0.78,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: selected ? bmSpecialColor : bmPrimaryColor.withValues(alpha: 0.35), width: selected ? 2 : 1),
          ),
          child: Column(
            children: [
              VGAestheticIllustration(option: option),
              16.height,
              Text(option.title, style: boldTextStyle(color: appTextColorPrimary, size: 18), textAlign: TextAlign.center),
              8.height,
              Text(option.description, style: secondaryTextStyle(color: appTextColorSecondary, size: 13), textAlign: TextAlign.center),
              16.height,
              Icon(selected ? Icons.check_circle : Icons.circle_outlined, color: bmSpecialColor),
            ],
          ),
        ),
      ),
    );
  }
}
