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

    // Tự động thêm namespace cho các thư viện cũ (như ota_update)
    pluginManager.withPlugin("com.android.library") {
        try {
            val android = extensions.findByType(com.android.build.gradle.LibraryExtension::class.java)
            if (android != null) {
                if (android.namespace == null) {
                    android.namespace = project.group.toString()
                }
            }
        } catch (e: Exception) {
            // Bỏ qua nếu có lỗi nhỏ trong quá trình gán, để không chặn build
            println("Namespace fix skipped for ${project.name}")
        }
    }
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}