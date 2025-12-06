
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {

    pluginManager.withPlugin("com.android.library") {
        try {
            val android = extensions.findByType(com.android.build.gradle.LibraryExtension::class.java)
            if (android != null) {
                // 1. Fix lỗi namespace (cho các lib cũ chưa khai báo)
                if (android.namespace == null) {
                    android.namespace = project.group.toString()
                }

                // 2. Fix lỗi lStar not found
                // Ép thư viện con (ota_update) phải biên dịch bằng SDK 34 mới hiểu được lStar
                android.compileSdk = 36
                android.defaultConfig.targetSdk = 36
            }
        } catch (e: Exception) {
            println("Skipping build config fix for ${project.name}")
        }
    }


    // Ép dùng bản core mới nhất (để chắc ăn 100%)
    project.configurations.all {
        resolutionStrategy {
            eachDependency {
                if (requested.group == "androidx.core" && requested.name == "core") {
                    useVersion("1.12.0")
                }
            }
        }
    }

    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}