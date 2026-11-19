import Quickshell.Services.Pipewire
import QtQuick
import "../singletons"

Item {
    id: root

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property bool ready: sink !== null && sink.audio !== null
    readonly property int volume: ready ? Math.round(sink.audio.volume * 100) : 0
    readonly property bool muted: ready ? sink.audio.muted : false

    implicitWidth: Theme.barWidth
    implicitHeight: text.implicitHeight

    PwObjectTracker {
        objects: [root.sink]
    }

    VText {
        id: text
        anchors.centerIn: parent
        text: root.muted ? "VOL MUTE" : "VOL " + root.volume + "%"
        color: root.muted ? Theme.error : Theme.fg
    }

    MouseArea {
        anchors.fill: parent
        onClicked: if (root.ready) root.sink.audio.muted = !root.sink.audio.muted
        onWheel: wheel => {
            if (!root.ready) return;
            const v = root.sink.audio.volume + (wheel.angleDelta.y > 0 ? 0.05 : -0.05);
            root.sink.audio.volume = Math.max(0, Math.min(1, v));
        }
    }
}
