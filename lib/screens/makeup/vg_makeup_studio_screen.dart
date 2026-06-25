import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/vg/makeup/vg_makeup_controls_panel.dart';
import '../../components/vg/makeup/vg_makeup_preview.dart';
import '../../models/vg_makeup_state.dart';
import '../../utils/BMColors.dart';
import '../../utils/vg_copy.dart';
import '../../utils/vg_makeup_regions.dart';

class VGMakeupStudioScreen extends StatefulWidget {
  final String photoPath;
  final List<String> paletteHex;
  final String? seasonLabel;

  const VGMakeupStudioScreen({
    super.key,
    required this.photoPath,
    this.paletteHex = const [],
    this.seasonLabel,
  });

  @override
  State<VGMakeupStudioScreen> createState() => _VGMakeupStudioScreenState();
}

class _VGMakeupStudioScreenState extends State<VGMakeupStudioScreen> {
  VGMakeupState? _state;
  Size _previewSize = const Size(280, 373);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final previewSize = vgMakeupPreviewSize(context.width());
    final regions = await vgMakeupRegionsFromPhoto(widget.photoPath, previewSize);
    if (!mounted) return;
    setState(() {
      _previewSize = previewSize;
      _state = VGMakeupState(regions: regions);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bmLightScaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: bmSpecialColor,
        foregroundColor: Colors.white,
        title: Text(
          widget.seasonLabel != null
              ? '${VGCopy.makeupStudioTitle} · ${widget.seasonLabel}'
              : VGCopy.makeupStudioTitle,
          style: boldTextStyle(color: Colors.white, size: 16),
        ),
      ),
      body: _state == null
          ? Center(child: CircularProgressIndicator(color: bmSpecialColor))
          : Column(
              children: [
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      child: VGMakeupPreview(
                        photoPath: widget.photoPath,
                        previewSize: _previewSize,
                        state: _state!,
                        onReset: () => setState(() => _state = _state!.resetAll()),
                      ),
                    ),
                  ),
                ),
                VGMakeupControlsPanel(
                  state: _state!,
                  seasonPaletteHex: widget.paletteHex,
                  onStateChanged: (s) => setState(() => _state = s),
                ),
              ],
            ),
    );
  }
}
