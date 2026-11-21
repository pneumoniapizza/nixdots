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
            anchors {
                top: parent.top
                bottom: parent.bottom
                right: parent.right
            }
            width: 1
            color: Theme.primary
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
