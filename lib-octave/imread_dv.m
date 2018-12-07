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

## Read DV files (single z stack only).
##
## There's no reason why it couldn't read multi channel and multi time
## but at the time we don't need it and would complicate how we return
## things.
##
## Requires bioformats package to be loaded.

function img = imread_dv (fpath, channel_n)
  if (nargin != 2)
    print_usage ();
  endif

  reader = bfGetReader (fpath);

  metadata = reader.getCoreMetadataList().get(0); # dv files only have one serie
  if (metadata.sizeT > 1)
    error ("this does not read time-series");
  elseif (channel_n > metadata.sizeC)
    error ("channel number '%i' greater than number of channels '%i'",
           channel_n, metadata.sizeC)
  endif

  get_plane_number = @(z) 1 + reader.getIndex (z-1, channel_n-1, 0);

  img = bfGetPlane (reader, get_plane_number (1));
  img = postpad (img, metadata.sizeZ, 0, 4);
  for p_idx = 2:metadata.sizeZ
    img(:,:,:,p_idx) = bfGetPlane (reader, get_plane_number (p_idx));
  endfor
endfunction
