cmake_minimum_required(VERSION 3.21)
project(rbff2 VERSION 0.1.0 LANGUAGES C CXX)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)

# The neogeorecomp toolkit: the in-tree copy (a submodule in a clean
# checkout), or a checkout next to this project.
if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/neogeorecomp/CMakeLists.txt)
    set(ng_default ${CMAKE_CURRENT_SOURCE_DIR}/neogeorecomp)
else()
    set(ng_default ${CMAKE_CURRENT_SOURCE_DIR}/../neogeorecomp)
endif()
set(NEOGEORECOMP_DIR ${ng_default} CACHE PATH "neogeorecomp checkout")
add_subdirectory(${NEOGEORECOMP_DIR} neogeorecomp_build)

# Your ROM files: the MAME "rbff2" set and the required "neogeo" system
# ROMs (sp-s2.sp1, sfix.sfix, sm1.sm1, 000-lo.lo), unzipped into one
# directory. Without this the player builds interpreter-only.
set(RBFF2_ROM_DIR "" CACHE PATH "Directory with your rbff2 and Neo Geo BIOS ROM files")
# Optional: entry points a previous run found at runtime (--dump-misses).
set(RBFF2_ENTRIES "${CMAKE_BINARY_DIR}/entries.txt" CACHE FILEPATH "Extra entry points for the recompiler")

# Stage 1: the generator.
add_executable(rbff2_recomp src/recomp_main.c src/game.c)
target_link_libraries(rbff2_recomp PRIVATE m68krecomp_core)
target_include_directories(rbff2_recomp PRIVATE src)

# Stage 2: the player, with the generated C when ROMs are available.
set(GAME_SOURCES src/main.c)
set(GEN_DIR ${CMAKE_BINARY_DIR}/generated)
set(GEN_FILES 16)
if(RBFF2_ROM_DIR)
    set(GEN_SOURCES ${GEN_DIR}/recomp_table.c)
    math(EXPR last "${GEN_FILES} - 1")
    foreach(i RANGE ${last})
        if(i LESS 10)
            list(APPEND GEN_SOURCES ${GEN_DIR}/recomp_0${i}.c)
        else()
            list(APPEND GEN_SOURCES ${GEN_DIR}/recomp_${i}.c)
        endif()
    endforeach()
    # The entry list starts empty; the `profile` target fills it from a
    # scripted play session and the next build regenerates with it.
    if(NOT EXISTS ${RBFF2_ENTRIES})
        file(WRITE ${RBFF2_ENTRIES} "")
    endif()
    file(MAKE_DIRECTORY ${GEN_DIR})
    add_custom_command(
        OUTPUT ${GEN_SOURCES} ${GEN_DIR}/recomp_common.h
        COMMAND rbff2_recomp --rom-path ${RBFF2_ROM_DIR} --out ${GEN_DIR} --files ${GEN_FILES}
                --entries ${RBFF2_ENTRIES}
        DEPENDS rbff2_recomp ${RBFF2_ENTRIES}
        COMMENT "Recompiling Real Bout Fatal Fury 2 from ${RBFF2_ROM_DIR}")
    list(APPEND GAME_SOURCES ${GEN_SOURCES})
endif()

add_executable(rbff2 ${GAME_SOURCES} src/game.c)
set_target_properties(rbff2 PROPERTIES OUTPUT_NAME "RBFF2")
target_link_libraries(rbff2 PRIVATE neogeorecomp)
target_include_directories(rbff2 PRIVATE src ${GEN_DIR})
if(RBFF2_ROM_DIR)
    add_custom_target(profile
        COMMAND rbff2 --headless --rom-path ${RBFF2_ROM_DIR} --frames 6000 --dump-misses ${RBFF2_ENTRIES}
        COMMAND rbff2 --headless --rom-path ${RBFF2_ROM_DIR} --frames 22000
                --input ${CMAKE_CURRENT_SOURCE_DIR}/tests/play_long.txt --dump-misses ${RBFF2_ENTRIES}
        DEPENDS rbff2
        COMMENT "Profiling a scripted session for runtime-only entry points")
    target_compile_definitions(rbff2 PRIVATE RBFF2_HAVE_RECOMP)
    if(MSVC)
        # Generated routines are large; /bigobj lifts the section limit.
        # /O1 avoids MSVC's superlinear optimizer blow-up on these giant
        # dispatch functions.  /Ob1 keeps the small static-inline bus/flag
        # helpers in cpu.h inlined but stops MSVC from trying to inline the
        # generated routines into each other, which is what makes /Ob2 take
        # tens of minutes per translation unit on a 5 MB program.
        set_source_files_properties(${GEN_SOURCES} PROPERTIES COMPILE_OPTIONS "/bigobj;/O1;/Ob1")
    else()
        # GCC/Clang: -O2 keeps the giant dispatch functions tractable; -O3
        # is superlinear on them and gains little for this kind of code.
        set_source_files_properties(${GEN_SOURCES} PROPERTIES COMPILE_OPTIONS "-O2")
    endif()
endif()
if(MSVC)
    target_compile_definitions(rbff2 PRIVATE _CRT_SECURE_NO_WARNINGS)
    target_compile_definitions(rbff2_recomp PRIVATE _CRT_SECURE_NO_WARNINGS)
endif()

# Ship the SDL2 DLL (when the window is built) next to the executable.
if(WIN32 AND TARGET SDL2::SDL2)
    add_custom_command(TARGET rbff2 POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different $<TARGET_RUNTIME_DLLS:rbff2> $<TARGET_FILE_DIR:rbff2>
        COMMAND_EXPAND_LISTS)
endif()
