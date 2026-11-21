import QtQuick
import "../singletons"

// Square toggle button for the quick settings panel
Rectangle {
    id: root

    property string text: ""
    property bool active: false
    property bool available: true

    signal clicked()
    signal rightClicked()

    height: 32
    radius: 0
    opacity: available ? 1 : 0.4
    color: active ? Theme.primary : (area.containsMouse && available ? Theme.surfaceHiest : "transparent")
    border.width: 1
    border.color: active ? Theme.primary : Theme.border

    Text {
        anchors.centerIn: parent
        text: root.text
        color: root.active ? Theme.primaryFg : Theme.fg
        font.family: Theme.font
        font.pixelSize: Theme.fontSize - 1
        font.bold: root.active
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        enabled: root.available
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor
        onClicked: mouse => {
            if (mouse.button === Qt.RightButton) root.rightClicked();
            else root.clicked();
        }
    }
}
