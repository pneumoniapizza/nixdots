pragma Singleton

import Quickshell
import Quickshell.Services.Mpris
import QtQuick

// Picks the active MPRIS player: first one that is playing, else the first one
Singleton {
    id: root

    readonly property var player: {
        const list = Mpris.players.values;
        for (let i = 0; i < list.length; i++) {
            if (list[i].isPlaying) return list[i];
        }
        return list.length > 0 ? list[0] : null;
    }

    readonly property bool hasPlayer: !!player
    readonly property bool playing: hasPlayer && player.isPlaying
    readonly property string title: hasPlayer ? (player.trackTitle || "Unknown") : ""
    readonly property string artist: hasPlayer ? (player.trackArtist || "") : ""
    readonly property string artUrl: hasPlayer ? (player.trackArtUrl || "") : ""

    function fmt(secs) {
        if (!isFinite(secs) || secs < 0) return "0:00";
        const s = Math.floor(secs);
        const m = Math.floor(s / 60);
        const r = s % 60;
        return m + ":" + (r < 10 ? "0" : "") + r;
    }
}
