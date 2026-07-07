ifndef target
  $(error target.mk: target not specified)
endif

# default target
build-all:

include $(rbuild)/scripts/include.mk


.PHONY: build-all
build-all: $(target)
	@:

# link final target
ifeq ($(BARE_METAL),1)
  # os / firmware
  quiet_cmd_link_target = LD      $@
        cmd_link_target = $(LD) $(ld_flags) -o $@ \
                          --whole-archive $(filter %built-in.a, $(prereqs)) --no-whole-archive \
                          --start-group $(filter %lib.a, $(prereqs)) $(LIBS) --end-group
else
  # hosted applications
  RPATH := -Wl,-rpath,$(SHLIB_DIR)

  quiet_cmd_link_target = CC      $@
        cmd_link_target = $(CC) $(cc_flags) $(ld_flags) -o $@ \
                          -Wl,--whole-archive $(filter %built-in.a, $(prereqs)) -Wl,--no-whole-archive \
                          -Wl,--start-group $(filter %lib.a, $(prereqs)) $(LIBS) -Wl,--end-group \
                          $(if $(SHLIB_DIR),$(RPATH))
endif


$(target):
	$(call cmd,link_target)

