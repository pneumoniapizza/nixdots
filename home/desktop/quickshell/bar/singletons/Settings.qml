pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

// Shell settings, persisted to ~/.config/quickshell/settings.json
// Edit the file by hand (hot-reloaded) or change them from the UI (written back).
Singleton {
    id: root

    signal loaded()

    // wallpaper
    readonly property string wallpaperDir: adapter.wallpaperDir
    readonly property var wallpaperCmd: adapter.wallpaperCmd   // wallpaper path is appended
    readonly property string current: adapter.current
    readonly property bool restoreOnStart: adapter.restoreOnStart
    readonly property bool closeOnApply: adapter.closeOnApply

    // screen frame
    readonly property bool frameEnabled: adapter.frameEnabled
    readonly property int frameWidth: adapter.frameWidth       // px
    readonly property int frameRounding: adapter.frameRounding // px, 0 = square corners
    readonly property bool frameBorder: adapter.frameBorder    // 1px outline on the frame and the bar

    // matugen
    readonly property string mode: adapter.mode               // dark | light
    readonly property string scheme: adapter.scheme           // scheme-tonal-spot, ...
    readonly property real contrast: adapter.contrast         // -1..1, passed to matugen --contrast
    readonly property real saturation: adapter.saturation     // 0..2, 1 = unchanged, applied to the shell colors
    readonly property int colorIndex: adapter.colorIndex      // 0..4, which source color matugen picks

    readonly property var schemes: [
        "scheme-tonal-spot", "scheme-content", "scheme-expressive", "scheme-fidelity",
        "scheme-fruit-salad", "scheme-monochrome", "scheme-neutral", "scheme-rainbow"
    ]

    function set(key, value) {
        adapter[key] = value;
    }

    function resolvedDir() {
        return adapter.wallpaperDir.replace(/^~/, Quickshell.env("HOME"));
    }

    FileView {
        path: Quickshell.env("HOME") + "/.config/quickshell/settings.json"
        watchChanges: true
        onFileChanged: reload()
        onAdapterUpdated: writeAdapter()
        onLoaded: root.loaded()
        onLoadFailed: error => {
            if (error === FileViewError.FileNotFound) writeAdapter();
        }

        JsonAdapter {
            id: adapter
            property string wallpaperDir: "~/Pictures/Wallpapers"
            property var wallpaperCmd: ["awww", "img", "--transition-type", "fade"]
            property string current: ""
            property bool restoreOnStart: true
            property bool closeOnApply: true
            property bool frameEnabled: true
            property int frameWidth: 6
            property int frameRounding: 0
            property bool frameBorder: true
            property string mode: "dark"
            property string scheme: "scheme-tonal-spot"
            property real contrast: 0.5
            property real saturation: 1.0
            property int colorIndex: 0
        }
    }
}
