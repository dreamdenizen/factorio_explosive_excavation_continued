data:extend({
  {
    type = "technology",
    name = "blasting-charges",
    icon = "__explosive_excavation_continued__/graphics/technology/blasting-explosives.png",
    -- 480x256: a 256px icon followed by its 128/64/32 mipmaps, which is what all 132
    -- base-game technology icons are. Base technology.lua declares icon_size, so do the same.
    icon_size = 256,
    prerequisites = {"cliff-explosives", "landfill", "military-science-pack"},
    unit =
    {
      count = 150,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"military-science-pack", 1}
      },
      time = 15
    },
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "blasting-charge"
      }
    },
    order = "b-d"
  }
})