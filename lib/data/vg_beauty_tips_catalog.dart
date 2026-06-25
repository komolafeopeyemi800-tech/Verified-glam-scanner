/// Skin concern categories and community-style tips (non-medical).
/// Source: docs/source/face_beauty_tips_ai_guide.md
class VGBeautyTipEntry {
  final String title;
  final String body;

  const VGBeautyTipEntry({required this.title, required this.body});
}

class VGBeautyCategoryDef {
  final String id;
  final String name;
  final String shortLabel;
  final int color;
  final double anchorX;
  final double anchorY;
  final String labelSide;
  final List<String> issueTags;

  const VGBeautyCategoryDef({
    required this.id,
    required this.name,
    required this.shortLabel,
    required this.color,
    required this.anchorX,
    required this.anchorY,
    required this.labelSide,
    this.issueTags = const [],
  });

  Map<String, double> get anchor => {'x': anchorX, 'y': anchorY};
}

/// Normalized offset from face-box center (multiply by half-width / half-height).
class VGBeautyFaceZone {
  final String id;
  final double dx;
  final double dy;
  final String? preferredSide;

  const VGBeautyFaceZone({
    required this.id,
    required this.dx,
    required this.dy,
    this.preferredSide,
  });
}

class VGBeautyTipsCatalog {
  VGBeautyTipsCatalog._();

  static const categoryIds = [
    'acne',
    'hyperpigmentation',
    'texture_scars',
    'aging',
    'sensitivity',
    'oily_pores',
    'dryness',
    'uneven_tone',
  ];

  static const categories = <VGBeautyCategoryDef>[
    VGBeautyCategoryDef(
      id: 'acne',
      name: 'Acne & Breakouts',
      shortLabel: 'Breakout',
      color: 0xFFE07A9A,
      anchorX: 0.32,
      anchorY: 0.48,
      labelSide: 'left',
      issueTags: ['pimples', 'blackheads', 'whiteheads', 'bumps'],
    ),
    VGBeautyCategoryDef(
      id: 'hyperpigmentation',
      name: 'Hyperpigmentation & Dark Spots',
      shortLabel: 'Dark spot',
      color: 0xFF8B6B4A,
      anchorX: 0.68,
      anchorY: 0.44,
      labelSide: 'right',
      issueTags: ['dark spots', 'PIH', 'melasma', 'uneven marks'],
    ),
    VGBeautyCategoryDef(
      id: 'texture_scars',
      name: 'Texture & Scars',
      shortLabel: 'Texture',
      color: 0xFF9C8575,
      anchorX: 0.38,
      anchorY: 0.62,
      labelSide: 'left',
      issueTags: ['rough skin', 'scars', 'pores', 'bumps'],
    ),
    VGBeautyCategoryDef(
      id: 'aging',
      name: 'Aging & Fine Lines',
      shortLabel: 'Fine lines',
      color: 0xFF6B7A8A,
      anchorX: 0.62,
      anchorY: 0.30,
      labelSide: 'right',
      issueTags: ['wrinkles', 'lines', 'sagging', 'eye bags'],
    ),
    VGBeautyCategoryDef(
      id: 'sensitivity',
      name: 'Sensitivity & Redness',
      shortLabel: 'Redness',
      color: 0xFFE57373,
      anchorX: 0.55,
      anchorY: 0.50,
      labelSide: 'right',
      issueTags: ['redness', 'flushing', 'irritation'],
    ),
    VGBeautyCategoryDef(
      id: 'oily_pores',
      name: 'Oily Skin & Pores',
      shortLabel: 'Oily zone',
      color: 0xFF7CB9A8,
      anchorX: 0.50,
      anchorY: 0.40,
      labelSide: 'top',
      issueTags: ['shine', 'large pores', 'oiliness'],
    ),
    VGBeautyCategoryDef(
      id: 'dryness',
      name: 'Dry & Dehydrated Skin',
      shortLabel: 'Dry patch',
      color: 0xFF5B8DEF,
      anchorX: 0.35,
      anchorY: 0.58,
      labelSide: 'left',
      issueTags: ['flaking', 'tightness', 'dullness', 'peeling'],
    ),
    VGBeautyCategoryDef(
      id: 'uneven_tone',
      name: 'Uneven Skin Tone',
      shortLabel: 'Uneven tone',
      color: 0xFFC5A373,
      anchorX: 0.65,
      anchorY: 0.55,
      labelSide: 'right',
      issueTags: ['blotchiness', 'patchy tone', 'discoloration'],
    ),
  ];

  static VGBeautyCategoryDef? categoryById(String id) {
    for (final c in categories) {
      if (c.id == id) return c;
    }
    return null;
  }

  /// Face zones for per-spot mock placement (offsets relative to face center).
  static const faceZones = <VGBeautyFaceZone>[
    VGBeautyFaceZone(id: 'forehead', dx: 0.0, dy: -0.48, preferredSide: 'top'),
    VGBeautyFaceZone(id: 'left_cheek', dx: -0.42, dy: 0.02),
    VGBeautyFaceZone(id: 'right_cheek', dx: 0.42, dy: 0.02),
    VGBeautyFaceZone(id: 'nose', dx: 0.0, dy: -0.08, preferredSide: 'top'),
    VGBeautyFaceZone(id: 'chin', dx: 0.0, dy: 0.42),
    VGBeautyFaceZone(id: 'under_eye_l', dx: -0.22, dy: -0.22),
    VGBeautyFaceZone(id: 'under_eye_r', dx: 0.22, dy: -0.22),
    VGBeautyFaceZone(id: 'jaw_l', dx: -0.32, dy: 0.28),
    VGBeautyFaceZone(id: 'jaw_r', dx: 0.32, dy: 0.28),
    VGBeautyFaceZone(id: 'temple_l', dx: -0.48, dy: -0.18),
    VGBeautyFaceZone(id: 'temple_r', dx: 0.48, dy: -0.18),
    VGBeautyFaceZone(id: 'mouth_area', dx: 0.0, dy: 0.18),
  ];

  static const _spotLabelFromTag = <String, String>{
    'pimples': 'Pimple',
    'blackheads': 'Blackhead',
    'whiteheads': 'Whitehead',
    'bumps': 'Bump',
    'dark spots': 'Dark spot',
    'pih': 'Dark mark',
    'melasma': 'Dark patch',
    'uneven marks': 'Spot',
    'rough skin': 'Rough patch',
    'scars': 'Scar',
    'pores': 'Pores',
    'wrinkles': 'Fine lines',
    'lines': 'Lines',
    'sagging': 'Loose skin',
    'eye bags': 'Under-eye',
    'redness': 'Redness',
    'flushing': 'Flush',
    'irritation': 'Irritation',
    'shine': 'Shine',
    'large pores': 'Large pores',
    'oiliness': 'Oily spot',
    'flaking': 'Flaking',
    'tightness': 'Dry patch',
    'dullness': 'Dull patch',
    'peeling': 'Peeling',
    'blotchiness': 'Blotch',
    'patchy tone': 'Uneven tone',
    'discoloration': 'Discoloration',
  };

  /// Short overlay label for a detected spot (from issue tags).
  static String spotLabelFor(String categoryId, int seedIndex) {
    final cat = categoryById(categoryId);
    if (cat == null) return 'Spot';
    if (cat.issueTags.isEmpty) return cat.shortLabel;
    final tag = cat.issueTags[seedIndex % cat.issueTags.length];
    return _spotLabelFromTag[tag.toLowerCase()] ??
        tag[0].toUpperCase() + tag.substring(1);
  }

  static List<VGBeautyTipEntry> tipsFor(String categoryId, String severity) {
    return _tips[categoryId]?[severity] ?? const [];
  }

  static VGBeautyTipEntry? pickTip(String categoryId, String severity, int index) {
    final list = tipsFor(categoryId, severity);
    if (list.isEmpty) return null;
    return list[index % list.length];
  }

  static const Map<String, Map<String, List<VGBeautyTipEntry>>> _tips = {
    'acne': {
      'high': [
        VGBeautyTipEntry(
          title: 'Try a raw honey mask',
          body:
              'Many people in the beauty community apply a thin layer of raw honey for 20–30 minutes before rinsing. Some say it helped calm painful breakouts over a few weeks of consistent use.',
        ),
        VGBeautyTipEntry(
          title: 'Gentle cold compress',
          body:
              'Wrapping an ice cube in a clean cloth and pressing it gently on swollen spots for a few minutes may help reduce redness. Creators often mention this before filming.',
        ),
        VGBeautyTipEntry(
          title: 'Diluted apple cider vinegar toner',
          body:
              'Mix one part apple cider vinegar with three parts water, dab with a cotton pad after cleansing, and see how your skin responds. Start once a day.',
        ),
        VGBeautyTipEntry(
          title: 'Simplify your routine',
          body:
              'When breakouts flare up, many people strip back to a gentle cleanser and lightweight moisturizer for two to three weeks to reduce irritation.',
        ),
      ],
      'medium': [
        VGBeautyTipEntry(
          title: 'Spot treat with tea tree oil',
          body:
              'Dilute a drop of tea tree oil and dab on individual spots with a cotton swab. Many creators share this as an overnight trick that may reduce redness by morning.',
        ),
        VGBeautyTipEntry(
          title: 'Green tea toner',
          body:
              'Brew green tea, cool it, and use it as a toner. Some users say regular use made mild breakouts look less noticeable over time.',
        ),
        VGBeautyTipEntry(
          title: 'Wash pillowcases often',
          body:
              'Switching to a clean cotton pillowcase every two to three days is a simple habit many creators credit for fewer cheek and jawline breakouts.',
        ),
        VGBeautyTipEntry(
          title: 'Clay mask once a week',
          body:
              'A weekly clay or charcoal mask may help with congestion. People often say skin looks cleaner after regular use.',
        ),
      ],
      'low': [
        VGBeautyTipEntry(
          title: 'Lukewarm water cleanse',
          body:
              'Many people say switching to lukewarm water and a gentle cleanser morning and night helped occasional breakouts over time.',
        ),
        VGBeautyTipEntry(
          title: 'Rice water rinse',
          body:
              'Soak rice in water for 15–20 minutes, strain, and rinse your face. Asian beauty creators often share this for a clearer-looking complexion.',
        ),
        VGBeautyTipEntry(
          title: 'Hands off your face',
          body:
              'Being mindful about not touching your face through the day may reduce how often new spots appear, according to many users.',
        ),
        VGBeautyTipEntry(
          title: 'Aloe vera gel moisturizer',
          body:
              'Pure aloe vera gel is a fan favourite for lightweight hydration that some say helps keep occasional breakouts calmer.',
        ),
      ],
    },
    'hyperpigmentation': {
      'high': [
        VGBeautyTipEntry(
          title: 'Turmeric and honey mask',
          body:
              'Mix a pinch of turmeric with honey, apply to dark areas for about 15 minutes, and rinse. Many creators rave about brighter-looking skin over consistent weeks.',
        ),
        VGBeautyTipEntry(
          title: 'Daily sunscreen',
          body:
              'Many people say daily SPF was the biggest change for fading dark marks and preventing new ones — even on cloudy days.',
        ),
        VGBeautyTipEntry(
          title: 'Potato slice rub',
          body:
              'Some creators gently rub raw potato slices on dark spots daily. It has a following in natural beauty communities.',
        ),
        VGBeautyTipEntry(
          title: 'Diluted lemon rinse',
          body:
              'A few drops of lemon in water on a cotton pad may help some people brighten dark areas — always patch test first.',
        ),
      ],
      'medium': [
        VGBeautyTipEntry(
          title: 'Cucumber under eyes',
          body:
              'Cool cucumber slices for 10–15 minutes are a classic trick many users say freshened under-eye darkness over time.',
        ),
        VGBeautyTipEntry(
          title: 'Aloe on dark marks',
          body:
              'Pure aloe vera on post-blemish marks is gentle for daily use; many say marks faded gradually.',
        ),
        VGBeautyTipEntry(
          title: 'Rice water brightening',
          body:
              'Rice water as a toner after cleansing is popular for a more even-looking tone with regular use.',
        ),
        VGBeautyTipEntry(
          title: 'Cold spoons for circles',
          body:
              'Chilled spoons under the eyes in the morning may help dark circles look less pronounced, creators often share.',
        ),
      ],
      'low': [
        VGBeautyTipEntry(
          title: 'Consistent cleansing',
          body:
              'Sticking to morning and evening cleanse helped many people with faint marks look more even over time.',
        ),
        VGBeautyTipEntry(
          title: 'Drink more water',
          body:
              'Increasing water intake is widely mentioned for a brighter overall complexion within a few weeks.',
        ),
        VGBeautyTipEntry(
          title: 'Rose water toner',
          body:
              'Rose water after cleansing may help mild tone unevenness while leaving skin feeling soft.',
        ),
        VGBeautyTipEntry(
          title: 'Prioritize sleep',
          body:
              'Many creators say 7–8 hours of sleep made dark circles and dullness look noticeably better.',
        ),
      ],
    },
    'texture_scars': {
      'high': [
        VGBeautyTipEntry(
          title: 'Rosehip oil massage',
          body:
              'Rosehip oil massaged into textured areas at night is popular; many creators report smoother-looking skin over months of use.',
        ),
        VGBeautyTipEntry(
          title: 'Gentle baking soda scrub',
          body:
              'A very gentle baking soda paste once a week may help surface texture — go lightly and skip if skin feels sensitive.',
        ),
        VGBeautyTipEntry(
          title: 'Raw honey healing mask',
          body:
              'Honey on scarred areas a few times a week is widely shared among creators dealing with textured skin.',
        ),
        VGBeautyTipEntry(
          title: 'Nightly aloe on scars',
          body:
              'Aloe vera gel nightly on pitted areas is one of the most talked-about natural repair tips online.',
        ),
      ],
      'medium': [
        VGBeautyTipEntry(
          title: 'Egg white pore mask',
          body:
              'A thin egg white mask for 10–15 minutes may temporarily tighten pores and smooth mild texture.',
        ),
        VGBeautyTipEntry(
          title: 'Sugar and coconut scrub',
          body:
              'A gentle sugar scrub once a week helped many users with rough patches look smoother over time.',
        ),
        VGBeautyTipEntry(
          title: 'Vitamin E on shallow scars',
          body:
              'Massaging vitamin E oil at night is a go-to many creators mention for softer-looking skin.',
        ),
        VGBeautyTipEntry(
          title: 'Stay moisturized',
          body:
              'Consistent moisturizer morning and night often makes scars and texture look less prominent.',
        ),
      ],
      'low': [
        VGBeautyTipEntry(
          title: 'Ice cube massage',
          body:
              'An ice cube in a cloth massaged gently may tighten pores and smooth mild texture instantly.',
        ),
        VGBeautyTipEntry(
          title: 'Cold green tea rinse',
          body:
              'Cool green tea splashed after cleansing is loved for a refined, smoother appearance.',
        ),
        VGBeautyTipEntry(
          title: 'Weekly gentle exfoliation',
          body:
              'A soft washcloth in circular motions once a week may reduce dead-skin buildup on mild roughness.',
        ),
        VGBeautyTipEntry(
          title: 'Coconut oil on rough spots',
          body:
              'A small amount on dry rough patches nightly helped some users smooth mild texture over time.',
        ),
      ],
    },
    'aging': {
      'high': [
        VGBeautyTipEntry(
          title: 'Daily facial massage',
          body:
              'Upward circular massage for 5–10 minutes daily is underrated; many anti-aging creators say it improved firmness over time.',
        ),
        VGBeautyTipEntry(
          title: 'Facial yoga',
          body:
              'Simple cheek and brow exercises held for a few seconds are popular for toning facial muscles with daily practice.',
        ),
        VGBeautyTipEntry(
          title: 'Egg white firming mask',
          body:
              'Egg white masks that dry on the skin are a widely shared tightening trick from home-beauty traditions.',
        ),
        VGBeautyTipEntry(
          title: 'Rose water cucumber compress',
          body:
              'Cold rose water and cucumber on cheeks and eyes may reduce puffiness and tiredness with regular use.',
        ),
      ],
      'medium': [
        VGBeautyTipEntry(
          title: 'Daily SPF',
          body:
              'Sun protection is among the top tips creators credit for slowing early lines and jawline softening.',
        ),
        VGBeautyTipEntry(
          title: 'Castor and rosehip oil',
          body:
              'A drop of castor mixed with rosehip massaged into lines at night may leave skin looking plumper.',
        ),
        VGBeautyTipEntry(
          title: 'Gua sha massage',
          body:
              'Upward gua sha strokes are said to improve circulation and give a lifted look over time.',
        ),
        VGBeautyTipEntry(
          title: 'Hydration and less salt',
          body:
              'More water and less salty processed food often gets credit for reduced puffiness in a few weeks.',
        ),
      ],
      'low': [
        VGBeautyTipEntry(
          title: 'Banana honey mask',
          body:
              'Mashed banana with honey for 15 minutes is a DIY favourite for a plumper, youthful glow.',
        ),
        VGBeautyTipEntry(
          title: 'Sleep on your back',
          body:
              'Back sleeping is recommended to avoid sleep lines becoming permanent creases.',
        ),
        VGBeautyTipEntry(
          title: 'Moisturize while damp',
          body:
              'Applying moisturizer on slightly damp skin may make fine lines look less visible quickly.',
        ),
        VGBeautyTipEntry(
          title: 'Aloe and vitamin E at night',
          body:
              'Aloe with a drop of vitamin E before bed is widely loved for fresher-looking mornings.',
        ),
      ],
    },
    'sensitivity': {
      'high': [
        VGBeautyTipEntry(
          title: 'Minimal routine reset',
          body:
              'Many people with reactive skin went back to cleanser plus plain moisturizer for two to four weeks to calm redness.',
        ),
        VGBeautyTipEntry(
          title: 'Fresh aloe gel',
          body:
              'Aloe straight from the plant is a top soother creators with sensitive skin often prefer over many products.',
        ),
        VGBeautyTipEntry(
          title: 'Oat milk rinse',
          body:
              'Blended oats strained into water used as a rinse may help calm persistent redness over time.',
        ),
        VGBeautyTipEntry(
          title: 'Skip hot water and steam',
          body:
              'Cooler face washing and avoiding steam helped many people look less red day to day.',
        ),
      ],
      'medium': [
        VGBeautyTipEntry(
          title: 'Chamomile compress',
          body:
              'Cooled chamomile tea on a cloth pressed on red areas may soothe mild flushing within minutes.',
        ),
        VGBeautyTipEntry(
          title: 'Fragrance-free swap',
          body:
              'Cutting fragranced skincare is a common tip; many saw improvement after swapping products.',
        ),
        VGBeautyTipEntry(
          title: 'Cold rose water mist',
          body:
              'Rose water in the fridge spritzed when skin heats up is popular for flushing-prone skin.',
        ),
        VGBeautyTipEntry(
          title: 'Green tea on red areas',
          body:
              'Cool green tea on a cotton pad may calm redness; creators mention it often for reactive skin.',
        ),
      ],
      'low': [
        VGBeautyTipEntry(
          title: 'Lukewarm water only',
          body:
              'Lukewarm cleansing avoids the pink flush some people get from very hot or cold water.',
        ),
        VGBeautyTipEntry(
          title: 'Pat dry gently',
          body:
              'Patting with a soft towel instead of rubbing reduced everyday redness for many users.',
        ),
        VGBeautyTipEntry(
          title: 'Aloe before moisturizer',
          body:
              'A thin aloe layer under moisturizer may keep occasionally sensitive skin calmer all day.',
        ),
        VGBeautyTipEntry(
          title: 'Mind spicy food on flare days',
          body:
              'Some people notice more redness after very spicy meals and adjust diet during reactive phases.',
        ),
      ],
    },
    'oily_pores': {
      'high': [
        VGBeautyTipEntry(
          title: 'Clay mask routine',
          body:
              'Clay masks two to three times a week are among the top tips for heavy shine and visible pores.',
        ),
        VGBeautyTipEntry(
          title: 'Blotting papers',
          body:
              'Blotting through the day without disturbing makeup helped many creators control grease.',
        ),
        VGBeautyTipEntry(
          title: 'Cleanse twice daily only',
          body:
              'Over-washing can trigger more oil; twice daily with a gentle cleanser is widely recommended.',
        ),
        VGBeautyTipEntry(
          title: 'Weekly honey mask',
          body:
              'Raw honey once a week may balance oil while keeping skin soft, many users say.',
        ),
      ],
      'medium': [
        VGBeautyTipEntry(
          title: 'Rice water toner',
          body:
              'Rice water after morning cleanse may help mattify and control midday shine.',
        ),
        VGBeautyTipEntry(
          title: 'Witch hazel toner',
          body:
              'Witch hazel after cleansing may reduce shine and tighten the look of pores over time.',
        ),
        VGBeautyTipEntry(
          title: 'Tomato pulp mask',
          body:
              'Fresh tomato on the face for 10 minutes is a home remedy some say balanced oil production.',
        ),
        VGBeautyTipEntry(
          title: 'Fresh pillowcases',
          body:
              'Changing pillowcases every few days surprised many oily-skin creators with fewer breakouts.',
        ),
      ],
      'low': [
        VGBeautyTipEntry(
          title: 'Cool water finish',
          body:
              'Ending your cleanse with cool water may keep mild T-zone shine at bay longer.',
        ),
        VGBeautyTipEntry(
          title: 'Aloe as moisturizer',
          body:
              'Aloe gel hydrates without heaviness — popular for mildly oily skin.',
        ),
        VGBeautyTipEntry(
          title: 'Egg white weekly',
          body:
              'A light egg white mask once a week may tighten pores that contribute to shine.',
        ),
        VGBeautyTipEntry(
          title: 'Avoid touching face',
          body:
              'Hands transfer oil onto the face; many say this habit reduced mild shine over time.',
        ),
      ],
    },
    'dryness': {
      'high': [
        VGBeautyTipEntry(
          title: 'Avocado honey mask',
          body:
              'Mashed avocado with honey for 20 minutes is a popular deep moisture treatment for very dry skin.',
        ),
        VGBeautyTipEntry(
          title: 'Coconut oil at night',
          body:
              'A thin layer of coconut oil before bed helped many people wake up to softer skin.',
        ),
        VGBeautyTipEntry(
          title: 'Drink water consistently',
          body:
              'Eight glasses daily is often credited for better hydration levels within a few weeks.',
        ),
        VGBeautyTipEntry(
          title: 'Oat milk rinse',
          body:
              'Oat water as a rinse after washing may leave extremely dry skin feeling soothed, not tight.',
        ),
      ],
      'medium': [
        VGBeautyTipEntry(
          title: 'Moisturize on damp skin',
          body:
              'Applying moisturizer while skin is slightly damp locks in more hydration for longer.',
        ),
        VGBeautyTipEntry(
          title: 'Banana milk mask',
          body:
              'Banana with milk for 15 minutes a few times a week may add glow to dull dry skin.',
        ),
        VGBeautyTipEntry(
          title: 'Aloe and rose water toner',
          body:
              'Equal parts aloe and rose water after cleansing may keep skin hydrated through the day.',
        ),
        VGBeautyTipEntry(
          title: 'Warm not hot showers',
          body:
              'Cooler showers and lukewarm face washing helped many with chronic dryness feel comfortable.',
        ),
      ],
      'low': [
        VGBeautyTipEntry(
          title: 'Rose water mist',
          body:
              'A spritz when skin feels tight refreshes without heaviness.',
        ),
        VGBeautyTipEntry(
          title: 'Rice water for glow',
          body:
              'Rice water toner may help slightly dry skin look more nourished with daily use.',
        ),
        VGBeautyTipEntry(
          title: 'Cucumber water',
          body:
              'Cucumber-infused water is a wellness trick many link to plumper-looking skin.',
        ),
        VGBeautyTipEntry(
          title: 'Never skip moisturizer',
          body:
              'Daily lightweight moisturizer prevents mild dryness from getting worse, creators say.',
        ),
      ],
    },
    'uneven_tone': {
      'high': [
        VGBeautyTipEntry(
          title: 'Turmeric yogurt mask',
          body:
              'Turmeric with yogurt for 10–15 minutes is a traditional brightening mask many creators share.',
        ),
        VGBeautyTipEntry(
          title: 'Aloe twice daily',
          body:
              'Aloe morning and evening may help blotchy skin look more balanced over weeks.',
        ),
        VGBeautyTipEntry(
          title: 'Green tea compress',
          body:
              'Cool green tea on patchy areas may reduce uneven redness with regular application.',
        ),
        VGBeautyTipEntry(
          title: 'Sun protection daily',
          body:
              'SPF and hats outdoors made a visible difference for many with heavy uneven tone.',
        ),
      ],
      'medium': [
        VGBeautyTipEntry(
          title: 'Diluted ACV toner',
          body:
              'One part apple cider vinegar to three parts water may help mild patchiness with daily use.',
        ),
        VGBeautyTipEntry(
          title: 'Tomato lemon rinse',
          body:
              'Tomato juice with a little diluted lemon on uneven areas — patch test first.',
        ),
        VGBeautyTipEntry(
          title: 'Honey oat scrub',
          body:
              'Honey and oats once a week may gently even texture and tone.',
        ),
        VGBeautyTipEntry(
          title: 'Manage stress',
          body:
              'Sleep and stress care are often mentioned when redness and patchiness calm down.',
        ),
      ],
      'low': [
        VGBeautyTipEntry(
          title: 'Potato juice brightener',
          body:
              'Potato juice on patchy spots with a cotton pad may help a more uniform look over weeks.',
        ),
        VGBeautyTipEntry(
          title: 'Rose water daily',
          body:
              'Rose water morning and evening may soften mild unevenness.',
        ),
        VGBeautyTipEntry(
          title: 'Eat colorful produce',
          body:
              'More fruits and vegetables is linked by many creators to naturally evened tone over time.',
        ),
        VGBeautyTipEntry(
          title: 'Rice water toner',
          body:
              'Daily rice water is a consistent favourite for brightening and evening mild blotchiness.',
        ),
      ],
    },
  };
}
