import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Pipewire
import QtQuick
import "../singletons"

// Volume / brightness popup at the bottom center.
// Volume shows by itself whenever the default sink's volume or mute changes.
// Brightness is shown over IPC, after the key handler has changed it:
//   qs ipc call osd brightness | volume
PanelWindow {
    id: root

    property string kind: "volume"      // "volume" | "brightness"
    property int value: 0               // 0-100
    property bool muted: false
    property bool armed: false          // ignore the initial PipeWire settle at startup

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property bool ready: sink !== null && sink.audio !== null

    visible: false
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    WlrLayershell.namespace: "osd"

    anchors.bottom: true
    margins.bottom: 48
    implicitWidth: 280
    implicitHeight: 44
    color: "transparent"
    mask: Region {}   // click-through

    PwObjectTracker { objects: [root.sink] }

    Timer {
        interval: 2000
        running: true
        onTriggered: root.armed = true
    }

    Timer {
        id: hideTimer
        interval: 1500
        onTriggered: root.visible = false
    }

    function pop() {
        visible = true;
        hideTimer.restart();
    }

    function showVolume() {
        if (!ready) return;
        kind = "volume";
        value = Math.round(sink.audio.volume * 100);
        muted = sink.audio.muted;
        pop();
    }

    Connections {
        target: root.ready ? root.sink.audio : null
        function onVolumeChanged() { if (root.armed) root.showVolume(); }
        function onMutedChanged() { if (root.armed) root.showVolume(); }
    }

    // brightnessctl -m prints: name,class,current,percent%,max
    Process {
        id: bright
        command: ["brightnessctl", "--class=backlight", "-m"]
        stdout: StdioCollector {
            onStreamFinished: {
                const f = text.trim().split(",");
                const pct = parseInt(f[3]);
                if (isNaN(pct)) return;
                root.kind = "brightness";
                root.value = pct;
                root.muted = false;
                root.pop();
            }
        }
    }

    IpcHandler {
        target: "osd"

        function volume(): void { root.showVolume(); }
        function brightness(): void { if (!bright.running) bright.running = true; }
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.surface
        radius: 0
        border.width: 1
        border.color: Theme.outline

        Text {
            id: label
            x: 12
            anchors.verticalCenter: parent.verticalCenter
            width: 52
            text: root.kind === "volume" ? "VOL" : "BRIGHT"
            color: Theme.fgDim
            font.family: Theme.font
            font.pixelSize: Theme.fontSize - 2
        }

        // track
        Rectangle {
            id: track
            anchors {
                left: label.right
                right: pct.left
                rightMargin: 10
                verticalCenter: parent.verticalCenter
            }
            height: 8
            radius: 0
            color: Theme.surfaceHi
            border.width: 1
            border.color: Theme.outline

            Rectangle {
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    left: parent.left
                    margins: 1
                }
                width: Math.max(0, (parent.width - 2) * Math.min(100, root.value) / 100)
                radius: 0
                color: root.muted ? Theme.error : Theme.primary
            }
        }

        Text {
            id: pct
            anchors {
                right: parent.right
                rightMargin: 12
                verticalCenter: parent.verticalCenter
            }
            width: 44
            horizontalAlignment: Text.AlignRight
            text: root.muted ? "MUTE" : root.value + "%"
            color: root.muted ? Theme.error : Theme.fg
            font.family: Theme.font
            font.pixelSize: Theme.fontSize
            font.bold: true
        }
    }
}
