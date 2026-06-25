/// Sets document title and meta description on web (no-op on mobile).
import 'vg_web_seo_stub.dart' if (dart.library.html) 'vg_web_seo_web.dart' as impl;

void vgWebSetPageMeta({required String title, required String description}) {
  impl.vgWebSetPageMetaImpl(title: title, description: description);
}
