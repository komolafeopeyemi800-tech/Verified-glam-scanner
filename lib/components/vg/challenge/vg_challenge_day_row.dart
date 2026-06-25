import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../models/vg_challenge_day.dart';
import '../../../utils/BMColors.dart';
enum VGChallengeDayRowState { completed, active, locked, upcoming }

class VGChallengeDayRow extends StatelessWidget {
  final VGChallengeDay day;
  final VGChallengeDayRowState state;
  final VoidCallback? onTap;

  const VGChallengeDayRow({
    super.key,
    required this.day,
    required this.state,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final canTap = state == VGChallengeDayRowState.active || state == VGChallengeDayRowState.completed;
    final opacity = state == VGChallengeDayRowState.locked ? 0.55 : 1.0;

    return Opacity(
      opacity: opacity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: canTap ? onTap : null,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: state == VGChallengeDayRowState.active
                    ? bmSpecialColor
                    : state == VGChallengeDayRowState.completed
                        ? const Color(0xFF81C784)
                        : bmPrimaryColor.withValues(alpha: 0.35),
                width: state == VGChallengeDayRowState.active ? 2 : 1,
              ),
              boxShadow: state == VGChallengeDayRowState.active
                  ? [
                      BoxShadow(
                        color: bmSpecialColor.withValues(alpha: 0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                _DayCircle(dayNumber: day.dayNumber, state: state),
                12.width,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(day.title, style: boldTextStyle(size: 14)),
                      4.height,
                      Text(
                        day.mainTask,
                        style: secondaryTextStyle(size: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                8.width,
                _StatusIcon(state: state),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DayCircle extends StatelessWidget {
  final int dayNumber;
  final VGChallengeDayRowState state;

  const _DayCircle({required this.dayNumber, required this.state});

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    switch (state) {
      case VGChallengeDayRowState.completed:
        bg = const Color(0xFFD1FAE5);
        fg = const Color(0xFF059669);
      case VGChallengeDayRowState.active:
        bg = bmSpecialColor;
        fg = Colors.white;
      case VGChallengeDayRowState.locked:
      case VGChallengeDayRowState.upcoming:
        bg = bmLightScaffoldBackgroundColor;
        fg = bmGreyColor;
    }

    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Text('$dayNumber', style: boldTextStyle(color: fg, size: 14)),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  final VGChallengeDayRowState state;

  const _StatusIcon({required this.state});

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case VGChallengeDayRowState.completed:
        return const Icon(Icons.check_circle, color: Color(0xFF059669), size: 22);
      case VGChallengeDayRowState.active:
        return Icon(Icons.arrow_forward_ios, color: bmSpecialColor, size: 16);
      case VGChallengeDayRowState.locked:
        return Icon(Icons.lock_outline, color: bmGreyColor, size: 20);
      case VGChallengeDayRowState.upcoming:
        return Icon(Icons.schedule, color: bmGreyColor, size: 20);
    }
  }
}
