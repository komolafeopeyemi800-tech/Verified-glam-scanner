import 'dart:convert';

class VGScanResult {
  final String id;
  final String featureType;
  final String featureTitle;
  final DateTime createdAt;
  final Map<String, dynamic> payload;
  final String? photoPath;
  final String? storagePath;
  final bool usedMockAnalysis;

  VGScanResult({
    required this.id,
    required this.featureType,
    required this.featureTitle,
    required this.createdAt,
    required this.payload,
    this.photoPath,
    this.storagePath,
    this.usedMockAnalysis = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'featureType': featureType,
        'featureTitle': featureTitle,
        'createdAt': createdAt.toIso8601String(),
        'payload': payload,
        if (photoPath != null) 'photoPath': photoPath,
        if (storagePath != null) 'storagePath': storagePath,
        'usedMockAnalysis': usedMockAnalysis,
      };

  factory VGScanResult.fromJson(Map<String, dynamic> json) {
    return VGScanResult(
      id: json['id'] as String,
      featureType: json['featureType'] as String,
      featureTitle: json['featureTitle'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      payload: Map<String, dynamic>.from(json['payload'] as Map),
      photoPath: json['photoPath'] as String?,
      storagePath: json['storagePath'] as String?,
      usedMockAnalysis: json['usedMockAnalysis'] as bool? ?? false,
    );
  }

  VGScanResult copyWith({
    String? id,
    String? featureType,
    String? featureTitle,
    DateTime? createdAt,
    Map<String, dynamic>? payload,
    String? photoPath,
    String? storagePath,
    bool? usedMockAnalysis,
  }) {
    return VGScanResult(
      id: id ?? this.id,
      featureType: featureType ?? this.featureType,
      featureTitle: featureTitle ?? this.featureTitle,
      createdAt: createdAt ?? this.createdAt,
      payload: payload ?? this.payload,
      photoPath: photoPath ?? this.photoPath,
      storagePath: storagePath ?? this.storagePath,
      usedMockAnalysis: usedMockAnalysis ?? this.usedMockAnalysis,
    );
  }

  static VGScanResult fromJsonString(String raw) {
    return VGScanResult.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  String toJsonString() => jsonEncode(toJson());
}
