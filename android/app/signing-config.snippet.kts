// Paste the blocks below into your `android/app/build.gradle.kts` to enable
// signed release builds backed by `android/key.properties`.
//
// 1. Add these imports near the top of the file (above the `plugins { }` block):

import java.io.FileInputStream
import java.util.Properties


// 2. Add this block BETWEEN the `plugins { }` block and the `android { }` block.
//    It loads keystore credentials from `android/key.properties` at
//    configuration time. key.properties is gitignored; see
//    `android/key.properties.example` for the expected fields.

val keyPropertiesFile = rootProject.file("key.properties")
val keyProperties = Properties()
if (keyPropertiesFile.exists()) {
    FileInputStream(keyPropertiesFile).use { keyProperties.load(it) }
}


// 3. Inside the `android { }` block, add a `signingConfigs { }` block
//    (or merge into the existing one):

signingConfigs {
    create("release") {
        keyAlias = keyProperties["keyAlias"] as String?
        keyPassword = keyProperties["keyPassword"] as String?
        storeFile = (keyProperties["storeFile"] as String?)?.let { file(it) }
        storePassword = keyProperties["storePassword"] as String?
    }
}


// 4. Inside the `android { }` block's `buildTypes { }`, change the `release`
//    block to use the release signing config when `key.properties` exists,
//    and fall back to the debug keystore when it doesn't (so local
//    `flutter build apk --release` still works during development):

buildTypes {
    release {
        signingConfig = if (keyPropertiesFile.exists()) {
            signingConfigs.getByName("release")
        } else {
            signingConfigs.getByName("debug")
        }
        isMinifyEnabled = false
        isShrinkResources = false
    }
}


// 5. While you're in the file, make sure `defaultConfig { }` has
//    `minSdk = 23` (google_mobile_ads requires API 23+):

defaultConfig {
    // ...your existing applicationId, versionCode, etc...
    minSdk = 23
}
