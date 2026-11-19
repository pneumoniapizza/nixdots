import QtQuick
import "../singletons"

// Vertical text (reads bottom → top). Item size = rotated size.
Item {
    id: root

    property string text: ""
    property color color: Theme.fg
    property bool bold: false
    property int pixelSize: Theme.fontSize
    property int elide: Text.ElideNone
    property real maxLength: -1   // max length along the bar; -1 = unlimited

    implicitWidth: label.implicitHeight
    implicitHeight: maxLength > 0 ? Math.min(label.implicitWidth, maxLength) : label.implicitWidth

    Text {
        id: label
        anchors.centerIn: parent
        width: root.maxLength > 0 ? root.height : implicitWidth
        rotation: -90
        text: root.text
        color: root.color
        elide: root.elide
        horizontalAlignment: Text.AlignHCenter
        font.family: Theme.font
        font.pixelSize: root.pixelSize
        font.bold: root.bold
    }
}
