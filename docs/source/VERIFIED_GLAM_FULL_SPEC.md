# Verified Glam — Complete Product Documentation
### "Beauty Made Perfect" | "Pretty in Every Way" | "Your Perfect Pretty Glow"

---

## Document Purpose

This document serves as the **complete product specification and development guide** for **Verified Glam**, an AI-powered beauty analysis mobile application. It is intended for the full development team including:

- **Mobile Developers** (Android — React Native via Cursor IDE)
- **Backend Developers** (API integration, database, server logic)
- **AI/ML Integration Engineers** (OpenAI API implementation)
- **QA Engineers** (test scenarios and acceptance criteria)
- **Product Managers** (feature scope and priorities)

The goal is to build a **production-ready Android app** that is fully publishable to the **Google Play Store**, with no ambiguity about how each screen, feature, flow, and interaction should work.

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Tech Stack & Tools](#2-tech-stack--tools)
3. [App Architecture](#3-app-architecture)
4. [Project Folder Structure](#4-project-folder-structure)
5. [Onboarding Flow](#5-onboarding-flow)
6. [Authentication & User Management](#6-authentication--user-management)
7. [Main Dashboard](#7-main-dashboard)
8. [Photo Upload & Scanning Flow](#8-photo-upload--scanning-flow)
9. [Feature Specifications](#9-feature-specifications)
10. [OpenAI API Integration](#10-openai-api-integration)
11. [Monetization Strategy](#11-monetization-strategy)
12. [Subscription & Pro Plan](#12-subscription--pro-plan)
13. [Google AdMob Integration](#13-google-admob-integration)
14. [Navigation Structure](#14-navigation-structure)
15. [Database Schema](#15-database-schema)
16. [Backend API Endpoints](#16-backend-api-endpoints)
17. [Push Notifications](#17-push-notifications)
18. [App Settings & Profile](#18-app-settings--profile)
19. [Google Play Store Submission](#19-google-play-store-submission)
20. [Development Milestones](#20-development-milestones)

---

## 1. Project Overview

### App Identity
| Property | Value |
|----------|-------|
| **App Name** | Verified Glam |
| **Primary Slogan** | Beauty Made Perfect |
| **Secondary Slogans** | Pretty in Every Way / Your Perfect Pretty Glow |
| **Platform** | Android (Google Play Store) |
| **Development Tool** | Cursor IDE |
| **Framework** | React Native (with Expo or bare workflow) |
| **Target Audience** | Women & beauty-conscious individuals aged 16–45 |
| **Monetization** | Freemium (Ads + Pro Subscription) |

### App Purpose
Verified Glam is an AI-powered beauty analysis app that:
- Analyzes users' facial features using AI (OpenAI Vision API)
- Provides personalized beauty scores, insights, and recommendations
- Offers multiple scan types (Beauty Analysis, Celebrity Look-Alike, Color Analysis, etc.)
- Helps users improve their look with tutorials and product recommendations
- Monetizes through Google AdMob ads (free tier) and Pro subscription (ad-free + premium features)

### Core Value Proposition
> "Most users complain that existing beauty apps don't give them real value. Verified Glam combines the best features of all top apps into one, giving users genuine confidence-boosting insights and actionable beauty recommendations."

---

## 2. Tech Stack & Tools

### Development
| Layer | Technology |
|-------|-----------|
| **IDE** | Cursor (AI-powered code editor) |
| **Framework** | React Native (bare workflow) |
| **Language** | TypeScript |
| **Navigation** | React Navigation v6 |
| **State Management** | Zustand or Redux Toolkit |
| **Styling** | StyleSheet API + NativeWind (Tailwind for RN) |

### Backend & Services
| Service | Purpose |
|---------|---------|
| **Convex Auth** | User authentication (email, Google sign-in) |
| **convex Firestore** | User data, scan history, profiles |
| **Convex Storage** | User photo storage |
| **OpenAI API (GPT-4 Vision)** | Facial analysis, beauty scoring, recommendations |
| **Google AdMob** | In-app advertising for free users |
| **RevenueCat** | Subscription management & in-app purchases |
| **Convex** | Push notifications |

### External APIs
| API | Purpose |
|-----|---------|
| **OpenAI GPT-4 Vision** | Image analysis and AI-generated beauty insights |
| **Google AdMob SDK** | Banner and interstitial ads |
| **RevenueCat SDK** | Cross-platform subscription management |

### Development Dependencies
```json
{
  "react-native": "0.73+",
  "typescript": "5.0+",
  "@react-navigation/native": "^6.0",
  "@react-navigation/stack": "^6.0",
  "@react-navigation/bottom-tabs": "^6.0",
  "convex": "^10.0",
  "zustand": "^4.0",
  "react-native-image-picker": "^7.0",
  "react-native-purchases": "^6.0",
  "react-native-google-mobile-ads": "^13.0",
  "react-native-vision-camera": "^4.0",
  "axios": "^1.6",
  "react-native-async-storage": "^1.21",
  "react-native-reanimated": "^3.0",
  "react-native-gesture-handler": "^2.0",
  "lottie-react-native": "^6.0"
}
```

---

## 3. App Architecture

### High-Level Architecture
```
┌─────────────────────────────────────────────┐
│               VERIFIED GLAM APP             │
│                                             │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  │
│  │  Screen  │  │  State   │  │ Services │  │
│  │  Layer   │  │ Manager  │  │  Layer   │  │
│  │(React    │  │(Zustand) │  │(convex │  │
│  │ Native)  │  │          │  │ OpenAI   │  │
│  └──────────┘  └──────────┘  │ AdMob    │  │
│                               │ RevCat)  │  │
│                               └──────────┘  │
└─────────────────────────────────────────────┘
         ↓              ↓              ↓
   UI Components    App State      External APIs
```

### Data Flow
```
User Opens App
      ↓
Check Auth State (convex)
      ↓
[New User]              [Returning User]
      ↓                       ↓
Onboarding Flow         Check Subscription
      ↓                       ↓
Questionnaire          [Free] Show Ads
      ↓                [Pro]  Skip Ads
Photo Upload                  ↓
      ↓               Main Dashboard
OpenAI Analysis               ↓
      ↓               Select Feature
Show Ad (Free)                ↓
OR Skip (Pro)          Upload Photo
      ↓                       ↓
Display Results        OpenAI Processing
      ↓                       ↓
Save to History        Show Ad (Free Only)
      ↓                       ↓
Subscription Prompt    Display Results
(if free user)                ↓
                       Save Scan History
```

---

## 4. Project Folder Structure

```
verified-glam/
├── src/
│   ├── screens/
│   │   ├── onboarding/
│   │   │   ├── SplashScreen.tsx
│   │   │   ├── WelcomeCarousel.tsx
│   │   │   ├── AgeScreen.tsx
│   │   │   ├── GenderScreen.tsx
│   │   │   ├── BeautyGoalsScreen.tsx
│   │   │   ├── SkinConcernsScreen.tsx
│   │   │   ├── ProductPreferencesScreen.tsx
│   │   │   ├── EthnicityScreen.tsx
│   │   │   ├── SkinTypeScreen.tsx
│   │   │   ├── AestheticScreen.tsx
│   │   │   └── ProfileReadyScreen.tsx
│   │   ├── auth/
│   │   │   ├── LoginScreen.tsx
│   │   │   └── SignUpScreen.tsx
│   │   ├── main/
│   │   │   ├── HomeScreen.tsx
│   │   │   ├── ScansScreen.tsx
│   │   │   ├── ProfileScreen.tsx
│   │   │   └── SettingsScreen.tsx
│   │   ├── features/
│   │   │   ├── FaceBeautyAnalysisScreen.tsx
│   │   │   ├── CelebrityLookAlikeScreen.tsx
│   │   │   ├── FacialSymmetryScreen.tsx
│   │   │   ├── BeautyScoreShowdownScreen.tsx
│   │   │   ├── FacialResemblanceScreen.tsx
│   │   │   ├── FaceReadingScreen.tsx
│   │   │   ├── BeautyTipsScreen.tsx
│   │   │   ├── BestFacePartScreen.tsx
│   │   │   ├── GoldenRatioScreen.tsx
│   │   │   ├── ColorAnalysisScreen.tsx
│   │   │   └── GlowUpGuideScreen.tsx
│   │   ├── scan/
│   │   │   ├── PhotoGuidelinesScreen.tsx
│   │   │   ├── PhotoUploadScreen.tsx
│   │   │   ├── ProcessingScreen.tsx
│   │   │   └── ResultsScreen.tsx
│   │   └── subscription/
│   │       ├── PaywallScreen.tsx
│   │       └── SubscriptionSuccessScreen.tsx
│   ├── components/
│   │   ├── common/
│   │   │   ├── Button.tsx
│   │   │   ├── ProgressBar.tsx
│   │   │   ├── LoadingOverlay.tsx
│   │   │   ├── FeatureCard.tsx
│   │   │   └── AdBanner.tsx
│   │   ├── onboarding/
│   │   │   ├── QuestionHeader.tsx
│   │   │   ├── OptionButton.tsx
│   │   │   └── MultiSelectGrid.tsx
│   │   └── results/
│   │       ├── ScoreDisplay.tsx
│   │       ├── AnalysisCard.tsx
│   │       └── RecommendationCard.tsx
│   ├── navigation/
│   │   ├── AppNavigator.tsx
│   │   ├── OnboardingNavigator.tsx
│   │   ├── MainTabNavigator.tsx
│   │   └── FeatureNavigator.tsx
│   ├── store/
│   │   ├── userStore.ts
│   │   ├── scanStore.ts
│   │   └── subscriptionStore.ts
│   ├── services/
│   │   ├── convex/
│   │   │   ├── auth.ts
│   │   │   ├── firestore.ts
│   │   │   └── storage.ts
│   │   ├── openai/
│   │   │   ├── beautyAnalysis.ts
│   │   │   ├── celebrityMatch.ts
│   │   │   ├── colorAnalysis.ts
│   │   │   └── prompts.ts
│   │   ├── admob/
│   │   │   └── ads.ts
│   │   └── revenuecat/
│   │       └── subscription.ts
│   ├── hooks/
│   │   ├── useAuth.ts
│   │   ├── useSubscription.ts
│   │   ├── useScan.ts
│   │   └── useAds.ts
│   ├── utils/
│   │   ├── imageUtils.ts
│   │   ├── validators.ts
│   │   └── constants.ts
│   └── types/
│       ├── user.types.ts
│       ├── scan.types.ts
│       └── subscription.types.ts
├── assets/
│   ├── images/
│   ├── animations/
│   └── fonts/
├── android/
├── ios/
├── app.json
├── package.json
├── tsconfig.json
└── .env
```

---

## 5. Onboarding Flow

### Overview
The onboarding flow runs **only once** when a user first installs the app. It collects personalization data to improve AI recommendations. Progress is saved locally so users can resume if they close the app mid-onboarding.

### Screen 1: Splash Screen
**File:** `SplashScreen.tsx`
**Duration:** 2.5 seconds (auto-advance)

**Content:**
- App logo "Verified Glam" (script/cursive font)
- Tagline: "Beauty Made Perfect"
- Animated face scan wireframe (Lottie animation)
- Loading progress bar at bottom

**Logic:**
```typescript
// On mount:
1. Check if user has completed onboarding (AsyncStorage key: 'onboarding_complete')
2. Check convex Auth state
   - If logged in + onboarding complete → Navigate to MainTabNavigator
   - If logged in + onboarding incomplete → Resume onboarding at last step
   - If not logged in → Navigate to WelcomeCarousel
3. Auto-advance after 2.5 seconds
```

---

### Screen 2: Welcome Carousel (3 slides)
**File:** `WelcomeCarousel.tsx`

**Slide 1:**
- Headline: "Pretty Up Now"
- Description: "Transform your look in seconds and get tutorials on your dream glow up"
- Illustration: Decorative hand mirror with sparkle effects
- CTA: "Continue" button
- Pagination dots: ● ○ ○

**Slide 2:**
- Headline: "Discover Your Features"
- Description: "Unlock detailed insights, customized tips, and personalized products for your face"
- Illustration: Face with scan brackets and checkmark
- CTA: "Continue" button
- Pagination dots: ○ ● ○

**Slide 3:**
- Headline: "Built By Experts"
- Description: "Made with ❤️ by top beauty and tech pros for the best results"
- Illustration: Three professional figures
- CTA: "Get Started" button
- Pagination dots: ○ ○ ●

**Interaction:**
- Swipe left/right to navigate between slides
- Tapping "Continue" advances to next slide
- Tapping "Get Started" on slide 3 → Navigate to AgeScreen
- Skip button (top right) on slides 2 & 3 → Jump to AgeScreen

---

### Screen 3: Age Selection
**File:** `AgeScreen.tsx`
**Progress:** Step 1 of 9

**Content:**
- Progress bar at top (showing ~11% filled)
- Headline: "Age"
- Description: "The following questions will be used to personalize your recommendations"
- Dropdown selector showing current value (default: 16)
- Age range: 13–65+
- CTA: "Continue" button (fixed at bottom)

**Data Saved:** `userProfile.age`

---

### Screen 4: Gender Selection
**File:** `GenderScreen.tsx`
**Progress:** Step 2 of 9

**Content:**
- Back arrow (top left) + Progress bar
- Headline: "Gender"
- Description: "Gender-specific characteristics can influence your skincare and makeup"
- Options (large rounded buttons, full width):
  - Female
  - Male
  - Non-binary
  - Other

**Interaction:**
- Tapping any option immediately advances to next screen (no separate "Continue" button needed)

**Data Saved:** `userProfile.gender`

---

### Screen 5: Beauty Goals
**File:** `BeautyGoalsScreen.tsx`
**Progress:** Step 3 of 9

**Content:**
- Headline: "Beauty Goals"
- Description: "Your goals drive our recommendations to provide targeted advice"
- Instruction: "Check all that apply"
- Options (multi-select checkboxes):
  - Find the best products for me
  - Get my personalized Pretty Glow guide
  - Do my color analysis
  - Try new beauty trends
  - Other
- CTA: "Continue" button

**Interaction:**
- Users can select multiple options
- Selected state: filled pink background with white checkmark
- Unselected state: white background with pink border
- At least one selection required before Continue is enabled

**Data Saved:** `userProfile.beautyGoals[]`

---

### Screen 6: Skin Concerns
**File:** `SkinConcernsScreen.tsx`
**Progress:** Step 4 of 9

**Content:**
- Headline: "Skin Concerns"
- Description: "85% of 12-24 year olds experience acne and 60% experience other skin issues"
- Instruction: "Check all that apply (or skip)"
- Options (multi-select pill buttons, 2-column grid):
  - Acne
  - Wrinkles
  - Dark Spots
  - Redness
  - Dryness
  - Oiliness
  - Sensitive Skin
  - Other
- CTA: "Continue" button
- Skip option available (back arrow or skip text)

**Data Saved:** `userProfile.skinConcerns[]`

---

### Screen 7: Product Preferences
**File:** `ProductPreferencesScreen.tsx`
**Progress:** Step 5 of 9

**Content:**
- Headline: "Product Preferences"
- Description: "76% of users select specific products to match beauty preferences"
- Instruction: "Check all that apply (or skip)"
- Options (multi-select pill buttons):
  - Fragrance-free
  - Hypo-allergenic
  - Sulfate-free
  - Vegan
  - Cruelty-free
  - Organic
  - Asian Products
  - European Products
- CTA: "Continue" button

**Data Saved:** `userProfile.productPreferences[]`

---

### Screen 8: Skin Type
**File:** `SkinTypeScreen.tsx`
**Progress:** Step 6 of 9

**Content:**
- Headline: "Skin Type"
- Description: "Choose the option that best describes your skin"
- Options (single select, full-width buttons):
  - Normal
  - Dry
  - Oily
  - Combination
  - Not Sure

**Interaction:**
- Single selection only
- Tapping advances immediately

**Data Saved:** `userProfile.skinType`

---

### Screen 9: Ethnicity Selection
**File:** `EthnicityScreen.tsx`
**Progress:** Step 7 of 9

**Content:**
- Headline: "Ethnicity"
- Description: "Different ethnicities have unique skin characteristics and concerns"
- Instruction: "Check all that apply"
- Options (multi-select):
  - East Asian
  - South Asian
  - Black/African Descent
  - Hispanic/Latino
  - Middle Eastern
  - Native American
  - Pacific Islander
  - White/Caucasian
  - Other
  - Prefer not to say
- CTA: "Continue" button

**Data Saved:** `userProfile.ethnicity[]`

---

### Screen 10: Aesthetic Preference
**File:** `AestheticScreen.tsx`
**Progress:** Step 8 of 9

**Content:**
- Headline: "Aesthetic"
- Description: "Choose your desired look for your glow up"
- Horizontal carousel of swipeable cards:

**Card 1: Soft Girl**
- Example image showing soft, dreamy aesthetic
- Title: "Soft Girl"
- Description: "A delicate, dreamy look with gentle colors and sweetness"
- Button: "Select"

**Card 2: Glow**
- Example image
- Title: "Glow"
- Description: "Bold, confident, striking with dramatic features"
- Button: "Select"

**Card 3: Natural**
- Example image
- Title: "Natural"
- Description: "Clean, minimal, fresh and effortless appearance"
- Button: "Select"

**Card 4: Bold/Edgy**
- Example image
- Title: "Bold"
- Description: "Dramatic, artistic and expressive look"
- Button: "Select"

**Card 5: Classic**
- Example image
- Title: "Classic"
- Description: "Timeless, polished and sophisticated"
- Button: "Select"

**Card 6: Choose For Me**
- Illustration with pointing hand
- Title: "Choose For Me"
- Description: "Let us choose for you based on your features"
- Button: "Select"

**Interaction:**
- Swipe left/right to view cards
- Pagination dots at bottom showing position
- Tapping "Select" saves preference and advances

**Data Saved:** `userProfile.aestheticPreference`

---

### Screen 11: Rating Request
**File:** Built into onboarding flow
**Progress:** Step 8.5 of 9 (shown between aesthetic and profile ready)

**Content:**
- Headline: "Leave a rating!"
- Description: "We're a small team, so a rating goes a really long way!"
- Illustration: Thumbs up with stars around it
- CTA: "Leave a rating!" button → Opens Google Play Store rating dialog
- Skip: Back arrow available

**Logic:**
```typescript
// Use react-native-rate or in-app review API
import InAppReview from 'react-native-in-app-review';

const requestReview = () => {
  if (InAppReview.isAvailable()) {
    InAppReview.RequestInAppReview();
  }
};
```

---

### Screen 12: Allow Notifications
**File:** Built into onboarding
**Progress:** Step 8.7 of 9

**Content:**
- Headline: "Allow Notifications"
- Description: "Get updated with the latest features and personalized tips!"
- Illustration: Paper plane with notification badge
- CTA: "Enable notifications!" button
- Skip: Back arrow

**Logic:**
```typescript
import messaging from '@react-native-convex/messaging';

const requestNotificationPermission = async () => {
  const authStatus = await messaging().requestPermission();
  const enabled =
    authStatus === messaging.AuthorizationStatus.AUTHORIZED ||
    authStatus === messaging.AuthorizationStatus.PROVISIONAL;
  
  if (enabled) {
    const fcmToken = await messaging().getToken();
    // Save fcmToken to Firestore user document
    await saveUserFCMToken(userId, fcmToken);
  }
};
```

---

### Screen 13: Processing/Setup Screen
**File:** `ProcessingScreen.tsx`

**Content:**
- Animated loading indicator (pink dot expanding)
- Text: "Setting up everything"
- Subtext: "Almost ready..."

**Logic:**
```typescript
// On this screen:
1. Save all collected onboarding data to Firestore
2. Create user profile document
3. Set AsyncStorage key 'onboarding_complete' = true
4. Auto-navigate after setup completes (1.5-3 seconds)
5. Navigate to ProfileReadyScreen
```

---

### Screen 14: Profile Ready
**File:** `ProfileReadyScreen.tsx`

**Content:**
- Headline: "Profile Ready"
- Description: "Based on your answers, we'll ensure our scans focus on:"
- Three highlighted cards:
  1. **Personalized Recommendations** — Get tailored product suggestions matched to your skin type, skin tone, and other facial features
  2. **Technique Improvement** — Master techniques for blush, eye makeup, foundation and many more
  3. **Understand Your Face** — Learn about your face shape, eye shape and more. Use that to do your makeup in the best way for your face
- CTA: "Get started" button

**Action on "Get started":**
→ Navigate to PaywallScreen (subscription prompt)

---

### Screen 15: Paywall / Subscription Prompt
**File:** `PaywallScreen.tsx`
**Shown:** After onboarding + after every 3 free feature uses

*(Full details in Section 12)*

---

## 6. Authentication & User Management

### Auth Strategy
- **Anonymous/Guest Usage:** Users can complete onboarding without signing in
- **Account Creation:** Prompted when saving first scan result
- **Sign-in Methods:** Email/Password, Google Sign-In

### Auth Flow
```typescript
// convex Auth implementation
import auth from '@react-native-convex/auth';

// Google Sign-In
import { GoogleSignin } from '@react-native-google-signin/google-signin';

GoogleSignin.configure({
  webClientId: 'YOUR_WEB_CLIENT_ID', // from convex console
});

const signInWithGoogle = async () => {
  await GoogleSignin.hasPlayServices();
  const { idToken } = await GoogleSignin.signIn();
  const googleCredential = auth.GoogleAuthProvider.credential(idToken);
  return auth().signInWithCredential(googleCredential);
};
```

### User Data Structure (Firestore)
```typescript
// Collection: 'users'
// Document ID: convex Auth UID

interface UserDocument {
  uid: string;
  email: string;
  displayName: string;
  photoURL?: string;
  createdAt: Timestamp;
  lastActiveAt: Timestamp;
  fcmToken: string;
  
  profile: {
    age: number;
    gender: 'female' | 'male' | 'non-binary' | 'other';
    beautyGoals: string[];
    skinConcerns: string[];
    productPreferences: string[];
    skinType: 'normal' | 'dry' | 'oily' | 'combination' | 'not_sure';
    ethnicity: string[];
    aestheticPreference: string;
    onboardingComplete: boolean;
  };
  
  subscription: {
    isProUser: boolean;
    plan: 'free' | 'weekly' | 'monthly' | 'annual';
    expiresAt: Timestamp | null;
    revenueCatUserId: string;
  };
  
  stats: {
    totalScans: number;
    lastScanDate: Timestamp;
  };
}
```

---

## 7. Main Dashboard

### Bottom Tab Navigator
**File:** `MainTabNavigator.tsx`

**Tabs:**
1. **Home** (house icon) → HomeScreen
2. **Scans** (face scan icon) → ScansScreen

*(Settings accessible via gear icon on Home top right)*

---

### Home Screen
**File:** `HomeScreen.tsx`

**Layout:**
- **Header:** "Verified Glam" logo (top left) + Settings gear icon (top right)
- **Greeting:** "Ready to Glam Up?" / "Pretty in Every Way"
- **Subtext:** "Choose a scan to start"
- **Feature Cards Carousel:** Horizontally swipeable feature cards (3 visible)
- **Pagination dots** below carousel
- **Bottom tab bar**

**Feature Cards on Carousel:**

Each card contains:
- Illustration/icon in pink circle
- Feature name + emoji
- Short description
- "Start scan" button

**Card 1: Color Analysis 🎨**
- Icon: Face with color wheel brackets
- Description: "Find your color season and your perfect colors"
- CTA: "Start scan"

**Card 2: Glow Up Guide ✨**
- Icon: Face with sparkle brackets
- Description: 'See yourself "Glamed Up" and get a guide'
- CTA: "Start scan"

**Card 3: Facial Analysis 🔬**
- Icon: Face with measurement brackets
- Description: "Facial analysis & makeup recommendations"
- CTA: "Start scan"

*(More cards accessible by scrolling)*

**Additional Features Grid (below carousel):**
A 2-column grid showing all features:
- Celebrity Look Alike 🌟 (HOT badge)
- Facial Symmetry (NEW badge)
- Beauty Score Showdown 👑 (HOT badge)
- Facial Resemblance
- Face Reading
- Beauty Tips 🎁
- Best Face Part
- Golden Ratio Score

**Settings Bottom Sheet (when gear icon tapped):**
- Share (share icon)
- Invite code (copy icon)
- Contact support (email icon)
- Follow us on IG (Instagram icon)
- Privacy policy (lock icon)

---

### Scans Screen
**File:** `ScansScreen.tsx`

**Empty State (no scans yet):**
- Headline: "No Scans Yet"
- Description: "Do a scan and then come back to see all your scans!"
- CTA: "Select a scan" button

**Populated State:**
- List of previous scans with thumbnail, date, scan type
- Tapping a scan → Opens saved results
- Pull to refresh
- Delete scan option (long press)

---

## 8. Photo Upload & Scanning Flow

### Step 1: Feature Selection → Photo Guidelines
When user taps "Start scan" on any feature card:
1. Check subscription status
2. If premium feature AND free user → Show PaywallScreen
3. If free feature OR pro user → Navigate to PhotoGuidelinesScreen

### Step 2: Photo Guidelines Screen
**File:** `PhotoGuidelinesScreen.tsx`

**Content:**
- Pink info box titled "Do's & Don'ts:"
  - 👀 Look straight at the camera
  - 💡 Use good lighting
  - 🐶 Don't use any filters
  - 🕶️ Don't wear hats or glasses
  - 🧕 Don't cover your face (bangs too!)
- **Good Examples** section: 3 sample photos with green ✅ badge
- **Bad Examples** section: 3 sample photos with red ❌ badge
- CTA: "Continue" button

---

### Step 3: Photo Upload Screen
**File:** `PhotoUploadScreen.tsx`

**Content:**
- Back arrow
- Headline: "Upload Photo"
- Description: "Take or upload a clear photo of your face"
- Privacy note: "We will NEVER share your image without your consent"
- Circular face illustration with camera icon
- CTA: "Upload or take a selfie" (large pink button)

**On Button Tap:**
```typescript
import { launchCamera, launchImageLibrary } from 'react-native-image-picker';

const handlePhotoAction = () => {
  // Show action sheet: Camera or Gallery
  ActionSheet.show({
    options: ['Take a selfie', 'Choose from gallery', 'Cancel'],
    cancelButtonIndex: 2,
  }, (index) => {
    if (index === 0) launchCamera(options, handleResponse);
    if (index === 1) launchImageLibrary(options, handleResponse);
  });
};

// Image picker options
const options = {
  mediaType: 'photo',
  quality: 0.8,
  maxWidth: 1024,
  maxHeight: 1024,
  includeBase64: true, // Needed for OpenAI API
};
```

---

### Step 4: Processing Screen
**File:** `ProcessingScreen.tsx`

**Visual Design:** 
- Dark background (#1A1A1A)
- Animated geometric face wireframe (neon green lines, Lottie animation)
- Scanning line moving up and down
- Text: "Verified Glam"
- Subtext: "Analyzing your beauty..."
- Progress bar at bottom

**Processing Logic:**
```typescript
const processImage = async (imageBase64: string, featureType: string) => {
  try {
    // 1. Upload image to convex Storage
    const imageUrl = await uploadImageToStorage(userId, imageBase64);
    
    // 2. Call OpenAI API
    const analysisResult = await analyzeWithOpenAI(imageBase64, featureType);
    
    // 3. Save results to Firestore
    await saveScanResult(userId, {
      featureType,
      imageUrl,
      results: analysisResult,
      createdAt: new Date(),
    });
    
    // 4. Navigate based on subscription status
    if (isProUser) {
      // Skip ad, go directly to results
      navigation.replace('ResultsScreen', { results: analysisResult });
    } else {
      // Show interstitial ad, then results
      await showInterstitialAd();
      navigation.replace('ResultsScreen', { results: analysisResult });
    }
  } catch (error) {
    // Handle error, show retry option
    showErrorAlert('Analysis failed. Please try again.');
  }
};
```

---

### Step 5: Ad Display (Free Users Only)
**Trigger:** After OpenAI processing completes, BEFORE showing results
**Ad Type:** Full-screen interstitial ad (Google AdMob)

```typescript
import { InterstitialAd, AdEventType, TestIds } from 'react-native-google-mobile-ads';

const adUnitId = __DEV__ 
  ? TestIds.INTERSTITIAL 
  : 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX'; // Your AdMob ID

const interstitial = InterstitialAd.createForAdRequest(adUnitId, {
  requestNonPersonalizedAdsOnly: true,
});

// Show ad before results
const showAdBeforeResults = async () => {
  return new Promise((resolve) => {
    interstitial.addAdEventListener(AdEventType.CLOSED, () => {
      resolve(true); // Ad closed, navigate to results
    });
    
    interstitial.addAdEventListener(AdEventType.ERROR, () => {
      resolve(false); // Ad failed, still show results
    });
    
    if (interstitial.loaded) {
      interstitial.show();
    } else {
      resolve(false); // Ad not loaded, skip
    }
  });
};
```

---

### Step 6: Results Screen
**File:** `ResultsScreen.tsx`

**General Layout (adapts per feature):**
- Back arrow + Feature title
- Analyzed photo (circular crop with overlay)
- Score/result prominently displayed
- Detailed breakdown sections
- Recommendations
- Share button
- "Scan again" button
- For free users: Banner ad at bottom

---

## 9. Feature Specifications

### Feature 1: Face Beauty Analysis
**Type:** Free (basic) + Pro (detailed)
**OpenAI Prompt:** See Section 10

**Results Display:**
- **Overall Beauty Score:** Large number display (e.g., "8.4/10")
- **Feature Scores (Pro):**
  - Eyes: X/10
  - Nose: X/10
  - Lips: X/10
  - Cheekbones: X/10
  - Jawline: X/10
  - Skin: X/10
- **Face Shape:** Detected shape (Oval, Round, Square, Heart, Diamond, Oblong)
- **Skin Tone:** Detected skin tone description
- **Top Compliments:** 3 positive things about the face
- **Improvement Areas (Pro):** Suggestions for enhancement
- **Makeup Recommendations (Pro):** Specific product suggestions
- **Share:** Generate shareable card with score

---

### Feature 2: Celebrity Look Alike
**Type:** Premium (Pro only)
**Badge:** HOT 🔥

**Results Display:**
- Top 3 celebrity matches
- Each match shows:
  - Celebrity name
  - Similarity percentage (e.g., "72%")
  - Progress bar for percentage
  - "You share similar [feature] with [celebrity name]"
- Swipeable match cards
- Tips to achieve each celebrity's look

---

### Feature 3: Facial Symmetry Analysis
**Type:** Premium (Pro only)
**Badge:** NEW

**Results Display:**
- Symmetry percentage score
- Visual: Left half vs right half comparison (mirrored face)
- Feature-by-feature symmetry scores:
  - Eye symmetry
  - Nose symmetry
  - Lip symmetry
  - Facial width symmetry
- Contouring tips to enhance symmetry
- "Your most symmetrical feature is..."

---

### Feature 4: Beauty Score Showdown
**Type:** Premium (Pro only)
**Badge:** HOT 🔥

**Results Display:**
- Leaderboard-style display
- User's position vs. anonymous other users
- Podium display (1st, 2nd, 3rd place with crown)
- User's score percentile: "You score higher than X% of users"
- Strengths comparison
- Weekly refresh of leaderboard

---

### Feature 5: Facial Resemblance
**Type:** Premium (Pro only)

**Flow:**
1. Upload first photo (self)
2. Upload second photo (friend/family/celebrity)
3. AI compares both

**Results Display:**
- "VS" split-screen showing both photos
- Overall resemblance percentage
- Feature-by-feature similarity:
  - Eye shape: X% similar
  - Nose: X% similar
  - Lip shape: X% similar
  - Face shape: X% similar
  - Skin tone: Match/Partial/Different

---

### Feature 6: Face Reading
**Type:** Premium (Pro only)

**Results Display:**
- Head diagram with labeled zones
- Trait categories with descriptions:
  - **Career:** "Your strong cheekbones suggest natural leadership ability"
  - **Love/Relationships:** Based on lip shape and eye characteristics
  - **Health Indicators:** Based on skin and facial features
  - **Personality:** 3-5 key traits
  - **Friends:** Your social nature based on facial features
  - **Wealth Indicators:** Traditional face reading insights
- Disclaimer: "For entertainment purposes"

---

### Feature 7: Beauty Tips
**Type:** Free (basic) + Pro (detailed with products)

**Results Display:**
- Personalized to user's skin type and concerns from profile
- Categories (tabs):
  - Skincare Routine
  - Makeup Tips
  - Hair Suggestions
  - Product Recommendations
- Each tip card includes:
  - Tip title
  - Description
  - Step-by-step instructions
  - Recommended products (with affiliate links for monetization)
- Pro users see product links and video tutorials

---

### Feature 8: Best Face Part
**Type:** Free

**Results Display:**
- Large highlighted photo with star indicator on best feature
- "Your best feature is: [FEATURE NAME]"
- Why it's special (2-3 sentences)
- "How to make it pop" — 3-5 tips
- Product recommendations to enhance
- Share button: "My best feature is my [feature] — Verified Glam"

---

### Feature 9: Golden Ratio Face Score
**Type:** Premium (Pro only)

**Results Display:**
- Golden ratio score: X.XX/10
- Visual overlay of golden ratio grid on user's face
- Explanation of golden ratio (brief)
- Which features align perfectly
- Which features deviate slightly
- "The golden ratio perfect score is 10. You scored X"
- Contouring and makeup techniques to approach golden ratio

---

### Feature 10: Color Analysis
**Type:** Premium (Pro only)

**Results Display:**
- Color Season Badge: "You are a [SEASON] ✨"
  - Spring: Warm, light, fresh
  - Summer: Cool, soft, muted
  - Autumn: Warm, deep, rich
  - Winter: Cool, bold, dramatic
- Color palette swatches (12+ colors)
- Section: "Best Makeup Colors"
  - Foundation undertone
  - Best blush shades
  - Best eyeshadow palette
  - Best lip colors
- Section: "Best Clothing Colors"
- Section: "Hair Color Suggestions"
- Section: "Colors to Avoid"

---

### Feature 11: Glow Up Guide
**Type:** Premium (Pro only)
**Badge:** ✨

**Results Display:**
- "Your Personalized Glow Up Guide"
- Before analysis photo displayed
- AI-generated "After" description (what you can achieve)
- 7-Day Plan breakdown:
  - Day 1: Skincare foundation
  - Day 2: Base makeup mastery
  - Day 3: Eye makeup for your eye shape
  - Day 4: Lip care and application
  - Day 5: Contouring for your face shape
  - Day 6: Full glow look
  - Day 7: Review and refine
- Each day has:
  - Goal
  - Steps
  - Products needed
  - Estimated time
- Progress tracking checkboxes

---

## 10. OpenAI API Integration

### Setup
```typescript
// services/openai/client.ts
import axios from 'axios';

const OPENAI_API_KEY = process.env.OPENAI_API_KEY; // Store in .env, never hardcode

export const openaiClient = axios.create({
  baseURL: 'https://api.openai.com/v1',
  headers: {
    'Authorization': `Bearer ${OPENAI_API_KEY}`,
    'Content-Type': 'application/json',
  },
});
```

> ⚠️ **SECURITY NOTE:** Never call OpenAI API directly from the mobile app. Route all OpenAI calls through your own backend server (convex Cloud Functions or Node.js server) to protect your API key.

### Recommended Backend Architecture
```
Mobile App → convex Cloud Function → OpenAI API → Return Result → Mobile App
```

### convex Cloud Functions Setup
```typescript
// functions/src/beautyAnalysis.ts
import * as functions from 'convex-functions';
import OpenAI from 'openai';

const openai = new OpenAI({
  apiKey: functions.config().openai.key,
});

export const analyzeBeauty = functions.https.onCall(async (data, context) => {
  // Verify auth
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be logged in');
  }
  
  const { imageBase64, featureType } = data;
  
  const prompt = getPromptForFeature(featureType);
  
  const response = await openai.chat.completions.create({
    model: 'gpt-4-vision-preview',
    messages: [
      {
        role: 'user',
        content: [
          { type: 'text', text: prompt },
          {
            type: 'image_url',
            image_url: {
              url: `data:image/jpeg;base64,${imageBase64}`,
              detail: 'high',
            },
          },
        ],
      },
    ],
    max_tokens: 1500,
    response_format: { type: 'json_object' }, // Force JSON response
  });
  
  return JSON.parse(response.choices[0].message.content);
});
```

### Prompts by Feature

```typescript
// services/openai/prompts.ts

export const getPromptForFeature = (featureType: string, userProfile?: UserProfile): string => {
  const profileContext = userProfile 
    ? `User profile: Age ${userProfile.age}, Gender: ${userProfile.gender}, 
       Skin type: ${userProfile.skinType}, Skin concerns: ${userProfile.skinConcerns.join(', ')},
       Aesthetic preference: ${userProfile.aestheticPreference}`
    : '';

  const prompts: Record<string, string> = {
    
    FACE_BEAUTY_ANALYSIS: `
      You are an expert AI beauty analyst. Analyze this facial photo and provide a comprehensive beauty analysis.
      ${profileContext}
      
      Return a JSON object with this exact structure:
      {
        "overallScore": (number 1-10 with one decimal),
        "faceShape": (one of: "oval", "round", "square", "heart", "diamond", "oblong"),
        "skinTone": (descriptive string),
        "featureScores": {
          "eyes": (1-10),
          "nose": (1-10),
          "lips": (1-10),
          "cheekbones": (1-10),
          "jawline": (1-10),
          "skin": (1-10)
        },
        "strengths": [(array of 3 positive statements about facial features)],
        "improvements": [(array of 3 constructive suggestions)],
        "makeupRecommendations": {
          "foundation": (shade/undertone recommendation),
          "eyeshadow": (color recommendation for their features),
          "lipColor": (color recommendation),
          "blush": (color and placement recommendation),
          "contouring": (technique specific to their face shape)
        },
        "skincareTips": [(3 personalized skincare tips based on visible skin)],
        "summary": (2-3 sentence encouraging summary)
      }
      
      Be encouraging and positive. Focus on genuine features. 
      Avoid making medical diagnoses or statements.
    `,

    CELEBRITY_LOOK_ALIKE: `
      You are an expert AI celebrity face matching system. Analyze this facial photo and identify celebrities with similar facial features.
      
      Return a JSON object with this exact structure:
      {
        "matches": [
          {
            "celebrityName": (string - real celebrity name),
            "similarity": (number 0-100),
            "sharedFeatures": [(array of 2-3 shared features)],
            "lookTips": [(array of 2 tips to enhance the resemblance)]
          }
        ],
        "dominantFeatures": [(3 most distinctive features of this face)],
        "summary": (encouraging sentence about their unique features)
      }
      
      Provide exactly 3 celebrity matches.
      Only use real, well-known celebrities.
      Be creative but reasonable with matches.
    `,

    FACIAL_SYMMETRY: `
      You are an expert AI facial symmetry analyst. Analyze the symmetry of this facial photo.
      
      Return a JSON object with this exact structure:
      {
        "overallSymmetry": (number 0-100, where 100 is perfectly symmetrical),
        "featureSymmetry": {
          "eyes": (0-100),
          "eyebrows": (0-100),
          "nose": (0-100),
          "lips": (0-100),
          "ears": (0-100),
          "facialWidth": (0-100)
        },
        "mostSymmetrical": (string - the most symmetrical feature),
        "leastSymmetrical": (string - the least symmetrical feature),
        "makeupTips": [(3 makeup contouring tips to enhance symmetry)],
        "factsAboutSymmetry": (interesting fact about facial symmetry),
        "summary": (2 sentence encouraging summary)
      }
    `,

    FACE_READING: `
      You are an expert AI face reader. Analyze this facial photo using traditional physiognomy principles for entertainment.
      
      Return a JSON object with this exact structure:
      {
        "disclaimer": "For entertainment purposes only",
        "faceShape": (string),
        "readings": {
          "personality": [(3 personality traits based on facial features)],
          "career": (career insight based on facial structure),
          "relationships": (relationship trait based on lip and eye characteristics),
          "health": (general wellness observation),
          "social": (social nature insight),
          "leadership": (leadership potential based on facial features)
        },
        "luckyFeature": (your most fortunate facial feature),
        "summary": (2 encouraging sentences)
      }
    `,

    GOLDEN_RATIO: `
      You are an expert AI analyst specializing in the golden ratio (phi = 1.618) as applied to facial aesthetics.
      
      Return a JSON object with this exact structure:
      {
        "overallScore": (number 1-10 with one decimal),
        "proportions": {
          "faceRatio": (description of face height to width ratio),
          "eyeSpacing": (description of eye spacing proportion),
          "noseToLip": (description of nose to lip proportion),
          "lipProportion": (upper to lower lip ratio description)
        },
        "goldenFeatures": [(features that closely match golden ratio)],
        "deviations": [(features that deviate from golden ratio)],
        "improvementTips": [(3 makeup/contouring tips to approach golden ratio)],
        "famousGoldenRatioFaces": [(2 celebrities known for golden ratio features)],
        "summary": (encouraging 2 sentence summary)
      }
    `,

    COLOR_ANALYSIS: `
      You are an expert AI color analyst specializing in seasonal color analysis.
      Analyze this person's coloring (skin tone, implied hair color, eye area) and determine their color season.
      
      Return a JSON object with this exact structure:
      {
        "colorSeason": (one of: "Spring", "Summer", "Autumn", "Winter"),
        "subType": (e.g., "Warm Spring", "Cool Summer", "Deep Autumn", "Bright Winter"),
        "undertone": (one of: "warm", "cool", "neutral"),
        "description": (2 sentence description of their coloring),
        "bestColors": {
          "clothing": [(6 hex color codes that suit them),],
          "makeup": {
            "foundation": (undertone description),
            "blush": [(2 recommended shades)],
            "eyeshadow": [(3 recommended shades)],
            "lipColors": [(3 recommended shades)]
          }
        },
        "colorsToAvoid": [(3 colors that clash with their coloring)],
        "celebrities": [(2 celebrities with the same color season)],
        "shoppingTip": (practical tip for shopping with their color season)
      }
    `,

    BEST_FACE_PART: `
      You are an expert AI beauty analyst. Analyze this facial photo and identify the person's most outstanding facial feature.
      
      Return a JSON object with this exact structure:
      {
        "bestFeature": (one of: "eyes", "lips", "nose", "cheekbones", "jawline", "eyebrows", "skin", "smile"),
        "score": (number 1-10 for this feature),
        "why": (2 sentences explaining why this is their best feature),
        "howToEnhance": [(4 specific tips to make this feature stand out more)],
        "productRecommendations": [(3 product types that would enhance this feature)],
        "celebrityWithSameFeature": (celebrity known for the same feature),
        "summary": (encouraging 1-2 sentence summary)
      }
    `,

    GLOW_UP_GUIDE: `
      You are an expert AI beauty transformation coach. Analyze this facial photo and create a personalized 7-day glow up guide.
      ${profileContext}
      
      Return a JSON object with this exact structure:
      {
        "currentStrengths": [(3 current strengths to build on)],
        "transformationGoal": (overall transformation description),
        "weeklyPlan": [
          {
            "day": 1,
            "focus": (focus area for this day),
            "goal": (what user will achieve),
            "steps": [(3-4 action steps)],
            "products": [(2-3 product types needed)],
            "timeRequired": (estimated minutes)
          }
          // ... days 2-7
        ],
        "longTermTips": [(3 long-term beauty habits to maintain results)],
        "motivationalMessage": (personalized encouraging message)
      }
    `,
  };

  return prompts[featureType] || prompts.FACE_BEAUTY_ANALYSIS;
};
```

---

## 11. Monetization Strategy

### Overview
Verified Glam uses a **dual monetization model:**
1. **Google AdMob** — Interstitial ads shown to free users before results
2. **Pro Subscription** — Ad-free experience + premium features

### Revenue Optimization Strategy
The most effective ad placement is the **post-scan / pre-result interstitial** because:
- User is highly engaged (just submitted their photo)
- They are waiting for results and will watch the ad
- High completion rate = higher CPM revenue
- Creates natural motivation to upgrade to Pro

### Ad Placement Map
```
User Action                     Ad Type              Frequency
─────────────────────────────────────────────────────────────────
After scan processing →         Interstitial Ad      Every scan (free users only)
Home screen (bottom) →          Banner Ad            Always visible (free users)
Scan history screen →           Banner Ad            Always visible (free users)
After rating/review screen →    Interstitial Ad      One-time
```

### Ad Revenue Optimization Tips (for Developer)
1. Load next interstitial ad in background while user is on Processing Screen
2. Use AdMob's Smart Banner for automatic sizing
3. Implement frequency capping (max 3 interstitials per session)
4. Cache banner ads to minimize loading time
5. Use test ad IDs during development, production IDs before release

---

## 12. Subscription & Pro Plan

### Subscription Tiers

| Plan | Price (NGN) | Price (USD approx.) | Features |
|------|-------------|---------------------|----------|
| **Free** | ₦0 | $0 | Basic features + Ads |
| **Weekly Pro** | ₦27,500/week | ~$17/week | All features, No ads |
| **Monthly Pro** | ₦70,500/month | ~$44/month | All features, No ads |
| **Annual Pro (Best Value)** | ₦141,000/year | ~$88/year | All features, No ads |
| **Free Trial** | 3 days free | — | Full Pro access, then weekly billing |

### Free vs Pro Feature Matrix

| Feature | Free | Pro |
|---------|------|-----|
| Face Beauty Analysis (basic score) | ✅ | ✅ |
| Best Face Part | ✅ | ✅ |
| Beauty Tips (limited) | ✅ | ✅ |
| Face Beauty Analysis (full details) | ❌ | ✅ |
| Celebrity Look Alike | ❌ | ✅ |
| Facial Symmetry | ❌ | ✅ |
| Beauty Score Showdown | ❌ | ✅ |
| Facial Resemblance | ❌ | ✅ |
| Face Reading | ❌ | ✅ |
| Golden Ratio Score | ❌ | ✅ |
| Color Analysis | ❌ | ✅ |
| GlOW Up Guide | ❌ | ✅ |
| Ad-Free Experience | ❌ | ✅ |
| Unlimited Scans | ❌ | ✅ |
| Scan History (unlimited) | 10 scans | Unlimited |

### RevenueCat Implementation
```typescript
// services/revenuecat/subscription.ts
import Purchases, { PurchasesPackage } from 'react-native-purchases';

// Initialize RevenueCat
export const initRevenueCat = async (userId: string) => {
  Purchases.configure({
    apiKey: 'your_revenuecat_api_key',
    appUserID: userId,
  });
};

// Get available packages
export const getSubscriptionPackages = async (): Promise<PurchasesPackage[]> => {
  const offerings = await Purchases.getOfferings();
  if (offerings.current !== null) {
    return offerings.current.availablePackages;
  }
  return [];
};

// Purchase subscription
export const purchaseSubscription = async (pkg: PurchasesPackage) => {
  const { customerInfo } = await Purchases.purchasePackage(pkg);
  return customerInfo.entitlements.active['pro'] !== undefined;
};

// Check subscription status
export const checkSubscriptionStatus = async (): Promise<boolean> => {
  const customerInfo = await Purchases.getCustomerInfo();
  return customerInfo.entitlements.active['pro'] !== undefined;
};

// Restore purchases
export const restorePurchases = async () => {
  const customerInfo = await Purchases.restorePurchases();
  return customerInfo.entitlements.active['pro'] !== undefined;
};
```

### Paywall Screen Design Specification
**File:** `PaywallScreen.tsx`

**Shown when:**
1. User completes onboarding
2. User taps a Pro-only feature
3. After 3 free feature uses in one session
4. Every 24 hours (once per day prompt for free users)

**Screen Content:**

**Header Section:**
- Close button (X) top right — allows dismissal
- 3D gift box illustration
- Headline: "Get Premium 👑"
- Subheading: "Unlock all Features"

**Urgency Section:**
- "50% OFF" badge (yellow/gold text)
- "Limited Time Offer"
- "This offer will expire in"
- Countdown timer: `00 : 00 : XX : XX` (Days : Hours : Minutes : Seconds)
- Timer counts down from 30 minutes

**Feature Comparison:**
- Two columns: "Free" | "PRO"
- List all features with ✓ or — indicators

**Pricing Options (radio buttons):**

Option A (pre-selected): "BEST PRICE" badge
- `~~NGN62,000.00~~ → Just ₦31,000.00/year`

Option B:
- "3-Day Free Trial"
- `then ₦27,500.00/week`

**CTA Buttons:**
- Primary: "Start free trial" (large pink/salmon button)
- Secondary: Shield icon + "No payment now"

**Legal Footer:**
- "Subscription Terms: 3-days free trial, then ₦27,500.00 per week. Subscription renews automatically every week unless canceled."
- Clickable: "Terms" and "Privacy Policy"

---

## 13. Google AdMob Integration

### Setup
```bash
# Install AdMob SDK
npm install react-native-google-mobile-ads

# Add to android/build.gradle
buildscript {
  dependencies {
    classpath 'com.google.gms:google-services:4.3.15'
  }
}

# Add to android/app/build.gradle
apply plugin: 'com.google.gms.google-services'

dependencies {
  implementation 'com.google.android.gms:play-services-ads:22.5.0'
}
```

### AndroidManifest.xml Addition
```xml
<manifest>
  <application>
    <!-- Add this inside <application> tag -->
    <meta-data
      android:name="com.google.android.gms.ads.APPLICATION_ID"
      android:value="ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX"/> <!-- Your AdMob App ID -->
  </application>
</manifest>
```

### Ad Units to Create in AdMob Dashboard
1. **Home Banner Ad** — Banner format
2. **Results Interstitial Ad** — Interstitial format (main revenue driver)
3. **Scans History Banner Ad** — Banner format

### Implementation
```typescript
// services/admob/ads.ts
import {
  BannerAd,
  BannerAdSize,
  InterstitialAd,
  AdEventType,
  TestIds,
  MobileAds,
} from 'react-native-google-mobile-ads';

// Initialize AdMob (call once at app startup)
export const initAdMob = async () => {
  await MobileAds().initialize();
};

// Ad Unit IDs
export const AD_UNITS = {
  BANNER_HOME: __DEV__ ? TestIds.BANNER : 'ca-app-pub-XXXX/XXXX',
  BANNER_SCANS: __DEV__ ? TestIds.BANNER : 'ca-app-pub-XXXX/XXXX',
  INTERSTITIAL_RESULTS: __DEV__ ? TestIds.INTERSTITIAL : 'ca-app-pub-XXXX/XXXX',
};

// Interstitial Ad Manager
export class ResultsInterstitialAd {
  private static ad = InterstitialAd.createForAdRequest(
    AD_UNITS.INTERSTITIAL_RESULTS,
    { requestNonPersonalizedAdsOnly: false }
  );

  static preload() {
    this.ad.load(); // Call this during processing screen
  }

  static async show(): Promise<void> {
    return new Promise((resolve) => {
      this.ad.addAdEventListener(AdEventType.CLOSED, () => {
        this.preload(); // Preload next ad
        resolve();
      });
      this.ad.addAdEventListener(AdEventType.ERROR, () => resolve());
      
      if (this.ad.loaded) {
        this.ad.show();
      } else {
        resolve(); // No ad loaded, skip
      }
    });
  }
}
```

### Banner Ad Component
```typescript
// components/common/AdBanner.tsx
import React from 'react';
import { BannerAd, BannerAdSize } from 'react-native-google-mobile-ads';
import { useSubscriptionStore } from '../../store/subscriptionStore';
import { AD_UNITS } from '../../services/admob/ads';

const AdBanner = () => {
  const { isProUser } = useSubscriptionStore();
  
  // Don't show ads to Pro users
  if (isProUser) return null;
  
  return (
    <BannerAd
      unitId={AD_UNITS.BANNER_HOME}
      size={BannerAdSize.ANCHORED_ADAPTIVE_BANNER}
      requestOptions={{ requestNonPersonalizedAdsOnly: false }}
    />
  );
};

export default AdBanner;
```

---

## 14. Navigation Structure

```typescript
// navigation/AppNavigator.tsx

AppNavigator
├── OnboardingStack (shown if onboarding not complete)
│   ├── SplashScreen
│   ├── WelcomeCarousel
│   ├── AgeScreen
│   ├── GenderScreen
│   ├── BeautyGoalsScreen
│   ├── SkinConcernsScreen
│   ├── ProductPreferencesScreen
│   ├── SkinTypeScreen
│   ├── EthnicityScreen
│   ├── AestheticScreen
│   ├── RatingScreen
│   ├── NotificationsScreen
│   ├── ProcessingSetupScreen
│   ├── ProfileReadyScreen
│   └── PaywallScreen
│
└── MainStack (shown after onboarding complete)
    ├── MainTabNavigator
    │   ├── HomeScreen (Tab 1)
    │   └── ScansScreen (Tab 2)
    │
    ├── FeatureStack (pushed from Home feature cards)
    │   ├── PhotoGuidelinesScreen
    │   ├── PhotoUploadScreen
    │   ├── ProcessingScreen
    │   └── ResultsScreen
    │
    ├── SettingsScreen (pushed from gear icon)
    └── PaywallScreen (modal, shown when needed)
```

---

## 15. Database Schema

### Firestore Collections

```
firestore/
├── users/
│   └── {userId}/
│       ├── (UserDocument — see Section 6)
│       └── scans/
│           └── {scanId}/
│               ├── featureType: string
│               ├── imageUrl: string
│               ├── thumbnailUrl: string
│               ├── results: object (varies by feature)
│               ├── createdAt: Timestamp
│               └── shared: boolean
│
├── leaderboard/
│   └── beauty_score_showdown/
│       └── {userId}/
│           ├── score: number
│           ├── displayName: string (anonymous)
│           └── updatedAt: Timestamp
│
└── app_config/
    └── global/
        ├── minimumAppVersion: string
        ├── forceUpdate: boolean
        ├── maintenanceMode: boolean
        └── featuredAesthetic: string
```

---

## 16. Backend API Endpoints

All backend logic is handled via **convex Cloud Functions**.

### Cloud Functions

```typescript
// Available endpoints (HTTPS Callable):

analyzeBeauty(imageBase64, featureType, userProfile)
  → Returns AI analysis result object

saveAnalysisResult(userId, scanData)
  → Saves scan to Firestore, returns scanId

getUserScans(userId, limit, lastDocId)
  → Returns paginated list of user scans

deleteScan(userId, scanId)
  → Deletes scan and associated image from Storage

getLeaderboard(limit)
  → Returns top beauty scores (anonymous)

updateUserProfile(userId, profileData)
  → Updates user profile in Firestore

sendNotification(userId, title, body, data)
  → Sends FCM push notification
```

### Environment Variables (.env)
```env
OPENAI_API_KEY=sk-...
convex_PROJECT_ID=verified-glam
convex_API_KEY=...
ADMOB_APP_ID=ca-app-pub-...
REVENUECAT_API_KEY=...
```

---

## 17. Push Notifications

### Notification Types

| Trigger | Title | Body |
|---------|-------|-------|
| Day after install (no scan) | "Your glow up awaits ✨" | "You haven't done your first beauty scan yet. Try it now — it's free!" |
| 3 days inactive | "Miss us? 💕" | "Your perfect pretty glow is waiting. Come back and scan today!" |
| New feature launch | "New feature available! 🆕" | "Try our new [Feature Name] — find out more about your beautiful face" |
| Subscription expiring | "Your Pro plan expires soon 👑" | "Renew today to keep all your premium features" |
| Weekly reminder | "Weekly Glow Check 🪞" | "Time for your weekly beauty scan! See how you're glowing." |

### Implementation
```typescript
// Schedule local notifications
import notifee from '@notifee/react-native';

export const scheduleEngagementNotification = async () => {
  // Day 1 after install — if no scan
  await notifee.createTriggerNotification(
    {
      title: 'Your glow up awaits ✨',
      body: "You haven't done your first beauty scan yet. Try it now — it's free!",
      android: { channelId: 'default' },
    },
    {
      type: TriggerType.TIMESTAMP,
      timestamp: Date.now() + 24 * 60 * 60 * 1000, // 24 hours
    }
  );
};
```

---

## 18. App Settings & Profile

### Settings Screen Options

**Account Section:**
- Edit Profile (name, email)
- Change Password

**App Section:**
- Notifications (toggle)
- Language (for future multi-language support)

**Subscription Section:**
- Current Plan (shows Free or Pro + expiry date)
- Upgrade to Pro (if free)
- Manage Subscription (if Pro) → Opens RevenueCat management
- Restore Purchases

**Support Section:**
- Share App (native share sheet)
- Invite Code (copy referral code)
- Contact Support (opens email to support@verifiedglam.com)
- Follow us on Instagram
- Rate the App → Opens Play Store

**Legal Section:**
- Privacy Policy (WebView)
- Terms of Service (WebView)

**Danger Zone:**
- Delete Account (with confirmation dialog)

---

## 19. Google Play Store Submission

### App Store Listing Requirements

| Field | Content |
|-------|---------|
| **App Name** | Verified Glam - Beauty Analysis |
| **Short Description** | AI beauty scanner, face analysis & personalized glow up guide |
| **Category** | Lifestyle / Beauty |
| **Content Rating** | Teen (13+) |
| **Pricing** | Free with in-app purchases |

### Full Description (Play Store)
```
✨ Verified Glam — Beauty Made Perfect ✨

Transform your look and discover your true beauty potential with 
Verified Glam, the AI-powered beauty analysis app designed to give 
you real, confidence-boosting insights about your face.

🌟 FEATURES:

📊 Face Beauty Analysis
Get a detailed beauty score and personalized analysis of your facial 
features with AI-powered insights.

🎨 Color Analysis
Discover your color season and find the perfect makeup and clothing 
colors that make you shine.

✨ Glow Up Guide
Get a personalized 7-day beauty transformation guide tailored 
specifically to your face and goals.

⭐ Celebrity Look Alike
Find out which celebrities share your beautiful facial features.

💫 Facial Symmetry
Analyze your facial symmetry and get contouring tips to enhance balance.

🔮 Face Reading
Discover personality traits and characteristics revealed by your features.

📐 Golden Ratio Score
See how your features compare to the mathematical ideal of beauty.

💄 Beauty Tips
Get personalized skincare and makeup tutorials based on your profile.

🏆 Beauty Score Showdown
Compare your beauty score and see how you rank.

Pretty in Every Way — Verified Glam helps you embrace and enhance 
your natural beauty with science-backed AI analysis.

Download now and start your Glow up journey today!
```

### Required Assets for Play Store
- App icon: 512x512 PNG
- Feature graphic: 1024x500 PNG
- Screenshots: Minimum 2, recommended 8 (phone screenshots)
- Video (optional but recommended): 30-120 second promo video

### Permissions Required (explain in Play Store)
- **CAMERA:** To take selfies for beauty analysis
- **READ_EXTERNAL_STORAGE:** To upload photos from gallery
- **INTERNET:** For AI analysis and cloud features
- **RECEIVE_BOOT_COMPLETED:** For scheduled notifications
- **VIBRATE:** For notification feedback

### Privacy Policy Requirements
Must address:
- What photos are collected and how they're stored
- convex data collection
- Google AdMob data collection
- How to delete user data
- Children's privacy (COPPA compliance — minimum age 13)

---

## 20. Development Milestones

### Phase 1 — Foundation (Week 1-2)
- [ ] Project setup with React Native + TypeScript
- [ ] convex configuration (Auth, Firestore, Storage)
- [ ] Navigation structure
- [ ] Splash screen + Welcome carousel
- [ ] Onboarding questionnaire (all 9 steps)
- [ ] Local state management with Zustand

### Phase 2 — Core Features (Week 3-4)
- [ ] Photo upload + camera integration
- [ ] Processing screen with animation
- [ ] OpenAI API integration via Cloud Functions
- [ ] Face Beauty Analysis feature (full)
- [ ] Results screen
- [ ] Save scans to Firestore

### Phase 3 — Premium Features (Week 5-6)
- [ ] Celebrity Look Alike
- [ ] Color Analysis
- [ ] Glow Up Guide
- [ ] Facial Symmetry
- [ ] Face Reading
- [ ] Golden Ratio Score
- [ ] Beauty Score Showdown
- [ ] Best Face Part
- [ ] Beauty Tips

### Phase 4 — Monetization (Week 7)
- [ ] RevenueCat subscription setup
- [ ] Paywall screen
- [ ] Google AdMob integration
- [ ] Interstitial ads before results
- [ ] Banner ads on free screens
- [ ] Pro feature gating

### Phase 5 — Polish & Launch (Week 8)
- [ ] Push notifications
- [ ] Settings screen
- [ ] Profile management
- [ ] App icon + splash screen assets
- [ ] Play Store listing assets
- [ ] Beta testing (internal)
- [ ] Bug fixes from testing
- [ ] Performance optimization
- [ ] Google Play Store submission

---

## Appendix A: Key Constants

```typescript
// utils/constants.ts

export const APP_CONFIG = {
  APP_NAME: 'Verified Glam',
  SLOGANS: [
    'Beauty Made Perfect',
    'Pretty in Every Way',
    'Your Perfect Pretty Glow',
  ],
  FREE_SCAN_LIMIT: 10, // Scans saved in history for free users
  AD_FREQUENCY: 1, // Show ad every N scans
  TRIAL_DAYS: 3,
  SUPPORT_EMAIL: 'support@verifiedglam.com',
  INSTAGRAM_URL: 'https://instagram.com/verifiedglam',
  PRIVACY_POLICY_URL: 'https://verifiedglam.com/privacy',
  TERMS_URL: 'https://verifiedglam.com/terms',
};

export const FEATURES = {
  FREE: ['FACE_BEAUTY_ANALYSIS', 'BEST_FACE_PART', 'BEAUTY_TIPS'],
  PRO: [
    'CELEBRITY_LOOK_ALIKE',
    'FACIAL_SYMMETRY',
    'BEAUTY_SCORE_SHOWDOWN',
    'FACIAL_RESEMBLANCE',
    'FACE_READING',
    'GOLDEN_RATIO',
    'COLOR_ANALYSIS',
    'GLOW_UP_GUIDE',
    'FACE_BEAUTY_ANALYSIS_DETAILED',
  ],
};
```

---

## Appendix B: Testing Checklist

### Before Play Store Submission
- [ ] Test on minimum SDK (Android 7.0 / API 24)
- [ ] Test on latest Android version
- [ ] Test all onboarding screens on small screen (5 inch)
- [ ] Test all onboarding screens on large screen (6.7 inch)
- [ ] Verify ads show correctly for free users
- [ ] Verify ads are hidden for Pro users
- [ ] Test subscription purchase flow
- [ ] Test subscription restore flow
- [ ] Test subscription cancellation
- [ ] Verify all OpenAI prompts return correct JSON
- [ ] Test with poor internet connection
- [ ] Test photo upload with various photo sizes
- [ ] Verify no API keys are exposed in app bundle
- [ ] Test push notifications
- [ ] Verify privacy policy and terms links open correctly
- [ ] Test account deletion flow
- [ ] Verify app handles OpenAI API errors gracefully
- [ ] Test all 11 features end-to-end

---

*Document Version: 1.0*
*App: Verified Glam*
*Slogan: Beauty Made Perfect | Pretty in Every Way | Your Perfect Pretty Glow*
*Last Updated: May 2026*
