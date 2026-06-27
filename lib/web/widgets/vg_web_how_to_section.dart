import 'package:flutter/material.dart';

import '../../utils/BMColors.dart';
import '../content/vg_tool_landing_content.dart';
import '../vg_web_breakpoints.dart';
import 'vg_web_section.dart';

class VGWebHowToSection extends StatelessWidget {
  final List<VGHowToStep> steps;

  const VGWebHowToSection({super.key, required this.steps});

  @override
  Widget build(BuildContext context) {
    final desktop = VGWebBreakpoints.isDesktop(context);

    return VGWebSection(
      background: bmLightScaffoldBackgroundColor,
      child: Column(
        children: [
          const VGWebSectionTitle(
            title: 'How to use',
            subtitle: 'Three simple steps from upload to personalized results.',
          ),
          const SizedBox(height: 40),
          if (desktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < steps.length; i++) ...[
                  if (i > 0) const Expanded(child: _StepConnector()),
                  Expanded(child: _StepCard(index: i + 1, step: steps[i])),
                ],
              ],
            )
          else
            Column(
              children: [
                for (var i = 0; i < steps.length; i++) ...[
                  _StepCard(index: i + 1, step: steps[i]),
                  if (i < steps.length - 1) const SizedBox(height: 16),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _StepConnector extends StatelessWidget {
  const _StepConnector();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 36),
      child: Container(height: 2, color: bmPrimaryColor.withValues(alpha: 0.35)),
    );
  }
}

class _StepCard extends StatelessWidget {
  final int index;
  final VGHowToStep step;

  const _StepCard({required this.index, required this.step});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          alignment: Alignment.center,
          decoration: const BoxDecoration(color: bmSpecialColor, shape: BoxShape.circle),
          child: Text(
            '$index',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          step.title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: appTextColorPrimary),
        ),
        const SizedBox(height: 8),
        Text(
          step.body,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, height: 1.55, color: appTextColorSecondary),
        ),
      ],
    );
  }
}
