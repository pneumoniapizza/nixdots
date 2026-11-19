import Quickshell
import Quickshell.Wayland
import QtQuick
import "../singletons"

// Overlay shown when a timer finishes, until it is clicked away.
PanelWindow {
    id: root

    visible: Countdown.finished
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    WlrLayershell.namespace: "timer-alert"

    anchors.top: true
    margins.top: 48
    implicitWidth: 280
    implicitHeight: 52
    color: "transparent"

    Rectangle {
        anchors.fill: parent
        color: Theme.surface
        radius: 0
        border.width: 1
        border.color: Theme.error

        Text {
            x: 12
            anchors.verticalCenter: parent.verticalCenter
            text: "TIMER DONE"
            color: Theme.error
            font.family: Theme.font
            font.pixelSize: Theme.fontSize + 2
            font.bold: true
        }

        Text {
            anchors {
                right: parent.right
                rightMargin: 12
                verticalCenter: parent.verticalCenter
            }
            text: Countdown.describe(Countdown.total) + "  CLICK TO DISMISS"
            color: Theme.fgDim
            font.family: Theme.font
            font.pixelSize: Theme.fontSize - 2
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: Countdown.dismiss()
        }
    }
}
