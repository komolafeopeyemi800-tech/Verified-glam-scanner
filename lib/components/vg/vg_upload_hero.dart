import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../utils/BMColors.dart';
import '../../utils/vg_assets.dart';
import 'vg_line_art_illustration.dart';

/// Upload-screen hero: portrait on rose scaffold — no extra card or background layer.
class VGUploadHero extends StatefulWidget {
  const VGUploadHero({super.key});

  @override
  State<VGUploadHero> createState() => _VGUploadHeroState();
}

class _VGUploadHeroState extends State<VGUploadHero> {
  bool? _hasPortraitAsset;

  @override
  void initState() {
    super.initState();
    _checkPortrait();
  }

  Future<void> _checkPortrait() async {
    try {
      await rootBundle.load(vgUploadSelfiePortraitAsset);
      if (mounted) setState(() => _hasPortraitAsset = true);
    } catch (_) {
      if (mounted) setState(() => _hasPortraitAsset = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasPortraitAsset == null) {
      return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
    }

    if (_hasPortraitAsset == true) {
      return _portraitHero();
    }

    return _fallbackHero();
  }

  /// Portrait asset only — blends with bmLightScaffoldBackgroundColor (no white card).
  Widget _portraitHero() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Image.asset(
          vgUploadSelfiePortraitAsset,
          fit: BoxFit.contain,
          height: 200,
          errorBuilder: (_, __, ___) => _fallbackHero(),
        ),
      ),
    );
  }

  Widget _fallbackHero() {
    return SizedBox(
      height: 168,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(left: 24, child: _cameraAccent()),
          Positioned(right: 24, child: _cameraAccent()),
          VGLineArtIllustration(motif: VGLineArtMotif.face, size: 140),
        ],
      ),
    );
  }

  Widget _cameraAccent() {
    return Container(
      height: 48,
      width: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: bmPrimaryColor.withValues(alpha: 0.4)),
      ),
      child: Icon(Icons.photo_camera_outlined, color: bmSpecialColor, size: 24),
    );
  }
}
