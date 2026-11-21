import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Bluetooth
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower
import QtQuick
import "../singletons"

// Quick settings: volume, mic, brightness, Wi-Fi, Bluetooth, DND, power profile.
// Opens at the bottom-left next to the bar.
//   qs ipc call quicksettings toggle | open | close
PanelWindow {
    id: root

    property bool shown: false
    readonly property int pad: 12

    // audio
    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource
    readonly property bool sinkReady: sink !== null && sink.audio !== null
    readonly property bool sourceReady: source !== null && source.audio !== null

    // brightness (-1 = no backlight)
    property int brightPct: -1
    // wifi
    property bool wifiOn: false
    // bluetooth
    readonly property var bt: Bluetooth.defaultAdapter

    visible: shown
    anchors {
        bottom: true
        left: true
    }
    margins {
        bottom: 8
        left: Theme.barWidth + 8
    }
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: shown ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    WlrLayershell.namespace: "quicksettings"

    implicitWidth: 340
    implicitHeight: content.implicitHeight + pad * 2 + 2
    color: "transparent"

    PwObjectTracker { objects: [root.sink, root.source] }

    IpcHandler {
        target: "quicksettings"

        function toggle(): void { root.shown = !root.shown; }
        function open(): void { root.shown = true; }
        function close(): void { root.shown = false; }
    }

    onShownChanged: {
        if (shown) {
            refresh();
            keys.forceActiveFocus();
        }
    }

    function refresh() {
        if (!readBright.running) readBright.running = true;
        if (!readWifi.running) readWifi.running = true;
    }

    // ---- brightness ----
    // brightnessctl -m prints: name,class,current,percent%,max
    Process {
        id: readBright
        command: ["brightnessctl", "--class=backlight", "-m"]
        stdout: StdioCollector {
            onStreamFinished: {
                const pct = parseInt(text.trim().split(",")[3]);
                root.brightPct = isNaN(pct) ? -1 : pct;
            }
        }
    }

    Timer {
        id: brightApply
        interval: 60
        onTriggered: Quickshell.execDetached(["brightnessctl", "--class=backlight", "set", Math.max(1, root.brightPct) + "%"])
    }

    // ---- wifi (NetworkManager) ----
    Process {
        id: readWifi
        command: ["nmcli", "radio", "wifi"]
        stdout: StdioCollector {
            onStreamFinished: root.wifiOn = text.trim() === "enabled"
        }
    }

    Timer {
        id: wifiRecheck
        interval: 700
        onTriggered: root.refresh()
    }

    function toggleWifi() {
        Quickshell.execDetached(["nmcli", "radio", "wifi", wifiOn ? "off" : "on"]);
        wifiOn = !wifiOn;
        wifiRecheck.restart();
    }

    // right-click on Wi-Fi / Bluetooth opens the device menu
    function openMenu(target) {
        shown = false;
        Quickshell.execDetached(["qs", "ipc", "call", target, "open"]);
    }

    // ---- ui ----
    Rectangle {
        anchors.fill: parent
        color: Theme.surface
        radius: 0
        border.width: 1
        border.color: Theme.border

        Item {
            id: keys
            anchors.fill: parent
            focus: true
            Keys.onPressed: event => {
                if (event.key === Qt.Key_Escape) {
                    root.shown = false;
                    event.accepted = true;
                }
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
                height: hdr.implicitHeight

                Text {
                    id: hdr
                    text: "QUICK SETTINGS"
                    color: Theme.fgDim
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize - 2
                }
            }

            // sliders
            Column {
                width: parent.width
                spacing: 4

                QsSlider {
                    width: parent.width
                    visible: root.sinkReady
                    label: "VOL"
                    clickableLabel: true
                    value: root.sinkReady ? root.sink.audio.volume : 0
                    muted: root.sinkReady && root.sink.audio.muted
                    onMoved: v => { if (root.sinkReady) root.sink.audio.volume = v; }
                    onLabelClicked: if (root.sinkReady) root.sink.audio.muted = !root.sink.audio.muted
                }

                QsSlider {
                    width: parent.width
                    visible: root.sourceReady
                    label: "MIC"
                    clickableLabel: true
                    value: root.sourceReady ? root.source.audio.volume : 0
                    muted: root.sourceReady && root.source.audio.muted
                    onMoved: v => { if (root.sourceReady) root.source.audio.volume = v; }
                    onLabelClicked: if (root.sourceReady) root.source.audio.muted = !root.source.audio.muted
                }

                QsSlider {
                    width: parent.width
                    visible: root.brightPct >= 0
                    label: "BRIGHT"
                    value: Math.max(0, root.brightPct) / 100
                    onMoved: v => {
                        root.brightPct = Math.round(v * 100);
                        brightApply.restart();
                    }
                }
            }

            // toggles
            Row {
                id: tiles
                spacing: 6
                readonly property real tileW: (width - spacing * 2) / 3

                QsTile {
                    width: tiles.tileW
                    text: "WI-FI"
                    active: root.wifiOn
                    onClicked: root.toggleWifi()
                    onRightClicked: root.openMenu("network")
                }

                QsTile {
                    width: tiles.tileW
                    text: "BLUETOOTH"
                    available: root.bt !== null
                    active: root.bt !== null && root.bt.enabled
                    onClicked: if (root.bt) root.bt.enabled = !root.bt.enabled
                    onRightClicked: root.openMenu("bluetooth")
                }

                QsTile {
                    width: tiles.tileW
                    text: "DND"
                    active: Notifs.dnd
                    onClicked: Notifs.dnd = !Notifs.dnd
                }
            }

            // shell
            Row {
                spacing: 6

                QsTile {
                    width: tiles.tileW
                    text: "FRAME"
                    active: Settings.frameEnabled
                    onClicked: Settings.set("frameEnabled", !Settings.frameEnabled)
                }

                QsTile {
                    width: tiles.tileW
                    text: "BORDER"
                    active: Settings.frameBorder
                    onClicked: Settings.set("frameBorder", !Settings.frameBorder)
                }
            }

            // power profile
            Column {
                width: parent.width
                spacing: 6

                Text {
                    text: "POWER PROFILE"
                    color: Theme.fgDim
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize - 2
                }

                Row {
                    id: profiles
                    spacing: 6
                    readonly property int n: PowerProfiles.hasPerformanceProfile ? 3 : 2
                    readonly property real tileW: (width - spacing * (n - 1)) / n

                    QsTile {
                        width: profiles.tileW
                        text: "SAVER"
                        active: PowerProfiles.profile === PowerProfile.PowerSaver
                        onClicked: PowerProfiles.profile = PowerProfile.PowerSaver
                    }
                    QsTile {
                        width: profiles.tileW
                        text: "BALANCED"
                        active: PowerProfiles.profile === PowerProfile.Balanced
                        onClicked: PowerProfiles.profile = PowerProfile.Balanced
                    }
                    QsTile {
                        width: profiles.tileW
                        visible: PowerProfiles.hasPerformanceProfile
                        text: "PERFORMANCE"
                        active: PowerProfiles.profile === PowerProfile.Performance
                        onClicked: PowerProfiles.profile = PowerProfile.Performance
                    }
                }
            }

            // footer
            Text {
                text: "RIGHT-CLICK WI-FI/BT FOR DEVICES   ESC CLOSE"
                color: Theme.fgDim
                font.family: Theme.font
                font.pixelSize: Theme.fontSize - 2
            }
        }
    }
}
