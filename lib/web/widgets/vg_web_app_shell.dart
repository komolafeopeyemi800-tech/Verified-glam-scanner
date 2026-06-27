import 'package:flutter/material.dart';

import '../../services/supabase/vg_supabase_auth_service.dart';
import '../../utils/BMColors.dart';
import '../../utils/vg_constants.dart';
import '../vg_web_breakpoints.dart';
import '../vg_web_page_nav_stub.dart'
    if (dart.library.html) '../vg_web_page_nav_web.dart' as page_nav;
import 'vg_web_credits_chip.dart';
import 'vg_web_profile_menu.dart';
import 'vg_web_tool_sidebar.dart';

/// Web SaaS chrome — top bar + sidebar or drawer + main workspace.
class VGWebAppShell extends StatefulWidget {
  final String? activeSlug;
  final VGWebAppSection section;
  final Widget child;

  const VGWebAppShell({
    super.key,
    this.activeSlug,
    this.section = VGWebAppSection.tool,
    required this.child,
  });

  @override
  State<VGWebAppShell> createState() => _VGWebAppShellState();
}

class _VGWebAppShellState extends State<VGWebAppShell> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> _signOut(BuildContext context) async {
    await VGSupabaseAuthService.signOut();
    if (context.mounted) page_nav.vgWebGoLogin();
  }

  @override
  Widget build(BuildContext context) {
    final signedIn = VGSupabaseAuthService.isSignedIn;
    final drawerNav = VGWebBreakpoints.useDrawerNav(context);
    final pad = VGWebBreakpoints.contentPadding(context);
    final phone = VGWebBreakpoints.isPhone(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: bmLightScaffoldBackgroundColor,
      drawer: drawerNav
          ? Drawer(
              width: 280,
              child: VGWebToolNav(
                activeSlug: widget.activeSlug,
                section: widget.section,
                onNavigate: () => _scaffoldKey.currentState?.closeDrawer(),
              ),
            )
          : null,
      body: Column(
        children: [
          Material(
            color: Colors.white,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: bmPrimaryColor.withValues(alpha: 0.22))),
              ),
              child: SafeArea(
                bottom: false,
                child: SizedBox(
                  height: 56,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: pad),
                    child: Row(
                      children: [
                        if (drawerNav)
                          IconButton(
                            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                            icon: const Icon(Icons.menu, color: bmSpecialColor),
                            tooltip: 'Menu',
                          ),
                        if (!drawerNav)
                          Text(
                            vgAppName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 17,
                              color: bmSpecialColorDark,
                            ),
                          )
                        else
                          Expanded(
                            child: Text(
                              vgAppName,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: phone ? 15 : 17,
                                color: bmSpecialColorDark,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        if (!drawerNav) const Spacer(),
                        if (signedIn) ...[
                          VGWebCreditsChip(compact: phone),
                          const SizedBox(width: 4),
                          VGWebProfileMenu(section: widget.section),
                          const SizedBox(width: 4),
                          phone
                              ? IconButton(
                                  onPressed: () => _signOut(context),
                                  icon: const Icon(Icons.logout, color: bmSpecialColor),
                                  tooltip: 'Sign out',
                                )
                              : TextButton(
                                  onPressed: () => _signOut(context),
                                  child: const Text('Sign out', style: TextStyle(color: bmSpecialColor)),
                                ),
                        ] else
                          phone
                              ? IconButton(
                                  onPressed: () => page_nav.vgWebGoLogin(),
                                  icon: const Icon(Icons.login, color: bmSpecialColor),
                                  tooltip: 'Log in',
                                )
                              : TextButton(
                                  onPressed: () => page_nav.vgWebGoLogin(),
                                  child: const Text('Log in', style: TextStyle(color: bmSpecialColor)),
                                ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!drawerNav)
                  VGWebToolSidebar(activeSlug: widget.activeSlug, section: widget.section),
                Expanded(
                  child: ColoredBox(
                    color: bmLightScaffoldBackgroundColor,
                    child: widget.child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
