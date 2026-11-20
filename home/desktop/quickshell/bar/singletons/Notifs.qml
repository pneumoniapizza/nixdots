pragma Singleton

import Quickshell
import Quickshell.Services.Notifications
import QtQuick

// Notification daemon (org.freedesktop.Notifications).
// Make sure no other daemon (mako, dunst, swaync) is running.
//
// `list` are the live notifications (shown as toasts). `history` keeps a plain
// copy of every notification (also ones dropped by Do Not Disturb) for the
// notification center.
Singleton {
    id: root

    property bool dnd: false
    property bool centerOpen: false   // set by NotificationCenter, hides the toasts
    property int unread: 0

    readonly property var list: server.trackedNotifications
    readonly property int count: list.values.length

    readonly property var history: historyModel
    readonly property int historyLimit: 100

    ListModel { id: historyModel }

    function record(n) {
        historyModel.insert(0, {
            appName: n.appName,
            summary: n.summary,
            body: n.body,
            image: n.image,
            critical: n.urgency === NotificationUrgency.Critical,
            time: Date.now()
        });
        if (historyModel.count > historyLimit)
            historyModel.remove(historyLimit, historyModel.count - historyLimit);
        if (!centerOpen) unread++;
    }

    function removeAt(i) { historyModel.remove(i); }

    function clearHistory() {
        historyModel.clear();
        unread = 0;
    }

    NotificationServer {
        id: server

        keepOnReload: true
        actionsSupported: true
        bodySupported: true
        imageSupported: true

        onNotification: n => {
            root.record(n);
            // Do Not Disturb: no toast for anything except critical
            if (root.dnd && n.urgency !== NotificationUrgency.Critical) return;
            n.tracked = true;
        }
    }
}
