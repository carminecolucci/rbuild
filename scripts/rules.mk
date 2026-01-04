# build rules

# ==========================================================
# C files
# .c -> .s
quiet_cmd_cc_s_c = CC      $@
cmd_cc_s_c = $(CC) -o $@ $(cc_flags) -fverbose-asm -S $<

$(obj)/%.s: $(src)/%.c
$(call cmd,cc_s_c)

# .c -> .o
quiet_cmd_cc_o_c = CC      $@
      cmd_cc_o_c = $(CC) -o $@ $(cc_flags) -c $<

$(obj)/%.o: $(src)/%.c
	$(call cmd,cc_o_c)

# .c -> position independent .o
quiet_cmd_cc_shobj_c = CC      $@
      cmd_cc_shobj_c = $(CC) -o $@ -fPIC $(cc_flags) -c $<

$(shobjs): $(obj)/%.o: $(src)/%.c
	$(call cmd,cc_shobj_c)

# ==========================================================
# Assembly files
# .s -> .o
quiet_cmd_cc_o_s = AS      $@
      cmd_cc_o_s = $(AS) -o $@ $(as_flags) $<

$(obj)/%.o: $(src)/%.s
	$(call cmd,cc_o_s)

# .S -> .o
quiet_cmd_cc_o_S = CC      $@
      cmd_cc_o_S = $(CC) -o $@ $(as_flags) -c $<

$(obj)/%.o: $(src)/%.S
	$(call cmd,cc_o_S)

# .S -> .s
quiet_cmd_cpp_s_S = CPP     $@
      cmd_cpp_s_S = $(CPP) -o $@ $(as_flags) $<

$(obj)/%.s: $(src)/%.S
	$(call cmd,cpp_s_S)

# ==========================================================
# Object files

ifdef target-obj
# Link objects into built-in.o:
quiet_cmd_ld_o_o = LD      $@
      cmd_ld_o_o = $(LD) -o $@ -r $(ld_flags) $^

.PHONY: $(target-obj)
$(target-obj): $(objs) $(subdir-target-objs)
	$(call cmd,ld_o_o)
endif # target-obj

ifdef target-lib
# Link objects into lib.a:
quiet_cmd_ar_a_o = AR      $@
      cmd_ar_a_o = $(RM) -f $@; $(AR) rcsTP $@ $^

.PHONY: $(target-lib)
$(target-lib): $(libs) $(subdir-target-libs)
	$(call cmd,ar_a_o)
endif # target-lib

# Link position independent objects in a shared library
# .o -> .so
quiet_cmd_ld_so_o = LD      $@
      cmd_ld_so_o = $(CC) -o $@ -shared $(addprefix $(obj)/,$($(@F:.so=-objs)))

$(shlibs): $(obj)/%: $(shobjs)
	$(call cmd,ld_so_o)

