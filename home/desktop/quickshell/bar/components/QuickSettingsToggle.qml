import Quickshell
import QtQuick
import "../singletons"

// Bar button that opens the quick settings panel
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
        text: "SET"
        color: area.containsMouse ? Theme.fg : Theme.fgDim
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: Quickshell.execDetached(["qs", "ipc", "call", "quicksettings", "toggle"])
    }
}
