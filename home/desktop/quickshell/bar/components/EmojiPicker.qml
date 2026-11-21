import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import "../singletons"
import "../data/EmojiData.js" as EmojiData

// Emoji picker. No bar button, no hover trigger: IPC only.
//   qs ipc call emoji toggle | open | close
// Keys: Enter copy, arrows or Ctrl+H/J/K/L move, type to search, Esc close
PanelWindow {
    id: root

    property bool shown: false
    readonly property int cols: 9
    readonly property int cell: 40
    readonly property int maxRows: 6
    readonly property int pad: 12

    visible: shown
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: shown ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    WlrLayershell.namespace: "emoji"

    implicitWidth: cols * cell + pad * 2 + 2
    implicitHeight: content.implicitHeight + pad * 2 + 2
    color: "transparent"

    IpcHandler {
        target: "emoji"

        function toggle(): void { root.shown = !root.shown; }
        function open(): void { root.shown = true; }
        function close(): void { root.shown = false; }
    }

    onShownChanged: {
        if (shown) {
            input.text = "";
            grid.currentIndex = 0;
            input.forceActiveFocus();
        }
    }

    // ---- search: every word of the query must appear in the keywords ----
    readonly property var results: {
        const words = input.text.toLowerCase().trim().split(/\s+/).filter(w => w !== "");
        const all = EmojiData.data;
        if (words.length === 0) return all;
        return all.filter(e => words.every(w => e[1].indexOf(w) >= 0));
    }

    readonly property var current: results[grid.currentIndex] || null

    function move(delta) {
        if (grid.count === 0) return;
        grid.currentIndex = Math.max(0, Math.min(grid.count - 1, grid.currentIndex + delta));
    }

    function pick() {
        const e = current;
        if (!e) return;
        shown = false;
        Quickshell.execDetached(["wl-copy", e[0]]);
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
                    text: "EMOJI"
                    color: Theme.fgDim
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize - 2
                }
                Text {
                    anchors.right: parent.right
                    text: root.results.length + " FOUND"
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
                border.color: input.activeFocus ? Theme.primary : Theme.border

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

                    onTextChanged: grid.currentIndex = 0

                    Keys.onPressed: event => {
                        const ctrl = event.modifiers & Qt.ControlModifier;
                        if (event.key === Qt.Key_Escape) {
                            root.shown = false;
                        } else if (event.key === Qt.Key_Right || (ctrl && event.key === Qt.Key_L)) {
                            root.move(1);
                        } else if (event.key === Qt.Key_Left || (ctrl && event.key === Qt.Key_H)) {
                            root.move(-1);
                        } else if (event.key === Qt.Key_Down || (ctrl && (event.key === Qt.Key_J || event.key === Qt.Key_N))) {
                            root.move(root.cols);
                        } else if (event.key === Qt.Key_Up || (ctrl && (event.key === Qt.Key_K || event.key === Qt.Key_P))) {
                            root.move(-root.cols);
                        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            root.pick();
                        } else {
                            return;
                        }
                        event.accepted = true;
                    }
                }
            }

            // grid
            GridView {
                id: grid
                width: parent.width
                height: Math.max(1, Math.min(Math.ceil(count / root.cols), root.maxRows)) * root.cell
                cellWidth: root.cell
                cellHeight: root.cell
                clip: true
                model: root.results
                currentIndex: 0
                boundsBehavior: Flickable.StopAtBounds
                highlightMoveDuration: 0

                delegate: Rectangle {
                    id: cellItem
                    required property var modelData
                    required property int index

                    readonly property bool sel: GridView.isCurrentItem

                    width: root.cell
                    height: root.cell
                    radius: 0
                    color: sel ? Theme.primary : (hover.containsMouse ? Theme.surfaceHiest : "transparent")

                    // no font.family here so the color emoji font is picked
                    Text {
                        anchors.centerIn: parent
                        text: cellItem.modelData[0]
                        font.pixelSize: 22
                    }

                    MouseArea {
                        id: hover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: grid.currentIndex = cellItem.index
                        onClicked: root.pick()
                    }
                }

                Text {
                    anchors.centerIn: parent
                    visible: grid.count === 0
                    text: "NO MATCHES"
                    color: Theme.fgDim
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize
                }
            }

            // selected emoji name
            Text {
                width: parent.width
                elide: Text.ElideRight
                text: root.current ? root.current[1].toUpperCase() : " "
                color: Theme.fg
                font.family: Theme.font
                font.pixelSize: Theme.fontSize - 1
            }

            // footer
            Text {
                id: hint
                text: "ENTER COPY   ARROWS MOVE   ESC CLOSE"
                color: Theme.fgDim
                font.family: Theme.font
                font.pixelSize: Theme.fontSize - 2
            }
        }
    }
}
