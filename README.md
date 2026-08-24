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
| `graphics/` | the item and technology icons, committed and shipped as PNGs |
| `tools/` | maintainer scripts; not included in the built mod |

## Notes on the icons

The finished PNGs live in `graphics/` and are committed here and shipped inside the
mod. Nothing is generated at install time or at load time: Factorio's data stage is
plain Lua with no image manipulation, so a mod has to carry its own sprites.

They are Factorio's own `cliff-explosives` art with the red and blue channels
swapped, which turns the blue dynamite yellow. Grey pixels have `R == B`, so the
swap leaves the wrapping bands, the cast shadow and the whole alpha channel
bit-identical to Wube's originals.

`tools/recolour-from-base.py` is how those PNGs were produced, kept here so the
result is reproducible and so they can be regenerated if Wube ever redraws the base
art. It is a maintainer tool, run by hand against a Factorio installation, and
`build.sh` deliberately leaves `tools/` out of the released zip. It needs Pillow
(`pip install Pillow`):

```
tools/recolour-from-base.py \
  "<factorio>/data/base/graphics/icons/cliff-explosives.png" \
  graphics/icons/blasting-explosives.png
```

Sizes are deliberate. The item icon is 120x64 (a 64px icon plus 32/16/8 mipmaps)
and the technology icon 480x256 (256px plus 128/64/32), which is what every
base-game item and technology icon is. Factorio infers the mipmap count from
`icon_size` and the image width, so neither needs declaring beyond `icon_size`.

Because they derive from Wube's art, these two files are **not** covered by this
repo's MIT licence. See CREDITS.md.

## Licence

MIT, continuing GotLag's original licence. Graphics excepted, as above.
