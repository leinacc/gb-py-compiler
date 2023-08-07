# GBPY compiler + game

Based off https://github.com/ISSOtm/gb-starter-kit with some modifications:
* `header.asm` - inits GBC palettes and inits double speed mode
* `vectors.asm` - stat and timer interrupt does things now
* `Makefile` - new rules between `pycompiled/%.asm` and `data/%_mtiles.bin`
* `project.mk` - personal changes
* `src/include/defines.asm` - constants/structs from `; Python VM` and down

This project roughly shows how a subset of python could be used to write game logic. Rather than operate as a full interpreter, including lexing/parsing/etc, python code is compiled using python's (CPython 3.10.4) `compile(...)`, and then its bytecode and metadata is formatted into data that can be `INCLUDE`'d in an rgbasm source file.

## Controls

* Directions - move orthogonally only. If phase shifting, you can pass through walls / solid blocks
* B - select power. They all default to the 1st: phase shift (walk straight through walls if you can eventually reach a ground tile, eg try phasing through the wall below where you start)
* Select - cycle through powers (if they weren't all phase shift like right now)

## Notes

* The python-to-gb-compiler is `src/tools/gbcompiler.py`
* A virtual file system is created with `src/tools/genFileSystem.py`
* To try the sample engine, uncomment `jp ExampleSamplesTest` in `src/intro.asm`
* Python VM-related files start with `src/pyvm_`
* Rainbow VWF code is in `src/text_engine.asm`
* The 1st room has a button you can stand on to make a block non-solid (thus preventing phase shifting through it). This script is in `pyscripts/crypt_5_5.py`
* DMG is just not handled

## Building

* Requires python 3.10 with pypng installed
* Other than that, gb-starter-kit's README has the compile instructions:

### Compiling

Simply open you favorite command prompt / terminal, place yourself in this directory (the one the Makefile is located in), and run the command `make`. This should create a bunch of things, including the output in the `bin` folder.

While this project is able to compile under "bare" Windows (i.e. without using MSYS2, Cygwin, etc.), it requires PowerShell, and is sometimes unreliable. You should try running `make` two or three times if it errors out.

If you get errors that you don't understand, try running `make clean`. If that gives the same error, try deleting the `deps` folder. If that still doesn't work, try deleting the `bin` and `obj` folders as well. If that still doesn't work, you probably did something wrong yourself.

### See also

If you want something more barebones, check out [gb-boilerplate](https://github.com/ISSOtm/gb-boilerplate).

Perhaps [a gbdev style guide](https://gbdev.io/guides/asmstyle) may be of interest to you?

I recommend the [BGB](https://bgb.bircd.org) emulator for developing ROMs on Windows and, via Wine, Linux and macOS (64-bit build available for Catalina). [SameBoy](https://github.com/LIJI32/SameBoy) is more accurate, but has a much worse interface outside of macOS.
