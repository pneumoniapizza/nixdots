pragma Singleton

import Quickshell
import QtQuick

// Countdown timer state, shared by the bar indicator, the menu and the alert.
// Control it with: qs ipc call timer start 10m | cancel | toggle
Singleton {
    id: root

    property bool running: false
    property bool paused: false
    property bool finished: false
    property int total: 0          // seconds, last started duration
    property real remaining: 0     // seconds left
    property real endsAt: 0        // ms since epoch, while running

    readonly property bool active: running || paused

    function start(secs) {
        if (secs <= 0) return;
        total = Math.round(secs);
        remaining = total;
        endsAt = Date.now() + total * 1000;
        finished = false;
        paused = false;
        running = true;
    }

    function pause() {
        if (!running) return;
        remaining = Math.max(0, (endsAt - Date.now()) / 1000);
        running = false;
        paused = true;
    }

    function resume() {
        if (!paused) return;
        endsAt = Date.now() + remaining * 1000;
        paused = false;
        running = true;
    }

    function togglePause() {
        if (running) pause();
        else if (paused) resume();
    }

    function add(secs) {
        if (!active) return;
        total += secs;
        if (running) endsAt += secs * 1000;
        else remaining += secs;
    }

    function cancel() {
        running = false;
        paused = false;
        finished = false;
        remaining = 0;
    }

    function dismiss() { finished = false; }
    function repeat() { start(total); }

    function finish() {
        running = false;
        paused = false;
        remaining = 0;
        finished = true;
        // best effort: freedesktop sound theme through pipewire or pulse
        Quickshell.execDetached(["sh", "-c",
            "for d in $(echo \"${XDG_DATA_DIRS:-/usr/share}\" | tr : ' '); do "
            + "f=\"$d/sounds/freedesktop/stereo/alarm-clock-elapsed.oga\"; "
            + "[ -f \"$f\" ] && { pw-play \"$f\" 2>/dev/null || paplay \"$f\" 2>/dev/null; exit; }; done"]);
    }

    Timer {
        interval: 250
        repeat: true
        running: root.running
        onTriggered: {
            const r = (root.endsAt - Date.now()) / 1000;
            if (r <= 0) root.finish();
            else root.remaining = r;
        }
    }

    // "10m", "1h30m", "90s", "5:00", "1:30:00"; a bare number is minutes. -1 if invalid.
    function parse(str) {
        const s = str.trim().toLowerCase();
        if (s === "") return -1;
        if (/^\d+(\.\d+)?$/.test(s)) return Math.round(parseFloat(s) * 60);
        let m = s.match(/^(\d+):(\d{1,2})(?::(\d{1,2}))?$/);
        if (m) {
            return m[3] !== undefined
                ? (+m[1]) * 3600 + (+m[2]) * 60 + (+m[3])
                : (+m[1]) * 60 + (+m[2]);
        }
        m = s.match(/^(?:(\d+(?:\.\d+)?)\s*h)?\s*(?:(\d+(?:\.\d+)?)\s*m(?:in)?)?\s*(?:(\d+(?:\.\d+)?)\s*s(?:ec)?)?$/);
        if (m && (m[1] || m[2] || m[3]))
            return Math.round((+m[1] || 0) * 3600 + (+m[2] || 0) * 60 + (+m[3] || 0));
        return -1;
    }

    // 9:41 or 1:02:03
    function fmt(secs) {
        const t = Math.max(0, Math.ceil(secs));
        const h = Math.floor(t / 3600);
        const m = Math.floor((t % 3600) / 60);
        const s = t % 60;
        const p = n => (n < 10 ? "0" : "") + n;
        return h > 0 ? h + ":" + p(m) + ":" + p(s) : p(m) + ":" + p(s);
    }

    // 1H 30M 10S
    function describe(secs) {
        const h = Math.floor(secs / 3600);
        const m = Math.floor((secs % 3600) / 60);
        const s = secs % 60;
        return [h ? h + "H" : "", m ? m + "M" : "", s ? s + "S" : ""].filter(x => x).join(" ");
    }
}
