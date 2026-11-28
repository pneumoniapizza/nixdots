-- Rose Pine for neovim: one static palette, every highlight group is built from it.
local M = {}

-- rose-pine, expressed as material-style roles
local palette = {
  primary = "#c4a7e7",
  on_primary = "#191724",
  primary_container = "#493f5b",
  on_primary_container = "#c4a7e7",
  secondary = "#9ccfd8",
  on_secondary = "#191724",
  secondary_container = "#3e4b56",
  on_secondary_container = "#9ccfd8",
  tertiary = "#ebbcba",
  on_tertiary = "#191724",
  tertiary_container = "#54454e",
  on_tertiary_container = "#ebbcba",
  error = "#eb6f92",
  on_error = "#191724",
  error_container = "#543043",
  on_error_container = "#eb6f92",
  background = "#191724",
  on_background = "#e0def4",
  surface = "#191724",
  on_surface = "#e0def4",
  surface_variant = "#26233a",
  on_surface_variant = "#908caa",
  outline = "#6e6a86",
  outline_variant = "#403d52",
  surface_dim = "#13111e",
  surface_bright = "#403d52",
  surface_container_lowest = "#13111e",
  surface_container_low = "#1c1a29",
  surface_container = "#1f1d2e",
  surface_container_high = "#26233a",
  surface_container_highest = "#403d52",
}

local function rgb(hex)
  return tonumber(hex:sub(2, 3), 16), tonumber(hex:sub(4, 5), 16), tonumber(hex:sub(6, 7), 16)
end

local function lerp(a, b, t)
  return math.floor(a + (b - a) * t + 0.5)
end

--- t = 0 → a, t = 1 → b
local function mix(a, b, t)
  local ar, ag, ab = rgb(a)
  local br, bg, bb = rgb(b)
  return ("#%02x%02x%02x"):format(lerp(ar, br, t), lerp(ag, bg, t), lerp(ab, bb, t))
end

function M.apply()
  local c = palette

  vim.o.background = "dark"

  vim.cmd("hi clear")
  if vim.fn.exists("syntax_on") == 1 then
    vim.cmd("syntax reset")
  end
  vim.o.termguicolors = true

  local fg = c.on_surface
  local bg = vim.g.transparent and "NONE" or c.surface
  local float = c.surface_container_low
  local sel = mix(c.surface, c.primary, 0.22)
  local warn = mix(c.error, c.tertiary, 0.55)

  -- syntax roles (Material only gives 3 hues, so we blend a few more)
  local p = {
    kw = c.primary,
    fn = c.tertiary,
    ty = mix(c.primary, c.tertiary, 0.5),
    str = c.secondary,
    num = mix(c.tertiary, c.error, 0.4),
    const = mix(c.tertiary, c.error, 0.4),
    builtin = mix(c.primary, c.error, 0.35),
    param = mix(fg, c.primary, 0.35),
    prop = mix(fg, c.secondary, 0.45),
    special = mix(c.primary, c.secondary, 0.5),
    op = c.on_surface_variant,
    delim = mix(c.on_surface_variant, c.outline, 0.4),
  }

  local hl = {
    -- editor
    Normal = { fg = fg, bg = bg },
    NormalNC = { fg = fg, bg = bg },
    NormalFloat = { fg = fg, bg = float },
    FloatBorder = { fg = c.outline, bg = float },
    FloatTitle = { fg = c.primary, bg = float, bold = true },
    SignColumn = { bg = bg },
    FoldColumn = { fg = c.outline, bg = bg },
    ColorColumn = { bg = c.surface_container_low },
    CursorLine = { bg = c.surface_container },
    CursorColumn = { bg = c.surface_container },
    CursorLineNr = { fg = c.primary, bold = true },
    LineNr = { fg = c.outline_variant },
    LineNrAbove = { fg = c.outline_variant },
    LineNrBelow = { fg = c.outline_variant },
    Visual = { bg = sel },
    VisualNOS = { bg = sel },
    Search = { fg = c.on_tertiary_container, bg = c.tertiary_container },
    CurSearch = { fg = c.on_tertiary, bg = c.tertiary },
    IncSearch = { fg = c.on_tertiary, bg = c.tertiary },
    Substitute = { fg = c.on_error, bg = c.error },
    MatchParen = { fg = c.tertiary, bold = true, underline = true },
    WinSeparator = { fg = c.outline_variant },
    Folded = { fg = c.on_surface_variant, bg = c.surface_container },
    NonText = { fg = c.outline_variant },
    Whitespace = { fg = c.outline_variant },
    SpecialKey = { fg = c.outline_variant },
    EndOfBuffer = { fg = bg },
    Conceal = { fg = c.outline },
    Directory = { fg = c.primary },
    Title = { fg = c.primary, bold = true },
    QuickFixLine = { bg = sel, bold = true },
    WildMenu = { fg = c.on_primary_container, bg = c.primary_container },
    Underlined = { underline = true },

    -- messages
    ErrorMsg = { fg = c.error, bold = true },
    WarningMsg = { fg = warn },
    MoreMsg = { fg = c.secondary },
    ModeMsg = { fg = c.on_surface_variant },
    Question = { fg = c.secondary },

    -- popup menu
    Pmenu = { fg = fg, bg = c.surface_container },
    PmenuSel = { fg = c.on_primary_container, bg = c.primary_container, bold = true },
    PmenuKind = { fg = c.secondary, bg = c.surface_container },
    PmenuExtra = { fg = c.outline, bg = c.surface_container },
    PmenuSbar = { bg = c.surface_container_high },
    PmenuThumb = { bg = c.outline },

    -- statusline / tabline
    StatusLine = { fg = c.on_surface_variant, bg = c.surface_container },
    StatusLineNC = { fg = c.outline, bg = c.surface_container },
    TabLine = { fg = c.outline, bg = c.surface_container },
    TabLineSel = { fg = c.on_primary_container, bg = c.primary_container, bold = true },
    TabLineFill = { bg = c.surface_container_low },

    -- diff
    DiffAdd = { bg = mix(c.surface, c.tertiary, 0.18) },
    DiffChange = { bg = mix(c.surface, c.primary, 0.12) },
    DiffDelete = { fg = c.error, bg = mix(c.surface, c.error, 0.18) },
    DiffText = { bg = mix(c.surface, c.primary, 0.3) },
    Added = { fg = c.tertiary },
    Changed = { fg = c.primary },
    Removed = { fg = c.error },

    -- syntax
    Comment = { fg = c.outline, italic = true },
    Constant = { fg = p.const },
    String = { fg = p.str },
    Character = { fg = p.str },
    Number = { fg = p.num },
    Boolean = { fg = p.const, bold = true },
    Float = { fg = p.num },
    Identifier = { fg = fg },
    Function = { fg = p.fn },
    Statement = { fg = p.kw },
    Operator = { fg = p.op },
    PreProc = { fg = p.special },
    Type = { fg = p.ty },
    Special = { fg = p.special },
    Delimiter = { fg = p.delim },
    Tag = { fg = p.kw },
    Error = { fg = c.error },
    Todo = { fg = c.on_tertiary, bg = c.tertiary, bold = true },

    -- treesitter (everything not listed falls back to the groups above)
    ["@variable"] = { fg = fg },
    ["@variable.builtin"] = { fg = p.builtin },
    ["@variable.parameter"] = { fg = p.param },
    ["@variable.member"] = { fg = p.prop },
    ["@property"] = { fg = p.prop },
    ["@constant.builtin"] = { fg = p.builtin },
    ["@function.builtin"] = { fg = p.builtin },
    ["@constructor"] = { fg = p.ty },
    ["@module"] = { fg = mix(fg, c.primary, 0.3) },
    ["@keyword.return"] = { fg = p.kw, italic = true },
    ["@punctuation.bracket"] = { fg = p.delim },
    ["@punctuation.delimiter"] = { fg = p.delim },
    ["@tag"] = { fg = p.kw },
    ["@tag.attribute"] = { fg = p.prop },
    ["@tag.delimiter"] = { fg = p.delim },
    ["@markup.heading"] = { fg = c.primary, bold = true },
    ["@markup.strong"] = { bold = true },
    ["@markup.italic"] = { italic = true },
    ["@markup.link"] = { fg = c.tertiary },
    ["@markup.link.url"] = { fg = c.tertiary, underline = true },
    ["@markup.raw"] = { fg = c.secondary },
    ["@comment.todo"] = { fg = c.on_tertiary, bg = c.tertiary, bold = true },
    ["@comment.note"] = { fg = c.on_primary, bg = c.primary, bold = true },
    ["@comment.warning"] = { fg = c.on_error, bg = warn, bold = true },
    ["@comment.error"] = { fg = c.on_error, bg = c.error, bold = true },

    -- lsp
    LspReferenceText = { bg = c.surface_container_high },
    LspReferenceRead = { bg = c.surface_container_high },
    LspReferenceWrite = { bg = c.surface_container_high, underline = true },
    LspInlayHint = { fg = c.outline, italic = true },
    LspCodeLens = { fg = c.outline },
    LspSignatureActiveParameter = { fg = c.primary, bold = true, underline = true },

    -- gitsigns
    GitSignsAdd = { fg = c.tertiary },
    GitSignsChange = { fg = c.primary },
    GitSignsDelete = { fg = c.error },

    -- snacks
    SnacksDashboardHeader = { fg = c.primary },
    SnacksDashboardKey = { fg = c.tertiary },
    SnacksDashboardIcon = { fg = c.primary },
    SnacksDashboardDesc = { fg = fg },
    SnacksDashboardFooter = { fg = c.outline, italic = true },
    SnacksIndent = { fg = c.surface_container_high },
    SnacksIndentScope = { fg = c.primary },
    SnacksPickerMatch = { fg = c.primary, bold = true },
    SnacksPickerDir = { fg = c.outline },

    -- blink.cmp
    BlinkCmpMenu = { fg = fg, bg = c.surface_container },
    BlinkCmpMenuBorder = { fg = c.outline_variant, bg = c.surface_container },
    BlinkCmpMenuSelection = { fg = c.on_primary_container, bg = c.primary_container, bold = true },
    BlinkCmpLabelMatch = { fg = c.primary, bold = true },
    BlinkCmpLabelDeprecated = { fg = c.outline, strikethrough = true },
    BlinkCmpKind = { fg = c.secondary },
    BlinkCmpGhostText = { fg = c.outline },
    BlinkCmpDoc = { fg = fg, bg = float },
    BlinkCmpDocBorder = { fg = c.outline, bg = float },

    -- statusline (see core/statusline.lua)
    StlBody = { fg = c.on_surface_variant, bg = c.surface_container },
    StlDim = { fg = c.outline, bg = c.surface_container },
    StlBranch = { fg = c.tertiary, bg = c.surface_container },
    StlError = { fg = c.error, bg = c.surface_container },
    StlWarn = { fg = warn, bg = c.surface_container },
    StlInfo = { fg = c.primary, bg = c.surface_container },
    StlHint = { fg = c.secondary, bg = c.surface_container },
    StlModeNormal = { fg = c.on_primary, bg = c.primary, bold = true },
    StlModeInsert = { fg = c.on_tertiary, bg = c.tertiary, bold = true },
    StlModeVisual = { fg = c.on_secondary, bg = c.secondary, bold = true },
    StlModeReplace = { fg = c.on_error, bg = c.error, bold = true },
    StlModeCommand = { fg = c.on_primary_container, bg = c.primary_container, bold = true },
    StlModeTerminal = { fg = c.on_secondary_container, bg = c.secondary_container, bold = true },
  }

  for name, col in pairs({ Error = c.error, Warn = warn, Info = c.primary, Hint = c.secondary, Ok = c.tertiary }) do
    hl["Diagnostic" .. name] = { fg = col }
    hl["DiagnosticVirtualText" .. name] = { fg = col, bg = mix(c.surface, col, 0.1) }
    hl["DiagnosticUnderline" .. name] = { underline = true, sp = col }
  end

  for name, spec in pairs(hl) do
    vim.api.nvim_set_hl(0, name, spec)
  end

  -- :terminal / snacks terminal use the same palette
  local ansi = {
    c.surface_container_high, c.error, c.tertiary, warn,
    c.primary, mix(c.primary, c.tertiary, 0.5), c.secondary, c.on_surface_variant,
  }
  for i, col in ipairs(ansi) do
    vim.g["terminal_color_" .. (i - 1)] = col
    vim.g["terminal_color_" .. (i + 7)] = mix(col, c.on_surface, 0.25)
  end

  vim.g.colors_name = "rose-pine"
end

function M.setup()
  vim.cmd.colorscheme("rose-pine")
end

return M
