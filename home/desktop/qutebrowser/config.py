import json
import os
import sys
import threading
import time
import urllib.error
import urllib.parse
import urllib.request
from concurrent.futures import ThreadPoolExecutor

config.load_autoconfig(False)

from qutebrowser.api import cmdutils, interceptor, message
from qutebrowser.completion.models import completionmodel, listcategory
from qutebrowser.qt.core import QUrl

# ───────────────────────── privacy ─────────────────────────
c.content.private_browsing = True            # no history, nothing persisted
c.auto_save.session = False
c.content.cookies.accept = "no-3rdparty"
c.content.headers.referer = "same-domain"
c.content.headers.do_not_track = True
c.content.headers.accept_language = "en-US,en;q=0.9"
c.content.webrtc_ip_handling_policy = "default-public-interface-only"
c.content.canvas_reading = False
c.content.geolocation = False
c.content.notifications.enabled = False
c.content.media.audio_capture = False
c.content.media.video_capture = False
c.content.media.audio_video_capture = False
c.content.autoplay = False
c.content.dns_prefetch = False
c.content.register_protocol_handler = False
c.content.javascript.clipboard = "none"
c.content.tls.certificate_errors = "block"

c.content.blocking.enabled = True
c.content.blocking.method = "both"           # hosts fallback if python-adblock is missing
c.content.blocking.adblock.lists = [
    "https://easylist.to/easylist/easylist.txt",
    "https://easylist.to/easylist/easyprivacy.txt",
    "https://secure.fanboy.co.nz/fanboy-annoyance.txt",
    "https://github.com/uBlockOrigin/uAssets/raw/master/filters/filters.txt",
    "https://github.com/uBlockOrigin/uAssets/raw/master/filters/privacy.txt",
]

c.url.searchengines = {
    "DEFAULT": "https://duckduckgo.com/?q={}",
    "sx": "https://searx.be/search?q={}",
    "nix": "https://search.nixos.org/packages?query={}",
    "hm": "https://home-manager-options.extranix.com/?query={}",
}
c.url.start_pages = ["about:blank"]
c.url.default_page = "about:blank"

# ───────────────────── frontend redirects ─────────────────────
# Instance lists live in frontends.json (first entry = default, India/Asia first).
# Inside qutebrowser:
#   ,i   ping every instance, then open ":frontend " with a latency-sorted list
#   ,I   forget your picks
# Picks are stored in ~/.local/state/qutebrowser/frontends-choice.json and apply
# immediately (no reload needed).
FRONTENDS = os.path.join(str(config.configdir), "frontends.json")
CHOICE = os.path.join(
    os.environ.get("XDG_STATE_HOME", os.path.expanduser("~/.local/state")),
    "qutebrowser",
    "frontends-choice.json",
)

_latency = {}  # url -> (milliseconds or None, status)
_redirects_on = [True]  # session-only switch, flipped by :frontend-toggle


def _load(path):
    try:
        with open(path) as f:
            return json.load(f)
    except (OSError, ValueError):
        return {}


def _save_choice(choice):
    os.makedirs(os.path.dirname(CHOICE), exist_ok=True)
    with open(CHOICE, "w") as f:
        json.dump(choice, f, indent=2)


def _pick(service):
    chosen = _load(CHOICE).get(service)
    if chosen:
        return chosen
    entries = _load(FRONTENDS).get(service, [])
    return entries[0]["url"] if entries else None


def _probe(url):
    t0 = time.monotonic()
    req = urllib.request.Request(
        url, method="HEAD", headers={"User-Agent": "Mozilla/5.0"}
    )
    try:
        with urllib.request.urlopen(req, timeout=4) as r:
            code = r.status
    except urllib.error.HTTPError as e:
        code = e.code
    except Exception:
        _latency[url] = (None, "down")
        return
    ms = int((time.monotonic() - t0) * 1000)
    _latency[url] = (ms, "ok" if code < 400 else f"http {code}")


def _instances_model(*, info=None):
    """Completion for :frontend, one category per service, fastest first."""
    model = completionmodel.CompletionModel(column_widths=(42, 40, 18))
    choice = _load(CHOICE)
    for service, entries in _load(FRONTENDS).items():
        rows = []
        for idx, e in enumerate(entries):
            ms, status = _latency.get(e["url"], (None, None))
            if ms is not None:
                key = (0, ms)
            elif status == "down":
                key = (2, idx)
            else:
                key = (1, idx)
            default = choice.get(service) == e["url"] or (
                service not in choice and idx == 0
            )
            lat = f"{ms} ms" if ms is not None else (status or "")
            if ms is not None and status != "ok":
                lat += f" ({status})"
            rows.append((
                key,
                (
                    e["url"],
                    " ".join(x for x in (e.get("country", ""), e.get("note", "")) if x),
                    ("* " if default else "") + lat,
                ),
            ))
        rows.sort(key=lambda r: r[0])
        model.add_category(
            listcategory.ListCategory(service, [r[1] for r in rows], sort=False)
        )
    return model


# :config-source re-executes this file inside the running process, where the
# commands and the interceptor are already registered. Register only once.
_RELOAD = getattr(sys, "_frontends_registered", False)
sys._frontends_registered = True


def _cmd(**kw):
    def deco(f):
        return f if _RELOAD else cmdutils.register(**kw)(f)
    return deco


@_cmd(name="frontend-ping")
def frontend_ping():
    """Measure latency to every frontend instance (shown in :frontend completion)."""
    _latency.clear()

    def run():
        urls = [e["url"] for es in _load(FRONTENDS).values() for e in es]
        with ThreadPoolExecutor(max_workers=16) as ex:
            list(ex.map(_probe, urls))

    threading.Thread(target=run, daemon=True).start()
    message.info("frontends: pinging instances...")


@_cmd(name="frontend")
@cmdutils.argument("url", completion=_instances_model)
def frontend(url: str):
    """Use this instance for its frontend service.

    Args:
        url: The instance URL (complete with Tab).
    """
    url = url.rstrip("/")
    for service, entries in _load(FRONTENDS).items():
        if any(e["url"] == url for e in entries):
            choice = _load(CHOICE)
            choice[service] = url
            _save_choice(choice)
            message.info(f"{service} -> {url}")
            return
    raise cmdutils.CommandError(f"unknown instance: {url}")


@_cmd(name="frontend-reset")
def frontend_reset():
    """Forget all frontend picks (back to the default order)."""
    _save_choice({})
    message.info("frontends: reset to default order")


@_cmd(name="frontend-toggle")
def frontend_toggle():
    """Turn frontend redirects on/off for this session."""
    _redirects_on[0] = not _redirects_on[0]
    message.info("frontend redirects: " + ("ON" if _redirects_on[0] else "OFF"))


def _redirect(info):
    if not _redirects_on[0]:
        return
    if info.resource_type != interceptor.ResourceType.main_frame:
        return
    url = info.request_url
    host = url.host().removeprefix("www.").removeprefix("m.")
    path = url.path()
    query = url.query()
    tail = path + (("?" + query) if query else "")

    service = None
    rest = tail
    if host in ("youtube.com", "music.youtube.com"):
        service = "invidious"
    elif host == "youtu.be":
        service, rest = "invidious", "/watch?v=" + path.lstrip("/")
    elif host in ("reddit.com", "old.reddit.com"):
        service = "redlib"
    elif host in ("twitter.com", "x.com"):
        service = "nitter"
    elif host == "instagram.com":
        service = "proxigram"
    elif host in ("imgur.com", "i.imgur.com"):
        service = "rimgo"
    elif host == "medium.com":
        service = "scribe"
    elif host.endswith(".fandom.com"):
        service = "breezewiki"
        rest = "/" + host[: -len(".fandom.com")] + tail

    if service is None:
        return
    base = _pick(service)
    if base:
        info.redirect(QUrl(base + rest))


if not _RELOAD:
    interceptor.register(_redirect)

# ───────────────── cloudflare challenges ─────────────────
# The "verify you are human" check needs canvas, first-party cookies and
# challenges.cloudflare.com; with them blocked it loops forever. Loosen those
# only for Cloudflare-fronted frontend instances (tagged in frontends.json).
c.content.blocking.whitelist = ["*://challenges.cloudflare.com/*"]
for _es in _load(FRONTENDS).values():
    for _e in _es:
        if "cloudflare" in _e.get("note", ""):
            _pat = "*://" + urllib.parse.urlparse(_e["url"]).hostname + "/*"
            config.set("content.cookies.accept", "all", _pat)
            config.set("content.canvas_reading", True, _pat)

# ───────────────────────── look ─────────────────────────
c.fonts.default_family = "MonaspiceNe Nerd Font"
c.fonts.default_size = "10pt"
c.tabs.show = "multiple"
c.tabs.padding = {"top": 5, "bottom": 5, "left": 10, "right": 10}
c.tabs.indicator.width = 0
c.tabs.title.format = "{audio}{current_title}"
c.statusbar.padding = {"top": 4, "bottom": 4, "left": 6, "right": 6}
c.completion.shrink = True
c.completion.scrollbar.width = 0
c.hints.border = "none"
c.scrolling.smooth = False
c.colors.webpage.preferred_color_scheme = "dark"
# force dark on sites with no dark theme of their own. Qt's darkmode only inverts
# (it can't take palette colors); the matugen part is webpage.bg below, which is
# what shows before a page paints and behind transparent pages. toggle: `td`
c.colors.webpage.darkmode.enabled = True
c.colors.webpage.darkmode.algorithm = "lightness-cielab"
c.colors.webpage.darkmode.policy.images = "smart"
config.bind("td", "config-cycle colors.webpage.darkmode.enabled true false")

# fallback palette so the browser still looks sane before matugen has run
P = {
    "background": "#111318", "on_background": "#e2e2e9",
    "surface": "#111318", "on_surface": "#e2e2e9", "on_surface_variant": "#c4c6d0",
    "surface_container_low": "#191c20", "surface_container": "#1d2024",
    "surface_container_high": "#282a2f",
    "primary": "#aac7ff", "on_primary": "#0a305f",
    "primary_container": "#284777", "on_primary_container": "#d6e3ff",
    "secondary": "#bfc6dc", "on_secondary": "#293041",
    "secondary_container": "#3f4759", "on_secondary_container": "#dbe2f9",
    "tertiary": "#debcdf", "on_tertiary": "#3f2844",
    "tertiary_container": "#573e5c", "on_tertiary_container": "#fbd7fc",
    "error": "#ffb4ab", "on_error": "#690005",
    "error_container": "#93000a", "on_error_container": "#ffdad6",
    "outline": "#8e9099", "outline_variant": "#44474e",
}
try:
    with open(os.path.join(str(config.configdir), "colors.json")) as f:
        P.update(json.load(f))
except (OSError, ValueError):
    pass

c.colors.webpage.bg = P["background"]

c.colors.completion.fg = [P["on_surface_variant"], P["on_surface"], P["on_surface"]]
c.colors.completion.odd.bg = P["surface_container_low"]
c.colors.completion.even.bg = P["surface_container_low"]
c.colors.completion.category.fg = P["primary"]
c.colors.completion.category.bg = P["surface_container_high"]
c.colors.completion.category.border.top = P["surface_container_high"]
c.colors.completion.category.border.bottom = P["surface_container_high"]
c.colors.completion.item.selected.fg = P["on_primary_container"]
c.colors.completion.item.selected.bg = P["primary_container"]
c.colors.completion.item.selected.border.top = P["primary_container"]
c.colors.completion.item.selected.border.bottom = P["primary_container"]
c.colors.completion.item.selected.match.fg = P["primary"]
c.colors.completion.match.fg = P["primary"]
c.colors.completion.scrollbar.fg = P["outline"]
c.colors.completion.scrollbar.bg = P["surface_container_low"]

c.colors.contextmenu.menu.bg = P["surface_container"]
c.colors.contextmenu.menu.fg = P["on_surface"]
c.colors.contextmenu.selected.bg = P["primary_container"]
c.colors.contextmenu.selected.fg = P["on_primary_container"]
c.colors.contextmenu.disabled.bg = P["surface_container"]
c.colors.contextmenu.disabled.fg = P["outline"]

c.colors.downloads.bar.bg = P["surface"]
c.colors.downloads.start.bg = P["primary"]
c.colors.downloads.start.fg = P["on_primary"]
c.colors.downloads.stop.bg = P["tertiary"]
c.colors.downloads.stop.fg = P["on_tertiary"]
c.colors.downloads.error.bg = P["error_container"]
c.colors.downloads.error.fg = P["on_error_container"]

c.colors.hints.bg = P["primary"]
c.colors.hints.fg = P["on_primary"]
c.colors.hints.match.fg = P["tertiary_container"]
c.colors.keyhint.bg = P["surface_container"]
c.colors.keyhint.fg = P["on_surface"]
c.colors.keyhint.suffix.fg = P["primary"]

c.colors.messages.info.bg = P["surface_container"]
c.colors.messages.info.fg = P["on_surface"]
c.colors.messages.info.border = P["surface_container"]
c.colors.messages.warning.bg = P["tertiary_container"]
c.colors.messages.warning.fg = P["on_tertiary_container"]
c.colors.messages.warning.border = P["tertiary_container"]
c.colors.messages.error.bg = P["error_container"]
c.colors.messages.error.fg = P["on_error_container"]
c.colors.messages.error.border = P["error_container"]

c.colors.prompts.bg = P["surface_container"]
c.colors.prompts.fg = P["on_surface"]
c.colors.prompts.border = f"1px solid {P['outline_variant']}"
c.colors.prompts.selected.bg = P["primary_container"]
c.colors.prompts.selected.fg = P["on_primary_container"]

c.colors.statusbar.normal.bg = P["surface"]
c.colors.statusbar.normal.fg = P["on_surface"]
c.colors.statusbar.insert.bg = P["primary"]
c.colors.statusbar.insert.fg = P["on_primary"]
c.colors.statusbar.passthrough.bg = P["secondary"]
c.colors.statusbar.passthrough.fg = P["on_secondary"]
c.colors.statusbar.private.bg = P["tertiary_container"]
c.colors.statusbar.private.fg = P["on_tertiary_container"]
c.colors.statusbar.command.bg = P["surface_container_high"]
c.colors.statusbar.command.fg = P["on_surface"]
c.colors.statusbar.command.private.bg = P["surface_container_high"]
c.colors.statusbar.command.private.fg = P["on_surface"]
c.colors.statusbar.caret.bg = P["tertiary"]
c.colors.statusbar.caret.fg = P["on_tertiary"]
c.colors.statusbar.caret.selection.bg = P["tertiary"]
c.colors.statusbar.caret.selection.fg = P["on_tertiary"]
c.colors.statusbar.progress.bg = P["primary"]
c.colors.statusbar.url.fg = P["on_surface"]
c.colors.statusbar.url.hover.fg = P["secondary"]
c.colors.statusbar.url.success.http.fg = P["on_surface"]
c.colors.statusbar.url.success.https.fg = P["primary"]
c.colors.statusbar.url.warn.fg = P["secondary"]
c.colors.statusbar.url.error.fg = P["error"]

c.colors.tabs.bar.bg = P["background"]
c.colors.tabs.odd.bg = P["surface_container_low"]
c.colors.tabs.even.bg = P["surface_container_low"]
c.colors.tabs.odd.fg = P["on_surface_variant"]
c.colors.tabs.even.fg = P["on_surface_variant"]
c.colors.tabs.selected.odd.bg = P["primary_container"]
c.colors.tabs.selected.even.bg = P["primary_container"]
c.colors.tabs.selected.odd.fg = P["on_primary_container"]
c.colors.tabs.selected.even.fg = P["on_primary_container"]
c.colors.tabs.pinned.odd.bg = P["secondary_container"]
c.colors.tabs.pinned.even.bg = P["secondary_container"]
c.colors.tabs.pinned.odd.fg = P["on_secondary_container"]
c.colors.tabs.pinned.even.fg = P["on_secondary_container"]
c.colors.tabs.pinned.selected.odd.bg = P["primary_container"]
c.colors.tabs.pinned.selected.even.bg = P["primary_container"]
c.colors.tabs.pinned.selected.odd.fg = P["on_primary_container"]
c.colors.tabs.pinned.selected.even.fg = P["on_primary_container"]
c.colors.tabs.indicator.start = P["secondary"]
c.colors.tabs.indicator.stop = P["primary"]
c.colors.tabs.indicator.error = P["error"]

# ───────────────────────── bindings ─────────────────────────
config.bind(",m", "spawn --userscript play")                    # current page -> mpv
config.bind(",M", "hint links userscript play")                 # hinted link -> mpv
config.bind(",i", "frontend-ping ;; cmd-set-text -s :frontend ")    # pick frontend instances
config.bind(",t", "frontend-toggle")                                 # redirects on/off (this session)
config.bind(",I", "frontend-reset")                                  # forget picks
config.bind(",f", "spawn librewolf {url}")                        # escape hatch: original site
config.bind(",c", "set -t -u *://{url:host}/* content.canvas_reading true ;; set -t -u *://{url:host}/* content.cookies.accept all ;; reload")  # fix stuck cloudflare check on this site
config.bind(",b", "config-cycle content.blocking.enabled true false")
config.bind(",r", "config-source")                              # reload (matugen does this itself)
