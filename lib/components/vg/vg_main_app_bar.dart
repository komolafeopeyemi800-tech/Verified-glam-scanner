import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../utils/BMColors.dart';
import '../vg/vg_settings_sheet.dart';
import '../../web/vg_web_breakpoints.dart';

class VGMainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showSettings;

  const VGMainAppBar({super.key, required this.title, this.showSettings = true});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: bmSpecialColor,
      elevation: 0,
      title: Text(title, style: boldTextStyle(color: Colors.white, size: 18)),
      actions: [
        if (showSettings && !(kIsWeb && VGWebBreakpoints.isDesktop(context)))
          IconButton(
            onPressed: () => showVGSettingsSheet(context),
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
          ),
      ],
    );
  }
}
