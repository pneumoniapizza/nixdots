import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Effects
import "../singletons"

// The visible frame: a solid sheet with a rounded hole cut out of it.
// It starts right after the bar, so the bar stays untouched and the hole's
// left corners blend into the bar. Purely visual, it never takes input.
PanelWindow {
    id: win

    property int thickness: 6
    property int rounding: 14

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    margins.left: Theme.barWidth

    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "frame"
    color: "transparent"
    mask: Region {}   // click-through

    // the sheet, with the hole cut out by an inverted mask
    Rectangle {
        anchors.fill: parent
        color: Theme.surface
        layer.enabled: true
        layer.effect: MultiEffect {
            maskSource: hole
            maskEnabled: true
            maskInverted: true
            maskThresholdMin: 0.5
            maskSpreadAtMin: 1
        }
    }

    // mask: the area that stays see-through
    Item {
        id: hole
        anchors.fill: parent
        layer.enabled: true
        visible: false

        Rectangle {
            x: 0
            y: win.thickness
            width: parent.width - win.thickness
            height: parent.height - win.thickness * 2
            radius: win.rounding
        }
    }

    // 1px outline along the edge of the hole (left side hidden behind the bar's own border)
    Rectangle {
        visible: Settings.frameBorder
        x: -1
        y: win.thickness
        width: parent.width - win.thickness + 1
        height: parent.height - win.thickness * 2
        radius: win.rounding
        color: "transparent"
        border.width: 1
        border.color: Theme.border
    }
}
