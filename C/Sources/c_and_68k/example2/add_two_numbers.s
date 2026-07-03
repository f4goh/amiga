
    XDEF    _add_two_numbers
_add_two_numbers:
        move.l 4(sp),d0
        add.l  8(sp),d0
        rts


