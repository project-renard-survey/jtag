function res = classify_pg(class_names, jtag_file, class_fn, varargin)
% CLASSIFY_PG    Attempts to find and classify each rectangular subrectangle
%                of IMG_FILE as one of the clases in CLASS_NAMES by running 
%                the CLASS_FN algorithm.
%
%   RES = CLASSIFY_PG(CLASS_NAMES, IMG_FILE, CLASS_FN, {ARGS})  Opens the 
%   JTAG_FILE passed, then determines a collection of rectangular subregions 
%   using the xycut algorithm.  Each subregion is then classified 
%   as one of the classes listed in CLASS_NAMES using the classification 
%   algorithm defined by CLASS_FN and any additional arguments in ARGS.
%
%   Once the rectangles have been classified, the information is dumped out to
%   the appropriate jtag and jlog files, overwriting any existing files.
%
%   If there is a problem at any point an error is returned.  On success res
%   is set to 1, and 0 otherwise.
%
%   See also:  CREATE_TRAINING_DATA


% CVS INFO %
%%%%%%%%%%%%
% $Id: classify_pg.m,v 1.11 2004-10-06 20:21:29 klaven Exp $
% 
% REVISION HISTORY:
% $Log: classify_pg.m,v $
% Revision 1.11  2004-10-06 20:21:29  klaven
% *** empty log message ***
%
% Revision 1.10  2004/08/16 22:38:31  klaven
% *** empty log message ***
%
% Revision 1.9  2004/07/27 22:06:15  klaven
% classify_pg.m now passes the jtag file on to the classification functions.  This will allow these functions to use the file path of the image to determine what page number it is and how many pages are in the article.  This information can now be used as features.
%
% Revision 1.8  2004/06/28 16:22:38  klaven
% *** empty log message ***
%
% Revision 1.7  2004/06/19 00:25:17  klaven
% Re-organizing files.  First step: delete from old locations.
%
% Revision 1.6  2004/06/01 21:56:54  klaven
% Modified all functions that call the feature extraction methods to call them with all the rectanges at once.
%
% Revision 1.5  2004/01/19 01:44:57  klaven
% Updated the changes made over the last couple of months to the CVS.  I really should have learned how to do this earlier.
%
% Revision 1.4  2003/09/19 15:27:08  scottl
% Updates to remove always passing training data.  Now it is an optional
% argument since it is only needed for knn_fn.
%
% Revision 1.3  2003/09/11 18:25:23  scottl
% Amended previous fix, to ensure that rectangles are found, if none currently
% exist in the jtag file.
%
% Revision 1.2  2003/09/11 17:47:09  scottl
% Allowed use of existing rectangles (if found) to be used for classification.
%
% Revision 1.1  2003/08/26 20:36:24  scottl
% Initial revision.
%

% Load paths
%startup;


% LOCAL VARS %
%%%%%%%%%%%%%%

%disp('Trying to classify page');

jtag_extn = 'jtag';  %jtag filename extension
jlog_extn = 'jlog';  %jlog filename extension

s = [];  % the structure we will build as we classify the rectangles

% first do some sanity checking on the arguments passed
error(nargchk(3,inf,nargin));

if ~iscell(class_names) | size(class_names,1) ~= 1
    error('CLASS_NAMES must be a cell array listing one class per column');
end
if iscell(jtag_file) | ~ ischar(jtag_file) | size(jtag_file,1) ~= 1
    error('JTAG_FILE must contain a single string.');
end

% initialize components of the structure
s.class_name = class_names;
s.img_file = jtag_file;
s.rects = [];

res = nan;

% parse file_name to determine name of jtag and jlog files
dot_idx = regexp(jtag_file, '\.');
s.jtag_file = strcat(jtag_file(1:dot_idx(length(dot_idx))), jtag_extn);
s.jlog_file = strcat(jtag_file(1:dot_idx(length(dot_idx))), jlog_extn);


% get the list of rectangles to classify, first see if they already exist in a
% jtag file, otherwise build them from scratch
try
    tmp_struct = parse_jtag(s.jtag_file);
    s.img_file = tmp_struct.img_file;
    if size(tmp_struct.rects,1) < 1
        %fprintf('Found no rects in jtag file - should run xycuts.\n');
        error
    end
    s.rects = tmp_struct.rects;
catch
    %fprintf('Running xycut segmentation algorithm.\n');
    
    rects = xycut(s.img_file);
    % rects = dist_img(img_file);
    % rects = dist_img_red(img_file);
    %disp(strcat('Found ', int2str(size(rects,1)), ' rectangles'));
    s.rects = rects;
end

% attempt to open and load the pixel contents of IMG_FILE passed (to 
% ensure it exists)
pixels = imread(s.img_file);

for i = 1:size(s.rects,1)
    % s.rects = [s.rects; line_detect(pixels, rects(i,:))];
    % s.rects(i,:) = get_sr(s.rects(i,:), pixels);
    s.rects(i,:) = seg_snap(pixels, s.rects(i,:), 0);
end

%classify all rectangles
all_features = run_all_features(s.rects,s.img_file);
if ~isempty(varargin)
    s.class_id = feval(class_fn, s.class_name, all_features, ...
                       s, varargin{:});
else;
    s.class_id = feval(class_fn, s.class_name, all_features, s);
end;

if (size(s.class_id,1) < size(s.class_id,2));
    s.class_id = s.class_id';
end;

% loop to classify each reactangle
%all_features = run_all_features(s.rects,s.img_file);
%for i = 1:size(s.rects,1)
%    % run through all features for this rectangle
%    features = all_features(i,:);
%    if ~isempty(varargin)
%        s.class_id(i,:) = feval(class_fn, s.class_name, features, ...
%                                s, varargin{:});
%    else
%        s.class_id(i,:) = feval(class_fn, s.class_name, features, s);
%    end
%end

% dump the results out to jtag and jlog files
dump_jfiles(s);

res = s;

% SUBFUNCITON DECLARATIONS %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
