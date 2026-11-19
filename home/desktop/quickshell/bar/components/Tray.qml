import Quickshell
import Quickshell.Services.SystemTray
import QtQuick
import "../singletons"

// App tray (StatusNotifierItem). Left click activates, middle click is the
// secondary action, right click opens the app's menu, wheel scrolls.
Column {
    id: root

    spacing: 4
    visible: SystemTray.items.values.length > 0

    Repeater {
        model: SystemTray.items

        delegate: Item {
            id: entry
            required property SystemTrayItem modelData

            readonly property bool hidden: modelData.status === Status.Passive

            visible: !hidden
            width: Theme.barWidth
            height: hidden ? 0 : 20

            Image {
                anchors.centerIn: parent
                width: 16
                height: 16
                sourceSize: Qt.size(16, 16)
                source: entry.modelData.icon
                asynchronous: true
                fillMode: Image.PreserveAspectFit
                opacity: hover.containsMouse ? 1 : 0.85
            }

            QsMenuAnchor {
                id: menu
                menu: entry.modelData.menu
                anchor.item: entry
                anchor.edges: Edges.Right
                anchor.gravity: Edges.Right
            }

            MouseArea {
                id: hover
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
                cursorShape: Qt.PointingHandCursor

                onClicked: mouse => {
                    const it = entry.modelData;
                    if (mouse.button === Qt.RightButton || (mouse.button === Qt.LeftButton && it.onlyMenu)) {
                        if (it.hasMenu) menu.open();
                    } else if (mouse.button === Qt.MiddleButton) {
                        it.secondaryActivate();
                    } else {
                        it.activate();
                    }
                }
                onWheel: wheel => entry.modelData.scroll(wheel.angleDelta.y, false)
            }
        }
    }
}
