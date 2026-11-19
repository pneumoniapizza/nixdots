import Quickshell
import QtQuick
import "../singletons"

// Bar item, only visible while a timer is running, paused or finished.
// Click opens the timer menu (or dismisses a finished timer).
Item {
    id: root

    property bool blink: false

    visible: Countdown.active || Countdown.finished
    implicitWidth: Theme.barWidth
    implicitHeight: visible ? text.implicitHeight : 0

    Timer {
        interval: 500
        repeat: true
        running: Countdown.finished
        onTriggered: root.blink = !root.blink
        onRunningChanged: if (!running) root.blink = false
    }

    VText {
        id: text
        anchors.centerIn: parent
        bold: true
        text: Countdown.finished
            ? "TMR DONE"
            : "TMR " + Countdown.fmt(Countdown.remaining) + (Countdown.paused ? " ||" : "")
        color: Countdown.finished
            ? (root.blink ? Theme.error : Theme.fg)
            : (Countdown.paused ? Theme.fgDim : Theme.primary)
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (Countdown.finished) Countdown.dismiss();
            else Quickshell.execDetached(["qs", "ipc", "call", "timer", "toggle"]);
        }
    }
}
