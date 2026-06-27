// ignore_for_file: avoid_print
/// Generates static marketing HTML from Dart content (no UI redesign — homepage chrome only).
///
/// Run: dart run tool/generate_marketing_html.dart
import 'dart:convert';
import 'dart:io';

import '../lib/web/content/vg_home_landing_content.dart';
import '../lib/web/content/vg_legal_content.dart';
import '../lib/web/content/vg_tool_landing_content.dart';

/// Pricing copy mirrored from VGCopy (cannot import vg_copy.dart in CLI — dart:ui via vg_constants).
const _pricingMetaTitle = 'Verified Glam Scanner Pricing — Credits & Plans';
const _pricingMetaDescription =
    'Verified Glam Scanner Pro: Yearly \$39.99/year (200 AI credits) or Pro \$3.99/week (30 credits weekly). 5 credits per AI generation. Ad-free.';
const _pricingHeroTitle = 'Choose the Right Plan';
const _pricingHeroSubtitle =
    'Unlock all AI Beauty analyses with a flexible subscription that fits your needs. Every subscription includes full access to all AI beauty tools, ad-free results, and downloadable reports. Credits are used whenever you generate a new AI analysis.';
const _pricingCompareTitle = 'Compare Plans';
const _pricingCompareSubtitle = 'Everything included with Yearly and Pro subscriptions.';
const _pricingFaqTitle = 'Pricing FAQ';
const _pricingSignUpCta = 'Sign up';
const _paywallSubscribeNow = 'Subscribe now';
const _paywallCancelAnytime = 'Cancel anytime';
const _paywallBestPrice = 'Best Value';
const _paywallYearlyPlanName = 'Yearly Plan';
const _paywallYearlyPrice = '\$39.99';
const _paywallYearlyPeriod = '/year';
const _paywallYearlyWasPrice = '\$80.99/year';
const _paywallYearlySubtitle = 'Billed once per year · Cancel anytime';
const _paywallProPlanName = 'Pro Plan';
const _paywallProWeeklyPrice = '\$3.99';
const _paywallProWeeklyPeriod = '/week';
const _paywallProSubtitle = 'Billed weekly · Cancel anytime';
const _paywallYearlyColumn = 'Yearly';
const _paywallProColumn = 'Pro Weekly';
const _pricingWhatsIncluded = "What's Included";
const _pricingCreditBreakdown = 'Credit Breakdown';
const _paywallSharedFeatures = [
  'Full access to all 10 AI Beauty Analyses',
  'Ad-free experience',
  'Instant result downloads',
  'Priority access to new AI features',
  'Secure cloud synchronization across devices',
];
const _paywallYearlyFeatures = [
  '200 AI Credits per year',
  'Each AI generation costs 5 credits',
  'Up to 40 AI generations per year',
  'Credits remain available throughout your annual subscription',
];
const _paywallProFeatures = [
  '30 AI Credits every week',
  'Credits automatically refresh every billing cycle',
  'Each AI generation costs 5 credits',
  'Up to 6 AI generations every week',
];
const _paywallYearlyCreditBreakdown = [
  '200 credits per year',
  '5 credits per generation',
  '40 total generations per year',
  'Effective cost: \$0.20 per credit',
];
const _paywallProCreditBreakdown = [
  '30 credits every week',
  '5 credits per generation',
  '6 generations every week',
  'Effective cost: \$0.133 per credit',
];
const _paywallSubscriptionTerms =
    'Subscription Terms: Yearly plan is \$39.99 per year and renews automatically unless cancelled. Pro plan is \$3.99 per week and renews automatically unless cancelled. Credits renew each billing period.';
const _paywallCancellationTerms =
    'Cancellation Terms: Cancel anytime in account settings to stop future renewals. Access and remaining credits continue until the end of your current billing period.';
const _paywallTermsPrefix = 'See';
const _paywallTerms = 'Terms';
const _paywallPrivacy = 'Privacy';
const _pricingFaqItems = [
  (
    'What plans do you offer?',
    'Verified Glam Scanner Pro is available as a Yearly plan (\$39.99/year, 200 credits) or a Pro weekly plan (\$3.99/week, 30 credits refreshed weekly).',
  ),
  (
    'How do credits work?',
    'Each new AI analysis costs 5 credits. Yearly subscribers get 200 credits per year (up to 40 generations). Pro Weekly subscribers get 30 credits per week (up to 6 generations).',
  ),
  (
    'What is the Yearly plan?',
    'Pay \$39.99 once per year for full Pro access, 200 AI credits, no ads, and every premium feature.',
  ),
  (
    'Can I cancel anytime?',
    'Yes. Cancel in account settings anytime. Your access continues until the end of your current billing period.',
  ),
];

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

/// Static feature catalog for tools grid / compare table (matches vg_feature_data.dart).
const _featureCatalog = [
  (
    'face-beauty-analysis',
    'Face Beauty Analysis',
    'Discover your beauty score with an instant facial feature analysis.',
  ),
  (
    'seasonal-color-palette',
    'Seasonal Color Palette',
    'Get your personalized color palette in under 60 seconds.',
  ),
  (
    'beauty-routine-challenge',
    'Beauty Routine Challenge',
    'A personalized beauty challenge based on your latest scan.',
  ),
  (
    'beauty-tips',
    'Beauty Tips',
    'Personalized beauty tips based on your facial analysis.',
  ),
  (
    'celebrity-look-alike',
    'Celebrity Look Alike',
    'Find which celebrity you resemble with AI face matching.',
  ),
  (
    'facial-symmetry',
    'Facial Symmetry',
    'Measure facial symmetry and balance with AI precision.',
  ),
  (
    'beauty-score-showdown',
    'Beauty Score Showdown',
    'Compare beauty scores and challenge friends.',
  ),
  (
    'face-comparison',
    'Face Comparison',
    'Compare two faces and see resemblance scores.',
  ),
  (
    'attractiveness-test',
    'Attractiveness Test',
    'Get an AI attractiveness score with detailed breakdown.',
  ),
  (
    'face-golden-ratio',
    'Face Golden Ratio',
    'Analyze facial proportions against the golden ratio.',
  ),
];

const _featuredSlugs = [
  'face-beauty-analysis',
  'seasonal-color-palette',
  'facial-symmetry',
];

void main() {
  if (!File('pubspec.yaml').existsSync()) {
    stderr.writeln('Run from repo root.');
    exit(1);
  }

  final partialsDir = Directory('website/partials');
  final header = _readFile('${partialsDir.path}${Platform.pathSeparator}site-header.html');
  final siteFooter = _readFile('${partialsDir.path}${Platform.pathSeparator}site-footer.html');
  final saasFooter = _readFile(
    '${partialsDir.path}${Platform.pathSeparator}saas${Platform.pathSeparator}saas-footer.html',
  );
  final outRoot = Directory('website/generated')..createSync(recursive: true);

  for (final slug in _allToolSlugs) {
    final content = landingContentForSlug(slug);
    if (content == null) continue;
    _writePage(
      path: '${outRoot.path}${Platform.pathSeparator}$slug${Platform.pathSeparator}index.html',
      header: header,
      footer: saasFooter,
      title: content.pageTitle,
      description: content.metaDescription,
      canonicalPath: '/$slug',
      jsonLd: _toolJsonLd(content),
      body: _toolBody(content),
      saas: true,
    );
  }

  _writePage(
    path: '${outRoot.path}${Platform.pathSeparator}tools${Platform.pathSeparator}index.html',
    header: header,
    footer: saasFooter,
    title: 'AI Beauty Tools — Verified Glam Scanner',
    description:
        'Browse AI beauty scan tools: face beauty analysis, symmetry, celebrity look-alike, seasonal color palette, and more.',
    canonicalPath: '/tools',
    jsonLd: _toolsIndexJsonLd(),
    body: _toolsIndexBody(),
    saas: true,
  );

  _writePage(
    path: '${outRoot.path}${Platform.pathSeparator}pricing${Platform.pathSeparator}index.html',
    header: header,
    footer: saasFooter,
    title: _pricingMetaTitle,
    description: _pricingMetaDescription,
    canonicalPath: '/pricing',
    jsonLd: _pricingJsonLd(),
    body: _pricingBody(),
    saas: true,
    extraScripts: '''  <script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2/dist/umd/supabase.min.js"></script>
  <script src="/js/auth-config.js"></script>
  <script src="/js/checkout.js"></script>''',
  );

  _writeLegalPages(outRoot, header, saasFooter);
  _writeAuthTemplate(outRoot, header, login: true);
  _writeAuthTemplate(outRoot, header, login: false);
  _writeHomePage(outRoot, header, siteFooter);

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
  bool saas = false,
  String extraScripts = '',
}) {
  final canonical = _canonicalUrl(canonicalPath);
  final ogImage = '$_siteUrl/icons/Icon-512.png';
  final jsonLdScript = jsonLd
      .map((m) => '<script type="application/ld+json">${jsonEncode(m)}</script>')
      .join('\n  ');
  final saasCss = saas ? '<link rel="stylesheet" href="/css/vg-saas.css">' : '';

  final html = '''<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${_esc(title)}</title>
  <meta name="description" content="${_esc(description)}">
  <meta name="theme-color" content="#872B3F">
  <link rel="canonical" href="$canonical">
  <link rel="icon" href="/assets/favicon.png" type="image/png">
  <link rel="apple-touch-icon" href="/assets/favicon.png">
  <meta name="robots" content="index, follow">
  <meta property="og:type" content="website">
  <meta property="og:title" content="${_esc(title)}">
  <meta property="og:description" content="${_esc(description)}">
  <meta property="og:url" content="$canonical">
  <meta property="og:image" content="$ogImage">
  <meta name="twitter:card" content="summary_large_image">
  <meta name="twitter:title" content="${_esc(title)}">
  <meta name="twitter:description" content="${_esc(description)}">
  <meta name="twitter:image" content="$ogImage">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@400;500;600;700;800&family=Playfair+Display:wght@600;700&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="/css/styles.css">
  $saasCss
  $jsonLdScript
</head>
<body>
$header
  <main>
$body
  </main>
$footer
  <script>(function(){var y=document.getElementById("year");if(y)y.textContent=new Date().getFullYear();document.querySelectorAll(".vg-footer-year").forEach(function(el){el.textContent=new Date().getFullYear();});})();</script>
  <script src="/js/config.js"></script>
  <script src="/js/main.js"></script>
  <script src="/js/prefetch-app.js"></script>
  $extraScripts
</body>
</html>
''';

  final file = File(path);
  file.parent.createSync(recursive: true);
  file.writeAsStringSync(html);
}

String _toolBody(VGToolLandingContent c) {
  final heroImg = _heroImageForSlug(c.slug);
  final featureTitle = _featureTitleForSlug(c.slug);
  final chips = _heroChipsForSlug(c.slug);

  const whyIcons = ['scan', 'detail', 'personalized'];
  final why = c.whyChoose
      .take(3)
      .toList()
      .asMap()
      .entries
      .map(
        (e) {
          final icon = e.value.icon != 'scan' ? e.value.icon : whyIcons[e.key % whyIcons.length];
          return '''
        <article class="vg-value-card">
          <div class="vg-value-icon vg-value-icon--$icon" aria-hidden="true"></div>
          <h3>${_esc(e.value.title)}</h3>
          <p>${_esc(e.value.body)}</p>
        </article>''';
        },
      )
      .join('\n');

  final showcase = c.showcase
      .asMap()
      .entries
      .map((e) {
        final layout = e.key.isOdd
            ? 'vg-showcase-feature--copy-first'
            : 'vg-showcase-feature--img-first';
        final img = _showcaseImage(e.value.imageAsset, c.slug, e.key);
        final cta = _esc(e.value.ctaLabel);
        final alt = _esc(e.value.imageAlt);
        return '''
        <div class="vg-showcase-feature $layout">
          <div class="vg-showcase-feature__visual">
            <img src="$img" alt="$alt" width="560" height="420" loading="lazy">
          </div>
          <div class="vg-showcase-feature__copy">
            <h2>${_esc(e.value.title)}</h2>
            <p>${_esc(e.value.body)}</p>
            <a class="vg-btn-pill vg-btn-pill--primary vg-showcase-feature__cta vg-app-link" href="/app/${c.slug}">$cta</a>
          </div>
        </div>''';
      })
      .join('\n');

  final howTo = c.howTo
      .asMap()
      .entries
      .map(
        (e) => '''
        <div class="vg-step-card">
          <div class="vg-step-card__num">${e.key + 1}</div>
          <h3>${_esc(e.value.title)}</h3>
          <p>${_esc(e.value.body)}</p>
        </div>''',
      )
      .join('\n');

  final reviews = c.reviews
      .map(
        (r) => '''
        <article class="vg-review-card">
          <div class="vg-review-card__header">
            <span class="vg-review-card__name">${_esc(r.name)}</span>
            <span class="vg-review-card__stars" aria-hidden="true">★★★★★</span>
          </div>
          <div class="vg-review-card__quote-icon" aria-hidden="true">"</div>
          <blockquote>${_esc(r.quote)}</blockquote>
        </article>''',
      )
      .join('\n');

  final faqs = c.faqs
      .map(
        (f) => '''
        <details class="vg-faq-item">
          <summary>${_esc(f.question)}</summary>
          <div class="vg-faq-item__answer">${_esc(f.answer)}</div>
        </details>''',
      )
      .join('\n');

  return '''
    <section class="vg-hero-saas">
      <div class="vg-hero-saas__inner">
        <div class="vg-hero-saas__grid">
          ${_heroDemoHtml(heroImg, chips)}
          <div>
            <h1 class="vg-hero-saas__headline">${_esc(c.headline)}</h1>
            <p class="vg-hero-saas__sub">${_esc(c.subheadline)}</p>
            ${_uploadCardHtml(c.slug, featureTitle)}
          </div>
        </div>
      </div>
    </section>

    ${_exploreToolsRow(c.slug)}

    <section class="vg-section vg-section--blush-light">
      <div class="vg-section__inner">
        <h2 class="vg-section-title">Why choose Verified Glam Scanner</h2>
        <p class="vg-section-subtitle">Professional AI analysis with your photo at the center — built for web and mobile.</p>
        <div class="vg-value-grid">$why</div>
      </div>
    </section>

    <section class="vg-showcase-features" aria-label="${_esc(c.showcaseTitle)}">
      <div class="vg-showcase-features__inner">$showcase</div>
    </section>

    <section class="vg-section vg-section--blush">
      <div class="vg-section__inner">
        <h2 class="vg-section-title">How to use</h2>
        <p class="vg-section-subtitle">Three simple steps from upload to personalized results.</p>
        <div class="vg-howto-steps">$howTo</div>
      </div>
    </section>

    ${_toolsGridSection(c.slug)}

    <section class="vg-section vg-section--white">
      <div class="vg-section__inner">
        <h2 class="vg-section-title">User reviews</h2>
        <div class="vg-reviews-grid">$reviews</div>
      </div>
    </section>

    <section class="vg-section vg-section--blush-light">
      <div class="vg-section__inner">
        <h2 class="vg-section-title">Frequently asked questions</h2>
        <p class="vg-section-subtitle">Quick answers for search engines and first-time visitors.</p>
        <div class="vg-faq-list">$faqs</div>
      </div>
    </section>''';
}

String _exploreToolsRow(String currentSlug) {
  final chips = _featureCatalog
      .where((f) => f.$1 != currentSlug)
      .map(
        (f) =>
            '<a class="vg-feature-chip vg-tool-link" href="/${f.$1}">${_esc(f.$2)}</a>',
      )
      .join('\n');

  return '''
    <section class="vg-section vg-section--explore">
      <div class="vg-section__inner">
        <h2 class="vg-section-title vg-section-title--start">Explore more tools</h2>
        <div class="vg-feature-chips vg-feature-chips--scroll">$chips</div>
      </div>
    </section>''';
}

String _heroDemoHtml(String img, List<String> chips) {
  final chipHtml = chips
      .asMap()
      .entries
      .map(
        (e) => e.key == 0
            ? '<span class="vg-hero-demo__chip vg-hero-demo__chip--primary">${_esc(e.value)}</span>'
            : '<span class="vg-hero-demo__chip">${_esc(e.value)}</span>',
      )
      .join('\n');
  return '''
    <div class="vg-hero-demo">
      <img src="$img" alt="" width="560" height="420" loading="eager">
      <div class="vg-hero-demo__overlay" aria-hidden="true"></div>
      <div class="vg-hero-demo__chips">$chipHtml</div>
    </div>''';
}

String _uploadCardHtml(String slug, String featureTitle) {
  return '''
    <div class="vg-upload-card">
      <div class="vg-upload-card__dropzone">
        <div class="vg-upload-card__icon" aria-hidden="true">
          <svg width="48" height="48" viewBox="0 0 48 48" fill="none" xmlns="http://www.w3.org/2000/svg">
            <path d="M24 8v20M24 8l-7 7M24 8l7 7" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>
            <path d="M8 32v4a4 4 0 004 4h24a4 4 0 004-4v-4" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"/>
          </svg>
        </div>
        <p class="vg-upload-card__title">Drag &amp; drop or click to upload</p>
        <p class="vg-upload-card__feature">${_esc(featureTitle)}</p>
      </div>
      <a class="vg-btn-pill vg-btn-pill--primary vg-app-link" href="/app/$slug">Try for free</a>
      <p class="vg-upload-card__proof">Trusted by beauty enthusiasts worldwide</p>
      <a class="vg-upload-card__tips vg-app-link" href="/app/$slug">View photo tips in the app</a>
    </div>''';
}

String _toolsGridSection(String? currentSlug) {
  final cards = _featureCatalog.map((f) {
    final current = f.$1 == currentSlug;
    final cls = current ? 'vg-tool-card vg-tool-card--current' : 'vg-tool-card';
    final img = _heroImageForSlug(f.$1);
    return '''
      <a class="$cls" href="/${f.$1}">
        <div class="vg-tool-card__thumb">
          <img src="$img" alt="" width="320" height="180" loading="lazy">
        </div>
        <div class="vg-tool-card__body">
          <h3>${_esc(f.$2)}</h3>
          <p>${_esc(f.$3)}</p>
          <span class="vg-tool-card__cta">Try it now →</span>
        </div>
      </a>''';
  }).join('\n');

  return '''
    <section class="vg-section vg-section--white">
      <div class="vg-section__inner">
        <h2 class="vg-section-title">All AI beauty tools</h2>
        <p class="vg-section-subtitle">Explore every Verified Glam Scanner analysis — each with its own landing page and upload flow.</p>
        <div class="vg-tools-grid">$cards</div>
      </div>
    </section>''';
}

String _toolsIndexBody() {
  final chips = _featuredSlugs.map((slug) {
    final title = _featureTitleForSlug(slug);
    return '<a class="vg-feature-chip" href="/$slug">${_esc(title)}</a>';
  }).join('\n');

  return '''
    <section class="vg-section vg-section--blush">
      <div class="vg-section__inner">
        <h2 class="vg-section-title vg-section-title--start">AI beauty tools</h2>
        <p class="vg-section-subtitle vg-section-subtitle--start">Each scan has its own page — upload a photo and get results on the web.</p>
        <div class="vg-feature-chips">$chips</div>
      </div>
    </section>
    ${_toolsGridSection(null)}''';
}

String _pricingFeatureListHtml(List<String> items) =>
    items.map((f) => '<li>${_esc(f)}</li>').join('\n');

String _pricingBody() {
  final yearlyIncluded = _pricingFeatureListHtml([
    ..._paywallSharedFeatures,
    ..._paywallYearlyFeatures,
  ]);
  final proIncluded = _pricingFeatureListHtml([
    ..._paywallSharedFeatures,
    ..._paywallProFeatures,
  ]);
  final yearlyCredits = _pricingFeatureListHtml(_paywallYearlyCreditBreakdown);
  final proCredits = _pricingFeatureListHtml(_paywallProCreditBreakdown);

  final compareRows = _featureCatalog
      .map(
        (f) => '''
        <div class="vg-compare-table__row">
          <span>${_esc(f.$2)}</span>
          <span>✓</span>
          <span>✓</span>
        </div>''',
      )
      .join('\n');

  final faqs = _pricingFaqItems
      .map(
        (f) => '''
        <details class="vg-faq-item">
          <summary>${_esc(f.$1)}</summary>
          <div class="vg-faq-item__answer">${_esc(f.$2)}</div>
        </details>''',
      )
      .join('\n');

  return '''
    <section class="vg-pricing-hero">
      <div class="vg-pricing-hero__inner">
        <h1>${_esc(_pricingHeroTitle)}</h1>
        <p>${_esc(_pricingHeroSubtitle)}</p>
      </div>
    </section>

    <div class="vg-paywall">
      <div class="vg-paywall__cards" role="radiogroup" aria-label="Subscription plans" data-plan-picker>
        <div class="vg-plan-card vg-plan-card--selected" role="radio" aria-checked="true" tabindex="0" data-plan="annual">
          <div class="vg-plan-card__header">
            <span class="vg-plan-card__radio" aria-hidden="true"></span>
            <span class="vg-plan-card__badge">${_esc(_paywallBestPrice)}</span>
          </div>
          <h3>${_esc(_paywallYearlyPlanName)}</h3>
          <div>
            <span class="vg-plan-card__price">${_esc(_paywallYearlyPrice)}</span>
            <span class="vg-plan-card__period">${_esc(_paywallYearlyPeriod)}</span>
          </div>
          <p class="vg-plan-card__was">${_esc(_paywallYearlyWasPrice)}</p>
          <p class="vg-plan-card__sub">${_esc(_paywallYearlySubtitle)}</p>
          <p class="vg-plan-card__section-title">${_esc(_pricingWhatsIncluded)}</p>
          <ul class="vg-plan-card__features">$yearlyIncluded</ul>
          <p class="vg-plan-card__section-title">${_esc(_pricingCreditBreakdown)}</p>
          <ul class="vg-plan-card__features vg-plan-card__features--muted">$yearlyCredits</ul>
          <div class="vg-plan-card__cta">
            <a class="vg-btn-pill vg-btn-pill--primary vg-checkout-btn" href="/register?plan=annual" data-plan="annual">${_esc(_paywallSubscribeNow)}</a>
            <p class="vg-plan-card__cancel">${_esc(_paywallCancelAnytime)}</p>
          </div>
        </div>
        <div class="vg-plan-card" role="radio" aria-checked="false" tabindex="-1" data-plan="pro_weekly">
          <div class="vg-plan-card__header">
            <span class="vg-plan-card__radio" aria-hidden="true"></span>
          </div>
          <h3>${_esc(_paywallProPlanName)}</h3>
          <div>
            <span class="vg-plan-card__price">${_esc(_paywallProWeeklyPrice)}</span>
            <span class="vg-plan-card__period">${_esc(_paywallProWeeklyPeriod)}</span>
          </div>
          <p class="vg-plan-card__sub">${_esc(_paywallProSubtitle)}</p>
          <p class="vg-plan-card__section-title">${_esc(_pricingWhatsIncluded)}</p>
          <ul class="vg-plan-card__features">$proIncluded</ul>
          <p class="vg-plan-card__section-title">${_esc(_pricingCreditBreakdown)}</p>
          <ul class="vg-plan-card__features vg-plan-card__features--muted">$proCredits</ul>
          <div class="vg-plan-card__cta">
            <a class="vg-btn-pill vg-btn-pill--primary vg-checkout-btn" href="/register?plan=pro_weekly" data-plan="pro_weekly">${_esc(_paywallSubscribeNow)}</a>
            <p class="vg-plan-card__cancel">${_esc(_paywallCancelAnytime)}</p>
          </div>
        </div>
      </div>

      <div class="vg-paywall__compare">
        <h2>${_esc(_pricingCompareTitle)}</h2>
        <p>${_esc(_pricingCompareSubtitle)}</p>
        <div class="vg-compare-table">
          <div class="vg-compare-table__head">
            <span>Feature</span>
            <span>${_esc(_paywallYearlyColumn)}</span>
            <span>${_esc(_paywallProColumn)}</span>
          </div>
          $compareRows
          <div class="vg-compare-table__row">
            <span>Ad-Free Experience</span>
            <span>✓</span>
            <span>✓</span>
          </div>
          <div class="vg-compare-table__row">
            <span>Download Results</span>
            <span>✓</span>
            <span>✓</span>
          </div>
          <div class="vg-compare-table__row">
            <span>Credits Included</span>
            <span>200/year</span>
            <span>30/week</span>
          </div>
          <div class="vg-compare-table__row">
            <span>Cost per Generation</span>
            <span>About \$0.20</span>
            <span>About \$0.133</span>
          </div>
          <div class="vg-compare-table__row">
            <span>Credit Renewal</span>
            <span>Annual</span>
            <span>Weekly</span>
          </div>
        </div>
      </div>

      <div class="vg-paywall__terms">
        <p>${_esc(_paywallSubscriptionTerms)}</p>
        <p>${_esc(_paywallCancellationTerms)}</p>
        <p>${_esc(_paywallTermsPrefix)} <a href="/terms">${_esc(_paywallTerms)}</a> · <a href="/privacy">${_esc(_paywallPrivacy)}</a></p>
      </div>
    </div>

    <section class="vg-pricing-signup">
      <a class="vg-btn-pill vg-btn-pill--primary vg-app-link" href="/register">${_esc(_pricingSignUpCta)}</a>
      <p class="vg-pricing-signup__login">Already have an account? <a href="/login">Log in</a></p>
    </section>

    <section class="vg-section vg-section--blush-light">
      <div class="vg-section__inner">
        <h2 class="vg-section-title">${_esc(_pricingFaqTitle)}</h2>
        <div class="vg-faq-list">$faqs</div>
      </div>
    </section>''';
}

void _writeLegalPages(Directory outRoot, String header, String saasFooter) {
  for (final page in [
    ('about', VGLegalPages.about),
    ('privacy', VGLegalPages.privacy),
    ('terms', VGLegalPages.terms),
  ]) {
    final p = page.$2;
    _writePage(
      path: '${outRoot.path}${Platform.pathSeparator}${page.$1}${Platform.pathSeparator}index.html',
      header: header,
      footer: saasFooter,
      title: p.pageTitle,
      description: p.metaDescription,
      canonicalPath: p.canonicalPath,
      jsonLd: [],
      body: _legalBody(p),
      saas: true,
    );
  }
}

String _legalBody(VGLegalPageContent p) {
  final blocks = p.blocks.map((b) {
    return switch (b) {
      VGLegalParagraph(:final text) => '<p>${_esc(text)}</p>',
      VGLegalHeading(:final text) => '<h2>${_esc(text)}</h2>',
      VGLegalBulletList(:final items) => '<ul>${items.map((i) => '<li>${_esc(i)}</li>').join()}</ul>',
      VGLegalNumberedList(:final items) =>
        '<ol>${items.map((i) => '<li>${_esc(i)}</li>').join()}</ol>',
    };
  }).join('\n        ');

  final meta = p.metaLine != null ? '<p class="vg-legal-meta">${_esc(p.metaLine!)}</p>' : '';

  return '''
    <div class="vg-legal-scaffold">
      <div class="vg-legal-inner">
        <h1>${_esc(p.h1)}</h1>
        $meta
        $blocks
      </div>
    </div>''';
}

void _writeAuthTemplate(Directory outRoot, String header, {required bool login}) {
  final path = login ? 'login' : 'register';
  final title = login ? 'Log in — Verified Glam Scanner' : 'Create account — Verified Glam Scanner';
  final description = login
      ? 'Sign in to Verified Glam Scanner to run AI beauty analyses and sync your scan history.'
      : 'Create your free Verified Glam Scanner account and start AI beauty analyses in your browser.';

  _writePage(
    path: '${outRoot.path}${Platform.pathSeparator}$path${Platform.pathSeparator}index.html',
    header: header,
    footer: '',
    title: title,
    description: description,
    canonicalPath: '/$path',
    jsonLd: [],
    body: _authBody(login: login),
    saas: true,
  );
}

String _authBody({required bool login}) {
  final otherPath = login ? '/register' : '/login';
  final otherLabel = login ? 'Create account' : 'Sign in';
  final prompt = login ? 'New to Verified Glam Scanner?' : 'Already have an account?';
  final heading = login ? 'Welcome back' : 'Create your account';
  final sub = login
      ? 'Sign in to Verified Glam Scanner to run analyses, save scans, and sync across devices.'
      : 'Join Verified Glam Scanner — upload a photo and start AI beauty scans in your browser.';

  return '''
    <div class="vg-auth-split">
      <div class="vg-auth-brand">
        <h2>Verified Glam Scanner</h2>
        <p class="vg-auth-brand__tagline">AI beauty analysis from your selfie</p>
        <div class="vg-auth-brand__bullet">10 AI beauty scans — scores and overlays on your photo</div>
        <div class="vg-auth-brand__bullet">Symmetry, color palette, celebrity match, and more</div>
        <div class="vg-auth-brand__bullet">Save results and sync across devices with Pro</div>
      </div>
      <div class="vg-auth-form-panel">
        <div class="vg-auth-form-inner">
          <h1>${_esc(heading)}</h1>
          <p class="vg-auth-sub">${_esc(sub)}</p>
          <form id="vg-auth-form" data-mode="${login ? 'login' : 'register'}">
            <label class="vg-auth-field">
              <span>Email</span>
              <input type="email" name="email" required autocomplete="email">
            </label>
            <label class="vg-auth-field">
              <span>Password</span>
              <input type="password" name="password" required minlength="6" autocomplete="${login ? 'current-password' : 'new-password'}">
            </label>
            ${login ? '<p class="vg-auth-forgot"><a href="/forgot-password">Forgot password?</a></p>' : ''}
            <button type="submit" class="vg-btn-pill vg-btn-pill--primary auth-submit">${login ? 'Sign in' : 'Create account'}</button>
            <p class="vg-auth-error" id="vg-auth-error" hidden></p>
          </form>
          <div class="vg-auth-divider">or</div>
          <button type="button" class="vg-btn-pill vg-btn-pill--ghost auth-google" id="vg-google-btn">Continue with Google</button>
          <p class="vg-auth-footer">${_esc(prompt)} <a href="$otherPath">$otherLabel</a></p>
        </div>
      </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2/dist/umd/supabase.min.js"></script>
    <script src="/js/auth-config.js"></script>
    <script src="/js/auth.js"></script>''';
}

String _featureTitleForSlug(String slug) {
  for (final f in _featureCatalog) {
    if (f.$1 == slug) return f.$2;
  }
  return slug;
}

List<String> _heroChipsForSlug(String slug) {
  switch (slug) {
    case 'facial-symmetry':
      return ['Symmetry', 'Midline', 'Balance', 'Eyes'];
    case 'seasonal-color-palette':
      return ['Spring', 'Summer', 'Autumn', 'Winter'];
    case 'face-golden-ratio':
      return ['Phi map', 'Thirds', 'Harmony', 'Ratios'];
    case 'celebrity-look-alike':
      return ['Match %', 'Eyes', 'Jawline', 'Smile'];
    default:
      return ['AI scan', 'Features', 'Score', 'Tips'];
  }
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

String _showcaseImage(String asset, String slug, int index) {
  final landingRel = 'images/vg/marketing/landings/$slug/showcase-${index + 1}.jpg';
  if (File(landingRel).existsSync()) {
    return '/assets/landings/$slug/showcase-${index + 1}.jpg';
  }
  if (asset.contains('face_beauty')) return '/assets/features/face-beauty.jpg';
  if (asset.contains('symmetry')) return '/assets/features/facial-symmetry.jpg';
  if (asset.contains('celebrity')) return '/assets/features/celebrity-match.jpg';
  if (asset.contains('attractiveness')) return '/assets/features/attractiveness.jpg';
  if (asset.contains('beauty_tips')) return '/assets/features/attractiveness.jpg';
  if (asset.contains('glow_up')) return '/assets/lifestyle/value-glowup.jpg';
  if (asset.contains('comparison')) return '/assets/features/face-beauty.jpg';
  if (asset.contains('golden_ratio')) return '/assets/features/facial-symmetry.jpg';
  if (asset.contains('showdown')) return '/assets/features/attractiveness.jpg';
  if (asset.contains('seasonal')) return '/assets/features/face-beauty.jpg';
  if (asset.contains('upload_selfie')) return '/assets/lifestyle/value-scan.jpg';
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

void _writeHomePage(Directory outRoot, String header, String footer) {
  final indexHtml = File('website/index.html');
  if (!indexHtml.existsSync()) {
    stderr.writeln('Missing website/index.html for homepage body extraction.');
    exit(1);
  }
  final raw = indexHtml.readAsStringSync();
  final mainStart = raw.indexOf('<main>');
  final mainEnd = raw.indexOf('</main>');
  if (mainStart < 0 || mainEnd < 0 || mainEnd <= mainStart) {
    stderr.writeln('Could not find <main> in website/index.html');
    exit(1);
  }
  var mainBody = raw.substring(mainStart + 6, mainEnd).trim();
  mainBody = mainBody
      .replaceAll('href="assets/', 'href="/assets/')
      .replaceAll('src="assets/', 'src="/assets/')
      .replaceAll('src="images/', 'src="/assets/');

  _writePage(
    path: '${outRoot.path}${Platform.pathSeparator}home${Platform.pathSeparator}index.html',
    header: header,
    footer: footer,
    title: VGHomeLandingContent.pageTitle,
    description: VGHomeLandingContent.metaDescription,
    canonicalPath: '/',
    jsonLd: _homeJsonLd(),
    body: mainBody,
  );
}

List<Map<String, dynamic>> _homeJsonLd() {
  return [
    {
      '@context': 'https://schema.org',
      '@type': 'Organization',
      'name': _productName,
      'url': _siteUrl,
      'logo': '$_siteUrl/icons/Icon-512.png',
    },
    {
      '@context': 'https://schema.org',
      '@type': 'WebSite',
      'name': _productName,
      'url': _siteUrl,
      'description': VGHomeLandingContent.metaDescription,
    },
    {
      '@context': 'https://schema.org',
      '@type': 'FAQPage',
      'mainEntity': VGHomeLandingContent.faqs
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
    },
  ];
}
