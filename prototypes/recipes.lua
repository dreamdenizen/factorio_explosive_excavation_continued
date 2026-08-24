data:extend({
  {
    type = "recipe",
    name = "blasting-charge",
    energy_required = 8,
    enabled = false,
    -- `category` was removed from RecipePrototype in 2.1.7 and merged into `categories`.
    categories = {"crafting"},
    ingredients =
    {
      {type = "item", name = "cliff-explosives", amount = 2},
      {type = "item", name = "barrel", amount = 1}
    },
    results =
    {
      {type = "item", name = "blasting-charge", amount = 1}
    }
  }
})
