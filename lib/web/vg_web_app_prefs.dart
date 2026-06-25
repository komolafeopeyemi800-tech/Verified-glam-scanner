import 'package:nb_utils/nb_utils.dart';

import 'vg_feature_slugs.dart';

const String vgLastWebToolSlugKey = 'vg_last_web_tool_slug';

const String vgDefaultWebToolSlug = 'face-beauty-analysis';

String vgWebDefaultAppPath() {
  final last = getStringAsync(vgLastWebToolSlugKey);
  if (last.isNotEmpty && isToolSlug(last)) {
    return '/app/$last';
  }
  return '/app/$vgDefaultWebToolSlug';
}

Future<void> vgSaveLastWebToolSlug(String slug) async {
  if (isToolSlug(slug)) {
    await setValue(vgLastWebToolSlugKey, slug);
  }
}
