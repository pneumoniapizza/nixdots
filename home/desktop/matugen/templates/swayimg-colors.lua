-- text / info overlay
swayimg.text.set_foreground(0xff{{colors.on_surface.default.hex_stripped}})
swayimg.text.set_background(0xaa{{colors.surface_container.default.hex_stripped}})
swayimg.text.set_shadow(0xff{{colors.shadow.default.hex_stripped}})

-- single image view
swayimg.viewer.set_window_background(0xff{{colors.surface.default.hex_stripped}})
swayimg.viewer.set_image_background(0xff{{colors.surface_variant.default.hex_stripped}})
swayimg.viewer.set_mark_color(0xee{{colors.primary.default.hex_stripped}})

-- gallery (thumbnail grid)
swayimg.gallery.set_window_color(0xff{{colors.surface.default.hex_stripped}})
swayimg.gallery.set_unselected_color(0xff{{colors.surface_container.default.hex_stripped}})
swayimg.gallery.set_selected_color(0xff{{colors.surface_container_high.default.hex_stripped}})
swayimg.gallery.set_border_color(0xff{{colors.primary.default.hex_stripped}})
swayimg.gallery.set_mark_color(0xee{{colors.primary.default.hex_stripped}})

-- slideshow
swayimg.slideshow.set_window_background(0xff{{colors.surface.default.hex_stripped}})
swayimg.slideshow.set_image_background(0xff{{colors.surface_variant.default.hex_stripped}})
swayimg.slideshow.set_mark_color(0xee{{colors.primary.default.hex_stripped}})
