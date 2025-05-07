package com.bloc.intellij_generator_plugin.util

import kotlin.test.Test
import kotlin.test.assertFalse
import kotlin.test.assertTrue

class VersionComparatorTest {
    @Test
    fun `equal versions return true`() {
        assertTrue(VersionComparator.isGreaterOrEqualThan("1.0.0", "1.0.0"))
        assertTrue(VersionComparator.isGreaterOrEqualThan("2.3.4", "2.3.4"))
        assertTrue(VersionComparator.isGreaterOrEqualThan("0.0.1", "0.0.1"))
    }

    @Test
    fun `greater versions return true`() {
        assertTrue(VersionComparator.isGreaterOrEqualThan("2.0.0", "1.0.0"))
        assertTrue(VersionComparator.isGreaterOrEqualThan("1.2.0", "1.1.0"))
        assertTrue(VersionComparator.isGreaterOrEqualThan("1.0.3", "1.0.2"))
        assertTrue(VersionComparator.isGreaterOrEqualThan("10.0.0", "9.9.9"))
    }

    @Test
    fun `lower versions return false`() {
        assertFalse(VersionComparator.isGreaterOrEqualThan("1.0.0", "2.0.0"))
        assertFalse(VersionComparator.isGreaterOrEqualThan("1.1.0", "1.2.0"))
        assertFalse(VersionComparator.isGreaterOrEqualThan("1.0.2", "1.0.3"))
        assertFalse(VersionComparator.isGreaterOrEqualThan("9.9.9", "10.0.0"))
    }

    @Test
    fun `different version segment counts are handled correctly`() {
        // Extra zeros at the end don't change version equality
        assertTrue(VersionComparator.isGreaterOrEqualThan("1.0.0", "1.0"))
        assertTrue(VersionComparator.isGreaterOrEqualThan("1.0", "1.0.0"))

        // Higher version with fewer segments
        assertTrue(VersionComparator.isGreaterOrEqualThan("2.0", "1.9.9"))

        // Lower version with fewer segments
        assertFalse(VersionComparator.isGreaterOrEqualThan("1.9", "2.0.0"))

        // Mixed segment counts
        assertTrue(VersionComparator.isGreaterOrEqualThan("1.2.3.4", "1.2.3"))
        assertFalse(VersionComparator.isGreaterOrEqualThan("1.2.3", "1.2.3.4"))
    }

    @Test
    fun `large version numbers are compared correctly`() {
        assertTrue(VersionComparator.isGreaterOrEqualThan("999.999.999", "999.999.998"))
        assertTrue(VersionComparator.isGreaterOrEqualThan("1000.0.0", "999.999.999"))
    }

    @Test(expected = IllegalArgumentException::class)
    fun `empty first version throws IllegalArgumentException`() {
        VersionComparator.isGreaterOrEqualThan("", "1.0.0")
    }

    @Test(expected = IllegalArgumentException::class)
    fun `empty second version throws IllegalArgumentException`() {
        VersionComparator.isGreaterOrEqualThan("1.0.0", "")
    }

    @Test(expected = IllegalArgumentException::class)
    fun `non-numeric version segments throw IllegalArgumentException`() {
        VersionComparator.isGreaterOrEqualThan("1.0.a", "1.0.0")
    }

    @Test(expected = IllegalArgumentException::class)
    fun `malformed version strings throw IllegalArgumentException`() {
        VersionComparator.isGreaterOrEqualThan("1.0.", "1.0.0")
    }

    @Test
    fun `versions with leading zeros are compared correctly`() {
        assertTrue(VersionComparator.isGreaterOrEqualThan("01.02.03", "1.2.3"))
        assertTrue(VersionComparator.isGreaterOrEqualThan("1.2.3", "01.02.03"))
    }
}