pragma Singleton

import Quickshell
import Quickshell.Services.Mpris
import QtQuick

Singleton {
    id: root

    readonly property var player: {
        const list = Mpris.players.values;
        let paused = null;
        for (let i = 0; i < list.length; i++) {
            const p = list[i];
            if (p.isPlaying) return p;
            if (!paused && p.playbackState === MprisPlaybackState.Paused) paused = p;
        }
        return paused;
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
