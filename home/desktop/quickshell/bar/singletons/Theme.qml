pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

// Matugen colors, hot-reloaded from ~/.config/quickshell/colors.json
Singleton {
    id: root

    // layout
    readonly property int barWidth: 32
    readonly property int boxSize: 12
    readonly property string font: "monospace"
    readonly property int fontSize: 12

    // scale a color's saturation by Settings.saturation (1 = unchanged)
    function adj(c) {
        const col = Qt.lighter(c, 1.0);
        if (Settings.saturation === 1 || col.hslSaturation === 0) return col;
        return Qt.hsla(col.hslHue, Math.min(1, col.hslSaturation * Settings.saturation), col.hslLightness, col.a);
    }

    // colors
    readonly property color surface: adj(adapter.surface)
    readonly property color surfaceHi: adj(adapter.surfaceHi)
    readonly property color surfaceHiest: adj(adapter.surfaceHiest)
    readonly property color fg: adj(adapter.fg)
    readonly property color fgDim: adj(adapter.fgDim)
    readonly property color primary: adj(adapter.primary)
    readonly property color primaryFg: adj(adapter.primaryFg)
    readonly property color secondaryContainer: adj(adapter.secondaryContainer)
    readonly property color error: adj(adapter.error)
    readonly property color outline: adj(adapter.outline)
    readonly property color border: primary   // color of every border and divider line

    FileView {
        path: Quickshell.env("HOME") + "/.config/quickshell/colors.json"
        watchChanges: true
        onFileChanged: reload()

        JsonAdapter {
            id: adapter
            property string surface: "#111111"
            property string surfaceHi: "#1a1a1a"
            property string surfaceHiest: "#242424"
            property string fg: "#e0e0e0"
            property string fgDim: "#8a8a8a"
            property string primary: "#a6c8ff"
            property string primaryFg: "#00315c"
            property string secondaryContainer: "#3a4a5f"
            property string error: "#ffb4ab"
            property string outline: "#44474e"
        }
    }
}
