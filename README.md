# Explosive Excavation Continued

Blast holes in the ground with explosives and let them fill with whatever liquid
the planet has. A maintained continuation of [GotLag's Explosive
Excavation](https://mods.factorio.com/mod/Explosive%20Excavation) for Factorio 2.1.

Research **Blasting charges** to unlock the recipe. Each charge is crafted from two
cliff explosives and a barrel, and places one tile of liquid: water on Nauvis, lava
on Vulcanus, heavy oil on Fulgora, a Gleba lake, or brash ice on Aquilo. Space
platforms refuse the charge and refund it.

## Installing

Grab it from the mod portal, or build from source:

```
tools/build.sh
```

That writes `dist/<name>_<version>.zip`, which you can drop straight into your
Factorio `mods/` folder.

## Layout

| path | what it is |
|---|---|
| `info.json` | mod metadata; `tools/build.sh` reads name and version from here |
| `data.lua` | loads the three prototype files |
| `prototypes/` | the item, its recipe, and the technology |
| `control.lua` | swaps the placed water for the planet's own liquid, plays the explosion, blocks space platforms |
| `graphics/` | item and technology icons |
| `tools/` | build and asset scripts |

## Notes on the icons

The icons are Factorio's own `cliff-explosives` art with the red and blue channels
swapped, which turns the blue dynamite yellow. Grey pixels have `R == B`, so the
swap leaves the wrapping bands, the cast shadow and the whole alpha channel
bit-identical to Wube's originals. `tools/recolour-from-base.py` regenerates them:

```
tools/recolour-from-base.py <factorio>/data/base/graphics/icons/cliff-explosives.png graphics/icons/blasting-explosives.png
```

They are Wube's assets, not covered by this repo's MIT licence. See CREDITS.md.

## Licence

MIT, continuing GotLag's original licence. Graphics excepted, as above.
