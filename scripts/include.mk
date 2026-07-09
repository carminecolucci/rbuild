# Each makefile executes with $(build)=dir.
# usage: $(MAKE) $(build)=dir
# this expands to: $(MAKE) -f $(rbuild)/scripts/build.mk obj=dir.
build := -f $(rbuild)/scripts/build.mk obj

clean := -f $(rbuild)/scripts/clean.mk obj

link  := -f $(rbuild)/scripts/target.mk target

# filename of target with directory and extension stripped
basetarget = $(basename $(notdir $@))

# print and execute a command
# usage: $(call cmd,cc_o_c)
# prints quiet_cmd_cc_o_c and runs cmd_cc_o_c.
cmd = @$(if $(cmd_$(1)), set -e; $(if $($(quiet)cmd_$(1)), echo '  $($(quiet)cmd_$(1))';) $(cmd_$(1)), :)

# flags shared between different makefiles
as_flags	= $(DEPSFLAGS) $(INCLUDES) $(CPPFLAGS) $(ASFLAGS) $(SUBDIR_ASFLAGS) $(asflags) $(asflags-$(basetarget))
cc_flags	= $(DEPSFLAGS) $(INCLUDES) $(CPPFLAGS) $(CFLAGS) $(SUBDIR_CCFLAGS) $(ccflags) $(ccflags-$(basetarget))
cpp_flags	= $(DEPSFLAGS) $(INCLUDES) $(CPPFLAGS) $(cppflags)
ld_flags	= $(LDFLAGS) $(ldflags)

