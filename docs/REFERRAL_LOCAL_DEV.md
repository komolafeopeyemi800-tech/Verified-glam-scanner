# Referral system — local development

Verified Glam referral sharing uses a **local mock** until Unilink and backend attribution are connected.

## Configuration

1. Replace the placeholder in [`lib/utils/vg_constants.dart`](../lib/utils/vg_constants.dart):

   ```dart
   const String vgUnilinkBaseUrl = 'https://YOUR-UNILINK-SUBDOMAIN.unilink.io/verifiedglam';
   ```

2. Create your Unilink smart link in the [Unilink dashboard](https://unilink.io) pointing to the Play Store listing.

## Share bar on all results

As of the Face Comparison rollout, **`VGResultScaffold`** renders `VGShareResultBar` by default (`showReferralShare: true`) on every feature result screen. Celebrity lookalike uses the same centralized `VGReferralService.shareMessageForResult` builder.

## How it works (local)

| Component | Role |
|-----------|------|
| `VGReferralService` | Generates persistent 8-char code, builds `{baseUrl}?ref={code}`, tracks download count |
| `VGReferralBonusStore` | Stores bonus scan credits after redeem |
| `VGShareResultBar` | Share sheet + progress UI on result screens |

### Reward threshold

- Default: **3 referrals** → **5 bonus scans** (`vgReferralRewardThreshold`, `vgReferralBonusScanAmount`)
- Redeem is one-time per install (`vgReferralBonusRedeemedKey`)

### Simulating referrals in dev

When `kVGLocalDevMode = true`:

1. Run Celebrity Lookalike → reach result screen
2. **Long-press** the dev hint under the share bar to increment mock download count (+1)
3. Repeat until **3/3**, then tap **Redeem reward**
4. Bonus scans are stored locally; in production they bypass paywall via `VGSubscriptionStore.shouldShowPaywallBeforeResults`

## Share message format

```
I got matched with {Name} ({Percent}% similarity) on Verified Glam!
Use my referral link to find your celebrity look-alike and download the app: {unilink}?ref={CODE}
```

## Production wiring (later)

- [ ] Replace mock download counter with Unilink webhook / backend
- [ ] Add `app_links` to handle incoming `?ref=` on first open
- [ ] Wire `VGShareResultBar` on other feature result screens
- [ ] Set `kVGLocalDevMode = false` before release
