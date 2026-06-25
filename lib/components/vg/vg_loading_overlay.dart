import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class VGLoadingOverlay extends StatelessWidget {
  final bool visible;
  final String? message;

  const VGLoadingOverlay({super.key, required this.visible, this.message});

  static void show(BuildContext context, {String? message}) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => VGLoadingOverlay(visible: true, message: message),
    );
  }

  static void hide(BuildContext context) {
    if (Navigator.canPop(context)) finish(context);
  }

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Colors.black54,
        elevation: 0,
        insetPadding: EdgeInsets.zero,
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  if (message != null) ...[
                    16.height,
                    Text(message!, style: primaryTextStyle(), textAlign: TextAlign.center),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
