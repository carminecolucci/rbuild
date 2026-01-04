# Each makefile executes with $(build)=dir.
# usage: $(MAKE) $(build)=dir
# this expands to: $(MAKE) -f scripts/build.mk obj=dir.
build := -f scripts/build.mk obj

clean := -f scripts/clean.mk obj

# filename of target with directory and extension stripped
basetarget = $(basename $(notdir $@))

# execute and print a command
# usage: $(call cmd,cc_o_c)
# cmd_cc_o_c is run, and quiet_cmd_cc_o_c is printed.
cmd = @$(cmd_$(1)); \
	$(if $($(quiet)cmd_$(1)),echo '  $($(quiet)cmd_$(1))')
