plugins {
    id("com.android.application")
    id("kotlin-android")
    // Add the Google services Gradle plugin
    id("com.google.gms.google-services")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.fgtp.sliding_tile"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.fgtp.sliding_tile"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
            // ProGuard/R8 disabled - no code shrinking (larger app size but simpler build)
            // If you enable minification, you MUST keep proguard-rules.pro file
            isMinifyEnabled = false
            isShrinkResources = false
            // Disable native library stripping to avoid build errors
            ndk {
                debugSymbolLevel = "NONE"
            }
        }
    }
    
    // Suppress Java 8 obsolete warnings from dependencies
    tasks.withType<JavaCompile>().configureEach {
        options.compilerArgs.add("-Xlint:-options")
    }
}

flutter {
    source = "../.."
}

dependencies {
    
    // Import the Firebase BoM
    implementation(platform("com.google.firebase:firebase-bom:34.5.0"))
    implementation("com.google.firebase:firebase-analytics")

    // AdMob SDK and Adapters
    // Note: All adapters must be compatible with Google Mobile Ads SDK used by google_mobile_ads 6.0.0
    implementation("com.facebook.android:facebook-android-sdk:[8,9)")
    // Add infer-annotation for Facebook SDK (required for R8/ProGuard)
    implementation("com.facebook.infer.annotation:infer-annotation:0.18.0")
    implementation("com.google.ads.mediation:facebook:6.16.0.0")
    
    // AppLovin SDK and Adapter
    // Using version range to find compatible version with SDK 12.2
    implementation("com.applovin:applovin-sdk:12.4.2")
    implementation("com.google.ads.mediation:applovin:+")
    
    // ironSource Adapter (SDK included automatically by adapter)
    // Using version range to find compatible version
    implementation("com.google.ads.mediation:ironsource:+")
    
    // Unity Ads SDK and Adapter
    implementation("com.unity3d.ads:unity-ads:4.12.3")
    implementation("com.google.ads.mediation:unity:+")
}
