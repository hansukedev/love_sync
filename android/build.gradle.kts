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
    // 1. Fix lỗi namespace (cũ)
    pluginManager.withPlugin("com.android.library") {
        try {
            val android = extensions.findByType(com.android.build.gradle.LibraryExtension::class.java)
            if (android != null) {
                if (android.namespace == null) {
                    android.namespace = project.group.toString()
                }
            }
        } catch (e: Exception) {
            println("Namespace fix skipped for ${project.name}")
        }
    }
    // Ép buộc tất cả thư viện phải dùng androidx.core bản mới (1.12.0 trở lên)
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