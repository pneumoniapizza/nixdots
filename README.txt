1. Unzip over the root of your dotfiles repo (same paths).
2. git add -A   (flakes ignore untracked files, so new files must be staged)
3. Rebuild, then run matugen once (Mod+W picker), then: tmux kill-server
Overwrites: terminal/default.nix, terminal/yazi/default.nix, matugen templates (tmux + yazi), nvim init.lua
New: terminal/tmux/default.nix, nvim lua/core/tmux.lua
