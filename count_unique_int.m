function [uniques,numUnique] = count_unique_int(x)
%COUNT_UNIQUE  Determines unique values for integers, and counts occurrences
%   [uniques,numUnique] = count_unique(x)
%
%   This function determines unique values of an array, and also counts the
%   number of instances of those values.
%
%   This uses the MATLAB builtin function accumarray, and is faster than
%   MATLAB's unique function for intermediate to large sizes of arrays for integer values.
%   Unlike 'unique' it cannot be used to determine if rows are unique or
%   operate on cell arrays.
%
%   Descriptions of Input Variables:
%   x:  Input vector or matrix, N-D of type integer
%
%   Descriptions of Output Variables:
%   uniques:    sorted unique values
%   numUnique:  number of instances of each unique value
%
%   Example(s):
%   >> [uniques] = count_unique(largeArray);
%   >> [uniques,numUnique] = count_unique(largeArray);
%
%   See also: unique, accumarray

% Author: Anthony Kendall
% Contact: anthony [dot] kendall [at] gmail [dot] com
% Created: 2009-03-17

nOut = nargout;
%First, determine the offset for negative values
x = int32(x);
minVal = min(x(:));

%Check to see if accumarray is appropriate for this function
% maxIndex = max(x(:)) - minVal + 1;
% if maxIndex / numel(x) > 1000
%     error('Accumarray is inefficient for arrays when ind values are >> than the number of elements')
% end
%Now, offset to get the index
index = x(:) - minVal + 1;
%Count the occurrences of each index value
numUnique = accumarray(index,1);
%Get the values which occur more than once
uniqueInd = int32((1:length(numUnique))');
uniques = int32(uniqueInd(numUnique>0)) + minVal - 1;
if nOut == 2
    %Trim the numUnique array
    numUnique = numUnique(numUnique>0);
end