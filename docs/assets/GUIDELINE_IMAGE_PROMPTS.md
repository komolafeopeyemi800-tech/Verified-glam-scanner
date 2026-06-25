# Guideline photo assets

**In use:** A single owner-provided composite at `images/vg/guidelines/good_bad_examples.png` (good + bad examples with labels). The app shows this on the photo guidelines screen — no separate six JPGs required.

Upload screen portrait: `images/vg/upload_selfie_portrait.png` only (no `upload_selfie_hero.png`). Shown centered on the rose scaffold with no extra white card behind it.

---

## Legacy: six separate JPG prompts (optional)

If you ever split the composite into individual tiles, generate **6 original JPGs** and save them under `images/vg/guidelines/` with **exact filenames** below. Use ChatGPT Image (or similar) — do not copy competitor screenshots.

## Good examples

### `good_front_light.jpg`

```
Realistic smartphone selfie photo of a woman facing the camera directly, neutral plain background, soft even indoor lighting, no makeup filter, no hat, no sunglasses, hair away from forehead, friendly natural expression, portrait orientation, photorealistic, 4:5 aspect ratio
```

### `good_natural_daylight.jpg`

```
Realistic photo of a man in natural daylight near a window, face clearly visible, slight angle acceptable, eyes open, no filters, no accessories on face, plain background, photorealistic portrait, 4:5 aspect ratio
```

### `good_clear_skin.jpg`

```
Realistic close-up portrait of a woman, full face in frame, hair pulled back from face, clean skin visible, neutral background, natural light, no beauty filter, photorealistic, 4:5 aspect ratio
```

## Bad examples

### `bad_filter.jpg`

```
Realistic portrait with obvious beauty filter applied, over-smoothed skin, unnatural glow, same framing as a good selfie but clearly filtered, photorealistic, 4:5 aspect ratio
```

### `bad_hat_glasses.jpg`

```
Realistic selfie of a person wearing sunglasses or a cap that partially hides eyes and forehead, otherwise normal lighting, photorealistic, 4:5 aspect ratio
```

### `bad_poor_light.jpg`

```
Realistic portrait with harsh shadow on half the face or underexposed dark image where facial features are hard to see, photorealistic, 4:5 aspect ratio
```

## Notes

- Mix gender and skin tones across the set for inclusivity.
- Keep backgrounds plain; no logos or competitor app UI.
- Export as JPG, roughly 400×500 px or larger.
- After adding files, run `flutter pub get` (if needed) and hot restart the app.
