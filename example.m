% Reference:  
% Zhan L, Jenkins LM, Wolfson O, GadElkarim JJ, Nocito K, 
% Thompson PM, Ajilore O, Chung MK and Leow A. The Significance of Negative
% Correlations in Brain Connectivity. The Journal of Comparative Neurology. 2017 
% doi: 10.1002/cne.24274.
% http://onlinelibrary.wiley.com/wol1/doi/10.1002/cne.24274/abstract
% Email: Liang Zhan:  zhan.liang@gmail.com          
%        Alex  Leow:  alexfeuillet@gmail.com 

clear;clc;close all

load F1000_input.mat 
% this example data is a 986-subject resting state fMRI connectome dataset 
% from the 1000 functional connectome project 
% (17 subjects’ connectomes were discarded due to corrupted files), 
% downloaded from the USC multimodal connectivity database 
% (http://umcd.humanconnectomeproject.org). 
% The dimension of the network is 177x177.  

%compute the negative probability p map
my_mat=zeros(size(NW,1),size(NW,2));
for i=1:size(NW,1)-1
    for j=i+1:size(NW,2)
        tmp=squeeze(NW(i,j,:));
        my_mat(i,j)=length(find(tmp<0))/size(NW,3);
    end
end
p=my_mat+my_mat';

lev=3; 
% 2^(lev+1) must be less than the total number of nodes
% usually you can set lev=3~5 
% the larger the lev is set, the longer time it will take
% the output_tree will have 2^(lev+1) branches.
[output_tree, psi]= PACE_core(p,lev);

disp('done')
