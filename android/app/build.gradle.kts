import java.util.Properties
import java.io.FileInputStream
plugins {
id("com.android.application")
id("kotlin-android")
id("dev.flutter.flutter-gradle-plugin")
}
// Load keystore properties
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}
android {
namespace = "dev.nareph.gymgenius"
compileSdk = flutter.compileSdkVersion
ndkVersion = "29.0.14206865"
compileOptions {
    sourceCompatibility = JavaVersion.VERSION_17
    targetCompatibility = JavaVersion.VERSION_17
}

kotlinOptions {
    jvmTarget = JavaVersion.VERSION_17.toString()
}

defaultConfig {
    applicationId = "dev.nareph.gymgenius"
    minSdk = flutter.minSdkVersion
    targetSdk = flutter.targetSdkVersion
    versionCode = flutter.versionCode
    versionName = flutter.versionName
    multiDexEnabled = true
}

// Signing configurations
signingConfigs {
    create("release") {
        if (keystorePropertiesFile.exists()) {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }
}

buildTypes {
    release {
        // Use release signing
        signingConfig = signingConfigs.getByName("release")
        
        // ProGuard/R8 optimizations
        isMinifyEnabled = true
        isShrinkResources = true
        proguardFiles(
            getDefaultProguardFile("proguard-android-optimize.txt"),
            "proguard-rules.pro"
        )
    }
    
    debug {
        signingConfig = signingConfigs.getByName("debug")
    }
}

// Split APKs by architecture (reduces APK size)
splits {
    abi {
        isEnable = true
        reset()
        include("arm64-v8a", "armeabi-v7a", "x86_64")
        isUniversalApk = true // Also generates universal APK
    }
}
}
dependencies {
implementation("androidx.multidex:multidex:2.0.1")
implementation("com.google.android.play:core:1.10.3")
}
flutter {
source = "../.."
}
