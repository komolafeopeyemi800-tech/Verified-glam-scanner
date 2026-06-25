# Asset audit

Verified Glam bundles only assets referenced by the active app flow. Legacy Beauty Master salon template images were removed.

## Active bundle (`images/`)
- **Brand:** `verified_glam_logo.png` (splash)
- **Walkthrough:** `model_one.jpg`, `model_two.jpg`, `model_three.jpg` (owner-provided originals)
- **Onboarding:** `notification.png`, `welcome.png`
- **Auth:** `google_logo.png`, `ic_apple.png`, `ic_facebook.svg`, `ic_twitter.svg`
- **Locales:** `flag/ic_us.png`, `ic_hi.png`, `ic_ar.png`, `ic_fr.png`
- **Product:** `images/vg/` — feature thumbs, guidelines, upload hero, mock celebrities/showdown

## Placeholder script
`tool/create_placeholder_assets.ps1` only creates missing files from the list above (not deleted salon/nav assets).
