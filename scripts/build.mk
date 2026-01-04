# This makefile is included in the project level Makefile.
# It defines all the variables and rules used to compile.

ifndef obj
  $(error build.mk: target obj not specified)
endif

src := $(obj)

# default target
build-all:

# ==========================================================
# User available variables
objs		:=
libs		:=
shlibs		:=

# User available flags
# flags used for the current directory
asflags		:=
ccflags		:=
cppflags	:=
ldflags		:=

# flags applied to the current directory and to every subdirectory
subdir-asflags	:=
subdir-ccflags	:=
# ==========================================================

include scripts/include.mk

# include directory Makefile
include $(src)/Makefile

# Flags
# ==========================================================
DEPSFLAGS	:= -MD -MMD
INCLUDES	:= $(addprefix -I,$(INCLUDE_DIR))
CFLAGS		:= $(addprefix -W,$(WARNINGS)) $(CFLAGS)

# ==========================================================
# flags used to make rules are combined in the following order:
#	- project level flags
#	- subdirectory flags
#	- current directory flags
#	- file specific flags

# export subdir specific flags to make them available in subdirectories
export SUBDIR_ASFLAGS := $(SUBDIR_ASFLAGS) $(subdir-asflags)
export SUBDIR_CCFLAGS := $(SUBDIR_CCFLAGS) $(subdir-ccflags)

as_flags	 = $(INCLUDES) $(ASFLAGS) $(SUBDIR_ASFLAGS) $(asflags) $(asflags-$(basetarget))
cc_flags	 = $(DEPSFLAGS) $(INCLUDES) $(CFLAGS) $(SUBDIR_CCFLAGS) $(ccflags) $(ccflags-$(basetarget))
cpp_flags	:= $(DEPSFLAGS) $(INCLUDES) $(cppflags)
ld_flags	:= $(LDFLAGS) $(ldflags)

# =============================================================

# get subdirectories to descend into
subdir	:= $(patsubst %/,%, $(filter %/, $(objs) $(libs)))

# replace each occurrence of dir/ with dir/built-in.o or dir/lib.a
objs	:= $(patsubst %/,%/built-in.o, $(objs))
libs	:= $(patsubst %/,%/lib.a, $(libs))

# get shared objects for each dynamic library
shobjs	:= $(foreach shlib,$(shlibs), $($(shlib:.so=-objs)))

# add path prefix
objs	:= $(addprefix $(obj)/, $(objs))
libs	:= $(addprefix $(obj)/, $(libs))
shlibs	:= $(addprefix $(obj)/, $(shlibs))
subdir	:= $(addprefix $(obj)/, $(subdir))
shobjs	:= $(addprefix $(obj)/, $(shobjs))

# get subdir targets
subdir-target-objs	:= $(filter %/built-in.o, $(objs))
subdir-target-libs	:= $(filter %/lib.a, $(libs))

# ===========================================================
# all objects in `objs` are compiled into a single built-in.o
ifneq ($(strip $(objs)),)
  target-obj := $(obj)/built-in.o
endif

# all objects in `libs` are compiled into a single lib.a
ifneq ($(strip $(libs)),)
  target-lib := $(obj)/lib.a
endif
# ===========================================================

.PHONY: build-all
build-all: $(target-obj) $(target-lib) $(shlibs)
	@:

include scripts/rules.mk

# Descend into subdirectories:
# ======================================

# Descend into subdirectories to make built-in.o and lib.a targets
.PHONY: $(subdir-target-objs) $(subdir-target-libs)
$(subdir-target-objs) $(subdir-target-libs): $(subdir)

.PHONY: $(subdir)
$(subdir):
	$Q$(MAKE) $(build)=$@
# ======================================

# Include dependency files
deps := $(objs:.o=.d)
-include $(deps)

