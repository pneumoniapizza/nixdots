import Quickshell
import Quickshell.Bluetooth
import QtQuick
import "../singletons"

// Bar button for Bluetooth. Left click opens the Bluetooth menu, right click
// toggles the adapter. Shows the number of connected devices.
Item {
    id: root

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool on: adapter !== null && adapter.enabled
    readonly property int connected: adapter ? adapter.devices.values.filter(d => d.connected).length : 0

    visible: adapter !== null
    implicitWidth: Theme.barWidth
    implicitHeight: visible ? text.implicitHeight + 8 : 0

    // hover highlight so it reads as a button
    Rectangle {
        anchors.fill: parent
        radius: 0
        color: area.containsMouse ? Theme.surfaceHiest : "transparent"
    }

    VText {
        id: text
        anchors.centerIn: parent
        text: !root.on ? "BT OFF" : (root.connected > 0 ? "BT " + root.connected : "BT")
        color: !root.on ? Theme.error : (root.connected > 0 ? Theme.primary : Theme.fgDim)
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor
        onClicked: mouse => {
            if (mouse.button === Qt.RightButton) {
                if (root.adapter) root.adapter.enabled = !root.adapter.enabled;
            } else {
                Quickshell.execDetached(["qs", "ipc", "call", "bluetooth", "toggle"]);
            }
        }
    }
}
