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

    // colors
    readonly property color surface: adapter.surface
    readonly property color surfaceHi: adapter.surfaceHi
    readonly property color surfaceHiest: adapter.surfaceHiest
    readonly property color fg: adapter.fg
    readonly property color fgDim: adapter.fgDim
    readonly property color primary: adapter.primary
    readonly property color primaryFg: adapter.primaryFg
    readonly property color secondaryContainer: adapter.secondaryContainer
    readonly property color error: adapter.error
    readonly property color outline: adapter.outline

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
