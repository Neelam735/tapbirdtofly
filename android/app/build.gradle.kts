import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and
    // Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Load signing configuration from key.properties if it exists.
// key.properties is not checked into source control (see .gitignore);
// copy key.properties.example to key.properties and fill in your
// keystore credentials to enable signed release builds.
val keyPropertiesFile = rootProject.file("key.properties")
val keyProperties = Properties()
if (keyPropertiesFile.exists()) {
    FileInputStream(keyPropertiesFile).use { keyProperties.load(it) }
}

android {
    namespace = "com.example.tapbirdtofly"
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
        applicationId = "com.example.tapbirdtofly"
        // google_mobile_ads requires minSdk 23+.
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            keyAlias = keyProperties["keyAlias"] as String?
            keyPassword = keyProperties["keyPassword"] as String?
            storeFile = (keyProperties["storeFile"] as String?)?.let { file(it) }
            storePassword = keyProperties["storePassword"] as String?
        }
    }

    buildTypes {
        release {
            // Fall back to the debug key when key.properties is absent so
            // local `flutter build apk --release` still produces a running
            // APK for developers who haven't set up a release keystore yet.
            signingConfig = if (keyPropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}
