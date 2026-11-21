import Quickshell
import Quickshell.Services.Mpris
import QtQuick
import "../singletons"

// Player popup opening to the right of the bar. Square corners, matugen colors.
PopupWindow {
    id: root

    readonly property var player: Media.player
    readonly property int pad: 12
    readonly property int innerW: 240

    anchor.edges: Edges.Right
    anchor.gravity: Edges.Right
    anchor.adjustment: PopupAdjustment.Slide

    implicitWidth: innerW + pad * 2 + 1
    implicitHeight: content.implicitHeight + pad * 2 + 1
    color: "transparent"

    // keep the position fresh while playing
    Timer {
        running: root.visible && Media.playing
        interval: 1000
        repeat: true
        onTriggered: root.player.positionChanged()
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.surface
        radius: 0
        border.width: 1
        border.color: Theme.border

        Column {
            id: content
            x: root.pad
            y: root.pad
            width: root.innerW
            spacing: 10

            // album art (square)
            Rectangle {
                width: root.innerW
                height: root.innerW
                radius: 0
                color: Theme.surfaceHi
                border.width: 1
                border.color: Theme.border

                Image {
                    anchors.fill: parent
                    anchors.margins: 1
                    source: Media.artUrl
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    visible: status === Image.Ready
                }

                Text {
                    anchors.centerIn: parent
                    visible: Media.artUrl === ""
                    text: "NO ART"
                    color: Theme.fgDim
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize
                }
            }

            // title / artist
            Column {
                width: root.innerW
                spacing: 2

                Text {
                    width: parent.width
                    elide: Text.ElideRight
                    text: Media.hasPlayer ? Media.title : "Nothing playing"
                    color: Theme.fg
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize + 2
                    font.bold: true
                }
                Text {
                    width: parent.width
                    elide: Text.ElideRight
                    text: Media.artist
                    color: Theme.fgDim
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize
                    visible: text !== ""
                }
            }

            // progress (click to seek)
            Column {
                width: root.innerW
                spacing: 4
                visible: !!root.player && root.player.lengthSupported

                Rectangle {
                    width: parent.width
                    height: 6
                    radius: 0
                    color: Theme.surfaceHiest
                    border.width: 1
                    border.color: Theme.border

                    Rectangle {
                        x: 1
                        y: 1
                        height: parent.height - 2
                        radius: 0
                        color: Theme.primary
                        width: root.player && root.player.length > 0
                            ? (parent.width - 2) * Math.min(1, root.player.position / root.player.length)
                            : 0
                    }

                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -4
                        enabled: root.player && root.player.canSeek
                        onClicked: mouse => {
                            const f = Math.max(0, Math.min(1, (mouse.x - 4) / (width - 8)));
                            root.player.position = f * root.player.length;
                        }
                    }
                }

                Item {
                    width: parent.width
                    height: posText.implicitHeight

                    Text {
                        id: posText
                        text: Media.fmt(root.player ? root.player.position : 0)
                        color: Theme.fgDim
                        font.family: Theme.font
                        font.pixelSize: Theme.fontSize - 1
                    }
                    Text {
                        anchors.right: parent.right
                        text: Media.fmt(root.player ? root.player.length : 0)
                        color: Theme.fgDim
                        font.family: Theme.font
                        font.pixelSize: Theme.fontSize - 1
                    }
                }
            }

            // controls
            Row {
                spacing: 6

                Repeater {
                    model: [
                        { label: "PREV", action: "prev" },
                        { label: "PLAY", action: "toggle" },
                        { label: "NEXT", action: "next" }
                    ]

                    delegate: Rectangle {
                        id: btn
                        required property var modelData

                        readonly property bool isToggle: modelData.action === "toggle"
                        readonly property bool enabledBtn: !!root.player && (
                            modelData.action === "prev" ? root.player.canGoPrevious
                            : modelData.action === "next" ? root.player.canGoNext
                            : root.player.canTogglePlaying)

                        width: (root.innerW - 12) / 3
                        height: 28
                        radius: 0
                        color: isToggle ? Theme.primary : (hover.containsMouse ? Theme.surfaceHiest : "transparent")
                        border.width: 1
                        border.color: isToggle ? Theme.primary : Theme.border
                        opacity: enabledBtn ? 1 : 0.4

                        Text {
                            anchors.centerIn: parent
                            text: btn.isToggle ? (Media.playing ? "PAUSE" : "PLAY") : btn.modelData.label
                            color: btn.isToggle ? Theme.primaryFg : Theme.fg
                            font.family: Theme.font
                            font.pixelSize: Theme.fontSize
                            font.bold: btn.isToggle
                        }

                        MouseArea {
                            id: hover
                            anchors.fill: parent
                            hoverEnabled: true
                            enabled: btn.enabledBtn
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (btn.modelData.action === "prev") root.player.previous();
                                else if (btn.modelData.action === "next") root.player.next();
                                else root.player.togglePlaying();
                            }
                        }
                    }
                }
            }
        }
    }
}
