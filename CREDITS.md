# Credits

## Code

Explosive Excavation was written by GotLag. This fork carries it forward for
Factorio 2.1 and is maintained by dreamdenizen. The original and this fork are
both MIT licensed.

## Graphics

`graphics/icons/blasting-explosives.png` and
`graphics/technology/blasting-explosives.png` are **derived from Factorio's own
`cliff-explosives` icons**, which are copyright Wube Software. They are not
original artwork and are not covered by this mod's MIT licence.

The derivation is a red/blue channel swap and nothing else, which turns the blue
dynamite yellow while leaving the grey wrapping bands, the cast shadow, and the
entire alpha channel bit-identical to Wube's originals. `tools/recolour-from-base.py`
regenerates both files from a Factorio installation.

The idea, and the observation that a straight channel swap avoids the green cast a
hue rotation introduces, came from a contributor on the mod portal. They also
confirmed the correct mipmap strip layout. Thanks for that.
