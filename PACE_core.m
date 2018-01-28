function [IdxOrd, psi]= PACE_core(NW,level)
% this function computes multi-level binary tree partitioning of a brain
% network matrix according to the intra/inter-modularity cost function
% Input:
% NW        is the brain network matrix
% level     is the final level of the tree
% Output:
% IdxOrd    is the index order of the multi-stage partitioning, it is a cell
%           array where each row contains the indexes of the sub-partitions during
%           the evolution of the tree, the last row represents the last stage having
%           2^level partitions.
% psi       the maximized value of the Psi metric

%%
% Reference:  
% Zhan L, Jenkins LM, Wolfson O, GadElkarim JJ, Nocito K, 
% Thompson PM, Ajilore O, Chung MK and Leow A. The Significance of Negative
% Correlations in Brain Connectivity. The Journal of Comparative Neurology. 2017 
% doi: 10.1002/cne.24274.
% http://onlinelibrary.wiley.com/wol1/doi/10.1002/cne.24274/abstract
% Email: Liang Zhan:  zhan.liang@gmail.com          
%        Alex  Leow:  alexfeuillet@gmail.com  

% The authors hereby grant permission to use this software and its
% documentation for any purpose, provided that existing copyright
% notices are retained in all copies and that this notice is included
% verbatim in any distributions. Additionally, the authors grant
% permission to modify this software and its documentation for any
% purpose, provided that such modifications are not distributed without
% the explicit consent of the authors and that existing copyright
% notices are retained in all copies.
%
% IN NO EVENT SHALL THE AUTHORS OR DISTRIBUTORS BE LIABLE TO ANY PARTY FOR
% DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING OUT
% OF THE USE OF THIS SOFTWARE, ITS DOCUMENTATION, OR ANY DERIVATIVES THEREOF,
% EVEN IF THE AUTHORS HAVE BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
%
% THE AUTHORS AND DISTRIBUTORS SPECIFICALLY DISCLAIM ANY WARRANTIES, INCLUDING,
% BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
% PARTICULAR PURPOSE, AND NON-INFRINGEMENT.  THIS SOFTWARE IS PROVIDED ON AN
% "AS IS" BASIS, AND THE AUTHORS AND DISTRIBUTORS HAVE NO OBLIGATION TO PROVIDE
% MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.


num_node=size(NW,1);
eps=2/(num_node*(num_node-1));
% test for isolated nodes
if ~isempty(find(sum(NW) == 0, 1))
    %error('Isolated nodes exist can not continue.');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Modified by Liang Zhan on Dec 31, 2017
% for the isolated nodes we will add a eps 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	tmp=find(sum(NW) == 0, 1);
	for i=1:length(tmp)
	    tmpnode=tmp(i);
		NW(tmpnode,:)=eps;
		NW(:,tmpnode)=eps;
		NW(tmpnode,tmpnode)=0;
	end	
end

totCosts=NW;
nNodes = length(NW); % number of nodes in the NW
% initialization
IdxOrd{1,1} = 1:nNodes;
psi = zeros(level,2^(level-1));

clc
for i=1:level
    for j = 1:size(IdxOrd(i,:),2)
        if isempty(IdxOrd{i,j}); continue; end
        subCost = totCosts(IdxOrd{i,j},IdxOrd{i,j});        
        [maximum, fval] = annealPL(subCost);
        if fval > 0 % in case of positive Psi accept bifurcation
            IdxL = IdxOrd{i,j}((maximum == 1));
            IdxR = IdxOrd{i,j}((maximum == 2));
            IdxOrd{i+1,2*j-1} = IdxL;               IdxOrd{i+1,2*j} = IdxR;
            psi(i,j) = fval;
        else
            IdxOrd{i+1,2*j-1} = IdxOrd{i,j};        IdxOrd{i+1,2*j} = [];
        end
    end
end