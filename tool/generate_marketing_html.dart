// ignore_for_file: avoid_print
/// Generates static marketing HTML from Dart content (no UI redesign — homepage chrome only).
///
/// Run: dart run tool/generate_marketing_html.dart
import 'dart:convert';
import 'dart:io';

import '../lib/web/content/vg_legal_content.dart';
import '../lib/web/content/vg_tool_landing_content.dart';

const _siteUrl = 'https://scanner.verifiedglam.com';
const _productName = 'Verified Glam Scanner';

const _allToolSlugs = [
  'face-beauty-analysis',
  'seasonal-color-palette',
  'beauty-routine-challenge',
  'beauty-tips',
  'celebrity-look-alike',
  'facial-symmetry',
  'beauty-score-showdown',
  'face-comparison',
  'attractiveness-test',
  'face-golden-ratio',
];

void main() {
  if (!File('pubspec.yaml').existsSync()) {
    stderr.writeln('Run from repo root.');
    exit(1);
  }

  final partialsDir = Directory('website/partials');
  final header = _readFile(partialsDir.path + Platform.pathSeparator + 'site-header.html');
  final footer = _readFile(partialsDir.path + Platform.pathSeparator + 'site-footer.html');
  final outRoot = Directory('website/generated')..createSync(recursive: true);

  for (final slug in _allToolSlugs) {
    final content = landingContentForSlug(slug);
    if (content == null) continue;
    _writePage(
      path: '${outRoot.path}${Platform.pathSeparator}$slug${Platform.pathSeparator}index.html',
      header: header,
      footer: footer,
      title: content.pageTitle,
      description: content.metaDescription,
      canonicalPath: '/$slug',
      jsonLd: _toolJsonLd(content),
      body: _toolBody(content),
    );
  }

  _writePage(
    path: '${outRoot.path}${Platform.pathSeparator}tools${Platform.pathSeparator}index.html',
    header: header,
    footer: footer,
    title: 'AI Beauty Tools — Verified Glam Scanner',
    description:
        'Browse AI beauty scan tools: face beauty analysis, symmetry, celebrity look-alike, seasonal color palette, and more.',
    canonicalPath: '/tools',
    jsonLd: _toolsIndexJsonLd(),
    body: _toolsIndexBody(),
  );

  _writePage(
    path: '${outRoot.path}${Platform.pathSeparator}pricing${Platform.pathSeparator}index.html',
    header: header,
    footer: footer,
    title: 'Verified Glam Pricing — Yearly & Pro Plans',
    description:
        'Verified Glam Pro: Yearly \$39.99/year (was \$80.99) or Pro \$3.99/week with a 3-day free trial. All AI beauty analyses, ad-free.',
    canonicalPath: '/pricing',
    jsonLd: _pricingJsonLd(),
    body: _pricingBody(),
  );

  _writeLegalPages(outRoot, header, footer);
  _writeAuthTemplate(outRoot, header, footer, login: true);
  _writeAuthTemplate(outRoot, header, footer, login: false);

  print('Generated static pages under website/generated/');
}

String _readFile(String path) {
  final f = File(path);
  if (!f.existsSync()) {
    stderr.writeln('Missing partial: $path');
    exit(1);
  }
  return f.readAsStringSync();
}

void _writePage({
  required String path,
  required String header,
  required String footer,
  required String title,
  required String description,
  required String canonicalPath,
  required List<Map<String, dynamic>> jsonLd,
  required String body,
}) {
  final canonical = _canonicalUrl(canonicalPath);
  final ogImage = '$_siteUrl/icons/Icon-512.png';
  final jsonLdScript = jsonLd
      .map((m) => '<script type="application/ld+json">${jsonEncode(m)}</script>')
      .join('\n  ');

  final html = '''<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${_esc(title)}</title>
  <meta name="description" content="${_esc(description)}">
  <meta name="theme-color" content="#872B3F">
  <link rel="canonical" href="${_esc(canonical)}">
  <link rel="icon" href="/assets/favicon.png" type="image/png">
  <link rel="apple-touch-icon" href="/assets/favicon.png">
  <meta property="og:type" content="website">
  <meta property="og:title" content="${_esc(title)}">
  <meta property="og:description" content="${_esc(description)}">
  <meta property="og:url" content="${_esc(canonical)}">
  <meta property="og:image" content="${_esc(ogImage)}">
  <meta name="twitter:card" content="summary_large_image">
  <meta name="twitter:title" content="${_esc(title)}">
  <meta name="twitter:description" content="${_esc(description)}">
  <meta name="twitter:image" content="${_esc(ogImage)}">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@400;500;600;700;800&family=Playfair+Display:wght@600;700&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="/css/styles.css">
  $jsonLdScript
</head>
<body>
$header
  <main>
$body
  </main>
$footer
  <script>document.getElementById("year").textContent = new Date().getFullYear();</script>
  <script src="/js/config.js"></script>
  <script src="/js/main.js"></script>
  <script src="/js/prefetch-app.js"></script>
</body>
</html>
''';

  final file = File(path);
  file.parent.createSync(recursive: true);
  file.writeAsStringSync(html);
}

String _toolBody(VGToolLandingContent c) {
  final heroImg = _heroImageForSlug(c.slug);
  final why = c.whyChoose
      .map(
        (w) =>
            '<div class="value-card"><h3>${_esc(w.title)}</h3><p>${_esc(w.body)}</p></div>',
      )
      .join('\n          ');
  final showcase = c.showcase
      .asMap()
      .entries
      .map((e) {
        final reverse = e.key.isOdd ? ' reverse' : '';
        final img = _showcaseImage(e.value.imageAsset, c.slug);
        return '''
        <div class="feature-row$reverse">
          <div class="feature-copy">
            <h3>${_esc(e.value.title)}</h3>
            <p>${_esc(e.value.body)}</p>
          </div>
          <div class="feature-visual">
            <img src="$img" alt="" width="480" height="360" loading="lazy">
          </div>
        </div>''';
      })
      .join('\n');
  final howTo = c.howTo
      .asMap()
      .entries
      .map(
        (e) =>
            '<li><strong>${_esc(e.value.title)}</strong> — ${_esc(e.value.body)}</li>',
      )
      .join('\n            ');
  final reviews = c.reviews
      .map(
        (r) => '''
          <article class="review-card">
            <blockquote class="review-card__quote">${_esc(r.quote)}</blockquote>
            <footer class="review-card__footer">
              <div class="review-card__meta"><strong class="review-card__name">${_esc(r.name)}</strong></div>
            </footer>
          </article>''',
      )
      .join('\n');
  final faqs = c.faqs
      .map(
        (f) => '''
          <div class="faq-item">
            <button class="faq-question" type="button" aria-expanded="false">${_esc(f.question)}</button>
            <div class="faq-answer"><p>${_esc(f.answer)}</p></div>
          </div>''',
      )
      .join('\n');

  return '''
    <section class="hero">
      <div class="container hero-grid">
        <div>
          <h1>${_esc(c.headline)}</h1>
          <p class="tagline">${_esc(c.subheadline)}</p>
          <div class="hero-ctas">
            <a class="btn btn-primary vg-app-link" href="/app/${c.slug}">Try it now</a>
            <a class="btn btn-ghost vg-app-link" href="/login?redirect=${Uri.encodeComponent('/app/${c.slug}')}">Log in</a>
          </div>
        </div>
        <div class="feature-visual">
          <img src="$heroImg" alt="" width="480" height="360" loading="eager">
        </div>
      </div>
    </section>

    <section class="section">
      <div class="container">
        <h2 class="section-title">Why choose <em>Verified Glam</em></h2>
        <div class="value-cards">
          $why
        </div>
      </div>
    </section>

    <section class="section" id="features">
      <div class="container">
        <h2 class="section-title">${_esc(c.showcaseTitle)}</h2>
        <p class="section-lead">${_esc(c.showcaseSubtitle)}</p>
        $showcase
      </div>
    </section>

    <section class="section">
      <div class="container">
        <h2 class="section-title">How it <em>works</em></h2>
        <ol class="check-list">
            $howTo
        </ol>
      </div>
    </section>

    <section class="section reviews-section">
      <div class="container">
        <h2 class="section-title">What users <em>say</em></h2>
        <div class="reviews-grid">
          $reviews
        </div>
      </div>
    </section>

    <section class="section" id="faq">
      <div class="container">
        <h2 class="section-title">Frequently asked <em>questions</em></h2>
        <div class="faq-list">
          $faqs
        </div>
      </div>
    </section>

    <section class="cta-final">
      <div class="container">
        <h2>Ready to try?</h2>
        <p>Upload a photo and get AI-powered results on your selfie.</p>
        <div class="cta-final-actions">
          <a class="btn btn-primary vg-app-link" href="/app/${c.slug}">Start analysis</a>
          <a class="btn btn-ghost vg-app-link" href="/register?redirect=${Uri.encodeComponent('/app/${c.slug}')}">Create free account</a>
        </div>
      </div>
    </section>''';
}

String _toolsIndexBody() {
  final cards = _allToolSlugs.map((slug) {
    final content = landingContentForSlug(slug);
    if (content == null) return '';
    final img = _heroImageForSlug(slug);
    final title = content.headline.split('—').first.trim();
    return '''
        <a class="tool-card" href="/$slug">
          <img src="$img" alt="" width="320" height="200" loading="lazy">
          <h3>${_esc(title)}</h3>
          <p>${_esc(content.subheadline)}</p>
        </a>''';
  }).join('\n');

  return '''
    <section class="hero">
      <div class="container">
        <h1>AI Beauty Tools</h1>
        <p class="tagline">Explore every Verified Glam scan — from face beauty scores to celebrity matches.</p>
      </div>
    </section>
    <section class="section">
      <div class="container tools-grid">
        $cards
      </div>
    </section>''';
}

String _pricingBody() {
  const faqItems = [
    ('What plans do you offer?', 'Verified Glam Pro is available as a Yearly plan (\$39.99/year, was \$80.99) or a Pro weekly plan (\$3.99/week after a 3-day free trial).'),
    ('How does the Pro free trial work?', 'Select Pro plan and tap Start free trial. Use the app free for 3 days, then \$3.99/week unless you cancel before the trial ends.'),
    ('What is the Yearly plan?', 'Pay \$39.99 once per year for full Pro access — all analyses, no ads, and every premium feature.'),
    ('Can I cancel anytime?', 'Yes. Cancel in account settings before the Pro trial ends to avoid charges, or anytime after to stop future renewals.'),
  ];
  final faqs = faqItems
      .map(
        (f) => '''
          <div class="faq-item">
            <button class="faq-question" type="button" aria-expanded="false">${_esc(f.$1)}</button>
            <div class="faq-answer"><p>${_esc(f.$2)}</p></div>
          </div>''',
      )
      .join('\n');

  return '''
    <section class="hero">
      <div class="container">
        <h1>Choose the right plan</h1>
        <p class="tagline">Yearly or Pro weekly — every analysis unlocked, ad-free. No hidden fees.</p>
      </div>
    </section>
    <section class="section">
      <div class="container">
        <h2 class="section-title">Compare plans</h2>
        <p class="section-lead">Everything included with Yearly and Pro subscriptions.</p>
        <div class="pricing-cards">
          <div class="pricing-card">
            <h3>Yearly</h3>
            <p class="pricing-card__price">\$39.99<span>/year</span></p>
            <p>All analyses, ad-free, full reports.</p>
            <a class="btn btn-primary vg-app-link" href="/register">Sign up free</a>
          </div>
          <div class="pricing-card pricing-card--featured">
            <h3>Pro</h3>
            <p class="pricing-card__price">\$3.99<span>/week</span></p>
            <p>3-day free trial, then weekly billing.</p>
            <a class="btn btn-primary vg-app-link" href="/register">Start free trial</a>
          </div>
        </div>
      </div>
    </section>
    <section class="section" id="faq">
      <div class="container">
        <h2 class="section-title">Pricing FAQ</h2>
        <div class="faq-list">$faqs</div>
      </div>
    </section>''';
}

void _writeLegalPages(Directory outRoot, String header, String footer) {
  for (final page in [
    ('about', VGLegalPages.about),
    ('privacy', VGLegalPages.privacy),
    ('terms', VGLegalPages.terms),
  ]) {
    final p = page.$2;
    _writePage(
      path: '${outRoot.path}${Platform.pathSeparator}${page.$1}${Platform.pathSeparator}index.html',
      header: header,
      footer: footer,
      title: p.pageTitle,
      description: p.metaDescription,
      canonicalPath: p.canonicalPath,
      jsonLd: [],
      body: _legalBody(p),
    );
  }
}

String _legalBody(VGLegalPageContent p) {
  final blocks = p.blocks.map((b) {
    return switch (b) {
      VGLegalParagraph(:final text) => '<p>${_esc(text)}</p>',
      VGLegalHeading(:final text) => '<h2>${_esc(text)}</h2>',
      VGLegalBulletList(:final items) =>
        '<ul>${items.map((i) => '<li>${_esc(i)}</li>').join()}</ul>',
      VGLegalNumberedList(:final items) =>
        '<ol>${items.map((i) => '<li>${_esc(i)}</li>').join()}</ol>',
    };
  }).join('\n      ');

  final meta = p.metaLine != null ? '<p class="legal-meta">${_esc(p.metaLine!)}</p>' : '';

  return '''
    <section class="legal-page">
      <div class="container">
        <h1>${_esc(p.h1)}</h1>
        $meta
        $blocks
      </div>
    </section>''';
}

void _writeAuthTemplate(Directory outRoot, String header, String footer, {required bool login}) {
  final path = login ? 'login' : 'register';
  final title = login ? 'Log in — Verified Glam Scanner' : 'Create account — Verified Glam Scanner';
  final description = login
      ? 'Sign in to Verified Glam Scanner to run AI beauty analyses and sync your scan history.'
      : 'Create your free Verified Glam Scanner account and start AI beauty analyses in your browser.';

  _writePage(
    path: '${outRoot.path}${Platform.pathSeparator}$path${Platform.pathSeparator}index.html',
    header: header,
    footer: footer,
    title: title,
    description: description,
    canonicalPath: '/$path',
    jsonLd: [],
    body: _authBody(login: login),
  );
}

String _authBody({required bool login}) {
  final otherPath = login ? '/register' : '/login';
  final otherLabel = login ? 'Create account' : 'Sign in';
  final prompt = login ? 'New to Verified Glam?' : 'Already have an account?';
  final heading = login ? 'Welcome back' : 'Create your account';
  final sub = login
      ? 'Sign in to run analyses, save scans, and sync across devices.'
      : 'Sign up to upload photos, save results, and unlock Pro features.';

  return '''
    <div class="auth-page">
      <div class="auth-page__brand">
        <img src="/assets/logo.png" alt="" width="56" height="56">
        <h2>Verified Glam Scanner</h2>
        <p>Pretty in Every Way</p>
      </div>
      <div class="auth-page__form-wrap">
        <h1>${_esc(heading)}</h1>
        <p class="auth-page__sub">${_esc(sub)}</p>
        <form id="vg-auth-form" class="auth-form" data-mode="${login ? 'login' : 'register'}">
          <label class="auth-field">
            <span>Email</span>
            <input type="email" name="email" required autocomplete="email">
          </label>
          <label class="auth-field">
            <span>Password</span>
            <input type="password" name="password" required minlength="6" autocomplete="${login ? 'current-password' : 'new-password'}">
          </label>
          ${login ? '<p class="auth-forgot"><a href="/forgot-password">Forgot password?</a></p>' : ''}
          <button type="submit" class="btn btn-primary auth-submit">${login ? 'Sign in' : 'Create account'}</button>
          <p class="auth-error" id="vg-auth-error" hidden></p>
        </form>
        <div class="auth-divider"><span>or</span></div>
        <button type="button" class="btn btn-ghost auth-google" id="vg-google-btn">Continue with Google</button>
        <p class="auth-footer">${_esc(prompt)} <a href="$otherPath">$otherLabel</a></p>
      </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2/dist/umd/supabase.min.js"></script>
    <script src="/js/auth-config.js"></script>
    <script src="/js/auth.js"></script>''';
}

String _heroImageForSlug(String slug) {
  const features = {
    'face-beauty-analysis': 'face-beauty.jpg',
    'seasonal-color-palette': 'face-beauty.jpg',
    'beauty-tips': 'attractiveness.jpg',
    'celebrity-look-alike': 'celebrity-match.jpg',
    'facial-symmetry': 'facial-symmetry.jpg',
    'beauty-score-showdown': 'attractiveness.jpg',
    'face-comparison': 'face-beauty.jpg',
    'attractiveness-test': 'attractiveness.jpg',
    'face-golden-ratio': 'facial-symmetry.jpg',
  };
  if (slug == 'beauty-routine-challenge') {
    return '/assets/lifestyle/value-glowup.jpg';
  }
  return '/assets/features/${features[slug] ?? 'face-beauty.jpg'}';
}

String _showcaseImage(String asset, String slug) {
  if (asset.contains('face_beauty')) return '/assets/features/face-beauty.jpg';
  if (asset.contains('symmetry')) return '/assets/features/facial-symmetry.jpg';
  if (asset.contains('celebrity')) return '/assets/features/celebrity-match.jpg';
  if (asset.contains('attractiveness')) return '/assets/features/attractiveness.jpg';
  if (asset.contains('beauty_tips')) return '/assets/features/attractiveness.jpg';
  return _heroImageForSlug(slug);
}

String _esc(String s) {
  return const HtmlEscape().convert(s);
}

String _canonicalUrl(String path) {
  if (path.isEmpty || path == '/') return '$_siteUrl/';
  return '$_siteUrl$path';
}

List<Map<String, dynamic>> _toolJsonLd(VGToolLandingContent content) {
  final url = _canonicalUrl('/${content.slug}');
  return [
    {
      '@context': 'https://schema.org',
      '@type': 'WebPage',
      'name': content.pageTitle,
      'description': content.metaDescription,
      'url': url,
    },
    {
      '@context': 'https://schema.org',
      '@type': 'Service',
      'name': content.headline,
      'description': content.subheadline,
      'provider': {'@type': 'Organization', 'name': _productName, 'url': _siteUrl},
      'url': url,
    },
  ];
}

List<Map<String, dynamic>> _toolsIndexJsonLd() => [
      {
        '@context': 'https://schema.org',
        '@type': 'CollectionPage',
        'name': 'AI Beauty Tools — Verified Glam Scanner',
        'url': _canonicalUrl('/tools'),
      },
    ];

List<Map<String, dynamic>> _pricingJsonLd() => [
      {
        '@context': 'https://schema.org',
        '@type': 'WebPage',
        'name': 'Verified Glam Scanner Pricing',
        'url': _canonicalUrl('/pricing'),
      },
    ];
