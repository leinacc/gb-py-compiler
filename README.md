# GBPY compiler + game

Based off https://github.com/ISSOtm/gb-starter-kit with some modifications:
* `header.asm` - inits GBC palettes and inits double speed mode
* `vectors.asm` - stat and timer interrupt does things now
* `Makefile` - new rules between `pycompiled/%.asm` and `data/%_mtiles.bin`
* `project.mk` - personal changes

This project roughly shows how a subset of python could be used to write game logic. Rather than operate as a full interpreter, including lexing/parsing/etc, python code is compiled using python's (CPython 3.10.4) `compile(...)`, and then its bytecode and metadata is formatted into data that can be `INCLUDE`'d in an rgbasm source file.

## Building

* Requires python 3.10 with pypng installed
* Other than that, gb-starter-kit's README has the compile instructions:

## Compiling

Simply open you favorite command prompt / terminal, place yourself in this directory (the one the Makefile is located in), and run the command `make`. This should create a bunch of things, including the output in the `bin` folder.

While this project is able to compile under "bare" Windows (i.e. without using MSYS2, Cygwin, etc.), it requires PowerShell, and is sometimes unreliable. You should try running `make` two or three times if it errors out.

If you get errors that you don't understand, try running `make clean`. If that gives the same error, try deleting the `deps` folder. If that still doesn't work, try deleting the `bin` and `obj` folders as well. If that still doesn't work, you probably did something wrong yourself.

## See also

If you want something more barebones, check out [gb-boilerplate](https://github.com/ISSOtm/gb-boilerplate).

Perhaps [a gbdev style guide](https://gbdev.io/guides/asmstyle) may be of interest to you?

I recommend the [BGB](https://bgb.bircd.org) emulator for developing ROMs on Windows and, via Wine, Linux and macOS (64-bit build available for Catalina). [SameBoy](https://github.com/LIJI32/SameBoy) is more accurate, but has a much worse interface outside of macOS.
