import QtQuick
import "../singletons"

// Square slider row for the quick settings panel: LABEL ====---- 60%
// Click or drag the track, scroll to nudge, click the label to toggle mute.
Item {
    id: root

    property string label: ""
    property real value: 0          // 0..1
    property bool muted: false
    property bool clickableLabel: false
    property string valueText: ""     // overrides the percentage on the right

    signal moved(real v)
    signal labelClicked()

    implicitHeight: 28

    Text {
        id: lbl
        x: 0
        anchors.verticalCenter: parent.verticalCenter
        width: 52
        text: root.muted ? "MUTE" : root.label
        color: root.muted ? Theme.error : (labelArea.containsMouse && root.clickableLabel ? Theme.fg : Theme.fgDim)
        font.family: Theme.font
        font.pixelSize: Theme.fontSize - 2

        MouseArea {
            id: labelArea
            anchors.fill: parent
            hoverEnabled: true
            enabled: root.clickableLabel
            cursorShape: Qt.PointingHandCursor
            onClicked: root.labelClicked()
        }
    }

    Rectangle {
        id: track
        anchors {
            left: lbl.right
            right: pct.left
            rightMargin: 10
            verticalCenter: parent.verticalCenter
        }
        height: 8
        radius: 0
        color: Theme.surfaceHi
        border.width: 1
        border.color: Theme.border

        Rectangle {
            anchors {
                top: parent.top
                bottom: parent.bottom
                left: parent.left
                margins: 1
            }
            width: Math.max(0, (parent.width - 2) * Math.max(0, Math.min(1, root.value)))
            radius: 0
            color: root.muted ? Theme.error : Theme.primary
        }
    }

    // taller hit area than the 8px track
    MouseArea {
        anchors {
            left: track.left
            right: track.right
            verticalCenter: track.verticalCenter
        }
        height: 24
        cursorShape: Qt.PointingHandCursor

        function apply(x) { root.moved(Math.max(0, Math.min(1, x / width))); }

        onPressed: mouse => apply(mouse.x)
        onPositionChanged: mouse => { if (pressed) apply(mouse.x); }
        onWheel: wheel => root.moved(Math.max(0, Math.min(1, root.value + (wheel.angleDelta.y > 0 ? 0.05 : -0.05))))
    }

    Text {
        id: pct
        anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
        }
        width: 44
        horizontalAlignment: Text.AlignRight
        text: root.valueText !== "" ? root.valueText : Math.round(root.value * 100) + "%"
        color: root.muted ? Theme.error : Theme.fg
        font.family: Theme.font
        font.pixelSize: Theme.fontSize
        font.bold: true
    }
}
