import Quickshell.Services.UPower
import QtQuick
import "../singletons"

Item {
    id: root

    readonly property var dev: UPower.displayDevice
    readonly property bool present: dev !== null && dev.isLaptopBattery
    readonly property int pct: present ? Math.round(dev.percentage * 100) : 0

    visible: present
    implicitWidth: Theme.barWidth
    implicitHeight: present ? text.implicitHeight : 0

    VText {
        id: text
        anchors.centerIn: parent
        text: "BAT " + root.pct + "%"
        color: root.pct <= 15 ? Theme.error : Theme.fg
    }
}
