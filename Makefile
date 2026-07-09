# Project level Makefile.

# absolute path to project source
this_makefile := $(lastword $(MAKEFILE_LIST))
export rbuild := $(realpath $(dir $(this_makefile)))

# ====================================================
# project variables
export TARGET		:=
export SRC_DIR		:=
export LIB_DIR		:=
export SHLIB_DIR	:=
export INCLUDE_DIR	:=

# project level flags
ASFLAGS		:=
CFLAGS		:=
WARNINGS	:= all extra pedantic
CPPFLAGS	:=
LDFLAGS		:=

# project libraries
STATIC_LIBS :=
SHARED_LIBS :=

# Set to 1 for kernel, firmware and bare metal apps
# This changes the final link stage
export BARE_METAL ?= 0

ifneq ($(ARCH),)
  SRC_DIR  += arch/$(ARCH)
  LDSCRIPT := $(rbuild)/arch/$(ARCH)/linker.ld
  LDFLAGS += -T $(LDSCRIPT)
  include arch/$(ARCH)/Makefile
endif

AR	:= $(CROSS_COMPILE)ar
AS	:= $(CROSS_COMPILE)as
CC	:= $(CROSS_COMPILE)gcc
LD	:= $(CROSS_COMPILE)ld
CPP	:= $(CC) -E
RM	:= rm

# ====================================================

export AR AS CC CPP LD RM

ifeq ($(DEBUG),1)
  ASFLAGS	+= -g
  CFLAGS	+= -Og -g
endif

export ASFLAGS CFLAGS WARNINGS CPPFLAGS LDFLAGS

# default target
all:

# Disable builtin rules and variables. Don't print "Entering/Leaving directory"
MAKEFLAGS += -rR --no-print-directory

# `make V=1` for verbose output
ifeq ("$(origin V)", "command line")
  RBUILD_VERBOSE := $V
endif

quiet	:= quiet_
Q	:= @

ifeq ($(RBUILD_VERBOSE),1)
  quiet	:=
  Q	:=
endif

# remove all output if make -s (silent mode) is used
ifneq ($(findstring s,$(firstword -$(MAKEFLAGS))),)
  quiet	:= silent_
endif

export quiet Q

include $(rbuild)/scripts/include.mk

# Build a single directory `make path/to/dir/`.
# Descending in these directories is handled using
# `make $(build)=path/to/dir`
single-dirs	:= $(sort $(filter %/, $(MAKECMDGOALS)))

# Build a single target (e.g. `make path/to/file.s`).
single-targets	:= %.a %.i %.ld %.o %.s
single-files	:= $(sort $(filter $(single-targets), $(MAKECMDGOALS)))

single-build	:=
ifneq ($(strip $(single-dirs) $(single-files)),)
  single-build	:= 1
endif

ifneq ($(single-dirs),)

# Remove trailing slash to get real recursion targets
target-dirs := $(patsubst %/,%,$(single-dirs))

# dir/ -> dir
$(single-dirs): %/: %
	@:

endif	# single-dirs

ifneq ($(single-files),)

file-dirs := $(sort $(patsubst %/,%,$(dir $(single-files))))

# dir/file.o -> dir
$(single-files): $(file-dirs)
	@:

# descend and pass down only the appropriate files
.PHONY: $(file-dirs)
$(file-dirs):
	$Q$(MAKE) $(build)=$@ $(filter $@/%, $(MAKECMDGOALS))

endif	# single-files

ifndef single-build
# Other targets are handled here

target-objs	:= $(addsuffix /built-in.a, $(SRC_DIR))
target-libs	:= $(addsuffix /lib.a, $(LIB_DIR))

LIBS	:=
ifneq ($(STATIC_LIBS),)
  LIBS	+= -L$(LIB_DIR) $(addprefix -l,$(STATIC_LIBS))
endif

ifneq ($(SHARED_LIBS),)
  LIBS	+= -L$(SHLIB_DIR) $(addprefix -l,$(SHARED_LIBS))
endif

export LIBS

.PHONY: all
all: $(TARGET)

.PHONY: $(TARGET)
$(TARGET): $(target-objs) $(target-libs) $(LDSCRIPT) | $(SHLIB_DIR)
	$Q$(MAKE) $(link)=$@ prereqs="$(filter-out $(LDSCRIPT),$^)"

target-dirs	:= $(SRC_DIR) $(LIB_DIR) $(SHLIB_DIR)

# to build dir/built-in.a descend into dir
%/built-in.a: %
	@:

%/lib.a: %
	@:

clean-dirs := $(addprefix _clean_,$(target-dirs))

.PHONY: $(clean-dirs)
$(clean-dirs):
	$Q$(MAKE) $(clean)=$(patsubst _clean_%,%,$@)

.PHONY: clean
clean: $(clean-dirs)
	$Q$(RM) -f $(TARGET)

help:
	@echo ""
	@echo "Targets:"
	@echo "  all:               build all targets (default)"
	@echo "  dir/:              build all files in dir/"
	@echo "  dir/file.[aios]:   build specified target only"
	@echo "  help:              show this message"
	@echo "  clean:             remove all generated files"
	@echo ""
	@echo "Flags:"
	@echo "  V=[01]:"
	@echo "                     0 => quiet build (default)"
	@echo "                     1 => verbose build"
	@echo ""
	@echo "  DEBUG=1:           => debug build"
	@echo "  -s                 => silent build"

endif # single-build

# ===========================================================
# Descend into directory

.PHONY: $(target-dirs)
$(target-dirs):
	$Q$(MAKE) $(build)=$@

