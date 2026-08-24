local item_sounds = require("__base__.prototypes.item_sounds")

data:extend({
  {
    type = "item",
    name = "blasting-charge",
    icon = "__explosive_excavation_unofficial_2_1__/graphics/icons/blasting-explosives.png",
    -- 120x64: a 64px icon followed by its 32/16/8 mipmaps, matching every base-game
    -- item icon. 64 is the ItemPrototype default, and 2.0.7 onwards infers the mipmap
    -- count from icon_size and the actual image width, so neither needs declaring.
    subgroup = "terrain",
    -- Sorts after landfill (c[landfill]-a[dirt]) and after the Space Age terrain items,
    -- the last of which is c[landfill]-g[foundation].
    order = "c[landfill]-h[blasting-charge]",
    inventory_move_sound = item_sounds.explosive_inventory_move,
    pick_sound = item_sounds.explosive_inventory_pickup,
    drop_sound = item_sounds.explosive_inventory_move,
    stack_size = 20,
    place_as_tile =
    {
      result = "water",
      condition_size = 1,
      -- Mirror image of landfill, which uses {layers={ground_tile=true}}: the charge is
      -- placeable wherever the terrain does *not* already collide with water_tile,
      -- i.e. on dry land. control.lua then swaps the water for the planet's own liquid.
      condition = {layers = {water_tile = true}}
    }
  }
})
