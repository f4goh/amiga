from PIL import Image

#------------------------------------------------------------
# Configuration
#------------------------------------------------------------

INPUT_FILE = "nemo.png"
OUTPUT_FILE = "sprite.h"

#------------------------------------------------------------

def rgb12(rgb):
    r, g, b = rgb
    return ((r >> 4) << 8) | ((g >> 4) << 4) | (b >> 4)

#------------------------------------------------------------

img = Image.open(INPUT_FILE).convert("RGB")

if img.width != 16:
    raise Exception("Le sprite doit faire exactement 16 pixels de large.")

width, height = img.size

#
# Tous les pixels noirs resteront transparents.
# Les autres seront quantifiés sur 3 couleurs.
#

work = img.copy()

for y in range(height):
    for x in range(width):
        if work.getpixel((x, y)) == (0, 0, 0):
            work.putpixel((x, y), (1, 1, 1))

#
# Quantification sur 4 couleurs.
#

quant = work.quantize(colors=4)

palette = quant.getpalette()

#
# Construction des 4 couleurs RGB
#

colors = []

for i in range(4):
    colors.append((
        palette[i * 3],
        palette[i * 3 + 1],
        palette[i * 3 + 2]
    ))

#
# La couleur la plus proche du noir devient la transparence.
#

transparent_index = 0
best = 1000000

for i, c in enumerate(colors):
    d = c[0] * c[0] + c[1] * c[1] + c[2] * c[2]
    if d < best:
        best = d
        transparent_index = i

#
# Palette Amiga
#

sprite_palette = []

for i, c in enumerate(colors):
    if i != transparent_index:
        sprite_palette.append(c)

while len(sprite_palette) < 3:
    sprite_palette.append((255, 255, 255))

#
# Conversion index quantifié -> index sprite
#

mapping = {}

next_index = 1

for i in range(4):
    if i == transparent_index:
        mapping[i] = 0
    else:
        mapping[i] = next_index
        next_index += 1

#
# Génération du fichier
#

out = []

out.append("static UWORD nemo_palette[] = {")
out.append("    0x000,")

for c in sprite_palette:
    out.append(f"    0x{rgb12(c):03X},")

out.append("};")
out.append("")
out.append("static UWORD __chip nemo_data[] = {")
out.append("    0x0000, 0x0000,")

for y in range(height):

    plane0 = 0
    plane1 = 0

    for x in range(16):

        idx = quant.getpixel((x, y))
        idx = mapping[idx]

        if idx & 1:
            plane0 |= 1 << (15 - x)

        if idx & 2:
            plane1 |= 1 << (15 - x)

    out.append(f"    0x{plane0:04X}, 0x{plane1:04X},")

out.append("    0x0000, 0x0000")
out.append("};")

with open(OUTPUT_FILE, "w") as f:
    f.write("\n".join(out))

print("Sprite généré :", OUTPUT_FILE)
