import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.mice_and_paws_cat_game"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"
          
    // ① – signingConfigs tanımı
    signingConfigs {
        create("release") {
            // key.properties dosyasını oku
            val keystorePropsFile = rootProject.file("key.properties")
            if (keystorePropsFile.exists()) {
                val keystoreProps = Properties().apply {
                    load(FileInputStream(keystorePropsFile))
                }
                keyAlias = keystoreProps.getProperty("keyAlias")
                keyPassword = keystoreProps.getProperty("keyPassword")
                storeFile = file(keystoreProps.getProperty("storeFile"))
                storePassword = keystoreProps.getProperty("storePassword")
            }
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.mice_and_paws_cat_game"
        minSdk = flutter.minSdkVersion
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        getByName("release") {
            // ② – release build’te oluşturduğumuz signingConfig’i ata
            signingConfig = signingConfigs.getByName("release")
            // proguard, minifyEnabled vb. ayarların buraya gelebilir
        }
        getByName("debug") {
            // debug için default debug key
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
