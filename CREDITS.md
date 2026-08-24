# Credits

## Code

Explosive Excavation was written by GotLag in 2016 and maintained through fourteen
releases up to version 1.3.0 in January 2025, spanning Factorio 0.13 to 2.0. This
fork carries it forward for Factorio 2.1 and is maintained by dreamdenizen.

The original is MIT licensed, as declared on its
[mod portal page](https://mods.factorio.com/mod/Explosive%20Excavation), and this
fork keeps that licence.

## Graphics

`graphics/icons/blasting-explosives.png` and
`graphics/technology/blasting-explosives.png` are **derived from Factorio's own
`cliff-explosives` icons**, which are copyright Wube Software. They are not
original artwork and are not covered by this mod's MIT licence.

The derivation is a red/blue channel swap and nothing else, which turns the blue
dynamite yellow while leaving the grey wrapping bands, the cast shadow, and the
entire alpha channel bit-identical to Wube's originals. `tools/recolour-from-base.py`
regenerates both files from a Factorio installation.

Thanks to [Ingo_Igel](https://mods.factorio.com/user/Ingo_Igel), author of Factorio
HD Age, who proposed the recolour on the mod portal and worked out that a straight
red/blue channel swap avoids the green cast a hue rotation leaves behind. They also
supplied the art already laid out as correct mipmap strips, which is what made it
obvious the base-game icons were the right starting point.
