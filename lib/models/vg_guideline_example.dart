class VGGuidelineExample {
  final String assetPath;
  final bool isGood;
  final String caption;

  const VGGuidelineExample({
    required this.assetPath,
    required this.isGood,
    required this.caption,
  });
}

List<VGGuidelineExample> getGoodGuidelineExamples() {
  return const [
    VGGuidelineExample(
      assetPath: 'images/vg/guidelines/good_front_light.jpg',
      isGood: true,
      caption: 'Even lighting',
    ),
    VGGuidelineExample(
      assetPath: 'images/vg/guidelines/good_natural_daylight.jpg',
      isGood: true,
      caption: 'Natural daylight',
    ),
    VGGuidelineExample(
      assetPath: 'images/vg/guidelines/good_clear_skin.jpg',
      isGood: true,
      caption: 'Clear framing',
    ),
  ];
}

List<VGGuidelineExample> getBadGuidelineExamples() {
  return const [
    VGGuidelineExample(
      assetPath: 'images/vg/guidelines/bad_filter.jpg',
      isGood: false,
      caption: 'Heavy filter',
    ),
    VGGuidelineExample(
      assetPath: 'images/vg/guidelines/bad_hat_glasses.jpg',
      isGood: false,
      caption: 'Face obscured',
    ),
    VGGuidelineExample(
      assetPath: 'images/vg/guidelines/bad_poor_light.jpg',
      isGood: false,
      caption: 'Poor lighting',
    ),
  ];
}
