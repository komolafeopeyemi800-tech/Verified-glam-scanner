# Beauty Tips API payload contract

When the vision API is integrated, return JSON matching this shape (mock uses the same structure in `buildMockResultPayload`).

## `spots[]` (source of truth for hero labels)

Each detected blemish / concern area on the portrait:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | string | yes | Stable id, e.g. `spot_1` |
| `categoryId` | string | yes | Catalog id: `acne`, `hyperpigmentation`, `texture_scars`, `aging`, `sensitivity`, `oily_pores`, `dryness`, `uneven_tone` |
| `label` | string | yes | Short overlay text: `Pimple`, `Dark spot`, `Bump`, etc. |
| `anchor` | `{x, y}` | yes | Normalized 0–1 coordinates on the portrait |
| `severity` | string | yes | `high`, `medium`, or `low` |
| `confidence` | number | no | 0–1 model confidence |
| `labelSide` | string | no | `left`, `right`, `top`, `bottom` — auto-derived from anchor if omitted |
| `color` | int | no | ARGB; falls back to catalog category color |

## Derived fields (server or client)

- **`annotations[]`** — one row per spot for `VGSkinConcernOverlay`: `{ text, anchor, labelSide, color, spotId }`
- **`findings[]`** — grouped by `categoryId`: `{ categoryId, categoryName, severity, shortLabel, spotCount, anchor, labelSide, color }`
- **`tips[]`** — from [`VGBeautyTipsCatalog`](../../lib/data/vg_beauty_tips_catalog.dart) per finding severity
- **`summary`**, **`globalDisclaimer`**

## Integration stub

In [`lib/utils/vg_mock_results.dart`](../../lib/utils/vg_mock_results.dart):

```dart
// if (kVGBeautyTipsApiEnabled) return VGBeautyTipsApi.analyze(photoPath!, detectedFaces);
return _beautyTipsPayload(s, detectedFaces: detectedFaces);
```
