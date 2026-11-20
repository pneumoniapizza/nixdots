import Quickshell
import Quickshell.Services.Notifications
import QtQuick
import "../singletons"

// Toast stack at the top-left, right next to the bar
PanelWindow {
    id: root

    readonly property int toastWidth: 320

    visible: Notifs.count > 0 && !Notifs.centerOpen
    anchors {
        top: true
        left: true
    }
    margins {
        top: 8
        left: Theme.barWidth + 8
    }
    exclusionMode: ExclusionMode.Ignore
    implicitWidth: toastWidth
    implicitHeight: Math.max(1, stack.implicitHeight)
    color: "transparent"

    Column {
        id: stack
        width: root.toastWidth
        spacing: 6

        Repeater {
            model: Notifs.list

            delegate: Rectangle {
                id: toast
                required property var modelData

                readonly property bool critical: modelData.urgency === NotificationUrgency.Critical
                readonly property bool hasImage: modelData.image !== ""

                width: stack.width
                height: body.implicitHeight + 20
                radius: 0
                color: Theme.surface
                border.width: 1
                border.color: critical ? Theme.error : Theme.outline

                // auto-expire (critical stays until dismissed)
                Timer {
                    running: !toast.critical
                    interval: toast.modelData.expireTimeout > 0 ? toast.modelData.expireTimeout * 1000 : 6000
                    onTriggered: toast.modelData.expire()
                }

                // urgency accent strip
                Rectangle {
                    anchors {
                        top: parent.top
                        bottom: parent.bottom
                        left: parent.left
                    }
                    width: 3
                    color: toast.critical ? Theme.error : Theme.primary
                }

                // click anywhere on the card to dismiss
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: toast.modelData.dismiss()
                }

                Row {
                    id: body
                    x: 14
                    y: 10
                    width: parent.width - 24
                    spacing: 10

                    Image {
                        visible: toast.hasImage
                        width: visible ? 48 : 0
                        height: 48
                        source: toast.modelData.image
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                    }

                    Column {
                        width: parent.width - (toast.hasImage ? 58 : 0)
                        spacing: 3

                        Text {
                            width: parent.width
                            elide: Text.ElideRight
                            text: toast.modelData.appName.toUpperCase()
                            color: Theme.fgDim
                            font.family: Theme.font
                            font.pixelSize: Theme.fontSize - 2
                        }

                        Text {
                            width: parent.width
                            elide: Text.ElideRight
                            text: toast.modelData.summary
                            color: toast.critical ? Theme.error : Theme.fg
                            font.family: Theme.font
                            font.pixelSize: Theme.fontSize
                            font.bold: true
                        }

                        Text {
                            width: parent.width
                            visible: text !== ""
                            text: toast.modelData.body
                            textFormat: Text.PlainText
                            wrapMode: Text.Wrap
                            maximumLineCount: 3
                            elide: Text.ElideRight
                            color: Theme.fgDim
                            font.family: Theme.font
                            font.pixelSize: Theme.fontSize
                        }

                        // actions
                        Row {
                            visible: toast.modelData.actions.length > 0
                            spacing: 6
                            topPadding: 4

                            Repeater {
                                model: toast.modelData.actions

                                delegate: Rectangle {
                                    id: act
                                    required property var modelData

                                    width: actText.implicitWidth + 16
                                    height: 22
                                    radius: 0
                                    color: actArea.containsMouse ? Theme.surfaceHiest : "transparent"
                                    border.width: 1
                                    border.color: Theme.outline

                                    Text {
                                        id: actText
                                        anchors.centerIn: parent
                                        text: act.modelData.text
                                        color: Theme.fg
                                        font.family: Theme.font
                                        font.pixelSize: Theme.fontSize - 1
                                    }

                                    MouseArea {
                                        id: actArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: act.modelData.invoke()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
