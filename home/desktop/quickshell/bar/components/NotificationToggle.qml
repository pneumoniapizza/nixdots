import QtQuick
import "../singletons"

Item {
    implicitWidth: Theme.barWidth
    implicitHeight: text.implicitHeight

    VText {
        id: text
        anchors.centerIn: parent
        text: Notifs.dnd ? "DND" : "NTF " + Notifs.count
        color: Notifs.dnd ? Theme.error : (Notifs.count > 0 ? Theme.primary : Theme.fgDim)
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: Notifs.dnd = !Notifs.dnd
    }
}
