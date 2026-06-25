import 'package:connectivity_plus/connectivity_plus.dart';

class VGConnectivityService {
  VGConnectivityService._();

  static Future<bool> isOnline() async {
    final results = await Connectivity().checkConnectivity();
    if (results.isEmpty) return false;
    return results.any((r) => r != ConnectivityResult.none);
  }
}
