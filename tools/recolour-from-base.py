#!/usr/bin/env python3
"""Recolour Factorio's cliff-explosives icons from blue to yellow.

The whole transform is a red/blue channel swap. That is all it takes, and it is
worth spelling out why it works so cleanly:

  * The dynamite sticks are blue, so swapping R and B turns them yellow.
  * Grey pixels have R == B, so a swap leaves them bit-identical. The wrapping
    bands and the cast shadow come through completely untouched, with no mask.
  * Alpha is not read or written, so mipmap levels, margins and antialiasing
    are preserved exactly as Wube authored them.

Anything more than the swap makes it worse: adding a green adjustment is what
put a green cast on the contributor's first attempt at these.

Usage: recolour.py <src.png> <dst.png>
"""
from PIL import Image
import numpy as np
import sys


def recolour(src, dst):
    a = np.array(Image.open(src).convert("RGBA"))
    Image.fromarray(a[:, :, [2, 1, 0, 3]], "RGBA").save(dst, optimize=True)
    return dst


if __name__ == "__main__":
    print(recolour(sys.argv[1], sys.argv[2]))
