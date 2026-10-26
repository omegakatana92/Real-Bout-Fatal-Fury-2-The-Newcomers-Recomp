/*
 * game.c - the Real Bout Fatal Fury 2 (NGH-240, MAME set "rbff2") ROM set,
 * shared by the player and the generator so both load the program
 * identically.
 *
 * Layout verified against MAME's neogeo.cpp (ROM_START( rbff2 ), MVS
 * version) and the hashes of the supplied archive.  The 5 MB program is the
 * 1 MB fixed bank (240-p1.p1) followed by a 4 MB banked image
 * (240-p2.sp2); both files are stored byte-swapped.  The cart uses the
 * standard 1 MB bank window, not a protection/decryption chip.
 */
#include "game.h"

const ng_game_t k_rbff2 = {
    .name = "rbff2",
    .title = "Real Bout Fatal Fury 2 - The Newcomers",
    .prom_size = 0x500000,
    .prom = {
        {"240-p1.p1", 0x000000, 0x000000, 0x100000, 1},
        {"240-p2.sp2", 0x000000, 0x100000, 0x400000, 1},
    },
    .crom_size = 0x3000000,
    .crom_pairs = {
        {"240-c1.c1", "240-c2.c2"},
        {"240-c3.c3", "240-c4.c4"},
        {"240-c5.c5", "240-c6.c6"},
    },
    .srom = "240-s1.s1",
    .m1 = "240-m1.m1",
    .vrom = {"240-v1.v1", "240-v2.v2", "240-v3.v3", "240-v4.v4"},
};
