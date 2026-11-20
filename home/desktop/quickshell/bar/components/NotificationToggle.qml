import Quickshell
import QtQuick
import "../singletons"

// Left click opens the notification center, right click toggles Do Not Disturb
Item {
    implicitWidth: Theme.barWidth
    implicitHeight: text.implicitHeight + 8

    // hover highlight so it reads as a button
    Rectangle {
        anchors.fill: parent
        radius: 0
        color: area.containsMouse ? Theme.surfaceHiest : "transparent"
    }

    VText {
        id: text
        anchors.centerIn: parent
        text: Notifs.dnd ? "DND" : "NTF " + Notifs.unread
        color: Notifs.dnd ? Theme.error : (Notifs.unread > 0 ? Theme.primary : Theme.fgDim)
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor
        onClicked: mouse => {
            if (mouse.button === Qt.RightButton) Notifs.dnd = !Notifs.dnd;
            else Quickshell.execDetached(["qs", "ipc", "call", "notifications", "toggle"]);
        }
    }
}
