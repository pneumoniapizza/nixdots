//@ pragma UseQApplication
import Quickshell
import "components"

ShellRoot {
    Variants {
        model: Quickshell.screens

        Bar {
            required property var modelData
            screen: modelData
        }
    }

    // screen frame (top, right, bottom); toggle in quick settings or: qs ipc call frame toggle
    Frame {}

    NotificationToasts {}

    // IPC only: qs ipc call notifications toggle
    NotificationCenter {}

    // IPC only: qs ipc call quicksettings toggle
    QuickSettings {}

    // IPC only: qs ipc call network toggle / qs ipc call bluetooth toggle
    NetworkMenu {}
    BluetoothMenu {}

    // IPC only: qs ipc call launcher toggle
    Launcher {}

    // IPC only: qs ipc call wallpaper toggle
    WallpaperSwitcher {}

    // IPC only: qs ipc call clipboard toggle
    Clipboard {}

    // IPC only: qs ipc call emoji toggle
    EmojiPicker {}

    // IPC only: qs ipc call power toggle
    PowerMenu {}

    // IPC only: qs ipc call timer toggle
    TimerMenu {}
    TimerAlert {}

    // IPC only: qs ipc call lock lock
    LockScreen {}

    // Volume shows on change; brightness via: qs ipc call osd brightness
    OSD {}
}
