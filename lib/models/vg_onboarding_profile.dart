import 'dart:convert';

class VGOnboardingProfile {
  int? age;
  String? gender;
  List<String> beautyGoals;
  List<String> skinConcerns;
  List<String> productPreferences;
  String? skinType;
  String? ethnicity;
  String? aesthetic;

  VGOnboardingProfile({
    this.age,
    this.gender,
    this.beautyGoals = const [],
    this.skinConcerns = const [],
    this.productPreferences = const [],
    this.skinType,
    this.ethnicity,
    this.aesthetic,
  });

  VGOnboardingProfile copyWith({
    int? age,
    String? gender,
    List<String>? beautyGoals,
    List<String>? skinConcerns,
    List<String>? productPreferences,
    String? skinType,
    String? ethnicity,
    String? aesthetic,
  }) {
    return VGOnboardingProfile(
      age: age ?? this.age,
      gender: gender ?? this.gender,
      beautyGoals: beautyGoals ?? this.beautyGoals,
      skinConcerns: skinConcerns ?? this.skinConcerns,
      productPreferences: productPreferences ?? this.productPreferences,
      skinType: skinType ?? this.skinType,
      ethnicity: ethnicity ?? this.ethnicity,
      aesthetic: aesthetic ?? this.aesthetic,
    );
  }

  Map<String, dynamic> toJson() => {
        'age': age,
        'gender': gender,
        'beautyGoals': beautyGoals,
        'skinConcerns': skinConcerns,
        'productPreferences': productPreferences,
        'skinType': skinType,
        'ethnicity': ethnicity,
        'aesthetic': aesthetic,
      };

  factory VGOnboardingProfile.fromJson(Map<String, dynamic> json) {
    return VGOnboardingProfile(
      age: json['age'] as int?,
      gender: json['gender'] as String?,
      beautyGoals: List<String>.from(json['beautyGoals'] ?? []),
      skinConcerns: List<String>.from(json['skinConcerns'] ?? []),
      productPreferences: List<String>.from(json['productPreferences'] ?? []),
      skinType: json['skinType'] as String?,
      ethnicity: json['ethnicity'] as String?,
      aesthetic: json['aesthetic'] as String?,
    );
  }

  static VGOnboardingProfile fromJsonString(String raw) {
    return VGOnboardingProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  String toJsonString() => jsonEncode(toJson());
}
