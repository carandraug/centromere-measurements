#!/usr/bin/env octave

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

pkg load image;

function [centromere_mask] = get_centromeres (im, nuclei_mask)
  if (! isinteger (im))
    ## we could just use abs() but if data is floating point, but we
    ## know it shouldn't be so just error.
    error ("data is not integer class");
  endif

  bw = im2bw (im, graythresh (im(nuclei_mask)));
  im(! bw | ! nuclei_mask) = 0;
  imc = imcomplement (im);
  w_lines = ! watershed (imc);
  im(w_lines) = 0;
  centromere_mask = bwareaopen (logical (im), 10);
endfunction

function [rv] = main (argv)

  if (numel (argv) != 4)
    error ("usage: centromere-mask.m FOCI_CHANNEL NUCLEI_MASK_FPATH IMG_FPATH CENTRMERE");
  endif

  centromere_channel = str2double (argv{1});
  nuclei_mask_fpath = argv{2};
  img_fpath = argv{3};
  centromere_mask_fpath = argv{4};

  if (isnan (centromere_channel))
    error ("centromere-mask: invalid CENTROMERE_CHANNEL number");
  elseif (fix (centromere_channel) != centromere_channel)
    error ("centromere-mask: FOCI_CHANNEL must be an integer");
  endif

  nuclei_mask = imread (nuclei_mask_fpath, "index", "all");
  centromeres = read_dv_channel (img_fpath, centromere_channel);
  if (! size_equal (nuclei_mask, centromeres))
    error ("centromere-mask: NUCLEI_MASK and IMG are images of different sizes");
  endif

  centromere_mask = get_centromeres (centromeres, nuclei_mask);

  imwrite (centromere_mask, centromere_mask_fpath);

  rv = 0;
  return;
endfunction

main (argv ());
