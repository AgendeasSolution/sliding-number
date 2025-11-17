# Ad Mediation Setup Guide

This document describes the ad mediation setup for Meta (Facebook), AppLovin, ironSource, and Unity Ads integration via Google AdMob Mediation.

## What Was Added

### Android Configuration

1. **Dependencies Added** (`android/app/build.gradle.kts`):
   - Meta (Facebook) Audience Network Adapter: `6.16.0.0`
   - AppLovin SDK: `12.4.2` + Adapter: `12.4.2.0`
   - ironSource SDK: `8.3.1` + Adapter: `8.3.1.0`
   - Unity Ads SDK: `4.12.3` + Adapter: `4.12.3.0`

2. **Repositories Added** (`android/build.gradle.kts`):
   - AppLovin Maven repository
   - ironSource Maven repository

3. **AndroidManifest.xml**:
   - Added optional placeholders for AppLovin SDK key and ironSource App key (commented out)
   - These can be configured in AdMob console instead

### iOS Configuration

1. **Podfile** (`ios/Podfile`):
   - Meta (Facebook) Audience Network Adapter: `6.16.0.0`
   - AppLovin Adapter: `12.4.2.0`
   - ironSource Adapter: `8.3.1.0`
   - Unity Ads Adapter: `4.12.3.0`

## Next Steps

### 1. Configure AdMob Mediation (Required)

You need to configure the mediation networks in your AdMob console:

1. Go to [AdMob Console](https://apps.admob.com/)
2. Navigate to **Mediation** → **Mediation groups**
3. Select your ad unit or create a new mediation group
4. Add the following ad networks:
   - **Meta Audience Network** (Facebook)
   - **AppLovin MAX**
   - **ironSource**
   - **Unity Ads**

5. For each network, you'll need to:
   - Add your network account credentials (App ID, SDK Key, etc.)
   - Configure eCPM (effective cost per mille) for ad prioritization
   - Set up ad unit mappings

### 2. Install iOS Dependencies

Run the following command in your project root:

```bash
cd ios
pod install
cd ..
```

### 3. Sync Android Dependencies

For Android, the dependencies will be automatically synced when you build the project. However, you can manually sync by:

1. Opening Android Studio
2. Click **File** → **Sync Project with Gradle Files**

Or run:

```bash
cd android
./gradlew build
cd ..
```

### 4. Build and Test

After completing the above steps:

1. **For iOS:**
   ```bash
   flutter clean
   flutter pub get
   cd ios && pod install && cd ..
   flutter run
   ```

2. **For Android:**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

## Important Notes

1. **No Code Changes Required**: Your existing ad code (`InterstitialAdService` and `AdBanner`) will work as-is. AdMob will automatically select the best ad from all configured networks.

2. **Network Credentials**: You'll need to obtain:
   - **AppLovin SDK Key**: From AppLovin dashboard
   - **ironSource App Key**: From ironSource dashboard
   - **Unity Ads Game ID**: From Unity Ads dashboard
   - **Meta App ID**: Already configured (808054202092916)

3. **Testing**: Use AdMob test ad unit IDs during development. The mediation will work with test ads from all networks.

4. **Version Updates**: The adapter versions may need to be updated periodically. Check the [AdMob Mediation documentation](https://developers.google.com/admob/android/mediation) for the latest versions.

## Troubleshooting

### iOS Build Issues

If you encounter pod installation issues:
```bash
cd ios
rm -rf Pods Podfile.lock
pod cache clean --all
pod install
cd ..
```

### Android Build Issues

If you encounter dependency resolution issues:
1. Check that all repositories are correctly configured
2. Ensure you have internet connection for downloading dependencies
3. Try invalidating caches in Android Studio: **File** → **Invalidate Caches / Restart**

### Ad Not Showing

1. Verify mediation is configured in AdMob console
2. Check that network credentials are correctly entered
3. Ensure ad units are properly mapped in mediation groups
4. Check AdMob console for error reports

## Resources

- [AdMob Mediation Documentation](https://developers.google.com/admob/android/mediation)
- [Meta Audience Network Integration](https://developers.facebook.com/docs/audience-network)
- [AppLovin MAX Integration](https://dash.applovin.com/documentation/mediation/android/getting-started/integration)
- [ironSource Integration](https://developers.is.com/ironsource-mobile/android/mediation-networks-android/)
- [Unity Ads Integration](https://docs.unity.com/ads/en/manual/GoogleAdMobMediationSetup)

