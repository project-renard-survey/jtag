function res = density_features(rects, pixels, varargin)
% DENSITY_FEATURES   Subjects RECT to a variety of density related features.
%
%  DENSITY_FEATURES(RECT, PAGE, {THRESHOLD})  Runs the 4 element vector RECT
%  passed against 2 different desnsity features, each of which returns a
%  scalar value.  These values along with the feature name are built up as
%  fields in a struct, with one entry for each feature.  These entries are
%  combined in a cell array and returned as RES.
%
%  If THRESHOLD is specified, it should be given as a percentage (between
%  0 and 1), determining the amount of non-background pixels that must be found
%  for the side to be considered significant.  If not specified it defaults to
%  2 percent.


% CVS INFO %
%%%%%%%%%%%%
% $Id: density_features.m,v 1.2 2004-07-29 20:41:56 klaven Exp $
%
% REVISION HISTORY:
% $Log: density_features.m,v $
% Revision 1.2  2004-07-29 20:41:56  klaven
% Training data is now normalized if required.
%
% Revision 1.1  2004/06/19 00:27:26  klaven
% Re-organizing files.  Third step: re-add the files.
%
% Revision 1.6  2004/06/08 00:56:50  klaven
% Debugged new distance and density features.  Added a script to make training simpler.  Added a script to print out output.
%
% Revision 1.4  2004/06/01 21:38:21  klaven
% Updated the feature extraction methods to take all the rectangles at once, rather than work one at a time.  This allows for the extraction of features that use relations between rectangles.
%
% Revision 1.3  2004/06/01 19:24:34  klaven
% Assorted minor changes.  About to re-organize.
%
% Revision 1.2  2004/05/14 17:21:32  klaven
% Working on features for classification.  Realized that the distance features need some work.  Specifically, I think they are not being normalized properly, and several of them are redundant.
%
% Revision 1.1  2003/08/18 15:46:18  scottl
% Initial revision.  Merger of 2 previously individualy calculated density
% features.
%


% LOCAL VARS %
%%%%%%%%%%%%%%

threshold = .02;    % default threshold to use if not passed above
bg = 1;             % default value for background pixels
ink_count = 0;      % the # of non background pixels counted
get_names = false;  % determine if we are looking for names only


% first do some argument sanity checking on the arguments passed
error(nargchk(0,3,nargin));

if nargin == 0
    get_names = true;
elseif nargin == 1
    error('can not pass in 1 argument.  Must be 0, 2 or 3');
else
    [r, c] = size(pixels);

    if ndims(rects) > 2 | size(rects,2) ~= 4
        error('Each RECT passed must have exactly 4 elements');
    end;
    if min(rects(:,1)) < 1 | min(rects(:,2)) < 1 | ...
       max(rects(:,3)) > c | max(rects(:,4)) > r;
        error('RECT passed exceeds PAGE boundaries');
    end
    if nargin == 3
        if varargin{1} < 0 | varargin{1} > 1
            error('THRESHOLD passed must be a percentage (between 0 and 1)');
        end
        threshold = varargin{1};
    end
end

%res = {};


if get_names
    rects = ones(1);
end

for rr=1:size(rects,1);
rect = rects(rr,:);

% feature 1 counts the percentage of non-background pixels over the total
% number of pixels inside the rectangle passed.
res(rr,1).name  = 'rect_dens';
res(rr,1).norm = false;

% feature 2 is similar to 1, but calculates the percentage of non-backgorund
% pixels over the total number of pixels inside the "snapped" subrectangle of
% the rectangle passed.
res(rr,2).name  = 'sr_dens';
res(rr,2).norm = false;

% feature 3 is the "sharpness" of the horizontal projection.  This should help
% distinquish between text and non-text regions (when the document is
% properly aligned).
res(rr,3).name = 'h_sharpness';
res(rr,3).norm = false;

% feature 4 is a boolean indicating whether there appears to be a horizontal
% line stretching across the region.
res(rr,4).name = 'h_line';
res(rr,4).norm = true;

% feature 5 is a boolean indicating whether there appears to be a vertical
% line stretching across the region.
res(rr,5).name = 'v_line';
res(rr,5).norm = true;

% feature 6 is the fraction of the total ink falling in the left quarter
res(rr,6).name = 'left_quarter_ink_fraction';
res(rr,6).norm = false;

% features 7 and on deal with the number of marks on the page, and their sizes


if get_names
    return;
end

% calculate feature 1 value
left   = rect(1);
top    = rect(2);
right  = rect(3);
bottom = rect(4);

ink_count = 0;
for i = top:bottom
    for j = left:right
        if pixels(i, j) ~= bg
            ink_count = ink_count + 1;
        end
    end
end

res(rr,1).val = ink_count / ((bottom - top + 1) * (right - left + 1));


% now calculate feature 2 value
sr = get_sr(rect, pixels, threshold);
res(rr,2).val = ink_count / ((sr(4) - sr(2) + 1) * (sr(3) - sr(1) + 1));


% calculate feature 3 value
h = mean(pixels(top:bottom,left:right),2);
h = h(2:end) - h(1:(end-1));
h = h .* h;
res(rr,3).val = mean(h);


% calculate feature 4 value
temp = max(mean(1 - pixels(top:bottom,left:right),2));
if (temp > 0.9)
    res(rr,4).val = 1;
else
    res(rr,4).val = 0;
end;


% calculate feature 5 value
temp = max(mean(1 - pixels(top:bottom,left:right),1));
if (temp > 0.9)
    res(rr,5).val = 1;
else
    res(rr,5).val = 0;
end;


% calculate feature 6 value
v = mean(1 - pixels(top:bottom,left:right),1);
res(rr,6).val = sum(v(1:(round(end / 4)))) / sum(v);

end;
