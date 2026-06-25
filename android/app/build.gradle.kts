plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

import org.gradle.api.tasks.compile.JavaCompile

android {
    namespace = "com.verifiedglam.beauty_scanner"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.verifiedglam.beauty_scanner"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

// GeneratedPluginRegistrant.java references Kotlin plugin classes; compile them first (AGP 9 ordering).
afterEvaluate {
    tasks.withType(JavaCompile::class.java).configureEach {
        val variant = if (name.contains("Debug")) "Debug" else "Release"
        rootProject.subprojects.forEach { sub ->
            if (sub.name == "app") return@forEach
            sub.tasks.findByName("compile${variant}Kotlin")?.let { kotlinTask ->
                dependsOn(kotlinTask)
            }
        }
    }
}
