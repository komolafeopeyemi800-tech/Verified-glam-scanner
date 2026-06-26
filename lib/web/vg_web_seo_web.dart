import 'dart:convert';

import 'dart:html' as html;

import '../../utils/vg_constants.dart';
import 'vg_web_seo_schema.dart';

void vgWebSetPageMetaImpl({
  required String title,
  required String description,
  String? canonicalPath,
  String? ogImage,
  String ogType = 'website',
  List<Map<String, dynamic>>? jsonLd,
}) {
  html.document.title = title;

  _setMetaName('description', description);

  final canonical = canonicalPath != null ? vgWebCanonicalUrl(canonicalPath) : null;
  if (canonical != null) {
    _setLinkRel('canonical', canonical);
  }

  final image = ogImage ?? vgWebDefaultOgImage;
  final pageUrl = canonical ?? vgMarketingSiteUrl;

  _setMetaProperty('og:title', title);
  _setMetaProperty('og:description', description);
  _setMetaProperty('og:type', ogType);
  _setMetaProperty('og:url', pageUrl);
  _setMetaProperty('og:image', image);
  _setMetaProperty('og:site_name', vgWebProductName);

  _setMetaName('twitter:card', 'summary_large_image');
  _setMetaName('twitter:title', title);
  _setMetaName('twitter:description', description);
  _setMetaName('twitter:image', image);

  if (jsonLd != null && jsonLd.isNotEmpty) {
    _setJsonLd(jsonLd);
  }
}

void _setMetaName(String name, String content) {
  var meta = html.document.querySelector('meta[name="$name"]') as html.MetaElement?;
  if (meta == null) {
    meta = html.MetaElement()..name = name;
    html.document.head?.append(meta);
  }
  meta.content = content;
}

void _setMetaProperty(String property, String content) {
  var meta = html.document.querySelector('meta[property="$property"]') as html.MetaElement?;
  if (meta == null) {
    meta = html.MetaElement()..setAttribute('property', property);
    html.document.head?.append(meta);
  }
  meta.content = content;
}

void _setLinkRel(String rel, String href) {
  var link = html.document.querySelector('link[rel="$rel"]') as html.LinkElement?;
  if (link == null) {
    link = html.LinkElement()..rel = rel;
    html.document.head?.append(link);
  }
  link.href = href;
}

void _setJsonLd(List<Map<String, dynamic>> graphs) {
  const id = 'vg-json-ld';
  html.document.querySelector('#$id')?.remove();
  final script = html.ScriptElement()
    ..id = id
    ..type = 'application/ld+json'
    ..text = jsonEncode(graphs.length == 1 ? graphs.first : graphs);
  html.document.head?.append(script);
}
