pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

// Niri workspaces via `niri msg -j`; re-queried on every event-stream line
Singleton {
    id: root

    property var workspaces: []

    function focusWorkspace(idx) {
        Quickshell.execDetached(["niri", "msg", "action", "focus-workspace", String(idx)]);
    }

    function refresh() {
        if (!wsProc.running) wsProc.running = true;
    }

    Component.onCompleted: refresh()

    Process {
        id: wsProc
        command: ["niri", "msg", "-j", "workspaces"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const list = JSON.parse(text);
                    list.sort((a, b) => a.idx - b.idx);
                    root.workspaces = list;
                } catch (e) {}
            }
        }
    }

    Process {
        running: true
        command: ["niri", "msg", "-j", "event-stream"]
        stdout: SplitParser {
            onRead: root.refresh()
        }
    }
}
