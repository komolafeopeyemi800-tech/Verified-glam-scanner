import 'dart:html' as html;

void vgWebSetPageMetaImpl({required String title, required String description}) {
  html.document.title = title;

  var meta = html.document.querySelector('meta[name="description"]') as html.MetaElement?;
  if (meta == null) {
    meta = html.MetaElement()..name = 'description';
    html.document.head?.append(meta);
  }
  meta.content = description;
}
