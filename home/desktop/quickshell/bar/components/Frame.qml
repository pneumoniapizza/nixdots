import Quickshell
import Quickshell.Io
import QtQuick
import "../singletons"

// Frame around the screen (top, right and bottom; the bar is the left side).
// Toggle it in quick settings, in settings.json ("frameEnabled", "frameWidth",
// "frameRounding", "frameBorder"), or over IPC:
//   qs ipc call frame toggle | enable | disable | border
Scope {
    id: root

    IpcHandler {
        target: "frame"

        function toggle(): void { Settings.set("frameEnabled", !Settings.frameEnabled); }
        function enable(): void { Settings.set("frameEnabled", true); }
        function disable(): void { Settings.set("frameEnabled", false); }
        function border(): void { Settings.set("frameBorder", !Settings.frameBorder); }
    }

    // when off, no windows exist at all, so windows grow back to the screen edge
    Variants {
        model: Settings.frameEnabled && Settings.frameWidth > 0 ? Quickshell.screens : []

        Scope {
            id: perScreen
            required property var modelData

            FrameOverlay {
                screen: perScreen.modelData
                thickness: Settings.frameWidth
                rounding: Settings.frameRounding
            }
            FrameZone { screen: perScreen.modelData; side: "top"; thickness: Settings.frameWidth }
            FrameZone { screen: perScreen.modelData; side: "right"; thickness: Settings.frameWidth }
            FrameZone { screen: perScreen.modelData; side: "bottom"; thickness: Settings.frameWidth }
        }
    }
}
