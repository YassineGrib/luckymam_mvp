import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    // Firebase Google Services plugin
    id("com.google.gms.google-services")
    // Firebase Crashlytics plugin (uploads mapping/symbols, links crash-free builds)
    id("com.google.firebase.crashlytics")
}

// Load keystore properties
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.luckmam.luckmam_mvp"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.luckmam.luckmam_mvp"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    signingConfigs {
        create("release") {
            val storeFileVal = keystoreProperties["storeFile"] as? String
            val storePasswordVal = keystoreProperties["storePassword"] as? String
            val keyAliasVal = keystoreProperties["keyAlias"] as? String
            val keyPasswordVal = keystoreProperties["keyPassword"] as? String
            if (storeFileVal != null && storePasswordVal != null && keyAliasVal != null && keyPasswordVal != null) {
                storeFile = file(storeFileVal)
                storePassword = storePasswordVal
                keyAlias = keyAliasVal
                keyPassword = keyPasswordVal
            }
        }
    }

    buildTypes {
        release {
            val hasReleaseKey = keystorePropertiesFile.exists() && 
                                keystoreProperties.containsKey("storeFile") &&
                                keystoreProperties.containsKey("storePassword") &&
                                keystoreProperties.containsKey("keyAlias") &&
                                keystoreProperties.containsKey("keyPassword")
            if (hasReleaseKey) {
                signingConfig = signingConfigs.getByName("release")
            } else {
                signingConfig = signingConfigs.getByName("debug")
            }
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
