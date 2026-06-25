import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/vg_feature_model.dart';
import '../../utils/BMColors.dart';
import '../../utils/vg_navigation.dart';

/// Hero upload card — drag-style CTA that starts the scan pipeline on web.
class VGWebUploadCard extends StatefulWidget {
  final VGFeatureModel feature;
  final String buttonLabel;

  const VGWebUploadCard({
    super.key,
    required this.feature,
    this.buttonLabel = 'Upload image',
  });

  @override
  State<VGWebUploadCard> createState() => _VGWebUploadCardState();
}

class _VGWebUploadCardState extends State<VGWebUploadCard> {
  final ImagePicker _picker = ImagePicker();
  bool _busy = false;

  Future<void> _startUpload() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await vgStartAnalysis(context, widget.feature);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pickFile() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 90,
      );
      if (file == null || !mounted) return;
      await vgStartAnalysis(context, widget.feature);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: bmLightScaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: bmPrimaryColor.withValues(alpha: 0.45), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: bmSpecialColor.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.cloud_upload_outlined, size: 48, color: bmSpecialColor.withValues(alpha: 0.85)),
          const SizedBox(height: 16),
          const Text(
            'Drag & drop or click to upload',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: appTextColorPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            widget.feature.title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: appTextColorSecondary, height: 1.5),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: Material(
              color: _busy ? bmGreyColor : bmSpecialColor,
              borderRadius: BorderRadius.circular(999),
              child: InkWell(
                onTap: _busy ? null : _pickFile,
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  constraints: const BoxConstraints(minHeight: 52),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  child: _busy
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          widget.buttonLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _busy ? null : _startUpload,
            child: const Text('View photo tips first', style: TextStyle(color: bmSpecialColor)),
          ),
        ],
      ),
    );
  }
}
