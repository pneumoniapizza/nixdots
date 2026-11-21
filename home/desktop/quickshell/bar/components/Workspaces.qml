import QtQuick
import "../singletons"

// Square boxes: focused = filled, active (other output) = tinted + border,
// occupied = dim fill, empty = hollow
Column {
    spacing: 2

    Repeater {
        model: Niri.workspaces

        delegate: Item {
            id: ws
            required property var modelData

            readonly property bool focused: modelData.is_focused
            readonly property bool active: modelData.is_active
            readonly property bool occupied: modelData.active_window_id !== null && modelData.active_window_id !== undefined

            width: Theme.barWidth
            height: Theme.boxSize + 8

            Rectangle {
                anchors.centerIn: parent
                width: Theme.boxSize
                height: Theme.boxSize
                radius: 0
                border.width: 1
                border.color: Theme.border
                color: ws.focused ? Theme.primary
                     : ws.active ? Theme.secondaryContainer
                     : ws.occupied ? Theme.outline
                     : "transparent"
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: Niri.focusWorkspace(ws.modelData.idx)
            }
        }
    }
}
