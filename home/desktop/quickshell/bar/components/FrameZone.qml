import Quickshell
import Quickshell.Wayland
import QtQuick

// Invisible window that only reserves screen space, so windows tile inside the frame.
PanelWindow {
    id: win

    required property string side      // "top" | "right" | "bottom"
    property int thickness: 6

    anchors {
        top: win.side !== "bottom"
        bottom: win.side !== "top"
        left: win.side !== "right"
        right: win.side !== "left"
    }

    implicitWidth: win.side === "right" ? win.thickness : 0
    implicitHeight: win.side === "right" ? 0 : win.thickness
    exclusiveZone: win.thickness
    WlrLayershell.namespace: "frame-zone"
    color: "transparent"
    mask: Region {}   // click-through
}
