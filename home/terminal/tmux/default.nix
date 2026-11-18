{pkgs, ...}: {
  programs.tmux = {
    enable = true;
    prefix = "C-Space";
    shell = "${pkgs.fish}/bin/fish";
    terminal = "tmux-256color";
    keyMode = "vi";
    mouse = true;
    baseIndex = 1;
    escapeTime = 0; # no esc lag in nvim
    historyLimit = 50000;
    secureSocket = false; # fixed /tmp socket so the matugen hook can always reach the server

    extraConfig = ''
      # terminal
      set -as terminal-features ",foot*:RGB,xterm-kitty:RGB"
      set -g focus-events on        # nvim FocusGained -> checktime
      set -g allow-passthrough on
      set -g set-clipboard on

      # numbering
      setw -g pane-base-index 1
      set -g renumber-windows on

      # sharp look
      set -g status on
      set -g status-position top
      set -g status-justify left
      set -g status-left-length 80
      set -g status-right-length 100
      set -g window-status-separator ""
      set -g pane-border-lines single
      set -g popup-border-lines single
      set -g menu-border-lines single

      # fallback palette; matugen overrides every @c_* in matugen-colors.conf
      set -g @c_primary "#a6c8ff"
      set -g @c_on_primary "#00315e"
      set -g @c_secondary "#bbc7db"
      set -g @c_on_secondary "#253140"
      set -g @c_tertiary "#d7bee4"
      set -g @c_on_tertiary "#3b2948"
      set -g @c_bar "#1d2024"
      set -g @c_seg "#272a2f"
      set -g @c_dim "#c3c7cf"
      set -g @c_outline "#8d9199"

      # nvim-style statusline:  [mode]>[ dir ]> windows ........ host <[ command ]<[ time ]
      # mode colors follow nvim: Normal = primary, Insert = tertiary (prefix held), Visual = secondary (copy mode)
      set -g @m_bg "#{?client_prefix,#{@c_tertiary},#{?pane_in_mode,#{@c_secondary},#{@c_primary}}}"
      set -g @m_fg "#{?client_prefix,#{@c_on_tertiary},#{?pane_in_mode,#{@c_on_secondary},#{@c_on_primary}}}"
      set -g @m_label "#{?client_prefix, PREFIX ,#{?pane_in_mode, COPY , #S }}"

      set -g status-left "#[bg=#{E:@m_bg},fg=#{E:@m_fg},bold]#{E:@m_label}#[fg=#{E:@m_bg},bg=#{@c_seg},nobold]\ue0b0#[fg=#{@c_dim}] \uf07b #[fg=#{E:@m_bg},bold]#{b:pane_current_path} #[fg=#{@c_seg},bg=#{@c_bar},nobold]\ue0b0#[fg=#{@c_dim}]"
      set -g status-right "#[fg=#{@c_dim},bg=#{@c_bar}]#h  #[fg=#{@c_seg}]\ue0b2#[fg=#{E:@m_bg},bg=#{@c_seg},bold] #{pane_current_command} #[fg=#{E:@m_bg}]\ue0b2#[fg=#{E:@m_fg},bg=#{E:@m_bg},bold] %H:%M  %d %b "

      # windows sit flat on the bar: hollow diamond = idle, filled = current
      set -g window-status-format " \u25c7 #I #W#{?window_zoomed_flag, #[fg=#{@c_outline}]zoom,} "
      set -g window-status-current-format "#[fg=#{E:@m_bg},bold] \u25c6 #I #W#{?window_zoomed_flag, #[fg=#{@c_outline}]zoom,} "

      # keys
      bind r source-file ~/.config/tmux/matugen-colors.conf \; display "colors reloaded"
      bind '|' split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      bind c new-window -c "#{pane_current_path}"
      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 5
      bind -r K resize-pane -U 5
      bind -r L resize-pane -R 5

      # copy mode (wl-copy)
      bind v copy-mode
      bind -T copy-mode-vi v send -X begin-selection
      bind -T copy-mode-vi C-v send -X rectangle-toggle
      bind -T copy-mode-vi y send -X copy-pipe-and-cancel "wl-copy"
      bind -T copy-mode-vi MouseDragEnd1Pane send -X copy-pipe-and-cancel "wl-copy"

      # seamless Ctrl+h/j/k/l between nvim splits and tmux panes (pairs with nvim core/tmux.lua)
      is_vim="ps -o state= -o comm= -t '#{pane_tty}' | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?\\.?(view|l?n?vim?x?|fzf)(diff)?(-wrapped)?$'"
      bind -n C-h if-shell "$is_vim" "send-keys C-h" "select-pane -L"
      bind -n C-j if-shell "$is_vim" "send-keys C-j" "select-pane -D"
      bind -n C-k if-shell "$is_vim" "send-keys C-k" "select-pane -U"
      bind -n C-l if-shell "$is_vim" "send-keys C-l" "select-pane -R"
      bind -T copy-mode-vi C-h select-pane -L
      bind -T copy-mode-vi C-j select-pane -D
      bind -T copy-mode-vi C-k select-pane -U
      bind -T copy-mode-vi C-l select-pane -R
      bind C-l send-keys C-l        # prefix+Ctrl+l = clear screen

      # palette + style colors, written by matugen (-q: ok if it doesn't exist yet)
      source-file -q ~/.config/tmux/matugen-colors.conf
    '';
  };
}
