import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    // Apply the Google services Gradle plugin
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.traveller_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.traveller_app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        debug {
            manifestPlaceholders["MAPS_API_KEY"] = mapsApiKey ?: ""
        }
        release {
            signingConfig = signingConfigs.getByName("debug")
            manifestPlaceholders["MAPS_API_KEY"] = mapsApiKey ?: ""
        }
    }


    buildFeatures {
        buildConfig = true  // Enable the buildConfig feature
    }
}


flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.core:core-ktx:1.12.0")
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.7.0")

    // Import the Firebase BoM
    implementation(platform("com.google.firebase:firebase-bom:33.12.0"))

    // Add the dependencies for Firebase products you want to use
    // When using the BoM, don't specify versions in Firebase dependencies
    implementation("com.google.firebase:firebase-analytics")

    // Add other Firebase SDKs you need (e.g., Firestore, Auth, etc.)
    // implementation("com.google.firebase:firebase-firestore")
    // implementation("com.google.firebase:firebase-auth")
    // ...
}

val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localPropertiesFile.inputStream().use { stream ->
        localProperties.load(stream)
    }
}
val mapsApiKey: String? = localProperties["MAPS_API_KEY"] as? String?