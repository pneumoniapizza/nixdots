import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Bluetooth
import QtQuick
import "../singletons"

// Bluetooth menu. No bar button: IPC only, or right-click the Bluetooth tile
// in quick settings. Scans while it is open.
//   qs ipc call bluetooth toggle | open | close
// Keys: Enter connect/disconnect/pair, Ctrl+F forget, Ctrl+S scan on/off,
//       type to filter, Esc close
PanelWindow {
    id: root

    property bool shown: false

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property int rowH: 28
    readonly property int maxRows: 9
    readonly property int pad: 12

    visible: shown
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: shown ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    WlrLayershell.namespace: "bluetooth"

    implicitWidth: 420
    implicitHeight: content.implicitHeight + pad * 2 + 2
    color: "transparent"

    IpcHandler {
        target: "bluetooth"

        function toggle(): void { root.shown = !root.shown; }
        function open(): void { root.shown = true; }
        function close(): void { root.shown = false; }
    }

    onShownChanged: {
        if (shown) {
            input.text = "";
            list.currentIndex = 0;
            input.forceActiveFocus();
            if (adapter && adapter.enabled) adapter.discovering = true;
        } else if (adapter) {
            adapter.discovering = false;
        }
    }

    // unnamed devices show up as their MAC address; hide them unless paired
    function usable(d) {
        if (!d.name) return false;
        if (d.paired || d.connected) return true;
        return d.name.replace(/-/g, ":").toUpperCase() !== String(d.address).toUpperCase();
    }

    function rank(d) { return d.connected ? 0 : (d.paired ? 1 : 2); }

    // ---- list ----
    readonly property var results: {
        if (!adapter) return [];
        if (!adapter.enabled) return [{ kind: "enable" }];
        const q = input.text.toLowerCase().trim();
        return adapter.devices.values
            .filter(d => usable(d) && (q === "" || d.name.toLowerCase().indexOf(q) >= 0))
            .sort((a, b) => (rank(a) - rank(b)) || a.name.localeCompare(b.name))
            .map(d => ({ kind: "dev", dev: d }));
    }

    function activate() {
        const e = results[list.currentIndex];
        if (!e) return;
        if (e.kind === "enable") {
            adapter.enabled = true;
            adapter.discovering = true;
            return;
        }
        const d = e.dev;
        if (d.connected) d.disconnect();
        else if (d.paired) d.connect();
        else {
            d.trusted = true;
            d.pair();
        }
    }

    function forget() {
        const e = results[list.currentIndex];
        if (e && e.kind === "dev" && e.dev.paired) e.dev.forget();
    }

    function tag(d) {
        if (d.pairing) return "PAIRING";
        if (d.connected) return "CONNECTED";
        if (d.paired) return "PAIRED";
        return "NEW";
    }

    // ---- ui ----
    Rectangle {
        anchors.fill: parent
        color: Theme.surface
        radius: 0
        border.width: 1
        border.color: Theme.outline

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
                    text: "BLUETOOTH"
                    color: Theme.fgDim
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize - 2
                }
                Text {
                    anchors.right: parent.right
                    text: !root.adapter ? "NO ADAPTER"
                        : (!root.adapter.enabled ? "OFF"
                        : (root.adapter.discovering ? "SCANNING" : "IDLE"))
                    color: Theme.fgDim
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize - 2
                }
            }

            // filter
            Rectangle {
                width: parent.width
                height: 32
                radius: 0
                color: Theme.surfaceHi
                border.width: 1
                border.color: input.activeFocus ? Theme.primary : Theme.outline

                Text {
                    id: prompt
                    x: 10
                    anchors.verticalCenter: parent.verticalCenter
                    text: ">"
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
                    clip: true

                    onTextChanged: list.currentIndex = 0

                    Keys.onPressed: event => {
                        const ctrl = event.modifiers & Qt.ControlModifier;
                        if (event.key === Qt.Key_Escape) {
                            root.shown = false;
                        } else if (event.key === Qt.Key_Down || (ctrl && (event.key === Qt.Key_J || event.key === Qt.Key_N))) {
                            list.currentIndex = Math.min(list.count - 1, list.currentIndex + 1);
                        } else if (event.key === Qt.Key_Up || (ctrl && (event.key === Qt.Key_K || event.key === Qt.Key_P))) {
                            list.currentIndex = Math.max(0, list.currentIndex - 1);
                        } else if (ctrl && event.key === Qt.Key_F) {
                            root.forget();
                        } else if (ctrl && event.key === Qt.Key_S) {
                            if (root.adapter && root.adapter.enabled) root.adapter.discovering = !root.adapter.discovering;
                        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            root.activate();
                        } else {
                            return;
                        }
                        event.accepted = true;
                    }
                }
            }

            // devices
            ListView {
                id: list
                width: parent.width
                height: Math.max(1, Math.min(count, root.maxRows)) * root.rowH
                clip: true
                model: root.results
                currentIndex: 0
                boundsBehavior: Flickable.StopAtBounds
                highlightMoveDuration: 0

                delegate: Rectangle {
                    id: row
                    required property var modelData
                    required property int index

                    readonly property bool sel: ListView.isCurrentItem
                    readonly property bool isDev: modelData.kind === "dev"
                    readonly property var dev: isDev ? modelData.dev : null

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
                        text: row.isDev ? row.dev.name : "TURN ON BLUETOOTH"
                        color: row.sel ? Theme.primaryFg : (row.isDev && row.dev.connected ? Theme.primary : Theme.fg)
                        font.family: Theme.font
                        font.pixelSize: Theme.fontSize
                        font.bold: row.sel || (row.isDev && row.dev.connected)
                    }

                    Text {
                        id: info
                        anchors {
                            right: parent.right
                            rightMargin: 10
                            verticalCenter: parent.verticalCenter
                        }
                        text: !row.isDev ? "" : [
                            root.tag(row.dev),
                            row.dev.batteryAvailable ? Math.round(row.dev.battery * 100) + "%" : ""
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
                    text: !root.adapter ? "NO BLUETOOTH ADAPTER" : (input.text === "" ? "NO DEVICES FOUND" : "NO MATCHES")
                    color: Theme.fgDim
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize
                }
            }

            // footer
            Text {
                text: "ENTER CONNECT   C-f FORGET   C-s SCAN   ESC CLOSE"
                color: Theme.fgDim
                font.family: Theme.font
                font.pixelSize: Theme.fontSize - 2
            }
        }
    }
}
