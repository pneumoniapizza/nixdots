import Quickshell
import QtQuick
import "../singletons"

Item {
    implicitWidth: Theme.barWidth
    implicitHeight: text.implicitHeight

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    VText {
        id: text
        anchors.centerIn: parent
        bold: true
        color: Theme.primary
        text: Qt.formatDateTime(clock.date, "ddd dd MMM  HH:mm").toUpperCase()
    }
}
