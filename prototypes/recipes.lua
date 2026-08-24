data:extend({
  {
    type = "recipe",
    name = "blasting-charge",
    energy_required = 8,
    enabled = false,
    -- `categories` is left unset: it defaults to {"crafting"}, which is what this wants.
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
