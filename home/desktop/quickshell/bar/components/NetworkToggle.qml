import Quickshell
import Quickshell.Io
import QtQuick
import "../singletons"

// Bar button for Wi-Fi. Left click opens the Wi-Fi menu, right click toggles the radio.
Item {
    id: root

    // "connected" | "disconnected" | "off" | "none" (no wifi device)
    property string wifiState: "none"

    visible: wifiState !== "none"
    implicitWidth: Theme.barWidth
    implicitHeight: visible ? label.implicitHeight + 8 : 0

    // nmcli -t -f TYPE,STATE device  ->  wifi:connected / wifi:disconnected / wifi:unavailable
    Process {
        id: poll
        command: ["nmcli", "-t", "-f", "TYPE,STATE", "device"]
        stdout: StdioCollector {
            onStreamFinished: {
                const line = text.split("\n").find(l => l.startsWith("wifi:"));
                if (!line) { root.wifiState = "none"; return; }
                const s = line.slice(5);
                root.wifiState = s === "connected" ? "connected" : (s === "unavailable" ? "off" : "disconnected");
            }
        }
    }

    Timer {
        interval: 10000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: if (!poll.running) poll.running = true
    }

    Timer {
        id: soon
        interval: 800
        onTriggered: if (!poll.running) poll.running = true
    }

    // hover highlight so it reads as a button
    Rectangle {
        anchors.fill: parent
        radius: 0
        color: area.containsMouse ? Theme.surfaceHiest : "transparent"
    }

    VText {
        id: label
        anchors.centerIn: parent
        text: root.wifiState === "off" ? "WIFI OFF" : "WIFI"
        color: root.wifiState === "connected" ? Theme.primary : (root.wifiState === "off" ? Theme.error : Theme.fgDim)
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor
        onClicked: mouse => {
            if (mouse.button === Qt.RightButton) {
                Quickshell.execDetached(["nmcli", "radio", "wifi", root.wifiState === "off" ? "on" : "off"]);
                soon.restart();
            } else {
                Quickshell.execDetached(["qs", "ipc", "call", "network", "toggle"]);
            }
        }
    }
}
