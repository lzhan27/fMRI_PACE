function [Psi Inter Intra]= computePsi (costs, groupVect)
% [Psi Inter Intra]= computePsi (costs, groupVect,pl_eff)
% Input:
% costs:        total cost or total efficiency per node
% groupVect:    must be a vector with index of communities
% association of the labeled node to the corresponding group
% Output:
% Intra:        average intra-Comm cost
% Inter:        average inter-Comm cost
% Psi           =  Inter - Intra
%%
[groupVect NewIdx] = sort(groupVect);                           % order elements by community
[Communities NelePerCom]= count_unique_int(int32(groupVect));   % get communities and their elements
nCom = numel(Communities);                                      % get number of communities
if nCom > 2; error('Group Vector must have only two labels.'); end
costs = costs(NewIdx,NewIdx);                                   % rearrange the cost
nNodes = length(costs);
if (nNodes == nCom); Psi = 0; Inter = 0; Intra = 0; return; end	% every node is a community-> bad case
%% Note totCosts is a symmetric matrix we don't need to divide norL and norR by 2
% average intra-hemispheric cost left and right
Length1 = NelePerCom(1);        Length2 = NelePerCom(2);
norL = (Length1*(Length1-1));   norR = (Length2*(Length2-1));
m1 = sum(sum(costs(1:Length1,1:Length1)))/(norL);
m2 = sum(sum(costs(Length1+1:nNodes,Length1+1:nNodes)))/(norR);
% solve one node commnity problem
if norL == 0; m1 = 0; nCom = 1; end
if norR == 0; m2 = 0; nCom = 1; end
Intra = (m1 + m2)/nCom;
if isnan(Intra); Intra = inf; end
if (nCom == 1); Psi = -Intra; Inter = 0; return; end
%% compute inter cost
Inter = sum(sum(costs(1:Length1,Length1+1:nNodes)))/((nNodes/2)^2);
%% Psi = Einter - Eintra
Psi = Inter - Intra;