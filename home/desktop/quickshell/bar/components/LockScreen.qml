import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Pam
import QtQuick
import "../singletons"

// Lock screen (ext-session-lock + PAM). IPC only:
//   qs ipc call lock lock
// Needs a PAM service named "quickshell" (security.pam.services.quickshell).
Scope {
    id: root

    property bool busy: false
    property bool failed: false
    property string pending: ""

    IpcHandler {
        target: "lock"

        function lock(): void { sessionLock.locked = true; }
    }

    PamContext {
        id: pam
        config: "quickshell"

        onResponseRequiredChanged: {
            if (responseRequired && root.busy) respond(root.pending);
        }

        onCompleted: result => {
            root.pending = "";
            root.busy = false;
            if (result === PamResult.Success) {
                root.failed = false;
                sessionLock.locked = false;
            } else {
                root.failed = true;
            }
        }

        onError: {
            root.pending = "";
            root.busy = false;
            root.failed = true;
        }
    }

    function submit(pw) {
        if (busy || pw === "") return;
        failed = false;
        busy = true;
        pending = pw;
        pam.start();
    }

    WlSessionLock {
        id: sessionLock

        onLockedChanged: {
            if (locked) {
                root.failed = false;
                root.busy = false;
            }
        }

        WlSessionLockSurface {
            id: surface
            color: Theme.surface

            SystemClock {
                id: clock
                precision: SystemClock.Minutes
            }

            Column {
                anchors.centerIn: parent
                spacing: 24

                Column {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 6

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: Qt.formatDateTime(clock.date, "HH:mm")
                        color: Theme.fg
                        font.family: Theme.font
                        font.pixelSize: 72
                        font.bold: true
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: Qt.formatDateTime(clock.date, "dddd dd MMMM").toUpperCase()
                        color: Theme.fgDim
                        font.family: Theme.font
                        font.pixelSize: Theme.fontSize
                    }
                }

                // password input
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 320
                    height: 32
                    radius: 0
                    color: Theme.surfaceHi
                    border.width: 1
                    border.color: root.failed ? Theme.error : (input.activeFocus ? Theme.primary : Theme.border)

                    Text {
                        id: prompt
                        x: 10
                        anchors.verticalCenter: parent.verticalCenter
                        text: ">"
                        color: root.failed ? Theme.error : Theme.primary
                        font.family: Theme.font
                        font.pixelSize: Theme.fontSize
                        font.bold: true
                    }

                    TextInput {
                        id: input
                        anchors {
                            left: prompt.right
                            leftMargin: 8
                            right: parent.right
                            rightMargin: 10
                            verticalCenter: parent.verticalCenter
                        }
                        color: Theme.fg
                        selectionColor: Theme.primary
                        selectedTextColor: Theme.primaryFg
                        font.family: Theme.font
                        font.pixelSize: Theme.fontSize + 1
                        echoMode: TextInput.Password
                        passwordCharacter: "*"
                        enabled: !root.busy
                        clip: true

                        Component.onCompleted: forceActiveFocus()
                        onEnabledChanged: if (enabled) forceActiveFocus()

                        Keys.onPressed: event => {
                            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                root.submit(text);
                                text = "";
                            } else if (event.key === Qt.Key_Escape) {
                                text = "";
                            } else {
                                if (root.failed) root.failed = false;
                                return;
                            }
                            event.accepted = true;
                        }
                    }
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: root.busy ? "AUTHENTICATING" : (root.failed ? "AUTHENTICATION FAILED" : "LOCKED")
                    color: root.failed ? Theme.error : Theme.fgDim
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize - 2
                }
            }
        }
    }
}
