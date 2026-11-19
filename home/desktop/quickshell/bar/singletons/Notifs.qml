pragma Singleton

import Quickshell
import Quickshell.Services.Notifications
import QtQuick

// Notification daemon (org.freedesktop.Notifications).
// Make sure no other daemon (mako, dunst, swaync) is running.
Singleton {
    id: root

    property bool dnd: false

    readonly property var list: server.trackedNotifications
    readonly property int count: list.values.length

    NotificationServer {
        id: server

        keepOnReload: true
        actionsSupported: true
        bodySupported: true
        imageSupported: true

        onNotification: n => {
            // Do Not Disturb: drop everything except critical
            if (root.dnd && n.urgency !== NotificationUrgency.Critical) return;
            n.tracked = true;
        }
    }
}
