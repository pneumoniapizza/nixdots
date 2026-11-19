import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import "../singletons"

// App launcher. No bar button, no hover trigger: IPC only.
//   qs ipc call launcher toggle | open | close
PanelWindow {
    id: root

    property bool shown: false
    readonly property int rowH: 28
    readonly property int maxRows: 8
    readonly property int pad: 12

    visible: shown
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: shown ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    WlrLayershell.namespace: "launcher"

    implicitWidth: 480
    implicitHeight: content.implicitHeight + pad * 2 + 2
    color: "transparent"

    IpcHandler {
        target: "launcher"

        function toggle(): void { root.shown = !root.shown; }
        function open(): void { root.shown = true; }
        function close(): void { root.shown = false; }
    }

    onShownChanged: {
        if (shown) {
            input.text = "";
            list.currentIndex = 0;
            input.forceActiveFocus();
        }
    }

    // ---- search ----
    function score(e, q) {
        const name = e.name.toLowerCase();
        if (name.startsWith(q)) return 300 - name.length;
        const i = name.indexOf(q);
        if (i >= 0) return 200 - i;
        const extra = ((e.genericName || "") + " " + (e.comment || "")).toLowerCase();
        if (extra.indexOf(q) >= 0) return 100;
        let p = 0;
        for (let c = 0; c < name.length && p < q.length; c++)
            if (name[c] === q[p]) p++;
        return p === q.length ? 50 : -1;
    }

    readonly property var results: {
        const q = input.text.toLowerCase().trim();
        const apps = DesktopEntries.applications.values.filter(e => !e.noDisplay);
        if (q === "")
            return apps.slice().sort((a, b) => a.name.localeCompare(b.name));
        return apps
            .map(e => ({ e: e, s: score(e, q) }))
            .filter(x => x.s >= 0)
            .sort((a, b) => b.s - a.s || a.e.name.localeCompare(b.e.name))
            .map(x => x.e);
    }

    function launch() {
        const e = results[list.currentIndex];
        if (!e) return;
        shown = false;
        e.execute();
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
                    text: "LAUNCH"
                    color: Theme.fgDim
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize - 2
                }
                Text {
                    anchors.right: parent.right
                    text: root.results.length + " APPS"
                    color: Theme.fgDim
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize - 2
                }
            }

            // input
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
                        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            root.launch();
                        } else {
                            return;
                        }
                        event.accepted = true;
                    }
                }
            }

            // results
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

                    width: list.width
                    height: root.rowH
                    radius: 0
                    color: sel ? Theme.primary : (hover.containsMouse ? Theme.surfaceHiest : "transparent")

                    Image {
                        id: icon
                        x: 8
                        anchors.verticalCenter: parent.verticalCenter
                        width: 16
                        height: 16
                        sourceSize: Qt.size(16, 16)
                        source: Quickshell.iconPath(row.modelData.icon, true)
                        asynchronous: true
                    }

                    Text {
                        anchors {
                            left: icon.right
                            leftMargin: 8
                            right: parent.right
                            rightMargin: 8
                            verticalCenter: parent.verticalCenter
                        }
                        elide: Text.ElideRight
                        text: row.modelData.name
                        color: row.sel ? Theme.primaryFg : Theme.fg
                        font.family: Theme.font
                        font.pixelSize: Theme.fontSize
                        font.bold: row.sel
                    }

                    MouseArea {
                        id: hover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: list.currentIndex = row.index
                        onClicked: root.launch()
                    }
                }

                Text {
                    anchors.centerIn: parent
                    visible: list.count === 0
                    text: "NO MATCHES"
                    color: Theme.fgDim
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize
                }
            }
        }
    }
}
