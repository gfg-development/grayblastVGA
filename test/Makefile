# The toplevel Makefile to build all different tests
#
# -----------------------------------------------------------------------------
#
# Copyright (c) 2024 Gerrit Grutzeck (g.grutzeck@gfg-development.de)
# SPDX-License-Identifier: Apache-2.0
#
# -----------------------------------------------------------------------------
#
# Author   : Gerrit Grutzeck g.grutzeck@gfg-development.de
# File     : Makefile
# Create   : Mai 14, 2024
# Revise   : Mai 14, 2024
# Revision : 1.0
#
# -----------------------------------------------------------------------------

TOPTARGETS := all clean


ifneq ($(GATES),yes)

SUBDIRS := $(wildcard */.)

else

SUBDIRS := toplevel

endif

$(TOPTARGETS): $(SUBDIRS)
$(SUBDIRS):
	$(MAKE) -C $@ $(MAKECMDGOALS)

.PHONY: $(TOPTARGETS) $(SUBDIRS)
