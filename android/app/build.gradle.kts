plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "live.bogo.app.live_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion
    val releaseKeystoreFile = file("key.jks")

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "live.bogo.app.live_app.xo" // yd xo
        // applicationId = "live.bogo.app.live_app.xo" // cn 91
        // applicationId = "live.bogo.app.live_app.xo" // tk
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            storeFile = releaseKeystoreFile
            storePassword = "liveappflu"
            keyAlias = "key"
            keyPassword = "liveappflu"
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig = if (releaseKeystoreFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                logger.warn("Release keystore key.jks not found; signing release APK with debug key for local build.")
                signingConfigs.getByName("debug")
            }
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    implementation("com.google.android.gms:play-services-tasks:18.3.0")
    implementation("me.pushy:sdk:1.0.72")
}
