import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:share_plus/share_plus.dart';

import '../../../services/vg_referral_service.dart';
import '../../../utils/BMColors.dart';
import '../../../utils/vg_constants.dart';
import '../../../utils/vg_copy.dart';
import '../vg_pill_button.dart';

class VGShareResultBar extends StatefulWidget {
  final Future<String> Function() buildShareMessage;

  const VGShareResultBar({super.key, required this.buildShareMessage});

  @override
  State<VGShareResultBar> createState() => _VGShareResultBarState();
}

class _VGShareResultBarState extends State<VGShareResultBar> {
  int _downloadCount = 0;
  bool _canRedeem = false;
  bool _redeemed = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final count = await VGReferralService.downloadCount();
    final canRedeem = await VGReferralService.canRedeem();
    final redeemed = await VGReferralService.isRedeemed();
    if (!mounted) return;
    setState(() {
      _downloadCount = count;
      _canRedeem = canRedeem;
      _redeemed = redeemed;
    });
  }

  Future<void> _share() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final message = await widget.buildShareMessage();
      await Share.share(message, subject: vgAppName);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _redeem() async {
    if (_busy || !_canRedeem) return;
    setState(() => _busy = true);
    try {
      final ok = await VGReferralService.redeemReward();
      if (!mounted) return;
      if (ok) {
        toast(VGCopy.shareReferralRedeemedSuccess);
        await _refresh();
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _mockReferral() async {
    if (!kVGLocalDevMode) return;
    await VGReferralService.mockRegisterDownload();
    if (!mounted) return;
    toast(VGCopy.shareReferralMockAdded);
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: bmPrimaryColor.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            VGCopy.shareReferralRewardTitle,
            style: boldTextStyle(color: bmSpecialColorDark, size: 14),
          ),
          6.height,
          Text(
            VGCopy.referralProgressLabel(_downloadCount, vgReferralRewardThreshold),
            style: secondaryTextStyle(size: 12),
          ),
          12.height,
          VGPillButton(
            label: _busy ? '…' : VGCopy.resultsShare,
            onTap: _busy ? null : _share,
          ),
          if (_canRedeem && !_redeemed) ...[
            10.height,
            VGPillButton(
              label: VGCopy.shareReferralRedeem,
              outline: true,
              onTap: _busy ? null : _redeem,
            ),
          ],
          if (_redeemed) ...[
            10.height,
            Text(
              VGCopy.shareReferralAlreadyRedeemed,
              style: secondaryTextStyle(size: 11, color: bmSpecialColor),
              textAlign: TextAlign.center,
            ),
          ],
          if (kVGLocalDevMode) ...[
            10.height,
            GestureDetector(
              onLongPress: _mockReferral,
              child: Text(
                VGCopy.shareReferralMockHint,
                style: secondaryTextStyle(size: 10),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
