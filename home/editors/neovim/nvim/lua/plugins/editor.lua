-- electric pairs, surround, text objects, colour previews (mini.nvim is added in ui.lua)
local u = require("core.util")

u.defer(function()
  require("mini.pairs").setup()
  require("mini.surround").setup() -- sa / sd / sr
  require("mini.ai").setup({ n_lines = 300 })

  -- colour previews: a coloured dot before #rrggbb and rgb(r, g, b) values
  local hi = require("mini.hipatterns")
  local dot = "● "
  hi.setup({
    highlighters = {
      hex_color = hi.gen_highlighter.hex_color({ style = "inline", inline_text = dot }),
      rgb_color = {
        pattern = "rgba?%(%s*%d+%s*,%s*%d+%s*,%s*%d+[%s,%)]",
        group = function(_, match)
          local r, g, b = match:match("rgba?%(%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)")
          r, g, b = tonumber(r), tonumber(g), tonumber(b)
          if not (r and g and b) or r > 255 or g > 255 or b > 255 then
            return nil
          end
          return hi.compute_hex_color_group(("#%02x%02x%02x"):format(r, g, b), "fg")
        end,
        extmark_opts = function(_, _, data)
          return {
            virt_text = { { dot, data.hl_group } },
            virt_text_pos = "inline",
            priority = 200,
            right_gravity = false,
          }
        end,
      },
    },
  })
end)
