import org.jetbrains.kotlin.gradle.dsl.JvmTarget

plugins {
    java
    id("org.jetbrains.intellij.platform") version "2.5.0"
    kotlin("jvm") version "2.1.0"
    idea
}

group = "com.bloc"
version = "4.1.6"

val lsp4ijVersion: String by project
val lsp4jVersion: String by project
val caseFormatVersion: String by project
val apacheCommonsTextVersion: String by project

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
    pluginVerification {
        ides {
            recommended()
        }
    }
}

dependencies {
    intellijPlatform {
        intellijIdeaCommunity("2023.3")
        bundledPlugin("com.intellij.java")
        plugin("com.redhat.devtools.lsp4ij:$lsp4ijVersion")
    }
    testImplementation(kotlin("test"))
    compileOnly("com.redhat.devtools.intellij:lsp4ij:$lsp4ijVersion")
    compileOnly("org.eclipse.lsp4j:org.eclipse.lsp4j:$lsp4jVersion")
    implementation("com.fleshgrinder.kotlin:case-format:$caseFormatVersion")
    implementation("org.apache.commons:commons-text:$apacheCommonsTextVersion")
}

tasks {
    compileKotlin {
        compilerOptions {
            jvmTarget.set(JvmTarget.JVM_17)
        }
    }

    compileTestKotlin {
        compilerOptions {
            jvmTarget.set(JvmTarget.JVM_17)
        }
    }
}