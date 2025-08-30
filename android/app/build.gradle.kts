plugins {
    id("com.android.application")
    id("kotlin-android")
    // Flutter Gradle Plugin harus terakhir
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.attendance_app"

    // Gunakan properti dari flutter plugin
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"  // Perbarui versi NDK yang sesuai

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    defaultConfig {
        applicationId = "com.example.attendance_app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // untuk sekarang pakai debug signing agar flutter run --release tetap jalan
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."  // Pastikan path ke Flutter source sudah benar
}
