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
    afterEvaluate {
        if (project.hasProperty("android")) {
            val android = project.extensions.getByName("android")
            if (android is com.android.build.gradle.BaseExtension) {
                // Force all plugins to compile with API 36
                android.compileSdkVersion(36)

                if (android.namespace == null) {
                    val manifestFile = project.file("src/main/AndroidManifest.xml")
                    if (manifestFile.exists()) {
                        val manifestXml = manifestFile.readText()
                        val packageMatch = Regex("""package="([^"]*)"""").find(manifestXml)
                        if (packageMatch != null) {
                            android.namespace = packageMatch.groupValues[1]

                            // AGP 8.0+ forbids 'package' attribute in AndroidManifest.xml
                            // We strip it here to allow older plugins to build with newer AGP
                            try {
                                val newManifestXml = manifestXml.replace(Regex("""\s*package="[^"]*""""), "")
                                manifestFile.writeText(newManifestXml)
                            } catch (e: Exception) {
                                println("Could not strip package from ${manifestFile.path}: ${e.message}")
                            }
                        }
                    }
                }

                if (android.namespace == null) {
                    android.namespace = "com.crew_support.${project.name.replace(":", "_")}"
                }
            }
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
