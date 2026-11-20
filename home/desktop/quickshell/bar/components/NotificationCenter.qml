import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import "../singletons"

// Notification history, opened at the top-left next to the bar.
//   qs ipc call notifications toggle | open | close | clear | dnd
// Click a card to remove it. Keys: C clear all, D toggle Do Not Disturb, Esc close
PanelWindow {
    id: root

    property bool shown: false
    property real now: Date.now()
    readonly property int pad: 12
    readonly property int maxListHeight: 460

    visible: shown
    anchors {
        top: true
        left: true
    }
    margins {
        top: 8
        left: Theme.barWidth + 8
    }
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: shown ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    WlrLayershell.namespace: "notifications"

    implicitWidth: 360
    implicitHeight: content.implicitHeight + pad * 2 + 2
    color: "transparent"

    IpcHandler {
        target: "notifications"

        function toggle(): void { root.shown = !root.shown; }
        function open(): void { root.shown = true; }
        function close(): void { root.shown = false; }
        function clear(): void { Notifs.clearHistory(); }
        function dnd(): void { Notifs.dnd = !Notifs.dnd; }
    }

    onShownChanged: {
        Notifs.centerOpen = shown;
        if (shown) {
            Notifs.unread = 0;
            now = Date.now();
            keys.forceActiveFocus();
        }
    }

    // keep the relative times fresh while open
    Timer {
        interval: 30000
        repeat: true
        running: root.shown
        onTriggered: root.now = Date.now()
    }

    function ago(t) {
        const s = Math.max(0, (now - t) / 1000);
        if (s < 60) return "NOW";
        if (s < 3600) return Math.floor(s / 60) + "M AGO";
        if (s < 86400) return Math.floor(s / 3600) + "H AGO";
        return Math.floor(s / 86400) + "D AGO";
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.surface
        radius: 0
        border.width: 1
        border.color: Theme.outline

        Item {
            id: keys
            anchors.fill: parent
            focus: true

            Keys.onPressed: event => {
                if (event.key === Qt.Key_Escape) root.shown = false;
                else if (event.key === Qt.Key_C) Notifs.clearHistory();
                else if (event.key === Qt.Key_D) Notifs.dnd = !Notifs.dnd;
                else return;
                event.accepted = true;
            }
        }

        Column {
            id: content
            x: root.pad + 1
            y: root.pad + 1
            width: parent.width - root.pad * 2 - 2
            spacing: 10

            // header
            Item {
                width: parent.width
                height: hdr.implicitHeight

                Text {
                    id: hdr
                    text: "NOTIFICATIONS"
                    color: Theme.fgDim
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize - 2
                }
                Text {
                    anchors.right: parent.right
                    text: Notifs.history.count + " STORED"
                    color: Theme.fgDim
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize - 2
                }
            }

            // buttons
            Row {
                spacing: 6

                Rectangle {
                    width: dndText.implicitWidth + 20
                    height: 26
                    radius: 0
                    color: Notifs.dnd ? Theme.primary : (dndArea.containsMouse ? Theme.surfaceHiest : "transparent")
                    border.width: 1
                    border.color: Notifs.dnd ? Theme.primary : Theme.outline

                    Text {
                        id: dndText
                        anchors.centerIn: parent
                        text: Notifs.dnd ? "DND ON" : "DND OFF"
                        color: Notifs.dnd ? Theme.primaryFg : Theme.fg
                        font.family: Theme.font
                        font.pixelSize: Theme.fontSize - 1
                        font.bold: Notifs.dnd
                    }

                    MouseArea {
                        id: dndArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Notifs.dnd = !Notifs.dnd
                    }
                }

                Rectangle {
                    width: clearText.implicitWidth + 20
                    height: 26
                    radius: 0
                    color: clearArea.containsMouse ? Theme.surfaceHiest : "transparent"
                    border.width: 1
                    border.color: Theme.outline

                    Text {
                        id: clearText
                        anchors.centerIn: parent
                        text: "CLEAR ALL"
                        color: Theme.fg
                        font.family: Theme.font
                        font.pixelSize: Theme.fontSize - 1
                    }

                    MouseArea {
                        id: clearArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Notifs.clearHistory()
                    }
                }
            }

            // history
            ListView {
                id: list
                width: parent.width
                height: Math.max(48, Math.min(contentHeight, root.maxListHeight))
                clip: true
                spacing: 6
                model: Notifs.history
                boundsBehavior: Flickable.StopAtBounds

                delegate: Rectangle {
                    id: card

                    required property int index
                    required property string appName
                    required property string summary
                    required property string body
                    required property string image
                    required property bool critical
                    required property real time

                    readonly property bool hasImage: image !== ""

                    width: list.width
                    height: cardBody.implicitHeight + 20
                    radius: 0
                    color: cardArea.containsMouse ? Theme.surfaceHi : "transparent"
                    border.width: 1
                    border.color: critical ? Theme.error : Theme.outline

                    // urgency accent strip
                    Rectangle {
                        anchors {
                            top: parent.top
                            bottom: parent.bottom
                            left: parent.left
                        }
                        width: 3
                        color: card.critical ? Theme.error : Theme.primary
                    }

                    MouseArea {
                        id: cardArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Notifs.removeAt(card.index)
                    }

                    Row {
                        id: cardBody
                        x: 14
                        y: 10
                        width: parent.width - 24
                        spacing: 10

                        Image {
                            visible: card.hasImage
                            width: visible ? 40 : 0
                            height: 40
                            source: card.image
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                        }

                        Column {
                            width: parent.width - (card.hasImage ? 50 : 0)
                            spacing: 3

                            Item {
                                width: parent.width
                                height: appText.implicitHeight

                                Text {
                                    id: appText
                                    width: parent.width - timeText.implicitWidth - 8
                                    elide: Text.ElideRight
                                    text: card.appName.toUpperCase()
                                    color: Theme.fgDim
                                    font.family: Theme.font
                                    font.pixelSize: Theme.fontSize - 2
                                }
                                Text {
                                    id: timeText
                                    anchors.right: parent.right
                                    text: root.ago(card.time)
                                    color: Theme.fgDim
                                    font.family: Theme.font
                                    font.pixelSize: Theme.fontSize - 2
                                }
                            }

                            Text {
                                width: parent.width
                                elide: Text.ElideRight
                                text: card.summary
                                color: card.critical ? Theme.error : Theme.fg
                                font.family: Theme.font
                                font.pixelSize: Theme.fontSize
                                font.bold: true
                            }

                            Text {
                                width: parent.width
                                visible: text !== ""
                                text: card.body
                                textFormat: Text.PlainText
                                wrapMode: Text.Wrap
                                maximumLineCount: 3
                                elide: Text.ElideRight
                                color: Theme.fgDim
                                font.family: Theme.font
                                font.pixelSize: Theme.fontSize
                            }
                        }
                    }
                }

                Text {
                    anchors.centerIn: parent
                    visible: list.count === 0
                    text: "NO NOTIFICATIONS"
                    color: Theme.fgDim
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize
                }
            }

            // footer
            Text {
                text: "CLICK REMOVE   C CLEAR   D DND   ESC CLOSE"
                color: Theme.fgDim
                font.family: Theme.font
                font.pixelSize: Theme.fontSize - 2
            }
        }
    }
}
