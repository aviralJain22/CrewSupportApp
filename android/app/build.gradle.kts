import java.util.Properties
import java.io.FileInputStream

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")

    //Firebase STARTS=====

    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
    
    //Firebase ENDS=====
}

android {
    namespace = "com.example.crew_support"

    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // following line is required by flutter_local_notifications
        // Flag to enable support for the new language APIs
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.crew_support.crew_support"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        
        minSdk = flutter.minSdkVersion
        
        targetSdk = 36

        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties.getProperty("keyAlias")
            keyPassword = keystoreProperties.getProperty("keyPassword")
            storeFile = keystoreProperties.getProperty("storeFile")?.let { file(it) }
            storePassword = keystoreProperties.getProperty("storePassword")
        }
    }

    buildTypes {
        getByName("release") {
            // This tells the release build to use the 'release' signing config created above
            signingConfig = signingConfigs.getByName("release")
            
            isMinifyEnabled = false // Set to true for code shrinking/obfuscation
            isShrinkResources = false
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

dependencies {

    // following line is required by flutter_local_notifications
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")

    // Firebase Bill of Materials (keeps versions aligned)
    implementation(platform("com.google.firebase:firebase-bom:34.7.0"))

    // Analytics
    implementation("com.google.firebase:firebase-analytics")

    // Crashlytics
    implementation("com.google.firebase:firebase-crashlytics")

    // Push / FCM
    implementation("com.google.firebase:firebase-messaging")
}

flutter {
    source = "../.."
}
