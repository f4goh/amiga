# PNG to bitplane converter online by F4GOH

[PNG to bitplane converter](https://f4goh.github.io/amiga/Utility/gfx/)

# ADF-reader online

[ADF-reader](https://f4goh.github.io/amiga/Utility/ADF-reader/)


# Tiled Map Editor

[Tiled Map Editor](https://thorbjorn.itch.io/tiled)

![icone Tiled Map Editor](tme.png)

# Amiga Utility online

[Amiga utility](https://dirkwhoffmann.github.io/Moira/docs/Overview/About.html)

# [ADF read online](https://f4goh.github.io/amiga/Utility/ADF-reader/) 

# Create copper list easy

[gradient-blaster](https://gradient-blaster.grahambates.com)

# Amigeconv

**Ami**_ga_ _Ima_**ge** **Conv**_erter_ by Todi / Tulou.

A graphics converter for different Amiga bitplanes, chunky & palette formats.

## Building

In a Unix-like environment simply `make` the binary.


## Usage

```
amigeconv <options> <input> <output>
```

## Available options are:

```
ale@ale-desktop:~/amiga/Utility$ ./amigeconv 
Amigeconv (Amiga Image Converter) by Todi / Tulou - version 1.1.1 (2025-08-03)

Usage: amigeconv <options> <input> <output>

-f, --format bitplane,chunky,palette,sprite         Desired output file format.
-p, --palette pal8,pal4,pal32,loadrgb4,loadrgb32    Desired palette file format.
-l, --interleaved                                   Data in output file is stored in interleaved format, only valid with bitplane output file format.
-m, --mask [inverted]                               Data in output file is stored as a mask, only valid with bitplane output file format.
-d, --depth 1-8                                     Number of bitplane saved in the output file, only valid with bitplane, sprite or chunky output file format.
-c, --colors 1-256                                  Number of colors saved in the output file, only valid with palette output file format.
-x, --copper                                        Generate copper list, only valid with palette output file format.
-w, --width 16,32,64                                Width, only valid with sprite output file format.
-t, --controlword                                   Write control word, only valid with sprite output file format.
-a, --attached                                      Attach mode sprite, only valid with sprite output file format.
-n, --piccon                                        Use PicCon compatible color conversion for 4 bit palette, only valid with palette output file format.
```


### Examples:


```
amigeconv -f bitplane -d 8 font.png font.raw
amigeconv -f bitplane -m font.png font.raw
amigeconv -f chunky font.png font.chk
amigeconv -f palette -p pal8 font.png font.pal8
amigeconv -f sprite -t font.png font.spr
```

## Install

### For Linux, Mac & Windows:

[Download precompiled binary](https://github.com/tditlu/amigeconv/releases)
