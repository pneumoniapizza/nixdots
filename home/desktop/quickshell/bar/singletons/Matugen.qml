pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

// Runs matugen with the theme settings (mode, scheme, contrast, source color).
// Every matugen invocation of the shell goes through here.
Singleton {
    id: root

    property bool busy: false
    property string pending: ""     // a run that was requested while one was still going

    function command(path) {
        return [
            "matugen", "image", path,
            "-m", Settings.mode,
            "-t", Settings.scheme,
            "--contrast", String(Settings.contrast),
            "--source-color-index", String(Settings.colorIndex)
        ];
    }

    function run(path) {
        if (!path) return;
        if (proc.running) {
            pending = path;
            return;
        }
        busy = true;
        proc.command = command(path);
        proc.running = true;
    }

    // re-run on the current wallpaper
    function apply() { run(Settings.current); }

    // for sliders: wait until the value stops changing
    function applySoon() { debounce.restart(); }

    Timer {
        id: debounce
        interval: 700
        onTriggered: root.apply()
    }

    Process {
        id: proc
        onExited: {
            root.busy = false;
            if (root.pending !== "") {
                const p = root.pending;
                root.pending = "";
                root.run(p);
            }
        }
    }
}
