import '../../utils/vg_constants.dart';
import 'content/vg_home_landing_content.dart';
import 'content/vg_tool_landing_content.dart';

/// Default Open Graph image for scanner.verifiedglam.com.
String get vgWebDefaultOgImage => '$vgMarketingSiteUrl/icons/Icon-512.png';

String vgWebCanonicalUrl(String path) {
  if (path.isEmpty || path == '/') return '$vgMarketingSiteUrl/';
  return '$vgMarketingSiteUrl$path';
}

List<Map<String, dynamic>> vgSeoHomeJsonLd() {
  final site = vgMarketingSiteUrl;
  return [
    {
      '@context': 'https://schema.org',
      '@type': 'Organization',
      'name': vgWebProductName,
      'url': site,
      'logo': '$site/icons/Icon-512.png',
      'email': vgLegalSupportEmail,
      'parentOrganization': {
        '@type': 'Organization',
        'name': 'Verified Glam',
        'url': vgParentCompanyUrl,
      },
    },
    {
      '@context': 'https://schema.org',
      '@type': 'WebSite',
      'name': vgWebProductName,
      'url': site,
      'description': VGHomeLandingContent.metaDescription,
    },
    {
      '@context': 'https://schema.org',
      '@type': 'SoftwareApplication',
      'name': vgWebProductName,
      'applicationCategory': 'LifestyleApplication',
      'operatingSystem': 'Android',
      'offers': {
        '@type': 'Offer',
        'price': '0',
        'priceCurrency': 'USD',
      },
      'url': site,
    },
    vgSeoFaqJsonLd(VGHomeLandingContent.faqs),
  ];
}

Map<String, dynamic> vgSeoFaqJsonLd(List<VGFaqItem> faqs) {
  return {
    '@context': 'https://schema.org',
    '@type': 'FAQPage',
    'mainEntity': faqs
        .map(
          (f) => {
            '@type': 'Question',
            'name': f.question,
            'acceptedAnswer': {
              '@type': 'Answer',
              'text': f.answer,
            },
          },
        )
        .toList(),
  };
}

List<Map<String, dynamic>> vgSeoWebPageJsonLd({
  required String name,
  required String description,
  required String path,
}) {
  return [
    {
      '@context': 'https://schema.org',
      '@type': 'WebPage',
      'name': name,
      'description': description,
      'url': vgWebCanonicalUrl(path),
    },
    vgSeoBreadcrumbJsonLd([
      ('Home', '/'),
      (name, path),
    ]),
  ];
}

Map<String, dynamic> vgSeoBreadcrumbJsonLd(List<(String, String)> items) {
  return {
    '@context': 'https://schema.org',
    '@type': 'BreadcrumbList',
    'itemListElement': [
      for (var i = 0; i < items.length; i++)
        {
          '@type': 'ListItem',
          'position': i + 1,
          'name': items[i].$1,
          'item': vgWebCanonicalUrl(items[i].$2),
        },
    ],
  };
}

List<Map<String, dynamic>> vgSeoToolPageJsonLd(VGToolLandingContent content) {
  final path = '/${content.slug}';
  return [
    {
      '@context': 'https://schema.org',
      '@type': 'WebPage',
      'name': content.pageTitle,
      'description': content.metaDescription,
      'url': vgWebCanonicalUrl(path),
    },
    {
      '@context': 'https://schema.org',
      '@type': 'Service',
      'name': content.headline,
      'description': content.subheadline,
      'provider': {
        '@type': 'Organization',
        'name': vgWebProductName,
        'url': vgMarketingSiteUrl,
      },
      'url': vgWebCanonicalUrl(path),
    },
    vgSeoBreadcrumbJsonLd([
      ('Home', '/'),
      ('AI Tools', '/tools'),
      (content.headline, path),
    ]),
    if (content.faqs.isNotEmpty) vgSeoFaqJsonLd(content.faqs),
  ];
}

List<Map<String, dynamic>> vgSeoToolsIndexJsonLd() {
  return [
    {
      '@context': 'https://schema.org',
      '@type': 'CollectionPage',
      'name': 'AI Beauty Tools — Verified Glam Scanner',
      'description':
          'Browse AI beauty scan tools: face beauty analysis, symmetry, celebrity look-alike, color palette, and more.',
      'url': vgWebCanonicalUrl('/tools'),
    },
    vgSeoBreadcrumbJsonLd([
      ('Home', '/'),
      ('AI Tools', '/tools'),
    ]),
  ];
}

List<Map<String, dynamic>> vgSeoPricingJsonLd() {
  return [
    ...vgSeoWebPageJsonLd(
      name: 'Verified Glam Scanner Pricing',
      description:
          'Yearly and Pro weekly plans for Verified Glam Scanner. Free tier with optional upgrade for full scans and no ads.',
      path: '/pricing',
    ),
    {
      '@context': 'https://schema.org',
      '@type': 'Product',
      'name': 'Verified Glam Scanner Pro',
      'description': 'Pro subscription — all scan types, no ads, unlimited history.',
      'brand': {'@type': 'Brand', 'name': vgWebProductName},
      'offers': [
        {
          '@type': 'Offer',
          'name': 'Yearly',
          'price': '39.99',
          'priceCurrency': 'USD',
          'url': vgWebCanonicalUrl('/pricing'),
        },
        {
          '@type': 'Offer',
          'name': 'Pro Weekly',
          'price': '3.99',
          'priceCurrency': 'USD',
          'url': vgWebCanonicalUrl('/pricing'),
        },
      ],
    },
  ];
}
