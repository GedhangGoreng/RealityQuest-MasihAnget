plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.realityquest"
    compileSdk = 36  // Update ke 34
    ndkVersion = flutter.ndkVersion

    defaultConfig {
        applicationId = "com.example.realityquest"
        minSdk = flutter.minSdkVersion  // Minimal Android 5.0
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        // ✅ PENTING: Enable multidex
        multiDexEnabled = true
    }

    compileOptions {
        // ✅ ENABLE DESUGARING (ini yang diminta error)
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("org.jetbrains.kotlin:kotlin-stdlib:1.9.0")
    
    // ✅ INI VERSI KOTLIN SCRIPT (PAKE KURUNG)
    implementation("androidx.appcompat:appcompat:1.6.1")
    implementation("androidx.constraintlayout:constraintlayout:2.1.4")
    implementation("androidx.core:core-ktx:1.10.1")

    // Core library desugaring
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
    
    // Multidex
    implementation("androidx.multidex:multidex:2.0.1")
}