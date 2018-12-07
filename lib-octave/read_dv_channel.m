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

function [channel] = read_dv_channel (fpath, channel_n)
  if (nargin != 2)
    print_usage ();
  elseif (channel_n != fix (channel_n))
    error ("read_dv_channel: CHANNEL_N must be an integer");
  endif
  im = imread_dv (fpath);

  if (channel_n > size (im, 4))
    error ("read_dv_channel: CHANNEL_N '%d' greater than total channels '%d'",
           channel_n, size (im, 4));
  elseif (size (im, 5) != 1)
    error ("read_dv_channel: multi timepoints are not supported");
  endif

  channel = im(:,:,:,channel_n,1);
  channel = reshape (channel, [rows(im) columns(im) 1 size(im, 3)]);
endfunction
