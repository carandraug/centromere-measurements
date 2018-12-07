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

function mask = get_dapi_mask (dapi)
  se_2d = strel ("disk", 3, 0);
  se_3d = strel ("arbitrary", repmat (getnhood (se_2d), [1 1 3]));

  ## XXX: there's an issue with the data in that the first column is
  ## rubish, so remove it.  Need to ivestigate the issue in the
  ## camera.
  dapi(:,1,:,:) = 0;

  mask = im2bw (imdilate (dapi, se_3d), graythresh (dapi(:)));
  mask = bwfill (mask, "holes", 8);
  mask = reshape (mask, size (dapi));

endfunction

function [rv] = main (argv)

  if (numel (argv) != 3)
    error ("usage: nuclei-mask.m DAPI_CHANNEL IMG_FPATH MASK_FPATH");
  endif

  dapi_channel = str2double (argv{1});
  in_fpath = argv{2};
  mask_fpath = argv{3};

  if (isnan (dapi_channel))
    error ("nucleus_mask: invalid DAPI_CHANNEL number");
  elseif (fix (dapi_channel) != dapi_channel)
    error ("nucleus_mask: DAPI_CHANNEL must be an integer");
  endif

  dapi = read_dv_channel (in_fpath, dapi_channel);
  mask = get_dapi_mask (dapi);

  imwrite (mask, mask_fpath);

  rv = 0;
endfunction

main (argv ());
