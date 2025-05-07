plugins {
    java
    id("org.jetbrains.intellij.platform") version "2.5.0"
    kotlin("jvm") version "1.9.25"
    idea
}

group = "com.bloc"
version = "4.1.1"

val lsp4ijVersion: String by project
val lsp4jVersion: String by project
val caseFormatVersion: String by project

java {
    sourceCompatibility = JavaVersion.VERSION_17
    targetCompatibility = JavaVersion.VERSION_17
}

repositories {
    mavenCentral()
    exclusiveContent {
        forRepository {
            maven {
                setUrl("https://mvn.falsepattern.com/releases")
                name = "mavenpattern"
            }
        }
        filter {
            includeModule("com.redhat.devtools.intellij", "lsp4ij")
        }
    }
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
        intellijIdeaCommunity("2023.3")
        bundledPlugin("com.intellij.java")
        plugin("com.redhat.devtools.lsp4ij:$lsp4ijVersion")
    }
    testCompileOnly("junit:junit:4.13.2")
    compileOnly("com.redhat.devtools.intellij:lsp4ij:$lsp4ijVersion")
    compileOnly("org.eclipse.lsp4j:org.eclipse.lsp4j:$lsp4jVersion")
    implementation("com.fleshgrinder.kotlin:case-format:$caseFormatVersion")
}

tasks {
    compileKotlin {
        kotlinOptions.jvmTarget = "17"
    }

    compileTestKotlin {
        kotlinOptions.jvmTarget = "17"
    }
}