function bestiter=findbestiter(namedir,verbose)
% bestiter=findbestiter(namedir,verbose);
% Finds the iteration with the lowest log-likelihood.
% namedir is the directory where are the results stored. The names of the
% results must contain *iter1* *iter2* etc... 
%
% Example: results stored in this folder
% simiter5/B11/results_updates_nmfclassic_nc24/
% are 
% results_iter1.mat, results_iter2.mat, results_iter3.mat
% Then one can call
% bestiter=findbestiter(['simiter5/B11/results_updates_nmfclassic_nc24'])

if ~exist('verbose','var')
    verbose = 0;
end

b = dir([namedir '/*iter*']);
if verbose
    fprintf('Found %d results.\n',size(b,1))
end
llbest = inf; 
bestiter =0;
for ii=1:size(b)
    load ([namedir '/' b(ii).name]);
    if peval.ddiv_end<llbest
        bestiter=ii;
        llbest=peval.ddiv_end;
    end
end
    