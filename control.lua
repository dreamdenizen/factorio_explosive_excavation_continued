-- Explosive Excavation -- control stage.
--
-- The heavy lifting is done by the prototype: the charge's `place_as_tile` has already
-- turned the target tiles into Nauvis water by the time any of these handlers run.
-- This script only
--   * plays a purely cosmetic explosion over every tile that was blasted,
--   * swaps that water for whatever liquid the planet actually has, and
--   * refuses to flood a space platform.
--
-- No state is kept between ticks, so there is nothing in `storage`, no on_init/on_load,
-- and no migrations are needed.

local CHARGE_ITEM = "blasting-charge"
local EXPLOSION = "big-explosion"

--- Liquid that replaces the water the charge places, per planet.
---
--- Keyed by *planet prototype* name (`LuaSurface::planet`) rather than by surface name:
--- surface names are not authoritative (they can be renamed, space platforms are called
--- "platform-1", and scripted surfaces reuse names freely), whereas the planet a surface
--- belongs to is. A planet missing from this table keeps the water that was already
--- placed, which is the correct result for Nauvis and for Nauvis-like modded planets.
local planet_fill_tile =
{
  vulcanus = "lava",
  fulgora = "oil-ocean-deep",
  gleba = "gleba-deep-lake",
  aquilo = "brash-ice",
}

--- @param surface LuaSurface
--- @return string|nil tile prototype name, or nil to keep the water already placed
local function fill_tile_for(surface)
  local planet = surface.planet
  if not planet then return nil end
  return planet_fill_tile[planet.name]
end

--- Put the blasted tiles back and refund the charges.
--- @param surface LuaSurface
--- @param tiles OldTileAndPosition[]
--- @param event EventData
local function undo(surface, tiles, event)
  local restored = {}
  for i = 1, #tiles do
    restored[i] = {position = tiles[i].position, name = tiles[i].old_tile.name}
  end
  surface.set_tiles(restored)

  -- One charge is consumed per tile (condition_size = 1), so refund one per tile.
  local refund = {name = event.item.name, count = #tiles, quality = event.quality}

  -- `insert` returns how many it actually took, which can be fewer than asked for.
  -- Placing the tiles just freed this space so a short insert is unlikely, but the
  -- difference would otherwise be items the player silently loses.
  local inserted = 0
  local inventory = event.inventory
  if inventory and inventory.valid then
    inserted = inventory.insert(refund)
  end

  local leftover = #tiles - inserted
  if leftover > 0 then
    local position = tiles[1].position
    surface.spill_item_stack({
      position = {position.x + 0.5, position.y + 0.5},
      stack = {name = refund.name, count = leftover, quality = refund.quality},
      enable_looted = true,
    })
  end
end

--- @param event EventData
--- @param builder LuaPlayer|LuaEntity|nil whoever placed the tiles, for the explosion's force
local function on_built_tile(event, builder)
  local item = event.item
  if not (item and item.valid and item.name == CHARGE_ITEM) then return end

  local tiles = event.tiles
  if #tiles == 0 then return end

  -- surface_index is the event's own authoritative surface; deriving it from the
  -- builder breaks for remote construction and for the space platform event, which
  -- has no builder entity at all.
  local surface = game.surfaces[event.surface_index]
  if not (surface and surface.valid) then return end

  -- A space platform is not a planet and has no business being flooded.
  if surface.platform then
    undo(surface, tiles, event)
    return
  end

  local force = (builder and builder.valid) and builder.force or nil
  for i = 1, #tiles do
    local position = tiles[i].position
    surface.create_entity({
      name = EXPLOSION,
      force = force,
      -- position is a TilePosition (the tile's top-left corner); offset to its centre.
      position = {position.x + 0.5, position.y + 0.5},
    })
  end

  local fill = fill_tile_for(surface)
  if not fill then return end

  -- Build a fresh array rather than mutating the event's tiles in place: the entries
  -- are OldTileAndPosition, other mods handling the same event see the same tables,
  -- and `set_tiles` requires a `name` on every entry.
  local replacement = {}
  for i = 1, #tiles do
    replacement[i] = {position = tiles[i].position, name = fill}
  end
  surface.set_tiles(replacement)
end

-- Neither of the built_tile events supports event filters in 2.1, so the item check
-- above is the earliest possible bail-out.
script.on_event(defines.events.on_player_built_tile, function(event)
  on_built_tile(event, game.get_player(event.player_index))
end)

script.on_event(defines.events.on_robot_built_tile, function(event)
  on_built_tile(event, event.robot)
end)

if defines.events.on_space_platform_built_tile then
  script.on_event(defines.events.on_space_platform_built_tile, function(event)
    on_built_tile(event, nil)
  end)
end
