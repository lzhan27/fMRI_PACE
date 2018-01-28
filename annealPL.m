function [maximum,fval] = annealPL(totCosts)
% [maximum,fval] = annealPL(totCosts, pl_eff)
% Input
% totCosts      is the cost paid to go from one node to another
% Output
% maximum       the best cut found: 1s and 2s to indicates groups
% fval          the value of psi at the best cut

nNodes = length(totCosts);  % number of nodes in the network
if nNodes < 5; maximum = []; fval = []; return; end
% parent is the initial guess
parent = ones(1,nNodes); parent(round(nNodes/2):end) = 2;
current = parent(randperm(nNodes));
% parameters
% counters etc
iter = 0;                       success = 0;            consec = 0;
initT = 1;                      stopT = 1e-8;           T = initT;
maxConsecRej = 2000;            maxSuccess = nNodes^2;  Niter = nNodes^2;
done = false;
% compute first iterations cost
initenergy = computePsi(totCosts,current);
oldEnergy = initenergy;
% keep track of best solution 
absMax = oldEnergy;             absMaxConf = current;

E = oldEnergy; c = 2; Tt = T;% quality test 

% group threshold
gTh = max([round(0.075*nNodes) 2]); %gTh = 0;
while ~done
    % terminate if no new mincost has been found for some time
    % Stop / decrement T criteria
    iter = iter+1;
    if iter >= Niter || success >= maxSuccess;
        if T < stopT || consec >= maxConsecRej;
            break;
        else
            T = 0.95*T;  % decrease T according to cooling schedule
            iter = 1;
            success = 0;
        end
    end     
    % randomly swap two elements
    notDiff = 1;
    while notDiff
        i1 = randi(nNodes);
        newGuess = current;
        newGuess(i1) = 3-newGuess(i1); %2->1 and 1->2
        nG1 = numel(find(newGuess == 1));
        if ~(nG1 < gTh || nG1 > nNodes-gTh); notDiff = 0; end % group size check
    end
    newEnergy = computePsi(totCosts,newGuess);
    
    if (newEnergy > oldEnergy) % new > old, we do maximization here
        current = newGuess;        
        oldEnergy = newEnergy;
        success = success+1;        
        consec = 0;
        E(c) = oldEnergy; c=c+1; Tt(c) = T;% quality test
    else % annealing
        if (exp(-(oldEnergy - newEnergy)/T)>rand) % old > new
            current = newGuess;            
            oldEnergy = newEnergy;
            success = success+1;
            E(c) = oldEnergy; c=c+1; Tt(c) = T;% quality test
        else
            consec = consec+1;
        end
    end 
    if (newEnergy>absMax)
        absMax = newEnergy;                
        absMaxConf = current;
    end
    iter = iter+1;
end
maximum = absMaxConf;
fval = absMax;