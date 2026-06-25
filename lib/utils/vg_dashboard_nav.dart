import 'package:flutter/foundation.dart';

/// Request bottom-nav tab switch from fragments (e.g. Profile quick actions).
final ValueNotifier<int?> vgDashboardTabRequest = ValueNotifier<int?>(null);

void vgRequestDashboardTab(int index) {
  vgDashboardTabRequest.value = index;
}
