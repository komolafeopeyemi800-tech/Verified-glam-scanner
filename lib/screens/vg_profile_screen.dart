import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../components/vg/challenge/vg_challenge_badge_grid.dart';
import '../main.dart';
import '../services/vg_challenge_service.dart';
import '../services/vg_subscription_store.dart';
import '../utils/BMColors.dart';
import '../utils/BMConstants.dart';
import '../utils/vg_constants.dart';
import '../utils/vg_copy.dart';
import '../utils/vg_navigation.dart';
import 'subscription/vg_paywall_screen.dart';

class VGProfileScreen extends StatefulWidget {
  const VGProfileScreen({super.key});

  @override
  State<VGProfileScreen> createState() => _VGProfileScreenState();
}

class _VGProfileScreenState extends State<VGProfileScreen> {
  List<Map<String, dynamic>> _badges = const [];
  bool _loadingBadges = true;

  @override
  void initState() {
    super.initState();
    _loadBadges();
  }

  Future<void> _loadBadges() async {
    try {
      final badges = await VGChallengeService.fetchUserBadges();
      if (!mounted) return;
      setState(() {
        _badges = badges;
        _loadingBadges = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingBadges = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: VGSubscriptionStore.isPro(),
      builder: (context, snapshot) {
        final isPro = snapshot.data == true;
        return Scaffold(
          backgroundColor: appStore.isDarkModeOn ? appStore.scaffoldBackground! : bmLightScaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: bmSpecialColor,
            foregroundColor: Colors.white,
            title: Text(VGCopy.profileTitle, style: boldTextStyle(color: Colors.white, size: 18)),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ListTile(
                leading: CircleAvatar(backgroundColor: bmLightScaffoldBackgroundColor, child: Text('VG', style: boldTextStyle(color: bmSpecialColor))),
                title: Text(vgAppName, style: boldTextStyle(color: appTextColorPrimary)),
                subtitle: Text(isPro ? VGCopy.profileSubscriptionPro : VGCopy.splashTagline, style: secondaryTextStyle(size: 12)),
              ),
              16.height,
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(VGCopy.challengeBadgesTitle, style: boldTextStyle(color: bmSpecialColorDark, size: 15)),
                    12.height,
                    VGChallengeBadgeGrid(earnedBadges: _badges, loading: _loadingBadges, compact: true),
                  ],
                ),
              ),
              12.height,
              _tile(Icons.brightness_6_outlined, VGCopy.profileTheme, trailing: Switch(
                value: appStore.isDarkModeOn,
                activeTrackColor: bmSpecialColor,
                onChanged: (val) async {
                  appStore.toggleDarkMode(value: val);
                  await setValue(isDarkModeOnPref, val);
                },
              )),
              _tile(
                Icons.workspace_premium_outlined,
                VGCopy.profileSubscription,
                subtitle: isPro ? VGCopy.profileSubscriptionPro : VGCopy.profileSubscriptionFree,
                onTap: isPro ? null : () => vgShowPaywall(context, entry: VGPaywallEntry.profile),
              ),
              _tile(Icons.privacy_tip_outlined, VGCopy.settingsPrivacy),
              _tile(Icons.mail_outline, VGCopy.settingsSupport, subtitle: vgSupportEmail),
            ],
          ),
        );
      },
    );
  }

  Widget _tile(IconData icon, String title, {String? subtitle, Widget? trailing, VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: bmSpecialColor),
        title: Text(title, style: boldTextStyle(color: appTextColorPrimary, size: 15)),
        subtitle: subtitle != null ? Text(subtitle, style: secondaryTextStyle(size: 12)) : null,
        trailing: trailing ?? (onTap != null ? Icon(Icons.chevron_right, color: bmPrimaryColor) : null),
        onTap: onTap,
      ),
    );
  }
}
