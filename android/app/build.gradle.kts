plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    // SmartRoute Uganda — Application ID
    // This ID is used on the Google Play Store and cannot be changed after publishing.
    namespace = "ug.smartroute.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "ug.smartroute.app"
        // Android 6.0+ (API 23) required for runtime location permissions.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // ── Release signing ──────────────────────────────────────────────
            // Before publishing to Google Play, replace with a proper keystore:
            //
            //   1. Generate a release keystore:
            //      keytool -genkey -v -keystore smartroute-release.jks \
            //        -alias smartroute -keyalg RSA -keysize 2048 -validity 10000
            //
            //   2. Create android/key.properties (git-ignored):
            //      storePassword=<store_password>
            //      keyPassword=<key_password>
            //      keyAlias=smartroute
            //      storeFile=<absolute_path>/smartroute-release.jks
            //
            //   3. Load the properties and update signingConfigs here.
            //
            // For demonstration builds, debug signing is used.
            // This allows `flutter build apk --release` to work for testing.
            // DO NOT distribute a debug-signed APK on Google Play.
            signingConfig = signingConfigs.getByName("debug")

            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
