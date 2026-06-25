import 'package:flutter/material.dart';

class VGAestheticOption {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final IconData? secondaryIcon;

  const VGAestheticOption({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.secondaryIcon,
  });
}

List<VGAestheticOption> getAestheticOptions() {
  return const [
    VGAestheticOption(
      id: 'effortless',
      title: 'Effortless ease',
      description: 'Light, fresh, and unfussy everyday polish.',
      icon: Icons.spa_outlined,
    ),
    VGAestheticOption(
      id: 'luminous',
      title: 'Luminous classic',
      description: 'Refined features with timeless balance.',
      icon: Icons.auto_awesome_outlined,
    ),
    VGAestheticOption(
      id: 'vivid',
      title: 'Vivid expression',
      description: 'Confident color and creative contrast.',
      icon: Icons.palette_outlined,
      secondaryIcon: Icons.brush_outlined,
    ),
    VGAestheticOption(
      id: 'bare',
      title: 'Bare minimum',
      description: 'Clean, skin-first, less-is-more approach.',
      icon: Icons.water_drop_outlined,
    ),
    VGAestheticOption(
      id: 'polished',
      title: 'Polished poise',
      description: 'Structured, elegant, and camera-ready.',
      icon: Icons.face_retouching_natural,
    ),
    VGAestheticOption(
      id: 'surprise',
      title: 'Surprise me',
      description: 'We will suggest a direction from your features.',
      icon: Icons.stars_outlined,
    ),
  ];
}
