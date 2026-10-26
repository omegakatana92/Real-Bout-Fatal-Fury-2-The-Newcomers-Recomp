/*
 * main.c - the Real Bout Fatal Fury 2 player.
 *
 * Everything hardware-related lives in neogeorecomp.  This file hands the
 * runtime the ROM layout and the table of routines rbff2_recomp generated
 * from the user's own dump at build time (never committed).
 */
#include "game.h"

#ifdef RBFF2_HAVE_RECOMP
extern const ng_func_entry_t ng_recomp_table[];
extern const size_t ng_recomp_count;
#endif

int main(int argc, char **argv) {
#ifdef RBFF2_HAVE_RECOMP
    return ng_main(argc, argv, &k_rbff2, ng_recomp_table, ng_recomp_count);
#else
    return ng_main(argc, argv, &k_rbff2, NULL, 0);
#endif
}
