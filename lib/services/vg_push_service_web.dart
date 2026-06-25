import 'package:flutter/material.dart';

/// Web stub — FCM push notifications are Android/iOS only for now.
class VGPushService {
  VGPushService._();

  static Future<void> initialize() async {}

  static Future<void> requestPermissionAndSync() async {}

  static Future<void> deactivateCurrentToken() async {}

  static void setPendingDeepLink(String deepLink, {String kind = ''}) {}

  static Future<bool> isReadyForDeepLink() async => false;

  static Future<void> openDeepLink(String deepLink, {String kind = ''}) async {}

  static Future<void> consumePendingDeepLinkIfReady() async {}

  static Future<void> syncTokenIfSignedIn() async {}
}
