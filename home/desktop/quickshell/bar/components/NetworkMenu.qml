import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import "../singletons"

// Wi-Fi menu (NetworkManager / nmcli). No bar button: IPC only, or right-click
// the Wi-Fi tile in quick settings.
//   qs ipc call network toggle | open | close
// Keys: Enter connect/disconnect, Ctrl+F forget, Ctrl+R rescan, type to filter, Esc close
PanelWindow {
    id: root

    property bool shown: false
    property bool radioOn: true
    property var networks: []        // { ssid, signal, security, active, saved }
    property var savedNames: []
    property string status: ""
    property string pendingSsid: ""  // non-empty while asking for a password

    readonly property int rowH: 28
    readonly property int maxRows: 9
    readonly property int pad: 12

    visible: shown
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: shown ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    WlrLayershell.namespace: "network"

    implicitWidth: 420
    implicitHeight: content.implicitHeight + pad * 2 + 2
    color: "transparent"

    IpcHandler {
        target: "network"

        function toggle(): void { root.shown = !root.shown; }
        function open(): void { root.shown = true; }
        function close(): void { root.shown = false; }
    }

    onShownChanged: {
        if (shown) {
            input.text = "";
            pendingSsid = "";
            status = "";
            list.currentIndex = 0;
            input.forceActiveFocus();
            refresh(true);
        }
    }

    // ---- nmcli ----
    // terse output escapes ':' and '\' with a backslash
    function splitTerse(line) {
        const out = [];
        let cur = "";
        for (let i = 0; i < line.length; i++) {
            const c = line[i];
            if (c === "\\" && i + 1 < line.length) cur += line[++i];
            else if (c === ":") { out.push(cur); cur = ""; }
            else cur += c;
        }
        out.push(cur);
        return out;
    }

    function refresh(rescan) {
        if (rescan) Quickshell.execDetached(["nmcli", "dev", "wifi", "rescan"]);
        if (!radio.running) radio.running = true;
    }

    Timer {
        interval: 4000
        repeat: true
        running: root.shown
        onTriggered: root.refresh(false)
    }

    Timer {
        id: soon
        interval: 800
        onTriggered: root.refresh(false)
    }

    // 1. is the radio on?
    Process {
        id: radio
        command: ["nmcli", "radio", "wifi"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.radioOn = text.trim() === "enabled";
                if (root.radioOn) saved.running = true;
                else root.networks = [];
            }
        }
    }

    // 2. which networks have a saved profile?
    Process {
        id: saved
        command: ["nmcli", "-t", "-f", "NAME,TYPE", "connection", "show"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.savedNames = text.split("\n").filter(l => l !== "")
                    .map(root.splitTerse)
                    .filter(f => f[1] === "802-11-wireless")
                    .map(f => f[0]);
                scan.running = true;
            }
        }
    }

    // 3. visible networks
    Process {
        id: scan
        command: ["nmcli", "-t", "-f", "IN-USE,SSID,SIGNAL,SECURITY", "dev", "wifi", "list"]
        stdout: StdioCollector {
            onStreamFinished: {
                const best = {};
                text.split("\n").filter(l => l !== "").forEach(l => {
                    const f = root.splitTerse(l);
                    const ssid = f[1];
                    if (!ssid) return;
                    const n = {
                        ssid: ssid,
                        active: f[0] === "*",
                        signal: parseInt(f[2]) || 0,
                        security: f[3] || "",
                        saved: root.savedNames.indexOf(ssid) >= 0
                    };
                    const old = best[ssid];
                    if (!old || n.active || (!old.active && n.signal > old.signal)) best[ssid] = n;
                });
                root.networks = Object.values(best).sort((a, b) =>
                    (b.active - a.active) || (b.signal - a.signal));
            }
        }
    }

    // connect: saved profiles and open networks
    Process {
        id: conn
        onExited: code => {
            root.status = code === 0 ? "CONNECTED" : "FAILED";
            root.refresh(false);
        }
    }

    // connect with a password; it goes through the environment, not the arguments
    Process {
        id: connPw
        onExited: code => {
            root.status = code === 0 ? "CONNECTED" : "WRONG PASSWORD?";
            root.refresh(false);
        }
    }

    // ---- list ----
    readonly property var results: {
        if (!radioOn) return [{ kind: "enable" }];
        const q = pendingSsid !== "" ? "" : input.text.toLowerCase().trim();
        const all = networks.map(n => ({ kind: "net", net: n }));
        if (q === "") return all;
        return all.filter(e => e.net.ssid.toLowerCase().indexOf(q) >= 0);
    }

    function activate() {
        const e = results[list.currentIndex];
        if (!e) return;
        if (e.kind === "enable") {
            Quickshell.execDetached(["nmcli", "radio", "wifi", "on"]);
            radioOn = true;
            status = "TURNING ON";
            soon.restart();
            return;
        }
        const n = e.net;
        if (n.active) {
            Quickshell.execDetached(["nmcli", "connection", "down", "id", n.ssid]);
            status = "DISCONNECTING";
            soon.restart();
        } else if (n.saved) {
            status = "CONNECTING";
            conn.command = ["nmcli", "connection", "up", "id", n.ssid];
            conn.running = true;
        } else if (n.security === "") {
            status = "CONNECTING";
            conn.command = ["nmcli", "dev", "wifi", "connect", n.ssid];
            conn.running = true;
        } else {
            pendingSsid = n.ssid;
            input.text = "";
        }
    }

    function submitPassword() {
        if (input.text === "") return;
        status = "CONNECTING";
        connPw.environment = { NM_PW: input.text };
        connPw.command = ["sh", "-c", "printf '%s\\n' \"$NM_PW\" | nmcli --ask dev wifi connect \"$1\"", "_", pendingSsid];
        connPw.running = true;
        pendingSsid = "";
        input.text = "";
    }

    function forget() {
        const e = results[list.currentIndex];
        if (!e || e.kind !== "net" || !e.net.saved) return;
        Quickshell.execDetached(["nmcli", "connection", "delete", "id", e.net.ssid]);
        status = "FORGOTTEN";
        soon.restart();
    }

    // ---- ui ----
    Rectangle {
        anchors.fill: parent
        color: Theme.surface
        radius: 0
        border.width: 1
        border.color: Theme.border

        Column {
            id: content
            x: root.pad + 1
            y: root.pad + 1
            width: parent.width - root.pad * 2 - 2
            spacing: 10

            // header
            Item {
                width: parent.width
                height: hdr.implicitHeight

                Text {
                    id: hdr
                    text: root.pendingSsid !== "" ? "PASSWORD FOR " + root.pendingSsid.toUpperCase() : "WI-FI"
                    color: Theme.fgDim
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize - 2
                    elide: Text.ElideRight
                    width: parent.width - statusText.implicitWidth - 12
                }
                Text {
                    id: statusText
                    anchors.right: parent.right
                    text: root.status !== "" ? root.status : (root.radioOn ? root.networks.length + " NETWORKS" : "OFF")
                    color: root.status === "FAILED" || root.status === "WRONG PASSWORD?" ? Theme.error : Theme.fgDim
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize - 2
                }
            }

            // input (filter, or password when asked)
            Rectangle {
                width: parent.width
                height: 32
                radius: 0
                color: Theme.surfaceHi
                border.width: 1
                border.color: input.activeFocus ? Theme.primary : Theme.border

                Text {
                    id: prompt
                    x: 10
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.pendingSsid !== "" ? "*" : ">"
                    color: Theme.primary
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize
                    font.bold: true
                }

                TextInput {
                    id: input
                    anchors {
                        left: prompt.right
                        leftMargin: 8
                        right: parent.right
                        rightMargin: 10
                        verticalCenter: parent.verticalCenter
                    }
                    color: Theme.fg
                    selectionColor: Theme.primary
                    selectedTextColor: Theme.primaryFg
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize + 1
                    echoMode: root.pendingSsid !== "" ? TextInput.Password : TextInput.Normal
                    passwordCharacter: "*"
                    clip: true

                    onTextChanged: list.currentIndex = 0

                    Keys.onPressed: event => {
                        const ctrl = event.modifiers & Qt.ControlModifier;
                        if (event.key === Qt.Key_Escape) {
                            if (root.pendingSsid !== "") { root.pendingSsid = ""; text = ""; }
                            else root.shown = false;
                        } else if (event.key === Qt.Key_Down || (ctrl && (event.key === Qt.Key_J || event.key === Qt.Key_N))) {
                            list.currentIndex = Math.min(list.count - 1, list.currentIndex + 1);
                        } else if (event.key === Qt.Key_Up || (ctrl && (event.key === Qt.Key_K || event.key === Qt.Key_P))) {
                            list.currentIndex = Math.max(0, list.currentIndex - 1);
                        } else if (ctrl && event.key === Qt.Key_F) {
                            root.forget();
                        } else if (ctrl && event.key === Qt.Key_R) {
                            root.status = "SCANNING";
                            root.refresh(true);
                        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            if (root.pendingSsid !== "") root.submitPassword();
                            else root.activate();
                        } else {
                            return;
                        }
                        event.accepted = true;
                    }
                }
            }

            // networks
            ListView {
                id: list
                width: parent.width
                height: Math.max(1, Math.min(count, root.maxRows)) * root.rowH
                clip: true
                model: root.pendingSsid !== "" ? [] : root.results
                currentIndex: 0
                boundsBehavior: Flickable.StopAtBounds
                highlightMoveDuration: 0

                delegate: Rectangle {
                    id: row
                    required property var modelData
                    required property int index

                    readonly property bool sel: ListView.isCurrentItem
                    readonly property bool isNet: modelData.kind === "net"
                    readonly property var net: isNet ? modelData.net : null

                    width: list.width
                    height: root.rowH
                    radius: 0
                    color: sel ? Theme.primary : (hover.containsMouse ? Theme.surfaceHiest : "transparent")

                    Text {
                        anchors {
                            left: parent.left
                            leftMargin: 10
                            right: info.left
                            rightMargin: 10
                            verticalCenter: parent.verticalCenter
                        }
                        elide: Text.ElideRight
                        text: row.isNet ? row.net.ssid : "TURN ON WI-FI"
                        color: row.sel ? Theme.primaryFg : (row.isNet && row.net.active ? Theme.primary : Theme.fg)
                        font.family: Theme.font
                        font.pixelSize: Theme.fontSize
                        font.bold: row.sel || (row.isNet && row.net.active)
                    }

                    Text {
                        id: info
                        anchors {
                            right: parent.right
                            rightMargin: 10
                            verticalCenter: parent.verticalCenter
                        }
                        text: !row.isNet ? "" : [
                            row.net.active ? "CONNECTED" : (row.net.saved ? "SAVED" : ""),
                            row.net.security === "" ? "OPEN" : row.net.security,
                            row.net.signal + "%"
                        ].filter(x => x !== "").join("  ")
                        color: row.sel ? Theme.primaryFg : Theme.fgDim
                        font.family: Theme.font
                        font.pixelSize: Theme.fontSize - 2
                    }

                    MouseArea {
                        id: hover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: list.currentIndex = row.index
                        onClicked: root.activate()
                    }
                }

                Text {
                    anchors.centerIn: parent
                    visible: list.count === 0
                    text: root.pendingSsid !== "" ? "ENTER TO CONNECT   ESC TO CANCEL" : "NO NETWORKS"
                    color: Theme.fgDim
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize
                }
            }

            // footer
            Text {
                text: "ENTER CONNECT   C-f FORGET   C-r RESCAN   ESC CLOSE"
                color: Theme.fgDim
                font.family: Theme.font
                font.pixelSize: Theme.fontSize - 2
            }
        }
    }
}
