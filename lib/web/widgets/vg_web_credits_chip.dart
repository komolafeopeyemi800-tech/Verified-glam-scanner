import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/vg_credits_service.dart';
import '../../utils/BMColors.dart';
import '../../utils/vg_copy.dart';

/// Compact credits indicator for the web app top bar.
class VGWebCreditsChip extends StatefulWidget {
  final bool compact;

  const VGWebCreditsChip({super.key, this.compact = false});

  @override
  State<VGWebCreditsChip> createState() => _VGWebCreditsChipState();
}

class _VGWebCreditsChipState extends State<VGWebCreditsChip> {
  VGCreditSnapshot? _snapshot;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final snapshot = await VGCreditsService.fetchSnapshot();
    if (!mounted) return;
    setState(() => _snapshot = snapshot ?? VGCreditSnapshot.empty);
  }

  void _openProfile() {
    context.go('/app/profile');
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = _snapshot;
    if (snapshot == null) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2, color: bmSpecialColor),
      );
    }

    if (widget.compact) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _openProfile,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: bmSecondBackgroundColorLight,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: bmPrimaryColor.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.monetization_on_outlined, color: bmSpecialColor, size: 16),
                const SizedBox(width: 4),
                Text(
                  '${snapshot.balance}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: bmSpecialColorDark,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _openProfile,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: bmSecondBackgroundColorLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: bmPrimaryColor.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                VGCopy.creditsBalanceTitle(snapshot.balance),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: bmSpecialColorDark,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              if (snapshot.isPro && snapshot.allocated > 0) ...[
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: snapshot.progressFraction,
                    minHeight: 4,
                    backgroundColor: bmPrimaryColor.withValues(alpha: 0.15),
                    color: bmSpecialColor,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
