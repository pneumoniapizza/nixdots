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

    NotificationToasts {}

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

    // IPC only: qs ipc call lock lock
    LockScreen {}

    // Volume shows on change; brightness via: qs ipc call osd brightness
    OSD {}
}
