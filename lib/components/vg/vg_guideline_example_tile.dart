import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../models/vg_guideline_example.dart';
import '../../utils/BMColors.dart';

class VGGuidelineExampleTile extends StatelessWidget {
  final VGGuidelineExample example;
  final double width;

  const VGGuidelineExampleTile({super.key, required this.example, this.width = 100});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: width * 1.15,
                  width: width,
                  child: Image.asset(
                    example.assetPath,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: bmLightScaffoldBackgroundColor,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            example.isGood ? Icons.face_outlined : Icons.no_photography_outlined,
                            color: bmPrimaryColor,
                            size: 32,
                          ),
                          if (kDebugMode) ...[
                            4.height,
                            Text('Add asset', style: secondaryTextStyle(size: 9, color: appTextColorSecondary)),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: example.isGood ? Colors.green.shade600 : bmSpecialColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    example.isGood ? Icons.check : Icons.close,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            ],
          ),
          6.height,
          Text(
            example.caption,
            style: secondaryTextStyle(size: 11, color: appTextColorSecondary),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}
