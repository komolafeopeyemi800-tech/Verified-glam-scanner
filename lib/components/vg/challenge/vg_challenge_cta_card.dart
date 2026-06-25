import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../utils/BMColors.dart';
class VGChallengeCtaCard extends StatelessWidget {
  final String headline;
  final String body;
  final String buttonLabel;
  final bool loading;
  final VoidCallback? onTap;
  final String? secondaryLabel;
  final VoidCallback? onSecondaryTap;

  const VGChallengeCtaCard({
    super.key,
    required this.headline,
    required this.body,
    required this.buttonLabel,
    this.loading = false,
    this.onTap,
    this.secondaryLabel,
    this.onSecondaryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [bmSpecialColor, bmSpecialColorDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(headline, style: boldTextStyle(color: Colors.white, size: 16)),
          8.height,
          Text(body, style: secondaryTextStyle(color: Colors.white.withValues(alpha: 0.9), size: 12)),
          16.height,
          if (loading)
            const Center(child: CircularProgressIndicator(color: Colors.white))
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: bmSpecialColorDark,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 0,
                ),
                child: Text(buttonLabel, style: boldTextStyle(color: bmSpecialColorDark, size: 14)),
              ),
            ),
          if (!loading && secondaryLabel != null) ...[
            10.height,
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: onSecondaryTap,
                child: Text(
                  secondaryLabel!,
                  style: boldTextStyle(color: Colors.white.withValues(alpha: 0.95), size: 13),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
