import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../utils/BMColors.dart';
import '../../../utils/vg_copy.dart';
import '../../../utils/vg_error_utils.dart';

/// Dialog for scan/analysis failures with optional retry.
Future<bool?> showVGScanErrorDialog(
  BuildContext context, {
  required VGAnalysisFailure failure,
}) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(
        vgAnalysisErrorTitle(failure.errorCode),
        style: boldTextStyle(color: bmSpecialColorDark, size: 18),
      ),
      content: Text(
        failure.message,
        style: primaryTextStyle(size: 14, height: 1.45),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(VGCopy.scanErrorCancel, style: primaryTextStyle(color: appTextColorSecondary)),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(VGCopy.scanErrorTryAgain, style: boldTextStyle(color: bmSpecialColor)),
        ),
      ],
    ),
  );
}
