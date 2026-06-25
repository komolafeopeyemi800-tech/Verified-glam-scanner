import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../utils/BMColors.dart';
import '../../utils/vg_copy.dart';
import '../../utils/vg_feature_data.dart';
import '../vg_feature_slugs.dart';
import '../vg_web_breakpoints.dart';

enum VGWebAppSection { tool, profile }

/// Shared tool + profile navigation for sidebar and drawer.
class VGWebToolNav extends StatelessWidget {
  final String? activeSlug;
  final VGWebAppSection section;
  final VoidCallback? onNavigate;

  const VGWebToolNav({
    super.key,
    this.activeSlug,
    this.section = VGWebAppSection.tool,
    this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final tools = getVerifiedGlamFeatures();

    void go(String path) {
      context.go(path);
      onNavigate?.call();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: InkWell(
            onTap: () => go('/'),
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Image.asset('images/verified_glam_logo.png', height: 32),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Verified Glam',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: bmSpecialColorDark),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'AI tools',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: appTextColorSecondary.withValues(alpha: 0.9),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              for (final tool in tools)
                _ToolTile(
                  label: tool.title,
                  icon: tool.icon,
                  selected: section == VGWebAppSection.tool && slugForFeatureType(tool.featureType) == activeSlug,
                  onTap: () => go('/app/${slugForFeatureType(tool.featureType)}'),
                ),
            ],
          ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
          child: _ToolTile(
            label: VGCopy.tabProfile,
            icon: Icons.person_outline,
            selected: section == VGWebAppSection.profile,
            onTap: () => go('/app/profile'),
          ),
        ),
      ],
    );
  }
}

/// Left rail — one tool at a time + Profile at the bottom.
class VGWebToolSidebar extends StatelessWidget {
  final String? activeSlug;
  final VGWebAppSection section;

  const VGWebToolSidebar({
    super.key,
    this.activeSlug,
    this.section = VGWebAppSection.tool,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: VGWebBreakpoints.sidebarWidth,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: bmPrimaryColor.withValues(alpha: 0.22))),
      ),
      child: SafeArea(
        child: VGWebToolNav(activeSlug: activeSlug, section: section),
      ),
    );
  }
}

class _ToolTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ToolTile({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: selected ? bmSpecialColor.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            child: Row(
              children: [
                Icon(icon, size: 20, color: selected ? bmSpecialColor : bmGreyColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected ? bmSpecialColorDark : appTextColorSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
