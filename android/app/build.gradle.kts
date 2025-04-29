plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.manag_cafe"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "29.0.13113456"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_21
        targetCompatibility = JavaVersion.VERSION_21
    }

    kotlinOptions {
        jvmTarget = "21" // Simplified to string "11" for clarity
    }

    defaultConfig {
        applicationId = "com.example.manag_cafe"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        minSdkVersion(23)
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
    android {
        applicationVariants.all {
            if (name == "debug") {
                tasks.register<Copy>("copyDebugApk") {
                    from("$buildDir/outputs/flutter-apk/app-debug.apk")
                    into("$buildDir/host/outputs/apk")
                    rename { "app-copy.apk" }
                }
            }
        }
    }
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:33.12.0"))
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-database") // Already added
    implementation("com.google.firebase:firebase-auth")
}

flutter {
    source = "../.."
}