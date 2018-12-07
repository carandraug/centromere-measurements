## Copyright (C) 2018 David Miguel Susano Pinto <david.pinto@bioch.ox.ac.uk>
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, see <http://www.gnu.org/licenses/>.

## FORCE_MAKE is used as dependency that is never built to keep a target
## always out of date.  This is used to leave the finding of dependencies
## and deciding for out of date up to latexmk (see latexmk man page)

##
## Environment variables and target alias.
##

OCTAVE ?= octave
OCTAVE_FLAGS := --path lib-octave/

DV_FILES =
include data/cenp-c.mk

## Channel number where to perform the measurements
MEASURE_CHANNEL = 1
## Channel number used for the masks for the measurement / reference (CENP-B)
CENTROMERE_CHANNEL = 2
## Channel number used for for nuclei mask (DAPI)
NUCLEI_CHANNEL = 3


NUCLEI_MASK_FILES = $(patsubst %.dv, %-nuclei-mask.tif, $(DV_FILES))

CENTROMERE_MASK_FILES = $(patsubst %.dv, %-centromere-mask.tif, $(DV_FILES))

nuclei_mask: $(NUCLEI_MASK_FILES)

centromere_mask: $(CENTROMERE_MASK_FILES)

%-nuclei-mask.tif: %.dv
	$(OCTAVE) $(OCTAVE_FLAGS) src/nuclei-mask.m \
	  $(NUCLEI_CHANNEL) $^ $@

%-centromere-mask.tif: %-nuclei-mask.tif %.dv
	$(OCTAVE) $(OCTAVE_FLAGS) src/centromere-mask.m \
	  $(CENTROMERE_CHANNEL) $^ $@
