import QtQuick
import "../singletons"

// Vertical now-playing text; click to toggle the player popup
Item {
    id: root

    clip: true

    VText {
        anchors.centerIn: parent
        height: parent.height
        maxLength: parent.height
        elide: Text.ElideRight
        color: popup.visible ? Theme.primary : (Media.hasPlayer ? Theme.fg : Theme.fgDim)
        text: !Media.hasPlayer ? "NO MEDIA"
            : (Media.playing ? "[>] " : "[||] ") + Media.title + (Media.artist ? " - " + Media.artist : "")
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: popup.visible = !popup.visible
    }

    MediaPopup {
        id: popup
        anchor.item: root
    }
}
