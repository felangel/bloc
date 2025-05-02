plugins {
    java
    id("org.jetbrains.intellij.platform") version "2.5.0"
    kotlin("jvm") version "1.9.25"
    idea
}

group = "com.bloc"
version = "4.0.2"

java {
    sourceCompatibility = JavaVersion.VERSION_17
    targetCompatibility = JavaVersion.VERSION_17
}

repositories {
    mavenCentral()

    intellijPlatform {
        defaultRepositories()
    }
}

intellijPlatform {
    pluginConfiguration {
        ideaVersion {
            untilBuild = provider { null }
        }
    }
}

dependencies {
    intellijPlatform {
        intellijIdeaCommunity("2022.3")
        bundledPlugin("com.intellij.java")
    }
    testCompileOnly("junit:junit:4.13.2")
    implementation("com.fleshgrinder.kotlin:case-format:0.2.0")
}

tasks {
    compileKotlin {
        kotlinOptions.jvmTarget = "17"
    }

    compileTestKotlin {
        kotlinOptions.jvmTarget = "17"
    }
}