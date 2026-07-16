plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.cutquote"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.cutquote"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
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

tasks.register("renameReleaseApk") {
    doLast {
        val versionName = android.defaultConfig.versionName ?: ""
        val apkDir = layout.buildDirectory.asFile.get().resolve("outputs/flutter-apk")
        val apk = apkDir.resolve("app-release.apk")
        if (apk.exists()) {
            apk.copyTo(apkDir.resolve("CutQuote_v${versionName}.apk"), overwrite = true)
        }
    }
}
tasks.whenTaskAdded(object : org.gradle.api.Action<Task> {
    override fun execute(task: Task) {
        if (task.name.startsWith("assemble") && task.name.endsWith("Release")) {
            task.finalizedBy("renameReleaseApk")
        }
    }
})