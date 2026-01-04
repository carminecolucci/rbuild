# Project level Makefile.

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
ifneq ($(findstring s,$(MAKEFLAGS)),)
  quiet	:= silent_
endif

export quiet Q RBUILD_VERBOSE

include scripts/include.mk

# project variables
# ====================================================
export TARGET		:=
export SRC_DIR		:= src
# export LIB_DIR		:= lib
# export SHLIB_DIR	:= lib
export INCLUDE_DIR	:= include

AR	:= ar
AS	:= as
CC	:= gcc
CPP	:= $(CC) -E
LD	:= ld
RM	:= rm

export AR AS CC CPP LD RM

# project level flags
# ====================================================
ASFLAGS		:=
CFLAGS		:=
WARNINGS	:= all extra pedantic
LDFLAGS		:=

ifeq ($(DEBUG),1)
  ASFLAGS	+= -g
  CFLAGS	+= -Og
endif

export ASFLAGS CFLAGS WARNINGS LDFLAGS

# project libraries
# ====================================================
STATIC_LIBS :=
SHARED_LIBS :=
# ====================================================

.PHONY: all
all: $(TARGET)

LIBS	:=
ifneq ($(STATIC_LIBS),)
  LIBS	+= -L$(LIB_DIR) $(addprefix -l,$(STATIC_LIBS))
endif

ifneq ($(SHARED_LIBS),)
  LIBS	+= -L$(SHLIB_DIR) $(addprefix -l,$(SHARED_LIBS))
endif

target-objs	:= $(addsuffix /built-in.o, $(SRC_DIR))
target-libs	:= $(addsuffix /lib.a, $(LIB_DIR))

quiet_cmd_cc_target = CC      $@
      cmd_cc_target = $(CC) -o $@ $(LDFLAGS) -Wl,--start-group $(target-libs) $(target-objs) $(LIBS) -Wl,--end-group -Wl,-rpath,$(SHLIB_DIR)


target-dirs	:= $(SRC_DIR) $(LIB_DIR) $(SHLIB_DIR)

.PHONY: $(TARGET)
$(TARGET): $(target-dirs)
	$(call cmd,cc_target)

.PHONY: $(target-dirs)
$(target-dirs):
	$Q$(MAKE) $(build)=$@

clean-dirs := $(addprefix clean_,$(target-dirs))

$(clean-dirs):
	$Q$(MAKE) $(clean)=$(patsubst clean_%,%,$@)
	$Q$(RM) -f $(TARGET)

.PHONY: clean
clean: $(clean-dirs)

help:
	@echo ""
	@echo "Targets:"
	@echo "  all:    build all targets (default)"
	@echo "  $(TARGET):   build the project"
	@echo "  help:   show this message"
	@echo "  clean:  remove all generated files"
	@echo ""
	@echo "Flags:"
	@echo "  V=[01]:"
	@echo "          0 => quiet build (default)"
	@echo "          1 => verbose build"
	@echo ""
	@echo "  DEBUG=1   => debug build"
	@echo "  -s        => silent build"

