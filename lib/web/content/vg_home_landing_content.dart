import 'vg_tool_landing_content.dart';

/// Homepage marketing copy — ported from website/index.html.
class VGHomeLandingContent {
  static const pageTitle = 'Verified Glam Scanner — AI Beauty Insights from Your Selfie';
  static const metaDescription =
      'Verified Glam Scanner analyzes your selfie with AI for face beauty scores, symmetry, celebrity look-alikes, and personalized glow-up tips. Download on Google Play for Android.';

  static const heroTitle = 'AI beauty insights from your selfie';
  static const heroTagline =
      'Pretty in every way. Upload a photo, get personalized scores, symmetry breakdowns, and glow-up tips powered by AI.';

  static const heroBullets = [
    '11 scan types — from face beauty to color analysis',
    'Results on your photo with face overlays and clear scores',
    'Free tier with optional Pro for full features and no ads',
    'Your photos are processed securely on our servers — never on-device API keys',
  ];

  static const featuredOnTitle = 'Featured on';
  static const featuredOnNote = 'Illustrative placement — not affiliated endorsements.';

  static const valueTitle = 'Ready to discover your glow?';
  static const valueLead =
      'Verified Glam Scanner turns a quick selfie into actionable beauty insights — scores you can understand, tips you can use, and results you can save.';

  static const featuresTitle = 'Everything you need to shine';
  static const featuresLead =
      'From core beauty scores to fun celebrity matches — explore what Verified Glam Scanner can do with one selfie.';

  static const reviewsTitle = 'What Verified Glam Scanner users say about us?';
  static const reviewsNote =
      'Illustrative reviews for design until verified Play Store reviews are available.';

  static const faqTitle = 'Frequently asked questions';

  static const ctaTitle = 'Download Verified Glam Scanner';
  static const ctaBody =
      'Get AI beauty insights on Android — or log in on the web to upload a photo and sync your scan history.';

  static const valueCards = [
    VGHomeValueCard(
      imageAsset: 'images/vg/marketing/lifestyle/value-scan.jpg',
      caption: 'Scan in seconds',
    ),
    VGHomeValueCard(
      imageAsset: 'images/vg/marketing/lifestyle/value-results.jpg',
      caption: 'See results on your photo',
    ),
    VGHomeValueCard(
      imageAsset: 'images/vg/marketing/lifestyle/value-glowup.jpg',
      caption: 'Build your glow-up routine',
    ),
  ];

  static const stats = [
    VGHomeStat(value: '11+', label: 'Beauty scan types'),
    VGHomeStat(value: 'AI', label: 'Personalized results'),
    VGHomeStat(value: '7', label: 'Day glow-up plans'),
  ];

  static const featureRows = [
    VGHomeFeatureRow(
      title: 'Face Beauty Analysis',
      body:
          'Get an overall beauty score with detailed breakdowns across facial features. Your uploaded photo stays front and center with overlays that highlight what the AI detected.',
      imageAsset: 'images/vg/marketing/features/face-beauty.jpg',
      primaryCta: 'Try it now',
      primarySlug: 'face-beauty-analysis',
      secondaryCta: 'Learn more',
      reverse: false,
    ),
    VGHomeFeatureRow(
      title: 'Facial Symmetry',
      body:
          'Understand balance and proportion with a dedicated symmetry scan. Pro users unlock the full symmetry report with visual guides on their selfie.',
      imageAsset: 'images/vg/marketing/features/facial-symmetry.jpg',
      primaryCta: 'Check your symmetry',
      primarySlug: 'facial-symmetry',
      secondaryCta: 'Learn more',
      reverse: true,
    ),
    VGHomeFeatureRow(
      title: 'Celebrity Look-Alike',
      body:
          'See which celebrities share your facial traits — a fun, shareable result powered by AI face analysis. Entertainment only, not identity verification.',
      imageAsset: 'images/vg/marketing/features/celebrity-match.jpg',
      primaryCta: 'Find your match',
      primarySlug: 'celebrity-look-alike',
      secondaryCta: 'Learn more',
      reverse: false,
    ),
    VGHomeFeatureRow(
      title: 'Attractiveness Test',
      body:
          'Explore attractiveness scoring with trait breakdowns and personality-style signals. Results include clear disclaimers — for fun and self-discovery, not medical judgment.',
      imageAsset: 'images/vg/marketing/features/attractiveness.jpg',
      primaryCta: 'Take the test',
      primarySlug: 'attractiveness-test',
      secondaryCta: 'Learn more',
      reverse: true,
    ),
  ];

  static const reviews = [
    VGHomeReviewItem(
      name: 'Amara K.',
      tenure: 'Using for 8 months',
      quote: 'I love seeing my scores right on my own photo — it feels personal, not generic.',
      avatarAsset: 'images/vg/marketing/reviews/avatar-1.jpg',
    ),
    VGHomeReviewItem(
      name: 'Priya S.',
      tenure: 'Using for 6 months',
      quote:
          'The symmetry scan helped me understand my features in a kind, visual way. I use it before makeup routines.',
      avatarAsset: 'images/vg/marketing/reviews/avatar-2.jpg',
    ),
    VGHomeReviewItem(
      name: 'Elena M.',
      tenure: 'Using for 1 year',
      quote:
          'Celebrity look-alike is so fun to share with friends. Glow Up Guide keeps me consistent every week.',
      avatarAsset: 'images/vg/marketing/reviews/avatar-3.jpg',
    ),
  ];

  static const faqs = [
    VGFaqItem(
      question: 'How does Verified Glam Scanner use my photos?',
      answer:
          'You upload a selfie for the scan you choose. Your photo is stored securely and sent to our servers for AI analysis. We do not embed OpenAI or other AI API keys in the app — processing happens server-side only. See our Privacy Policy for details.',
    ),
    VGFaqItem(
      question: 'Is this medical or professional advice?',
      answer:
          'No. Verified Glam Scanner is for entertainment and beauty self-discovery. Face reading, attractiveness scores, and celebrity matches are not medical, dermatological, or psychological assessments. Always consult qualified professionals for health or skin concerns.',
    ),
    VGFaqItem(
      question: 'What is free vs Pro?',
      answer:
          'Free users get basic scans with ads and limited history. Pro subscribers unlock all scan types, remove ads, and receive AI credits (Yearly \$39.99/year with 200 credits, or Pro \$3.99/week with 30 credits weekly). Subscriptions are billed securely through Polar.sh and sync to your account on web and Android.',
    ),
    VGFaqItem(
      question: 'Is Verified Glam Scanner available on iPhone?',
      answer:
          'Verified Glam Scanner is currently available for Android on Google Play only. There is no App Store version at this time.',
    ),
    VGFaqItem(
      question: 'How long is my data kept?',
      answer:
          'Scan photos and results are tied to your account while you use the app. You can delete scans from history in the app. Account deletion requests can be sent to support@verifiedglam.com. See our Privacy Policy for retention details.',
    ),
    VGFaqItem(
      question: 'Who can use the app?',
      answer:
          'Verified Glam Scanner is for adults aged 18 and older. You must be at least 18 to create an account or purchase a Pro subscription. The service is not directed at minors.',
    ),
  ];

  static const pressLogos = [
    'images/vg/marketing/press/allure.svg',
    'images/vg/marketing/press/vogue.svg',
    'images/vg/marketing/press/byrdie.svg',
    'images/vg/marketing/press/cosmopolitan.svg',
    'images/vg/marketing/press/harpers-bazaar.svg',
  ];
}

class VGHomeValueCard {
  final String imageAsset;
  final String caption;

  const VGHomeValueCard({required this.imageAsset, required this.caption});
}

class VGHomeStat {
  final String value;
  final String label;

  const VGHomeStat({required this.value, required this.label});
}

class VGHomeFeatureRow {
  final String title;
  final String body;
  final String imageAsset;
  final String primaryCta;
  final String primarySlug;
  final String secondaryCta;
  final bool reverse;

  const VGHomeFeatureRow({
    required this.title,
    required this.body,
    required this.imageAsset,
    required this.primaryCta,
    required this.primarySlug,
    required this.secondaryCta,
    this.reverse = false,
  });
}

class VGHomeReviewItem {
  final String name;
  final String tenure;
  final String quote;
  final String avatarAsset;

  const VGHomeReviewItem({
    required this.name,
    required this.tenure,
    required this.quote,
    required this.avatarAsset,
  });
}
