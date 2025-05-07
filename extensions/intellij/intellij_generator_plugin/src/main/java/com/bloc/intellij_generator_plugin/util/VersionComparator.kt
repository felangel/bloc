package com.bloc.intellij_generator_plugin.util

import kotlin.math.max

class VersionComparator {
    companion object {
        /**
         * Compares two version numbers represented as strings.
         *
         * Takes two strings, [a] and [b], representing version numbers
         * and returns `true` if version [a] is greater or equal than version [b],
         * and `false` otherwise.
         */
        fun isGreaterOrEqualThan(a: String, b: String): Boolean {
            try {
                if (a.isEmpty() || b.isEmpty()) {
                    throw IllegalArgumentException()
                }
                if (a == b) {
                    return true
                }

                val splitA = a.split(".").map { it.toInt() }
                val splitB = b.split(".").map { it.toInt() }

                for (i in 0 until max(splitA.size, splitB.size)) {
                    val valA = splitA.getOrNull(i) ?: 0
                    val valB = splitB.getOrNull(i) ?: 0
                    if (valA > valB) {
                        return true
                    }
                    if (valA < valB) {
                        return false
                    }
                }
                return true
            } catch (e: NumberFormatException) {
                throw IllegalArgumentException(e)
            }
        }
    }
}