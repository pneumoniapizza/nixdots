import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import "../singletons"

// Timer menu. No bar button, no hover trigger: IPC only.
//   qs ipc call timer toggle | open | close | start 10m | cancel
// Type a duration (10m, 1h30m, 90s, 5:00, bare number = minutes) and press Enter.
PanelWindow {
    id: root

    property bool shown: false
    readonly property int rowH: 28
    readonly property int pad: 12

    readonly property var presets: [
        { label: "5 MIN",  secs: 300 },
        { label: "10 MIN", secs: 600 },
        { label: "15 MIN", secs: 900 },
        { label: "25 MIN", secs: 1500 },
        { label: "45 MIN", secs: 2700 },
        { label: "1 HOUR", secs: 3600 }
    ]

    visible: shown
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: shown ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    WlrLayershell.namespace: "timer"

    implicitWidth: 360
    implicitHeight: content.implicitHeight + pad * 2 + 2
    color: "transparent"

    IpcHandler {
        target: "timer"

        function toggle(): void { root.shown = !root.shown; }
        function open(): void { root.shown = true; }
        function close(): void { root.shown = false; }
        function start(spec: string): void {
            const s = Countdown.parse(spec);
            if (s > 0) Countdown.start(s);
        }
        function cancel(): void { Countdown.cancel(); }
    }

    onShownChanged: {
        if (shown) {
            input.text = "";
            list.currentIndex = 0;
            input.forceActiveFocus();
        }
    }

    // ---- actions ----
    readonly property int parsed: Countdown.parse(input.text)

    readonly property var actions: {
        if (parsed > 0)
            return [{ label: "START " + Countdown.describe(parsed), run: () => Countdown.start(parsed) }];
        if (input.text.trim() !== "")
            return [];
        if (Countdown.finished) {
            return [
                { label: "REPEAT " + Countdown.describe(Countdown.total), run: () => Countdown.repeat() },
                { label: "DISMISS", run: () => Countdown.dismiss() }
            ];
        }
        if (Countdown.active) {
            return [
                { label: Countdown.paused ? "RESUME" : "PAUSE", run: () => Countdown.togglePause() },
                { label: "ADD 5 MIN", run: () => Countdown.add(300), keepOpen: true },
                { label: "CANCEL", run: () => Countdown.cancel() }
            ];
        }
        return presets.map(p => ({ label: p.label, run: () => Countdown.start(p.secs) }));
    }

    function run() {
        const a = actions[list.currentIndex];
        if (!a) return;
        a.run();
        if (!a.keepOpen) shown = false;
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
                    text: "TIMER"
                    color: Theme.fgDim
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize - 2
                }
                Text {
                    anchors.right: parent.right
                    text: Countdown.finished ? "DONE" : (Countdown.paused ? "PAUSED" : (Countdown.running ? "RUNNING" : "IDLE"))
                    color: Countdown.finished ? Theme.error : Theme.fgDim
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize - 2
                }
            }

            // current timer
            Item {
                width: parent.width
                height: 52
                visible: Countdown.active || Countdown.finished

                Text {
                    id: big
                    anchors.left: parent.left
                    text: Countdown.finished ? "00:00" : Countdown.fmt(Countdown.remaining)
                    color: Countdown.finished ? Theme.error : (Countdown.paused ? Theme.fgDim : Theme.primary)
                    font.family: Theme.font
                    font.pixelSize: 30
                    font.bold: true
                }

                Text {
                    anchors.right: parent.right
                    anchors.baseline: big.baseline
                    text: "OF " + Countdown.describe(Countdown.total)
                    color: Theme.fgDim
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize - 2
                }

                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: 8
                    radius: 0
                    color: Theme.surfaceHi
                    border.width: 1
                    border.color: Theme.border

                    Rectangle {
                        anchors {
                            top: parent.top
                            bottom: parent.bottom
                            left: parent.left
                            margins: 1
                        }
                        width: Countdown.total > 0
                            ? (parent.width - 2) * (1 - Countdown.remaining / Countdown.total)
                            : 0
                        radius: 0
                        color: Countdown.finished ? Theme.error : Theme.primary
                    }
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
                            root.run();
                        } else {
                            return;
                        }
                        event.accepted = true;
                    }
                }
            }

            // actions
            ListView {
                id: list
                width: parent.width
                height: Math.max(1, count) * root.rowH
                clip: true
                interactive: false
                model: root.actions
                currentIndex: 0
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

                    Text {
                        anchors {
                            left: parent.left
                            leftMargin: 10
                            right: parent.right
                            rightMargin: 10
                            verticalCenter: parent.verticalCenter
                        }
                        elide: Text.ElideRight
                        text: row.modelData.label
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
                        onClicked: root.run()
                    }
                }

                Text {
                    anchors.centerIn: parent
                    visible: list.count === 0
                    text: "INVALID DURATION"
                    color: Theme.error
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize
                }
            }

            // footer
            Text {
                text: "ENTER SELECT   TYPE 10m 1h30m 5:00   ESC CLOSE"
                color: Theme.fgDim
                font.family: Theme.font
                font.pixelSize: Theme.fontSize - 2
            }
        }
    }
}
