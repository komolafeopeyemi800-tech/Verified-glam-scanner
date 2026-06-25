import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../utils/BMColors.dart';
import '../../../utils/vg_copy.dart';

/// Live countdown until the next challenge day unlocks.
class VGChallengeUnlockCountdown extends StatefulWidget {
  final DateTime unlockAt;
  final TextStyle? labelStyle;

  const VGChallengeUnlockCountdown({
    super.key,
    required this.unlockAt,
    this.labelStyle,
  });

  @override
  State<VGChallengeUnlockCountdown> createState() => _VGChallengeUnlockCountdownState();
}

class _VGChallengeUnlockCountdownState extends State<VGChallengeUnlockCountdown> {
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  @override
  void didUpdateWidget(covariant VGChallengeUnlockCountdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.unlockAt != widget.unlockAt) _tick();
  }

  void _tick() {
    final now = DateTime.now();
    final remain = widget.unlockAt.difference(now);
    if (!mounted) return;
    setState(() => _remaining = remain.isNegative ? Duration.zero : remain);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_remaining <= Duration.zero) {
      return Text(
        VGCopy.challengeDayReadyNow,
        style: widget.labelStyle ?? boldTextStyle(color: bmSpecialColor, size: 13),
      );
    }
    final h = _remaining.inHours;
    final m = _remaining.inMinutes.remainder(60);
    final s = _remaining.inSeconds.remainder(60);
    final time = '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    return Text(
      '${VGCopy.guideLockedUntil} $time',
      style: widget.labelStyle ?? boldTextStyle(color: bmSpecialColor, size: 13),
    );
  }
}
