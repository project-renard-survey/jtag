function res = ltc_build_all_td(batchname);
    evalstr = ['diary ' batchname 'diary.txt'];
    eval(evalstr);
    diary on;
    
    nipsTrainDirs = {'/p/learning/klaven/Journals/TAGGED/nips_2001/', ...
                     '/p/learning/klaven/Journals/TAGGED/nips_2002/'};
    nipsTestDirs = {'/p/learning/klaven/Journals/TEST_DATA/nips_2001/', ...
                    '/p/learning/klaven/Journals/TEST_DATA/nips_2002/'};

    jmlrTrainDirs = {'/p/learning/klaven/Journals/TAGGED/jmlr/'};
    jmlrTestDirs = {'/p/learning/klaven/Journals/TEST_DATA/jmlr/'};

    fprintf('For nips training data:\n');
    build_td(nipsTrainDirs,[batchname '-nips-train'],true);
    fprintf('For nips test data:\n');
    build_td(nipsTestDirs,[batchname '-nips-test'],false);

    fprintf('For jmlr training data:\n');
    build_td(jmlrTrainDirs,[batchname '-jmlr-train'],true);
    fprintf('For jmlr test data:\n');
    build_td(jmlrTestDirs,[batchname '-jmlr-test'],false);
    res = 0;
    diary off;
    


%*********************************************
% Subfunction Declarations

function res = build_td(dirs,fname,dolr);

    tmpfname = [fname '.ltc3.mat'];
    tmp1 = dir(tmpfname);
    if (length(tmp1)>0);
        if (nargin >= 3) && (dolr);
            fprintf('Training data already extracted.  Loading...\n');
            evalstr = ['load ' tmpfname];
            eval(evalstr);
            tmp_td = samples;
            featnames = fnames;
        end;
    else;
        trnfiles = {};
        for i=1:length(dirs);
            tmp1 = dir(strcat(dirs{i},'/*.jtag'));
            trnfiles = [trnfiles,strcat(dirs{i},{tmp1.name})];
        end;

        fprintf('     Found %i .jtag files in %i target dirs\n', ...
                length(trnfiles), length(dirs));

        tmp_td = {};
        fprintf('     Starting feature extraction\n');
        tmpfname = [fname '.ltc3.mat'];

        [tmp_td,featnames] = ltc3_create_td(trnfiles, {tmpfname});
        res = 1;

        fprintf('     Done feature extraction.\n');
    end;
    
    if (nargin == 3) && dolr;
        build_lr(tmp_td, featnames, fname);
        res = 1;
    end;

function res = build_lr(td, featnames, fname);

    fprintf('     Starting LR optimization.\n');
    tmp_lrweights = ltc3_create_lr_weights(td,featnames, ...
                                           1e-3,1e4, [fname '.lr.mat']);

    %weights_to_csv(tmp_lrweights, [fname '-lr-weights.csv']);
    
