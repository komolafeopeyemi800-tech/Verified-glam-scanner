import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../utils/BMColors.dart';
import '../../utils/vg_constants.dart';
import '../vg_web_breakpoints.dart';
import 'vg_web_header.dart';

/// Split-panel SaaS auth chrome (login / register) — web only.
class VGWebAuthLayout extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget form;
  final String footerPrompt;
  final String footerActionLabel;
  final String footerActionPath;

  const VGWebAuthLayout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.form,
    required this.footerPrompt,
    required this.footerActionLabel,
    required this.footerActionPath,
  });

  @override
  Widget build(BuildContext context) {
    final wide = !VGWebBreakpoints.isCompact(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const VGWebHeader(),
      body: wide ? _WideLayout(
        title: title,
        subtitle: subtitle,
        form: form,
        footerPrompt: footerPrompt,
        footerActionLabel: footerActionLabel,
        footerActionPath: footerActionPath,
      ) : _NarrowLayout(
        title: title,
        subtitle: subtitle,
        form: form,
        footerPrompt: footerPrompt,
        footerActionLabel: footerActionLabel,
        footerActionPath: footerActionPath,
      ),
    );
  }
}

class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF872B3F), Color(0xFFC79A9A)],
        ),
      ),
      padding: const EdgeInsets.all(48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('images/verified_glam_logo.png', height: 56),
          const SizedBox(height: 24),
          Text(
            vgAppName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w800,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            vgTagline,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 17, height: 1.5),
          ),
          const SizedBox(height: 32),
          _brandBullet('Upload a portrait and get AI beauty insights in seconds'),
          _brandBullet('Per-tool landing pages with clear, visual results'),
          _brandBullet('Your burgundy-and-rose brand — polished on desktop'),
        ],
      ),
    );
  }

  Widget _brandBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: TextStyle(color: Colors.white.withValues(alpha: 0.92), height: 1.5)),
          ),
        ],
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget form;
  final String footerPrompt;
  final String footerActionLabel;
  final String footerActionPath;

  const _FormCard({
    required this.title,
    required this.subtitle,
    required this.form,
    required this.footerPrompt,
    required this.footerActionLabel,
    required this.footerActionPath,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: appTextColorPrimary),
              ),
              const SizedBox(height: 8),
              Text(subtitle, style: const TextStyle(fontSize: 15, height: 1.5, color: appTextColorSecondary)),
              const SizedBox(height: 28),
              form,
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(footerPrompt, style: const TextStyle(color: appTextColorSecondary)),
                  TextButton(
                    onPressed: () => context.go(footerActionPath),
                    child: Text(
                      footerActionLabel,
                      style: const TextStyle(fontWeight: FontWeight.w700, color: bmSpecialColor),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WideLayout extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget form;
  final String footerPrompt;
  final String footerActionLabel;
  final String footerActionPath;

  const _WideLayout({
    required this.title,
    required this.subtitle,
    required this.form,
    required this.footerPrompt,
    required this.footerActionLabel,
    required this.footerActionPath,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: _BrandPanel()),
        Expanded(
          child: _FormCard(
            title: title,
            subtitle: subtitle,
            form: form,
            footerPrompt: footerPrompt,
            footerActionLabel: footerActionLabel,
            footerActionPath: footerActionPath,
          ),
        ),
      ],
    );
  }
}

class _NarrowLayout extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget form;
  final String footerPrompt;
  final String footerActionLabel;
  final String footerActionPath;

  const _NarrowLayout({
    required this.title,
    required this.subtitle,
    required this.form,
    required this.footerPrompt,
    required this.footerActionLabel,
    required this.footerActionPath,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 180,
          width: double.infinity,
          child: _BrandPanel(),
        ),
        Expanded(
          child: _FormCard(
            title: title,
            subtitle: subtitle,
            form: form,
            footerPrompt: footerPrompt,
            footerActionLabel: footerActionLabel,
            footerActionPath: footerActionPath,
          ),
        ),
      ],
    );
  }
}

/// Rounded SaaS text field for web auth forms.
class VGWebAuthField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final bool obscure;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final VoidCallback? onSubmitted;
  final Widget? suffix;

  const VGWebAuthField({
    super.key,
    required this.label,
    required this.controller,
    this.focusNode,
    this.obscure = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.onSubmitted,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: appTextColorPrimary),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          focusNode: focusNode,
          obscureText: obscure,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onSubmitted: (_) => onSubmitted?.call(),
          style: const TextStyle(fontSize: 16, color: appTextColorPrimary),
          decoration: InputDecoration(
            filled: true,
            fillColor: bmSecondBackgroundColorLight,
            suffixIcon: suffix,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: bmPrimaryColor.withValues(alpha: 0.35)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: bmPrimaryColor.withValues(alpha: 0.35)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: bmSpecialColor, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class VGWebPrimaryButton extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback? onPressed;

  const VGWebPrimaryButton({
    super.key,
    required this.label,
    this.loading = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: loading ? bmGreyColor : bmSpecialColor,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: loading ? null : onPressed,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 52),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          child: loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Text(
                  label,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
                ),
        ),
      ),
    );
  }
}

class VGWebGoogleButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool loading;

  const VGWebGoogleButton({super.key, this.onPressed, this.loading = false});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: loading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        side: BorderSide(color: bmPrimaryColor.withValues(alpha: 0.45)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      icon: Image.asset('images/google_logo.png', height: 22, width: 22),
      label: const Text(
        'Continue with Google',
        style: TextStyle(fontWeight: FontWeight.w600, color: appTextColorPrimary),
      ),
    );
  }
}
