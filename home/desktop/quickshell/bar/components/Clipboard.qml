import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import "../singletons"

// Clipboard history (cliphist). No bar button, no hover trigger: IPC only.
//   qs ipc call clipboard toggle | open | close | wipe
// Image entries get a thumbnail, decoded lazily into a runtime cache dir.
// Keys: Enter copy, Ctrl+D delete entry, Ctrl+J/K or arrows move, Esc close
PanelWindow {
    id: root

    property bool shown: false
    property var entries: []
    readonly property int rowH: 28
    readonly property int maxRows: 8
    readonly property int pad: 12
    readonly property int thumbH: 56
    readonly property string previewDir: (Quickshell.env("XDG_RUNTIME_DIR") || "/tmp") + "/clipboard-previews"

    visible: shown
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: shown ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    WlrLayershell.namespace: "clipboard"

    implicitWidth: 480
    implicitHeight: content.implicitHeight + pad * 2 + 2
    color: "transparent"

    IpcHandler {
        target: "clipboard"

        function toggle(): void { root.shown = !root.shown; }
        function open(): void { root.shown = true; }
        function close(): void { root.shown = false; }
        function wipe(): void { root.wipe(); }
    }

    onShownChanged: {
        if (shown) {
            input.text = "";
            list.currentIndex = 0;
            reload();
            // drop cached previews older than a day
            Quickshell.execDetached(["sh", "-c", "find \"$1\" -type f -mtime +0 -delete 2>/dev/null", "_", previewDir]);
            input.forceActiveFocus();
        }
    }

    // ---- data ----
    function reload() {
        if (!fetch.running) fetch.running = true;
    }

    // cliphist list lines look like "<id>\t<preview>"
    Process {
        id: fetch
        command: ["cliphist", "list"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.entries = text.split("\n").filter(l => l !== "").map(l => {
                    const t = l.indexOf("\t");
                    const prev = l.slice(t + 1);
                    return {
                        line: l,
                        id: l.slice(0, t),
                        text: prev,
                        image: prev.startsWith("[[ binary data")
                    };
                });
            }
        }
    }

    // ---- search ----
    readonly property var results: {
        const q = input.text.toLowerCase().trim();
        if (q === "") return entries;
        return entries.filter(e => e.text.toLowerCase().indexOf(q) >= 0);
    }

    function label(e) {
        if (e.image) return "IMAGE " + e.text.replace(/^\[\[ binary data\s*/, "").replace(/\s*\]\]$/, "");
        return e.text.trim().replace(/\s+/g, " ");
    }

    // ---- actions ----
    function pick() {
        const e = results[list.currentIndex];
        if (!e) return;
        shown = false;
        Quickshell.execDetached(["sh", "-c", "cliphist decode \"$1\" | wl-copy", "_", e.id]);
    }

    function remove() {
        const e = results[list.currentIndex];
        if (!e) return;
        const keep = list.currentIndex;
        Quickshell.execDetached(["sh", "-c", "printf '%s\\n' \"$1\" | cliphist delete", "_", e.line]);
        root.entries = root.entries.filter(x => x.id !== e.id);
        list.currentIndex = Math.max(0, Math.min(keep, list.count - 1));
    }

    function wipe() {
        Quickshell.execDetached(["cliphist", "wipe"]);
        root.entries = [];
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
                    text: "CLIPBOARD"
                    color: Theme.fgDim
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize - 2
                }
                Text {
                    anchors.right: parent.right
                    text: root.results.length + " ENTRIES"
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
                        } else if (ctrl && event.key === Qt.Key_D) {
                            root.remove();
                        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            root.pick();
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
                height: Math.max(root.rowH, Math.min(contentHeight, root.maxRows * root.rowH))
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

                    property bool thumbReady: false

                    width: list.width
                    height: modelData.image ? root.thumbH + 8 : root.rowH
                    radius: 0
                    color: sel ? Theme.primary : (hover.containsMouse ? Theme.surfaceHiest : "transparent")

                    // decode image entries to a cache file the first time the row is shown
                    Process {
                        id: decode
                        command: ["sh", "-c",
                            "f=\"$1/$2\"; mkdir -p \"$1\"; [ -s \"$f\" ] || cliphist decode \"$2\" > \"$f\"",
                            "_", root.previewDir, row.modelData.id]
                        onExited: row.thumbReady = true
                    }
                    Component.onCompleted: if (modelData.image) decode.running = true

                    Rectangle {
                        id: thumb
                        visible: row.modelData.image
                        x: 10
                        anchors.verticalCenter: parent.verticalCenter
                        width: 88
                        height: root.thumbH
                        radius: 0
                        color: Theme.surfaceHi
                        border.width: 1
                        border.color: row.sel ? Theme.primaryFg : Theme.outline

                        Image {
                            anchors.fill: parent
                            anchors.margins: 1
                            source: row.thumbReady ? "file://" + root.previewDir + "/" + row.modelData.id : ""
                            sourceSize: Qt.size(176, 112)
                            fillMode: Image.PreserveAspectFit
                            asynchronous: true
                            cache: false
                        }
                    }

                    Text {
                        anchors {
                            left: row.modelData.image ? thumb.right : parent.left
                            leftMargin: 10
                            right: parent.right
                            rightMargin: 10
                            verticalCenter: parent.verticalCenter
                        }
                        elide: Text.ElideRight
                        text: root.label(row.modelData)
                        color: row.sel ? Theme.primaryFg : (row.modelData.image ? Theme.fgDim : Theme.fg)
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
                        onClicked: root.pick()
                    }
                }

                Text {
                    anchors.centerIn: parent
                    visible: list.count === 0
                    text: input.text === "" ? "CLIPBOARD EMPTY" : "NO MATCHES"
                    color: Theme.fgDim
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize
                }
            }

            // footer
            Item {
                width: parent.width
                height: hint.implicitHeight

                Text {
                    id: hint
                    text: "ENTER COPY   C-d DELETE   C-j/k MOVE   ESC CLOSE"
                    color: Theme.fgDim
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize - 2
                }
            }
        }
    }
}
