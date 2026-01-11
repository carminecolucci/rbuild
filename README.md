# Rbuild

**Rbuild** is a lightweight, Makefile-based build system inspired by the Linux Kernel **Kbuild**.

## Objectives

Its goal is to make large, hierarchical C projects easy to manage by:

- letting each directory describe only its own files,

- building everything via recursive `make` in a controlled and predictable way,

- and supporting **single-target builds** such as:
  ```bash
  make src/module/
  make src/module/foo.o
  ```

Each directory has its own Makefile, describing the objects and libraries it builds and which subdirectories it contains.

## File layout

A typical Rbuild project follows this layout:

```bash
project/
├─── include/   # contains all the header files.
├─── lib/       # (optional) used for static and dynamic libraries.
├─── scripts/   # contains Rbuild Makefiles to build the project.
├─── src/       # contains the project source code.
└─── Makefile   # top level Makefile
```

## Get started

In the top level Makefile, set the following variables:


```make
export TARGET		:= main
export SRC_DIR		:= src
export LIB_DIR		:= lib
export SHLIB_DIR	:= lib
export INCLUDE_DIR	:= include
```

`TARGET` is the name of the final executable.

`LIB_DIR` (optional) static libraries directory.

`SHLIB_DIR` (optional) shared libraries directory. It can be different from `LIB_DIR`.

## Variables

Each directory that contains source code gets its own Makefile. Each Makefile is only responsile for building objects in its directory.

There are two user available variables to tell Rbuild which files to produce:

- `objs`: all objects added here are combined in a single `built-in.o` for that directory.

- `libs`: all objects added here are combined in a single `lib.a` for that directory. The use of this variable should be restricted to `LIB_DIR`.

Subdirectories can be added to both variables to tell Rbuild to descend in them and look for a Makefile.

### Example

```bash
project/
├── include/
│   ├── amazing_lib.h
│   ├── file1.h
│   ├── libcool/file2.h
│   └── module/file3.h
├── src/
│   ├── Makefile
│   ├── main.c
│   ├── file1.c
│   └── module/
│       ├── Makefile
│       └── file3.c
└── lib/
    ├── Makefile
    │   ├── amazing_lib.c
    │   ├── helper.c
    │   └── helper.h
    └── libcool/
        ├── Makefile
        └── file2.c

```

- `src/Makefile`:

    ```make
    objs += main.o file1.o module/
    ```

- `src/module/Makefile`:

    ```make
    objs += file3.o
    ```

- `libs/Makefile`:

    ```make
    libs += amazing_lib.o helper.o libcool/
    ```

- `libs/libcool/Makefile`:

    ```make
    libs += file2.o
    ```

## Shared Libraries

To create a shared library, use `shlibs` to specify the library name. Then, use `<libname>-objs` to specify the objects it needs. To link it, add the library to `SHARED_LIBS` in the project level Makefile.

- `Makefile`:

    ```make
    SHARED_LIBS := foo
    ```

- `lib/Makefile`:

    ```make
    shlibs += libfoo.so
    libname-objs := bar.o baz.o
    ```

## Existing libraries

To add existing static or dynamic libraries **not** in `$PATH`, simply place them in `LIB_DIR`/`SHLIB_DIR`.

To link the libraries, add them to `STATIC_LIBS`/`SHARED_LIBS` in the project level Makefile.

## Flags

### Project level flags

`ASFLAGS`, `CFLAGS`, `WARNINGS`, `LDFLAGS` can be set directly in the project level Makefile. They are applied to the whole project.

Warnings must be specified without the `-W` prefix, it will be added automatically.
```make
CFLAGS   := -std=c99
WARNINGS := all extra
```

### Current directory flags

`asflags`, `ccflags`, `cppflags`, `ldflags` are used to set additional flags to the assembler, compiler, preprocessor and linker, respectively. These flags are applied only to the current directory of the Makefile.

```make
ccflags += -O2
```

### Subdir flags

`subdir-asflags`, `subdir-ccflags` set additonal flags to the assembler and compiler, respectively. These flags are applied in the current directory of the Makefile and in every subdirectory.

### File specific flags

`asflags-<file>` and `ccflags-<file>` can be used to set file specific flags for the assembler and the compiler, respectively. These flags are only applied to the corresponding source file. Example:

```make
objs += file1.o file2.o
ccflags-file1 := -Wshadow -DDEBUG
asflags-file2 := -march=armv8-a
```

