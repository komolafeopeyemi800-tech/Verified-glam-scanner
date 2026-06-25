import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../utils/BMColors.dart';
import '../../utils/vg_dashboard_nav.dart';
import '../../utils/vg_copy.dart';
import '../../web/vg_web_breakpoints.dart';
import '../../web/vg_web_navigation.dart';

void showVGSettingsSheet(BuildContext context) {
  if (kIsWeb && VGWebBreakpoints.isDesktop(context)) {
    context.go('/app/profile');
    return;
  }
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (ctx) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 4,
              width: 40,
              decoration: BoxDecoration(color: bmGreyColor.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(999)),
            ),
            20.height,
            _sheetRow(ctx, VGCopy.settingsProfile, Icons.tune_outlined, () {
              finish(ctx);
              vgRequestDashboardTab(2);
            }),
            _sheetRow(ctx, VGCopy.settingsShare, Icons.share_outlined, () => finish(ctx)),
            _sheetRow(ctx, VGCopy.settingsInvite, Icons.card_giftcard_outlined, () => finish(ctx)),
            _sheetRow(ctx, VGCopy.settingsSupport, Icons.mail_outline, () => finish(ctx)),
            _sheetRow(ctx, VGCopy.settingsPrivacy, Icons.lock_outline, () => finish(ctx)),
          ],
        ),
      );
    },
  );
}

Widget _sheetRow(BuildContext context, String label, IconData icon, VoidCallback onTap) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Material(
      color: bmLightScaffoldBackgroundColor,
      borderRadius: BorderRadius.circular(999),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        leading: Icon(icon, color: bmSpecialColor),
        title: Text(label, style: boldTextStyle(color: bmSpecialColor, size: 15)),
        trailing: Icon(Icons.chevron_right, color: bmSpecialColor),
        onTap: onTap,
      ),
    ),
  );
}
