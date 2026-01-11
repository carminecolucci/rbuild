# This makefile is included in the project level Makefile.
# It defines all the variables and rules used to clean.

ifndef obj
  $(error clean.mk: target obj not specified)
endif

src := $(obj)

# default target
clean-all:

# ================ User available variables ================
objs	:=
libs	:=
shlibs	:=

include $(rbuild)/scripts/include.mk

# include subdir makefile
include $(src)/Makefile

shobjs	:= $(foreach shlib,$(shlibs), $($(shlib:.so=-objs)))
objs	+= $(shobjs)

# add path prefix
objs	:= $(addprefix $(obj)/, $(objs))
libs	:= $(addprefix $(obj)/, $(libs))
shlibs	:= $(addprefix $(obj)/, $(shlibs))

# get subdirectories to descend into
subdir := $(patsubst %/,%, $(filter %/, $(objs) $(libs)))

ifneq ($(strip $(objs)),)
  target-obj := $(obj)/built-in.o
endif

ifneq ($(strip $(libs)),)
  target-lib := $(obj)/lib.a
endif

# remove dir/ from objs and libs. Subdirectories are cleaned directly with `subdir` target.
objs := $(filter-out %/, $(objs))
libs := $(filter-out %/, $(libs))

deps := $(patsubst %.o,%.d, $(objs) $(libs))
clean-files := $(target-obj) $(target-lib) $(objs) $(libs) $(shlibs) $(deps)

quiet_cmd_clean_all = CLEAN   $(obj)
      cmd_clean_all = $(RM) -rf $(clean-files)

.PHONY: clean-all
clean-all: $(subdir)
	$(call cmd,clean_all)

.PHONY: $(subdir)
$(subdir):
	$Q$(MAKE) $(clean)=$@

