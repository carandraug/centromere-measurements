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

## Compute threshold value using triangle method adapted for
## fluorescence microscopy.
##
## The algorithm was designed for "normal" light microscopy images
## where the histogram has a high peak for pixels of white intensity
## and the part of interest is the long tail after the peak.
##
## Our histogram is the other way around (note that on the publication
## they put white on the left though), which is the adaptation that we
## do.
##
## See discussion of the algorithm at
## http://forum.imagej.net/t/understanding-imagej-implementation-of-the-triangle-algorithm-for-threshold/752/7
##
## TODO this should be done in the Image package
##
## FIXME this does not return the same threshold values as ImageJ.
##       Not sure what is causing the difference though.  But the
##       different threshold values seem to work even better for our
##       images.

function [thresh] = graythresh_triangle (img)

  nbins = 2**15;
  [counts, bins_centers] = hist (img(:), nbins);

  ## The algorithm assumes a high peak for bright values but this is
  ## fluorescence microscopy so invert the histogram.
  counts = counts(end:-1:1);
  [h_max, h_max_idx] = max (counts);

  ## The reference for the algorithm does not specify if the min is
  ## the first non-0 value or the first 0 zero before it.  But ImageJ
  ## and "Fundamentals of Image Processing" say bmin = (p=0)% so we
  ## "draw" the triangle from the non-existing bar before the first
  ## bar, to the highest histogram peak.  And we use the center of
  ## each bar for computations.
  triangle_range = 1:(h_max_idx-1);
  norm_heights = counts(triangle_range) ./ h_max;

  ## The positions of each bin center, as distance from the center of
  ## the 0 height bin before the histogram.  Do not compute the last
  ## bin because the threshold won't be there.
  norm_bin_positions = (1 ./ h_max_idx) .* triangle_range;

  distances = norm_bin_positions - norm_heights;
  [~, thresh] = max (distances);

  ## The space to find the threshold has been reduced twice. First, we
  ## throw away the whole dynamic range and use only the part where
  ## there's counts.  Then from that histogram we use only the part of
  ## the histogram from the peak to one of the sides.  Now we undo all
  ## that to get a threshold in range [0 1].
  range_end = getrangefromclass (img)(2);
  thresh_offset = bins_centers(1) ./ range_end;
  hist_range = (bins_centers(end) - bins_centers(1)) ./ range_end;

  hist_thresh = (numel (counts) - thresh) ./ hist_range;
  thresh = thresh_offset + hist_thresh;
  thresh = im2double (cast (thresh, class (img)));
endfunction
