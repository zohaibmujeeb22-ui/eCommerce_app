buildscript {
    ext.kotlin_version = '1.9.22'
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath 'com.android.tools.build:gradle:8.3.0'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
        
        classpath 'com.google.gms:google-services:4.4.1' 
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.layout.buildDirectory.value(rootProject.layout.buildDirectory.dir("../../build").get())

subprojects {
    project.layout.buildDirectory.value(rootProject.layout.buildDirectory.dir(project.name).get())
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register("clean", Delete) {
    delete rootProject.layout.buildDirectory
}
dependencies {
    implementation("com.android.support:animated-vector-drawable:28.0.0")
    implementation("com.android.support:appcompat-v7:28.0.0")
    implementation("androidx.vectordrawable:vectordrawable-animated:1.2.0")
}
