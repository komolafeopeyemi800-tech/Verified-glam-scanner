import 'package:flutter/material.dart';

class VGFeatureModel {
  final String featureType;
  final String title;
  final String description;
  final IconData icon;
  final String? badge;
  final bool isPro;
  final String? thumbnailAsset;

  const VGFeatureModel({
    required this.featureType,
    required this.title,
    required this.description,
    required this.icon,
    this.badge,
    this.isPro = false,
    this.thumbnailAsset,
  });
}
