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

## Read DV files.
##
## Data is always returned in [y x z channel time] order.
##
## Not using bioformats because we get random crashes and hangs

function img = imread_dv (fpath, channel_n)
  if (nargin != 1)
    print_usage ();
  endif

  info = dir (fpath);
  if (isempty (info))
    error ("failed to stat '%s'", fpath);
  elseif (info.bytes < 1024)
    error ("file is smaller than 1024 bytes, the smallest MRC header possible");
  endif

  [fid, msg] = fopen (fpath, "rb");
  if (fid < 0)
    error ("failed to fopen '%s': %s", fpath, msg);
  endif

  ## confirm it's a DV file and identify byte order
  magic_number = fread_at (fid, 96, 1, "int16", "n");
  switch (magic_number)
    case (-16224), arch = "ieee-le";
    case (-24384), arch = "ieee-be";
    otherwise, error ("no valid magic number - not a DV file");
  endswitch

  ## Read the metadata. We are only interested in image size (to
  ## reshape the array, extended header size (to skip), and data
  ## precision.
  isize = fread_at (fid, 0, 3, "int32", arch);

  magic_precision = fread_at (fid, 12, 1, "int32", arch);
  switch (magic_precision)
    ## there are other types but they don't make sense for us
    case (0), dtype = "uint8";
    case (1), dtype = "int16";  % IW_SHORT - 2-byte signed integer
    case (2), dtype = "single";
    case (5), dtype = "int16";  % IW_EMTOM - 2-byte signed integer
    case (6), dtype = "uint16";
    case (7), dtype = "int32";
    otherwise, error ("invalid pixel data type '%d'", magic_precision);
  endswitch

  n_timepoints = fread_at (fid, 180, 1, "int16", arch);
  n_channels = fread_at (fid, 196, 1, "int16", arch);
  n_zslices = isize(3) / (n_timepoints * n_channels);

  img_sequence = fread_at (fid, 182, 1, "int16", arch);
  switch (img_sequence)
    case (0), isize(3:5) = [n_zslices n_timepoints n_channels]; # ZTW
    case (1), isize(3:5) = [n_channels n_zslices, n_timepoints]; # WZT
    case (2), isize(3:5) = [n_zslices n_channels n_timepoints]; # ZWT
    otherwise, error ("imread_dv: unknown IMG_SEQUENCE '%d'", img_sequence);
  endswitch

  if (img_sequence != 2) # ZWT
    ## We could add support but why have the work if they are all ZWT ordered
    error ("imread_dv: only ZWT sequence order is supported");
  endif

  ext_h_size = fread_at (fid, 92, 1, "int32", arch);
  data_start = 1024 + ext_h_size; # 1024 is the size of the standard header

  npixels = prod (isize);
  img = fread_at (fid, data_start, npixels, ["*" dtype], arch);

  ## note that on file, array is on row major order and from bottom to top.
  img = rotdim (reshape (img, isize(:).'), 1, [1 2]);

endfunction


function [data] = fread_at (fid, offset, size, precision, arch)
  if (fseek (fid, offset, "bof"))
    error ("failed to fseek");
  endif
  [data, count] = fread (fid, size, precision, arch);
  if (count != size)
    error ("did not read enough elements");
  endif
endfunction
