import Quickshell
import QtQuick
import "../singletons"

PanelWindow {
    id: bar

    anchors {
        top: true
        bottom: true
        left: true
    }
    implicitWidth: Theme.barWidth
    exclusiveZone: Theme.barWidth
    color: "transparent"

    // background: square corners, 1px right border
    Rectangle {
        anchors.fill: parent
        color: Theme.surface
        radius: 0

        Rectangle {
            // with the frame on, the line only runs along the frame's opening,
            // so it ends where the frame's own outline starts instead of crossing it
            readonly property int inset: Settings.frameEnabled && Settings.frameWidth > 0 ? Settings.frameWidth : 0
            anchors {
                top: parent.top
                bottom: parent.bottom
                right: parent.right
                topMargin: inset
                bottomMargin: inset
            }
            width: 1
            visible: Settings.frameBorder
            color: Theme.border
        }
    }

    // top
    Workspaces {
        id: workspaces
        anchors {
            top: parent.top
            topMargin: 6
            horizontalCenter: parent.horizontalCenter
        }
    }

    // middle: media (click opens the player popup)
    MediaButton {
        anchors {
            top: workspaces.bottom
            topMargin: 12
            bottom: stats.top
            bottomMargin: 12
            left: parent.left
            right: parent.right
        }
    }

    // bottom
    Column {
        id: stats
        spacing: 14
        anchors {
            bottom: parent.bottom
            bottomMargin: 8
            horizontalCenter: parent.horizontalCenter
        }

        TimerIndicator {}
        Tray {}
        NetworkToggle {}
        BluetoothToggle {}
        QuickSettingsToggle {}
        NotificationToggle {}
        Volume {}
        Battery {}
        Clock {}
    }
}
