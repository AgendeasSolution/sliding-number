plugins {
    id("com.google.gms.google-services") version "4.4.4" apply false
}

allprojects {
    repositories {
        // Google repository must be first for Google mediation adapters
        google()
        mavenCentral()
        // AppLovin repository (for AppLovin SDK only)
        // Using exclusiveContent to prevent Gradle from searching here for Google artifacts
        maven {
            url = uri("https://artifacts.applovin.com/android")
            mavenContent {
                includeGroup("com.applovin")
            }
        }
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
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
