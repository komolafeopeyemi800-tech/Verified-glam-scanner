import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/vg/vg_aesthetic_card.dart';
import '../../components/vg/vg_onboarding_scaffold.dart';
import '../../components/vg/vg_pill_button.dart';
import '../../components/vg/vg_selection_row.dart';
import '../../models/vg_aesthetic_option.dart';
import '../../models/vg_onboarding_profile.dart';
import '../../screens/BMEnableNotificationScreen.dart';
import '../../services/vg_onboarding_store.dart';
import '../../utils/BMColors.dart';
import '../../utils/vg_copy.dart';
import '../../web/vg_web_app_prefs.dart';
import '../../web/vg_web_auth_helpers.dart';
import '../../web/widgets/vg_web_onboarding_shell.dart';

class VGOnboardingFlow extends StatefulWidget {
  const VGOnboardingFlow({super.key});

  @override
  State<VGOnboardingFlow> createState() => _VGOnboardingFlowState();
}

class _VGOnboardingFlowState extends State<VGOnboardingFlow> {
  static const _totalSteps = 10;
  int _step = 0;
  late VGOnboardingProfile _profile;

  @override
  void initState() {
    super.initState();
    _profile = VGOnboardingProfile(age: 24);
    _loadExisting();
  }

  Future<void> _loadExisting() async {
    final saved = await VGOnboardingStore.loadProfile();
    if (saved.age != null || saved.gender != null) {
      setState(() => _profile = saved);
    }
  }

  void _next() {
    if (_step < _totalSteps - 1) {
      setState(() => _step++);
      VGOnboardingStore.saveProfile(_profile);
    } else {
      _finish();
    }
  }

  void _back() {
    if (_step == 0) {
      finish(context);
    } else {
      setState(() => _step--);
    }
  }

  Future<void> _finish() async {
    await VGOnboardingStore.markComplete(_profile);
    if (!mounted) return;
    if (kIsWeb) {
      final target = await vgTakePostAuthRedirect();
      context.go(target ?? vgWebDefaultAppPath());
      return;
    }
    BMEnableNotificationScreen().launch(context, isNewTask: true);
  }

  bool get _canContinue {
    switch (_step) {
      case 0:
        return _profile.age != null && _profile.age! >= 13;
      case 1:
        return _profile.gender != null && _profile.gender!.isNotEmpty;
      case 2:
        return _profile.beautyGoals.isNotEmpty;
      case 3:
        return _profile.skinConcerns.isNotEmpty;
      case 4:
        return _profile.productPreferences.isNotEmpty;
      case 5:
        return _profile.skinType != null;
      case 6:
        return _profile.ethnicity != null;
      case 7:
        return _profile.aesthetic != null;
      case 8:
        return true;
      case 9:
        return true;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = _buildStepContent();
    if (kIsWeb) {
      return VGWebOnboardingShell(
        stepIndex: _step,
        totalSteps: _totalSteps,
        child: step,
      );
    }
    return step;
  }

  Widget _buildStepContent() {
    switch (_step) {
      case 0:
        return VGOnboardingScaffold(
          stepIndex: _step,
          totalSteps: _totalSteps,
          title: VGCopy.onboardingAgeTitle,
          subtitle: VGCopy.onboardingAgeSubtitle,
          primaryLabel: VGCopy.continueLabel,
          primaryEnabled: _canContinue,
          onPrimary: _next,
          onBack: _back,
          body: Column(
            children: [
              Slider(
                value: (_profile.age ?? 24).toDouble(),
                min: 16,
                max: 65,
                divisions: 49,
                activeColor: bmSpecialColor,
                label: '${_profile.age ?? 24}',
                onChanged: (v) => setState(() => _profile = _profile.copyWith(age: v.round())),
              ),
              Text('${_profile.age ?? 24} years old', style: boldTextStyle(color: bmSpecialColor, size: 18)).center(),
            ],
          ),
        );
      case 1:
        return VGOnboardingScaffold(
          stepIndex: _step,
          totalSteps: _totalSteps,
          title: VGCopy.onboardingGenderTitle,
          subtitle: VGCopy.onboardingGenderSubtitle,
          primaryLabel: VGCopy.continueLabel,
          primaryEnabled: _canContinue,
          onPrimary: _next,
          onBack: _back,
          body: Column(
            children: VGCopy.genders
                .map(
                  (g) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: VGPillButton(
                      label: g,
                      outline: _profile.gender != g,
                      onTap: () => setState(() => _profile = _profile.copyWith(gender: g)),
                    ),
                  ),
                )
                .toList(),
          ),
        );
      case 2:
        return _multiSelectStep(
          title: VGCopy.onboardingGoalsTitle,
          subtitle: VGCopy.onboardingGoalsSubtitle,
          options: VGCopy.beautyGoals,
          selected: _profile.beautyGoals,
          onChanged: (list) => setState(() => _profile = _profile.copyWith(beautyGoals: list)),
        );
      case 3:
        return _multiSelectStep(
          title: VGCopy.onboardingConcernsTitle,
          subtitle: VGCopy.onboardingConcernsSubtitle,
          options: VGCopy.skinConcerns,
          selected: _profile.skinConcerns,
          onChanged: (list) => setState(() => _profile = _profile.copyWith(skinConcerns: list)),
        );
      case 4:
        return _multiSelectStep(
          title: VGCopy.onboardingProductsTitle,
          subtitle: VGCopy.onboardingProductsSubtitle,
          options: VGCopy.productPrefs,
          selected: _profile.productPreferences,
          onChanged: (list) => setState(() => _profile = _profile.copyWith(productPreferences: list)),
        );
      case 5:
        return _singleSelectStep(
          title: VGCopy.onboardingSkinTypeTitle,
          subtitle: VGCopy.onboardingSkinTypeSubtitle,
          options: VGCopy.skinTypes,
          selected: _profile.skinType,
          onSelect: (v) => setState(() => _profile = _profile.copyWith(skinType: v)),
        );
      case 6:
        return _singleSelectStep(
          title: VGCopy.onboardingEthnicityTitle,
          subtitle: VGCopy.onboardingEthnicitySubtitle,
          options: VGCopy.ethnicities,
          selected: _profile.ethnicity,
          onSelect: (v) => setState(() => _profile = _profile.copyWith(ethnicity: v)),
        );
      case 7:
        return _AestheticStep(
          step: _step,
          totalSteps: _totalSteps,
          selectedId: _profile.aesthetic,
          onSelect: (title) => setState(() => _profile = _profile.copyWith(aesthetic: title)),
          onBack: _back,
          onNext: _next,
          canContinue: _canContinue,
        );
      case 8:
        return VGOnboardingScaffold(
          stepIndex: _step,
          totalSteps: _totalSteps,
          title: VGCopy.ratingTitle,
          subtitle: VGCopy.ratingSubtitle,
          primaryLabel: VGCopy.ratingCta,
          primaryEnabled: true,
          onPrimary: _next,
          onBack: _back,
          body: Column(
            children: [
              Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(color: bmLightScaffoldBackgroundColor, shape: BoxShape.circle),
                child: Icon(Icons.thumb_up_alt_outlined, size: 52, color: bmSpecialColor),
              ).center(),
              16.height,
              Text(VGCopy.ratingSkip, style: boldTextStyle(color: bmGreyColor, size: 14)).center().onTap(_next),
            ],
          ),
        );
      case 9:
        return VGOnboardingScaffold(
          stepIndex: _step,
          totalSteps: _totalSteps,
          title: VGCopy.onboardingSummaryTitle,
          subtitle: VGCopy.onboardingSummarySubtitle,
          primaryLabel: VGCopy.finishLabel,
          primaryEnabled: true,
          onPrimary: _next,
          onBack: _back,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_profile.gender != null) _summaryRow('Gender', _profile.gender!),
              if (_profile.skinType != null) _summaryRow('Skin type', _profile.skinType!),
              if (_profile.aesthetic != null) _summaryRow('Style', _profile.aesthetic!),
              _summaryRow('Goals', '${_profile.beautyGoals.length} selected'),
              _summaryRow('Concerns', '${_profile.skinConcerns.length} selected'),
            ],
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _multiSelectStep({
    required String title,
    required String subtitle,
    required List<String> options,
    required List<String> selected,
    required ValueChanged<List<String>> onChanged,
  }) {
    return VGOnboardingScaffold(
      stepIndex: _step,
      totalSteps: _totalSteps,
      title: title,
      subtitle: subtitle,
      primaryLabel: VGCopy.continueLabel,
      primaryEnabled: _canContinue,
      onPrimary: _next,
      onBack: _back,
      body: Column(
        children: options.map((option) {
          final isSelected = selected.contains(option);
          return VGSelectionRow(
            label: option,
            selected: isSelected,
            onTap: () {
              final next = List<String>.from(selected);
              if (isSelected) {
                next.remove(option);
              } else {
                next.add(option);
              }
              onChanged(next);
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _singleSelectStep({
    required String title,
    required String subtitle,
    required List<String> options,
    required String? selected,
    required ValueChanged<String> onSelect,
  }) {
    return VGOnboardingScaffold(
      stepIndex: _step,
      totalSteps: _totalSteps,
      title: title,
      subtitle: subtitle,
      primaryLabel: VGCopy.continueLabel,
      primaryEnabled: _canContinue,
      onPrimary: _next,
      onBack: _back,
      body: Column(
        children: options.map((option) {
          return VGSelectionRow(
            label: option,
            selected: selected == option,
            onTap: () => onSelect(option),
          );
        }).toList(),
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: secondaryTextStyle(color: appTextColorSecondary)),
          Flexible(child: Text(value, style: boldTextStyle(color: appTextColorPrimary, size: 14), textAlign: TextAlign.end)),
        ],
      ),
    );
  }
}

class _AestheticStep extends StatefulWidget {
  final int step;
  final int totalSteps;
  final String? selectedId;
  final ValueChanged<String> onSelect;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final bool canContinue;

  const _AestheticStep({
    required this.step,
    required this.totalSteps,
    required this.selectedId,
    required this.onSelect,
    required this.onBack,
    required this.onNext,
    required this.canContinue,
  });

  @override
  State<_AestheticStep> createState() => _AestheticStepState();
}

class _AestheticStepState extends State<_AestheticStep> {
  final PageController _controller = PageController(viewportFraction: 0.82);
  int _index = 0;
  final _options = getAestheticOptions();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VGOnboardingScaffold(
      stepIndex: widget.step,
      totalSteps: widget.totalSteps,
      title: VGCopy.onboardingAestheticTitle,
      subtitle: VGCopy.onboardingAestheticSubtitle,
      primaryLabel: VGCopy.continueLabel,
      primaryEnabled: widget.canContinue,
      onPrimary: widget.onNext,
      onBack: widget.onBack,
      body: Column(
        children: [
          SizedBox(
            height: 340,
            child: PageView.builder(
              controller: _controller,
              itemCount: _options.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (context, i) {
                final option = _options[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: VGAestheticCard(
                    option: option,
                    selected: widget.selectedId == option.title,
                    onTap: () => widget.onSelect(option.title),
                  ),
                );
              },
            ),
          ),
          12.height,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_options.length, (i) {
              final active = i == _index;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 8,
                width: active ? 20 : 8,
                decoration: BoxDecoration(
                  color: active ? bmSpecialColor : bmPrimaryColor.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(999),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
