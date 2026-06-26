// Sets document title, meta, Open Graph, Twitter, and JSON-LD on web (no-op on mobile).
import 'vg_web_seo_stub.dart' if (dart.library.html) 'vg_web_seo_web.dart' as impl;

void vgWebSetPageMeta({
  required String title,
  required String description,
  String? canonicalPath,
  String? ogImage,
  String ogType = 'website',
  List<Map<String, dynamic>>? jsonLd,
}) {
  impl.vgWebSetPageMetaImpl(
    title: title,
    description: description,
    canonicalPath: canonicalPath,
    ogImage: ogImage,
    ogType: ogType,
    jsonLd: jsonLd,
  );
}
