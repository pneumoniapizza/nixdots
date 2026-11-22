import Quickshell
import Quickshell.Wayland
import Quickshell.Services.UPower
import QtQuick
import "../singletons"

// Battery warnings at the top center: low (15%), critical (5%), plus a short
// notice when the charger is plugged in or removed. Click to dismiss.
// Low fades after a few seconds, critical stays until you plug in or click it.
PanelWindow {
    id: root

    // thresholds in percent
    property int lowAt: 15
    property int criticalAt: 5

    readonly property var dev: UPower.displayDevice
    readonly property bool present: dev !== null && dev.isLaptopBattery
    readonly property int pct: present ? Math.round(dev.percentage * 100) : 0
    readonly property bool discharging: present && dev.state === UPowerDeviceState.Discharging

    property string kind: ""            // "" | "low" | "critical" | "plugged" | "unplugged"
    property bool armed: false          // ignore the first seconds while UPower settles
    property bool warnedLow: false
    property bool warnedCritical: false

    readonly property bool warning: kind === "low" || kind === "critical"

    visible: kind !== ""
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    WlrLayershell.namespace: "battery-alert"

    anchors.top: true
    margins.top: 108
    implicitWidth: 300
    implicitHeight: 52
    color: "transparent"

    Timer {
        interval: 3000
        running: true
        onTriggered: {
            root.armed = true;
            root.check();   // already low at login
        }
    }

    Timer {
        id: hideTimer
        onTriggered: root.kind = ""
    }

    function show(k) {
        kind = k;
        if (k === "critical") hideTimer.stop();
        else {
            hideTimer.interval = k === "low" ? 10000 : 2500;
            hideTimer.restart();
        }
    }

    function check() {
        if (!armed || !present) return;

        if (!discharging) {
            warnedLow = false;
            warnedCritical = false;
            if (warning) kind = "";
            return;
        }

        if (pct <= criticalAt && !warnedCritical) {
            warnedCritical = true;
            warnedLow = true;
            show("critical");
        } else if (pct <= lowAt && !warnedLow) {
            warnedLow = true;
            show("low");
        } else if (pct > lowAt + 5) {
            // charged up a bit without a plug event: allow warning again
            warnedLow = false;
            warnedCritical = false;
        }
    }

    onPctChanged: check()

    onDischargingChanged: {
        if (!armed || !present) return;
        show(discharging ? "unplugged" : "plugged");
        check();
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.surface
        radius: 0
        border.width: 1
        border.color: root.warning ? Theme.error : Theme.border

        Text {
            x: 12
            anchors.verticalCenter: parent.verticalCenter
            text: root.kind === "critical" ? "CRITICAL BATTERY"
                : root.kind === "low" ? "LOW BATTERY"
                : root.kind === "plugged" ? "CHARGER CONNECTED"
                : "ON BATTERY"
            color: root.warning ? Theme.error : Theme.fg
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
            text: root.kind === "critical" ? root.pct + "%  PLUG IN NOW" : root.pct + "%"
            color: Theme.fgDim
            font.family: Theme.font
            font.pixelSize: Theme.fontSize - 2
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.kind = ""
        }
    }
}
