package com.bloc.intellij_generator_plugin.util

import com.intellij.notification.NotificationGroupManager
import com.intellij.notification.NotificationType
import com.intellij.openapi.project.Project

object BlocPluginNotification {
    private const val NOTIFICATION_GROUP = "Bloc Plugin Notifications"

    fun notify(project: Project, content: String, type: NotificationType) {
        NotificationGroupManager.getInstance()
            .getNotificationGroup(NOTIFICATION_GROUP)
            .createNotification(content, type)
            .notify(project)
    }
}