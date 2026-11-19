import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import "../singletons"

// Wallpaper switcher: sets the wallpaper and re-runs matugen on it.
// IPC only:  qs ipc call wallpaper toggle | open | close | random | set <path> | mode
// Keys: hjkl/arrows move, gg/G first/last, Enter apply, m mode, t/T scheme, r rescan, q/Esc close
PanelWindow {
    id: root

    property bool shown: false
    property var files: []
    property bool pendingG: false
    property bool restored: false

    readonly property int cols: 4
    readonly property int cellW: 224
    readonly property int cellH: 150
    readonly property int pad: 12

    visible: shown
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: shown ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    WlrLayershell.namespace: "wallpaper"

    implicitWidth: cols * cellW + pad * 2 + 2
    implicitHeight: content.implicitHeight + pad * 2 + 2
    color: "transparent"

    // ---- logic ----
    function nameOf(p) { return p.split("/").pop(); }

    function rescan() {
        if (!scan.running) scan.running = true;
    }

    function runMatugen(path) {
        Quickshell.execDetached(["matugen", "image", path, "-m", Settings.mode, "-t", Settings.scheme]);
    }

    function setWallpaper(path) {
        const cmd = Array.from(Settings.wallpaperCmd);
        cmd.push(path);
        Quickshell.execDetached(cmd);
    }

    function apply(path) {
        if (!path) return;
        Settings.set("current", path);
        setWallpaper(path);
        runMatugen(path);
        if (Settings.closeOnApply) shown = false;
    }

    function toggleMode() {
        Settings.set("mode", Settings.mode === "dark" ? "light" : "dark");
        if (Settings.current !== "") runMatugen(Settings.current);
    }

    function cycleScheme(dir) {
        const l = Settings.schemes;
        const i = Math.max(0, l.indexOf(Settings.scheme));
        Settings.set("scheme", l[(i + dir + l.length) % l.length]);
        if (Settings.current !== "") runMatugen(Settings.current);
    }

    function random() {
        if (files.length === 0) return;
        apply(files[Math.floor(Math.random() * files.length)]);
    }

    onShownChanged: {
        if (shown) {
            rescan();
            keys.forceActiveFocus();
            const i = files.indexOf(Settings.current);
            grid.currentIndex = i >= 0 ? i : 0;
        }
    }

    Component.onCompleted: rescan()

    // re-apply the saved wallpaper once on startup (colors.json already persists)
    Connections {
        target: Settings
        function onLoaded() {
            if (root.restored) return;
            root.restored = true;
            if (Settings.restoreOnStart && Settings.current !== "")
                root.setWallpaper(Settings.current);
        }
    }

    Process {
        id: scan
        command: [
            "find", Settings.resolvedDir(), "-maxdepth", "2", "-type", "f",
            "(", "-iname", "*.jpg", "-o", "-iname", "*.jpeg", "-o", "-iname", "*.png",
            "-o", "-iname", "*.webp", "-o", "-iname", "*.gif", ")"
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                const list = text.split("\n").filter(l => l !== "");
                list.sort((a, b) => a.localeCompare(b));
                root.files = list;
                const i = list.indexOf(Settings.current);
                if (root.shown && grid.currentIndex === 0 && i > 0) grid.currentIndex = i;
            }
        }
    }

    IpcHandler {
        target: "wallpaper"

        function toggle(): void { root.shown = !root.shown; }
        function open(): void { root.shown = true; }
        function close(): void { root.shown = false; }
        function random(): void { root.random(); }
        function set(path: string): void { root.apply(path); }
        function mode(): void { root.toggleMode(); }
    }

    // small square button
    component Chip: Rectangle {
        id: chip
        property string label: ""
        signal clicked()

        width: chipText.implicitWidth + 20
        height: 24
        radius: 0
        color: chipArea.containsMouse ? Theme.surfaceHiest : "transparent"
        border.width: 1
        border.color: Theme.outline

        Text {
            id: chipText
            anchors.centerIn: parent
            text: chip.label
            color: Theme.fg
            font.family: Theme.font
            font.pixelSize: Theme.fontSize - 1
        }
        MouseArea {
            id: chipArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: chip.clicked()
        }
    }

    // ---- ui ----
    Rectangle {
        anchors.fill: parent
        color: Theme.surface
        radius: 0
        border.width: 1
        border.color: Theme.outline

        Item {
            id: keys
            anchors.fill: parent
            focus: true

            Timer {
                id: gTimer
                interval: 500
                onTriggered: root.pendingG = false
            }

            Keys.onPressed: event => {
                const k = event.key;
                const t = event.text;
                if (k === Qt.Key_Escape || t === "q") root.shown = false;
                else if (t === "h" || k === Qt.Key_Left) grid.moveCurrentIndexLeft();
                else if (t === "l" || k === Qt.Key_Right) grid.moveCurrentIndexRight();
                else if (t === "j" || k === Qt.Key_Down) grid.moveCurrentIndexDown();
                else if (t === "k" || k === Qt.Key_Up) grid.moveCurrentIndexUp();
                else if (t === "G") grid.currentIndex = Math.max(0, grid.count - 1);
                else if (t === "g") {
                    if (root.pendingG) {
                        grid.currentIndex = 0;
                        root.pendingG = false;
                    } else {
                        root.pendingG = true;
                        gTimer.restart();
                    }
                    event.accepted = true;
                    return;
                }
                else if (k === Qt.Key_Return || k === Qt.Key_Enter || k === Qt.Key_Space)
                    root.apply(root.files[grid.currentIndex]);
                else if (t === "m") root.toggleMode();
                else if (t === "t") root.cycleScheme(1);
                else if (t === "T") root.cycleScheme(-1);
                else if (t === "r") root.rescan();
                else return;
                root.pendingG = false;
                event.accepted = true;
            }
        }

        Column {
            id: content
            x: root.pad + 1
            y: root.pad + 1
            width: parent.width - root.pad * 2 - 2
            spacing: 10

            // header
            Item {
                width: parent.width
                height: 24

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "WALLPAPER"
                    color: Theme.fgDim
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize - 2
                }

                Row {
                    anchors.right: parent.right
                    spacing: 6

                    Chip {
                        label: "MODE: " + Settings.mode.toUpperCase()
                        onClicked: root.toggleMode()
                    }
                    Chip {
                        label: "TYPE: " + Settings.scheme.replace("scheme-", "").toUpperCase()
                        onClicked: root.cycleScheme(1)
                    }
                    Chip {
                        label: "RESCAN"
                        onClicked: root.rescan()
                    }
                }
            }

            // grid
            GridView {
                id: grid
                width: parent.width
                height: root.cellH * 3
                cellWidth: root.cellW
                cellHeight: root.cellH
                clip: true
                model: root.files
                boundsBehavior: Flickable.StopAtBounds
                highlightMoveDuration: 0
                keyNavigationEnabled: false

                delegate: Item {
                    id: cell
                    required property string modelData
                    required property int index

                    readonly property bool sel: GridView.isCurrentItem
                    readonly property bool active: modelData === Settings.current

                    width: grid.cellWidth
                    height: grid.cellHeight

                    Rectangle {
                        x: 6
                        y: 6
                        width: parent.width - 12
                        height: parent.height - 12
                        radius: 0
                        color: Theme.surfaceHi
                        border.width: cell.sel ? 2 : 1
                        border.color: cell.sel ? Theme.primary : Theme.outline

                        Image {
                            anchors {
                                fill: parent
                                margins: cell.sel ? 2 : 1
                                bottomMargin: 20
                            }
                            source: "file://" + cell.modelData
                            sourceSize: Qt.size(320, 180)
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            cache: true
                            clip: true
                        }

                        // name bar
                        Rectangle {
                            anchors {
                                left: parent.left
                                right: parent.right
                                bottom: parent.bottom
                                margins: cell.sel ? 2 : 1
                            }
                            height: 18
                            radius: 0
                            color: cell.sel ? Theme.primary : Theme.surfaceHiest

                            Text {
                                anchors {
                                    left: parent.left
                                    leftMargin: 6
                                    right: tag.left
                                    rightMargin: 6
                                    verticalCenter: parent.verticalCenter
                                }
                                elide: Text.ElideRight
                                text: root.nameOf(cell.modelData)
                                color: cell.sel ? Theme.primaryFg : Theme.fgDim
                                font.family: Theme.font
                                font.pixelSize: Theme.fontSize - 2
                            }
                            Text {
                                id: tag
                                anchors {
                                    right: parent.right
                                    rightMargin: 6
                                    verticalCenter: parent.verticalCenter
                                }
                                visible: cell.active
                                text: "ACTIVE"
                                color: cell.sel ? Theme.primaryFg : Theme.primary
                                font.family: Theme.font
                                font.pixelSize: Theme.fontSize - 2
                                font.bold: true
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onEntered: grid.currentIndex = cell.index
                            onClicked: root.apply(cell.modelData)
                        }
                    }
                }

                Text {
                    anchors.centerIn: parent
                    visible: grid.count === 0
                    text: "NO IMAGES IN " + Settings.wallpaperDir
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
                    text: "hjkl MOVE   gg/G ENDS   ENTER APPLY   m MODE   t/T TYPE   r RESCAN   q CLOSE"
                    color: Theme.fgDim
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize - 2
                }
                Text {
                    anchors.right: parent.right
                    text: root.files.length + " IMAGES"
                    color: Theme.fgDim
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize - 2
                }
            }
        }
    }
}
