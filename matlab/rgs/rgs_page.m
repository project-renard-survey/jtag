function [segs,score] = rgs_page(jt,rgs_params);


if (ischar(jt));
    jt = jt_load(jt,0);
end;
pix = imread(jt.img_file);

if (ischar(rgs_params));
    evalstr = ['load ' rgs_params];
    eval(evalstr);
    rgs_params = savedweightvar;
end;

startseg = [1,1,size(pix,2),size(pix,1)];
startseg = seg_snap(pix,startseg);

[segs,score] = rgs(pix,startseg,rgs_params,1,0);




function [segs,score] = rgs(pix,seg_in,rgs_params,h,rec_lev);

scoremat = [];

score_in = rgs_eval(pix,seg_in,rgs_params,h);
cuts = get_cut_cands(pix,seg_in,h);
[subsegs,cuts] = cuts_to_segs(seg_in,cuts,pix,h,0); %This pads cuts as well
numsubsegs = size(subsegs.rects,1);
%fprintf('Entering rgs.  numsubsegs = %i, subsegs = \n', numsubsegs);
%disp(subsegs);
if (numsubsegs > 0);
    %fprintf('We have %i subsegs from %i cuts',numsubsegs, length(cuts));
    %disp(subsegs);
    %fprintf('cut_before:\n');
    %disp(subsegs.cut_before);
    %fprintf('cut_after:\n');
    %disp(subsegs.cut_after);
    scoremat = zeros(length(cuts));
end;
for i = 1:numsubsegs;
    fprintf('Recursion_level=%i, seg %i of %i\n',rec_lev,i,numsubsegs);
    c1 = subsegs.cut_before(i);
    c2 = subsegs.cut_after(i);
    if (c1 ~= 1) || (c2 < numsubsegs);
        [tmp1,tmp2] = rgs(pix,subsegs.rects(i,:),rgs_params,~h,rec_lev+1);
        %fprintf('Emerged from recursion on %i,%i.  tmp1=\n',c1,c2);
        %disp(tmp1);
        %fprintf('tmp2=\n');
        %disp(tmp2);
        scoremat(c1,c2) = tmp2;
        segmat(c1,c2).segs = tmp1;
    else; %Don't re-call rgs on the same seg (this prevents infinite
          %recursion.
        %fprintf('Not re-recursive on orig seg %i,%i.  score_in=\n',c1,c2);
        %disp(score_in);
        %fprintf('seg_in=\n');
        %disp(seg_in);
        scoremat(c1,c2) = score_in;
        segmat(c1,c2).segs = seg_in;
    end;
end;

if numsubsegs > 0; 
    %fprintf('Constructing best path with %i subsegs.  Scoremat = \n', ...
    %        numsubsegs);
    %disp(scoremat);
    [path,pathscore] = best_path(scoremat);
    
    segs = [];
    score = 0;
    for i=2:length(path);
        segs = [segs;segmat(path(i-1),path(i)).segs];
        score = score + scoremat(path(i-1),path(i));
    end;
    if (score ~= pathscore);
        fprintf('ERROR: score=%f, pathscore=%f\n',score,pathscore);
    end;
else;
    %fprintf('No subsegs available. score_in=\n');
    %disp(score_in);
    %fprintf('seg_in=\n');
    %disp(seg_in);
    segs = seg_in;
    score = score_in;
end;




function score = rgs_eval(pix,seg,rgs_params,h);
global rgs_eval_count;
rgs_eval_count = rgs_eval_count + 1;
score = 1;
return;

%global class_names;
%for i=1:length(class_names);
%    ll(i)=
%    
%    feats = rgs_get_features(pix,seg);
%    means = rgs_params.means(i,:);
%    sigma = rgs_params.variance(i);
%    pix_on = sum(sum(1-pix(seg(2):seg(4),seg(1):seg(3))));
%    pix_off = sum(sum(pix(seg(2):seg(4),seg(1):seg(3))));
%    ll(i) = log(rgs_params.class_priors(i)) - ...
%            sum(log(sqrt(2 * pi * sigma))) + ...
%            sum((feats - means)^2 ./ (2*(sigma)^2)) + ...
%            pix_on * log(rgs_params.pix_on_frac(i)) + ...
%            pix_off * log(1-rgs_params.pix_on_frac(i));
%    
%end;    
%    
%score = max(ll);
%

